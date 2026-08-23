# Portfolio CSV import

DividendenDackel imports portfolio activities from a local CSV file on Android
and Linux. The file is read on the device, is not uploaded, and is not retained
after the review dialog closes.

## Review and safety model

1. Choose a CSV file of at most 10 MB.
2. Review valid activities, skipped duplicates, and rejected rows.
3. Apply the valid rows in one SQLite transaction. If any activity would make a
   holding negative, the whole batch is rejected and nothing is changed.
4. Undo an applied batch from Import history. Undo appends reversal activities;
   it never erases the audit trail.

Each imported activity has a stable external identity. Re-importing the same
file skips records already applied to that portfolio and source. Invalid rows
are reported by line number without copying raw portfolio data into logs.

## DividendenDackel CSV

Column names are case-insensitive. `Date` and `Type` are required. Other useful
columns are:

| Column | Meaning |
| --- | --- |
| `Date` | ISO `YYYY-MM-DD` or `DD.MM.YYYY` |
| `Type` | `Purchase`, `Sale`, `Opening Balance`, `Deposit`, `Withdrawal`, `Dividend`, `Tax`, or `Fee` |
| `ISIN` / `Symbol` | Exact local instrument identity; ISIN is preferred |
| `Quantity` | Positive share count for security activities |
| `Unit Price` | Optional exact price per share |
| `Amount`, `Currency` | Positive absolute cash amount and ISO currency code |
| `Fees`, `Taxes` | Optional amounts imported as separate ledger activities |
| `External ID` | Recommended broker/source transaction identity |
| `Notes` | Optional local note |

Example:

```csv
Date,Type,ISIN,Quantity,Unit Price,Amount,Currency,Fees,Taxes,External ID,Notes
2026-01-02,Purchase,DE0008404005,2,100,200,EUR,1.50,0.50,trade-1,"first lot"
2026-05-10,Dividend,DE0008404005,,,27.60,EUR,,,cash-1,distribution
```

Cash activities do not require an instrument. Security activities require an
ISIN or ticker that resolves to exactly one instrument already known locally;
ambiguous ticker matches are rejected rather than guessed.

## Portfolio Performance CSV

Transaction exports from Portfolio Performance are detected from their header
fields. English and German header names, comma or semicolon delimiters, and
localized decimal separators are accepted. Supported transaction types include
Buy/Kauf, Sell/Verkauf, Deposit/Einlage, Removal/Entnahme,
Dividend/Dividende, taxes, fees, and inbound delivery/Einlieferung.

Export transactions from Portfolio Performance with the identity fields
(`ISIN` or `Ticker Symbol`) included. DividendenDackel uses `Gross Amount` for
the security value when present and creates fees and taxes as separate ledger
activities. It does not import accounts, classifications, dashboards, or
Portfolio Performance's calculated performance figures.

Portfolio Performance documents its transaction CSV columns in its
[official export reference](https://help.portfolio-performance.info/en/reference/file/export/).

## Interactive Brokers Flex CSV

Interactive Brokers Flex Query CSVs are detected from the official Trades or
Statement of Funds fields. For Trades, include `Trade Date`, `Buy/Sell`,
`Asset Class`, `Currency`, `ISIN` or `Symbol`, `Quantity`, `Trade Price`,
`Trade Money` or `Proceeds`, `Trade ID`, `IB Commission`, `IB Commission
Currency`, `Taxes` and `Notes/Codes`. Use execution-level rows rather than
summaries; non-execution detail levels are refused. For Statement of Funds,
include `Date`, `Activity Code`, `Amount`,
`Currency`, `Transaction ID` and the available instrument identity fields.

The adapter supports stock purchases and sales, deposits, withdrawals,
dividends, withholding/transaction taxes, fees and interest cash movements.
Negative broker quantities and cash amounts are normalized to the positive
absolute values required by the activity type. Stock sales still fail the
entire apply transaction if they would make the selected portfolio negative.
Options, futures, forex and other non-stock asset classes are rejected rather
than approximated. Rows marked with Interactive Brokers' canceled-trade `Ca`
code are also rejected.

For multi-account files, the account id or alias is hashed into the duplicate
identity so equal broker transaction ids cannot collide across accounts. The
raw account id is not stored.

Flex dates must use the official default `yyyyMMdd` format or ISO `yyyy-MM-dd`.
Slash dates are intentionally refused because Interactive Brokers lets the
exporter choose either month-first or day-first order, which cannot be inferred
safely from values such as `03/04/2026`.

Interactive Brokers documents the available [Trades fields](https://www.ibkrguides.com/reportingreference/reportguide/tradesfq.htm),
[Statement of Funds fields and activity codes](https://www.ibkrguides.com/reportingreference/reportguide/statement%20of%20fundsfq.htm),
and [Flex Query CSV configuration](https://www.ibkrguides.com/clientportal/performanceandstatements/tradeflex.htm).

## Deliberate limits

- Import is local file import, not broker credential synchronization.
- The source filename and source file are not stored.
- The importer does not invent instruments, exchange rates, or missing dates.
- One reviewed file targets one explicitly selected portfolio.
