#!/usr/bin/env bash
set -euo pipefail

cd /home/kdrogaieva/airflow_runtime

echo ">>> Initializing Airflow DB and creating admin user (Kate Drogaieva)..."
docker compose up airflow-init

echo ">>> Starting webserver and scheduler in background..."
docker compose up -d airflow-webserver airflow-scheduler

echo ">>> Airflow is starting. Check http://localhost:8080 (via SSH tunnel from your laptop)."
