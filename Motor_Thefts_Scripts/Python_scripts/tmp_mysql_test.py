import configparser
from pathlib import Path
import socket
import mysql.connector

output_path = Path(r'C:\Users\pritam\DataEnggProject\DataEnggProject\Motor_Thefts_Scripts\Python_scripts\tmp_mysql_test_output.txt')
config = configparser.ConfigParser()
config.read(Path(r'C:\Users\pritam\DataEnggProject\DataEnggProject\Motor_Thefts_Scripts\Config\db_config.ini'))
sec = config['mysql']
lines = []
lines.append('host=' + sec.get('host'))
lines.append('port=' + sec.get('port'))
lines.append('user=' + sec.get('user'))
lines.append('database=' + sec.get('database'))

for host in [sec.get('host'), '127.0.0.1', 'localhost']:
    try:
        sock = socket.create_connection((host, int(sec.get('port'))), timeout=5)
        sock.close()
        lines.append(f'TCP_CONNECT {host}=OK')
        print(f'TCP_CONNECT {host}=OK')
    except Exception as e:
        lines.append(f'TCP_CONNECT {host}={type(e).__name__}: {e}')
        print(f'TCP_CONNECT {host}={type(e).__name__}: {e}')

for host in [sec.get('host'), '127.0.0.1', 'localhost']:
    try:
        conn = mysql.connector.connect(
            host=host,
            port=int(sec.get('port')),
            user=sec.get('user'),
            password=sec.get('password'),
            connection_timeout=5,
            use_pure=True,
        )
        lines.append(f'MYSQL_CONNECT {host}=OK')
        print(f'MYSQL_CONNECT {host}=OK')
        cursor = conn.cursor()
        cursor.execute(
            "CREATE TABLE IF NOT EXISTS make_details ("
            "make_id INT PRIMARY KEY, "
            "make_name VARCHAR(255), "
            "make_type VARCHAR(50)"
            ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4"
        )

        lines.append(f'DBCONNECT {host}=OK')
        conn.close()
    except Exception as e:
        lines.append(f'MYSQL_CONNECT {host}={type(e).__name__}: {e}')
        print(f'MYSQL_CONNECT {host}={type(e).__name__}: {e}')

output_path.write_text('\n'.join(lines), encoding='utf-8')
print('WROTE', output_path)

