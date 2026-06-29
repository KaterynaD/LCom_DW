#!/usr/bin/env bash
set -euo pipefail

REPO_MIRROR_DIR="${REPO_MIRROR_DIR:-/home/kdrogaieva/Prod/repo-mirror.git}"
REMOTE_NAME="${REMOTE_NAME:-origin}"
QA_BRANCH="${QA_BRANCH:-qa}"
MASTER_BRANCH="${MASTER_BRANCH:-master}"

git --git-dir="$REPO_MIRROR_DIR" fetch --prune "$REMOTE_NAME" \
  "+refs/heads/${QA_BRANCH}:refs/remotes/${REMOTE_NAME}/${QA_BRANCH}" \
  "+refs/heads/${MASTER_BRANCH}:refs/remotes/${REMOTE_NAME}/${MASTER_BRANCH}"

git --git-dir="$REPO_MIRROR_DIR" merge-base --is-ancestor \
  "${REMOTE_NAME}/${MASTER_BRANCH}" \
  "${REMOTE_NAME}/${QA_BRANCH}"

QA_SHA="$(git --git-dir="$REPO_MIRROR_DIR" rev-parse "${REMOTE_NAME}/${QA_BRANCH}")"

git --git-dir="$REPO_MIRROR_DIR" push "$REMOTE_NAME" \
  "${QA_SHA}:refs/heads/${MASTER_BRANCH}"