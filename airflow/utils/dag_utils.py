import os
import yaml
import json
from airflow.operators.bash import BashOperator
from airflow.operators.python import PythonOperator, BranchPythonOperator
from airflow.operators.empty import EmptyOperator
from airflow.utils.trigger_rule import TriggerRule
from airflow.utils.email import send_email
from airflow.models import Variable
from airflow.models import Connection
from airflow import settings
from datetime import datetime
from urllib.parse import urlsplit, urlunsplit, parse_qsl, urlencode

# ------------------------------------------------------------------------
# Shared config
# ------------------------------------------------------------------------
REPO_DIR = os.environ.get("REPO_DIR", "/opt/airflow/transformations")
DBT_PROFILES_DIR = os.environ.get(
    "DBT_PROFILES_DIR",
    "/home/airflow/.dbt"
)
DBT_TARGET_DIR = os.environ.get(
    "DBT_TARGET_PATH",
    "/home/airflow/dbt_target"
)
DBT_LCOM_DW_PROJECT_DIR = os.environ.get(
    "DBT_LCOM_DW_PROJECT_DIR",
    "/opt/airflow/transformations/dbt/LCom_DW"
)
ALERT_EMAIL = Variable.get("ALERT_EMAIL", default_var="reportinganalytics@learning.com")
init_flag = Variable.get("INIT_DBT_PROJECT", default_var="YES").upper()

# ------------------------------------------------------------------------
# Shared callbacks
# ------------------------------------------------------------------------
def strip_query_param(url: str, param: str) -> str:
    parts = urlsplit(url)
    query = dict(parse_qsl(parts.query))
    query.pop(param, None)  # remove base_date if present
    new_query = urlencode(query, doseq=True)
    return urlunsplit((parts.scheme, parts.netloc, parts.path, new_query, parts.fragment))

def notify_task_failure(context):
    """Send per-task failure email with log link."""
    task_instance = context["task_instance"]
    dag_id = context["dag"].dag_id
    task_id = task_instance.task_id

    # Raw URL from Airflow
    raw_log_url = task_instance.log_url

    # Clean URL without &base_date=...
    log_url = strip_query_param(raw_log_url, "base_date")


    ts = context.get("ts")

    subject = f"LCom DW load failed at task {task_id}"
    html_content = f"""
    <p>LCom DW run failed at a task.</p>
    <ul>
      <li><b>DAG:</b> {dag_id}</li>
      <li><b>Task:</b> {task_id}</li>
      <li><b>Execution time:</b> {ts}</li>
      <li><b>Log:</b> <a href="{log_url}">{log_url}</a></li>
    </ul>
    """

    send_email(to=[ALERT_EMAIL], subject=subject, html_content=html_content)




# ------------------------------------------------------------------------
# Shared branch logic: INIT_DBT_PROJECT
# ------------------------------------------------------------------------
def decide_init_dbt_project():
    """
    Branch callable used by BranchPythonOperator to decide whether to run
    git pull + dbt deps, based on INIT_DBT_PROJECT variable.
    """
    
    if init_flag == "YES":
        return "refresh_git_repo"
    else:
        return "skip_dbt_init"


def create_init_branch(dag, repo_dir=None, dbt_project_dir=None):
    """
    Create the standard:
        decide_init -> [refresh_git_repo, skip_dbt_init] -> init_done

    Returns the 'init_done' task which you can depend on in each DAG.

    (using NONE_FAILED_MIN_ONE_SUCCESS on the join).
    """
    repo_dir = repo_dir or REPO_DIR
    dbt_project_dir = dbt_project_dir or DBT_LCOM_DW_PROJECT_DIR

    decide_init = BranchPythonOperator(
        task_id="decide_init_dbt_project",
        python_callable=decide_init_dbt_project,
        dag=dag,
    )

    skip_dbt_init = EmptyOperator(
        task_id="skip_dbt_init",
        dag=dag,
    )

    # refresh_git_repo = BashOperator(
    #         task_id="refresh_git_repo",
    #         bash_command=(
    #             f"cd {repo_dir} && "
    #             "git pull origin master"
    #        ),
    #         on_failure_callback=notify_task_failure,
    #         dag=dag,
    #     )

    refresh_git_repo = BashOperator(
        task_id="refresh_git_repo",
        bash_command=(
            f"cd {repo_dir} && "
            "git fetch origin && "
            "git reset --hard origin/master && "
            "git clean -fd"
       ),
       on_failure_callback=notify_task_failure,
       dag=dag,
    )

    run_dbt_deps = BashOperator(
        task_id="run_dbt_deps",
        bash_command=(
            f"cd {dbt_project_dir} && "
            "dbt deps"
        ),
        on_failure_callback=notify_task_failure,
        dag=dag,
    )

    # Join of the two branches
    init_done = EmptyOperator(
        task_id="init_done",
        trigger_rule=TriggerRule.NONE_FAILED_MIN_ONE_SUCCESS,
        dag=dag,
    )

    # Wire the flow
    decide_init >> [refresh_git_repo, skip_dbt_init]
    refresh_git_repo >> run_dbt_deps >> init_done
    skip_dbt_init >> init_done

    return init_done

