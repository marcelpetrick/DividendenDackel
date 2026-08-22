# Vision.md — DividendenDackel

> **Document type:** Product & Engineering Requirements  
> **Product name:** DividendenDackel  
> **Platforms:** Android 10+ and Linux x86_64  
> **Technology:** Flutter + Dart  
> **Architecture:** Client-first, local-first, provider-agnostic  
> **Status:** MVP requirements and development baseline  
> **Versioning:** Semantic Versioning

---

## 1. Product vision

**DividendenDackel** is a portfolio companion focused on dividends, upcoming portfolio events, financial research, and clear daily insights.

It is not intended to be another chart-heavy trading app.

The core question is:

> **What matters for my portfolio today, what happens next, and what should I understand about it?**

A user should be able to open the app and understand within a few seconds:

- which dividends are expected,
- when ex-dividend and payment dates occur,
- how much dividend income is expected this month and in future months,
- which earnings or corporate events are coming up,
- which news matters to the user's holdings,
- whether the research picture of a holding has changed,
- which data is confirmed and which is estimated,
- how fresh the displayed information is,
- which data providers are currently being queried,
- whether data came from the local cache or from a live provider request.

The product should feel approachable to beginners while still exposing enough detail for experienced investors.

---

# 2. Product principles

## 2.1 Relevance before data volume

Do not show a generic firehose of financial data.

Prefer:

> **3 things matter for your portfolio today**

over:

> 84 new market articles.

Information must be ranked by relevance to the user's holdings and watchlist.

---

## 2.2 Explain instead of command

The app must not present opaque or absolute commands such as:

- BUY NOW
- SELL NOW
- THIS WILL RISE
- GUARANTEED DIVIDEND

Use explainable research language instead:

- historically attractive valuation,
- increased event risk,
- improving earnings trend,
- dividend appears well covered,
- dividend estimate,
- research outlook improved,
- worth reviewing,
- elevated uncertainty.

Any score must explain why it exists.

---

## 2.3 Beginner-first, expert-expandable

Default screens show simple language and a small number of important values.

Detailed metrics are available through progressive disclosure.

Example:

Beginner view:

> Expected dividend in 4 days: **€24.80**

Expanded view:

- Ex-date
- Payment date
- Dividend per share
- Yield
- Payout ratio
- 5-year dividend CAGR
- Previous dividend
- Source
- Data age
- Confirmation status

---

## 2.4 Local-first

The portfolio and cached market data should remain usable without an internet connection.

The application must display previously downloaded information immediately and update it in the background when possible.

Never replace useful cached data with an empty screen merely because a provider is temporarily unavailable.

---

## 2.5 Transparent data

Important values should expose:

- source,
- last update time,
- cache state,
- confirmation state,
- currency,
- estimate status where applicable.

Financial-data uncertainty is part of the product and must be visible.

---

# 3. Target audience

Primary users:

- private investors,
- dividend investors,
- people holding a small or medium-sized stock portfolio,
- users who do not want to search multiple financial websites every day,
- beginners who need explanations of financial terminology.

Secondary users:

- experienced investors who want fast event monitoring,
- open-source users,
- Linux desktop users,
- users who prefer local portfolio storage.

---

# 4. Supported platforms

## 4.1 Android

Minimum supported Android version:

```text
Android 10
API level 29
```

The application must be deployable as an APK.

Android 10 is the minimum runtime requirement, not the target API level.

The application should target a current Android API level required for modern publication while remaining compatible with Android 10.

For Google Play releases, the project must follow the currently required target API level.

As of August 31, 2026, new apps and updates submitted to Google Play must target Android 16 / API 36 or newer.

Therefore the expected Android configuration is conceptually:

```text
minSdk: 29
targetSdk: current Play requirement
compileSdk: current stable supported SDK
```

The CI pipeline must verify that Android 10 compatibility is not accidentally removed.

---

## 4.2 Linux Desktop

The same application must also run as a native Flutter desktop application on:

```text
Linux x86_64
```

The Linux version must not require an Android runtime or emulator.

Expected artifact:

```text
Linux x86_64 release bundle
```

The Linux UI may adapt to larger screens but must provide the same core functionality.

---

# 5. Technology choice

The application is built with:

- Flutter
- Dart

Flutter is chosen because the same application can target:

- Android,
- Linux desktop,

while sharing:

- domain logic,
- data providers,
- database models,
- research calculations,
- caching,
- most UI components.

Platform-specific integrations should be isolated behind adapters.

---

# 6. Application navigation

The primary navigation should remain small.

Recommended top-level sections:

1. **Today**
2. **Calendar**
3. **Portfolio**
4. **Research**

Additional destinations:

- Watchlist
- Data Status
- Notifications
- Settings
- About / Data Sources

On desktop these may appear in a navigation rail or sidebar.

On Android they may appear in bottom navigation plus secondary screens.

---

# 7. Today screen

The **Today** screen is the central product experience.

It should answer:

1. What matters today?
2. What happens in the next 3 days?
3. How much dividend income is expected?
4. What changed since the previous refresh?

Example structure:

