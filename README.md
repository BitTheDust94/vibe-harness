# vibe-harness

**Your AI output gets better while you sleep.**

A self-improving harness for anyone using AI agents in professional work — coding, finance, research, pharma, legal, design, and more. Inspired by [Karpathy's autoresearch](https://github.com/karpathy/autoresearch), but instead of optimizing model weights, it optimizes *how you work with AI*.

Every time you accept, reject, or modify AI output during your daily work, the system silently logs preference signals. Overnight, an optimization loop analyzes patterns and tunes your harness — rules, hooks, prompt templates, domain guidelines — so tomorrow's AI output is closer to what you actually want.

```
You work with AI → signals accumulate → overnight loop analyzes →
harness improves → next day's output is better → repeat
```

## The Problem

AI output quality is inconsistent — whether you're writing code, drafting investment memos, reviewing contracts, analyzing clinical trial data, or writing research papers.

You correct the same mistakes repeatedly. You know what "good" looks like in your domain, but that knowledge lives in your head, not in your tooling. Every new session starts from zero — AI doesn't remember that you rejected the same bad pattern yesterday.

**Without domain-calibrated constraints, AI outputs drift toward generic, mediocre results.** A financial model missing key risk factors. A legal review that overlooks non-standard clauses. A research paper with the wrong statistical test. Code with security vulnerabilities you've caught three times before.

## The Solution: A Harness That Learns From You

Karpathy showed that a single metric + a modification loop + overnight experiments = autonomous improvement. We apply the same pattern to the *harness* itself:

| Karpathy's autoresearch | vibe-harness |
|---|---|
| `train.py` (agent modifies) | Rules, hooks, templates (agent modifies) |
| `prepare.py` (fixed evaluation) | `benchmarks/*.md` (domain-specific evaluation tasks) |
| `program.md` (human instructions) | `program.md` (human instructions) |
| `results.tsv` (experiment log) | `experiments.tsv` (experiment log) |
| `val_bpb` (single metric) | Benchmark pass rate (multi-dimensional) |
| GPU training loop | Harness optimization loop |
| Modify code to lower loss | Modify rules to improve output quality |

**You're not training a model. You're training a harness.** The LLM stays the same. What changes is how you use it — the rules it follows, the constraints it respects, the domain standards it adheres to.

## How It Works

### 1. Silent Signal Capture (automatic, zero effort)

Three hooks run in the background during your normal work. You don't need to do anything different.

- **PostToolUse** → logs every AI action (file edits, commands) with timestamp
- **UserPromptSubmit** → detects feedback in your natural language (English and Chinese):
  - **Reject**: "wrong / not right / undo / 不对 / 重新 / 离谱 / 数字不对 / 逻辑不通"
  - **Accept**: "good / perfect / love it / 好 / 完美 / 就是这个 / 数据对了 / 分析到位"
  - **Modify**: "instead / adjust / a bit / 改一下 / 稍微 / 太大了 / 有点像 / 差一点"
- **SessionEnd** → records session summary

All signals accumulate in `feedback-log.jsonl`:

```jsonl
{"ts":"2026-03-18T14:30:01","signal":"reject","confidence":0.8,"prompt_preview":"数字不对，FCF calculation should exclude one-time items"}
{"ts":"2026-03-18T14:33:15","signal":"accept","confidence":0.7,"prompt_preview":"good, the comps table looks right now"}
{"ts":"2026-03-18T14:35:00","signal":"modify","confidence":0.6,"prompt_preview":"analysis is close but missing regulatory risk section"}
{"ts":"2026-03-18T15:01:42","signal":"accept","confidence":0.7,"prompt_preview":"完美，就是这个"}
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
3. Proposes harness improvements (new rules, new hooks, adjusted templates)
4. Runs domain benchmarks to verify improvements
5. Keeps changes that pass, discards those that don't
6. Logs results to `experiments.tsv`

### 3. Morning Review (30 seconds)

```bash
cat .claude/autoloop/experiments.tsv
```

> "Last night: 12 experiments. Financial modeling prompt v3 improved benchmark score from 72% to 81%. New rule added: 'Always exclude one-time items in FCF calculations'. New rule added: 'Include regulatory risk section in all pharma analysis'."

You decide what to keep. One command to apply.

## Works Across Every Domain

Anyone using AI for professional work generates accept/reject signals. vibe-harness turns those signals into a self-improving system.

| Domain | Example Work | What Gets Better Over Time |
|---|---|---|
| **Finance / Investment** | Financial models, investment memos, comps analysis, due diligence | Valuation methodology, risk factor coverage, data accuracy |
| **Scientific Research** | Literature reviews, experiment design, data analysis, paper drafting | Statistical method selection, citation accuracy, gap identification |
| **Pharma / Biotech** | Clinical trial analysis, pipeline valuation, regulatory filings | Endpoint interpretation, safety signal detection, precedent accuracy |
| **Legal** | Contract review, case research, due diligence, legal memos | Risk clause identification, precedent relevance, jurisdiction accuracy |
| **Software Development** | Feature implementation, bug fixes, refactoring, architecture | Code quality, security, framework patterns, test coverage |
| **Product & Design** | PRDs, UI components, design systems, user flows | Design consistency, interaction patterns, brand alignment |
| **Content & Marketing** | Copywriting, strategy docs, market analysis | Tone calibration, audience fit, brand voice consistency |

### Pre-built Domain Benchmarks

Each domain has a benchmark suite with 3 evaluation tasks. Pick the ones that match your work:

```
autoloop/benchmarks/
├── coding.md          # Software development
├── product.md         # Product design & strategy
├── ui.md              # UI/UX design
├── finance.md         # Financial analysis & modeling
├── research.md        # Scientific research
├── pharma.md          # Pharma & biotech
└── legal.md           # Legal review & due diligence
```

**Don't see your domain?** Create your own `benchmarks/your-domain.md` with 3 representative tasks. The system works with any domain where you can evaluate "good vs bad" output.

## Installation

### For Claude Code

```bash
# Clone
git clone https://github.com/BitTheDust94/vibe-harness.git

# Copy into your project's .claude/ directory
cp -r vibe-harness/autoloop your-project/.claude/
cp -r vibe-harness/hooks your-project/.claude/
cp -r vibe-harness/commands your-project/.claude/

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
│   ├── log-feedback.sh          # PostToolUse: records AI actions
│   ├── log-user-prompt.sh       # UserPromptSubmit: detects accept/reject/modify
│   └── log-session-end.sh       # SessionEnd: session summary
├── commands/
│   └── autoloop.md              # /autoloop slash command
└── autoloop/
    ├── program.md               # Optimization instructions (you edit this)
    ├── feedback-log.jsonl       # Accumulated signals (auto-generated)
    ├── experiments.tsv          # Experiment history (auto-generated)
    ├── run-loop.sh              # Nightly execution script
    └── benchmarks/
        ├── coding.md            # Software development
        ├── product.md           # Product design
        ├── ui.md                # UI/UX design
        ├── finance.md           # Finance & investment
        ├── research.md          # Scientific research
        ├── pharma.md            # Pharma & biotech
        └── legal.md             # Legal
```

## The Karpathy Loop, Applied to Professional Expertise

> "Any efficiently evaluatable metric can benefit from agent-driven optimization." — Andrej Karpathy

Your professional judgment is a metric. Every accept/reject is a data point. Given enough data points, an AI agent can learn to approximate your domain standards — not by training a model, but by tuning the *rules and constraints* that guide it.

A senior investment analyst knows that FCF calculations should exclude one-time items. A pharma researcher knows that Phase II endpoints need to be contextualized against competitor trials. A lawyer knows that indemnification clauses in SaaS agreements need mutual caps.

This knowledge usually stays in their heads. vibe-harness captures it through natural work signals and encodes it into machine-enforceable rules.

**The harness is the product. The model is commodity.**

## Requirements

- [Claude Code](https://claude.ai/code) CLI
- macOS or Linux (hooks are bash scripts)
- `claude -p` support (headless mode for overnight runs)

## Credits

- Pattern inspired by [autoresearch](https://github.com/karpathy/autoresearch) by Andrej Karpathy
- Harness engineering concepts from [OpenAI's Codex team](https://openai.com/index/harness-engineering/) and [Martin Fowler](https://martinfowler.com/articles/exploring-gen-ai/harness-engineering.html)
- Born from ZC, founder of [Penso](https://penso.so) and Serendipity Ventures

## License

MIT
