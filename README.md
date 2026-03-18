# vibe-harness

**Your AI learns your standards as you work.**

A self-improving harness for Claude Code. Every time you accept, reject, or modify AI output, the system silently captures that signal and iterates — refining rules, constraints, and domain guidelines in real time, so AI output gets progressively closer to your professional standards.

Inspired by [Karpathy's autoresearch](https://github.com/karpathy/autoresearch) — but instead of running overnight experiments, vibe-harness learns continuously from your natural workflow. No extra steps. Just work as usual, and the harness evolves around you.

```
You work with AI → accept / reject / modify → signal captured →
harness self-iterates → next output is better → repeat
```

## The Problem

AI output quality is inconsistent — whether you're writing code, drafting investment memos, reviewing contracts, or analyzing clinical trial data.

You correct the same mistakes repeatedly. You know what "good" looks like in your domain, but that knowledge lives in your head, not in your tooling. Every new session starts from zero — AI doesn't remember that you rejected the same bad pattern yesterday.

**Without domain-calibrated constraints, AI outputs drift toward generic, mediocre results.** A financial model missing key risk factors. A legal review that overlooks non-standard clauses. A research paper with the wrong statistical test. Code with security vulnerabilities you've caught three times before.

## The Solution: A Harness That Learns From You

Your professional judgment is the training signal. Every "不对", every "perfect", every "改一下" is a data point. vibe-harness captures these signals in real time, identifies patterns, and updates the rules that guide AI — so the same mistake doesn't happen twice.

| What | How |
|---|---|
| You say "不对" or "wrong" | Logged as rejection signal → pattern analyzed → new rule added |
| You say "好" or "perfect" | Logged as acceptance signal → successful pattern reinforced |
| You say "改一下" or "adjust" | Logged as modification signal → constraint refined |
| Signals accumulate | `/autoloop` analyzes patterns → proposes harness improvements |
| Harness updates | Next AI output follows updated rules → fewer corrections needed |

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

### 2. Self-Iteration (when you're ready)

When enough signals have accumulated (typically 20+ feedback events), trigger analysis:

```
/autoloop
```

The agent:
1. Reads your accumulated feedback signals
2. Identifies rejection patterns ("60% of rejections are about missing risk factors")
3. Proposes specific harness improvements (new rules, adjusted constraints)
4. Runs domain benchmarks to verify improvements don't break other things
5. Shows you what changed and why

You review and approve. The harness is updated. Next time AI encounters the same situation, it gets it right.

### 3. Continuous Improvement

The cycle never stops. As you keep working, new signals accumulate, new patterns emerge, and the harness keeps evolving. After a few weeks, AI output matches your professional standards with minimal corrections.

```
Week 1:  You correct AI 10 times / day
Week 2:  Harness has 5 new rules from your feedback → corrections drop to 6 / day
Week 4:  15 rules accumulated → corrections drop to 3 / day
Week 8:  AI output consistently matches your standards
```

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

Each domain has a benchmark suite with evaluation tasks. Pick the ones that match your work:

```
autoloop/benchmarks/
├── coding.md          # Software development
├── product.md         # Product design & strategy
├── ui.md              # UI/UX design
├── finance.md         # Finance & investment
├── research.md        # Scientific research
├── pharma.md          # Pharma & biotech
└── legal.md           # Legal
```

**Don't see your domain?** Create your own `benchmarks/your-domain.md` with 3 representative tasks. The system works with any domain where you can evaluate "good vs bad" output.

## Installation

### For Claude Code

```bash
# Clone
git clone https://github.com/ericsonglab/vibe-harness.git

# Copy into your project's .claude/ directory
cp -r vibe-harness/autoloop your-project/.claude/
cp -r vibe-harness/hooks your-project/.claude/
cp -r vibe-harness/commands your-project/.claude/

# Merge hook config into your .claude/settings.json (see settings-example.json)
```

### Trigger self-iteration

In Claude Code, type `/autoloop` whenever you want the system to analyze accumulated feedback and propose improvements.

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
    ├── program.md               # Self-iteration instructions (you can edit this)
    ├── feedback-log.jsonl       # Accumulated signals (auto-generated)
    ├── experiments.tsv          # Iteration history (auto-generated)
    ├── run-loop.sh              # Batch execution script (optional cron)
    └── benchmarks/
        ├── coding.md            # Software development
        ├── product.md           # Product design
        ├── ui.md                # UI/UX design
        ├── finance.md           # Finance & investment
        ├── research.md          # Scientific research
        ├── pharma.md            # Pharma & biotech
        └── legal.md             # Legal
```

## The Core Idea

> "Any efficiently evaluatable metric can benefit from agent-driven optimization." — Andrej Karpathy

Your professional judgment is a metric. Every accept/reject is a data point.

A senior investment analyst knows that FCF calculations should exclude one-time items. A pharma researcher knows that Phase II endpoints need to be contextualized against competitor trials. A lawyer knows that indemnification clauses in SaaS agreements need mutual caps.

This knowledge usually stays in their heads. vibe-harness captures it through natural work signals and encodes it into machine-enforceable rules. No extra steps, no forms to fill, no feedback buttons to click. Just work as you normally do.

**The harness is the product. The model is commodity.**

## Requirements

- [Claude Code](https://claude.ai/code) CLI
- macOS or Linux (hooks are bash scripts)

## Credits

- Pattern inspired by [autoresearch](https://github.com/karpathy/autoresearch) by Andrej Karpathy
- Harness engineering concepts from [OpenAI's Codex team](https://openai.com/index/harness-engineering/) and [Martin Fowler](https://martinfowler.com/articles/exploring-gen-ai/harness-engineering.html)
- Born from ZC, founder of [Penso](https://penso.so) and Serendipity Ventures

## License

MIT
