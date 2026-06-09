import configparser
import csv
from pathlib import Path
from typing import Dict, List, Tuple

try:
    import mysql.connector
    from mysql.connector import errorcode
except ImportError as exc:
    raise ImportError(
        'mysql.connector is required. Install it with `pip install mysql-connector-python`.'
    ) from exc

import pandas as pd

BASE_DIR = Path(__file__).resolve().parents[2]
PROCESSED_DIR = BASE_DIR / 'datasets' / 'Motor Therfts' / 'Processed'
CONFIG_PATH = Path(__file__).resolve().parent.parent / 'Config' / 'db_config.ini'
SQL_PATH = Path(__file__).resolve().parent.parent / 'SQL scripts' / 'join_motor_thefts.sql'

TABLE_DEFINITIONS = {
    'locations': (
        "CREATE TABLE IF NOT EXISTS locations ("
        "location_id INT PRIMARY KEY, "
        "region VARCHAR(200), "
        "country VARCHAR(200), "
        "population INT, "
        "density DECIMAL(10,2)"
        ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4"
    ),
    'make_details': (
        "CREATE TABLE IF NOT EXISTS make_details ("
        "make_id INT PRIMARY KEY, "
        "make_name VARCHAR(255), "
        "make_type VARCHAR(50)"
        ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4"
    ),
    'stolen_vehicles': (
        "CREATE TABLE IF NOT EXISTS stolen_vehicles ("
        "vehicle_id INT PRIMARY KEY, "
        "vehicle_type VARCHAR(100), "
        "make_id INT, "
        "model_year INT, "
        "vehicle_desc VARCHAR(255), "
        "color VARCHAR(50), "
        "date_stolen DATE, "
        "location_id INT, "
        "FOREIGN KEY (make_id) REFERENCES make_details(make_id), "
        "FOREIGN KEY (location_id) REFERENCES locations(location_id)"
        ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4"
    ),
}

CSV_TABLE_MAP = {
    'locations_cleaned.csv': 'locations',
    'make_details_cleaned.csv': 'make_details',
    'stolen_vehicles_cleaned.csv': 'stolen_vehicles',
}

COLUMN_MAP = {
    'locations': [
        'location_id', 'region', 'country', 'population', 'density'
    ],
    'make_details': [
        'make_id', 'make_name', 'make_type'
    ],
    'stolen_vehicles': [
        'vehicle_id', 'vehicle_type', 'make_id', 'model_year',
        'vehicle_desc', 'color', 'date_stolen', 'location_id'
    ],
}


def read_db_config(path: Path) -> Dict[str, str]:
    if not path.exists():
        raise FileNotFoundError(f'Missing config file: {path}')
    config = configparser.ConfigParser()
    config.read(path)
    if 'mysql' not in config:
        raise KeyError('db_config.ini must contain a [mysql] section')
    return dict(config['mysql'])


def connect_database(config: Dict[str, str], with_database: bool = True):
    params = {
        'host': config.get('host', 'localhost'),
        'port': int(config.get('port', 3306)),
        'user': config.get('user'),
        'password': config.get('password'),
    }
    if with_database and config.get('database'):
        params['database'] = config.get('database')
    return mysql.connector.connect(**params)


def ensure_database(config: Dict[str, str]) -> None:
    database = config.get('database')
    if not database:
        raise ValueError('database must be set in [mysql] section')
    conn = connect_database(config, with_database=False)
    conn.autocommit = True
    cursor = conn.cursor()
    cursor.execute(f"CREATE DATABASE IF NOT EXISTS `{database}` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci")
    cursor.close()
    conn.close()


def create_tables(cursor) -> None:
    for table_sql in TABLE_DEFINITIONS.values():
        cursor.execute(table_sql)


def clean_value(value):
    if pd.isna(value):
        return None
    if isinstance(value, str) and value.strip() == '':
        return None
    return value


def build_insert_query(table: str) -> str:
    columns = COLUMN_MAP[table]
    placeholders = ', '.join(['%s'] * len(columns))
    cols = ', '.join(columns)
    return f"INSERT INTO {table} ({cols}) VALUES ({placeholders})"


def load_csv_to_table(cursor, csv_path: Path, table: str) -> None:
    df = pd.read_csv(csv_path, dtype=str)
    if df.empty:
        return
    df = df[COLUMN_MAP[table]].copy()
    df = df.applymap(clean_value)
    if table == 'locations':
        df['population'] = pd.to_numeric(df['population'], errors='coerce').astype('Int64')
        df['density'] = pd.to_numeric(df['density'], errors='coerce')
    elif table == 'make_details':
        df['make_id'] = pd.to_numeric(df['make_id'], errors='coerce').astype('Int64')
    elif table == 'stolen_vehicles':
        df['vehicle_id'] = pd.to_numeric(df['vehicle_id'], errors='coerce').astype('Int64')
        df['make_id'] = pd.to_numeric(df['make_id'], errors='coerce').astype('Int64')
        df['model_year'] = pd.to_numeric(df['model_year'], errors='coerce').astype('Int64')
        df['location_id'] = pd.to_numeric(df['location_id'], errors='coerce').astype('Int64')
        df['date_stolen'] = pd.to_datetime(df['date_stolen'], errors='coerce').dt.date

    query = build_insert_query(table)
    rows = [tuple(clean_value(v) for v in row) for row in df.itertuples(index=False, name=None)]
    if not rows:
        return
    cursor.executemany(query, rows)


def execute_join_query(cursor, sql_path: Path) -> List[Tuple]:
    if not sql_path.exists():
        raise FileNotFoundError(f'Missing SQL file: {sql_path}')
    join_sql = sql_path.read_text(encoding='utf-8')
    cursor.execute(join_sql)
    return cursor.fetchall(), [column[0] for column in cursor.description]


def save_query_result(rows: List[Tuple], columns: List[str], output_path: Path) -> None:
    output_path.parent.mkdir(parents=True, exist_ok=True)
    with output_path.open('w', newline='', encoding='utf-8') as csvfile:
        writer = csv.writer(csvfile)
        writer.writerow(columns)
        writer.writerows(rows)


def main() -> None:
    config = read_db_config(CONFIG_PATH)
    ensure_database(config)
    conn = connect_database(config, with_database=True)
    cursor = conn.cursor()
    create_tables(cursor)
    conn.commit()

    for csv_name, table in CSV_TABLE_MAP.items():
        csv_path = PROCESSED_DIR / csv_name
        if not csv_path.exists():
            raise FileNotFoundError(f'Missing cleaned CSV file: {csv_path}')
        print(f'Loading {csv_path.name} into {table}...')
        cursor.execute(f'TRUNCATE TABLE {table}')
        load_csv_to_table(cursor, csv_path, table)
        conn.commit()

    print('Executing join query...')
    rows, columns = execute_join_query(cursor, SQL_PATH)
    output_path = PROCESSED_DIR / 'motor_thefts_joined.csv'
    save_query_result(rows, columns, output_path)
    print(f'Join results saved to: {output_path}')

    cursor.close()
    conn.close()


if __name__ == '__main__':
    main()
