"""Simple MySQL connection test for both mysql.connector and SQLAlchemy."""

import traceback

import mysql.connector
from sqlalchemy import create_engine, text

from config import DATABASE_BRONZE, MYSQL_CONFIG, get_connection_string


def test_mysql_connector():
    print("mysql.connector test:")
    try:
        conn = mysql.connector.connect(
            host=MYSQL_CONFIG["host"],
            port=MYSQL_CONFIG["port"],
            user=MYSQL_CONFIG["user"],
            password=MYSQL_CONFIG["password"],
            database=DATABASE_BRONZE,
            use_pure=True,
        )
        cursor = conn.cursor()
        cursor.execute("SELECT DATABASE(), 1")
        print("  OK ->", cursor.fetchone())
        cursor.close()
        conn.close()
    except Exception:
        print("  FAILED")
        traceback.print_exc()


def test_sqlalchemy():
    print("SQLAlchemy test:")
    try:
        engine = create_engine(get_connection_string(DATABASE_BRONZE))
        with engine.connect() as conn:
            result = conn.execute(text("SELECT DATABASE(), 1"))
            print("  OK ->", result.fetchone())
        engine.dispose()
    except Exception:
        print("  FAILED")
        traceback.print_exc()


if __name__ == "__main__":
    test_mysql_connector()
    print()
    test_sqlalchemy()