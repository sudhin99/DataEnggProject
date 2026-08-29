from datetime import datetime
from airflow import DAG
from airflow.operators.python import PythonOperator
import pymysql


def run_mysql_query():
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
            cursor.execute("SHOW DATABASES;")
            rows = cursor.fetchall()
            print("MySQL databases:")
            for row in rows:
                print(row)

            # Optional test query
            # cursor.execute("SELECT 1;")
            # print("SELECT 1 result:", cursor.fetchone())
    finally:
        conn.close()

with DAG(
    dag_id="mysql_direct_connect_dag",
    description="Run a real MySQL query from db_config.ini",
    start_date=datetime(2024, 1, 1),
    schedule=None,
    catchup=False,
    tags=["mysql", "pymysql", "test"],
) as dag:

    test_mysql = PythonOperator(
        task_id="run_mysql_query",
        python_callable=run_mysql_query,
    )