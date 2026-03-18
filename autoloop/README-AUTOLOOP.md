# AutoLoop — Harness Self-Iteration System

> Inspired by Karpathy's autoresearch: your feedback signals become the training data for your harness.

## Core Concept

```
You work with Claude Code as usual
    ↓  hooks silently capture every accept / reject / modify signal
    ↓  signals accumulate in feedback-log.jsonl
You trigger /autoloop (when you have 20+ signals)
    ↓  agent analyzes feedback → finds patterns
    ↓  proposes harness improvements → runs benchmarks to verify
    ↓  improvements that pass → applied to rules / hooks / templates
    ↓  improvements that fail → discarded, logged to experiments.tsv
Next session
    ↓  AI follows updated rules → fewer corrections needed
    ↓  new signals accumulate → cycle continues
```

## File Structure

```
autoloop/
├── README-AUTOLOOP.md  ← You're reading this
├── feedback-log.jsonl  ← Accumulated signals (auto-generated)
├── experiments.tsv     ← Iteration history (auto-generated)
├── program.md          ← Self-iteration agent instructions
├── run-loop.sh         ← Batch execution script (optional cron)
└── benchmarks/
    ├── coding.md       # Software development
    ├── product.md      # Product design
    ├── ui.md           # UI/UX design
    ├── finance.md      # Finance & investment
    ├── research.md     # Scientific research
    ├── pharma.md       # Pharma & biotech
    └── legal.md        # Legal
```

## Usage

### 1. Daily work: just work as usual
Hooks run silently. No extra steps needed.

### 2. Trigger self-iteration
When you have enough signals (20+), type in Claude Code:
```
/autoloop
```

### 3. Review improvements
The agent will show you what patterns it found and what rules it proposes. You approve or reject.

### 4. Optional: batch mode via cron
If you prefer overnight runs:
```bash
crontab -e
# Add:
0 2 * * * /path/to/your/project/.claude/autoloop/run-loop.sh >> /path/to/cron.log 2>&1
```
