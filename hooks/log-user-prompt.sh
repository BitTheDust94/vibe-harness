#!/bin/bash
# log-user-prompt.sh — UserPromptSubmit hook
# 检测用户 prompt 中的反馈信号（接受/拒绝/修改）
# 信号词汇表基于中英文混合使用场景

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOGFILE="$SCRIPT_DIR/../autoloop/feedback-log.jsonl"

mkdir -p "$(dirname "$LOGFILE")"

/usr/bin/python3 -c "
import sys, json, datetime, re, os

input_data = json.load(sys.stdin)
prompt = input_data.get('prompt', '')
session_id = input_data.get('session_id', '')

reject_patterns = [
    r'(?i)\b(no|nope|wrong)\b',
    r'(?i)(不对|不行|不要|不是这个|重新|重来|撤回|回退)',
    r'(?i)(undo|revert|rollback)',
    r'(?i)(别这样|这不对|不是这个意思|搞错了|错了)',
    r'(?i)(不好|太差|不满意|有问题)',
]

accept_patterns = [
    r'(?i)\b(ok|good|great|nice|perfect|lgtm)\b',
    r'(?i)(可以|没问题|正确|就这样|继续|不错|很好|满意)',
    r'(?i)^(y|yes|好|好的|嗯|对的|是的|行|对)$',
]

modify_patterns = [
    r'(?i)(改一下|调整|换成|改成|instead|change.*to|modify|tweak)',
    r'(?i)(但是.*应该|不过.*要|however|but.*should|其实应该|我想要的是)',
    r'(?i)(稍微|微调|小改|略|slightly|a bit)',
]

signal = 'neutral'
confidence = 0.0

for p in reject_patterns:
    if re.search(p, prompt):
        signal = 'reject'
        confidence = 0.8
        break

if signal == 'neutral':
    for p in accept_patterns:
        if re.search(p, prompt):
            signal = 'accept'
            confidence = 0.7
            break

if signal == 'neutral':
    for p in modify_patterns:
        if re.search(p, prompt):
            signal = 'modify'
            confidence = 0.6
            break

if signal != 'neutral':
    entry = {
        'ts': datetime.datetime.now().isoformat(),
        'session': session_id,
        'type': 'user_feedback',
        'signal': signal,
        'confidence': confidence,
        'prompt_preview': prompt[:200],
    }
    logfile = os.environ.get('AUTOLOOP_LOG', '$LOGFILE')
    with open(logfile, 'a') as f:
        f.write(json.dumps(entry, ensure_ascii=False) + '\n')
" 2>/dev/null

exit 0
