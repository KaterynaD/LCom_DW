#!/usr/bin/env bash
# deploy_release_from_actions.sh
#
# Usage (from GitHub Actions on self-hosted runner):
#   ./deploy_release_from_actions.sh "<sha>" "<branch>"
#
# Example:
#   ./deploy_release_from_actions.sh "$GITHUB_SHA" "$GITHUB_REF_NAME"

set -euo pipefail

### ----------------------------
### Args
### ----------------------------
NEW_SHA="${1:-}"
BRANCH="${2:-}"

if [[ -z "$NEW_SHA" || -z "$BRANCH" ]]; then
  echo "ERROR: Missing args."
  echo "Usage: $0 <sha> <branch>"
  exit 2
fi

### ----------------------------
### Config
### ----------------------------
REPO_MIRROR_DIR="${REPO_MIRROR_DIR:-/home/kdrogaieva/Prod/repo-mirror}"
RELEASES_DIR="${RELEASES_DIR:-/home/kdrogaieva/Prod/releases}"
CURRENT_LINK="${RELEASES_DIR}/current"

# Per your note:
COMPOSE_DIR="${COMPOSE_DIR:-/home/kdrogaieva/Prod/airflow_runtime}"
SERVICE_NAME="${SERVICE_NAME:-airflow-webserver}"

DBT_TARGET_NAME="${DBT_TARGET_NAME:-Prod}"

LOG_DIR="${LOG_DIR:-/home/kdrogaieva/Prod/deploy/logs}"
LOCK_DIR="${LOCK_DIR:-/home/kdrogaieva/Prod/deploy/locks}"

# Remote used by repo-mirror
REMOTE_NAME="${REMOTE_NAME:-origin}"

# The branch ref we’ll fetch (we won’t auto-resolve SHA from it, but we’ll fetch it for verification)
REMOTE_BRANCH_REF="${REMOTE_NAME}/${BRANCH}"

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

LOG_FILE="${LOG_DIR}/deploy_$(date +%Y%m%d_%H%M%S)_pending.log"
touch "$LOG_FILE"
chmod 600 "$LOG_FILE" || true
exec > >(tee -a "$LOG_FILE") 2>&1

trap 'rollback; cleanup_failed_release; log "DEPLOY FAILED — see log: $LOG_FILE"; exit 1' ERR INT TERM

### ----------------------------
### Run in-container steps BEFORE new release
### dbt compile with predefined loaddate to compare later with new compile, the same predefined date to detect modified models
### ----------------------------
log "Pre-release running in-container steps via docker compose..."
cd "$COMPOSE_DIR"

docker compose exec -T "$SERVICE_NAME" bash -c "
set -euo pipefail

export PATH=\"/home/airflow/.local/bin:/usr/local/bin:/usr/local/sbin:/usr/sbin:/usr/bin:/sbin:/bin:\$PATH\"

echo '[container] whoami:' \$(whoami)
echo '[container] PATH:' \"\$PATH\"
command -v python || true
command -v dbt || true

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


\"\$DBT_BIN\" compile --target ${DBT_TARGET_NAME} --vars '{"loaddate": "1900-01-01"}'"




log "Starting deploy."
log "Requested: SHA=${NEW_SHA}  BRANCH=${BRANCH}  RemoteRef=${REMOTE_BRANCH_REF}"
log "Current SHA: ${OLD_SHA:-<none>}"



### ----------------------------
### Fetch + verify SHA exists
### ----------------------------
log "Fetching from remote in: $REPO_MIRROR_DIR"
cd "$REPO_MIRROR_DIR"

# Fetch the branch tip (fast, helps verification / logs)
git fetch --prune "$REMOTE_NAME" "$BRANCH" || git fetch --all --prune

# Ensure NEW_SHA exists locally; if not, fetch it explicitly
if ! git cat-file -e "${NEW_SHA}^{commit}" >/dev/null 2>&1; then
  log "SHA ${NEW_SHA} not found locally; fetching it explicitly..."
  git fetch --prune "$REMOTE_NAME" "${NEW_SHA}" || true
fi

