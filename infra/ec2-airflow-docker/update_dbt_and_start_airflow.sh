#!/usr/bin/env bash
set -euo pipefail

# --- CONFIG ---
HOST_REPO_DIR="/home/kdrogaieva/transformations"
CONTAINER_DBT_DIR="/opt/airflow/transformations/dbt/LCom_DW"
WEBSERVER_SERVICE="airflow-webserver"
SCHEDULER_SERVICE="airflow-scheduler"
BRANCH_NAME="master"   # change if you use 'main' or another branch
# --------------

echo "==========================================================="
echo "  Updating dbt project and ensuring Airflow is running"
echo "==========================================================="

echo ">>> Pulling latest dbt repo on EC2 host..."
cd "$HOST_REPO_DIR"
#git pull origin "$BRANCH_NAME"

echo ">>> Starting Airflow webserver and scheduler (if stopped)..."
cd /home/kdrogaieva/transformations/infra/ec2-airflow-docker
docker compose start "$WEBSERVER_SERVICE" >/dev/null 2>&1 || true
docker compose start "$SCHEDULER_SERVICE" >/dev/null 2>&1 || true

echo ">>> Running 'dbt deps' inside $WEBSERVER_SERVICE container..."
docker compose exec "$WEBSERVER_SERVICE" bash -c "
  cd '$CONTAINER_DBT_DIR' &&
  dbt deps
"

echo ">>> SUCCESS! Airflow webserver & scheduler are running, dbt deps completed."
echo "==========================================================="
