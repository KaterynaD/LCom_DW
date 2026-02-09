from datetime import datetime
import sys
from pathlib import Path

# Add ../../airflow/utils to PYTHONPATH (same pattern as the example)
UTILS_DIR = (Path(__file__).resolve().parents[1] / "utils")
sys.path.insert(0, str(UTILS_DIR))

from airflow import DAG
from airflow.operators.bash import BashOperator

import pendulum

local_tz = pendulum.timezone("America/Los_Angeles")

from dag_utils import (
    DBT_LCOM_DW_PROJECT_DIR,
    notify_task_failure,
    create_set_load_date_task,
    create_notify_summary_task,
)

default_args = {
    "owner": "airflow",
    "depends_on_past": False,
    "retries": 0,
    "email_on_failure": False,  # we use custom callback instead
    "email_on_retry": False,
}

with DAG(
    dag_id="sfdc_base_profiles_manual_run",
    description="SFDC: Manual run - base profiles for schema audit (manual trigger only)",
    default_args=default_args,
    start_date=datetime(2025, 1, 1, tzinfo=local_tz),
    schedule=None,           # manual trigger only
    max_active_runs=1,
    catchup=False,
    tags=["dbt", "sfdc", "profiles", "manual", "schema_audit"],
) as dag:

    # --------------------------------------------------------------------
    # Load date (shared utility task)
    # --------------------------------------------------------------------
    set_load_date_task = create_set_load_date_task(dag)

    # --------------------------------------------------------------------
    # DAG-specific core task
    # --------------------------------------------------------------------
    run_sfdc_base_profiles = BashOperator(
        task_id="run_sfdc_base_profiles",
        bash_command=(
            f"cd {DBT_LCOM_DW_PROJECT_DIR} && "
            "dbt run "
            "--select \"tag:sfdc_profile\" "
            "--target sfdc "
            "--vars '{"
            "\"sfdc_profile_name\": \"base\", "
            "\"loaddate\": \"{{ ti.xcom_pull(task_ids='Start_Load.Set_Load_Date', key='LoadDate') }}\""
            "}' "
        ),
        on_failure_callback=notify_task_failure,
    )

    # Shared summary email at the end
    notify_summary = create_notify_summary_task(
        dag,
        run_name="SFDC Base Profiles (schema audit)",
    )

    # Final wiring
    set_load_date_task >> run_sfdc_base_profiles >> notify_summary
