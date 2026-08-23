# Project status

- **Last updated:** 2026-08-23
- **Version:** 0.49.0+80
- **Branch:** `master` (local work ahead of `origin/master`)
- **Pinned toolchain:** Flutter 3.47.1 / Dart 3.13.1
- **Quality gate:** green — 565 tests, Linux integration, Android 10
  compatibility and Android/Linux release builds

## Product state

DividendenDackel is a working local-first desktop and Android application, not a
scaffold. Fresh installs start with an empty personal portfolio; the bundled
reference data keeps discovery and primary screens usable without an account,
API key or network. Keyless SEC EDGAR and Frankfurter/ECB adapters add real US
company facts, filings, dividend history and daily reference FX rates.

Implemented user capabilities:

- responsive Android bottom navigation and Linux navigation rail;
- first-run onboarding and persisted System/Light/Dark themes;
- Today dashboard with ranked portfolio-relevant events and income windows;
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
  assessments with history and bull/bear evidence;
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
storage.

The complete design is in [`architecture.md`](architecture.md). Provider terms,
research methodology, privacy and releases are documented in
[`data-providers.md`](data-providers.md),
[`research-score.md`](research-score.md), [`privacy.md`](privacy.md) and
[`releases.md`](releases.md).

The real portfolio integration journey runs on both Linux and an Android
10/API 29 emulator in CI and in the tag-triggered release workflow.

## Delivery automation

`./localPipeline.sh` is the single local/CI/release gate. It validates the
pinned toolchain, dependency lock, formatting, strict analysis, tests, the real
Linux portfolio journey, `minSdk 29`, release builds and a rendered Linux first
frame. GitHub CI splits the same script into parallel jobs and publishes the
temporary APK and Linux bundle for inspection.

Tag-triggered release automation verifies the tag against `pubspec.yaml`, runs
the full gate, produces a raw APK and Linux tarball, creates SHA-256 checksums,
generates notes from Conventional Commits and publishes a public GitHub Release.
Every third-party action is pinned to an immutable commit SHA and workflows use
minimal permissions.

Dependabot checks pub, Gradle and GitHub Actions weekly. A separate scheduled
report compares the pinned Flutter, Android Gradle Plugin, Gradle and Kotlin
versions with current stable upstream releases without blindly merging them.

## Remaining decisions and release work

The required 0.1.0 backlog is complete and locally tagged. The official Parqet
comparison in [`parqet-comparison.md`](parqet-comparison.md) reprioritized the
post-1.0 queue. The activity ledger, actual-versus-forecast reconciliation,
reviewable CSV and IBKR imports, private calendar export, isolated
multi-portfolio management and explainable cash-flow performance are
implemented. Optional keyed providers, broker credential sync, encrypted
cross-device sync, widgets/tray mode, research history and localization remain
candidates rather than MVP blockers.

Known release limitations:

- the 0.1.0 APK is development/debug-signed, not Play Store signed;
- the release workflow cannot be proven end-to-end until a `v*` tag is pushed;
- an Android API 29 emulator/device is required for the final runtime smoke;
- the dated withholding starter table is an editable estimate and must never be
  presented as current tax advice;
- only SEC EDGAR and Frankfurter/ECB live adapters ship in 0.1.0; optional keyed
  provider entries in Settings do not yet perform requests.

## Working protocol

Each iteration takes the first unchecked backlog task, marks it in progress,
implements and tests it, runs the full gate, self-reviews, marks it complete and
creates one atomic Conventional Commit. The worktree is not intentionally left
with failing checks.
