#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEFAULT_REMOTE="origin"
if git -C "$ROOT_DIR" remote | grep -qx "buaaplay"; then
  DEFAULT_REMOTE="buaaplay"
fi
MAIN_REMOTE="${1:-$DEFAULT_REMOTE}"
MAIN_BRANCH="${2:-$(git -C "$ROOT_DIR" branch --show-current)}"

ensure_clean_repo() {
  local repo_dir="$1"
  local repo_name="$2"

  if [[ -n "$(git -C "$repo_dir" status --porcelain)" ]]; then
    echo "Refusing to pull: $repo_name has uncommitted changes."
    git -C "$repo_dir" status --short
    exit 1
  fi
}

pull_repo() {
  local repo_dir="$1"
  local repo_name="$2"
  local remote_name="$3"
  local branch_name="$4"

  if [[ -z "$branch_name" ]]; then
    echo "Cannot determine branch for $repo_name."
    exit 1
  fi

  echo "==> Updating $repo_name ($remote_name/$branch_name)"
  ensure_clean_repo "$repo_dir" "$repo_name"
  git -C "$repo_dir" fetch "$remote_name" "$branch_name"
  git -C "$repo_dir" pull --ff-only "$remote_name" "$branch_name"
}

pull_repo "$ROOT_DIR" "RoboInter" "$MAIN_REMOTE" "$MAIN_BRANCH"
echo "==> Pull complete"
