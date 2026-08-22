# Currency conversion

DividendenDackel stores quotes, dividends and purchase prices in their native
ISO 4217 currency. Native amounts remain visible and are never added across
currencies. A user-selected display currency adds a separate converted view; it
does not mutate or relabel the source records.

## Rates and calculation

- Daily reference rates come from the Frankfurter v2 API with the provider
  filter fixed to `ECB`.
- Persisted rates answer “one EUR equals _x_ quote currency” and retain source,
  retrieval time, reference date and reported currency.
- Historical calculations select the newest rate on or before the valuation or
  dividend payment date. A future rate is never backfilled into the past.
- Non-EUR cross conversion divides into EUR and then multiplies into the target
  currency. Decimal arithmetic is retained through both legs and rounded only
  by final display formatting.
- A selected rate more than seven calendar days old is shown as stale. Cached
  stale values stay visible and a failed refresh does not erase them.

If any required leg is absent, the converted total is explicitly incomplete.
The app never substitutes `1`, silently drops the currency, or presents a
partial number as complete.

## Portfolio and tax

Portfolio value and 365-day income are converted independently, while currency
exposure is calculated from converted position-value buckets. Missing quotes
and missing rates are separate visible limitations.

German dividend-tax estimates convert foreign gross payments to EUR using the
payment-date rate before applying withholding and domestic tax. The UI retains
the native gross amount and shows the rate source, date and stale state next to
the EUR net estimate.

ECB rates are reference data, not executable broker prices. Forecasts may use
the latest cached rate for a future payment, which will become stale relative
to that future date and is labelled accordingly.
