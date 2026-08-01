from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.providers.mysql.hooks.mysql import MySqlHook
from datetime import datetime


def run_mysql_query(**context):
    hook = MySqlHook(mysql_conn_id="my_mysql_conn")
    sql = "SELECT 1 + 1"
    results = hook.get_records(sql)
    print("MySQL query results:", results)
    return results


def run_sql_file(**context):
    sql_file = context['params'].get('sql_file', '/opt/airflow/dags/sql/demo.sql')
    hook = MySqlHook(mysql_conn_id="my_mysql_conn")
    if sql_file:
        with open(sql_file, 'r') as f:
            sql = f.read()
        results = hook.get_records(sql)
        print(f"Executed SQL file {sql_file} with results:", results)
        return results
    raise FileNotFoundError(f"SQL file not found: {sql_file}")


default_args = {
    'owner': 'airflow',
}

with DAG(
    dag_id='mysql_query_dag',
    default_args=default_args,
    description='Run MySQL queries using MySqlHook and PythonOperator',
    start_date=datetime(2024, 1, 1),
    schedule=None,
    catchup=False,
    tags=['mysql', 'queries'],
) as dag:

    query_task = PythonOperator(
        task_id='run_mysql_query',
        python_callable=run_mysql_query,
    )

    query_file_task = PythonOperator(
        task_id='run_sql_file',
        python_callable=run_sql_file,
        params={
            'sql_file': '/opt/airflow/dags/sql/demo.sql',
        },
    )

    query_task >> query_file_task
