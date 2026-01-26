import os
import sys
from pathlib import Path
# Add ../../airflow/Utils to PYTHONPATH
UTILS_DIR = (Path(__file__).resolve().parents[1] / "utils")
sys.path.insert(0, str(UTILS_DIR))


from datetime import datetime

from airflow import DAG
from airflow.models import Variable
from airflow.operators.empty import EmptyOperator
from airflow.operators.python import BranchPythonOperator
from airflow.utils.task_group import TaskGroup
from airflow.utils.trigger_rule import TriggerRule

from airflow.exceptions import AirflowSkipException
from airflow.utils.state import TaskInstanceState



from dag_utils import (
    notify_task_failure,
    create_set_load_date_task,
    create_notify_summary_task,
)
from dbt_run_utils import (
    make_run_lcom_dw_common_task,
    make_run_lcom_dw_licensing_task,
    make_run_lcom_dw_training_sessions_task,
    make_run_lcom_dw_support_task,
    make_run_lcom_dw_revenue_task,
    make_run_lcom_dw_cdu_task,
    make_run_lcom_dw_snapshots_task,
    make_run_drop_all_fk_task,
    make_run_recreating_all_fk_task,
    make_run_tests_task,
)

# ------------------------------------------------------------------------
# Helper
# ------------------------------------------------------------------------
def _any_success(task_ids: list[str], **context) -> bool:
    """
    Return True if at least one of task_ids finished with SUCCESS in this DagRun.
    """
    dag_run = context["dag_run"]
    for tid in task_ids:
        ti = dag_run.get_task_instance(tid)
        if ti and ti.state == TaskInstanceState.SUCCESS:
            return True
    return False

def _is_yes(value: str | None) -> bool:
    return str(value or "").strip().lower() in {"yes", "y", "true", "1"}

def make_toggle_task_group(
    dag: DAG,
    *,
    group_id: str,
    task_id: str,
    var_name: str,          
    make_task_fn,
    make_task_kwargs: dict | None = None,
) -> tuple[TaskGroup, EmptyOperator]:
    """
    TaskGroup layout:
        check_enabled (Branch)
           ├─ <real task>
           └─ skipped
              ↓
             join  (TriggerRule.NONE_FAILED_MIN_ONE_SUCCESS)
    """
    make_task_kwargs = make_task_kwargs or {}

    with TaskGroup(group_id=group_id, dag=dag) as tg:

        def _choose_branch(**_):
            enabled = _is_yes(Variable.get(var_name, default_var="Yes"))
            return f"{group_id}.{task_id}" if enabled else f"{group_id}.skipped"

        check_enabled = BranchPythonOperator(
            task_id="check_enabled",
            python_callable=_choose_branch,
        )

        real_task = make_task_fn(
            dag,
            **make_task_kwargs,
        )

        skipped = EmptyOperator(task_id="skipped")
        join = EmptyOperator(
            task_id="join",
            trigger_rule=TriggerRule.NONE_FAILED_MIN_ONE_SUCCESS,
        )

        check_enabled >> [real_task, skipped]
        [real_task, skipped] >> join

    return tg, join


# ------------------------------------------------------------------------
# DAG
# ------------------------------------------------------------------------
default_args = {"owner": "airflow", "depends_on_past": False, "retries": 0}

