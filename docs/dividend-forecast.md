# Dividend forecast rules

DividendenDackel's MVP forecast is deterministic. It does not use machine
learning and it does not imply that a company will declare or pay a dividend.
Every generated event is labelled `historicallyEstimated` and carries low or
medium confidence.

## Inputs and precedence

The engine uses reported payments for the selected instrument only. Existing
estimates never become evidence for another estimate.

1. Detect a regular annual, semi-annual, quarterly or monthly frequency.
2. Learn seasonal payment dates from the newest complete reported year.
3. Preserve announced or confirmed future events unchanged.
4. Use an announced amount as the basis for the same seasonal slot next year.
5. Generate only missing slots inside the half-open 24-month horizon.

Payment dates drive the income horizon. When history contains both an ex-date
and a payment date, the median observed offset is retained so an estimated
event can expose both dates. When no recurring dated pattern exists, the app
shows known events but does not invent future dates.

## Growth assumption

The longest available standard dividend CAGR is preferred in this order:
10-year, 5-year, then 3-year. CAGR uses completed reported calendar years as
defined in D1; partial current years and estimated payments are excluded.

When fewer than three complete growth years are available, MVP v1 uses a
documented fallback annual growth rate of **3.0%**. This is a neutral product
assumption, not a provider estimate or a promise. The UI must state:

> Estimated from the documented default growth rate (+3.0% p.a.) because
> fewer than three complete growth years are available.

The fallback is centralized in `DividendForecastEngine` so a later settings
control can replace it without changing forecast semantics.

## Confidence and limitations

- `medium`: an instrument CAGR is available and at least three complete years
  match the detected seasonal schedule;
- `low`: a shorter schedule or the default growth assumption is used;
- unavailable: no reported history, an irregular schedule, or amounts without
  recurring ex/payment dates. No generated events are returned.

Special dividends can affect annual growth and should be explained in a later
research view. Corporate guidance, payout coverage and management decisions
are not predicted. Forecasts are estimates, not investment advice.
