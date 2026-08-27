# Changelog

All notable changes to DividendenDackel are documented here.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/)
(Vision.md §60, §75).

## [Unreleased]

### Added

- Live English, German and Croatian application languages. The first launch
  follows a supported device locale, Settings applies changes without a
  restart, and the explicit choice stays on the device. Application copy,
  dynamic labels, accessibility descriptions and Flutter's platform controls
  share the active locale while portfolio and provider content is preserved.
- Explainable portfolio performance in each native currency: exact monthly,
  quarterly and annual cash-flow detail, dated money-weighted XIRR, and TTWROR
  over retained complete valuations. Formulas, coverage and cash treatment are
  visible, while missing prices, incoherent quote dates and sparse valuation
  history refuse a misleading result.
- Private RFC 5545 calendar snapshots for the current portfolio/watchlist/all
  scope, visible range and ex/payment-date mode. Estimated events are explicit,
  Android uses the system document creator and Linux uses its native save
  dialog; no public subscription URL or broad storage permission is added.
- Direct local Interactive Brokers Flex CSV import for stock trades,
  commissions, taxes, dividends and account cash movements. The adapter accepts
  official trade and statement-of-funds fields, refuses derivatives, canceled
  trades and ambiguous dates, and reuses the review/duplicate/atomic-undo flow.
- Complete local multi-portfolio management: create, rename, clear and delete
  portfolios; edit/delete holdings and watchlist entries; persistent portfolio
  selection; and an explicit read-only consolidated projection. Tax assumptions
  and display-currency preferences are stored per portfolio, and fresh installs
  no longer receive demonstration positions.
- A local immutable activity ledger for purchases, sales, deposits,
  withdrawals, dividends, taxes and fees. Holding projections update
  transactionally, corrections append auditable reversals, and actual gross
  dividends reconcile against dated expected payments without mixing
  currencies.
- Review-first local CSV import for the native schema and Portfolio Performance
  transaction exports, with row validation, stable duplicate detection, one
  atomic apply transaction, retained batch history and reversal-based undo.
- Current official Parqet comparison and a reprioritized post-1.0 scope focused
  on local transaction truth, dividend reconciliation, private import/export,
  multiple portfolios and explainable performance.

### Fixed

- The version-scheme gate no longer fails commits that cannot bump the version.
  A commit touching only documentation or repository metadata produces a
  bit-identical build, and a bot-authored dependency update cannot run the bump
  script at all; both may keep the current version, while one that moves it is
  still validated. The gate now carries its own test cases.

## [0.1.0] - 2026-08-23

### Added

- Flutter application skeleton targeting Android 10+ (API 29) and Linux x86_64.
- Typed `Failure` hierarchy and `Result` type covering every error category in
  Vision.md §55.
- Structured logging with component/provider/operation/duration/error-category
  fields, scoped loggers, bounded in-memory sink for the Data Status screen and
  redaction of credentials and portfolio content.
- `localPipeline.sh`: local quality gate (toolchain, format, analysis, tests,
  Android 10 assertion, both release builds, optional app smoke test).
- GitHub Actions pull-request CI running the same pipeline script.
- README, contribution guide and GPLv3 license.
- Repositories over the local database, exposing streams the UI observes.
- Bundled sample dataset: ten instruments across three currencies with annual,
  quarterly and monthly payers, materialised around the current date so the
  calendar is never empty.
- App icon for Android and Linux: a dachshund fetching a euro coin.
- Tagged release pipeline publishing a raw APK, a Linux tarball, checksums and
  release notes generated from the commit history.
- Application shell: Riverpod, routing, a responsive frame that switches
  between a bottom bar and a navigation rail, and light and dark themes.
- Persisted System, Light and Dark theme selection in Settings, with verified
  WCAG AA semantic-colour contrast and large-text layout coverage.
- Data-source settings with keyless-provider toggles and secure, user-supplied
  API-key storage on Android and Linux; release artifacts now receive their
  source commit for the About screen.
- Configurable per-data-type cache lifetimes, explicit fresh/stale/missing
  resolution, and persisted cache metadata for request coordination.
- Central request coordination with global/provider concurrency limits,
  provider pacing, priorities, typed timeouts, exponential retries,
  in-flight deduplication, cancellation and live operation status.
- Capability-specific market-data provider contracts, a validated registry and
  per-data-type fallback into normalized domain records through the shared
  request coordinator.
- Keyless SEC EDGAR ticker search, CIK resolution, declared dividend-per-share
  facts and filing links, with a declared bot identity, conservative Fair
  Access pacing, fixture contract tests and explicit source provenance.