with DAG(
    dag_id="0_lcom_dw_scheduled_full_run_dag",
    default_args=default_args,
    start_date=datetime(2024, 1, 1),
    schedule=None,          
    max_active_runs=1, 
    catchup=False,
    tags=["lcom_dw", "dbt", "scheduled"],
) as dag:


    set_load_date_task = create_set_load_date_task(dag)

    # -------------------------
    # Toggle groups (explicit var_name per task)
    # -------------------------

    tg_drop_fk, drop_fk_join = make_toggle_task_group(
        dag,
        group_id="tg_drop_all_fk",
        task_id="drop_all_fk",
        var_name="RUN__DROP_ALL_FK",
        make_task_fn=make_run_drop_all_fk_task
    )

    tg_common, common_join = make_toggle_task_group(
        dag,
        group_id="tg_common",
        task_id="run_common",
        var_name="RUN__COMMON",
        make_task_fn=make_run_lcom_dw_common_task,
        make_task_kwargs={
            "run_type": "Scheduled Prod run - common",
            "threads": 1
        },
    )

    tg_licensing, licensing_join = make_toggle_task_group(
        dag,
        group_id="tg_licensing",
        task_id="run_licensing",
        var_name="RUN__LICENSING",
        make_task_fn=make_run_lcom_dw_licensing_task,
        make_task_kwargs={
            "run_type": "Scheduled Prod run - licensing",
            "threads": 1
        },
    )

    tg_training, training_join = make_toggle_task_group(
        dag,
        group_id="tg_training_sessions",
        task_id="run_training_sessions",
        var_name="RUN__TRAINING_SESSIONS",
        make_task_fn=make_run_lcom_dw_training_sessions_task,
        make_task_kwargs={
            "run_type": "Scheduled Prod run - training sessions",
            "threads": 1
        },
    )

    tg_support, support_join = make_toggle_task_group(
        dag,
        group_id="tg_support",
        task_id="run_support",
        var_name="RUN__SUPPORT",
        make_task_fn=make_run_lcom_dw_support_task,
        make_task_kwargs={
            "run_type": "Scheduled Prod run - support",
            "threads": 1
        },
    )

    tg_revenue, revenue_join = make_toggle_task_group(
        dag,
        group_id="tg_revenue",
        task_id="run_revenue",
        var_name="RUN__REVENUE",
        make_task_fn=make_run_lcom_dw_revenue_task,
        make_task_kwargs={
            "run_type": "Scheduled Prod run - revenue",
            "threads": 1
        },
    )

    tg_cdu, cdu_join = make_toggle_task_group(
        dag,
        group_id="tg_cdu",
        task_id="run_cdu",
        var_name="RUN__CDU",
        make_task_fn=make_run_lcom_dw_cdu_task,
        make_task_kwargs={
            "run_type": "Scheduled Prod run - cdu",
            "threads": 1
        },
    )


    snapshots_gate = BranchPythonOperator(
    task_id="snapshots_gate",
    trigger_rule=TriggerRule.ALL_DONE,  # waits for all upstream terminal states
    python_callable=lambda **context: (
        "tg_snapshots.check_enabled"
        if _any_success(
            [
                "tg_licensing.join",
                "tg_training_sessions.join",
                "tg_support.join",
                "tg_revenue.join",
                "tg_cdu.join",
            ],
            **context,
        )
        else "tg_snapshots.skipped"
    ),
    )

    tg_snapshots, snapshots_join = make_toggle_task_group(
    dag,
    group_id="tg_snapshots",
    task_id="run_snapshots",
    var_name="RUN__SNAPSHOTS",
    make_task_fn=make_run_lcom_dw_snapshots_task,
    make_task_kwargs={
        "run_type": "Scheduled Prod run - snapshots",
        "threads": 1,
    },
   )

    tg_recreate_fk, recreate_fk_join = make_toggle_task_group(
        dag,
        group_id="tg_recreate_all_fk",
        task_id="recreate_all_fk",
        var_name="RUN__RECREATE_ALL_FK",
        make_task_fn=make_run_recreating_all_fk_task
    )

    tg_tests, tests_join = make_toggle_task_group(
        dag,
        group_id="tg_tests",
        task_id="run_tests",
        var_name="RUN__TESTS",
        make_task_fn=make_run_tests_task
    )


    notify_summary = create_notify_summary_task(
        dag,
        run_name="LCom DW Full Load",
    )


    # -------------------------
    # Dependencies
    # -------------------------
    set_load_date_task >> tg_drop_fk
    drop_fk_join >> tg_common

    # fan-out after common
    common_join >> [tg_licensing, tg_training, tg_support, tg_revenue, tg_cdu] 

    # wait until all branches finished (ran or skipped), then snapshots
    [licensing_join, training_join, support_join, revenue_join, cdu_join] >> snapshots_gate
    snapshots_gate >> tg_snapshots

    snapshots_join >> tg_recreate_fk
    recreate_fk_join >> tg_tests
    tests_join >> notify_summary