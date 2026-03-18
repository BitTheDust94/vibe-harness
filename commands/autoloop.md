---
description: 分析反馈信号并优化 harness
---

读取以下文件并执行优化分析：

1. 先读取 `.claude/autoloop/program.md` 了解完整流程
2. 读取 `.claude/autoloop/feedback-log.jsonl` 获取反馈信号
3. 读取 `CLAUDE.md` 了解当前 harness 配置
4. 读取 `.claude/autoloop/experiments.tsv` 了解历史实验

按照 program.md 中定义的流程执行：信号聚合 → 假设生成 → 评估 → 应用改进。

输出完整的 AutoLoop Report。
