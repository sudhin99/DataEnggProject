# Airflow setup helpers

Files included:

- `check_env.ps1` — PowerShell script to check WSL, Docker, and port 8080 on Windows.
- `setup_wsl_airflow.sh` — Shell script to run inside WSL (Ubuntu) that downloads the official `docker-compose.yaml` and writes `.env`.

Quick usage:

- On Windows (PowerShell):

```powershell
.\low\airflow_setup\check_env.ps1
```

- Inside WSL Ubuntu (after Docker Desktop is installed and WSL integration enabled):

```bash
cd ~/airflow  # or wherever you want
bash ~/path/to/setup_wsl_airflow.sh
docker compose up airflow-init
docker compose up -d
```

If you prefer, edit the `docker-compose.yaml` downloaded by the script to change host port mapping (e.g. map `8085:8080`) before starting services.
