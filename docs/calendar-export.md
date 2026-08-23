# Private calendar export

The calendar's download action creates a local RFC 5545 `.ics` snapshot. The
user chooses the destination through Android's system document creator or the
Linux desktop save dialog. DividendenDackel has no hosted calendar feed and
never sends the snapshot to Google, Microsoft, Apple or another service.

## What is exported

The snapshot uses exactly the calendar state visible when Export is selected:

- current portfolio, watchlist or all-instruments scope;
- current month, year or agenda date range;
- ex-date or payment-date organization; and
- only events with a known selected date inside that half-open range.

Each event is an all-day entry with the instrument name and symbol, exact
per-share amount and currency, selected date meaning, certainty and local
source label. Estimated, expected and unknown events use `STATUS:TENTATIVE`,
start their summary with `[ESTIMATE]` and repeat the limitation in the
description. Company-confirmed and announced events use `STATUS:CONFIRMED`.

The file deliberately excludes holding quantities, cost basis, gross portfolio
income, tax settings, portfolio activities and credentials. Calendar clients
may copy an imported file to their own cloud according to the user's choice and
that client's privacy terms.

## Compatibility and snapshot semantics

The document uses CRLF endings, UTF-8-safe 75-octet line folding, deterministic
event UIDs, inclusive all-day starts and exclusive next-day ends. It can be
imported by calendar clients that support standard `.ics` files, including
Google Calendar, Outlook and Apple Calendar.

This is a snapshot, not a subscription. Importing a later export is controlled
by the calendar client; DividendenDackel does not update or delete entries in an
external calendar. A cancelled or failed save changes no app data.
