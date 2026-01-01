from datetime import datetime
import os
from pathlib import Path,PurePosixPath

import logging
from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.python import PythonOperator
from airflow.models import Connection
from airflow import settings
from airflow.models import Variable
from airflow.hooks.postgres_hook import PostgresHook
from airflow.utils.email import send_email

from dag_utils import (
    DBT_PROFILES_DIR,
    DBT_LCOM_DW_PROJECT_DIR,
    ALERT_EMAIL,
    notify_task_failure,
    create_init_branch,
    create_notify_summary_task,
    create_set_load_date_task,
    create_create_connection_task,
)

# SQL queries for base profile management
DELETE_BASE_PROFILE_SQL = """
delete from rawdata.profiles.sfdc_schema_audit  where profile_name='base';
"""

RENAME_CURRENT_TO_BASE_SQL = """
update rawdata.profiles.sfdc_schema_audit
set profile_name='base'
where profile_name='current';
"""





# ------------------------------------------------------------------------
# Manage base profile based on Airflow variable
# ------------------------------------------------------------------------
def manage_base_profile():
    """Check USE_EXISTING_BASE_PROFILE variable and manage base profile accordingly."""
    try:
        use_existing = Variable.get("USE_EXISTING_BASE_PROFILE")
    except:
        # Variable doesn't exist, create it with default value
        Variable.set("USE_EXISTING_BASE_PROFILE", "NO")
        use_existing = "NO"

    if use_existing.upper() == "NO":
        # Delete existing base profile and rename current to base
        hook = PostgresHook(postgres_conn_id='redshift_sfdc')
        hook.run(DELETE_BASE_PROFILE_SQL)
        hook.run(RENAME_CURRENT_TO_BASE_SQL)

# ------------------------------------------------------------------------
# Get compiled SQL path
# ------------------------------------------------------------------------
def get_compiled_sql_path(filename):
    """Get the path to the compiled SQL file."""
    return os.path.join(DBT_LCOM_DW_PROJECT_DIR, "target", "compiled", "LCom_DW", "analyses", "SFDC_schema_drift", filename)

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

    # Run missing_columns.sql
    missing_columns_path = get_compiled_sql_path("missing_columns.sql")
    with open(missing_columns_path, 'r') as f:
        missing_columns_sql = f.read()

    missing_columns_results = hook.get_records(missing_columns_sql)
    logging.info(f"Missing columns query returned {len(missing_columns_results)} rows")

    # Generate HTML report
    html_report = generate_html_report(profiles_results, missing_columns_results)

    # Send email with report
    send_email_report(html_report)

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
        logging.info("Found missing columns, generating table")
        html += "<table border='1' style='border-collapse: collapse;'>"
        html += "<tr><th>Table Name</th><th>Model Path</th><th>Column Name</th><th>Present in Model</th></tr>"

        for row in missing_columns_results:
            table_name, model_name, column_name = row
            present_in_model = check_column_in_model(model_name, column_name) if column_name else "N/A"
            html += f"<tr><td>{table_name}</td><td>{model_name}</td><td>{column_name or 'N/A'}</td><td>{present_in_model}</td></tr>"

        html += "</table>"
    else:
        logging.info("No missing columns detected")
        html += "<p>No schema drift detected today.</p>"

    return html

def check_column_in_model(model_path, column_name):
    """Check if column is present in the specified dbt model file."""
    if not model_path or not column_name:
        return "N/A"

    full_path = PurePosixPath(DBT_LCOM_DW_PROJECT_DIR) / model_path.lstrip("/")

    logging.info(f"Analyzing file:  {str(full_path)} rows")

    
    try:
        with open(full_path, 'r') as f:
            content = f.read()
            return "Yes" if column_name.lower() in content.lower() else "No"
    except:
        return "Error reading file"

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

def create_profile_task(table_name):
    """Create a profile task for a given SFDC table."""
    args_dict = {
        'database_name': 'rawdata',
        'schema_name': 'fivetran_salesforce_quickstart',
        'table_name': table_name,
        'profiles_db': 'rawdata',
        'profiles_schema': 'profiles',
        'profiles_table': 'sfdc_schema_audit',
        'profile_name': 'current',
        'exclude_stats_numeric': ['placeholder', 'min', 'max', 'avg', 'stddev_pop', 'cnt_neg', 'cnt_zero', 'cnt_pos', 'cnt_int'],
        'exclude_stats_varchar': ['placeholder', 'min_length', 'max_length', 'avg_length', 'cnt_leading_ws', 'cnt_trailing_ws', 'cnt_empty_after_trim', 'cnt_lower', 'cnt_upper', 'cnt_mixed', 'cnt_cast_int', 'cnt_cast_decimal', 'cnt_cast_date', 'cnt_cast_timestamp'],
        'exclude_stats_datetime': ['placeholder', 'min', 'max'],
        'exclude_columns':['num_opps_c','nc_tier_1_c','last_activity_logged_on_c','district_nces_c'],
        'loaddate': '{{ ti.xcom_pull(task_ids=\'Start_Load.Set_Load_Date\', key=\'LoadDate\') }}'
    }
    args_str = json.dumps(args_dict)
    return BashOperator(
        task_id=f"profile_{table_name.replace('_', '_')}",
        bash_command=(
            f"cd {DBT_LCOM_DW_PROJECT_DIR} && "
            "dbt run-operation create_profile "
            f"--args '{args_str}' "
            "--target sfdc"
        ),
        on_failure_callback=notify_task_failure,
    )

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
    default_args=default_args,
    start_date=datetime(2024, 1, 1),
    schedule_interval=None,  # Manual runs only for testing
    catchup=False,
    tags=["dbt", "sfdc", "profiles", "schema_drift", "audit", "maintenance"],
) as dag:

    # Shared "init" branch:
    # decide_init -> [refresh_git_repo, skip_dbt_init] -> init_done
    init_done = create_init_branch(dag)

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
    profile_account = create_profile_task("account")
    profile_opportunity = create_profile_task("opportunity")
    profile_opportunity_line_item = create_profile_task("opportunity_line_item")
    profile_case = create_profile_task("case")
    profile_training_session_c = create_profile_task("training_session_c")
    profile_product_2 = create_profile_task("product_2")

    # 6. Compile dbt analyses queries
    compile_query = BashOperator(
        task_id="compile_analyses",
        bash_command=(
            f"cd {DBT_LCOM_DW_PROJECT_DIR} && "
            "dbt compile --select missing_columns profiles_stats"
        ),
        on_failure_callback=notify_task_failure,
    )

    # 7. Run schema drift analysis and send report
    run_analysis = PythonOperator(
        task_id="run_schema_drift_analysis",
        python_callable=run_schema_drift_analysis,
        on_failure_callback=notify_task_failure,
    )

    # 8. Shared summary email at the end
    notify_summary = create_notify_summary_task(
        dag,
        run_name="SFDC Schema Drift Audit Daily Run",
    )

    # Final wiring
    init_done >> set_load_date_task >> create_connection >> manage_base_profile_task
    manage_base_profile_task >> [profile_account, profile_opportunity, profile_opportunity_line_item, profile_case, profile_training_session_c, profile_product_2] >> compile_query >> run_analysis >> notify_summary
