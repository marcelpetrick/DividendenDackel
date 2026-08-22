# Changelog

All notable changes to DividendenDackel are documented here.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/)
(Vision.md §60, §75).

## [Unreleased]

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

### Changed

- Android release builds now explicitly request internet access, and the local
  and CI pipeline asserts the permission alongside Android 10 compatibility.

- Product renamed to **DividendenDackel** across the Dart package, Android
  application ID, Linux binary, window titles and documentation.
