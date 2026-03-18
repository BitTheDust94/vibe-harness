# AutoLoop — Harness 自我优化系统

> 借鉴 Karpathy autoresearch 模式：白天积累信号，夜间跑优化循环。

## 核心概念

```
白天 vibe coding
    ↓  hooks 自动记录每次交互的反馈信号
    ↓  信号写入 feedback-log.jsonl
夜间 cron 启动
    ↓  claude -p 分析 feedback-log → 发现模式
    ↓  生成实验假设 → 用 benchmark 验证
    ↓  结果好 → 更新 CLAUDE.md / hooks / templates
    ↓  结果差 → 丢弃，记录到 experiments.tsv
第二天早上
    ↓  查看 experiments.tsv，了解发生了什么
    ↓  继续 vibe coding，新一轮信号积累
```

## 文件结构

```
.claude/
├── settings.json           ← hooks 配置
├── hooks/
│   ├── log-feedback.sh     ← 每次交互后记录信号
│   └── log-session-end.sh  ← 会话结束时写摘要
├── autoloop/
│   ├── README-AUTOLOOP.md  ← 你正在读的这个文件
│   ├── feedback-log.jsonl  ← 累积的反馈信号（自动生成）
│   ├── experiments.tsv     ← 实验记录（类似 autoresearch）
│   ├── program.md          ← 优化 agent 的指令（对标 Karpathy 的 program.md）
│   ├── run-loop.sh         ← 夜间执行脚本
│   └── benchmarks/
│       ├── coding.md       ← 编码类 benchmark 任务
│       ├── product.md      ← 产品设计类 benchmark
│       └── ui.md           ← UI 设计类 benchmark
```

## 使用方法

### 1. 白天：正常 vibe coding，hooks 自动工作
无需做任何事。hooks 在后台静默记录。

### 2. 手动触发分析（随时可用）
```bash
cd /Users/chen/Flow插件/flow-2.0
claude -p "$(cat .claude/autoloop/program.md)"
```

### 3. 设置 cron 自动夜间运行
```bash
# 编辑 crontab
crontab -e

# 添加这行（每天凌晨 2 点运行）
0 2 * * * /Users/chen/Flow插件/flow-2.0/.claude/autoloop/run-loop.sh >> /Users/chen/Flow插件/flow-2.0/.claude/autoloop/cron.log 2>&1
```

### 4. 早上查看结果
```bash
cat .claude/autoloop/experiments.tsv
tail -50 .claude/autoloop/cron.log
```
