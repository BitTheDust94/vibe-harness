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
    # English
    r'(?i)\b(no|nope|wrong|bad|terrible|awful|ugly|hate it|not right|not what i want)\b',
    r'(?i)\b(undo|revert|rollback|go back|start over|try again|redo)\b',
    r'(?i)(this is wrong|that.s wrong|completely wrong|not even close|way off)',
    r'(?i)(don.t like|doesn.t work|won.t work|broken|useless|horrible)',
    r'(?i)(scratch that|never mind|forget it|stop|cancel)',
    # Chinese
    r'(不对|不行|不要|不是这个|重新|重来|撤回|回退|取消)',
    r'(别这样|这不对|不是这个意思|搞错了|错了|完全不对)',
    r'(不好|太差|不满意|有问题|太丑了|难看|不好看)',
    r'(重新来|再来一次|推翻|废弃|删掉|不能用|没法用)',
    r'(离谱|扯淡|乱搞|瞎搞|什么鬼|不像话)',
]

accept_patterns = [
    # English
    r'(?i)\b(ok|good|great|nice|perfect|lgtm|love it|awesome|excellent|beautiful)\b',
    r'(?i)\b(yes|yep|yeah|yup|sure|exactly|correct|right|agreed|fine)\b',
    r'(?i)(looks good|well done|that.s it|nailed it|ship it|this works|keep it)',
    r'(?i)(i like|much better|way better|this is what i want)',
    # Chinese
    r'(可以|没问题|正确|就这样|继续|不错|很好|满意|完美)',
    r'^(好|好的|嗯|对的|是的|行|对|OK|ok|可)$',
    r'(好看|漂亮|舒服|优雅|到位|精准|牛|厉害|赞)',
    r'(就是这个|对了|没错|这就对了|有感觉|有那味了)',
    r'(上线吧|发布|提交|合并|就这样吧|定了)',
]

modify_patterns = [
    # English
    r'(?i)(instead|change.*to|modify|tweak|adjust|update|replace|swap)',
    r'(?i)(but.*should|however|although.*could|what if|how about)',
    r'(?i)(slightly|a bit|a little|too much|too little|more|less)',
    r'(?i)(almost|close but|nearly|not quite|90% there|one more thing)',
    r'(?i)(can you make|could you|try making|what about making)',
    # Chinese
    r'(改一下|调整|换成|改成|修改|替换|调一下)',
    r'(但是.*应该|不过.*要|其实应该|我想要的是|我觉得应该)',
    r'(稍微|微调|小改|略|差一点|接近了|快了)',
    r'(太大|太小|太多|太少|太亮|太暗|太粗|太细|太宽|太窄)',
    r'(有点像|感觉像|看起来像|不够.*感觉|没有.*感觉)',
    r'(能不能|可不可以|要不要|试试|换个)',
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
