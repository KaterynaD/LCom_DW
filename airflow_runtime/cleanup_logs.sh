#!/usr/bin/env bash
set -euo pipefail

# -------------------------
# Config (override in cron)
# -------------------------
RETENTION_DAYS=10
DRY_RUN=0

# Airflow task logs folder (recursive; delete old files)
AIRFLOW_LOG_DIR="/home/kdrogaieva/Prod/airflow_logs"

# Deploy logs folder (recursive; delete old files)
DEPLOY_LOG_DIR="/home/kdrogaieva/Prod/deploy/logs"



MAIL_FROM="reportinganalytics@learning.com"
MAIL_TO="reportinganalytics@learning.com"
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
# find -mtime +9 matches >=10 days old
build_mtime_args() {
  local days="$1"
  if (( days == 0 )); then
    echo ""
  else
    echo "-mtime +$((days - 1))"
  fi
}

run_find_delete() {
  local label="$1"
  local base_dir="$2"
  local mtime_args="$3"
  local deleted_count=0

  echo ""
  echo "---- ${label} ----"
  echo "Dir      : ${base_dir}"
  echo "Retention: ${RETENTION_DAYS} days"
  echo "Dry run  : ${DRY_RUN}"

  if [[ "${DRY_RUN}" == "1" ]]; then
    # shellcheck disable=SC2086
    deleted_count=$(find -P "${base_dir}" -type f ! -type l ${mtime_args} -print | wc -l)
    echo "DRY RUN: ${deleted_count} files would be deleted."
    # shellcheck disable=SC2086
    find -P "${base_dir}" -type f ! -type l ${mtime_args} -print
  else
    # shellcheck disable=SC2086
    deleted_count=$(find -P "${base_dir}" -type f ! -type l ${mtime_args} -print -delete | wc -l)
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

AIRFLOW_DELETED=0
DEPLOY_DELETED=0

MTIME_ARGS="$(build_mtime_args "${RETENTION_DAYS}")"

if [[ -n "${AIRFLOW_LOG_DIR}" ]]; then
  validate_dir "${AIRFLOW_LOG_DIR}"
  AIRFLOW_DELETED="$(run_find_delete "Airflow logs cleanup" "${AIRFLOW_LOG_DIR}" "${MTIME_ARGS}")"
fi

if [[ -n "${DEPLOY_LOG_DIR}" ]]; then
  validate_dir "${DEPLOY_LOG_DIR}"
  DEPLOY_DELETED="$(run_find_delete "Deploy logs cleanup" "${DEPLOY_LOG_DIR}" "${MTIME_ARGS}")"
fi

# Disk free after cleanup (use airflow logs filesystem if available)
DF_TARGET="${AIRFLOW_LOG_DIR:-.}"
DISK_LINE="$(df -h "${DF_TARGET}" | awk 'NR==2')"
DISK_FS="$(echo "${DISK_LINE}" | awk '{print $1}')"
DISK_USED="$(echo "${DISK_LINE}" | awk '{print $5}')"
DISK_FREE="$(echo "${DISK_LINE}" | awk '{print $4}')"

END_TS="$(date -Is)"

REPORT=$(cat <<EOF
Log cleanup completed.


Retention (days): ${RETENTION_DAYS}
Dry run         : ${DRY_RUN}

Airflow log dir : ${AIRFLOW_LOG_DIR}
Airflow deleted : ${AIRFLOW_DELETED}

Deploy log dir  : ${DEPLOY_LOG_DIR}
Deploy deleted  : ${DEPLOY_DELETED}

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

