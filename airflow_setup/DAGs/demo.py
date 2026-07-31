from airflow import DAG
from airflow.providers.mysql.operators.mysql import MySqlOperator
from airflow.utils.dates import days_ago
import os

# DAG configuration
DAG_ID = "DEMO_SQL"
SQL_FILE_PATH = os.path.join(os.path.dirname(__file__), "queries", "/sql/demo.sql")

# Ensure SQL file exists before DAG parsing
if not os.path.exists(SQL_FILE_PATH):
    raise FileNotFoundError(f"SQL file not found: {SQL_FILE_PATH}")

with DAG(
    dag_id=DAG_ID,
    description="DAG to execute a SQL file using mysql",
    start_date=days_ago(1),
    schedule_interval=None,  # Run manually or set cron
    catchup=False,
    tags=["sql", "mysql"],
) as dag:

    start_task = EmptyOperator(task_id="start")
    end_task = EmptyOperator(task_id="end")

    run_sql = MySqlOperator(
 task_id="create_table",
 mysql_conn_id="my_mysql_conn", # Must match Airflow connection ID
 sql="SELECT 1+2"
    )

    start_task >> run_sql >> end_task
