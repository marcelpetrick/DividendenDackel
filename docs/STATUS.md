# Project status

**Living document.** Updated at the end of every work iteration so anyone —
including a future session — can pick up without re-reading the whole history.

- **Last updated:** 2026-08-22
- **Version:** 0.1.0+1 (pre-release, `0.x.y`)
- **Branch:** `master` (pushed to `origin`)
- **Quality gate:** green — `./localPipeline.sh --noRun` passes, 199 tests

---

## 1. What this is

DividendenDackel — a local-first dividend and portfolio-event companion for
Android 10+ and Linux x86_64. Full specification in [`Vision.md`](../Vision.md);
task queue in [`BACKLOG.md`](BACKLOG.md); working rules in
[`CLAUDE.md`](../CLAUDE.md).

## 2. Where we are

**Foundation phase.** The engineering substrate is built and tested; the
product UI is not yet. `flutter run -d linux` currently still shows the Flutter
counter demo — that is replaced in task **F10**.

Done so far:

| Area | State |
| --- | --- |
| Flutter app, Android + Linux targets | done, both build in release |
| `minSdk 29` / `targetSdk 36` pinned + asserted in CI | done |
| Strict static analysis | done |
| Local pipeline + GitHub Actions CI | done |
| README, LICENSE, CONTRIBUTING, CHANGELOG | done |
| Typed `Failure` + `Result` (F1) | done |
| Structured logging with redaction (F2) | done |
| Domain entities and value objects (F3) | done |
| SQLite schema + migration safety (F4) | done |
| Repositories over the database (F5) | done |
| Bundled sample data (F9) | **next** |
| Everything else | see BACKLOG |

## 3. Immediate goal

**A working, installable Android APK plus a Linux build that visibly does
something useful, driven by bundled sample data and needing no API keys.**

The backlog was reordered for this: repositories → sample data → app shell →
portfolio/calendar/Today. The Request Coordinator and live provider adapters
(F6–F8) come *after* that, because they are not needed for a usable app and
would otherwise delay one.

Path to the goal:

```text
F9  sample data         →  a realistic portfolio with no API key
Q8  app icon            →  a Dackel fetching a coin, on both platforms
F10 app shell           →  navigation, themes; app stops looking like a demo
D3  portfolio           →  holdings, search, add
D4  dividend calendar   →  month/year/agenda, ex-date vs payment toggle
D5  monthly forecast    →  income per month
T1  Today screen        →  the actual product experience
E1  end-to-end tests    →  integration_test over the real flows
E2  release verification→  APK + Linux bundle launched and checked
```

## 4. How to build and check

```sh
./localPipeline.sh --noRun              # full gate: format, analyze, test, both builds
./localPipeline.sh --noRun --stage quality
./localPipeline.sh --selfTest           # verify the gate itself reports failures
./localPipeline.sh                      # includes a Linux app launch smoke test

flutter run -d linux
flutter build apk --release             # build/app/outputs/flutter-apk/app-release.apk
flutter build linux --release           # build/linux/x64/release/bundle/dividendendackel
```

After changing a Drift table, regenerate and reformat:

```sh
dart run build_runner build
dart format .
```

## 5. Decisions worth knowing

- **Money is never a float.** `Money` = exact `Decimal` + `Currency`; the
  database stores amounts as decimal *text*. Mixing currencies throws.
- **Timestamps are ISO-8601 text**, not Unix seconds, so calendar-day grouping
  across timezones stays unambiguous.
- **Enums persist by name**, so reordering one cannot rewrite stored history.
- **Holdings do not cascade-delete.** Market data does. A provider refresh can
  never remove the user's portfolio (Vision.md §76).
- **Missing data yields `null`, never a placeholder.** No cost basis without a
  purchase price, no EPS surprise without both numbers.
- **Scores cannot exist without their explanation** — `ScoredAssessment`
  rejects an empty factor list at construction.
- **Db-prefixed row classes** keep persistence rows from shadowing domain
  entities.
- **Repositories expose streams**, because the UI observes the database, not
  provider responses. Writes return `Result`, reads return streams.
- **A malformed stored amount fails loudly** as a `ParsingFailure` rather than
  parsing to something plausible.
- **Value objects live in `lib/domain/value_objects/`**, a refinement of the
  layout Vision.md §53 recommends.
- **No API keys in the repo or the built app.** Keys are user-supplied and
  stored locally; the app is designed to be fully usable without any.

## 6. Known issues and follow-ups

- `lib/main.dart` is still the generated counter demo (fixed by F10).
- No provider adapters yet, so nothing fetches live data (F8, R5).
- `build_runner` is pinned to 2.15.1; 2.16.0 conflicts with the pinned Flutter
  SDK's constraints. Recheck on the next SDK bump.
- Generated `*.g.dart` files are committed so CI needs no codegen step. They
  must be reformatted with `dart format .` after regeneration.

## 7. Working protocol

Each iteration: take the first unchecked task in `BACKLOG.md`, implement it,
run the gate until green, self-review, tick the box, and make one atomic
Conventional Commit. Never leave the tree with failing checks. Update this file
when the picture changes.