- Additive database schema 2 fields that preserve SEC reporting periods
  without mislabelling them as ex-, declaration or payment dates.
- Keyless daily FX reference rates through Frankfurter v2, explicitly filtered
  to ECB data, with exact-decimal conversion, local history, a 12-hour cache
  policy, fixture contracts and additive database schema 3 migrations.
- Data Status now shows every source's persistent runtime health, active
  requests, honest cache hit/miss statistics, rate-limit reset times and the
  latest privacy-safe error, while retaining health across offline restarts.
- Explainable dividend-growth analytics aggregate reported payments by
  completed calendar year and calculate period-labelled 3/5/10-year CAGR,
  consecutive no-cut years, and the latest annual increase and decrease.
- A deterministic 24-month dividend forecast detects frequency and payment
  seasonality, prefers the longest available instrument CAGR, preserves
  announced values, marks every generated event as estimated, and explains its
  documented 3% fallback when history is short.
- Instrument search now combines the local database with enabled live
  providers, then supports exact-decimal add-holding and add-to-watchlist
  flows. The portfolio overview shows currency-separated value, day change,
  allocation, forward gross yield and each holding's next dividend without
  treating missing quotes as zero.
- The dividend calendar now provides month, year and agenda views; ex-date and
  payment-date explanations; portfolio, watchlist and all-instrument scopes;
  optional weekend columns; capped busy days with tap/hover detail; explicit
  estimate markers; held gross payments; and an honest display-currency
  selector that does not relabel native amounts before dated FX conversion.
- A dedicated portfolio-income forecast now turns the explainable forecast
  engine into a 24-month monthly, quarterly and annual view. Relative stacked
  bars and a payout table keep paid, confirmed and estimated gross income
  separate; annual share, current-month status, trailing-twelve-month income,
  year-over-year change and per-year cumulative curves remain currency-safe.
- A deterministic Dividend Quality Score now normalizes only across available
  evidence and explains every positive, risk and neutral factor. It covers
  dividend growth, cuts, history, yield, payout, cash-flow coverage, earnings,
  debt and cash-flow trends without penalizing missing fundamentals.
- An explainable German private-share dividend-tax engine now tracks the annual
  savings allowance in payment order and separates source withholding,
  potential and applied foreign-tax credit, reclaimable withholding,
  Kapitalertragsteuer, solidarity surcharge, optional church tax, gross and
  estimated net. A dated, versioned starter table covers DE/US/CH/GB/NL and
  supports country or instrument overrides; unsupported cases are refused.
- Gross and estimated-net amounts are shown together across Today, portfolio,
  calendar and forecast views, with editable tax-profile assumptions and clear
  “estimate, not tax advice” labels.
- Exact multi-currency totals, exposure and display-currency conversion backed
  by dated ECB rates; missing or stale conversion evidence stays visible.
- Today combines portfolio value, relevant dividends, earnings, corporate
  events, filings and publisher-linked news into an explainable ranked view.
- Six-dimension research scoring and per-instrument detail with dividend
  history, evidence coverage, bull/bear cases, change conditions and bounded
  score history.
- Portfolio health insights for position, sector, country, currency and dividend
  income concentration, plus an additional-investment dividend simulator.
- Three-step onboarding, complete loading/empty/error/offline states,
  accessibility and keyboard passes, and opt-in conservative local
  notifications.
- A real Linux integration journey covering holding creation, portfolio,
  calendar, income forecast and offline persistence.
- The same portfolio journey runs on an Android 10/API 29 emulator in CI and
  blocks tag-triggered releases if the phone runtime regresses.
- Release artifact checks for Android and Linux, including APK inspection,
  exact sizes and a rendered Linux first-frame smoke test.
- Weekly Dependabot checks and a non-mutating toolchain freshness report for
  Dart packages, Flutter, AGP, Gradle, Kotlin and GitHub Actions.
- Architecture, provider-policy, research methodology, privacy and release
  documentation.

### Changed

- Android release builds now explicitly request internet access, and the local
  and CI pipeline asserts the permission alongside Android 10 compatibility.
- Product renamed to **DividendenDackel** across the Dart package, Android
  application ID, Linux binary, window titles and documentation.
- The reproducible toolchain is updated to Flutter 3.47.1 / Dart 3.13.1, Android
  Gradle Plugin 9.3.1, Gradle 9.7.1 and Kotlin 2.4.10; direct dependencies are
  pinned to their latest stable compatible releases.

### Fixed

- Notification reconciliation is single-flight across startup, resume and
  settings changes, and distinct same-company dividends on one day no longer
  collide in delivered-event tracking.
