from datetime import datetime
import os
import sys
from pathlib import Path,PurePosixPath

# Add ../../airflow/Utils to PYTHONPATH
UTILS_DIR = (Path(__file__).resolve().parents[1] / "utils")
sys.path.insert(0, str(UTILS_DIR))

import json
import logging
from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.python import PythonOperator
from airflow.operators.empty import EmptyOperator
from airflow.operators.python import PythonOperator, BranchPythonOperator

from airflow.utils.trigger_rule import TriggerRule
from airflow.exceptions import AirflowSkipException

from airflow.models import Variable
from airflow.hooks.postgres_hook import PostgresHook
from airflow.utils.email import send_email

from html import escape as html_escape
from typing import Any, Dict, List






from colibri_lineage import get_column_lineage  

import pendulum

local_tz = pendulum.timezone("America/Los_Angeles")

from dag_utils import (
    DBT_PROFILES_DIR,
    DBT_TARGET_DIR,
    DBT_LCOM_DW_PROJECT_DIR,
    ALERT_EMAIL,
    notify_task_failure,
    create_notify_summary_task,
    create_set_load_date_task,
    create_create_connection_task,
    create_profile_task,
)

MANIFEST_PATH = os.path.join(DBT_TARGET_DIR, "colibri-manifest.json")

# SQL queries for base profile management
DELETE_BASE_PROFILE_SQL = """
delete from rawdata.profiles.sfdc_schema_audit  where profile_name='base';
"""

RENAME_CURRENT_TO_BASE_SQL = """
update rawdata.profiles.sfdc_schema_audit
set profile_name='base'
where profile_name='current';
"""


# 8 PM Pacific by default
SCHEDULE_SFDC_SCHEMA_DRIFT_AUDIT = Variable.get("SCHEDULE_SFDC_SCHEMA_DRIFT_AUDIT", default_var="0 20 * * *")

RUN_COLUMN_LINEAGE_FLAG = Variable.get("RUN_COLUMN_LINEAGE_FLAG", default_var="YES").upper()

USE_EXISTING_BASE_PROFILE = Variable.get("USE_EXISTING_BASE_PROFILE", default_var="YES").upper()

# ------------------------------------------------------------------------
# Manage base profile based on Airflow variable
# ------------------------------------------------------------------------
def manage_base_profile():
    """Check USE_EXISTING_BASE_PROFILE variable and manage base profile accordingly."""


    if USE_EXISTING_BASE_PROFILE == "NO":
        # Delete existing base profile and rename current to base
        hook = PostgresHook(postgres_conn_id='redshift_sfdc')
        hook.run(DELETE_BASE_PROFILE_SQL)
        hook.run(RENAME_CURRENT_TO_BASE_SQL)

# ------------------------------------------------------------------------
# Get compiled SQL path
# ------------------------------------------------------------------------
def get_compiled_sql_path(filename):
    """Get the path to the compiled SQL file."""
    return os.path.join(DBT_TARGET_DIR, "compiled", "LCom_DW", "analyses", "SFDC_schema_drift", filename)

# ------------------------------------------------------------------------
# Run schema drift analysis and send report
# ------------------------------------------------------------------------
def run_schema_drift_analysis():
    """Run compiled SQL queries and generate schema drift report."""
    logging.info("Starting schema drift analysis")
    hook = PostgresHook(postgres_conn_id='redshift_default')

    # Run profiles_stats.sql
    profiles_stats_path = get_compiled_sql_path("profiles_stats.sql")
    with open(profiles_stats_path, 'r') as f:
        profiles_stats_sql = f.read()

    profiles_results = hook.get_records(profiles_stats_sql)
    logging.info(f"Profiles stats query returned {len(profiles_results)} rows")

    # Run missing_columns_lineage.sql
    missing_columns_lineage_path = get_compiled_sql_path("missing_columns_lineage.sql")
    with open(missing_columns_lineage_path, 'r') as f:
        missing_columns_lineage_sql = f.read()

    missing_columns_lineage_results = hook.get_records(missing_columns_lineage_sql)
    logging.info(f"Missing columns lineage query returned {len(missing_columns_lineage_results)} rows")

    # Generate HTML report
    html_report = generate_html_report(profiles_results, missing_columns_lineage_results)
    # Send email with report
    send_email_report(html_report)

