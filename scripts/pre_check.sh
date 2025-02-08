#!/bin/bash
# AI调用预处理脚本

MAX_LINES=5  # 超过5行变更才调用AI
CHANGES=$(git diff --name-only @{1day})

if [ $(echo "$CHANGES" | wc -l) -lt $MAX_LINES ]; then
    echo "小范围变更，使用本地规则处理"
    python3 scripts/version_tracker.py --minor
else
    echo "检测到重大变更，调用AI分析..."
    curl -X POST https://api.o3-mini.com/analyze -d "$CHANGES"
fi
