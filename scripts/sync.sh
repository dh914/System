#!/usr/bin/env bash
# Pull latest repository state and hard-reset working tree to match origin.
# Intended to run from a launchd agent (macOS) / systemd timer (Linux) / cron.
#
# Usage:
#   SYSTEM_REPO_DIR=/path/to/local/System scripts/sync.sh
#
# Behavior:
#   - fetches origin
#   - hard-resets the current branch to origin/<default-branch>
#   - prunes deleted remote branches
#   - logs to $SYSTEM_REPO_DIR/.sync.log

set -euo pipefail

REPO_DIR="${SYSTEM_REPO_DIR:-${1:-}}"
if [ -z "${REPO_DIR}" ]; then
  echo "error: set SYSTEM_REPO_DIR or pass path as first argument" >&2
  exit 2
fi
if [ ! -d "${REPO_DIR}/.git" ]; then
  echo "error: ${REPO_DIR} is not a git repository" >&2
  exit 2
fi

cd "${REPO_DIR}"
LOG="${REPO_DIR}/.sync.log"
TS="$(date -u +'%Y-%m-%dT%H:%M:%SZ')"

{
  echo "=== ${TS} sync ==="
  git fetch --prune origin
  DEFAULT_BRANCH="$(git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null | sed 's@^origin/@@' || echo main)"
  CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"

  if [ "${CURRENT_BRANCH}" != "${DEFAULT_BRANCH}" ]; then
    echo "switching ${CURRENT_BRANCH} -> ${DEFAULT_BRANCH}"
    git checkout "${DEFAULT_BRANCH}" 2>/dev/null || git checkout -B "${DEFAULT_BRANCH}" "origin/${DEFAULT_BRANCH}"
  fi

  # Stash any local junk so reset can't fail; do not auto-restore.
  if ! git diff --quiet || ! git diff --cached --quiet; then
    git stash push -u -m "sync-autostash-${TS}" || true
    echo "warning: local changes stashed as sync-autostash-${TS}"
  fi

  git reset --hard "origin/${DEFAULT_BRANCH}"
  git clean -fdx -e .sync.log
  echo "ok: HEAD now at $(git rev-parse --short HEAD)"
} >> "${LOG}" 2>&1
