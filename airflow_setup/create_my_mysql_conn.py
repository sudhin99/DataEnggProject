#!/usr/bin/env python3
"""
Create or update an Airflow Connection `my_mysql_conn` using Airflow ORM.
Run this inside the Airflow environment (WSL venv or inside the Airflow container).
"""
import os
from airflow.models import Connection
from airflow.utils.session import provide_session


def _get_uri(user, password, host, port, db):
    return f"mysql+pymysql://{user}:{password}@{host}:{port}/{db}"


@provide_session
def create_conn(session=None):
    conn_id = os.getenv("MYSQL_CONN_ID", "my_mysql_conn")
    user = os.getenv("MYSQL_USER", "root")
    password = os.getenv("MYSQL_PASSWORD", "Pritam@1994")
    host = os.getenv("MYSQL_HOST", "192.168.1.8")
    port = int(os.getenv("MYSQL_PORT", "3306"))
    db = os.getenv("MYSQL_DB", "mysql")

    uri = _get_uri(user, password, host, port, db)

    existing = session.query(Connection).filter(Connection.conn_id == conn_id).first()
    if existing:
        print(f"Updating existing connection {conn_id}")
        session.delete(existing)
        session.flush()

    conn = Connection(conn_id=conn_id, uri=uri)
    session.add(conn)
    session.commit()
    print(f"Created/updated connection {conn_id} -> {uri}")


if __name__ == "__main__":
    create_conn()
