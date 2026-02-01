from datetime import datetime
import os
import sys
from pathlib import Path
# Add ../../airflow/Utils to PYTHONPATH
UTILS_DIR = (Path(__file__).resolve().parents[1] / "utils")
sys.path.insert(0, str(UTILS_DIR))

from airflow import DAG
from airflow.operators.bash import BashOperator



import pendulum

local_tz = pendulum.timezone("America/Los_Angeles")

# 8 PM Pacific by default
SCHEDULE_LCOM_DW_PRODUCT_USAGE_RUN = Variable.get("SCHEDULE_LCOM_DW_PRODUCT_USAGE_RUN", default_var="30 2 * * *")

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
    dag_id="0_lcom_dw_scheduled_product_usage_scheduled_run",
    description="LCom DW: Product Usage run",
    default_args=default_args,
    start_date=datetime(2025, 1, 1, tzinfo=local_tz),
    schedule=SCHEDULE_LCOM_DW_PRODUCT_USAGE_RUN, 
    max_active_runs=1,      
    catchup=False,
    tags=["dbt", "lcom_dw", "product usage", "scheduled"],
) as dag:

    # --------------------------------------------------------------------
    # Load date
    # --------------------------------------------------------------------
    set_load_date_task = create_set_load_date_task(dag)

    # DAG-specific core task 
    run_product_usage = BashOperator(
        task_id="run_lcom_dw_product_usage",
        bash_command=(
            f"cd {DBT_LCOM_DW_PROJECT_DIR} && "
            "dbt run "
            "--select tag:product_usage "
            "--exclude \"config.materialized:view\" "
            "--vars '{"
            "\"run_type\": \"Scheduled Prod run - product_usage\", "
            "\"loaddate\": \"{{ ti.xcom_pull(task_ids='Start_Load.Set_Load_Date', key='LoadDate') }}\""
            "}' "
        ),
        on_failure_callback=notify_task_failure,
    )

    test_product_usage = BashOperator(
        task_id="test_lcom_dw_product_usage",
        bash_command=(
            f"cd {DBT_LCOM_DW_PROJECT_DIR} && "
            "dbt test "
            "--select tag:product_usage "
            "--vars '{"
            "\"run_type\": \"Scheduled Prod test - product_usage\", "
            "\"loaddate\": \"{{ ti.xcom_pull(task_ids='Start_Load.Set_Load_Date', key='LoadDate') }}\""
            "}' "
        ),
        on_failure_callback=notify_task_failure,
    )


    # Shared summary email at the end
    notify_summary = create_notify_summary_task(
        dag,
        run_name="LCom DW Product Usage Load",
    )

    # Final wiring
    set_load_date_task >> run_product_usage >> test_product_usage >> notify_summary



