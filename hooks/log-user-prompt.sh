#!/bin/bash
# UserPromptSubmit hook — detect accept/reject/modify signals in user messages
# Bilingual pattern matching (English + Chinese)

set -e

DIR="$(cd "$(dirname "$0")/.." && pwd)/autoloop"
mkdir -p "$DIR"
LOG="$DIR/feedback-log.jsonl"

INPUT=$(cat)

python3 -c "
import json, sys, datetime, re

try:
    data = json.loads(sys.stdin.read()) if not '''$INPUT'''.strip() else json.loads('''$INPUT''')
except:
    sys.exit(0)

prompt = data.get('prompt', data.get('message', ''))
if not prompt or len(prompt) < 2:
    sys.exit(0)

session = data.get('session_id', 'unknown')
text = prompt.lower()

# Reject signals
reject_patterns = [
    r'\b(wrong|undo|revert|rollback|no[, ]not|shouldn.t have|take it back)\b',
    r'(不对|错了|撤回|回滚|不要这样|别这样|搞错了|改回来|不是这样)',
]

# Accept signals
accept_patterns = [
    r'\b(perfect|great|good|looks good|lgtm|ship it|nice|exactly)\b',
    r'(好的?|可以|没问题|就这样|对的|正确|不错|完美)',
]

# Modify signals
modify_patterns = [
    r'\b(change|adjust|modify|tweak|almost|close but|instead|rather)\b',
    r'(改一下|调整|修改|差一点|换成|改成|不过要|但是要)',
]

signal = None
confidence = 0

for p in reject_patterns:
    if re.search(p, text):
        signal = 'reject'
        confidence = 0.7
        break

if not signal:
    for p in modify_patterns:
        if re.search(p, text):
            signal = 'modify'
            confidence = 0.6
            break

if not signal:
    for p in accept_patterns:
        if re.search(p, text):
            signal = 'accept'
            confidence = 0.6
            break

if signal and confidence >= 0.6:
    entry = {
        'ts': datetime.datetime.now().isoformat(),
        'session': session,
        'type': 'user_signal',
        'signal': signal,
        'confidence': confidence,
        'prompt_preview': prompt[:200],
    }
    with open('$LOG', 'a') as f:
        f.write(json.dumps(entry, ensure_ascii=False) + '\n')
" 2>/dev/null

exit 0
