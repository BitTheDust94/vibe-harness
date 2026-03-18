#!/bin/bash
# log-feedback.sh — PostToolUse hook
# 记录 Claude 每次工具调用的结果，用于后续分析
# 输入：stdin 接收 JSON（包含 tool_name, tool_input, tool_response）
# 输出：静默追加到 feedback-log.jsonl

LOGDIR="$(dirname "$0")/../autoloop"
LOGFILE="$LOGDIR/feedback-log.jsonl"

# 确保目录存在
mkdir -p "$LOGDIR"

# 读取 stdin
INPUT=$(cat)

# 提取关键字段，追加时间戳
TOOL_NAME=$(echo "$INPUT" | /usr/bin/python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_name',''))" 2>/dev/null)
TOOL_INPUT=$(echo "$INPUT" | /usr/bin/python3 -c "import sys,json; d=json.load(sys.stdin); print(json.dumps(d.get('tool_input',{})))" 2>/dev/null)
TOOL_RESPONSE=$(echo "$INPUT" | /usr/bin/python3 -c "import sys,json; d=json.load(sys.stdin); r=d.get('tool_response',{}); print(json.dumps(r) if isinstance(r,dict) else json.dumps({'raw':str(r)[:500]}))" 2>/dev/null)
SESSION_ID=$(echo "$INPUT" | /usr/bin/python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('session_id',''))" 2>/dev/null)

# 只记录有意义的工具调用（Edit, Write, Bash）
case "$TOOL_NAME" in
  Edit|Write|Bash)
    /usr/bin/python3 -c "
import json, datetime
entry = {
    'ts': datetime.datetime.now().isoformat(),
    'session': '$SESSION_ID',
    'tool': '$TOOL_NAME',
    'input': json.loads('$TOOL_INPUT' if '$TOOL_INPUT' else '{}'),
    'signal': 'completed'
}
# 截断大字段
if 'content' in entry['input']:
    entry['input']['content'] = entry['input']['content'][:200] + '...'
if 'command' in entry['input']:
    entry['input']['command'] = entry['input']['command'][:300]
print(json.dumps(entry, ensure_ascii=False))
" >> "$LOGFILE" 2>/dev/null
    ;;
esac

# 永远不要阻塞 Claude 的工作流
exit 0
