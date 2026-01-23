#!/usr/bin/env bash
# deploy_release.sh

set -euo pipefail

### ----------------------------
### Config
### ----------------------------
REPO_MIRROR_DIR="/home/kdrogaieva/repo-mirror"
RELEASES_DIR="/home/kdrogaieva/releases"
CURRENT_LINK="${RELEASES_DIR}/current"

# Per your note:
COMPOSE_DIR="${COMPOSE_DIR:-/home/kdrogaieva/airflow_runtime}"
SERVICE_NAME="${SERVICE_NAME:-airflow-webserver}"

DBT_TARGET_NAME="${DBT_TARGET_NAME:-Prod}"

LOG_DIR="/home/kdrogaieva/deploy/logs"
LOCK_DIR="/home/kdrogaieva/deploy/locks"

REMOTE_REF="${REMOTE_REF:-origin/master}"

### ----------------------------
### Helpers
### ----------------------------
ts() { date +"%Y-%m-%d %H:%M:%S%z"; }
log() { echo "[$(ts)] $*"; }
die() { log "ERROR: $*"; return 1; }

mkdir -p "$LOG_DIR" "$LOCK_DIR"

LOCK_FILE="${LOCK_DIR}/deploy_release.lock"
exec 200>"$LOCK_FILE"
if ! flock -n 200; then
  echo "[$(ts)] ERROR: Another deploy is running (lock: $LOCK_FILE). Exiting."
  exit 1
fi

read_current_sha() {
  if [[ -L "$CURRENT_LINK" ]]; then
    local target
    target="$(readlink -f "$CURRENT_LINK" || true)"
    basename "$target" 2>/dev/null || true
  else
    echo ""
  fi
}

OLD_SHA="$(read_current_sha)"
NEW_SHA=""
ROLLBACK_NEEDED="YES"

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

cleanup_failed_release() {
  set +e
  if [[ -n "${NEW_SHA:-}" ]]; then
    local release_dir="${RELEASES_DIR}/${NEW_SHA}"
    local wt_dir="${release_dir}/transformations"

    log "Cleaning up failed release artifacts for SHA: ${NEW_SHA}"

    if [[ -d "${wt_dir}" ]]; then
      cd "$REPO_MIRROR_DIR" || true
      git worktree remove --force "${wt_dir}" >/dev/null 2>&1 || true
      rm -rf "${wt_dir}" || true
    fi

    if [[ -d "${release_dir}" ]]; then
      rmdir "${release_dir}" >/dev/null 2>&1 || rm -rf "${release_dir}" || true
    fi
  fi
}

### ----------------------------
### Logging
### ----------------------------
log "Starting deploy. Current SHA: ${OLD_SHA:-<none>}"

LOG_FILE="${LOG_DIR}/deploy_$(date +%Y%m%d_%H%M%S)_pending.log"
touch "$LOG_FILE"
chmod 600 "$LOG_FILE" || true
exec > >(tee -a "$LOG_FILE") 2>&1

trap 'rollback; cleanup_failed_release; log "DEPLOY FAILED — see log: $LOG_FILE"; exit 1' ERR INT TERM

### ----------------------------
### Fetch and resolve new SHA
### ----------------------------
log "Fetching latest from remote in: $REPO_MIRROR_DIR"
cd "$REPO_MIRROR_DIR"

git fetch --all --prune
NEW_SHA="$(git rev-parse "$REMOTE_REF")"
log "Resolved ${REMOTE_REF} -> ${NEW_SHA}"

# No-op if nothing new
if [[ -n "${OLD_SHA}" && "${NEW_SHA}" == "${OLD_SHA}" ]]; then
  NEW_LOG_FILE="${LOG_DIR}/deploy_$(date +%Y%m%d_%H%M%S)_${NEW_SHA}_noop.log"
  mv "$LOG_FILE" "$NEW_LOG_FILE" || true
  LOG_FILE="$NEW_LOG_FILE"
  log "No changes detected (NEW_SHA == OLD_SHA == ${NEW_SHA}). Nothing to deploy."
  trap - ERR INT TERM
  exit 0
fi

NEW_LOG_FILE="${LOG_DIR}/deploy_$(date +%Y%m%d_%H%M%S)_${NEW_SHA}.log"
mv "$LOG_FILE" "$NEW_LOG_FILE" || true
LOG_FILE="$NEW_LOG_FILE"
log "Logging to: $LOG_FILE"

### ----------------------------
### Create release worktree
### ----------------------------
RELEASE_DIR="${RELEASES_DIR}/${NEW_SHA}"
WT_DIR="${RELEASE_DIR}/transformations"

