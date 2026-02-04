#!/usr/bin/env bash
set -euo pipefail

# -------------------------
# Config (override in cron)
# -------------------------
RETENTION_DAYS=10
DRY_RUN=0

# Airflow task logs folder (recursive; delete old files)
AIRFLOW_LOG_DIR="/home/kdrogaieva/Prod/airflow_logs"

# dbt logs folder (delete rotated logs only; keep dbt.log)
DBT_LOG_DIR="/home/kdrogaieva/Prod/dbt_logs"

# Mail (optional). Set SEND_MAIL=0 to disable.
MAIL_FROM="kdrogaieva@learning.com"
MAIL_TO="kdrogaieva@learning.com"
MAIL_SUBJECT="Log cleanup report ($(hostname))"

# -------------------------
# Helpers
# -------------------------
die() { echo "ERROR: $*" >&2; exit 2; }

validate_dir() {
  local d="$1"
  [[ -n "$d" ]] || die "Empty directory path"
  [[ "$d" != "/" ]] || die "Refusing to operate on '/'"
  [[ -d "$d" ]] || die "Directory does not exist: $d"
  [[ ! -L "$d" ]] || die "Refusing to operate on symlink directory: $d"
}

validate_int() {
  local v="$1"
  [[ "$v" =~ ^[0-9]+$ ]] || die "RETENTION_DAYS must be a non-negative integer (got: $v)"
}

# mtime cutoff for "N days and older"
# find -mtime +9 matches >=10 days old (in the usual sense)
build_mtime_args() {
  local days="$1"
  if (( days == 0 )); then
    echo ""  # no mtime filter => everything
  else
    local cutoff=$(( days - 1 ))
    echo "-mtime +${cutoff}"
  fi
}

run_find_delete() {
  local label="$1"
  local base_dir="$2"
  local extra_find_args="$3"   # string of extra find predicates
  local mtime_args="$4"

  local deleted_count=0

  echo ""
  echo "---- ${label} ----"
  echo "Dir      : ${base_dir}"
  echo "Retention: ${RETENTION_DAYS} days"
  echo "Dry run  : ${DRY_RUN}"

  if [[ "${DRY_RUN}" == "1" ]]; then
    # shellcheck disable=SC2086
    deleted_count=$(find -P "${base_dir}" -type f ! -type l ${mtime_args} ${extra_find_args} -print | wc -l)
    echo "DRY RUN: ${deleted_count} files would be deleted."
    # shellcheck disable=SC2086
    find -P "${base_dir}" -type f ! -type l ${mtime_args} ${extra_find_args} -print
  else
    # shellcheck disable=SC2086
    deleted_count=$(find -P "${base_dir}" -type f ! -type l ${mtime_args} ${extra_find_args} -print -delete | wc -l)
    echo "Deleted: ${deleted_count} files."
  fi

  echo "${deleted_count}"
}

# -------------------------
# Main
# -------------------------
validate_int "${RETENTION_DAYS}"

START_TS="$(date -Is)"
HOST="$(hostname)"

# Validate directories if present (you can disable by setting var to empty)
AIRFLOW_DELETED=0
DBT_DELETED=0

MTIME_ARGS="$(build_mtime_args "${RETENTION_DAYS}")"

if [[ -n "${AIRFLOW_LOG_DIR}" ]]; then
  validate_dir "${AIRFLOW_LOG_DIR}"
  AIRFLOW_DELETED="$(run_find_delete "Airflow logs cleanup" "${AIRFLOW_LOG_DIR}" "" "${MTIME_ARGS}")"
fi

if [[ -n "${DBT_LOG_DIR}" ]]; then
  validate_dir "${DBT_LOG_DIR}"
  # Only delete rotated dbt logs (dbt.log.1, dbt.log.2, etc). Keep active dbt.log.
  # This matches files like dbt.log.1, dbt.log.2, dbt.log.2026-..., etc IF they start with dbt.log.
  DBT_DELETED="$(run_find_delete "dbt logs cleanup (rotated only)" "${DBT_LOG_DIR}" "-name 'dbt.log.*'" "${MTIME_ARGS}")"
fi

# Disk free after cleanup (for current filesystem of airflow logs if set, else use ".")
DF_TARGET="${AIRFLOW_LOG_DIR:-.}"
DISK_LINE="$(df -h "${DF_TARGET}" | awk 'NR==2')"
DISK_FS="$(echo "${DISK_LINE}" | awk '{print $1}')"
DISK_USED="$(echo "${DISK_LINE}" | awk '{print $5}')"
DISK_FREE="$(echo "${DISK_LINE}" | awk '{print $4}')"

END_TS="$(date -Is)"

REPORT=$(cat <<EOF
Log cleanup completed.

Host            : ${HOST}
Retention (days): ${RETENTION_DAYS}
Dry run         : ${DRY_RUN}

Airflow log dir : ${AIRFLOW_LOG_DIR}
Airflow deleted : ${AIRFLOW_DELETED}

dbt log dir     : ${DBT_LOG_DIR}
dbt deleted     : ${DBT_DELETED}

Disk filesystem : ${DISK_FS}
Disk used       : ${DISK_USED}
Disk free       : ${DISK_FREE}

Started at      : ${START_TS}
Finished at     : ${END_TS}
EOF
)

echo ""
echo "${REPORT}"


echo "${REPORT}" | mail -r "${MAIL_FROM}" -s "${MAIL_SUBJECT}" "${MAIL_TO}"

