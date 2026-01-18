#!/usr/bin/env bash
# deploy_release.sh
#
# GitHub Actions–ready release deploy script (also runnable manually on host).
# - Fetches latest origin/master into a mirror repo
# - Creates a worktree release at /home/kdrogaieva/releases/<sha>/transformations
# - Re-points /home/kdrogaieva/releases/current -> <sha>
# - Runs dbt deps/compile/docs + colibri + dev_check_dags.py inside airflow-webserver container
# - Success requires dev_check_dags.py output to contain: "No import errors"
# - On any failure, rolls back /home/kdrogaieva/releases/current to previous SHA
# - Logs everything (no email/SMTP)
# - If NEW_SHA == OLD_SHA -> exits 0 early ("nothing to deploy")
#
# Exit codes:
#  0 success
#  1 failure (rolled back)

set -euo pipefail

### ----------------------------
### Config (edit if needed)
### ----------------------------
REPO_MIRROR_DIR="/home/kdrogaieva/repo-mirror"
RELEASES_DIR="/home/kdrogaieva/releases"
CURRENT_LINK="${RELEASES_DIR}/current"

# Where your docker-compose.yml is (must be the directory you run `docker compose ...` from)
COMPOSE_DIR="${COMPOSE_DIR:-/home/kdrogaieva/airflow_runtime}"
SERVICE_NAME="${SERVICE_NAME:-airflow-webserver}"

# In-container commands rely on these env vars existing inside the container:
#   DBT_LCOM_DW_PROJECT_DIR
#   DBT_TARGET_PATH
#   AIRFLOW__CORE__DAGS_FOLDER
DBT_TARGET_NAME="${DBT_TARGET_NAME:-Prod}"

# Logging / locking
LOG_DIR="/home/kdrogaieva/deploy/logs"
LOCK_DIR="/home/kdrogaieva/deploy/locks"

# Git ref to deploy
REMOTE_REF="${REMOTE_REF:-origin/master}"

### ----------------------------
### Helpers
### ----------------------------
ts() { date +"%Y-%m-%d %H:%M:%S%z"; }

mkdir -p "$LOG_DIR" "$LOCK_DIR"

LOCK_FILE="${LOCK_DIR}/deploy_release.lock"
exec 200>"$LOCK_FILE"
if ! flock -n 200; then
  echo "[$(ts)] ERROR: Another deploy is running (lock: $LOCK_FILE). Exiting."
  exit 1
fi

log() { echo "[$(ts)] $*"; }

die() {
  log "ERROR: $*"
  return 1
}

read_current_sha() {
  # Returns the SHA (basename) currently pointed to by releases/current (if exists)
  if [[ -L "$CURRENT_LINK" ]]; then
    local target
    target="$(readlink -f "$CURRENT_LINK" || true)"
    basename "$target" 2>/dev/null || true
  else
    echo ""
  fi
}

### ----------------------------
### Main
### ----------------------------
OLD_SHA="$(read_current_sha)"
log "Starting deploy. Current SHA: ${OLD_SHA:-<none>}"

# Prepare log file (include NEW_SHA once known)
LOG_FILE="${LOG_DIR}/deploy_$(date +%Y%m%d_%H%M%S)_pending.log"
touch "$LOG_FILE"
chmod 600 "$LOG_FILE" || true

# Mirror all output to log
exec > >(tee -a "$LOG_FILE") 2>&1

ROLLBACK_NEEDED="YES"
NEW_SHA=""

rollback() {
  set +e
  if [[ "$ROLLBACK_NEEDED" == "YES" ]]; then
    log "Rolling back current symlink..."
    if [[ -n "${OLD_SHA}" ]]; then
      ln -sfn "${OLD_SHA}" "$CURRENT_LINK"
      log "Rollback complete: ${CURRENT_LINK} -> ${OLD_SHA}"
    else
      log "No previous SHA found; leaving ${CURRENT_LINK} as-is."
    fi
  fi
}

