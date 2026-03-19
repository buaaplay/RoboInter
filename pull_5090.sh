#!/usr/bin/env bash
set -euo pipefail

WITH_RUNTIME=0
if [[ "${1:-}" == "--with-runtime" ]]; then
  WITH_RUNTIME=1
fi

cd /home/robot/project/RoboInter

DYNAMIC_FILES=(
  "RoboInterTools/asserts/demo_data/no_annotation_lang.json"
  "RoboInterTools/asserts/demo_data/has_annotation_lang.json"
  "RoboInterTools/asserts/demo_data/no_annotation_sam.json"
  "RoboInterTools/asserts/demo_data/has_annotation_sam.json"
  "RoboInterTools/asserts/demo_data/video_2_lang_anno.json"
  "RoboInterTools/user_config/error_video.txt"
)

TMP_DIR=""
restore_dynamic_files() {
  if [[ "$WITH_RUNTIME" -eq 0 && -n "$TMP_DIR" && -d "$TMP_DIR" ]]; then
    for file in "${DYNAMIC_FILES[@]}"; do
      if [[ -f "$TMP_DIR/$file" ]]; then
        mkdir -p "$(dirname "$file")"
        cp "$TMP_DIR/$file" "$file"
      fi
    done
    rm -rf "$TMP_DIR"
  fi
}

if [[ "$WITH_RUNTIME" -eq 0 ]]; then
  TMP_DIR="$(mktemp -d)"
  for file in "${DYNAMIC_FILES[@]}"; do
    if [[ -f "$file" ]]; then
      mkdir -p "$(dirname "$TMP_DIR/$file")"
      cp "$file" "$TMP_DIR/$file"
    fi
  done
  trap restore_dynamic_files EXIT
fi

git pull --ff-only buaaplay buaaplay/5090-sync
restore_dynamic_files
trap - EXIT
git rev-parse --short HEAD
