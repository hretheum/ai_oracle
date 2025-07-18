# Early Signals Score Algorithm

## Overview
The Early Signals Score (0-100) predicts future paper impact based on indicators from the first 7 days after publication.

## Signal Weights
- **40%** - Author metrics (h-index, institutional affiliation)
- **35%** - Code implementations (GitHub repos within 72 hours)
- **20%** - Social signals (Twitter mentions, Reddit discussions)
- **5%** - Technical novelty (new methods, benchmarks)

## Implementation Details
[To be added during Phase 2 development]

## Validation Methodology
- Historical data: Papers from 2020-2022
- Success metric: Top 20% by citations after 24 months
- Baseline comparison: Random (20%), h-index only (51%)
- Target accuracy: 70%+
