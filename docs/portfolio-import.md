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

## Deliberate limits

- Import is local file import, not broker credential synchronization.
- The source filename and source file are not stored.
- The importer does not invent instruments, exchange rates, or missing dates.
- One reviewed file targets one selected portfolio. Multiple-portfolio
  selection is tracked separately in the implementation backlog.
