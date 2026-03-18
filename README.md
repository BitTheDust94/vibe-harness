# vibe-harness

**Your vibe coding gets better while you sleep.**

A self-improving harness system for AI-assisted development. Inspired by [Karpathy's autoresearch](https://github.com/karpathy/autoresearch) — but instead of optimizing model weights, it optimizes *how you work with AI*.

Every time you accept, reject, or modify AI output during your daily coding, the system silently logs preference signals. Overnight, an optimization loop analyzes patterns and tunes your harness — CLAUDE.md rules, hooks, prompt templates, design guidelines — so tomorrow's AI output is closer to what you want.

```
You vibe code → signals accumulate → overnight loop analyzes →
harness improves → next day's output is better → repeat
```

## The Problem

Vibe coding output quality is inconsistent. Sometimes AI nails it, sometimes it's way off. You correct the same mistakes repeatedly. Your taste and standards exist in your head but not in your tooling.

**AI-generated code has 2.74x more security vulnerabilities and 8x more duplication than human-written code.** (Source: [AlterSquare, 2026](https://altersquare.io/rescued-15-plus-codebases-ai-tools-pattern/))

## The Solution: A Harness That Learns From You

Karpathy showed that a single metric + a modification loop + overnight experiments = autonomous improvement. We apply the same pattern to the *harness* itself:

| Karpathy's autoresearch | vibe-harness |
|---|---|
| `train.py` (agent modifies) | `CLAUDE.md` + hooks config (agent modifies) |
| `prepare.py` (fixed evaluation) | `benchmarks/*.md` (fixed evaluation tasks) |
| `program.md` (human instructions) | `program.md` (human instructions) |
| `results.tsv` (experiment log) | `experiments.tsv` (experiment log) |
| `val_bpb` (single metric) | benchmark pass rate (multi-dimensional) |
| GPU training loop | harness optimization loop |
| Modify code to lower loss | Modify rules to improve AI output quality |

## How It Works

### 1. Silent Signal Capture (automatic, zero effort)

Three hooks run in the background during your normal work:

- **PostToolUse** → logs every Edit/Write/Bash call with file path and timestamp
- **UserPromptSubmit** → detects feedback keywords in both English and Chinese:
  - Reject: "wrong / not right / undo / revert / 不对 / 重新 / 太丑了 / 离谱"
  - Accept: "good / perfect / love it / lgtm / 好 / 完美 / 好看 / 就是这个"
  - Modify: "instead / a bit / adjust / 改一下 / 稍微 / 有点像 / 太大了"
- **SessionEnd** → records session summary

All signals accumulate in `feedback-log.jsonl`:

```jsonl
{"ts":"2026-03-18T14:32:01","signal":"reject","confidence":0.8,"prompt_preview":"不对，Supabase RLS policy should use auth.uid()"}
{"ts":"2026-03-18T14:33:15","signal":"accept","confidence":0.7,"prompt_preview":"good, ship it"}
{"ts":"2026-03-18T14:35:00","signal":"modify","confidence":0.6,"prompt_preview":"有点像女性胸部，改成纯光线发散"}
{"ts":"2026-03-18T15:01:42","signal":"accept","confidence":0.7,"prompt_preview":"好看，就是这个"}
```

### 2. Overnight Optimization Loop (runs while you sleep)

A scheduled job analyzes accumulated feedback and runs experiments:

```bash
# Add to crontab: every night at 2am
0 2 * * * /path/to/your/project/.claude/autoloop/run-loop.sh
```

The loop:
1. Reads `program.md` for optimization guidelines
2. Analyzes `feedback-log.jsonl` for rejection patterns
3. Proposes harness improvements (new CLAUDE.md rules, new hooks, adjusted templates)
4. Runs benchmarks against test tasks
5. Keeps improvements that pass, discards those that don't
6. Logs results to `experiments.tsv`

### 3. Morning Review (30 seconds)

```bash
cat .claude/autoloop/experiments.tsv
```

> "Last night: 12 experiments. Retrieval prompt v3 improved benchmark score from 72% to 81%. New CLAUDE.md rule added: 'Always use auth.uid() in Supabase RLS policies'. Proposed hook: auto-check component file size after Edit."

You decide what to keep. One command to apply.

## Installation

### For Claude Code

```bash
# Clone
git clone https://github.com/BitTheDust94/vibe-harness.git

# Copy into your project's .claude/ directory
cp -r vibe-harness/autoloop your-project/.claude/
cp -r vibe-harness/hooks your-project/.claude/
cp vibe-harness/commands/autoloop.md your-project/.claude/commands/

# Merge hook config into your .claude/settings.json (see settings-example.json)
```

### Set up nightly loop

```bash
chmod +x your-project/.claude/autoloop/run-loop.sh
crontab -e
# Add:
0 2 * * * /absolute/path/to/your/project/.claude/autoloop/run-loop.sh >> /absolute/path/to/your/project/.claude/autoloop/cron.log 2>&1
```

### Manual trigger

In Claude Code, type: `/autoloop`

## File Structure

```
.claude/
├── hooks/
│   ├── log-feedback.sh          # PostToolUse: records tool calls
│   ├── log-user-prompt.sh       # UserPromptSubmit: detects accept/reject/modify
│   └── log-session-end.sh       # SessionEnd: session summary
├── commands/
│   └── autoloop.md              # /autoloop slash command
└── autoloop/
    ├── program.md               # Optimization agent instructions (you edit this)
    ├── feedback-log.jsonl       # Accumulated signals (auto-generated)
    ├── experiments.tsv          # Experiment history (auto-generated)
    ├── run-loop.sh              # Nightly execution script
    └── benchmarks/
        ├── coding.md            # Code quality test tasks
        ├── product.md           # Product design test tasks
        └── ui.md                # UI design test tasks
```

## Three Types of Work, One Loop

vibe-harness captures signals across all types of AI-assisted work:

| Work Type | Accept Signal | Reject Signal | What Gets Optimized |
|---|---|---|---|
| **Coding** | Merge, ship, "好" | "不对", revert, manual rewrite | CLAUDE.md rules, code templates, hooks |
| **Product Design** | Adopt proposal, "这个方向对" | "都不够好", ask to rethink | Product discussion prompts, decision frameworks |
| **UI Design** | "好看", use as-is | "不够优雅", "没有那个感觉" | Design system rules, component templates, style params |

## The Karpathy Loop, Applied to Taste

> "Any efficiently evaluatable metric can benefit from agent-driven optimization." — Andrej Karpathy

Your taste is a metric. Every accept/reject is a data point. Given enough data points, an AI agent can learn to approximate your standards — not by training a model, but by tuning the *rules and constraints* that guide it.

You're not training a local model. You're training a harness. The LLM stays the same. What changes is how you use it.

**The harness is the product. The model is commodity.**

## Requirements

- [Claude Code](https://claude.ai/code) CLI
- macOS or Linux (hooks are bash scripts)
- `claude -p` support (headless mode for overnight runs)

## Credits

- Pattern inspired by [autoresearch](https://github.com/karpathy/autoresearch) by Andrej Karpathy
- Harness engineering concepts from [OpenAI's Codex team](https://openai.com/index/harness-engineering/) and [Martin Fowler](https://martinfowler.com/articles/exploring-gen-ai/harness-engineering.html)
- Built for the [Penso](https://penso.so) development workflow

## License

MIT