log "Creating release dir: $RELEASE_DIR"
mkdir -p "$RELEASE_DIR"

if [[ -d "$WT_DIR/.git" || -d "$WT_DIR" ]]; then
  log "Worktree path already exists: $WT_DIR"
  git worktree remove --force "$WT_DIR" >/dev/null 2>&1 || true
  rm -rf "$WT_DIR" || true
fi

log "Adding git worktree: $WT_DIR"
git worktree add "$WT_DIR" "$NEW_SHA"

log "Pointing current symlink: ${CURRENT_LINK} -> ${NEW_SHA}"
ln -sfn "$NEW_SHA" "$CURRENT_LINK"

### ----------------------------
### Run in-container steps
### ----------------------------
log "Running in-container steps via docker compose..."
cd "$COMPOSE_DIR"

# IMPORTANT: force PATH so dbt is found in non-interactive shells
# (common locations: /home/airflow/.local/bin, /usr/local/bin, etc.)
docker compose exec -T "$SERVICE_NAME" bash -c "
set -euo pipefail

# Make dbt discoverable even in non-interactive shells
export PATH=\"/home/airflow/.local/bin:/usr/local/bin:/usr/local/sbin:/usr/sbin:/usr/bin:/sbin:/bin:\$PATH\"

# Debug info (kept in log)
echo '[container] whoami:' \$(whoami)
echo '[container] PATH:' \"\$PATH\"
command -v python || true
command -v dbt || true

# If dbt still not found, try common absolute locations before failing
if ! command -v dbt >/dev/null 2>&1; then
  for p in /home/airflow/.local/bin/dbt /usr/local/bin/dbt /usr/bin/dbt; do
    if [[ -x \"\$p\" ]]; then
      export DBT_BIN=\"\$p\"
      break
    fi
  done
else
  export DBT_BIN=\"\$(command -v dbt)\"
fi

if [[ -z \"\${DBT_BIN:-}\" ]]; then
  echo 'FATAL: dbt not found even after PATH fix.'
  exit 1
fi

echo '[container] Using dbt at:' \"\$DBT_BIN\"

echo '[container] DBT project dir:' \"\$DBT_LCOM_DW_PROJECT_DIR\"
cd \"\$DBT_LCOM_DW_PROJECT_DIR\"

\"\$DBT_BIN\" deps
\"\$DBT_BIN\" compile --target ${DBT_TARGET_NAME}
\"\$DBT_BIN\" docs generate --static --target ${DBT_TARGET_NAME}

echo '[container] Running colibri...'
colibri generate \
  --manifest \"\$DBT_TARGET_PATH/manifest.json\" \
  --catalog  \"\$DBT_TARGET_PATH/catalog.json\" \
  --output-dir \"\$DBT_TARGET_PATH\"
"

log "Running dev_check_dags.py and validating output..."
DAG_CHECK_OUTPUT="$(docker compose exec -T "$SERVICE_NAME" bash -c "
set -euo pipefail
cd \"\$AIRFLOW__CORE__DAGS_FOLDER\"
python dev_check_dags.py
" || true)"

echo "$DAG_CHECK_OUTPUT"

if ! echo "$DAG_CHECK_OUTPUT" | grep -q "No import errors"; then
  die "dev_check_dags.py did not report 'No import errors' -> FAIL"
fi

log "All checks passed."


### ----------------------------
### Publish dbt docs (merged logs)
### ----------------------------
log "Publishing dbt docs to docs branch..."
/home/kdrogaieva/deploy/bin/publish_dbt_docs.sh
log "Docs published."



### ----------------------------
### Cleanup old releases (keep only current + previous)
### ----------------------------
log "Cleaning up old releases (keeping current=${NEW_SHA} and previous=${OLD_SHA:-<none>})..."

KEEP1="${NEW_SHA}"
KEEP2="${OLD_SHA:-}"

shopt -s nullglob
for d in "${RELEASES_DIR}"/*; do
  name="$(basename "$d")"

  # Only consider real directories in releases (ignore symlinks like 'current')
  if [[ -d "$d" && ! -L "$d" ]]; then
    # Keep current + previous; delete everything else
    if [[ "$name" != "$KEEP1" && ( -z "$KEEP2" || "$name" != "$KEEP2" ) ]]; then
      log "Removing old release dir: ${d}"
      rm -rf "$d"
    fi
  fi
done
shopt -u nullglob

trap - ERR INT TERM
log "DEPLOY SUCCESS — see log: $LOG_FILE"
ROLLBACK_NEEDED="NO"
exit 0
