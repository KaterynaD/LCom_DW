from datetime import datetime
import os
import yaml
from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.operators.bash import BashOperator
from airflow.providers.postgres.hooks.postgres import PostgresHook
from airflow.models import Connection, Variable
import pandas as pd

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

def get_compiled_sql_path():
    """Get the path to the compiled missing_columns.sql."""
    return os.path.join(DBT_LCOM_DW_PROJECT_DIR, "target", "compiled", "LCom_DW", "analyses", "SFDC_schema_drift", "missing_columns.sql")

def create_or_update_redshift_connection():
    """Create or update Airflow Redshift connection based on dbt profile."""
    profiles_path = os.path.join(DBT_LCOM_DW_PROJECT_DIR, "profiles.yml")
    with open(profiles_path, 'r') as f:
        profiles = yaml.safe_load(f)

    default_target = profiles['LCom_DW']['target']
    target_config = profiles['LCom_DW']['outputs'][default_target]
    host = target_config['host']
    port = target_config.get('port', 5439)
    user = target_config['user']
    password = target_config['password']
    dbname = target_config['dbname']

    conn_id = 'redshift_default'
    conn = Connection(
        conn_id=conn_id,
        conn_type='postgres',
        host=host,
        port=port,
        schema=dbname,
        login=user,
        password=password,
    )
    conn.upsert()  # This will create or update the connection

def execute_missing_columns_sql():
    """Execute the compiled missing_columns.sql and return results."""
    compiled_sql_path = get_compiled_sql_path()
    with open(compiled_sql_path, 'r') as f:
        sql = f.read()

    # Use the created connection
    hook = PostgresHook(postgres_conn_id='redshift_default')
    engine = hook.get_sqlalchemy_engine()

    df = pd.read_sql(sql, engine)
    return df.to_dict('records')

def process_missing_columns(**context):
    """Process missing columns: check models, replace, log actions."""
    results = execute_missing_columns_sql()
    changes_made = False

    for row in results:
        model_name = row['model_name']
        missing_source_column = row['missing_source_column']
        replace_to_default = row['replace_to_default']
        column_name = row['column_name']
        table_name = row['table_name']

        model_path = os.path.join(DBT_LCOM_DW_PROJECT_DIR, model_name.lstrip('/'))

        if not os.path.exists(model_path):
            print(f"Model file not found: {model_path} for table {table_name}")
            continue

        with open(model_path, 'r') as f:
            content = f.read()

        # Check if missing_source_column exists in the content
        if missing_source_column in content:
            # Replace with "replace_to_default as column_name"
            replacement = f"{replace_to_default} as {column_name}"
            new_content = content.replace(missing_source_column, replacement)

            with open(model_path, 'w') as f:
                f.write(new_content)

            print(f"Replaced {missing_source_column} with {replacement} in {model_name} for table {table_name}")
            changes_made = True
        else:
            print(f"{missing_source_column} not found in {model_name} for table {table_name}")

    if changes_made:
        Variable.set("INIT_DBT_PROJECT", "YES")
        context['task_instance'].xcom_push(key='changes_made', value=True)
        context['task_instance'].xcom_push(key='missing_columns', value=results)
    else:
        context['task_instance'].xcom_push(key='changes_made', value=False)

def send_schema_drift_notification(**context):
    """Send notification email based on schema drift results."""
    ti = context['task_instance']
    changes_made = ti.xcom_pull(key='changes_made', task_ids='process_missing_columns')

    if changes_made:
        missing_columns = ti.xcom_pull(key='missing_columns', task_ids='process_missing_columns')
        subject = "SFDC Schema Drift Detected - Review Required"
        html_content = f"""
        <p>SFDC schema drift has been detected and columns have been replaced with default values.</p>
        <p>Missing columns processed: {len(missing_columns)}</p>
        <ul>
        """
        for col in missing_columns:
            html_content += f"<li>{col['missing_source_column']} in {col['model_name']} (table: {col['table_name']})</li>"
        html_content += "</ul><p><b>Review the models and rebase SFDC data profiles!!!</b></p>"
    else:
        subject = "SFDC Schema Drift Check - No Changes"
        html_content = "<p>No SFDC schema drift today.</p>"

    from airflow.utils.email import send_email
    ALERT_EMAIL = Variable.get("ALERT_EMAIL", default_var="reportinganalytics@learning.com")
    send_email(to=[ALERT_EMAIL], subject=subject, html_content=html_content)

with DAG(
    dag_id="sfdc_schema_drift_temp_fix",
    description="SFDC Schema Drift Detection and Temporary Fix",
    default_args=default_args,
    start_date=datetime(2024, 1, 1),
    schedule=None,
    catchup=False,
    tags=["dbt", "lcom_dw", "sfdc", "schema_drift"],
) as dag:

    # Shared "init" branch
    init_done = create_init_branch(dag)

    # Core tasks
    run_profile = BashOperator(
        task_id="run_sfdc_profile",
        bash_command=(
            f"cd {DBT_LCOM_DW_PROJECT_DIR} && "
            "dbt run-operation create_profile "
            "--args \"{'database_name':'rawdata', 'schema_name':'fivetran_salesforce_quickstart','table_name':'account', 'profiles_db':'rawdata', 'profiles_schema':'profiles', 'profiles_table':'sfdc_schema_audit', 'profile_name':'current','exclude_stats_numeric':['placeholder','min','max','avg','stddev_pop','cnt_neg','cnt_zero','cnt_pos','cnt_int'],'exclude_stats_varchar':['placeholder','min_length','max_length','avg_length','cnt_leading_ws','cnt_trailing_ws','cnt_empty_after_trim','cnt_lower','cnt_upper','cnt_mixed','cnt_cast_int','cnt_cast_decimal','cnt_cast_date','cnt_cast_timestamp'],'exclude_stats_datetime':['placeholder','min','max'],'exclude_columns':['num_opps_c','nc_tier_1_c','last_activity_logged_on_c','district_nces_c']}\""
        ),
        on_failure_callback=notify_task_failure,
    )

    compile_query = BashOperator(
        task_id="compile_missing_columns",
        bash_command=(
            f"cd {DBT_LCOM_DW_PROJECT_DIR} && "
            "dbt compile --select analyses/SFDC_schema_drift/missing_columns.sql"
        ),
        on_failure_callback=notify_task_failure,
    )

    create_connection = PythonOperator(
        task_id="create_redshift_connection",
        python_callable=create_or_update_redshift_connection,
        on_failure_callback=notify_task_failure,
    )

    process_columns = PythonOperator(
        task_id="process_missing_columns",
        python_callable=process_missing_columns,
        provide_context=True,
        on_failure_callback=notify_task_failure,
    )

    # Notification
    notify_drift = PythonOperator(
        task_id="notify_schema_drift",
        python_callable=send_schema_drift_notification,
        provide_context=True,
        trigger_rule="all_done",
    )

    # Wiring
    init_done >> run_profile >> compile_query >> create_connection >> process_columns >> notify_drift