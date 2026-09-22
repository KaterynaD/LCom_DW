from __future__ import annotations

from collections.abc import Mapping
import sys
from functools import partial
from pathlib import Path



UTILS_DIR = Path(__file__).resolve().parents[1] / "utils"
if str(UTILS_DIR) not in sys.path:
    sys.path.insert(0, str(UTILS_DIR))

from prefect import flow, get_run_logger, task
from prefect.states import State
from prefect.utilities.annotations import quote
from prefect.variables import Variable
from prefect_sqlalchemy import SqlAlchemyConnector


from html import escape as html_escape
from typing import Any, Dict, List


from dbt_utils import run_dbt, set_loaddate, get_compiled_sql_sfdc_schema_drift_path
from dryrun import DryRun, simulate
from flow_utils import (
    run_sequential_tasks,
    task_dry_run,
    get_variable_as_bool,
)
from colibri_lineage import get_column_lineage

import os
from environment_utils import get_env_path

DBT_TARGET_PATH = get_env_path("DBT_TARGET_PATH")
MANIFEST_PATH = os.path.join(DBT_TARGET_PATH, "colibri-manifest.json")

from smtp_utils import send_flow_report,send_task_failure_email,send_email



# ------------------------------------------------------------------------
# Helper functions for generating HTML report
# ------------------------------------------------------------------------

def to_html_table(rows: List[Dict[str, Any]]) -> str:
    headers = [
        "source",
        "source_column",
        "direct_usage",
        "downstream_usage",
        "error",
        "flg",
    ]

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
    parts.append(
        "<thead><tr>"
        + "".join(f"<th>{html_escape(h)}</th>" for h in headers)
        + "</tr></thead>"
    )
    parts.append("<tbody>")

    for r in rows:
        tds: List[str] = []

        for h in headers:
            val = r.get(h, "")
            cell = fmt_list(val)

            if h == "error" and cell:
                tds.append(
                    f"<td class='err'>{html_escape(cell)}</td>"
                )
            else:
                tds.append(
                    f"<td>{html_escape(cell)}</td>"
                )

        parts.append("<tr>" + "".join(tds) + "</tr>")

    parts.append("</tbody></table>")

    return "\n".join(parts)


def generate_html_report(
    profiles_results,
    missing_columns_results,
):
    """Generate HTML report from query results."""

    logger = get_run_logger()

    logger.info(
        f"Generating HTML report: "
        f"{len(profiles_results)} profile rows, "
        f"{len(missing_columns_results)} missing column rows"
    )

    html = "SFDC Schema Drift Audit Report"

    # Profiles stats table
    html += "<h3>Profile Statistics</h3>"
    html += (
        "<table border='1' style='border-collapse: collapse;'>"
    )
    html += (
        "<tr>"
        "<th>Table Name</th>"
        "<th>Base Profile Collected On</th>"
        "<th>Base Profile Columns Count</th>"
        "<th>Current Profile Collected On</th>"
        "<th>Current Profile Columns Count</th>"
        "<th>Difference in Columns Counts</th>"
        "</tr>"
    )

    for row in profiles_results:
        (
            table_name,
            base_date,
            base_cols,
            current_date,
            current_cols,
            diff,
        ) = row

        row_style = (
            "background-color: #ffcccc;"
            if diff != 0
            else ""
        )

        html += (
            f"<tr style='{row_style}'>"
            f"<td>{table_name}</td>"
            f"<td>{base_date}</td>"
            f"<td>{base_cols}</td>"
            f"<td>{current_date}</td>"
            f"<td>{current_cols}</td>"
            f"<td>{diff}</td>"
            f"</tr>"
        )

    html += "</table>"

    # Missing columns table
    html += "<h3>Missing Columns Analysis</h3>"

    if missing_columns_results:
        logger.info(
            "Found missing columns, generating lineage table"
        )

        outputs: List[Dict[str, Any]] = []

        for row in missing_columns_results:
            source_name, table_name, column_name, flg = row

            lineage_info = get_column_lineage(
                MANIFEST_PATH,
                source_name,
                column_name,
                flg,
            )

            outputs.append(lineage_info)

            if (
                lineage_info["error"]
                != "Paths found, but none reached any model.* nodes."
            ):
                logger.info(
                    f"{source_name}.{column_name} is used in models. "
                    f"Base profile needs to be reviewed"
                )


                Variable.set(
                                "use_existing_base_profile",
                                "YES",
                                overwrite=True,
                            )

        html += to_html_table(outputs)

    else:
        logger.info("No missing columns detected")

        html += "<p>No schema drift detected today.</p>"

        logger.info(
            "Base profile is replaced with current profile "
            "for next runs since no missing columns detected"
        )

        Variable.set(
            "use_existing_base_profile",
            "NO",
            overwrite=True,
                )



    return html