```text
Good morning

Portfolio today
+0.4 %
14 holdings
3 relevant events

Today matters
NVIDIA — Earnings after market close
Allianz — Ex-dividend tomorrow
Microsoft — Material company update

Next 3 days
2 earnings
1 ex-dividend event
1 dividend payment
4 relevant news items

Expected dividends
Next 7 days:    €42.60
Next 30 days:   €146.20
This year:      €1,284.30
```

The screen must remain useful even when live quotes are unavailable.

---

# 8. Portfolio

Users can create a portfolio locally.

## 8.1 Add holding

A prominent `+` action allows the user to search for an asset.

Search should support where data allows:

- company name,
- ticker,
- exchange,
- ISIN.

After selecting an instrument:

```text
Add to:
[ Portfolio ]
[ Watchlist ]
```

For portfolio holdings:

Required:

- instrument,
- quantity.

Optional:

- average purchase price,
- purchase date,
- notes.

The MVP does not need to implement full broker-grade transaction accounting.

---

## 8.2 Portfolio overview

Display:

- total value where quote data is available,
- daily change,
- holdings,
- allocation,
- expected dividend income,
- portfolio dividend yield,
- next dividend,
- upcoming events.

Portfolio data must be stored locally.

---

# 9. Dividend calendar

The dividend calendar is one of the primary features.

The UX can take inspiration from products such as Parqet, particularly the idea of combining portfolio-filtered dividend events, calendar views, estimates, and income forecasts.

The implementation must remain original.

## 9.1 Calendar modes

Required:

- month view,
- year view,
- agenda/list view.

Optional later:

- week view.

---

## 9.2 Event date modes

Users must be able to switch between:

### Ex-dividend date

The relevant entitlement date.

### Payment date

The expected or confirmed payout date.

These concepts must be clearly explained for beginners.

---

## 9.3 Calendar contents

Each event should show at minimum:

- company name or ticker,
- dividend amount per share,
- currency,
- confirmation status.

When the holding quantity is known, also display:

- expected portfolio payment amount.

Example:

```text
15 Aug

Allianz
€13.80 / share
Expected payment for your holding: €276.00
Confirmed
```

---

## 9.4 Dividend status

Every dividend event must have an explicit status:

- confirmed,
- announced,
- expected,
- historically estimated,
- unknown.

Estimated values must be visually distinguishable from confirmed values.

Never display a forecast as if it were guaranteed.

---

# 10. Dividend monthly forecast

A dedicated forecast must summarize dividend income by month.

Example:

```text
2027 forecast

Jan   €82
Feb   €41
Mar   €196
Apr   €110
May   €370
Jun   €144
...
```

Required visualizations:

- month-by-month amount,
- annual total,
- confirmed amount,
- estimated amount,
- share of annual dividend income.

A simple bar visualization is recommended.

The current month should show:

- already paid,
- confirmed upcoming,
- estimated upcoming.

---

# 11. Dividend forecast logic

The app should estimate future dividends where provider data does not yet contain a confirmed payment.

Forecast inputs may include:

- historical payment frequency,
- most recent dividend,
- historical dividend growth,
- dividend CAGR,
- seasonal payment pattern,
- latest announced dividend.

Forecasts must include a confidence/status marker.

MVP forecasting should remain deterministic and explainable.

Avoid pretending to use sophisticated AI when the calculation is rule-based.

---

# 12. Dividend CAGR

Dividend growth must include **Compound Annual Growth Rate**.

Required periods when data is available:

- 3-year dividend CAGR,
- 5-year dividend CAGR,
- 10-year dividend CAGR.

Formula:

```text
CAGR = (Ending value / Beginning value)^(1 / years) - 1
```

For dividends:

```text
Dividend CAGR =
(Current annual dividend / Historical annual dividend)^(1 / years) - 1
```

Also display:

- years without a dividend cut,
- latest dividend increase,
- latest dividend decrease.

Example:

> **5Y dividend CAGR: +7.4% p.a.**

CAGR must always show its time period.

---

# 13. Portfolio return CAGR

Where mathematically appropriate, the app may show:

- 3-year CAGR,
- 5-year CAGR,
- CAGR since purchase.

However, a naive CAGR of total portfolio value is not valid when deposits, withdrawals, buys and sells occurred during the period.

The architecture should therefore allow later support for:

- Time-Weighted Return (TWR),
- Money-Weighted Return,
- XIRR.

The UI must not label a cash-flow-distorted value as CAGR.

---

# 14. Dividend Quality Score

Dividend yield alone is insufficient.

Each suitable asset can have a Dividend Quality Score based on explainable factors such as:

- dividend yield,
- payout ratio,
- free-cash-flow coverage,
- dividend history,
- dividend CAGR,
- number of consecutive payments,
- dividend cuts,
- earnings development,
- debt,
- free-cash-flow trend.

Example:

```text
Dividend Quality
67 / 100

Positive
+ 5Y dividend CAGR +8.1%
+ No cut in 8 years
+ Free cash flow covers payout

Risk
- Payout ratio increased
```

---

# 15. Research score

Each asset may have an explainable research score.

Do not reduce it to a BUY/SELL signal.

Suggested dimensions:

## Valuation

