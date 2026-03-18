#!/bin/bash
# run-loop.sh — 夜间自动优化循环
# 用法：直接运行，或通过 cron 调用
# crontab: 0 2 * * * /Users/chen/Flow插件/flow-2.0/.claude/autoloop/run-loop.sh

set -euo pipefail

PROJECT_DIR="/Users/chen/Flow插件/flow-2.0"
AUTOLOOP_DIR="$PROJECT_DIR/.claude/autoloop"
LOGFILE="$AUTOLOOP_DIR/feedback-log.jsonl"
PROGRAM="$AUTOLOOP_DIR/program.md"
TIMESTAMP=$(date +"%Y-%m-%d_%H%M")

echo "=== AutoLoop Run: $TIMESTAMP ==="

# 1. 检查信号量是否足够
if [ ! -f "$LOGFILE" ]; then
    echo "No feedback log found. Nothing to analyze."
    exit 0
fi

SIGNAL_COUNT=$(wc -l < "$LOGFILE" | tr -d ' ')
echo "Signal count: $SIGNAL_COUNT"

if [ "$SIGNAL_COUNT" -lt 10 ]; then
    echo "Not enough signals ($SIGNAL_COUNT < 10). Skipping."
    exit 0
fi

# 2. 备份当前 harness 文件（可回退）
BACKUP_DIR="$AUTOLOOP_DIR/backups/$TIMESTAMP"
mkdir -p "$BACKUP_DIR"
cp "$PROJECT_DIR/CLAUDE.md" "$BACKUP_DIR/CLAUDE.md.bak"
cp "$PROJECT_DIR/.claude/settings.json" "$BACKUP_DIR/settings.json.bak" 2>/dev/null || true

echo "Backed up current harness to $BACKUP_DIR"

# 3. 运行优化 agent
echo "Starting optimization agent..."

cd "$PROJECT_DIR"

claude -p "$(cat "$PROGRAM")

---

以下是当前的反馈信号日志（最近 200 条）：

$(tail -200 "$LOGFILE")

---

以下是当前的 CLAUDE.md：

$(cat "$PROJECT_DIR/CLAUDE.md")

---

以下是当前的实验记录：

$(cat "$AUTOLOOP_DIR/experiments.tsv")

---

请分析信号，生成假设，并应用改进。遵循 program.md 中的流程。
将实验结果追加到 .claude/autoloop/experiments.tsv。
将改进应用到 CLAUDE.md（如果有的话）。
输出完整的 AutoLoop Report。" \
    --allowedTools "Read,Edit,Write,Grep,Glob" \
    --max-turns 30 \
    2>&1

echo "=== AutoLoop Complete: $(date) ==="

# 4. 归档已处理的信号（保留原文件，加后缀标记）
mv "$LOGFILE" "$AUTOLOOP_DIR/feedback-log.processed.$TIMESTAMP.jsonl"
touch "$LOGFILE"
echo "Archived processed signals."