# Re-check after fetch attempt
if ! git cat-file -e "${NEW_SHA}^{commit}" >/dev/null 2>&1; then
  die "SHA ${NEW_SHA} is not a valid commit in the mirror after fetch. Check workflow inputs / remote access."
fi

# Optional: validate SHA is reachable from the branch (can be strict or best-effort).
# If your workflow always passes a SHA from that branch, keep this STRICT.
if ! git merge-base --is-ancestor "${NEW_SHA}" "${REMOTE_BRANCH_REF}" >/dev/null 2>&1; then
  die "SHA ${NEW_SHA} is not an ancestor of ${REMOTE_BRANCH_REF}. Refusing to deploy (protects against wrong-branch deploy)."
fi

# No-op if nothing new
if [[ -n "${OLD_SHA}" && "${NEW_SHA}" == "${OLD_SHA}" ]]; then
  NEW_LOG_FILE="${LOG_DIR}/deploy_$(date +%Y%m%d_%H%M%S)_${NEW_SHA}_noop.log"
  mv "$LOG_FILE" "$NEW_LOG_FILE" || true
  LOG_FILE="$NEW_LOG_FILE"
  log "No changes detected (NEW_SHA == OLD_SHA == ${NEW_SHA}). Nothing to deploy."
  trap - ERR INT TERM
  exit 0
fi

NEW_LOG_FILE="${LOG_DIR}/deploy_$(date +%Y%m%d_%H%M%S)_${BRANCH}_${NEW_SHA}.log"
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

docker compose exec -T "$SERVICE_NAME" bash -c "
set -euo pipefail

export PATH=\"/home/airflow/.local/bin:/usr/local/bin:/usr/local/sbin:/usr/sbin:/usr/bin:/sbin:/bin:\$PATH\"

echo '[container] whoami:' \$(whoami)
echo '[container] PATH:' \"\$PATH\"
command -v python || true
command -v dbt || true

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


# Ensure state dir exists

STATE_DIR="\$DBT_TARGET_PATH/latest_prod_artifact"
mkdir -p "\$STATE_DIR"

# Preserve the existing (most recent) manifest BEFORE we compile (compile may overwrite it)
if [[ -f "\$DBT_TARGET_PATH/manifest.json" ]]; then
  cp -f "\$DBT_TARGET_PATH/manifest.json" "\$STATE_DIR/manifest.json"
  echo '[container] Saved prior manifest to: '"\$STATE_DIR"'/manifest.json'
else
  echo '[container] No prior manifest found at '"\$DBT_TARGET_PATH"'/manifest.json; state comparison will be skipped.'
fi


\"\$DBT_BIN\" deps


# List modified models ONLY if we have a state manifest to compare against
if [[ -f "\$STATE_DIR/manifest.json" ]]; then
  
\"\$DBT_BIN\" list \
  --select state:modified \
  --state \"\$STATE_DIR\" \
  --resource-type model \
  --target ${DBT_TARGET_NAME} \
  --vars '{"loaddate": "1900-01-01"}'

else
  echo '[container] Skipping: dbt list --select state:modified (missing '"\$STATE_DIR"'/manifest.json)'
fi

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
cd \"../utils/\"
python dev_check_dags.py
" || true)"

echo "$DAG_CHECK_OUTPUT"

if ! echo "$DAG_CHECK_OUTPUT" | grep -q "No import errors"; then
  die "dev_check_dags.py did not report 'No import errors' -> FAIL"
fi


docker compose exec -T "$SERVICE_NAME" bash -c "
set -euo pipefail
cd \"\$AIRFLOW__CORE__DAGS_FOLDER\"
cd \"../utils/\"
python set_airflow_variables.py
"

log "All checks passed."


### ----------------------------
### Cleanup old releases (keep only current + previous)
### ----------------------------
log "Cleaning up old releases (keeping current=${NEW_SHA} and previous=${OLD_SHA:-<none>})..."

KEEP1="${NEW_SHA}"
KEEP2="${OLD_SHA:-}"

shopt -s nullglob
for d in "${RELEASES_DIR}"/*; do
  name="$(basename "$d")"

  if [[ -d "$d" && ! -L "$d" ]]; then
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
