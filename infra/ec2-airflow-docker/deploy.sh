#!/usr/bin/env bash
# /home/kdrogaieva/deploy/bin/deploy.sh
#
# Stable deploy launcher.
# Called by GitHub Actions or manually.
#
# Usage:
#   deploy.sh <git_sha>

set -euo pipefail

NEW_SHA="${1:-}"
[[ -n "$NEW_SHA" ]] || { echo "Usage: $0 <git_sha>"; exit 1; }

REPO_SSH_URL="git@github.com:learningcom/transformations.git"

BASE_DIR="/home/kdrogaieva"
MIRROR_DIR="$BASE_DIR/repo-mirror"
RELEASES_DIR="$BASE_DIR/releases"
ACTIVE_LINK="$BASE_DIR/transformations"
LOCK_FILE="$BASE_DIR/deploy.lock"

log() { echo "[$(date -Is)] $*"; }

NEW_RELEASE="$RELEASES_DIR/$NEW_SHA/transformations"
DEPLOY_SCRIPT="$NEW_RELEASE/infra/ec2-airflow-docker/deploy_release.sh"

cleanup_lock() {
  rm -f "$LOCK_FILE" || true
}

cleanup_failed_worktree() {
  # Only cleanup if we actually created/used this release dir
  if [[ -d "$NEW_RELEASE" && -d "$MIRROR_DIR/.git" ]]; then
    log "Deploy failed. Cleaning up worktree for release: $NEW_RELEASE"
    (
      cd "$MIRROR_DIR" || exit 0

      # If it's registered as a worktree, remove it
      # (If not, this will fail harmlessly; we ignore errors.)
      git worktree remove --force "$NEW_RELEASE" >/dev/null 2>&1 || true

      # Remove leftover directory (defense-in-depth)
      rm -rf "$NEW_RELEASE" >/dev/null 2>&1 || true

      # Prune stale metadata
      git worktree prune >/dev/null 2>&1 || true
    )
    log "Cleanup complete."
  fi
}

# Always remove lock; additionally cleanup worktree only on failure
on_exit() {
  rc=$?
  if [[ $rc -ne 0 ]]; then
    cleanup_failed_worktree
  fi
  cleanup_lock
  exit $rc
}
trap on_exit EXIT

#######################################
# Lock
#######################################
if [[ -e "$LOCK_FILE" ]]; then
  echo "ERROR: deploy.lock exists"
  exit 1
fi
echo "$(date -Is) $$" > "$LOCK_FILE"

#######################################
# Ensure mirror repo
#######################################
if [[ ! -d "$MIRROR_DIR/.git" ]]; then
  log "Cloning mirror repo..."
  git clone "$REPO_SSH_URL" "$MIRROR_DIR"
fi

cd "$MIRROR_DIR"
git fetch --all --prune

git cat-file -e "${NEW_SHA}^{commit}" \
  || { echo "ERROR: SHA not found: $NEW_SHA"; exit 1; }

#######################################
# Create new release directory
#######################################
if [[ ! -d "$NEW_RELEASE" ]]; then
  log "Creating new release: $NEW_RELEASE"
  git worktree add "$NEW_RELEASE" "$NEW_SHA"
else
  log "Release already exists: $NEW_RELEASE"
fi

#######################################
# Execute versioned deploy script
#######################################
if [[ ! -x "$DEPLOY_SCRIPT" ]]; then
  echo "ERROR: deploy_release.sh not found or not executable:"
  echo "  $DEPLOY_SCRIPT"
  exit 1
fi

log "Executing versioned deploy script"
"$DEPLOY_SCRIPT" "$NEW_SHA"
log "Deploy script completed successfully."
