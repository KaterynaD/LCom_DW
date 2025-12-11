from datetime import datetime

from airflow import DAG
from airflow.operators.bash import BashOperator

from dag_utils import (
    DBT_LCOM_DW_PROJECT_DIR,
    notify_task_failure,
    create_init_branch,
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
    dag_id="5_lcom_dw_manual_restore_fk",
    description="LCom DW: dbt run-operation Recreating_all_FK (manual trigger only)",
    default_args=default_args,
    start_date=datetime(2024, 1, 1),
    schedule_interval=None,
    catchup=False,
    tags=["dbt", "lcom_dw", "fk", "maintenance" ],
) as dag:

    # Shared "init" branch:
    # decide_init -> [refresh_git_repo, skip_dbt_init] -> init_done
    init_done = create_init_branch(dag)

    # DAG-specific core task 
    core_task =BashOperator(
        task_id="run_dbt_recreating_all_fk",
        bash_command=(
            f"cd {DBT_LCOM_DW_PROJECT_DIR} && "
            "dbt run-operation Recreating_all_FK"
        ),
        on_failure_callback=notify_task_failure,
    )

    # Shared summary email at the end
    notify_summary = create_notify_summary_task(
        dag,
        run_name="LCom DW: dbt run-operation Recreating_all_FK",
    )

    # Final wiring
    init_done >> core_task >> notify_summary
