#!/usr/bin/env bash
set -euo pipefail

# --- CONFIG ---
WEBSERVER_SERVICE="airflow-webserver"
SCHEDULER_SERVICE="airflow-scheduler"
# --------------

echo "==========================================================="

echo ">>> Starting Airflow webserver and scheduler (if stopped)..."
cd /home/kdrogaieva/transformations/infra/ec2-airflow-docker
docker compose start "$WEBSERVER_SERVICE" >/dev/null 2>&1 || true
docker compose start "$SCHEDULER_SERVICE" >/dev/null 2>&1 || true



echo ">>> SUCCESS! Airflow webserver & scheduler are running"
echo "==========================================================="
