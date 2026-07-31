#!/usr/bin/env bash
set -euo pipefail

AIRFLOW_VERSION=${AIRFLOW_VERSION:-2.6.3}
PYTHON_VERSION=${PYTHON_VERSION:-3.10}

echo "Preparing Airflow directory in home..."
mkdir -p ~/airflow
cd ~/airflow
mkdir -p dags logs plugins

if ! command -v curl >/dev/null 2>&1; then
  echo "curl not found — installing curl (requires sudo)"
  sudo apt update && sudo apt install -y curl
fi

echo "Downloading official docker-compose.yaml for Airflow ${AIRFLOW_VERSION}..."
curl -LfO "https://airflow.apache.org/docs/apache-airflow/${AIRFLOW_VERSION}/docker-compose.yaml"
echo "AIRFLOW_UID=$(id -u)" > .env

echo "Run 'docker compose up airflow-init' and then 'docker compose up -d' from this directory once Docker is available."
