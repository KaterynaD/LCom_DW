#!/usr/bin/env bash
set -euo pipefail

MAIL_FROM="kdrogaieva@learning.com"
MAIL_TO="kdrogaieva@learning.com"

COMPOSE_DIR="/home/kdrogaieva/Prod/airflow_runtime"
SERVICES=("airflow-webserver" "airflow-scheduler")

cd "$COMPOSE_DIR"

for svc in "${SERVICES[@]}"; do
  CID="$(docker compose ps -q "$svc" 2>/dev/null || true)"

  # Service not running at all in this compose project
  if [[ -z "$CID" ]]; then
    echo "Service '$svc' is NOT RUNNING (docker compose ps empty)


Time: $(date)
Compose dir: $COMPOSE_DIR

docker compose ps:
$(docker compose ps)
" | mail -r "$MAIL_FROM" -s "❌ Airflow service DOWN: $svc" "$MAIL_TO"
    continue
  fi

  STATE="$(docker inspect --format='{{.State.Status}}' "$CID" 2>/dev/null || echo unknown)"
  HEALTH="$(docker inspect --format='{{if .State.Health}}{{.State.Health.Status}}{{else}}no-healthcheck{{end}}' "$CID" 2>/dev/null || echo unknown)"

  if [[ "$STATE" != "running" || "$HEALTH" == "unhealthy" ]]; then
    echo "Airflow service problem detected

Service: $svc

Time: $(date)
Compose dir: $COMPOSE_DIR

Container ID: $CID
Container state: $STATE
Health status: $HEALTH

Last logs (tail 80):
$(docker logs --tail 80 "$CID" 2>/dev/null || true)
" | mail -r "$MAIL_FROM" -s "❌ Airflow issue: $svc ($STATE / $HEALTH)" "$MAIL_TO"
  fi
done
