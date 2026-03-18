# Finance Benchmarks

Validates financial analysis quality. Run after `/autoloop` applies rule changes.

## BENCH-F01: Quarterly Report Extraction

**Task**: Extract key metrics (revenue, operating income, net income, FCF) from a quarterly earnings report. Identify discrepancies between reported figures and management commentary.

**Pass criteria**:
- [ ] All key metrics extracted with correct units
- [ ] At least one discrepancy identified between numbers and narrative
- [ ] Sources cited for each metric
- [ ] No hallucinated figures

## BENCH-F02: Investment Memo Synthesis

**Task**: Synthesize 5+ research documents into a cohesive investment memo with bull/bear cases, valuation framework, and risk assessment.

**Pass criteria**:
- [ ] Both bull and bear cases presented with evidence
- [ ] Valuation framework uses appropriate methodology
- [ ] Key risks identified with materiality assessment
- [ ] Cross-document contradictions flagged
- [ ] No unsupported claims

## BENCH-F03: Comparable Analysis

**Task**: Build a comp table contextualizing a target company against 5-8 peers.

**Pass criteria**:
- [ ] Peer selection justified
- [ ] Metrics consistent across companies
- [ ] Outliers identified and explained
- [ ] Time periods aligned
