#!/bin/bash
# log-session-end.sh — SessionEnd hook
# 在会话结束时写一条摘要到 feedback-log.jsonl

LOGDIR="$(dirname "$0")/../autoloop"
LOGFILE="$LOGDIR/feedback-log.jsonl"

mkdir -p "$LOGDIR"

INPUT=$(cat)

/usr/bin/python3 -c "
import sys, json, datetime

input_data = json.loads('''$(echo "$INPUT" | sed "s/'/'\\\\''/g")''')
session_id = input_data.get('session_id', '')
reason = input_data.get('reason', 'unknown')

entry = {
    'ts': datetime.datetime.now().isoformat(),
    'session': session_id,
    'type': 'session_end',
    'reason': reason,
}

with open('$LOGFILE', 'a') as f:
    f.write(json.dumps(entry, ensure_ascii=False) + '\n')
" 2>/dev/null

exit 0
