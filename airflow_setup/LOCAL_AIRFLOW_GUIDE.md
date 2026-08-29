# Local Airflow and MySQL guide

This project runs Airflow in WSL2. Do not run the `airflow` command from Windows PowerShell: the Windows installation is unsupported and can select the wrong Python runtime.

## 1. Start WSL and activate the supported runtime

From PowerShell:

```powershell
wsl -d Ubuntu-26.04
```

Inside Ubuntu:

```bash
source ~/.pyenv/versions/3.11.9/bin/activate
export AIRFLOW_HOME=$HOME/airflow-dev
mkdir -p "$AIRFLOW_HOME/dags"
```

The supported runtime is Python 3.11.9 with Airflow 3.0.0. Confirm it:

```bash
python --version
airflow version
```

## 2. Use the project DAGs

The project is stored on the Windows filesystem. Point Airflow at its DAG directory for this shell:

```bash
export AIRFLOW__CORE__DAGS_FOLDER=/mnt/c/Users/pritam/DataEnggProject/DataEnggProject/airflow_setup/DAGs
```

The SQL file used by the demo DAG is `DAGs/queries/demo.sql` and currently runs `SELECT 1 + 1 AS result`.

To make the exports permanent, add the same three `export` lines to `~/.bashrc`, then run `source ~/.bashrc`.

## 3. Repair a disposable local metadata database

The metadata database is Airflow's own SQLite database. It is not the MySQL database used by DAG tasks. Stop Airflow processes first, then back up and rebuild only the local metadata database:

```bash
pkill -f airflow || true
mv "$AIRFLOW_HOME/airflow.db" "$AIRFLOW_HOME/airflow.db.backup.$(date +%Y%m%d%H%M%S)" 2>/dev/null || true
airflow db migrate
```

This removes Airflow task history, connections, variables, and users from the local development metadata store. It does not alter project files or application MySQL data. For a shared or production metadata database, take a database backup and run `airflow db migrate` instead; do not edit `alembic_version` manually.

## 4. Configure the MySQL connection

Set these values to the host and credentials of the MySQL server. Do not commit passwords to the repository:

```bash
export AIRFLOW_CONN_MY_MYSQL_CONN='mysql+pymysql://USER:PASSWORD@MYSQL_HOST:3306/DATABASE'
airflow connections get my_mysql_conn
```

Alternatively create it through the Airflow UI or CLI:

```bash
airflow connections add my_mysql_conn \
  --conn-type mysql \
  --conn-host MYSQL_HOST \
  --conn-port 3306 \
  --conn-login USER \
  --conn-password 'PASSWORD' \
  --conn-schema DATABASE
```

The MySQL server must accept connections from WSL. Test the port before running a DAG:

```bash
nc -vz MYSQL_HOST 3306
```

If MySQL is running on Windows, use the Windows host IP visible in `/etc/resolv.conf` or set `MYSQL_HOST` explicitly. `localhost` inside WSL is not always the Windows host.

## 5. Start Airflow

```bash
airflow standalone
```

Open `http://localhost:8080`. The generated login password is stored at:

```bash
cat "$AIRFLOW_HOME/simple_auth_manager_passwords.json.generated"
```

Leave this terminal running. Use a second WSL terminal for CLI commands.

## 6. Run the hosted SQL script

In the second WSL terminal, repeat the activation and exports from steps 1 and 2, then verify the DAG:

```bash
airflow dags list | grep DEMO_SQL
airflow dags test DEMO_SQL 2026-01-01
```

Or trigger it through the UI by opening `DEMO_SQL` and selecting **Trigger DAG**. The `execute_sql_file` task reads `queries/demo.sql` and executes it through the `my_mysql_conn` connection.

## Troubleshooting

- `Can't locate revision identified by ...`: the metadata database and Airflow package do not share the same migration history. Rebuild the disposable local `airflow.db` as in step 3, or restore a backup and migrate with the original Airflow version first.
- `airflow: command not found`: activate `/home/pritam/.pyenv/versions/3.11.9/bin/activate` inside WSL.
- `FileNotFoundError ... queries/demo.sql`: ensure `AIRFLOW__CORE__DAGS_FOLDER` points to this project's `airflow_setup/DAGs` directory.
- MySQL connection refused or timed out: verify MySQL is running, listening on port 3306, and allowing the WSL source address. Check firewall and bind-address settings on the MySQL host.
- Do not use the Windows `airflow.exe`; it is not a supported Airflow runtime.
