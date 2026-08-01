from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime
import os
import socket
import pymysql


def _get_wsl_host_from_resolv():
    """Return the first nameserver from /etc/resolv.conf (Windows host IP in WSL)."""
    try:
        with open("/etc/resolv.conf", "r") as f:
            for line in f:
                line = line.strip()
                if line.startswith("nameserver"):
                    parts = line.split()
                    if len(parts) >= 2:
                        return parts[1]
    except Exception:
        return None


def _test_tcp(host, port=3306, timeout=3):
    try:
        with socket.create_connection((host, port), timeout=timeout):
            return True
    except Exception:
        return False


def run_mysql_query(**context):
    # Candidates: env var -> WSL nameserver -> localhost -> 127.0.0.1
    env_host = os.environ.get("MYSQL_HOST")
    candidates = []
    if env_host:
        candidates.append(env_host)
    resolv_ip = _get_wsl_host_from_resolv()
    if resolv_ip and resolv_ip not in candidates:
        candidates.append(resolv_ip)
    for h in ("localhost", "127.0.0.1"):
        if h not in candidates:
            candidates.append(h)

    last_err = None
    for host in candidates:
        if not host:
            continue
        print(f"Trying MySQL host: {host}:3306")
        if not _test_tcp(host, 3306, timeout=3):
            print(f"TCP connect to {host}:3306 failed, trying next candidate")
            continue
        try:
            conn = pymysql.connect(
                host=host,
                port=3306,
                user="root",
                password="Pritam@1994",
                database="mysql",
                connect_timeout=5,
            )
        except Exception as e:
            print(f"pymysql connect to {host} failed: {e}")
            last_err = e
            continue

        try:
            with conn.cursor() as cur:
                cur.execute("USE mysql;")
                cur.execute("SELECT 1 + 1;")
                results = cur.fetchall()
                print("MySQL query results:", results)
                return results
        finally:
            conn.close()

    # If we get here, no host worked
    raise RuntimeError(f"Unable to connect to MySQL. Last error: {last_err}")


with DAG(
    dag_id="demo_sql_dag",
    start_date=datetime(2024, 1, 1),
    schedule=None,
    catchup=False,
) as dag:
    query_task = PythonOperator(
        task_id="run_mysql_query",
        python_callable=run_mysql_query,
    )