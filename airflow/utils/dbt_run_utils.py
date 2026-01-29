# utils/dbt_run_utils.py

from typing import Optional
from airflow.operators.bash import BashOperator

from dag_utils import (
    DBT_LCOM_DW_PROJECT_DIR,
    notify_task_failure,
)


def make_run_lcom_dw_common_task(dag,  run_type: str, threads: Optional[int] = None, **operator_kwargs,) -> BashOperator:
    threads_part = f"--threads {threads}" if threads is not None else ""

    return BashOperator(dag=dag,
        task_id="run_common",
        bash_command=(
            f"cd {DBT_LCOM_DW_PROJECT_DIR} && "
            "dbt run "
            "--select tag:common "
            "--exclude \"config.materialized:view\" "
            "--vars '{"
            f"\"run_type\": \"{run_type}\", "
            "\"loaddate\": \"{{ ti.xcom_pull(task_ids='Start_Load.Set_Load_Date', key='LoadDate') }}\""
            "}' "
            f"{threads_part}"
        ),
        on_failure_callback=notify_task_failure,
        **operator_kwargs, 
    )


def make_run_lcom_dw_licensing_task(dag,  run_type: str, threads: Optional[int] = None, **operator_kwargs,) -> BashOperator:
    threads_part = f"--threads {threads}" if threads is not None else ""

    return BashOperator(dag=dag,
        task_id="run_licensing",
        bash_command=(
            f"cd {DBT_LCOM_DW_PROJECT_DIR} && "
            "dbt run "
            "--select tag:licensing "
            "--exclude \"config.materialized:view\" "
            "--vars '{"
            f"\"run_type\": \"{run_type}\", "
            "\"loaddate\": \"{{ ti.xcom_pull(task_ids='Start_Load.Set_Load_Date', key='LoadDate') }}\""
            "}' "
            f"{threads_part}"
        ),
        on_failure_callback=notify_task_failure,
        **operator_kwargs, 
    )


def make_run_lcom_dw_training_sessions_task(dag,  run_type: str, threads: Optional[int] = None, **operator_kwargs,) -> BashOperator:
    threads_part = f"--threads {threads}" if threads is not None else ""

    return BashOperator(dag=dag,
        task_id="run_training_sessions",
        bash_command=(
            f"cd {DBT_LCOM_DW_PROJECT_DIR} && "
            "dbt run "
            "--select tag:training "
            "--exclude \"config.materialized:view\" "
            "--vars '{"
            f"\"run_type\": \"{run_type}\", "
            "\"loaddate\": \"{{ ti.xcom_pull(task_ids='Start_Load.Set_Load_Date', key='LoadDate') }}\""
            "}' "
            f"{threads_part}"
        ),
        on_failure_callback=notify_task_failure,
        **operator_kwargs, 
    )


def make_run_lcom_dw_support_task(dag,  run_type: str, threads: Optional[int] = None, **operator_kwargs,) -> BashOperator:
    threads_part = f"--threads {threads}" if threads is not None else ""

    return BashOperator(dag=dag,
        task_id="run_support",
        bash_command=(
            f"cd {DBT_LCOM_DW_PROJECT_DIR} && "
            "dbt run "
            "--select tag:support "
            "--exclude \"config.materialized:view\" "
            "--vars '{"
            f"\"run_type\": \"{run_type}\", "
            "\"loaddate\": \"{{ ti.xcom_pull(task_ids='Start_Load.Set_Load_Date', key='LoadDate') }}\""
            "}' "
            f"{threads_part}"
        ),
        on_failure_callback=notify_task_failure,
        **operator_kwargs, 
    )


def make_run_lcom_dw_revenue_task(dag,  run_type: str, threads: Optional[int] = None, **operator_kwargs,) -> BashOperator:
    threads_part = f"--threads {threads}" if threads is not None else ""

    return BashOperator(dag=dag,
        task_id="run_revenue",
        bash_command=(
            f"cd {DBT_LCOM_DW_PROJECT_DIR} && "
            "dbt run "
            "--select tag:revenue "
            "--exclude \"config.materialized:view\" "
            "--vars '{"
            f"\"run_type\": \"{run_type}\", "
            "\"loaddate\": \"{{ ti.xcom_pull(task_ids='Start_Load.Set_Load_Date', key='LoadDate') }}\""
            "}' "
            f"{threads_part}"
        ),
        on_failure_callback=notify_task_failure,
        **operator_kwargs, 
    )


