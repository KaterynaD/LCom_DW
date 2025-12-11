#!/usr/bin/env bash
set -euo pipefail

cd /home/kdrogaieva/transformations/infra/ec2-airflow-docker

echo ">>> Stopping Airflow webserver, scheduler, and Postgres..."
docker compose stop airflow-webserver airflow-scheduler postgres || true

echo ">>> Airflow services stopped."
