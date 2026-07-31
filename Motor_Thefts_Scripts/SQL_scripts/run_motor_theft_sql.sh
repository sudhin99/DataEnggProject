#!/bin/bash
set -euo pipefail

# Example cron entry:
# 0 * * * * /bin/bash /path/to/Motor_Thefts_Scripts/SQL_scripts/run_motor_theft_sql.sh /path/to/Motor_Thefts_Scripts/SQL_scripts/practice/01_data_quality_checks.sql >> /tmp/motor_theft_cron.log 2>&1

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${CONFIG_FILE:-$SCRIPT_DIR/../Config/db_config.ini}"
DEFAULT_SQL_FILE="$SCRIPT_DIR/practice/01_data_quality_checks.sql"
SQL_FILE="${1:-${SQL_FILE:-$DEFAULT_SQL_FILE}}"
DB_NAME="${DB_NAME:-motot_theaft}"
LOG_DIR="${LOG_DIR:-$SCRIPT_DIR/logs}"
LOG_FILE="${LOG_FILE:-$LOG_DIR/run_motor_theft_sql.log}"

mkdir -p "$LOG_DIR"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "MySQL config file not found: $CONFIG_FILE" >&2
    exit 1
fi

if [ ! -f "$SQL_FILE" ]; then
    echo "SQL file not found: $SQL_FILE" >&2
    exit 1
fi

if ! command -v mysql >/dev/null 2>&1; then
    echo "mysql client not found in PATH" >&2
    exit 1
fi

read_ini_value() {
    local section="$1"
    local key="$2"

    awk -F= -v section="$section" -v key="$key" '
        $0 ~ /^\[/ { in_section=0 }
        $0 ~ "^\[" section "\]" { in_section=1; next }
        in_section {
            sub(/^[[:space:]]+/, "", $0)
            sub(/[[:space:]]+$/, "", $0)
            if ($0 ~ /^#|^;/) next
            if ($0 ~ "^" key "[[:space:]]*=") {
                sub("^[^=]+=", "", $0)
                sub(/^[[:space:]]+/, "", $0)
                sub(/[[:space:]]+$/, "", $0)
                print $0
                exit
            }
        }
    ' "$CONFIG_FILE"
}

DB_HOST="$(read_ini_value mysql host)"
DB_PORT="$(read_ini_value mysql port)"
DB_USER="$(read_ini_value mysql user)"
DB_PASSWORD="$(read_ini_value mysql password)"
DB_NAME_CONFIG="$(read_ini_value mysql database)"

DB_HOST="${DB_HOST:-127.0.0.1}"
DB_PORT="${DB_PORT:-3306}"
DB_USER="${DB_USER:-root}"
DB_PASSWORD="${DB_PASSWORD:-}"
DB_NAME="${DB_NAME:-${DB_NAME_CONFIG:-motot_theaft}}"

{
    echo "===== $(date '+%Y-%m-%d %H:%M:%S') ====="
    echo "Running SQL file: $SQL_FILE"
    MYSQL_PWD="$DB_PASSWORD" mysql --host="$DB_HOST" --port="$DB_PORT" --user="$DB_USER" "$DB_NAME" < "$SQL_FILE"
    echo "Completed successfully"
} 2>&1 | tee -a "$LOG_FILE"
