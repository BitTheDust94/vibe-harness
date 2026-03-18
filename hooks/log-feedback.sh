#!/bin/bash
# PostToolUse hook — silently log Edit/Write/Bash tool calls
# Captures what the AI does so /autoloop can analyze patterns

set -e

DIR="$(cd "$(dirname "$0")/.." && pwd)/autoloop"
mkdir -p "$DIR"
LOG="$DIR/feedback-log.jsonl"

INPUT=$(cat)

python3 -c "
import json, sys, datetime

try:
    data = json.loads(sys.stdin.read()) if not '''$INPUT'''.strip() else json.loads('''$INPUT''')
except:
    sys.exit(0)

tool = data.get('tool_name', '')
if tool not in ('Edit', 'Write', 'Bash'):
    sys.exit(0)

inp = data.get('tool_input', {})
resp = str(data.get('tool_response', ''))[:200]
session = data.get('session_id', 'unknown')

content = str(inp.get('content', inp.get('command', '')))[:300]
file_path = inp.get('file_path', inp.get('path', ''))

entry = {
    'ts': datetime.datetime.now().isoformat(),
    'session': session,
    'type': 'tool_use',
    'tool': tool,
    'file': file_path,
    'content_preview': content[:200],
    'response_preview': resp,
}

with open('$LOG', 'a') as f:
    f.write(json.dumps(entry, ensure_ascii=False) + '\n')
" 2>/dev/null

exit 0