- P/E,
- Forward P/E,
- P/S,
- EV/EBITDA,
- comparison with historical ranges.

## Quality

- margins,
- free cash flow,
- debt,
- ROE,
- ROIC.

## Growth

- revenue CAGR,
- EPS CAGR,
- free-cash-flow CAGR,
- analyst estimates where available.

## Momentum

- 1 month,
- 3 months,
- 6 months,
- relative performance.

## Dividend

- yield,
- payout ratio,
- dividend CAGR,
- consistency,
- coverage.

## Event risk

- earnings proximity,
- guidance changes,
- abnormal volatility,
- material filings,
- elevated news activity.

Every score must include a human-readable explanation.

---

# 16. Research detail screen

An individual instrument should provide:

- price overview,
- upcoming events,
- dividend data,
- dividend history,
- earnings,
- valuation,
- growth,
- profitability,
- balance sheet,
- dividend quality,
- news,
- filings,
- risks,
- Bull Case,
- Bear Case,
- research-score history.

A particularly useful section is:

> **What would change the assessment?**

Example:

Positive:

- margins improve,
- free cash flow increases,
- guidance is raised.

Negative:

- payout ratio rises sharply,
- debt increases,
- dividend is cut.

---

# 17. What matters today

The app should not simply list all available news.

It should rank information according to relevance to the portfolio.

Potential relevance factors:

- asset is in portfolio,
- holding weight,
- asset is in watchlist,
- dividend announcement,
- earnings,
- guidance,
- merger or acquisition,
- management change,
- regulatory event,
- capital increase,
- share buyback,
- material SEC filing,
- unusual price movement,
- recency.

The Today screen should surface only the most relevant items first.

---

# 18. News

News items should include:

- headline,
- source,
- publication time,
- related instrument,
- category,
- relevance.

Potential categories:

- earnings,
- dividends,
- guidance,
- M&A,
- management,
- regulation,
- product,
- analyst,
- filing,
- macro,
- general.

The app should link to the original source where legally and technically permitted rather than republishing entire articles.

---

# 19. Why did my stock move?

For unusual movements, the app may show potentially relevant events.

Example:

```text
Stock: -4.8%

Potentially relevant factors
- Guidance lowered
- Earnings below expectations
- Sector weak today
- Unusually high news activity
```

Always use language such as:

> potentially relevant factors

rather than claiming unsupported causation.

---

# 20. Portfolio health

The app should provide a portfolio health overview.

Possible metrics:

- sector concentration,
- country exposure,
- currency exposure,
- largest position,
- Top-5 concentration,
- dividend-income concentration,
- volatility,
- correlation where data permits,
- value/growth exposure,
- portfolio dividend yield,
- long-term return metrics.

Example insight:

> 61% of expected dividend income comes from four companies.

This is more useful than presenting raw statistical values without context.

---

# 21. Dividend simulator

A user can simulate an additional investment.

Example:

> What happens if I invest another €2,000 in this holding?

Show:

- purchasable shares,
- additional estimated annual dividend,
- monthly/quarterly income effect,
- new portfolio weight,
- new dividend yield,
- concentration impact.

Future enhancement:

> At my current dividend yield, approximately how much invested capital would be required for €500 gross dividends per month?

---

# 22. Notifications

Useful event-based notifications:

- ex-dividend date tomorrow,
- payment expected today,
- dividend announced,
- dividend increased,
- dividend cut,
- earnings today,
- earnings tomorrow,
- earnings released,
- important new filing,
- material portfolio news,
- research score changed materially,
- unusual price movement.

Users must be able to configure:

- disabled,
- important only,
- all.

Per-instrument overrides may be added later.

Notifications must not use manipulative FOMO wording.

---

# 23. Beginner onboarding

Keep onboarding short.

## Step 1

> Which assets do you want to follow?

Large search field.

## Step 2

> Do you already own this asset?

If yes:

- quantity,
- optional purchase price.

## Step 3

> What matters to you?

Defaults:

- dividends,
- earnings,
- important news.

Optional:

- research scores,
- unusual movements.

Then open the Today screen immediately.

No long tutorial.

---

# 24. Design requirements

The app should feel:

- clean,
- modern,
- calm,
- responsive,
- trustworthy,
- visually polished.

Avoid:

- flashing green/red values,
- casino-like visual language,
- excessive charts,
- overwhelming dashboards,
- fake urgency.

Use strong information hierarchy.

Primary cards on Today:

- Today matters,
- Next 3 days,
- Expected dividends,
- Portfolio changes.

---

# 25. Responsive design

The same app must adapt to different screen sizes.

## Android

Prioritize:

- one-column layouts,
- touch targets,
- bottom navigation,
- concise cards.

## Linux

Use additional width for:

- navigation rail,
- multi-column dashboards,
- expanded tables,
- side-by-side calendar and detail views.

Do not create two separate products.

---

# 26. Light and dark themes

Support from the beginning:

- System
- Light
- Dark

Both themes must pass accessibility and contrast checks.

---

# 27. Accessibility

The MVP should support:

- scalable text,
- semantic labels,
- keyboard navigation on Linux where reasonable,
- visible focus states,
- sufficient contrast,
- non-color-only status indicators.

