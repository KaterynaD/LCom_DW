import os
import sys
from pathlib import Path

# Add ../../airflow/Utils to PYTHONPATH
UTILS_DIR = (Path(__file__).resolve().parents[1] / "utils")
sys.path.insert(0, str(UTILS_DIR))

from datetime import datetime

from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.python import PythonOperator
from airflow.operators.empty import EmptyOperator

import json

from dag_utils import (
    DBT_LCOM_DW_PROJECT_DIR,
    notify_task_failure,
    create_init_branch,
    create_notify_summary_task,
    create_set_load_date_task,
    create_profile_task,
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
    start_date=datetime(2024, 1, 1),
    catchup=False,
    tags=["dbt", "sfdc", "profiles", "schema_audit", "maintenance"],
) as dag:

    # Shared "init" branch:
    # decide_init -> [refresh_git_repo, skip_dbt_init] -> init_done
    init_done = create_init_branch(dag)

    # 2. Set LoadDate (XCom)
    set_load_date_task = create_set_load_date_task(dag)

    # Profile tasks for different SFDC tables - run in parallel
    profile_account = create_profile_task("account", "base")
    profile_opportunity = create_profile_task("opportunity", "base")
    profile_opportunity_line_item = create_profile_task("opportunity_line_item", "base")
    profile_case = create_profile_task("case", "base")
    profile_training_session_c = create_profile_task("training_session_c", "base")
    profile_product_2 = create_profile_task("product_2", "base")
    profile_user = create_profile_task("user", "base")
    profile_contact = create_profile_task("contact", "base")
    profile_campaign = create_profile_task("campaign", "base")

    dummy_1 = EmptyOperator(task_id="dummy_1")
    dummy_2 = EmptyOperator(task_id="dummy_2")
  
    # Shared summary email at the end
    notify_summary = create_notify_summary_task(
        dag,
        run_name="SFDC: Manual run - base profiles for schema audit",
    )

    # Final wiring - all profile tasks run in parallel after init, then all feed to notification
    init_done >> set_load_date_task >> [profile_account, profile_opportunity, profile_opportunity_line_item, profile_case] >> dummy_1 >> [profile_training_session_c, profile_product_2, profile_user] >> dummy_2 >> [profile_contact, profile_campaign] >> notify_summary



