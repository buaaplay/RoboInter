#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SAM2_DIR="$ROOT_DIR/RoboInterTools/sam2"
STAMP="20260317_113721"
BACKUP_ROOT="$(cd "$ROOT_DIR/.." && pwd)/RoboInter_backups"
BACKUP_DIR="$BACKUP_ROOT/sam2_git_$STAMP"

if [[ ! -d "$SAM2_DIR" ]]; then
  echo "sam2 directory not found: $SAM2_DIR"
  exit 1
fi

if [[ ! -d "$SAM2_DIR/.git" ]]; then
  echo "sam2 is already a normal directory."
  exit 0
fi

mkdir -p "$BACKUP_ROOT"
mv "$SAM2_DIR/.git" "$BACKUP_DIR"

echo "Moved nested sam2 git metadata to: $BACKUP_DIR"
echo "sam2 is now ready to be tracked as a normal directory by the parent repo."
