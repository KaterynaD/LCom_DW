from datetime import datetime
from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.utils.trigger_rule import TriggerRule
from airflow.utils.email import send_email

from airflow.models import Variable

import pendulum

local_tz = pendulum.timezone("America/Los_Angeles")

SCHEDULE_TEST_RUN = Variable.get("SCHEDULE_TEST_RUN", default_var="0 * * * *")
# ------------------------------------------------------------------------
# Dummy summary function (always runs)
# ------------------------------------------------------------------------
def send_test_summary(**context):
    subject = "Airflow Email Test — Summary Notification"
    html_content = """
    <h3>This is a test Airflow summary email.</h3>
    <p>Your SMTP configuration works!</p>
    <p>Here is some dummy task summary content:</p>
    <ul>
        <li><b>Succeeded tasks:</b> task_a, task_b</li>
        <li><b>Failed tasks:</b> none</li>
        <li><b>Other tasks:</b> none</li>
    </ul>
    <p>Execution date: {{ ds }}</p>
    """

    send_email(
        to=["kdrogaieva@learning.com"],
        subject=subject,
        html_content=html_content
    )


# ------------------------------------------------------------------------
# Test DAG — only one task
# ------------------------------------------------------------------------


default_args = {
    "owner": "airflow",
    "depends_on_past": False,
    "retries": 0
}

with DAG(
    dag_id="test_email_summary",
    default_args=default_args,
    start_date=datetime(2025, 1, 1, tzinfo=local_tz),
    schedule=SCHEDULE_TEST_RUN,     
    max_active_runs=1, 
    catchup=False,
    tags=["test", "email"],
) as dag:


    notify_summary = PythonOperator(
        task_id="notify_summary",
        python_callable=send_test_summary,
        provide_context=True,
        trigger_rule=TriggerRule.ALL_DONE,
    )



