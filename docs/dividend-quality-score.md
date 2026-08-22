# Dividend Quality Score

The score is a deterministic 0–100 assessment of the evidence currently
available for one instrument. It is not a recommendation.

## Factors and maximum weights

| Factor | Weight |
| --- | ---: |
| Consecutive years without a cut | 25 |
| Longest available standard 10/5/3-year dividend CAGR | 20 |
| Completed payment-history length | 15 |
| Forward yield | 10 |
| Payout ratio | 15 |
| Free-cash-flow coverage | 15 |
| Earnings trend | 5 |
| Debt trend | 5 |
| Free-cash-flow trend | 5 |

The earned points are divided by the maximum points of the factors that were
actually available. Missing fundamentals are excluded, never scored as zero.
No score is emitted without at least one completed, company-reported dividend
year. Sparse evidence remains visible through the factor list.

Yield above 8%, payout above 80%, uncovered dividends, falling earnings or
cash flow, rising debt and a current dividend cut are explicit risks. Every
result contains the exact positive, negative and neutral factors used to
calculate it. Thresholds are product heuristics, not claims of predictive
accuracy, and can evolve only with a documented rule and regression tests.