Red and green must never be the only way to communicate meaning.

---

# 28. Client-first data architecture

MVP 1 does not require a central server.

Each installed app instance is responsible for:

- provider access,
- request coordination,
- local caching,
- normalization,
- research calculations,
- scheduling,
- status reporting.

High-level flow:

```text
UI
 |
 v
Repository / Use Cases
 |
 +--> Local Cache
 |      |
 |      +--> Fresh -> return immediately
 |
 +--> Missing / stale
        |
        v
  Request Coordinator
        |
   +----+--------+----------+
   |             |          |
Provider A   Provider B  Provider C
   |             |          |
   +------+------|----------+
          |
          v
     Normalization
          |
          v
       SQLite
          |
          v
          UI
```

---

# 29. Parallel provider access

Independent provider requests should run in parallel where safe.

Example:

```text
Quotes --------\
Dividends ------\
Earnings --------+--> concurrently
News ------------/
Filings --------/
```

Do not execute everything serially.

However, parallelism must be controlled.

---

# 30. Request Coordinator

A central Request Coordinator is required.

Responsibilities:

- parallel-request limits,
- per-provider rate limits,
- timeout handling,
- retry policy,
- exponential backoff,
- deduplication,
- cache lookup,
- cancellation,
- request priorities,
- provider fallback,
- status reporting.

Screens must not create uncontrolled HTTP requests directly.

---

# 31. Request deduplication

If multiple parts of the UI need the same data at the same time, only one provider request should run.

Example:

Today, Calendar, and Research all require Apple dividend data.

Expected behavior:

```text
1 external request
3 local subscribers
```

not:

```text
3 identical external requests
```

---

# 32. Provider abstraction

External providers must implement common domain-facing interfaces.

Conceptual interface:

```text
MarketDataProvider
- searchInstruments()
- getQuotes()
- getDividends()
- getEarnings()
- getFundamentals()
- getNews()
- getFilings()
- getCompanyEvents()
```

Potential implementations:

- Financial Modeling Prep adapter,
- Finnhub adapter,
- Alpha Vantage adapter,
- SEC EDGAR adapter,
- future providers.

The UI must not know which provider supplied the data.

---

# 33. Provider priority and fallback

Different providers may be preferred for different data types.

Example:

```text
Dividends
1. Provider A
2. Provider B

News
1. Provider C
2. Provider A

US filings
1. SEC EDGAR
```

Fallbacks must obey rate limits.

Provider responses must be normalized into internal models before entering the rest of the app.

---

# 34. API keys and client security

This is a critical MVP constraint.

Because providers are accessed directly from Android/Linux clients:

> **A secret API key embedded in the application cannot be considered secret.**

Compiled applications can be inspected.

Therefore the client-only MVP must use one or more of these approaches:

1. providers that permit public/client-side keys,
2. providers that require no secret,
3. user-supplied API keys stored locally,
4. provider-specific free credentials whose exposure is acceptable under their terms.

Do not embed privileged server-grade credentials in the released application.

The architecture must allow a future aggregation server if protected credentials become necessary.

---

# 35. Local database

Use a local SQLite-backed persistence layer.

A Flutter-compatible database abstraction such as Drift is suitable.

Core entities:

```text
Instrument
Holding
WatchlistEntry
Quote
DividendEvent
EarningsEvent
NewsItem
Filing
ResearchSnapshot
AlertRule
ProviderState
SyncJob
SyncLog
CacheMetadata
```

The UI should primarily observe the local database.

Provider updates write into the database and automatically refresh the UI.

---

# 36. Instrument identity

Do not use ticker alone as the unique identifier.

A ticker can be ambiguous without an exchange.

Use an internal instrument ID with fields such as:

```text
internalId
symbol
exchange
MIC
ISIN
name
currency
country
providerMappings
```

---

# 37. Cache strategy

Different data types require different cache lifetimes.

Initial defaults may be:

```text
Instrument metadata       7-30 days
Historical dividends      7-30 days
Announced dividends       6-24 hours
Earnings calendar         6-12 hours
Fundamentals              12-24 hours
News                      5-15 minutes
Quotes                    provider-dependent
SEC filings               5-15 minutes for active holdings
```

These values should be configurable.

---

# 38. Stale-while-revalidate

If cached data exists but is old:

1. display it immediately,
2. mark it as stale,
3. refresh in the background,
4. update the UI when the fresh result arrives.

Example:

> Last updated 42 minutes ago — refreshing…

Avoid blocking the entire interface.

---

# 39. Background refresh

## Android

Android background restrictions must be respected.

Use platform-appropriate scheduled work rather than assuming a permanently running process.

Refresh opportunities include:

- app launch,
- app resume,
- periodic background work,
- network becoming available,
- user refresh.

Android 10 compatibility must be tested.

## Linux

While the application is running, a local scheduler can perform periodic refreshes.

Potential future feature:

- system tray mode,
- start-on-login,
- optional background daemon.

These are not required for the first MVP.

---

# 40. Sync priorities

When the app starts, not all data is equally important.

Priority order:

