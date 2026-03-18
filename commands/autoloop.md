---
description: Analyze feedback signals and optimize harness rules
---

Execute the harness self-optimization loop:

## Step 1: Load data

Read these files:
1. `.claude/autoloop/program.md` — Full process definition
2. `.claude/autoloop/feedback-log.jsonl` — Feedback signals
3. `.claude/autoloop/experiments.tsv` — Experiment history
4. `CLAUDE.md` — Current harness configuration
5. `PROGRESS.md` — Lesson log

## Step 2: Signal aggregation

Per program.md:
- Count signals by category
- Identify high-frequency categories (>= 3 occurrences)
- Identify repeated mistakes (repeat: true)
- Check experiment outcomes (did the rule prevent the mistake?)

## Step 3: Hypothesis generation + evaluation

- Generate improvement hypotheses for high-frequency/repeated categories
- Check experiments.tsv to avoid duplicate attempts
- Evaluate ROI (frequency x severity / rule complexity)

## Step 4: Apply improvements

- Write passing hypotheses to CLAUDE.md or AGENTS.md
- Record in experiments.tsv (outcome = pending)
- Update existing experiment outcomes (effective/ineffective)

## Step 5: Cleanup

- Experiments effective for 10+ sessions → mark "internalized"
- Archive feedback-log entries older than 30 days

## Step 6: Output AutoLoop Report

```
=== AutoLoop Report ===

Signal stats:
  Total signals: N
  High-frequency: [...]
  Repeated mistakes: [...]

New hypotheses:
  1. [description] → suggest writing to [file:location]
  2. ...

Rule effectiveness:
  Effective (keep): N
  Pending: N
  Ineffective (upgrade): N

Changes made:
  - [what changed, where]

========================
```

$ARGUMENTS