# ------------------------------------------------------------------------
# Run summary helpers
# ------------------------------------------------------------------------
def _collect_task_states(dag_run, exclude_task_ids=None):
    """
    Return (succeeded, failed, other) lists of task_ids for the given dag_run.

    exclude_task_ids: iterable of task_ids that should be ignored
    (e.g., the notify_summary task itself, which is still 'running').
    """
    exclude = set(exclude_task_ids or [])

    tis = dag_run.get_task_instances()

    succeeded = [
        ti.task_id
        for ti in tis
        if ti.state == "success" and ti.task_id not in exclude
    ]
    failed = [
        ti.task_id
        for ti in tis
        if ti.state == "failed" and ti.task_id not in exclude
    ]
    other = [
        ti.task_id
        for ti in tis
        if ti.task_id not in exclude
        and ti.state not in ("success", "failed", "removed", "skipped")
    ]

    return succeeded, failed, other


def send_run_summary(run_name: str, **context):
    """
    Generic run summary email.

    Parameters
    ----------
    run_name : str
        Friendly name to appear in the email subject and body, e.g.
        "LCom DW scheduled load" or "LCom DW manual Dropping_all_FK".
    """
    dag_run = context["dag_run"]
    current_ti = context["task_instance"]
    summary_task_id = current_ti.task_id  # usually "notify_summary"

    # Exclude the summary task itself so its "running" state
    # doesn't count as "other/unfinished"
    succeeded, failed, other = _collect_task_states(
        dag_run,
        exclude_task_ids=[summary_task_id],
    )

    status = "SUCCESS" if not failed and not other else "COMPLETED WITH ISSUES"

    subject = f"{run_name} summary - {status}"

    def format_list(name, items):
        if not items:
            return f"<p><b>{name}:</b> none</p>"
        items_html = "".join(f"<li>{task_id}</li>" for task_id in sorted(items))
        return f"<p><b>{name}:</b></p><ul>{items_html}</ul>"

    html_content = (
        f"<p>{run_name} has finished. Here is the task status summary:</p>"
        f"{format_list('Succeeded tasks', succeeded)}"
        f"{format_list('Failed tasks', failed)}"
        f"{format_list('Other/unfinished tasks', other)}"
        f"<p><b>Execution date:</b> {context.get('ds')}</p>"
    )

    send_email(to=[ALERT_EMAIL], subject=subject, html_content=html_content)


def create_notify_summary_task(dag, run_name: str, task_id: str = "notify_summary"):
    """
    Create a PythonOperator that sends a generic summary email at the end of a DAG.

    Usage:
        notify_summary = create_notify_summary_task(
            dag,
            run_name="LCom DW scheduled load",
        )
    """
    return PythonOperator(
        task_id=task_id,
        python_callable=send_run_summary,
        op_kwargs={"run_name": run_name},
        provide_context=True,
        trigger_rule=TriggerRule.ALL_DONE,
        dag=dag,
    )

# ------------------------------------------------------------------------
# Set Load Date via XCom
# ------------------------------------------------------------------------
def set_load_date(ti, **kwargs):
    # No microseconds for nicer string; ISO is safe to pass into dbt vars
    load_date = datetime.today().replace(microsecond=0).isoformat()
    ti.xcom_push(key="LoadDate", value=load_date)

def create_set_load_date_task(dag, trigger_rule=None):
    kwargs = {
        'task_id': "Start_Load.Set_Load_Date",
        'python_callable': set_load_date,
        'provide_context': True,
        'on_failure_callback': notify_task_failure,
        'dag': dag,
    }
    if trigger_rule is not None:
        kwargs['trigger_rule'] = trigger_rule
    return PythonOperator(**kwargs)

