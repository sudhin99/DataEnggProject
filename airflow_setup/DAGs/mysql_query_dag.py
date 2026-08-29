from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.providers.mysql.hooks.mysql import MySqlHook
from datetime import datetime
import os
import socket
import pymysql


def run_mysql_query(**context):
    sql = "SELECT 1 + 1"

    # Primary: use Airflow Connection `my_mysql_conn`
    try:
        hook = MySqlHook(mysql_conn_id="my_mysql_conn")
        results = hook.get_records(sql)
        print("MySQL (hook) query results:", results)
        return results
    except Exception as e:
        print(f"MySqlHook failed: {e}, falling back to direct connect")

    # Fallback: try direct pymysql connections using environment or discovered hosts
    def _get_wsl_host_from_resolv():
        try:
            with open("/etc/resolv.conf", "r") as f:
                for line in f:
                    if line.strip().startswith("nameserver"):
                        parts = line.split()
                        if len(parts) >= 2:
                            return parts[1]
        except Exception:
            return None

    def _test_tcp(host, port=3306, timeout=2):
        try:
            with socket.create_connection((host, port), timeout=timeout):
                return True
        except Exception:
            return False

    candidates = []
    env_host = os.environ.get("MYSQL_HOST")
    if env_host:
        candidates.append(env_host)
    resolv_ip = _get_wsl_host_from_resolv()
    if resolv_ip and resolv_ip not in candidates:
        candidates.append(resolv_ip)
    # Common reachable Windows LAN IP used earlier in this workspace
    windows_lan_ip = os.environ.get("WINDOWS_HOST") or "192.168.1.8"
    if windows_lan_ip and windows_lan_ip not in candidates:
        candidates.append(windows_lan_ip)
    for h in ("localhost", "127.0.0.1"):
        if h not in candidates:
            candidates.append(h)

    last_err = None
    for host in candidates:
        if not host:
            continue
        print(f"Trying fallback MySQL host: {host}:3306")
        if not _test_tcp(host, 3306, timeout=2):
            print(f"TCP connect to {host}:3306 failed, trying next candidate")
            continue
        try:
            conn = pymysql.connect(
                host=host,
                port=int(os.environ.get("MYSQL_PORT", 3306)),
                user=os.environ.get("MYSQL_USER", "root"),
                password=os.environ.get("MYSQL_PASSWORD", "Pritam@1994"),
                database=os.environ.get("MYSQL_DB", "mysql"),
                connect_timeout=5,
            )
        except Exception as e:
            print(f"pymysql connect to {host} failed: {e}")
            last_err = e
            continue

        try:
            with conn.cursor() as cur:
                cur.execute(sql)
                results = cur.fetchall()
                print("MySQL (direct) query results:", results)
                return results
        finally:
            conn.close()

    raise RuntimeError(f"Unable to connect to MySQL via hook or fallbacks. Last error: {last_err}")


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
    dag_id='NEW_SQL_DAG',
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
