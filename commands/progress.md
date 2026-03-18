Review this conversation and execute the following steps:

## 1. Scan for mistakes and lessons

Check each category for issues that occurred in this conversation:

| Category | Check |
|----------|-------|
| **Code errors** (code_error) | Introduced bugs? Type errors? Logic errors? Wrong API? |
| **Shortcuts** (shortcut) | Asked to do N but only sampled? Used DB query instead of UI verification? |
| **Architecture mistakes** (arch_mistake) | Wrong approach? Over-engineered? Missed constraints? |
| **Rule violations** (rule_violation) | Broke CLAUDE.md / AGENTS.md rules? Touched protected files? Used Write on existing files? |
| **Communication** (comms) | Misunderstood user intent? Did unrequested work? |
| **Repeated mistakes** (repeat) | Is this already in PROGRESS.md? |

Also scan for user corrections ("don't...", "not that...", "wrong...", rejected tool calls).

## 2. Read existing records

Read `PROGRESS.md` (project root) and `.claude/autoloop/feedback-log.jsonl`.

## 3. Write to PROGRESS.md

For each issue found, append to the `## Lessons` table:
```
| # | Date | Category | What went wrong | Why | What to do instead |
```

For things done well, append to the `## Things done well` table.

**Rules:**
- No duplicates (check existing entries first)
- Only write reusable lessons, not one-off issues
- "What to do instead" must be specific and actionable, not "be more careful"
- If no mistakes were made, say "No new lessons" and list what was done well

## 4. Write to feedback-log.jsonl (AutoLoop signal source)

For each issue AND user correction, append one JSONL line to `.claude/autoloop/feedback-log.jsonl`:

```json
{"ts":"YYYY-MM-DD","type":"mistake|user_correction|session_clean","category":"code_error|shortcut|arch_mistake|rule_violation|comms|process","signal":"one-line description","severity":"high|medium|low","repeat":true/false,"rule_ref":"existing rule reference if any","progress_ref":"#N if any"}
```

If zero mistakes:
```json
{"ts":"YYYY-MM-DD","type":"session_clean","category":"all","signal":"Zero mistakes this session","severity":"none","repeat":false}
```

## 5. Check if /autoloop should run

Count new signals since last `/autoloop`. If >= 5, suggest running `/autoloop`.

## 6. Output summary

Report to user:
- How many mistakes this session
- How many new lessons added
- How many new feedback signals
- Flag any repeated mistakes
- Whether to run `/autoloop`

$ARGUMENTS
