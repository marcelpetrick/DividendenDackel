# Research score

The research score is an explainable snapshot of the evidence currently
available for one instrument. It is not a BUY/SELL signal and does not predict
returns.

## Dimensions and weights

| Dimension | Overall weight | Evidence |
| --- | ---: | --- |
| Valuation | 20% | P/E, forward P/E, P/S, EV/EBITDA, own historical percentile |
| Quality | 20% | margins, debt/equity, ROE, ROIC |
| Growth | 20% | revenue, EPS and free-cash-flow CAGR, labelled analyst estimate |
| Momentum | 15% | 1/3/6-month and benchmark-relative returns |
| Dividend | 15% | the explainable Dividend Quality Score |
| Event risk | 10% | earnings proximity and explicitly observed risk flags |

Each metric is assigned a disclosed band score, then normalized over only the
known metrics in its dimension. The overall score uses the weights above,
renormalized over only the available dimensions. Missing evidence is omitted;
it never becomes zero and never receives an invented neutral value.

Event-risk scores run in the same direction as the other dimensions: a higher
number means fewer observed near-term risk flags. A flag says only that
proximity or activity was observed, not that the outcome will be positive or
negative. A false flag may be supplied only when the source covered the stated
observation window; absence of a fetched record is unknown.

## Interpretation

- 75–100: broadly strong available evidence;
- 50–74: mixed available evidence;
- 0–49: material risks in the available evidence.

Every overall and per-dimension score carries its source factors. Forward and
analyst figures are labelled as estimates. Non-positive valuation multiples
are treated as adverse rather than as unusually cheap. Thresholds are
heuristics for comparison, not financial advice, and can be revised without
rewriting historical source data.
