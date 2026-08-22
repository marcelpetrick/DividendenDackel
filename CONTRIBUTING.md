# Contributing to DividendenDackel

Thanks for looking at the Dackel. This document describes what a change has to
satisfy before it can be merged.

## Toolchain

| Tool | Version |
| --- | --- |
| Flutter | **3.44.7** (stable) |
| Dart | 3.12.2 (ships with that Flutter) |
| Java | 17 (Android builds) |

The Flutter version is pinned deliberately (Vision.md §70). It appears in
`localPipeline.sh` (`PINNED_FLUTTER_VERSION`) and in
`.github/workflows/ci.yml` (`FLUTTER_VERSION`) — change both together.

## Setup

```sh
flutter pub get
```

Linux desktop builds additionally need:

```sh
clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev libsecret-1-dev libjsoncpp-dev
```

## The quality gate

Run the same script CI runs:

```sh
./localPipeline.sh --noRun            # full gate, no app launch
./localPipeline.sh --noRun --stage quality
```

It must end with every mandatory stage `PASS`. The individual commands are:

```sh
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
```

Static analysis is strict on purpose. Do not silence a warning with an
`ignore:` comment unless the diff explains why the rule is wrong here.

## Commits

Commits follow [Conventional Commits](https://www.conventionalcommits.org/) and
must be **atomic** — one logical change each (Vision.md §63, §64).

```text
feat(calendar): add payment-date toggle
fix(cache): prevent duplicate provider requests
test(research): cover five-year CAGR calculation
```

Do not combine a feature, a dependency bump, a reformat and an unrelated fix in
one commit. If two changes can be understood or reverted independently, they are
two commits.

Types in use: `feat`, `fix`, `refactor`, `test`, `docs`, `ci`, `build`, `chore`,
`perf`. Breaking changes are marked per the specification.

## Definition of Done

A feature is not done because it renders (Vision.md §87):

- requirement implemented
- Android behaviour considered
- Linux behaviour considered
- loading, empty, error and offline states
- tests added or updated
- format, analyze and tests pass
- diff self-reviewed
- documentation updated if needed
- atomic Conventional Commit created

## Android 10 compatibility

`minSdk` must stay **29**. This is a product requirement (Vision.md §4.1, §58),
and both `localPipeline.sh` and CI assert it mechanically. If a dependency
forces it higher, that is a discussion, not a silent bump.

## Data providers

A provider adapter may not be merged until `docs/data-providers.md` documents,
for that provider (Vision.md §47):

```text
Free usage allowed?      Client-side usage allowed?
Caching allowed?         Redistribution allowed?
Attribution required?    Rate limit?
Retention limit?         Commercial-use restrictions?
API-key restrictions?
```

Every adapter needs fixture-based contract tests: a recorded upstream response
in, a normalized domain model out (Vision.md §77). Upstream APIs change; the
fixtures are how we notice.

**Never commit an API key.** Keys are supplied by the user at runtime and stored
locally (Vision.md §34).

## Pull requests

CI must be green. A pull request that fails formatting, analysis, tests or
either platform build does not merge (Vision.md §68, §74).
