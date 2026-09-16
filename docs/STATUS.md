# Project status

- **Last updated:** 2026-09-16
- **Version:** 0.65.8+128
- **Branch:** `master`
- **Pinned toolchain:** Flutter 3.47.4 / Dart 3.13.3
- **Quality gate:** green — 683 tests, 10 compiled Linux journeys, 10 compiled
  Android 10 journeys and Android/Linux release builds

## Product state

DividendenDackel is a working local-first desktop and Android application, not a
scaffold. Fresh installs start with an empty personal portfolio; the bundled
reference data keeps discovery and primary screens usable without an account,
API key or network. Keyless SEC EDGAR and Frankfurter/ECB adapters add real US
company facts, filings, dividend history and daily reference FX rates.

Implemented user capabilities:

- responsive Android bottom navigation and Linux navigation rail;
- first-run onboarding, persisted System/Light/Dark themes and live persisted
  English/German/Croatian language selection;
- scan-first Today dashboard with separate native-currency KPIs, ranked
  portfolio-relevant events and a responsive income layout;
- holding/watchlist search and editing, allocation, yield and next dividend;
- multiple local portfolios with create, rename, clear and protected delete,
  persistent selection and an explicit read-only consolidated view;
- per-portfolio display currency and tax assumptions, with no cross-portfolio
  net-tax calculation;
- immutable purchase, sale and cash-flow activities with reversal-based
  corrections and expected-versus-actual dividend reconciliation;
- explainable native-currency XIRR and valuation-chain TTWROR, with exact
  monthly/quarterly/annual cash-flow detail and explicit evidence limits;
- review-first local DividendenDackel and Portfolio Performance CSV import with
  validation, duplicate detection, atomic apply, batch history and undo;
- direct Interactive Brokers Flex CSV support for stock trades, commissions,
  taxes, dividends and cash movements, with unsafe rows refused;
- portfolio health by holding, sector, country, currency and dividend income;
- additional-investment dividend simulator;
- month/year/agenda dividend calendar with ex/payment date modes, scopes,
  weekend control, busy-day disclosure and attributable held income;
- private local `.ics` snapshots of the active calendar filters, with
  deterministic identities and estimates marked for calendar clients;
- 24-month monthly/quarterly/yearly income forecast, paid/confirmed/estimated
  separation, TTM and year-over-year comparisons;
- explainable dividend growth, forecast, quality and six-dimension research
  assessments with lazy comparison previews, history and bull/bear evidence;
- exact display-currency conversion with dated ECB provenance;
- explainable gross/net German dividend-tax estimates and editable assumptions;
- provider settings, health, active jobs, cache status and privacy-safe errors;
- loading, empty, stale, offline and error states throughout;
- keyboard/focus/semantics support and large-text coverage;
- disabled/important/all local notification modes with conservative wording.

## Engineering state

The app uses Drift/SQLite schema 7 as its local source of truth. Provider
responses are normalized and persisted before repository streams update the UI.
All money and FX arithmetic is exact-decimal. Explicit additive migrations
preserve portfolio data from schemas 1 through 6.

The request coordinator enforces global and per-provider concurrency, pacing,
priorities, deadlines, bounded exponential retries, deduplication and
cancellation. Cache policy supports stale-while-revalidate so network failures
do not erase useful local data. Logs omit portfolio contents and credentials;
optional credentials use Android Keystore-backed or Linux Secret Service-backed
storage. Application translations are bundled and work offline; the language
preference is stored locally and updates both application and platform UI
without restarting.

The complete design is in [`architecture.md`](architecture.md). Provider terms,
research methodology, privacy and releases are documented in
[`data-providers.md`](data-providers.md),
[`research-score.md`](research-score.md), [`privacy.md`](privacy.md) and
[`releases.md`](releases.md).

The compiled application journeys cover every declared route on Linux. The
portfolio journey also runs on an Android 10/API 29 emulator in CI and in the
release workflow; a mechanical audit fails if a route lacks journey coverage.

## Delivery automation

`./localPipeline.sh` is the single local/CI/release gate. It validates the
pinned toolchain, dependency lock, formatting, strict analysis, tests, the real
Linux portfolio journey, `minSdk 29`, release builds and a rendered Linux first
frame. GitHub CI splits the same script into parallel jobs and publishes the
temporary APK and Linux bundle for inspection.

Release automation verifies the tag against `pubspec.yaml`, runs the full gate,
produces a raw APK, Linux AppImage and Linux tarball, creates SHA-256 checksums,
generates notes from Conventional Commits and publishes a public GitHub Release.
Every third-party action is pinned to an immutable commit SHA and workflows use
minimal permissions.

Dependabot checks pub, Gradle and GitHub Actions weekly. A separate scheduled
report compares the pinned Flutter, Android Gradle Plugin, Gradle and Kotlin
versions with current stable upstream releases without blindly merging them.

## Remaining decisions and release work

The required MVP backlog is complete. The official Parqet
comparison in [`parqet-comparison.md`](parqet-comparison.md) reprioritized the
post-1.0 queue. The activity ledger, actual-versus-forecast reconciliation,
reviewable CSV and IBKR imports, private calendar export, isolated
multi-portfolio management and explainable cash-flow performance are
implemented. Optional keyed providers, broker credential sync, encrypted
cross-device sync, widgets/tray mode and research history remain
candidates rather than MVP blockers.

Known release limitations:

- release APKs are development/debug-signed, not Play Store signed;
- live Alpha Vantage/Finnhub responses require maintainer-supplied keys and
  could not be verified in this checkout;
- Financial Modeling Prep remains blocked on its required licensing review;
- the dated withholding starter table is an editable estimate and must never be
  presented as current tax advice;
- Linux screenshots are unsupported by Flutter's integration-test plugin, so
  compositor, window-manager and HiDPI behavior remain outside the journey.

## Working protocol

Each iteration takes the first unchecked backlog task, marks it in progress,
implements and tests it, runs the full gate, self-reviews, marks it complete and
creates one atomic Conventional Commit. The worktree is not intentionally left
with failing checks.
