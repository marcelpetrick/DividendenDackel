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

### Changed

- Product renamed to **DividendenDackel** across the Dart package, Android
  application ID, Linux binary, window titles and documentation.
