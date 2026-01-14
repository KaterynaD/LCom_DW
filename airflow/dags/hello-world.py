from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime

def print_hello():
    """
    A simple Python function that prints "Hello World!".
    """
    print("Hello World!")

with DAG(
    dag_id='hello_world_dag',
    start_date=datetime(2023, 1, 1),
    schedule_interval='@daily',
    catchup=False,
    tags=['example'],
) as dag:
    # Define a PythonOperator task that calls the print_hello function
    hello_task = PythonOperator(
        task_id='hello_world_task',
        python_callable=print_hello,
    )

