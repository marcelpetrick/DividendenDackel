# Current Parqet comparison

Reviewed 2026-08-23 against Parqet's official product pages, help center and
changelog. This is product research, not a request to reproduce Parqet's design
or implementation. DividendenDackel keeps its narrower dividend/event focus,
local-first privacy model and explainable calculations.

## Capability comparison

| Capability | Parqet evidence | DividendenDackel 0.1.0 | Scope decision |
| --- | --- | --- | --- |
| Dividend calendar | Month/year/table views, portfolio/watchlist filters, ex/payment date choice, weekend control, expected marker and large instrument universe | Month/year/agenda views, the same core filters and date modes, weekend control, explicit estimate markers, held gross/net amounts and attributable FX | Core is covered. Do not add another calendar view merely for parity. |
| Calendar export | iCal download and subscribed calendar feeds | No export | Promote a privacy-safe local `.ics` export. Do not expose a public portfolio feed URL by default. |
| Dividend forecast | Historical forecast and announced-dividend views | Explainable 24-month monthly/quarterly/yearly forecast, announced values preferred, confirmed/estimated split, tax and FX disclosures | DividendenDackel is already differentiated; improve data coverage rather than adding opaque forecast complexity. |
| Live data coverage | Dividend data for more than 35,000 instruments | Keyless SEC coverage for US issuers, ECB FX and an explicitly labelled offline dataset | Expand only through documented, licensed adapters such as R5; never disguise sample coverage as live parity. |
| Portfolio capture | Manual activities, PDF/CSV import and broker autosync | Manual holding/watchlist entry with average price | Add a transaction/activity ledger first, then local file imports. Broker credential sync is later and requires a separate threat model. |
| Actual cash flows | Purchases, sales, distributions, fees and taxes are activities | Holdings and forecast events; no broker-recorded cash-flow history | Add actual dividend/tax/fee records and forecast-versus-paid reconciliation. This directly improves the dividend product. |
| Performance | Capital-weighted return, TTWROR, XIRR, benchmarks, monthly/quarterly/yearly return detail and capital-flow analysis | Value/day change, allocation, yield, health and dividend-income analytics | Add only after the activity ledger. Every method must disclose formula, cash-flow treatment, period and data coverage. |
| Multiple portfolios | Multiple portfolios/subaccounts and consolidated views | Local create/rename/clear/delete, isolated holdings/watchlists/ledgers/preferences and an explicit read-only consolidated view | Covered without crossing tax, currency, provenance or write boundaries. |
| Taxes and fees | Actual tax/withholding and fee analysis from activities | Explainable German estimated net dividend tax, treaty/credit/reclaim split and editable assumptions | Preserve the estimate advantage; add actual-versus-estimated reconciliation rather than another standalone estimate chart. |
| News and analysis | Portfolio-filtered news, allocation/performance analysis and integrations | Portfolio-ranked Today feed, provider provenance, health, explainable dividend/research scores and change conditions | Current direction is stronger for the product statement. No generic news volume or hidden score. |
| Platforms and privacy | Hosted account, web/mobile apps, local broker-sync options and external integrations | No account/backend, Android 10+ and native Linux, local database, offline sample/cache, no analytics | Local-first remains a differentiator. Sync and integrations must not become prerequisites. |
| Other assets and AI integrations | Cash, crypto, real estate and other assets; third-party/AI integrations | Listed dividend instruments and portfolio events | Deliberately out of scope. They dilute the dividend companion and expand privacy/licensing risk. |

## Added post-1.0 priorities

1. **Local activity ledger and reconciliation.** Purchases, sales, deposits,
   withdrawals, dividends, taxes and fees need stable identities, provenance,
   correction/reversal semantics and additive migrations. The first user value
   is “expected versus actually paid,” not a generic trading dashboard.
2. **Local, reviewable import.** Start with a documented CSV schema and
   Portfolio Performance CSV. Import must have preview, validation, duplicate
   detection, an atomic commit and undo; source files stay on the device.
3. **Private calendar export.** Export the currently selected portfolio/date
   mode to `.ics`, with estimates visibly marked. Avoid a remotely hosted secret
   URL in the local-only architecture.
4. **Multiple portfolios and consolidated views — implemented.** Per-portfolio
   tax, currency, provenance and write boundaries are retained while an explicit
   read-only view combines safe projections.
5. **Explainable performance.** Add capital flows, XIRR and TTWROR plus optional
   benchmark comparison only after transaction history is trustworthy. Never
   compare money-weighted portfolio return with a time-weighted benchmark
   without explaining the mismatch.
6. **Broker document import, then reconsider autosync.** Local PDF/CSV parsing is
   compatible with the privacy model. Credential-based broker sync needs a
   provider-by-provider security, licensing and failure-reconciliation design
   and remains optional.

## Explicit non-goals from the comparison

- no hosted AI/chat integration with portfolio read/write access;
- no social/community feed, leaderboards or trade rankings;
- no expansion into real estate, insurance, loans or crypto for feature-count
  parity;
- no public calendar subscription URL that can reveal dividend amounts;
- no opaque performance or forecast score.

## Official sources

- [Parqet web-app overview](https://faq.parqet.com/de/articles/660871-die-parqet-webapp-im-uberblick)
- [Parqet dividend calendar](https://parqet.com/de/blog/dividendenkalender)
- [Parqet calendar integration](https://parqet.com/blog/dividenden-kalender-integration)
- [Parqet activity entry and import](https://faq.parqet.com/de/articles/651198-so-fugst-du-aktivitaten-in-parqet-hinzu)
- [Parqet Portfolio Performance import](https://faq.parqet.com/de/articles/651207-portfolio-performance-import)
- [Parqet return and TTWROR explanation](https://faq.parqet.com/de/articles/650587-rendite-vs-ttwror)
- [Parqet XIRR explanation](https://faq.parqet.com/de/articles/650586-izf-interner-zinsfuss)
- [Parqet current changelog](https://parqet.com/de/changelog)
