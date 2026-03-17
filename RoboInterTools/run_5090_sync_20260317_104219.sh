#!/usr/bin/env bash
set -euo pipefail

ROOT="/home/robot/project/RoboInter/RoboInterTools"

echo "[1/5] Move to RoboInterTools root"
cd "$ROOT"

echo "[2/5] Ensure required directories exist"
mkdir -p config
mkdir -p asserts/demo_data/video
mkdir -p asserts/demo_data/human_anno_lang
mkdir -p asserts/demo_data/human_anno_sam/0/sam
mkdir -p asserts/demo_data/human_anno_sam/0/sam_mask
mkdir -p asserts/demo_data/human_anno_sam/0/sam_video
mkdir -p user_config/lang
mkdir -p user_config/sam
touch user_config/error_video.txt

echo "[3/5] Check input video"
if [[ ! -f "$ROOT/asserts/demo_data/video/video_001.mp4" ]]; then
  echo "Missing video: $ROOT/asserts/demo_data/video/video_001.mp4"
  echo "Put your test video there, then rerun this script."
  exit 1
fi
ls -lh "$ROOT/asserts/demo_data/video/video_001.mp4"

echo "[4/5] Rebuild annotation pools"
python "$ROOT/tools/generate_annotation_pool.py" \
  --input "$ROOT/asserts/demo_data/video_2_lang_anno.json" \
  --output "$ROOT/asserts/demo_data"

echo "[5/5] Show current task pools"
echo "--- no_annotation_sam.json ---"
cat "$ROOT/asserts/demo_data/no_annotation_sam.json"
echo
echo "--- no_annotation_lang.json ---"
cat "$ROOT/asserts/demo_data/no_annotation_lang.json"
echo

cat <<'EOF'

Next:

1. Start server:
cd /home/robot/project/RoboInter/RoboInterTools
python server/server.py --config /home/robot/project/RoboInter/RoboInterTools/config/config.yaml --port 5000

2. In another terminal:
unset http_proxy
unset https_proxy
unset HTTP_PROXY
unset HTTPS_PROXY
export no_proxy=127.0.0.1,localhost
export NO_PROXY=127.0.0.1,localhost
cd /home/robot/project/RoboInter/RoboInterTools
python client/client.py

3. Client login:
username: root
ip: 127.0.0.1
port: 5000
mode: 分割标注
round: 0

4. After saving one SAM annotation:
cd /home/robot
python /home/robot/project/RoboInter/RoboInterTools/tools/parse_sam.py \
  --config /home/robot/project/RoboInter/RoboInterTools/config/config.yaml \
  --username root \
  --time 0

EOF
