from datetime import datetime
import os

from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.python import PythonOperator
from airflow.operators.empty import EmptyOperator
from airflow.operators.python import BranchPythonOperator
from airflow.utils.trigger_rule import TriggerRule
from airflow.utils.email import send_email
from airflow.exceptions import AirflowException
from airflow.models import Variable


from dag_utils import (
    DBT_LCOM_DW_PROJECT_DIR,
    notify_task_failure,
    create_init_branch,
    create_notify_summary_task,
    init_flag,
    create_set_load_date_task,
)








# ------------------------------------------------------------------------
# Check that core tasks all succeeded
# ------------------------------------------------------------------------
def check_core_tasks(**context):
    dag_run = context["dag_run"]
    

    # Base core tasks that must always succeed
    core_task_ids = [
        "Start_Load.Set_Load_Date",
        "run_dbt_dropping_all_fk",
        "run_lcom_dw_common",
    ]

    # Only treat repo/deps as mandatory when we are initializing
    if init_flag == "YES":
        core_task_ids = ["refresh_git_repo", "run_dbt_deps"] + core_task_ids

    bad_states = []
    for tid in core_task_ids:
        ti = dag_run.get_task_instance(tid)
        if ti is None or ti.state != "success":
            bad_states.append(f"{tid}: {ti.state if ti else 'no TI'}")

    if bad_states:
        # This will mark check_core_success as failed,
        # which prevents recreate_all_fk (with ONE_SUCCESS) from running.
        raise AirflowException(
            "Core tasks did not all succeed: " + ", ".join(bad_states)
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
    dag_id="0_lcom_dw_full_scheduled_run",
    description="LCom DW: full run (git pull + dbt deps + main dbt runs)",
    default_args=default_args,
    start_date=datetime(2024, 1, 1),
    schedule_interval=None,   # change to cron when ready to schedule
    catchup=False,
    tags=["dbt", "lcom_dw", "scheduled", "full_load" ],
) as dag:

    # Shared "init" branch:
    # decide_init -> [refresh_git_repo, skip_dbt_init] -> init_done
    init_done = create_init_branch(dag)

    # 3. Set LoadDate (XCom)
    set_load_date_task = create_set_load_date_task(dag, trigger_rule=TriggerRule.NONE_FAILED_MIN_ONE_SUCCESS)

    # 4. drop_all_fk
    drop_all_fk = BashOperator(
        task_id="run_dbt_dropping_all_fk",
        bash_command=(
            f"cd {DBT_LCOM_DW_PROJECT_DIR} && "
            "dbt run-operation Dropping_all_FK"
        ),
        on_failure_callback=notify_task_failure,
    )

    # 5. run_common
    run_common = BashOperator(
        task_id="run_lcom_dw_common",
        bash_command=(
            f"cd {DBT_LCOM_DW_PROJECT_DIR} && "
            "dbt run "
            "--select tag:common "
            "--exclude \"config.materialized:view\" "
            "--vars '{"
            "\"run_type\": \"Scheduled Prod run - common\", "
            "\"loaddate\": \"{{ ti.xcom_pull(task_ids='Start_Load.Set_Load_Date', key='LoadDate') }}\""
            "}' "
        ),
        on_failure_callback=notify_task_failure,
    )

    # 6.1 run_licensing (parallel)
    run_licensing = BashOperator(
        task_id="run_lcom_dw_licensing",
        bash_command=(
            f"cd {DBT_LCOM_DW_PROJECT_DIR} && "
            "dbt run "
            "--select tag:licensing "
            "--exclude \"config.materialized:view\" "
            "--vars '{"
            "\"run_type\": \"Scheduled Prod run - licensing\", "
            "\"loaddate\": \"{{ ti.xcom_pull(task_ids='Start_Load.Set_Load_Date', key='LoadDate') }}\""
            "}' "
            "--threads 1"
        ),
        on_failure_callback=notify_task_failure,
    )

    # 6.2 run_training_sessions (parallel)
    run_training_sessions = BashOperator(
        task_id="run_lcom_dw_training_sessions",
        bash_command=(
            f"cd {DBT_LCOM_DW_PROJECT_DIR} && "
            "dbt run "
            "--select tag:training "
            "--exclude \"config.materialized:view\" "
            "--vars '{"
            "\"run_type\": \"Scheduled Prod run - training sessions\", "
            "\"loaddate\": \"{{ ti.xcom_pull(task_ids='Start_Load.Set_Load_Date', key='LoadDate') }}\""
            "}' "
            "--threads 1"
        ),
        on_failure_callback=notify_task_failure,
    )

    # 6.3 run_support (parallel)
    run_support = BashOperator(
        task_id="run_lcom_dw_support",
        bash_command=(
            f"cd {DBT_LCOM_DW_PROJECT_DIR} && "
            "dbt run "
            "--select tag:support "
            "--exclude \"config.materialized:view\" "
            "--vars '{"
            "\"run_type\": \"Scheduled Prod run - support\", "
            "\"loaddate\": \"{{ ti.xcom_pull(task_ids='Start_Load.Set_Load_Date', key='LoadDate') }}\""
            "}' "
            "--threads 1"
        ),
        on_failure_callback=notify_task_failure,
    )

    # 6.4 run_revenue (parallel)
    run_revenue = BashOperator(
        task_id="run_lcom_dw_revenue",
        bash_command=(
            f"cd {DBT_LCOM_DW_PROJECT_DIR} && "
            "dbt run "
            "--select tag:revenue "
            "--exclude \"config.materialized:view\" "
            "--vars '{"
            "\"run_type\": \"Scheduled Prod run - tag:revenue\", "
            "\"loaddate\": \"{{ ti.xcom_pull(task_ids='Start_Load.Set_Load_Date', key='LoadDate') }}\""
            "}' "
            "--threads 1"
        ),
        on_failure_callback=notify_task_failure,
    )

    # 6.5 run_cdu (parallel)
    run_cdu = BashOperator(
        task_id="run_lcom_dw_cdu",
        bash_command=(
            f"cd {DBT_LCOM_DW_PROJECT_DIR} && "
            "dbt run "
            "--select tag:cdu "
            "--exclude \"config.materialized:view\" "
            "--vars '{"
            "\"run_type\": \"Scheduled Prod run - tag:cdu\", "
            "\"loaddate\": \"{{ ti.xcom_pull(task_ids='Start_Load.Set_Load_Date', key='LoadDate') }}\""
            "}' "
            "--threads 1"
        ),
        on_failure_callback=notify_task_failure,
    )

    # Check that core tasks all succeeded (controls whether FK recreation is allowed)
    check_core_success = PythonOperator(
        task_id="check_core_success",
        python_callable=check_core_tasks,
        provide_context=True,
        trigger_rule=TriggerRule.ALL_DONE,  # run even if run_common fails
    )

    # 7. Snapshots:
    run_snapshots = BashOperator(
        task_id="run_lcom_dw_snapshots",
        bash_command=(
            f"cd {DBT_LCOM_DW_PROJECT_DIR} && "
            "dbt run "
            "--select tag:snapshot "
            "--exclude \"config.materialized:view\" "
            "--vars '{"
            "\"run_type\": \"Scheduled Prod run - tag:snapshot\", "
            "\"loaddate\": \"{{ ti.xcom_pull(task_ids='Start_Load.Set_Load_Date', key='LoadDate') }}\""
            "}' "
        ),
        trigger_rule=TriggerRule.ONE_SUCCESS,  # require at least one success (check_core_success)
        on_failure_callback=notify_task_failure,
    )

    # 8. Recreate FK:
    recreate_all_fk = BashOperator(
        task_id="run_dbt_recreating_all_fk",
        bash_command=(
            f"cd {DBT_LCOM_DW_PROJECT_DIR} && "
            "dbt run-operation Recreating_all_FK"
        ),
        trigger_rule=TriggerRule.ONE_SUCCESS,  # require at least one success (check_core_success)
        on_failure_callback=notify_task_failure,
    )

    # 9. Tests:
    run_tests = BashOperator(
        task_id="run_lcom_dw_tests",
        bash_command=(
            f"cd {DBT_LCOM_DW_PROJECT_DIR} && "
            "dbt test "
            "--exclude \"config.materialized:view\" \"tag:product_usage\" "
            "--vars '{\"run_type\": \"Scheduled Prod test\"}'"
        ),
        trigger_rule=TriggerRule.ONE_SUCCESS,  # require at least one success (check_core_success)
        on_failure_callback=notify_task_failure,
    )

    # 10. Always send summary email with success/failed tasks
    notify_summary = create_notify_summary_task(
        dag,
        run_name="LCom DW Full Load",
    )

    # --------------------------------------------------------------------
    # Dependencies
    # --------------------------------------------------------------------


    # If we init: refresh_git_repo -> run_dbt_deps -> set_load_date
    init_done  >> set_load_date_task

    # Common path from here on
    set_load_date_task >> drop_all_fk >> run_common

    run_common >> [run_licensing, run_training_sessions, run_support, run_revenue, run_cdu]
    run_common >> check_core_success

    [run_licensing, run_training_sessions, run_support, run_revenue, run_cdu, check_core_success] >> run_snapshots >> recreate_all_fk >> run_tests >> notify_summary
