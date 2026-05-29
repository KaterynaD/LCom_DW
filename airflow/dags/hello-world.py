from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime

def print_hello():
    """
    A simple Python function that prints "Hello World!".
    """
    print("Hello World!!!!")

with DAG(
    dag_id='hello_world_dag',
    star


