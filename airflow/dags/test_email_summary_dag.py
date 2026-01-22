from datetime import datetime
from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.utils.trigger_rule import TriggerRule
from airflow.utils.email import send_email


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
with DAG(
    dag_id="test_email_summary",
    start_date=datetime(2024, 1, 1),
    schedule_interval=None,
    catchup=False,
    tags=["test", "email"],
) as dag:

    notify_summary = PythonOperator(
        task_id="notify_summary",
        python_callable=send_test_summary,
        provide_context=True,
        trigger_rule=TriggerRule.ALL_DONE,
    )



