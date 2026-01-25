import os
import sys
from pathlib import Path
# Add ../../airflow/Utils to PYTHONPATH
UTILS_DIR = (Path(__file__).resolve().parents[1] / "utils")
sys.path.insert(0, str(UTILS_DIR))

from datetime import datetime

from airflow import DAG
from airflow.operators.bash import BashOperator

from dag_utils import (
    DBT_LCOM_DW_PROJECT_DIR,
    notify_task_failure,
    create_set_load_date_task,
    create_notify_summary_task,
)

from dbt_run_utils import (    
    make_run_lcom_dw_snapshots_task
)

default_args = {
    "owner": "airflow",
    "depends_on_past": False,
    "retries": 0,
    "email_on_failure": False,  # we use custom callback instead
    "email_on_retry": False,
}

with DAG(
    dag_id="4_lcom_dw_manual_run_snapshots",
    description="LCom DW: dbt Manual run - snapshots (manual trigger only)",
    default_args=default_args,
    start_date=datetime(2024, 1, 1),
    catchup=False,
    tags=["dbt", "lcom_dw", "snapshots", "maintenance" ],
) as dag:

    # --------------------------------------------------------------------
    # Load date
    # --------------------------------------------------------------------
    set_load_date_task = create_set_load_date_task(dag)

    # DAG-specific core task 
    core_task = make_run_lcom_dw_snapshots_task(dag,
        run_type="Manual Prod run - tag:snapshot",
    )

    # Shared summary email at the end
    notify_summary = create_notify_summary_task(
        dag,
        run_name="LCom DW: dbt Manual run - snapshots",
    )

    # Final wiring
    set_load_date_task >> core_task >> notify_summary