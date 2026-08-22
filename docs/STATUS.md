# Project status

**Living document.** Updated at the end of every work iteration so anyone —
including a future session — can pick up without re-reading the whole history.

- **Last updated:** 2026-08-22
- **Version:** 0.1.0+1 (pre-release, `0.x.y`)
- **Branch:** `master` (local work ahead of `origin`)
- **Quality gate:** green — 326 tests, analyzer clean, both platforms build

---

## 1. What this is

DividendenDackel — a local-first dividend and portfolio-event companion for
Android 10+ and Linux x86_64. Full specification in [`Vision.md`](../Vision.md);
task queue in [`BACKLOG.md`](BACKLOG.md); working rules in
[`CLAUDE.md`](../CLAUDE.md).

## 2. Where we are

**The app is real.** `flutter run -d linux` now opens DividendenDackel: four
sections (Today, Calendar, Portfolio, Research), a responsive frame that
switches between a bottom bar and a navigation rail, light and dark themes,
Settings, About with the version, and a Data Status screen. Sample data is
seeded on first launch, so the screens are populated with no API key.

The screens are functional but thin — real calendar views, forecasts and the
Today ranking land with D3–D5 and T1.

### Done

| Area | Task | State |
| --- | --- | --- |
| Flutter app, Android + Linux | — | both build in release (APK 58 MB, bundle 28 MB) |
| `minSdk 29` pinned and asserted in CI | — | done |
| Strict static analysis | B3 | done |
| Local pipeline + PR CI + release pipeline | R1, R3 | done |
| README, LICENSE, CONTRIBUTING, CHANGELOG | R4a | done |
| Typed `Failure` + `Result` | F1 | done |
| Structured logging with redaction | F2 | done |
| Domain entities and value objects | F3 | done |
| SQLite schema + migration safety | F4 | done |
| Repositories over the database | F5 | done |
| Bundled sample dataset | F9 | done |
| App icon, both platforms | Q8 | done |
| Application shell, themes, navigation | F10 | done |
| Persisted System/Light/Dark selection | Q10 | done |
| Secure provider settings + build identity | F11 | done |
| Cache TTL policy + metadata repository | F6 | done |
| Bounded, deduplicating Request Coordinator | F7 | done |
| Provider contracts, registry + fallback chain | F8 | done |
| Keyless SEC EDGAR adapter | F8a | done |
| Keyless Frankfurter/ECB FX adapter | F8b | done |

### What is left

Ordered by what unblocks a usable app soonest.

| Next | Task | Why it matters |
| --- | --- | --- |
| 1 | **F12** Data Status | Provider health, operations and cache visibility. |
| 2 | **D1/D2** dividend analytics | CAGR and an explainable forecast engine. |
| 3 | **D3–D5/T1** core UI | Portfolio, calendar, forecast and Today. |
| 4 | **E1/E2** delivery proof | End-to-end flows and artifact launch verification. |
| 5 | **D6–D9** deeper portfolio data | Quality, currency and gross/net tax. |

Then: D6 quality score · D7 currency · **D8/D9 gross-and-net tax** ·
T2–T6 events, news, research ·
Q1–Q7 offline, states, accessibility, health, simulator, onboarding,
notifications · R2 dependency workflows · R4b remaining docs ·
R5 optional keyed providers · R6 release readiness · S1 self-review ·
Phase 6 post-1.0.

Full detail in [`BACKLOG.md`](BACKLOG.md).

## 3. Immediate goal

**A working, installable Android APK plus a Linux build that visibly does
something useful, driven by bundled sample data and needing no API key.**

The APK and Linux bundle already build and open onto populated sample-driven
screens. D3 through T1 turn those thin read-only screens into the core product.

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
- **Cache expiry is explicit and testable.** Every data category has a default
  TTL inside the Vision.md range, policies accept per-category overrides, and
  the resolver treats the exact expiry instant as stale while preserving the
  cached payload for stale-while-revalidate.
- **All provider work goes through one coordinator.** It applies global and
  per-provider concurrency, start spacing, typed deadlines, bounded
  exponential retry, high/medium/low priority, in-flight deduplication and
  per-subscriber cancellation. Retry backoff releases capacity and retry
  attempts re-enter the same scheduler, so they cannot bypass limits.
- **Provider capabilities are contracts, not flags alone.** Registry creation
  rejects adapters that advertise an interface they do not implement, applies
  per-data-type priority and enablement, and uses the coordinator for typed,
  ordered fallback into normalized domain records.
- **SEC reporting periods are not dividend event dates.** EDGAR's declared
  dividend-per-share fact is normalized with explicit reporting-period fields;
  ex-date, declaration date and payment date stay null. Annual facts supersede
  overlapping quarters so totals are not double-counted.
- **Database schemas 2 and 3 are additive.** Version 2 adds nullable dividend
  reporting-period columns; version 3 adds exact daily FX rows. Tested 1→3 and
  2→3 migrations preserve existing data.
- **FX rates stay exact and attributable.** Frankfurter v2 requests are always
  filtered to `providers=ECB`; rows store decimal text, UTC reference dates and
  provenance. Range translation preserves the domain's half-open convention,
  and conversion rounds only at the final display boundary.
- **A malformed stored amount fails loudly** as a `ParsingFailure` rather than
  parsing to something plausible.
- **Value objects live in `lib/domain/value_objects/`**, a refinement of the
  layout Vision.md §53 recommends.
- **No API keys in the repo or the built app.** Two genuinely keyless public
  sources — SEC EDGAR for real dividend history and filings, Frankfurter/ECB
  for FX — are the default tier, so the app ships with real data and no user
  setup. Keyed providers are an opt-in upgrade. The app will not provision a
  secret credential on the user's behalf; embedding one would not keep it
  secret (Vision.md §34).
- **Optional API keys use platform-secure storage.** Android uses a
  Keystore-backed implementation and Linux uses Secret Service; enable flags
  are the only provider settings stored in plain preferences. Android app
  backup is disabled so encrypted values cannot be restored without their
  device-bound key.
- **Sample data is generated from patterns, not fixed dates**, so the calendar
  is populated whenever the app runs, and the generated history actually grows
  year on year so dividend CAGR has something real to compute.
- **Dividends will be shown gross *and* net**, with withholding, treaty cap and
  German tax modelled as an explainable estimate — see
  [`dividend-taxation.md`](dividend-taxation.md).

## 6. Known issues and follow-ups

- Screens are functional but minimal; the calendar is an agenda list and the
  Today ranking is not implemented yet.
- Widget tests run without a database on purpose: drift's stream machinery
  outlives the widget tree and the test binding reports it as a pending timer.
  The data layer is covered by its own tests.
- SEC EDGAR is registered and ready for live ticker search, dividend facts and
  filings. The UI/background stale-while-revalidate workflow that persists and
  surfaces live refreshes is still due in D3 and Q1.
- The withholding tax table in `dividend-taxation.md` is a design sketch; the
  rates must be verified against the BZSt publication before release.
- The release workflow has never run. It is written and validated but unproven
  until the first `v*` tag is pushed.
- `build_runner` is pinned to 2.15.1; 2.16.0 conflicts with the pinned Flutter
  SDK's constraints. Recheck on the next SDK bump.
- Generated `*.g.dart` files are committed so CI needs no codegen step. They
  must be reformatted with `dart format .` after regeneration.

## 7. Working protocol

Each iteration: take the first unchecked task in `BACKLOG.md`, implement it,
run the gate until green, self-review, tick the box, and make one atomic
Conventional Commit. Never leave the tree with failing checks. Update this file
when the picture changes.