def to_html_table(rows: List[Dict[str, Any]]) -> str:
    headers = ["source", "source_column", "direct_usage", "downstream_usage", "error"]

    def fmt_list(v: Any) -> str:
        if isinstance(v, list):
            return ", ".join(str(x) for x in v)
        return "" if v is None else str(v)

    parts: List[str] = []
    
    parts.append(
        "<style>"
        "body{font-family:Arial, sans-serif; padding:16px}"
        "table{border-collapse:collapse; width:100%}"
        "th,td{border:1px solid #ccc; padding:8px; vertical-align:top}"
        "th{background:#f5f5f5; text-align:left}"
        ".err{color:#b00020; font-weight:600}"
        "</style>"
    )
    parts.append("</head><body>")
    parts.append("<h2>Column Lineage Report</h2>")
    parts.append("<table>")
    parts.append("<thead><tr>" + "".join(f"<th>{html_escape(h)}</th>" for h in headers) + "</tr></thead>")
    parts.append("<tbody>")

    for r in rows:
        tds: List[str] = []
        for h in headers:
            val = r.get(h, "")
            cell = fmt_list(val)
            if h == "error" and cell:
                tds.append(f"<td class='err'>{html_escape(cell)}</td>")
            else:
                tds.append(f"<td>{html_escape(cell)}</td>")
        parts.append("<tr>" + "".join(tds) + "</tr>")

    parts.append("</tbody></table>")
    
    return "\n".join(parts)

def generate_html_report(profiles_results, missing_columns_results):
    """Generate HTML report from query results."""
    logging.info(f"Generating HTML report: {len(profiles_results)} profile rows, {len(missing_columns_results)} missing column rows")
    html = "<h2>SFDC Schema Drift Audit Report</h2>"

    # Profiles stats table
    html += "<h3>Profile Statistics</h3>"
    html += "<table border='1' style='border-collapse: collapse;'>"
    html += "<tr><th>Table Name</th><th>Base Profile Collected On</th><th>Base Profile Columns Count</th><th>Current Profile Collected On</th><th>Current Profile Columns Count</th><th>Difference in Columns Counts</th></tr>"

    for row in profiles_results:
        table_name, base_date, base_cols, current_date, current_cols, diff = row
        row_style = "background-color: #ffcccc;" if diff != 0 else ""
        html += f"<tr style='{row_style}'><td>{table_name}</td><td>{base_date}</td><td>{base_cols}</td><td>{current_date}</td><td>{current_cols}</td><td>{diff}</td></tr>"

    html += "</table>"

    # Missing columns table
    html += "<h3>Missing Columns Analysis</h3>"
    if missing_columns_results:
        logging.info("Found missing columns, generating lineage table")


        outputs: List[Dict[str, Any]] = []

        for row in missing_columns_results:
            source_name, table_name,  column_name = row
            outputs.append(get_column_lineage(MANIFEST_PATH, source_name, column_name))
        
        html_table = to_html_table(outputs)

        html += html_table

        
    else:

        logging.info("No missing columns detected")
        html += "<p>No schema drift detected today.</p>"

    return html


def send_email_report(html_content):
    """Send email with the schema drift report."""
    logging.info("Preparing to send email report")
    subject = "SFDC Schema Drift Audit Report"
    to = ALERT_EMAIL
    body = f"""
    <html>
    <body>
    {html_content}
    </body>
    </html>
    """

    try:
        logging.info(f"Sending email to {to} with subject '{subject}'")
        send_email(
            to=to,
            subject=subject,
            html_content=body
        )
        logging.info("Email sent successfully")
    except Exception as e:
        logging.error(f"Failed to send email: {e}")
        raise

    
def branch_on_column_lineage_flag():
    """Run lineage tasks only when RUN_COLUMN_LINEAGE_FLAG == 'YES'."""
    return "compile_analyses" if RUN_COLUMN_LINEAGE_FLAG == "YES" else "skip_column_lineage"    

# ------------------------------------------------------------------------
# DAG definition
# ------------------------------------------------------------------------
default_args = {
    "owner": "airflow",
    "depends_on_past": False,
    "retries": 0,
    "email_on_failure": False,  # we use custom callback instead
    "email_on_retry": False,
}


