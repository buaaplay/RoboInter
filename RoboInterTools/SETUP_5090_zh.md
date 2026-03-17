# RoboInterTools 5090 Setup

这份说明对应机器路径：

`/home/robot/project/RoboInter`

工具目录：

`/home/robot/project/RoboInter/RoboInterTools`

## 1. 当前代码实际依赖

当前仓库里实际使用的是内嵌的 `sam2/` 目录，而不是 README 里提到的 `segment-anything-2/`。

`tools/sam.py` 直接导入：

```python
from sam2.build_sam import build_sam2_video_predictor
```

因此当前环境里必须满足两件事：

1. `RoboInterTools/sam2` 已经存在
2. 这个目录已经在同一个 Python 环境中执行过 `pip install -e .`

## 2. 你必须准备的目录

在 `RoboInterTools` 根目录下至少要有这些目录：

```text
RoboInterTools/
├── config/
│   └── config.yaml
├── sam2/
│   ├── checkpoints/
│   │   └── sam2.1_hiera_large.pt
├── asserts/
│   └── demo_data/
│       ├── video/
│       ├── human_anno_lang/
│       └── human_anno_sam/
│           └── 0/
│               ├── sam/
│               ├── sam_mask/
│               └── sam_video/
└── user_config/
```

建议直接执行：

```bash
cd /home/robot/project/RoboInter/RoboInterTools
mkdir -p config
mkdir -p asserts/demo_data/video
mkdir -p asserts/demo_data/human_anno_lang
mkdir -p asserts/demo_data/human_anno_sam/0/sam
mkdir -p asserts/demo_data/human_anno_sam/0/sam_mask
mkdir -p asserts/demo_data/human_anno_sam/0/sam_video
mkdir -p user_config/lang
mkdir -p user_config/sam
touch user_config/error_video.txt
```

## 3. 视频要什么格式

最小要求：

- 文件格式是 `.mp4`
- 一个视频对应一个完整操作 episode
- 视频中不要混入多个完全不相关任务
- 目标物体和机械臂尽量持续可见
- 不要求必须有 GPT 草稿

推荐形态：

- 固定视角
- 从任务开始录到任务结束
- 视频不要中途剪切
- 尽量不要大幅抖动

例如：

```text
asserts/demo_data/video/demo_001.mp4
asserts/demo_data/video/demo_002.mp4
```

## 4. GPT / `lang_anno` 是否必须

不是必须。

输入 JSON 的 value 是“已有语言草稿路径”：

- 没有草稿：写空字符串 `""`
- 有草稿：写 `.npz` 路径

所以你现在完全可以先不准备 GPT 数据，先把分割流程和手工语言标注流程跑通。

## 5. 输入 JSON 格式

创建：

`asserts/demo_data/video_2_lang_anno.json`

内容示例：

```json
{
  "asserts/demo_data/video/demo_001.mp4": "",
  "asserts/demo_data/video/demo_002.mp4": ""
}
```

含义：

- key：视频路径，相对于 `RoboInterTools` 根目录
- value：已有语言预标注 `.npz` 路径，没有就留空

## 6. 配置文件

仓库里已经补了一份：

`config/config.yaml`

关键点：

- `root_dir` 固定写成 `/home/robot/project/RoboInter/RoboInterTools`
- 权重路径按你现在的目录写成 `sam2/checkpoints/sam2.1_hiera_large.pt`
- 模型配置路径使用当前仓库真实存在的
  `sam2/sam2/configs/sam2/sam2_hiera_l.yaml`

## 7. 生成任务池

在 `RoboInterTools` 根目录执行：

```bash
python tools/generate_annotation_pool.py \
  --input asserts/demo_data/video_2_lang_anno.json \
  --output asserts/demo_data
```

生成后会得到：

- `asserts/demo_data/no_annotation_lang.json`
- `asserts/demo_data/has_annotation_lang.json`
- `asserts/demo_data/no_annotation_sam.json`
- `asserts/demo_data/has_annotation_sam.json`

## 8. 启动顺序

### 8.1 启动服务端

```bash
cd /home/robot/project/RoboInter/RoboInterTools
python server/server.py --config ./config/config.yaml --port 5000
```

### 8.2 启动客户端

新开一个终端：

```bash
cd /home/robot/project/RoboInter/RoboInterTools/client
python client.py
```

登录信息：

- 用户名：`root`
- IP：`127.0.0.1`
- 端口：`5000`

如果先做分割：

- 模式：`分割标注`
- 轮次：`0`

如果先做语言：

- 模式：`语言标注`

## 9. 分割标注后跑 SAM2

做完第 0 轮分割点标后：

```bash
cd /home/robot/project/RoboInter/RoboInterTools
python tools/parse_sam.py --config ./config/config.yaml --username root --time 0
```

如果显存压力大：

```bash
python tools/parse_sam.py --config ./config/config.yaml --username root --time 0 --low
```

输出：

- `asserts/demo_data/human_anno_sam/0/sam_mask/*.npz`
- `asserts/demo_data/human_anno_sam/0/sam_video/*.mp4`

## 10. 最小跑通清单

```bash
cd /home/robot/project/RoboInter/RoboInterTools
python -c "import sam2; print('sam2 ok')"
python -c "from sam2.build_sam import build_sam2_video_predictor; print('build ok')"
python -c "import PyQt5, flask, cv2, portalocker, imageio; print('deps ok')"
```

然后按顺序：

1. 放 `.mp4` 到 `asserts/demo_data/video/`
2. 创建 `asserts/demo_data/video_2_lang_anno.json`
3. 跑 `generate_annotation_pool.py`
4. 跑 `server.py`
5. 跑 `client.py`
6. 做一轮点标
7. 跑 `parse_sam.py --time 0`

## 11. 当前公开代码里能确认的边界

- GPT 预标注不是必须
- 语言标注可以纯人工做
- 最完整可跑的是“语言标注 + SAM 分割多轮质检”
- 其他论文里提到的自动派生字段，并没有在这个工具仓库中完整公开整条生成链
