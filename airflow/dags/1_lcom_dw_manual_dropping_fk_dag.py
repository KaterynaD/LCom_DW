from datetime import datetime
import os
import sys
from pathlib import Path
# Add ../../airflow/Utils to PYTHONPATH
UTILS_DIR = (Path(__file__).resolve().parents[1] / "utils")
sys.path.insert(0, str(UTILS_DIR))

from airflow import DAG
from airflow.operators.bash import BashOperator

from dag_utils import (
    DBT_LCOM_DW_PROJECT_DIR,
    notify_task_failure,
    create_set_load_date_task,
    create_notify_summary_task,
)

from dbt_run_utils import (
    make_run_drop_all_fk_task
)

default_args = {
    "owner": "airflow",
    "depends_on_past": False,
    "retries": 0,
    "email_on_failure": False,  # we use custom callback instead
    "email_on_retry": False,
}

with DAG(
    dag_id="1_lcom_dw_manual_dropping_fk",
    description="LCom DW: dbt run-operation Dropping_all_FK (manual trigger only)",
    default_args=default_args,
    start_date=datetime(2024, 1, 1),
    schedule=None,          
    max_active_runs=1,      
    catchup=False,
    tags=["dbt", "lcom_dw", "fk", "maintenance"],
) as dag:

    # --------------------------------------------------------------------
    # Load date
    # --------------------------------------------------------------------
    set_load_date_task = create_set_load_date_task(dag)

    # DAG-specific core task 
    core_task = make_run_drop_all_fk_task(dag)

    # Shared summary email at the end
    notify_summary = create_notify_summary_task(
        dag,
        run_name="LCom DW manual Dropping_all_FK",
    )

    # Final wiring
    set_load_date_task >> core_task >> notify_summary