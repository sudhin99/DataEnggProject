#!/usr/bin/env bash
set -euo pipefail
# Creates or updates an Airflow connection `my_mysql_conn` using the CLI.
# Usage (inside Airflow environment or container):
#   MYSQL_USER=root MYSQL_PASSWORD='pwd' MYSQL_HOST=192.168.1.8 \ 
#     MYSQL_PORT=3306 MYSQL_DB=mysql ./create_my_mysql_conn.sh

: "${MYSQL_CONN_ID:=my_mysql_conn}"
: "${MYSQL_USER:=root}"
: "${MYSQL_PASSWORD:=Pritam@1994}"
: "${MYSQL_HOST:=192.168.1.8}"
: "${MYSQL_PORT:=3306}"
: "${MYSQL_DB:=mysql}"

CONN_URI="mysql+pymysql://${MYSQL_USER}:${MYSQL_PASSWORD}@${MYSQL_HOST}:${MYSQL_PORT}/${MYSQL_DB}"

echo "Creating/updating Airflow connection '${MYSQL_CONN_ID}' -> ${CONN_URI}"

# If running inside Docker Compose, run this inside the webserver/scheduler container.
airflow connections add "${MYSQL_CONN_ID}" --conn-uri "${CONN_URI}" --overwrite

echo "Done."