def make_run_lcom_dw_cdu_task(dag,  run_type: str, threads: Optional[int] = None, **operator_kwargs,) -> BashOperator:
    threads_part = f"--threads {threads}" if threads is not None else ""

    return BashOperator(
        task_id="run_cdu",
        bash_command=(  
            f"cd {DBT_LCOM_DW_PROJECT_DIR} && "
            "dbt run "
            "--select tag:cdu "
            "--exclude \"config.materialized:view\" "
            "--vars '{"
            f"\"run_type\": \"{run_type}\", "
            "\"loaddate\": \"{{ ti.xcom_pull(task_ids='Start_Load.Set_Load_Date', key='LoadDate') }}\""
            "}' "
            f"{threads_part}"
        ),
        on_failure_callback=notify_task_failure,
        **operator_kwargs, 
    )

def make_run_lcom_dw_marketing_task(dag,  run_type: str, threads: Optional[int] = None, **operator_kwargs,) -> BashOperator:
    threads_part = f"--threads {threads}" if threads is not None else ""

    return BashOperator(
        task_id="run_marketing",
        bash_command=(  
            f"cd {DBT_LCOM_DW_PROJECT_DIR} && "
            "dbt run "
            "--select tag:marketing "
            "--exclude \"config.materialized:view\" "
            "--vars '{"
            f"\"run_type\": \"{run_type}\", "
            "\"loaddate\": \"{{ ti.xcom_pull(task_ids='Start_Load.Set_Load_Date', key='LoadDate') }}\""
            "}' "
            f"{threads_part}"
        ),
        on_failure_callback=notify_task_failure,
        **operator_kwargs, 
    )

def make_run_lcom_dw_revenue_and_marketing_task(dag,  run_type: str, threads: Optional[int] = None, **operator_kwargs,) -> BashOperator:
    threads_part = f"--threads {threads}" if threads is not None else ""

    return BashOperator(
        task_id="run_revenue_and_marketing",
        bash_command=(  
            f"cd {DBT_LCOM_DW_PROJECT_DIR} && "
            "dbt run "
            "--select tag:revenue tag:marketing "
            "--exclude \"config.materialized:view\" "
            "--vars '{"
            f"\"run_type\": \"{run_type}\", "
            "\"loaddate\": \"{{ ti.xcom_pull(task_ids='Start_Load.Set_Load_Date', key='LoadDate') }}\""
            "}' "
            f"{threads_part}"
        ),
        on_failure_callback=notify_task_failure,
        **operator_kwargs, 
    )

def make_run_lcom_dw_snapshots_task(dag,  run_type: str, threads: Optional[int] = None, **operator_kwargs,) -> BashOperator:
    threads_part = f"--threads {threads}" if threads is not None else ""

    return BashOperator(dag=dag,
        task_id='run_snapshots',
        bash_command=(
            f"cd {DBT_LCOM_DW_PROJECT_DIR} && "
            "dbt run "
            "--select tag:snapshot "
            "--exclude \"config.materialized:view\" "
            "--vars '{"
            f"\"run_type\": \"{run_type}\", "
            "\"loaddate\": \"{{ ti.xcom_pull(task_ids='Start_Load.Set_Load_Date', key='LoadDate') }}\""
            "}' "
            f"{threads_part}"
        ),
        on_failure_callback=notify_task_failure,
        **operator_kwargs, 
    )

def make_run_drop_all_fk_task(dag, **operator_kwargs) -> BashOperator:

    return  BashOperator(dag=dag,
        task_id="run_dropping_all_fk",
        bash_command=(
            f"cd {DBT_LCOM_DW_PROJECT_DIR} && "
            "dbt run-operation Dropping_all_FK"
        ),
        on_failure_callback=notify_task_failure,
        **operator_kwargs, 
     )

def make_run_recreating_all_fk_task(dag, **operator_kwargs) -> BashOperator:

    return  BashOperator(dag=dag,
        task_id="run_recreating_all_fk",
        bash_command=(
            f"cd {DBT_LCOM_DW_PROJECT_DIR} && "
            "dbt run-operation Recreating_all_FK"
        ),
        on_failure_callback=notify_task_failure,
        **operator_kwargs, 
    )


def make_run_tests_task(dag, **operator_kwargs) -> BashOperator:

    return BashOperator(
        task_id="run_lcom_dw_tests",
        bash_command=(
            f"cd {DBT_LCOM_DW_PROJECT_DIR} && "
            "dbt test "
            "--exclude \"config.materialized:view\" \"tag:product_usage\" "
            "--vars '{\"run_type\": \"Scheduled Prod test\"}'"
        ),
        on_failure_callback=notify_task_failure,
        **operator_kwargs, 
    )