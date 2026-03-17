#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TOOLS_DIR="$ROOT_DIR/RoboInterTools"

USERNAME="${1:-root}"
TIME_ARG="${2:-0}"
CONFIG_PATH="${3:-./config/config.yaml}"

cd "$TOOLS_DIR"

echo "Running SAM parse for user=$USERNAME time=$TIME_ARG"
python tools/parse_sam.py --config "$CONFIG_PATH" --username "$USERNAME" --time "$TIME_ARG"