## High

- Today's portfolio events,
- next 3 days,
- dividend payments,
- ex-dividend dates,
- important news.

## Medium

- quotes,
- research scores,
- portfolio-health metrics.

## Low

- historical data,
- long-term fundamentals,
- non-visible watchlist history.

The Today screen should become useful as early as possible.

---

# 41. Data Status screen

A dedicated **Data Status** window/screen is required.

This is an important transparency and debugging feature.

Example:

```text
Data Status

Financial Modeling Prep
Connected
Active requests: 2
Last request: 8 sec ago
Cache hit rate: 84%

Alpha Vantage
Rate limit reached
Retry available: 18:04

Finnhub
Connected
Active requests: 1

SEC
Idle
Last refresh: 12 min ago
```

---

# 42. Active operations view

The status screen should also show current jobs:

```text
Current activity

✓ AAPL dividends       Cache hit
↻ MSFT earnings        Finnhub
↻ NVDA news            FMP
↻ AMD filing           SEC
… 6 more tasks
```

Optional detail fields:

- request type,
- instrument,
- provider,
- start time,
- duration,
- state,
- cache hit/miss,
- retries,
- last error,
- HTTP status,
- next allowed request.

This is especially useful for open-source users and development.

---

# 43. Provider health

Each provider should have a runtime state such as:

- healthy,
- degraded,
- rate limited,
- offline,
- authentication error,
- unknown.

One broken provider must not cause a global app failure.

---

# 44. Offline behavior

With no internet connection the user can still access:

- portfolio,
- calendar from cached data,
- previous dividend forecast,
- previous research,
- previously loaded news metadata,
- provider/status history.

Show:

> Last updated …

rather than presenting an empty screen.

---

# 45. Data provenance

Important domain records should include metadata such as:

```text
source
fetchedAt
updatedAt
cacheState
confidence
currency
originalSymbol
exchange
```

This enables transparent UI and easier debugging.

---

# 46. Candidate data providers

The architecture must remain provider-independent.

Potential MVP sources include:

## Financial Modeling Prep

Potential data:

- dividends,
- dividend calendar,
- earnings,
- earnings calendar,
- splits,
- company news,
- press releases,
- fundamentals,
- economic calendar.

## Alpha Vantage

Potential data:

- dividends,
- earnings,
- fundamentals,
- price history,
- news/sentiment.

## Finnhub

Potential data:

- company news,
- earnings calendar,
- market data,
- selected fundamentals.

Availability differs by endpoint and plan.

## SEC EDGAR

Useful for US listed companies:

- 10-K,
- 10-Q,
- 8-K,
- company facts,
- filings.

Provider terms and limits must be reviewed before release.

---

# 47. Provider licensing requirement

Open source and non-commercial distribution do **not** automatically grant permission to redistribute provider data.

For every provider maintain documentation containing:

```text
Provider
Free usage allowed?
Client-side usage allowed?
Caching allowed?
Redistribution allowed?
Attribution required?
Rate limit?
Retention limit?
Commercial-use restrictions?
API-key restrictions?
```

Recommended file:

```text
docs/data-providers.md
```

Do not merge a provider integration until these questions have been documented.

---

# 48. Data forecasting and confidence

Forecasts are estimates.

Every forecast must indicate whether it is:

- confirmed,
- announced,
- expected,
- derived from history.

Possible confidence levels:

- high,
- medium,
- low.

The user must be able to distinguish known future payments from inferred values at a glance.

---

# 49. Privacy

The portfolio should remain local by default.

MVP 1 does not require:

- login,
- cloud account,
- central portfolio database.

Benefits:

- simpler architecture,
- privacy,
- offline capability,
- easier open-source deployment.

Future optional feature:

- encrypted synchronization between Android and Linux.

---

# 50. Non-goals for MVP

The first MVP is not intended to be:

- a broker,
- an order execution platform,
- a tax filing application,
- a full double-entry portfolio ledger,
- a social trading network,
- an AI trading bot,
- an investment-advice service.

These exclusions keep the first release focused.

---

# 51. MVP scope

MVP 1 must contain:

## Core

- Flutter/Dart shared application,
- Android 10 compatibility,
- Linux x86_64 build,
- local portfolio,
- watchlist,
- instrument search,
- Today screen,
- next-3-days view,
- dividend calendar,
- monthly dividend forecast,
- annual dividend forecast,
- ex-date/payment-date toggle,
- confirmed vs expected dividend state,
- dividend CAGR,
- dividend history,
- basic research score,
- important portfolio news,
- local SQLite cache,
- Request Coordinator,
- parallel provider requests,
- request deduplication,
- provider fallback,
- Data Status screen,
- offline display.

## Quality

- responsive UI,
- light theme,
- dark theme,
- loading states,
- empty states,
- error states,
- source/freshness information.

---

# 52. MVP 2 candidates

After the initial release:

- push/local notifications,
- Dividend Quality Score improvements,
- portfolio-health analysis,
- dividend simulator,
- "Why did my stock move?",
- advanced research history,
- calendar export,
- CSV import,
- multiple portfolios,
- encrypted sync,
- widgets,
- Linux tray mode,
- broker import.

