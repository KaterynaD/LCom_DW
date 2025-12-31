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

def create_profile_task(table_name):
    """Create a profile task for a given SFDC table."""
    return BashOperator(
        task_id=f"profile_{table_name.replace('_', '_')}",
        bash_command=(
            f"cd {DBT_LCOM_DW_PROJECT_DIR} && "
            "dbt run-operation create_profile "
            f"--args \"{{'database_name':'rawdata', 'schema_name':'fivetran_salesforce_quickstart','table_name':'{table_name}', 'profiles_db':'rawdata', 'profiles_schema':'profiles', 'profiles_table':'sfdc_schema_audit', 'profile_name':'base','exclude_stats_numeric':['placeholder','min','max','avg','stddev_pop','cnt_neg','cnt_zero','cnt_pos','cnt_int'],'exclude_stats_varchar':['placeholder','min_length','max_length','avg_length','cnt_leading_ws','cnt_trailing_ws','cnt_empty_after_trim','cnt_lower','cnt_upper','cnt_mixed','cnt_cast_int','cnt_cast_decimal','cnt_cast_date','cnt_cast_timestamp'],'exclude_stats_datetime':['placeholder','min','max']}}\" "
            "--target sfdc"
        ),
        on_failure_callback=notify_task_failure,
    )

with DAG(
    dag_id="sfdc_base_profiles_manual_run",
    description="SFDC: Manual run - base profiles for schema audit (manual trigger only)",
    default_args=default_args,
    start_date=datetime(2024, 1, 1),
    schedule_interval=None,
    catchup=False,
    tags=["dbt", "sfdc", "profiles", "schema_audit", "maintenance"],
) as dag:

    # Shared "init" branch:
    # decide_init -> [refresh_git_repo, skip_dbt_init] -> init_done
    init_done = create_init_branch(dag)

    # Profile tasks for different SFDC tables - run in parallel
    profile_account = create_profile_task("account")
    profile_opportunity = create_profile_task("opportunity")
    profile_opportunity_line_item = create_profile_task("opportunity_line_item")
    profile_case = create_profile_task("case")
    profile_training_session_c = create_profile_task("training_session_c")
    profile_product_2 = create_profile_task("product_2")

    # Shared summary email at the end
    notify_summary = create_notify_summary_task(
        dag,
        run_name="SFDC: Manual run - base profiles for schema audit",
    )

    # Final wiring - all profile tasks run in parallel after init, then all feed to notification
    init_done >> [profile_account, profile_opportunity, profile_opportunity_line_item, profile_case, profile_training_session_c, profile_product_2] >> notify_summary</content>
