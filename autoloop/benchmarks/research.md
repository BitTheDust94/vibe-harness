# Research Benchmarks

Validates research synthesis quality.

## BENCH-R01: Literature Synthesis

**Task**: Synthesize 10+ documents into a structured research overview with dimension-based organization.

**Pass criteria**:
- [ ] 4-6 coherent dimensions (not 10+ fragmented ones)
- [ ] Dimension names are generic (no subject-specific prefixes)
- [ ] Each document classified into exactly one dimension
- [ ] Contradictions between sources explicitly noted
- [ ] Knowledge gaps identified

## BENCH-R02: Assumption Detection

**Task**: Given a set of research documents, identify implicit assumptions — claims treated as facts without sufficient evidence.

**Pass criteria**:
- [ ] At least 2 implicit assumptions identified
- [ ] Each assumption linked to specific document references
- [ ] Distinction between "frequently cited but unverified" and "stated once as fact"

## BENCH-R03: Research Gap Analysis

**Task**: Given a research overview, identify what's missing compared to typical coverage for this research type.

**Pass criteria**:
- [ ] Gaps tied to expected dimensions (not invented ones)
- [ ] Severity of each gap assessed (critical / nice-to-have)
- [ ] Actionable suggestions for filling gaps