trap 'rollback; log "DEPLOY FAILED — see log: $LOG_FILE"; exit 1' ERR INT TERM

log "Fetching latest from remote in: $REPO_MIRROR_DIR"
cd "$REPO_MIRROR_DIR"

git fetch --all --prune

NEW_SHA="$(git rev-parse "$REMOTE_REF")"
log "Resolved ${REMOTE_REF} -> ${NEW_SHA}"

# If nothing changed, exit successfully without doing any work
if [[ -n "${OLD_SHA}" && "${NEW_SHA}" == "${OLD_SHA}" ]]; then
  # Rename log to include SHA (nice-to-have)
  NEW_LOG_FILE="${LOG_DIR}/deploy_$(date +%Y%m%d_%H%M%S)_${NEW_SHA}_noop.log"
  mv "$LOG_FILE" "$NEW_LOG_FILE" || true
  LOG_FILE="$NEW_LOG_FILE"
  log "No changes detected (NEW_SHA == OLD_SHA == ${NEW_SHA}). Nothing to deploy."
  trap - ERR INT TERM
  exit 0
fi

# Update log filename now that we know SHA
NEW_LOG_FILE="${LOG_DIR}/deploy_$(date +%Y%m%d_%H%M%S)_${NEW_SHA}.log"
mv "$LOG_FILE" "$NEW_LOG_FILE" || true
LOG_FILE="$NEW_LOG_FILE"
log "Logging to: $LOG_FILE"

RELEASE_DIR="${RELEASES_DIR}/${NEW_SHA}"
WT_DIR="${RELEASE_DIR}/transformations"

log "Creating release dir: $RELEASE_DIR"
mkdir -p "$RELEASE_DIR"

# If an old worktree exists for this SHA, remove it safely
if [[ -d "$WT_DIR/.git" || -d "$WT_DIR" ]]; then
  log "Worktree path already exists: $WT_DIR"
  # Try to remove the worktree registration first (won't delete random dirs)
  git worktree remove --force "$WT_DIR" >/dev/null 2>&1 || true
  rm -rf "$WT_DIR" || true
fi

log "Adding git worktree: $WT_DIR"
git worktree add "$WT_DIR" "$NEW_SHA"

log "Pointing current symlink: ${CURRENT_LINK} -> ${NEW_SHA}"
ln -sfn "$NEW_SHA" "$CURRENT_LINK"

log "Running in-container steps via docker compose..."
cd "$COMPOSE_DIR"

# 1) dbt deps/compile/docs + colibri (in DBT project dir)
docker compose exec -T "$SERVICE_NAME" bash -lc "
set -euo pipefail
echo '[container] DBT project dir:' \"\$DBT_LCOM_DW_PROJECT_DIR\"
cd \"\$DBT_LCOM_DW_PROJECT_DIR\"

dbt deps
dbt compile --target ${DBT_TARGET_NAME}
dbt docs generate --static --target ${DBT_TARGET_NAME}

echo '[container] Running colibri...'
colibri generate \
  --manifest \"\$DBT_TARGET_PATH/manifest.json\" \
  --catalog  \"\$DBT_TARGET_PATH/catalog.json\" \
  --output-dir \"\$DBT_TARGET_PATH\"
"

# 2) dev_check_dags.py + success string check
log "Running dev_check_dags.py and validating output..."
DAG_CHECK_OUTPUT="$(docker compose exec -T "$SERVICE_NAME" bash -lc "
set -euo pipefail
cd \"\$AIRFLOW__CORE__DAGS_FOLDER\"
python dev_check_dags.py
" || true)"

echo "$DAG_CHECK_OUTPUT"

if ! echo "$DAG_CHECK_OUTPUT" | grep -q "No import errors"; then
  die "dev_check_dags.py did not report 'No import errors' -> FAIL"
fi

log "All checks passed."
ROLLBACK_NEEDED="NO"

trap - ERR INT TERM
log "DEPLOY SUCCESS — see log: $LOG_FILE"
exit 0