# ------------------------------------------------------------------------
# Helper functions to send HTML report
# ------------------------------------------------------------------------

def send_email_report(html_content: str) -> None:
    """Send email with the schema drift report."""

    logger = get_run_logger()

    subject = "SFDC Schema Drift Audit Report"

    logger.info(f"Sending email report")

    send_email(
        subject=subject,
        body="SFDC Schema Drift Audit Report",
        html_content=html_content,
    )

    logger.info("Email report sent successfully")

# ------------------------------------------------------------------------
# FDC Schema Drift Analyses
# ------------------------------------------------------------------------    

@task(
    task_run_name="SFDC Schema Drift Analyses",
    on_failure=[send_task_failure_email],
)
def run_schema_drift_analysis(
    dry_run: DryRun = DryRun.REAL,
) -> State[Any] | None:
    """Run schema drift analysis, generate report, and send email."""

    state = simulate(dry_run, "End Flow")

    if state is not None:
        return state

    logger = get_run_logger()
    logger.info("Starting schema drift analysis")

    with SqlAlchemyConnector.load("redshift-default") as db:

        # Run profiles_stats.sql
        profiles_stats_path = (
            get_compiled_sql_sfdc_schema_drift_path("profiles_stats.sql")
        )

        with open(profiles_stats_path, "r") as f:
            profiles_stats_sql = f.read()

        logger.info(f"Running SQL: {profiles_stats_path}")

        profiles_results = list(
            db.fetch_all(profiles_stats_sql)
        )

        logger.info(
            f"Profiles stats query returned {len(profiles_results)} rows"
        )

        # Run missing_columns_lineage.sql
        missing_columns_lineage_path = (
            get_compiled_sql_sfdc_schema_drift_path(
                "missing_columns_lineage.sql"
            )
        )

        with open(missing_columns_lineage_path, "r") as f:
            missing_columns_lineage_sql = f.read()

        logger.info(f"Running SQL: {missing_columns_lineage_path}")

        missing_columns_lineage_results = list(
            db.fetch_all(missing_columns_lineage_sql)
        )

        logger.info(
            f"Missing columns lineage query returned "
            f"{len(missing_columns_lineage_results)} rows"
        )

    # Generate HTML report
    logger.info("Generating SFDC schema drift HTML report")

    html_report = generate_html_report(
        profiles_results,
        missing_columns_lineage_results,
    )

    logger.info("SFDC schema drift HTML report generated")

    # Send report
    send_email_report(html_report)

    logger.info("SFDC schema drift analysis completed")

    return None

@flow
def sfdc_schema_drift_audit_flow(
    task_dry_runs: Mapping[str, DryRun] | None = None,
) -> None:

    loaddate = set_loaddate()

    task_states = {}

    """
    If USE_EXISTING_BASE_PROFILE == "NO" run dbt macros to replace base profile.
    If "YES" skip and continue.
    """

    tasks = [

         (
            "Delete Base Profile",
            partial(
                run_dbt,
                command_name="Delete Base Profile",
                target="sfdc",
                run_enabled= not get_variable_as_bool("use_existing_base_profile", default=True),
            ),
        ),      
        (
            "Reset Profiles Current to Base",
            partial(
                run_dbt,
                command_name="Reset Profiles Current to Base",
                target="sfdc",
                run_enabled= not get_variable_as_bool("use_existing_base_profile", default=True),
            ),
        ),  
        (
            "SFDC Current Profiles",
            partial(
                run_dbt,
                command_name="SFDC Current Profiles",
                loaddate=loaddate,
                target="sfdc",
            ),
        ),                   
        (
            "SFDC Schema Drift Analyses",
            partial(
                run_dbt,
                command_name="SFDC Schema Drift Analyses",
                target=Variable.get("target", default="dev")
            ),
        ),
    (
        "Run Schema Drift Analysis",
        run_schema_drift_analysis,
    ),
    ]

    



    run_sequential_tasks(tasks, task_states, task_dry_runs)


    send_flow_report(
        task_states=quote(task_states),
        dry_run=task_dry_run("Send Flow Report", task_dry_runs),
    )


if __name__ == "__main__":
    state = sfdc_schema_drift_audit_flow(
        task_dry_runs={
            "Delete Base Profile": DryRun.REAL,
            "Reset Profiles Current to Base": DryRun.REAL,
            "SFDC Current Profiles": DryRun.REAL,
            "SFDC Schema Drift Analyses": DryRun.REAL,
            "Run Schema Drift Analysis": DryRun.REAL,
            "Send Flow Report": DryRun.REAL,
        },
        return_state=True,
    )

    print(state)
