# Coding Benchmarks

Validates coding rules in CLAUDE.md. Run after `/autoloop` applies rule changes.

## BENCH-C01: Create a New Module

**Task**: Create a new `qaXxx.ts` module in `src/` that performs basic keyword extraction.

**Pass criteria** (all must pass):
- [ ] File naming follows project convention
- [ ] Uses named exports (no default exports)
- [ ] Includes corresponding test file
- [ ] Code comments in English
- [ ] No modifications to unrelated config files
- [ ] No circular dependencies

## BENCH-C02: Fix a Type Error

**Task**: Fix a provided code snippet where `getEvidenceScore` returns a number but is assigned to a string variable.

**Pass criteria**:
- [ ] Type error corrected
- [ ] No `as any` or `@ts-ignore` workarounds
- [ ] Function semantics preserved

## BENCH-C03: Error Handling

**Task**: Add try-catch and graceful degradation to a search method.

**Pass criteria**:
- [ ] Errors captured and logged (using project logger, not console)
- [ ] Empty results returned instead of crashes
- [ ] Errors not silently suppressed
- [ ] Type safety maintained