with DAG(
    dag_id="sfdc_schema_drift_audit",
    description="SFDC: Schema drift audit - compare profiles and report missing columns (manual trigger only)",
    start_date=datetime(2025, 1, 1, tzinfo=local_tz),
    schedule=SCHEDULE_SFDC_SCHEMA_DRIFT_AUDIT,
    catchup=False,
    max_active_runs=1,
    default_args=default_args,
    tags=["dbt", "sfdc", "profiles", "schema_drift", "audit", "maintenance"],
) as dag:



    # 2. Set LoadDate (XCom)
    set_load_date_task = create_set_load_date_task(dag)

    # 3. Create/update Redshift connection
    create_connection = create_create_connection_task(dag)

    # 4. Manage base profile based on Airflow variable
    manage_base_profile_task = PythonOperator(
        task_id="manage_base_profile",
        python_callable=manage_base_profile,
        on_failure_callback=notify_task_failure,
    )

    # 5. Create new current profiles in parallel
    profile_account = create_profile_task("account", "current")
    profile_opportunity = create_profile_task("opportunity", "current")
    profile_opportunity_line_item = create_profile_task("opportunity_line_item", "current")
    profile_case = create_profile_task("case", "current")
    profile_training_session_c = create_profile_task("training_session_c", "current")
    profile_product_2 = create_profile_task("product_2", "current")
    profile_user = create_profile_task("user", "current")
    profile_contact = create_profile_task("contact", "current")
    profile_campaign = create_profile_task("campaign", "current")


    # 6. Join + gate: wait for all profile tasks to finish, then require at least one success
    profiles_1 = [
        profile_account,
        profile_opportunity,
        profile_opportunity_line_item,
        profile_case]
    
    profiles_2 = [       
        profile_training_session_c,
        profile_product_2,
        profile_user,
    ]


    profiles_3 = [       
        profile_contact,
        profile_campaign
    ]   

    # Barrier: wait for ALL profile tasks to finish (success/failed/skipped)
    profiles_1_done = EmptyOperator(
        task_id="profiles_1_done",
        trigger_rule=TriggerRule.ALL_DONE,
    )

    profiles_2_done = EmptyOperator(
        task_id="profiles_2_done",
        trigger_rule=TriggerRule.ALL_DONE,
    )

    profiles_3_done = EmptyOperator(
        task_id="profiles_3_done",
        trigger_rule=TriggerRule.ALL_DONE,
    )


    def require_one_profile_success(**context):
        """Skip downstream if no profile_* task succeeded."""
        tis = context["dag_run"].get_task_instances()
        state_by_id = {ti.task_id: ti.state for ti in tis}
        states = [state_by_id.get(t.task_id) for t in profiles_1 + profiles_2 + profiles_3]

        if not any(s == "success" for s in states):
            raise AirflowSkipException("No profile_* task succeeded; skipping compile/analysis.")

    require_one_success = PythonOperator(
        task_id="require_one_profile_success",
        python_callable=require_one_profile_success,
        trigger_rule=TriggerRule.ALL_DONE,
        on_failure_callback=notify_task_failure,
    )


    # Creates columns lineage if variable set RUN_COLUMN_LINEAGE_FLAG to YES



    branch_column_lineage = BranchPythonOperator(
    task_id="branch_column_lineage",
    python_callable=branch_on_column_lineage_flag,
    trigger_rule=TriggerRule.ALL_SUCCESS,
    on_failure_callback=notify_task_failure,
  )

    skip_column_lineage = EmptyOperator(
    task_id="skip_column_lineage",
  )

    dbt_compile = BashOperator(
        task_id="dbt_compile",
        bash_command=(
            f"cd {DBT_LCOM_DW_PROJECT_DIR} && "
            "dbt compile"
        ),
        trigger_rule=TriggerRule.ALL_SUCCESS,
        on_failure_callback=notify_task_failure,
    )    


    dbt_docs_generate = BashOperator(
        task_id="dbt_docs_generate",
        bash_command=(
            f"cd {DBT_LCOM_DW_PROJECT_DIR} && "
            "dbt docs generate"
        ),
        trigger_rule=TriggerRule.ALL_SUCCESS,
        on_failure_callback=notify_task_failure,
    )   

    colibri_generate = BashOperator(
        task_id="colibri_generate",
        bash_command=(
            f"cd {DBT_LCOM_DW_PROJECT_DIR} && "
            "colibri generate --manifest $DBT_TARGET_PATH/manifest.json --catalog $DBT_TARGET_PATH/catalog.json --output-dir $DBT_TARGET_PATH"
        ),
        trigger_rule=TriggerRule.ALL_SUCCESS,
        on_failure_callback=notify_task_failure,
    )    

    # Compile dbt analyses queries (runs only if the gate task succeeds)
    compile_query = BashOperator(
        task_id="compile_analyses",
        bash_command=(
            f"cd {DBT_LCOM_DW_PROJECT_DIR} && "
            "dbt compile --select missing_columns_lineage profiles_stats"
        ),
        trigger_rule=TriggerRule.ALL_SUCCESS,
        on_failure_callback=notify_task_failure,
    )

    # 7. Run schema drift analysis and send report
    run_analysis = PythonOperator(
        task_id="run_schema_drift_analysis",
        python_callable=run_schema_drift_analysis,
        trigger_rule=TriggerRule.NONE_FAILED_MIN_ONE_SUCCESS,
        on_failure_callback=notify_task_failure,
    )

    # 8. Shared summary email at the end
    notify_summary = create_notify_summary_task(
        dag,
        run_name="SFDC Schema Drift Audit Daily Run",
    )

    # Final wiring
    set_load_date_task >> create_connection >> manage_base_profile_task
    
    # CHANGE Final wiring (replace the last line with this)
    manage_base_profile_task >> profiles_1 >> profiles_1_done >> profiles_2 >> profiles_2_done >> profiles_3 >> profiles_3_done >> require_one_success >> branch_column_lineage
    branch_column_lineage >> compile_query >> dbt_compile >> dbt_docs_generate >> colibri_generate >> run_analysis >> notify_summary
    branch_column_lineage >> skip_column_lineage >> run_analysis



