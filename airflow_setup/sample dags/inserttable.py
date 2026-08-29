from datetime import datetime
from airflow import DAG
from airflow.operators.python import PythonOperator
import pymysql

SQL_FILE_PATH = r"/home/pritam/.pyenv/versions/3.11.9/lib/python3.11/site-packages/airflow/example_dags/sql/insert_data.sql"


def run_sql_file():
    with open(SQL_FILE_PATH, "r", encoding="utf-8") as f:
        sql_script = f.read()

    conn = pymysql.connect(
        host="192.168.1.8",
        port=3306,
        user="root",
        password="Pritam@1994",
        database="mysql",
        autocommit=True,
        connect_timeout=10,
    )

    try:
        with conn.cursor() as cursor:
            for statement in sql_script.split(";"):
                stmt = statement.strip()
                if stmt:
                    cursor.execute(stmt)
                    print(f"Executed SQL statement: {stmt[:80]}...")
    finally:
        conn.close()


with DAG(
    dag_id="sql_insert_data",
    description="Load a local SQL script into MySQL",
    start_date=datetime(2024, 1, 1),
    schedule=None,
    catchup=False,
    tags=["mysql", "sql", "load"],
) as dag:

    load_sql = PythonOperator(
        task_id="load_sql_file",
        python_callable=run_sql_file,
    )