# ------------------------------------------------------------------------
# Create or update Redshift connection
# ------------------------------------------------------------------------
def create_or_update_redshift_connection():
    """Create or update Airflow Redshift connections based on dbt profile."""
    profiles_path = os.path.join(DBT_PROFILES_DIR, "profiles.yml")
    with open(profiles_path, 'r') as f:
        profiles = yaml.safe_load(f)

    # Keep original redshift_default for default target
    default_target = profiles['LCom_DW']['target']
    target_config = profiles['LCom_DW']['outputs'][default_target]
    conn_type = target_config['type']
    host = target_config['host']
    port = target_config.get('port', 5439)
    user = target_config['user']
    password = target_config['password']
    dbname = target_config['dbname']

    dbt_conn_id = 'redshift_default'
    session = settings.Session()

    try:
        new_conn = session.query(Connection).filter(Connection.conn_id == dbt_conn_id).one()
        new_conn.conn_type = conn_type
        new_conn.login = user
        new_conn.password = password
        new_conn.host = host
        new_conn.port = port
        new_conn.schema = dbname
    except:
        new_conn = Connection(conn_id=dbt_conn_id,
                              conn_type=conn_type,
                              login=user,
                              password=password,
                              host=host,
                              port=port,
                              schema=dbname)
        session.add(new_conn)

    # Now create connections for all outputs as redshift_<output_name>
    lcom_dw_outputs = profiles['LCom_DW']['outputs']

    for output_name, target_config in lcom_dw_outputs.items():
        conn_id = f'redshift_{output_name}'
        conn_type = target_config['type']
        host = target_config['host']
        port = target_config.get('port', 5439)
        user = target_config['user']
        password = target_config['password']
        dbname = target_config['dbname']

        try:
            existing_conn = session.query(Connection).filter(Connection.conn_id == conn_id).one()
            existing_conn.conn_type = conn_type
            existing_conn.login = user
            existing_conn.password = password
            existing_conn.host = host
            existing_conn.port = port
            existing_conn.schema = dbname
        except:
            new_conn = Connection(
                conn_id=conn_id,
                conn_type=conn_type,
                login=user,
                password=password,
                host=host,
                port=port,
                schema=dbname
            )
            session.add(new_conn)

    session.commit()

def create_manage_base_profile_task(dag):
    return PythonOperator(
        task_id="manage_base_profile",
        python_callable=manage_base_profile,
        on_failure_callback=notify_task_failure,
        dag=dag,
    )

def create_create_connection_task(dag):
    return PythonOperator(
        task_id="create_redshift_connection",
        python_callable=create_or_update_redshift_connection,
        on_failure_callback=notify_task_failure,
        dag=dag,
    )

# ------------------------------------------------------------------------
# Create SFDC Table Profile Task
# -----------------------------------------------------------------------

def create_profile_task(table_name, profile_name):
    """Create a profile task for a given SFDC table."""
    args_dict = {
        'database_name': 'rawdata',
        'schema_name': 'fivetran_salesforce_quickstart',
        'table_name': table_name,
        'profiles_db': 'rawdata',
        'profiles_schema': 'profiles',
        'profiles_table': 'sfdc_schema_audit',
        'profile_name': profile_name,
        'exclude_stats_numeric': ['placeholder', 'min', 'max', 'avg', 'stddev_pop', 'cnt_neg', 'cnt_zero', 'cnt_pos', 'cnt_int'],
        'exclude_stats_varchar': ['placeholder', 'min_length', 'max_length', 'avg_length', 'cnt_leading_ws', 'cnt_trailing_ws', 'cnt_empty_after_trim', 'cnt_lower', 'cnt_upper', 'cnt_mixed', 'cnt_cast_int', 'cnt_cast_decimal', 'cnt_cast_date', 'cnt_cast_timestamp'],
        'exclude_stats_datetime': ['placeholder', 'min', 'max'],
        'loaddate': '{{ ti.xcom_pull(task_ids=\'Start_Load.Set_Load_Date\', key=\'LoadDate\') }}'
    }
    args_str = json.dumps(args_dict)
    return BashOperator(
        task_id=f"profile_{table_name.replace('_', '_')}",
        bash_command=(
            f"cd {DBT_LCOM_DW_PROJECT_DIR} && "
            "dbt run-operation create_profile "
            f"--args '{args_str}' "
            "--target sfdc"
        ),
        on_failure_callback=notify_task_failure,
    )