---

# 53. Engineering architecture

Recommended source structure:

```text
lib/
├── app/
├── core/
│   ├── errors/
│   ├── networking/
│   ├── logging/
│   └── utils/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── use_cases/
├── data/
│   ├── database/
│   ├── models/
│   ├── repositories/
│   └── providers/
├── features/
│   ├── today/
│   ├── calendar/
│   ├── portfolio/
│   ├── research/
│   ├── status/
│   └── settings/
└── platform/
    ├── android/
    └── linux/
```

Keep domain logic independent from UI widgets and provider DTOs.

---

# 54. State management

Use one consistent state-management approach across the application.

Preferred candidates:

- Riverpod,
- Bloc.

Do not mix multiple major state-management patterns without a concrete reason.

Repositories expose domain data.

UI consumes application state.

---

# 55. Error handling

Errors must be typed and actionable.

Example categories:

- network unavailable,
- timeout,
- rate limited,
- authentication,
- provider unavailable,
- parsing failure,
- invalid instrument,
- no data,
- stale data.

Do not expose raw stack traces to normal users.

Detailed diagnostic information may be available in the Data Status screen or developer logs.

---

# 56. Logging

Use structured application logging.

Logs should include:

- component,
- provider,
- operation,
- duration,
- error category.

Avoid logging sensitive user information.

Debug builds may be verbose.

Release builds should use controlled logging.

---

# 57. Testing requirements

At minimum:

## Unit tests

- CAGR,
- dividend forecast,
- research calculations,
- cache expiry,
- request deduplication,
- provider fallback,
- normalization.

## Repository tests

- fresh-cache path,
- stale-cache path,
- provider failure,
- fallback provider.

## Widget tests

Critical screens:

- Today,
- Calendar,
- Portfolio,
- Data Status.

## Integration tests

At least one happy path for:

- add holding,
- load dividends,
- show calendar event,
- show forecast.

---

# 58. Android compatibility testing

CI and release review must explicitly protect Android 10 compatibility.

Check:

- `minSdk` remains 29,
- dependencies still support the required Android versions,
- no feature accidentally depends on newer Android APIs without guards.

A real Android 10 device or emulator should be part of release testing where practical.

---

# 59. Linux testing

Release validation must include:

- x86_64 Linux build succeeds,
- application launches,
- database opens,
- network provider requests work,
- calendar renders,
- desktop resizing works.

---

# 60. Versioning

Use **Semantic Versioning**:

```text
MAJOR.MINOR.PATCH
```

Examples:

```text
0.1.0
0.2.0
0.2.1
1.0.0
```

Before stable release:

```text
0.x.y
```

Rules:

- PATCH: bug fix,
- MINOR: backwards-compatible feature,
- MAJOR: incompatible application/data behavior or stable breaking change.

---

# 61. Flutter version metadata

Flutter version information must be kept in `pubspec.yaml`.

Example:

```yaml
version: 0.1.0+1
```

Where:

- `0.1.0` = semantic application version,
- `1` = build number.

For Android:

- version name derives from semantic version,
- version code derives from build number.

Build numbers must always increase for published Android artifacts.

---

# 62. Version display

The app should expose version information in:

```text
Settings -> About
```

Display:

- app name,
- semantic version,
- build number,
- commit SHA where available,
- build date where available.

Example:

```text
DividendenDackel
0.3.0 (42)
Commit: a83f91c
```

---

# 63. Git workflow

Development quality is part of the project requirements.

Every code change should be committed in small, reviewable units.

## Atomic commits

Each commit should represent one logical change.

Good:

```text
feat(calendar): add payment-date toggle
```

Bad:

```text
update app
```

A commit should not combine unrelated changes such as:

- calendar feature,
- dependency update,
- formatting entire project,
- unrelated bug fix.

If changes can be independently understood or reverted, they should normally be separate commits.

---

# 64. Conventional Commits

Commit messages must follow Conventional Commits.

Examples:

```text
feat(calendar): add monthly dividend forecast
fix(cache): prevent duplicate provider requests
refactor(provider): extract dividend adapter interface
test(research): cover five-year CAGR calculation
docs(vision): document Android 10 requirement
ci(release): build Linux release artifact
chore(deps): update dio
```

Recommended types:

- feat
- fix
- refactor
- test
- docs
- ci
- build
- chore
- perf

Breaking changes must be marked according to the Conventional Commits specification.

---

# 65. Development loop

For each implementation task, use the following loop:

```text
1. Understand one small requirement.
2. Implement the smallest coherent change.
3. Format.
4. Analyze/lint.
5. Run relevant tests.
6. Review the diff.
7. Fix issues found during review.
8. Re-run checks.
9. Create one atomic Conventional Commit.
10. Continue with the next requirement.
```

Do not accumulate a large pile of unrelated changes before committing.

---

# 66. Mandatory self-review

Before each commit:

- inspect the diff,
- look for unintended files,
- check naming,
- check error states,
- check async behavior,
- check null/empty handling,
- check Android/Linux compatibility,
- check tests,
- check whether comments/documentation remain accurate.

Before release:

