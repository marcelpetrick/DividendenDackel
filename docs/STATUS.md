# Project status

- **Last updated:** 2026-08-23
- **Version:** 0.1.0+1 release candidate
- **Branch:** `master` (local work ahead of `origin/master`)
- **Pinned toolchain:** Flutter 3.47.1 / Dart 3.13.1
- **Quality gate:** green — 500 tests, Linux integration, Android and Linux
  release builds, Android 10 compatibility

## Product state

DividendenDackel is a working local-first desktop and Android application, not a
scaffold. Its bundled sample data makes every primary flow usable without an
account, API key or network. Keyless SEC EDGAR and Frankfurter/ECB adapters add
real US company facts, filings, dividend history and daily reference FX rates.

Implemented user capabilities:

- responsive Android bottom navigation and Linux navigation rail;
- first-run onboarding and persisted System/Light/Dark themes;
- Today dashboard with ranked portfolio-relevant events and income windows;
- holding/watchlist search and editing, allocation, yield and next dividend;
- portfolio health by holding, sector, country, currency and dividend income;
- additional-investment dividend simulator;
- month/year/agenda dividend calendar with ex/payment date modes, scopes,
  weekend control, busy-day disclosure and attributable held income;
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

The app uses Drift/SQLite schema 4 as its local source of truth. Provider
responses are normalized and persisted before repository streams update the UI.
All money and FX arithmetic is exact-decimal. Explicit additive migrations
preserve portfolio data from schemas 1, 2 and 3.

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

The authoritative queue is [`BACKLOG.md`](BACKLOG.md). Required 0.1.0 work after
this documentation pass is the final Android 10/Linux/migration smoke audit and
local `v0.1.0` tag. Optional keyed provider adapters are deliberately not
required for the keyless MVP. Phase 6 ideas—imports, multiple portfolios, sync,
widgets/tray mode, research history and localization—are post-1.0 candidates
unless the product comparison changes their priority.

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
