# Portfolio performance

DividendenDackel calculates performance locally from the immutable activity
ledger and exact native-currency portfolio valuations. It does not combine
currencies, infer missing prices or turn an incomplete history into a plausible
number.

## Cash-flow detail

The portfolio shows monthly, quarterly and annual lines for purchases, sales,
actual dividends, taxes, fees, deposits and withdrawals. Purchase and sale
values require both an exact quantity and recorded unit price. An opening
balance is treated as invested capital. Reversed activities are excluded; the
reversal remains visible in the ledger.

`Net invested = purchases + taxes + fees - sales - dividends`

Deposits and withdrawals are displayed separately. They are not part of the
security-only return because the app does not currently maintain or value a
portfolio cash account.

## XIRR

XIRR is the money-weighted annual rate `r` that solves:

`0 = sum(cash flow i / (1 + r) ^ elapsed years i)`

Purchases, opening balances, taxes and fees are capital outflows. Sales and
actual dividends are inflows. The final complete covered security value is the
terminal inflow. The displayed period starts on the first valued security cash
flow and ends on the coherent date of the terminal quotes, not automatically
on today's date.

The app withholds XIRR when a current position is unpriced, a trade or holding
adjustment has no defensible cash value, the terminal valuation predates a cash
flow, the signs do not support a solution, or the cash flows have multiple
mathematical solutions.

## TTWROR

TTWROR chains valuation-to-valuation segment returns:

`segment = (ending value + distributions) / (beginning value + contributions) - 1`

`TTWROR = product(1 + segment) - 1`

Purchases and costs are contributions; sales and dividends are distributions.
At least two complete end-of-day valuations are required, and every security
cash-flow day inside the measured window must have a complete valuation. This
strict boundary avoids silently assuming whether a flow happened at the start
or end of a longer interval.

## Valuation history and coverage

When available position quotes in one currency share one calendar day, the app
stores an idempotent local valuation snapshot for that portfolio (or the
explicit consolidated scope). The position counts state whether it is complete;
only complete snapshots can support a return. The app never backdates a changed
holding to an older quote. Each snapshot stores its scope, currency, exact
total, normalized UTC date, position count and priced-position count. Schema 7
adds this history through an additive migration.

Each currency is reported independently. A sold-out currency can terminate at
zero on the calculation date; an open position must use coherent quote evidence.
Partial current value, unsupported ledger rows and insufficient history are
shown as limitations beside the affected metric.

## Benchmarks

Benchmark comparison is deliberately unavailable until the app has a licensed,
like-for-like historical benchmark series with matching currency, dates and
cash-flow convention. A current index quote is not enough, and a money-weighted
portfolio result must not be presented as directly equivalent to a time-weighted
benchmark.