- review all changes since the previous release,
- run the full test suite,
- run static analysis,
- run formatting checks,
- build Android and Linux artifacts,
- smoke-test both targets.

---

# 67. Formatting and static quality

Required commands in development and CI should include equivalents of:

```text
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
```

Additional lint rules should be defined in:

```text
analysis_options.yaml
```

Prefer strict static analysis.

Warnings should not be routinely ignored.

---

# 68. GitHub Actions — Pull Request CI

Every pull request must run automated quality checks.

Required workflow:

```text
checkout
setup Flutter
restore dependency cache
flutter pub get
format check
flutter analyze
flutter test
build Android
build Linux where runner support allows
```

A pull request should not merge when required checks fail.

---

# 69. GitHub Actions — Release pipeline

A release workflow must create deployable artifacts.

Recommended trigger:

```text
Git tag: v*
```

Example:

```text
v0.3.0
```

Release pipeline:

1. checkout tagged commit,
2. set up pinned Flutter version,
3. verify version matches tag,
4. fetch dependencies,
5. run format check,
6. run analyzer,
7. run tests,
8. build Android release APK,
9. optionally build Android App Bundle,
10. build Linux x86_64 release,
11. generate checksums,
12. create GitHub Release,
13. upload artifacts.

Expected release artifacts:

```text
dividend-tracker-0.3.0-android.apk
dividend-tracker-0.3.0-linux-x86_64.tar.gz
SHA256SUMS
```

Optional:

```text
dividend-tracker-0.3.0-android.aab
```

---

# 70. Reproducible release configuration

CI must pin major tooling versions intentionally.

Do not silently build releases with arbitrary "latest" Flutter versions.

The selected Flutter SDK version should be documented.

Possible mechanisms:

- FVM,
- CI configuration,
- repository toolchain file.

Dependency lockfiles must be committed where appropriate.

---

# 71. Dependency update checks

Dependency freshness should be automated.

Use one of:

- Dependabot,
- Renovate.

A scheduled GitHub Action may also run:

```text
flutter pub outdated
```

The check should report outdated dependencies.

Do not automatically merge every dependency update.

Updates must still pass:

- analysis,
- tests,
- Android build,
- Linux build.

---

# 72. Toolchain freshness checks

A scheduled CI workflow should periodically report:

- outdated Dart packages,
- outdated Flutter SDK selection,
- Android Gradle Plugin changes where relevant,
- Gradle changes,
- Android target API requirements,
- action-version updates.

The goal is visibility, not blind upgrades.

Android 10 support must be rechecked after major dependency/toolchain upgrades.

---

# 73. GitHub Action security

Third-party GitHub Actions should be:

- reputable,
- pinned to stable versions,
- preferably pinned to full commit SHA for high-trust release workflows.

Release workflows must use minimal required permissions.

Secrets must not be exposed to pull requests from untrusted forks.

---

# 74. Branch protection

Recommended repository rules:

- pull request required for protected branches,
- CI checks required,
- no merge with failing analyzer/tests,
- linear history preferred,
- force-push disabled on release branches,
- tagged releases created only from reviewed commits.

For a small solo project, direct development may remain possible, but release branches/tags should still pass all automated checks.

---

# 75. Changelog

Maintain release notes.

Options:

- manually maintained `CHANGELOG.md`,
- generated from Conventional Commits.

Each release should describe:

- features,
- fixes,
- breaking changes,
- data-provider changes,
- migration notes.

---

# 76. Database migrations

Local database schema changes must use explicit migrations.

Requirements:

- never silently delete the user's portfolio,
- test migrations,
- keep schema version,
- support upgrade from the previous released version.

Destructive reset is only acceptable during early development and must not remain the default once real releases exist.

---

# 77. Data-provider contract tests

Provider adapters are fragile because upstream APIs change.

Create fixture-based tests for provider normalization.

For each provider:

```text
sample upstream response
      |
      v
normalized domain model
```

This makes provider breakages easier to detect.

---

# 78. Performance requirements

The app should:

- show cached Today data quickly,
- avoid blocking UI during provider requests,
- avoid unnecessary rebuilds,
- batch and deduplicate requests,
- lazy-load deep research data,
- avoid loading full historical datasets during startup.

Calendar scrolling should remain smooth on Android 10-era hardware.

---

# 79. Failure behavior

Examples:

## Provider unavailable

Show cached data plus:

> Provider temporarily unavailable.

## Rate limit reached

Show:

> Data source limit reached. Next refresh available later.

## Missing payment date

Show:

> Payment date not yet confirmed.

## Forecast only

Show:

> Estimated from historical dividend pattern.

Never fabricate missing values.

---

# 80. Security baseline

Minimum requirements:

- HTTPS only,
- TLS certificate validation,
- no privileged API secrets embedded in app,
- validate provider responses,
- sanitize external URLs,
- safe local storage,
- no portfolio content in crash logs by default,
- minimal permissions on Android.

Do not request Android permissions that are not required.

---

# 81. Open-source repository structure

Recommended:

