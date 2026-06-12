"""Solution for the employee load task.

This script shows the expected end-to-end solution for the employee task file:
1. Find and read the employee file
2. Clean the data
3. Prepare the data for loading
4. Truncate and load into MySQL
"""

import os
import sys
import glob

import pandas as pd
import mysql.connector

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..')))
from database_load_python_scripts.config import DATABASE_BRONZE, MYSQL_CONFIG


def find_employee_file():
    """Find the employee CSV file in the Reliant Digitech staging folder."""
    script_dir = os.path.dirname(os.path.abspath(__file__))
    stg_folder = os.path.abspath(os.path.join(script_dir, '..', '..', 'datasets', 'Reliant_Digitech', 'stg'))

    matches = sorted(glob.glob(os.path.join(stg_folder, 'employee_*.csv')))
    if not matches:
        raise FileNotFoundError('No employee file found matching employee_*.csv')
    return matches[-1]


def main():
    # ======================================================================
    # TASK 1: Find and read the file
    # ======================================================================
    file_path = find_employee_file()
    file_name = os.path.basename(file_path)

    df = pd.read_csv(file_path, dtype=str)
    print(f"File loaded successfully! ({file_name})")
    print("Total employees:", len(df))
    print("Columns:", list(df.columns))
    print("\n--- First 5 records ---")
    print(df.head(5).to_string(index=False))

    # ======================================================================
    # TASK 2: Clean the data before loading
    # ======================================================================
    df.columns = [col.lower() for col in df.columns]
    df = df.drop_duplicates()
    df['joining_date'] = pd.to_datetime(df['joining_date'], errors='coerce').dt.strftime('%Y-%m-%d')
    print("\nCleaned rows:", len(df))
    print("Cleaned columns:", len(df.columns))

    # ======================================================================
    # TASK 3: Prepare the data for database loading
    # ======================================================================
    df['source_file'] = file_name
    df = df.where(pd.notnull(df), None)
    print("\nFinal columns:", list(df.columns))

    # ======================================================================
    # TASK 4: Load into the staging table
    # ======================================================================
    conn = mysql.connector.connect(
        host=MYSQL_CONFIG['host'],
        port=MYSQL_CONFIG['port'],
        user=MYSQL_CONFIG['user'],
        password=MYSQL_CONFIG['password'],
        database=DATABASE_BRONZE,
        use_pure=True,
    )

    try:
        cursor = conn.cursor()
        cursor.execute('TRUNCATE TABLE stg_employees')
        conn.commit()
        cursor.close()

        cursor = conn.cursor()
        columns = df.columns.tolist()
        placeholders = ', '.join(['%s'] * len(columns))
        columns_str = ', '.join(columns)
        query = f"INSERT INTO stg_employees ({columns_str}) VALUES ({placeholders})"
        cursor.executemany(query, df.values.tolist())
        conn.commit()
        cursor.close()

        print(f"\nSuccessfully loaded {len(df):,} rows into STG_EMPLOYEES")
    except Exception as exc:
        conn.rollback()
        print(f"\nLoad failed: {exc}")
    finally:
        conn.close()


if __name__ == '__main__':
    main()
