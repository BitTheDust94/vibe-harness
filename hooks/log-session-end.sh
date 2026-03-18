#!/bin/bash
# SessionEnd hook — log session termination for signal counting

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

session = data.get('session_id', 'unknown')
reason = data.get('reason', 'unknown')

entry = {
    'ts': datetime.datetime.now().isoformat(),
    'session': session,
    'type': 'session_end',
    'reason': reason,
}

with open('$LOG', 'a') as f:
    f.write(json.dumps(entry, ensure_ascii=False) + '\n')
" 2>/dev/null

exit 0