```text
/
├── lib/
├── test/
├── integration_test/
├── android/
├── linux/
├── assets/
├── docs/
│   ├── architecture.md
│   ├── data-providers.md
│   ├── research-score.md
│   ├── privacy.md
│   └── releases.md
├── .github/
│   ├── workflows/
│   │   ├── ci.yml
│   │   ├── release.yml
│   │   └── dependencies.yml
│   └── dependabot.yml
├── analysis_options.yaml
├── pubspec.yaml
├── pubspec.lock
├── CHANGELOG.md
├── CONTRIBUTING.md
├── LICENSE
├── README.md
└── Vision.md
```

---

# 82. Contribution requirements

`CONTRIBUTING.md` should explain:

- Flutter version,
- setup,
- test commands,
- formatting,
- Conventional Commits,
- atomic commit expectation,
- pull-request requirements,
- provider fixture rules,
- Android 10 compatibility requirement,
- Linux build requirement.

---

# 83. Product success criteria

The product is successful when a user can open it and answer within approximately ten seconds:

> **What matters for my investments today?**

And within approximately thirty seconds:

> **What dividends should I expect this month and over the coming months?**

The experience should require less effort than manually checking multiple finance portals.

---

# 84. Core retention loop

The app should create useful reasons to return without manipulative gamification.

Examples:

Morning:

> 3 things matter today.

Before earnings:

> Earnings today after market close.

Dividend:

> Approximately €64.20 expected this week.

Change:

> Dividend outlook changed for one holding.

Month view:

> Expected dividend income next month: €183.

Retention should come from useful information, not artificial streaks.

---

# 85. Explicitly avoid

Do not implement:

- trading streaks,
- gambling-style celebration,
- "don't miss this opportunity" prompts,
- fake countdowns,
- guaranteed return claims,
- hidden scoring logic,
- default notification spam.

The tone should encourage understanding rather than impulsive trading.

---

# 86. Development phases

## Phase 1 — Foundation

1. Flutter project for Android and Linux.
2. Android minimum API 29.
3. Shared domain model.
4. SQLite persistence.
5. Instrument search.
6. Local portfolio.
7. Provider interfaces.
8. Request Coordinator.
9. Data Status screen.

## Phase 2 — Dividend core

10. Dividend provider adapter.
11. Historical dividends.
12. Dividend calendar.
13. Ex-date/payment-date modes.
14. Monthly forecast.
15. Annual forecast.
16. Dividend CAGR.
17. Confirmed/estimated states.

## Phase 3 — Daily insight

18. Today screen.
19. Next 3 days.
20. Earnings.
21. News.
22. Relevance ranking.
23. Basic research score.

## Phase 4 — Quality

24. Offline behavior.
25. Provider fallback.
26. full empty/error states.
27. dark mode.
28. accessibility.
29. Android 10 smoke tests.
30. Linux desktop polish.

## Phase 5 — Delivery

31. CI workflow.
32. dependency workflow.
33. release pipeline.
34. version validation.
35. signed/tagged GitHub releases.
36. documentation.
37. first public MVP.

---

# 87. Definition of Done for a feature

A feature is not complete merely because it renders.

Definition of Done:

- requirement implemented,
- Android behavior considered,
- Linux behavior considered,
- loading state,
- empty state,
- error state,
- offline state where relevant,
- tests added or updated,
- formatting passes,
- analyzer passes,
- relevant tests pass,
- diff self-reviewed,
- documentation updated if needed,
- atomic Conventional Commit created.

---

# 88. Release Definition of Done

A release is complete only if:

- semantic version is updated,
- build number increased,
- changelog/release notes prepared,
- all CI checks pass,
- Android APK builds,
- Linux x86_64 build succeeds,
- Android 10 compatibility was not removed,
- database migration path is tested,
- no privileged provider secrets are embedded,
- provider-license documentation is current,
- GitHub Release contains artifacts and checksums.

---

# 89. Current reference notes

## Parqet inspiration

Parqet currently demonstrates several useful dividend UX patterns:

- month and year dividend calendar views,
- portfolio/watchlist filtering,
- switching between ex-date and payment date,
- expected dividends marked separately,
- dividend metrics,
- monthly dividend income forecasting.

DividendenDackel should use these ideas as product inspiration but implement its own design and interaction model.

Reference:

- https://app.parqet.com/de/dividenden-kalender
- https://parqet.com/de/blog/dividendenkalender
- https://parqet.com/de/changelog

## Android requirements

Current Google Play target API rules must be checked before every release.

Reference:

- https://developer.android.com/google/play/requirements/target-sdk

## Flutter platform references

Use the current Flutter documentation when configuring Android and Linux builds.

Reference:

- https://docs.flutter.dev/platform-integration/android
- https://docs.flutter.dev/platform-integration/linux/building

---

# 90. Final product statement

> **DividendenDackel turns a local portfolio into a clear timeline of dividends, events, research changes, and upcoming income.**

The app should make financial information understandable without hiding the underlying data.

Its strongest identity is the combination of:

- portfolio,
- dividend calendar,
- monthly forecast,
- daily event summary,
- research insights,
- transparent provider activity,
- local-first privacy,
- Android + Linux support,
- open-source engineering quality.

The first release should prioritize reliability and clarity over feature count.
