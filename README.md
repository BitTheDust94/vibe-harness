# vibe-harness v2: Self-Improving AI Harness

A self-improving system for Claude Code that learns from your professional judgment. Accept, reject, or modify AI output during normal work — the system captures these signals and iteratively refines the rules governing AI behavior.

## What's New in v2

- **PROGRESS.md** — Human-readable mistake/learning log alongside machine-readable JSONL
- **Severity + repeat tracking** — Distinguish critical errors from minor issues, flag repeated mistakes
- **Rule reference tracking** — Link signals to the specific rules they triggered (or should have)
- **Positive reinforcement** — Track what works well, not just what fails
- **Experiment lifecycle** — `pending → effective → internalized` with outcome validation
- **Two-command system** — `/progress` (scan + record) + `/autoloop` (analyze + optimize)
- **Upgraded hooks** — Better signal capture with structured metadata

## How It Works

```
You work normally with Claude Code
         ↓
Hooks silently capture signals (accept/reject/modify + tool usage)
         ↓
/progress scans the conversation, records mistakes + learnings
         ↓
Signals accumulate in feedback-log.jsonl
         ↓
/autoloop analyzes patterns → proposes rule changes → applies improvements
         ↓
Next conversation reads improved rules → fewer mistakes
         ↓
/autoloop validates: did the rule work? keep / upgrade / discard
```

## Quick Start

### 1. Copy files into your project

```bash
# From your project root:
mkdir -p .claude/autoloop .claude/hooks

# Copy autoloop system
cp vibe-harness/autoloop/program.md .claude/autoloop/
cp vibe-harness/autoloop/experiments.tsv .claude/autoloop/
touch .claude/autoloop/feedback-log.jsonl

# Copy hooks
cp vibe-harness/hooks/*.sh .claude/hooks/
chmod +x .claude/hooks/*.sh

# Copy commands
cp vibe-harness/commands/*.md ~/.claude/commands/

# Copy PROGRESS.md template
cp vibe-harness/PROGRESS.md ./PROGRESS.md
```

### 2. Register hooks

Merge into your `.claude/settings.json` (create if it doesn't exist):

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write|Bash",
        "hooks": [{
          "type": "command",
          "command": "bash \"$CLAUDE_PROJECT_DIR/.claude/hooks/log-feedback.sh\"",
          "timeout": 5
        }]
      }
    ],
    "UserPromptSubmit": [
      {
        "hooks": [{
          "type": "command",
          "command": "bash \"$CLAUDE_PROJECT_DIR/.claude/hooks/log-user-prompt.sh\"",
          "timeout": 5
        }]
      }
    ],
    "SessionEnd": [
      {
        "hooks": [{
          "type": "command",
          "command": "bash \"$CLAUDE_PROJECT_DIR/.claude/hooks/log-session-end.sh\"",
          "timeout": 5
        }]
      }
    ]
  }
}
```

### 3. Add to CLAUDE.md

Add this line to your project's `CLAUDE.md`:

```markdown
| `PROGRESS.md` | **Must read** — mistakes and lessons learned, do not repeat |
```

### 4. Use it

```bash
# After a work session, review what happened:
/progress

# After 5+ signals accumulate, optimize rules:
/autoloop
```

## File Structure

```
your-project/
├── CLAUDE.md                          ← Your project rules (auto-improved by /autoloop)
├── PROGRESS.md                        ← Human-readable mistake/learning log
└── .claude/
    ├── settings.json                  ← Hook registration
    ├── autoloop/
    │   ├── program.md                 ← AutoLoop engine logic
    │   ├── feedback-log.jsonl         ← Raw signals (auto-populated by hooks)
    │   ├── experiments.tsv            ← Rule experiment tracking
    │   └── benchmarks/                ← Domain-specific test suites
    │       ├── coding.md
    │       ├── finance.md
    │       └── ...
    ├── hooks/
    │   ├── log-feedback.sh            ← PostToolUse: log Edit/Write/Bash calls
    │   ├── log-user-prompt.sh         ← UserPromptSubmit: detect accept/reject/modify
    │   └── log-session-end.sh         ← SessionEnd: session summary
    └── commands/
        ├── progress.md                ← /progress command definition
        └── autoloop.md                ← /autoloop command definition
```

## Signal Types

### Automatic (via hooks)

| Hook | Trigger | Signal |
|------|---------|--------|
| `log-feedback.sh` | After Edit/Write/Bash | Tool usage with file path + content preview |
| `log-user-prompt.sh` | User sends message | Accept/reject/modify detection (EN + CN) |
| `log-session-end.sh` | Session ends | Session boundary marker |

### Manual (via /progress)

| Category | What it catches |
|----------|----------------|
| `code_error` | Bugs introduced, type errors, wrong API usage |
| `shortcut` | Cutting corners, sampling instead of full coverage |
| `arch_mistake` | Wrong approach, over-engineering, missed constraints |
| `rule_violation` | Broke existing CLAUDE.md/AGENTS.md rules |
| `comms` | Misunderstood user intent, did unrequested work |
| `repeat` | Same mistake already in PROGRESS.md |

## Experiment Lifecycle

```
Hypothesis created → pending
  ↓
3+ sessions with zero repeat → effective
  ↓
10+ sessions with zero repeat → internalized (rule is now habit)

OR

Same mistake repeats → ineffective → upgrade rule (more specific/strict)
```

## Supported Domains

Pre-built benchmarks in `autoloop/benchmarks/`:

| Domain | File | Tasks |
|--------|------|-------|
| Software Development | `coding.md` | Module creation, type fixes, error handling |
| Finance | `finance.md` | Metric extraction, investment memo, comp analysis |
| Research | `research.md` | Literature review, methodology, synthesis |
| Pharma | `pharma.md` | Safety data, regulatory, trial analysis |
| Legal | `legal.md` | Contract review, risk assessment, compliance |
| Product | `product.md` | PRD review, user flow, metrics |
| UI Design | `ui.md` | Component design, accessibility, responsiveness |

Create custom benchmarks by adding new `.md` files to the benchmarks directory.

## Design Principles

1. **Silent capture** — Hooks run in background, never interrupt workflow
2. **Human-readable + machine-readable** — PROGRESS.md for humans, JSONL for automation
3. **Specific rules over vague guidelines** — "Check chunk is delta vs full before SSE integration" beats "be careful with streaming"
4. **3 precise rules > 10 fuzzy rules** — Every rule has cognitive cost
5. **Reversible** — Every change can be rolled back by the next iteration
6. **CLAUDE.md stays lean** — If adding a rule, consider removing a low-value one

## License

MIT
