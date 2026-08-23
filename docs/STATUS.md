# Project status

**Living document.** Updated at the end of every work iteration so anyone —
including a future session — can pick up without re-reading the whole history.

- **Last updated:** 2026-08-23
- **Version:** 0.1.0+1 (pre-release, `0.x.y`)
- **Branch:** `master` (local work ahead of `origin`)
- **Quality gate:** green — 447 tests, analyzer clean, both platforms build

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

The core portfolio, calendar and 24-month income forecast are functional. Today
combines portfolio value, dividend income, earnings, company events and
attributable headlines from the local cache, ranked by disclosed relevance
factors.

### Done

| Area | Task | State |
| --- | --- | --- |
| Flutter app, Android + Linux | — | both build in release (APK 59 MB, bundle 29 MB) |
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
| Persistent provider health + live Data Status | F12 | done |
| Dividend CAGR + cut history analytics | D1 | done |
| Deterministic dividend forecast engine | D2 | done |
| Instrument add flows + portfolio overview | D3 | done |
| Month/year/agenda dividend calendar | D4 | done |
| 24-month dividend income forecast | D5 | done |
| Explainable Dividend Quality Score | D6 | done |
| Explainable German dividend-tax model | D8 | done |
| Display-currency conversion and exposure | D7 | done |
| Gross and estimated-net income UI | D9 | done |
| Offline-capable Today dashboard | T1 | done |
| Earnings and corporate events | T2 | done |
| News metadata, categories and publisher links | T3 | done |
| Explainable Today relevance ranking | T4 | done |
| Six-dimension explainable research score | T5 | done |

### What is left

Ordered by what unblocks a usable app soonest.

| Next | Task | Why it matters |
| --- | --- | --- |
| 1 | **T6** research detail | Surface the assessment and evidence per asset. |
| 2 | **Q1–Q9** quality | Harden offline behavior, accessibility and performance. |

Then:
Q1–Q7 offline, states, accessibility, health, simulator, onboarding,
notifications · R2 dependency workflows · R4b remaining docs ·
R5 optional keyed providers · R6 release readiness · S1 self-review ·
Phase 6 post-1.0.

Full detail in [`BACKLOG.md`](BACKLOG.md).

## 3. Immediate goal

**A working, installable Android APK plus a Linux build that visibly does
something useful, driven by bundled sample data and needing no API key.**

The APK and Linux bundle already build and open onto populated sample-driven
screens. The remaining backlog deepens news, research and release quality.

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
- **Database schemas 2, 3 and 4 are additive.** Version 2 adds nullable dividend
  reporting-period columns, version 3 adds exact daily FX rows, and version 4
  adds scheduled corporate events. Tested upgrades preserve existing rows.
- **FX rates stay exact and attributable.** Frankfurter v2 requests are always
  filtered to `providers=ECB`; rows store decimal text, UTC reference dates and
  provenance. Range translation preserves the domain's half-open convention,
  and conversion rounds only at the final display boundary.
- **Provider diagnostics persist without sensitive data.** Coordinator
  outcomes update provider health, last request, rate-limit reset and a safe
  user-facing error in SQLite. Active jobs remain live-only; cache hit rates
  stay explicitly unavailable until a real lookup records a hit or miss.
- **Dividend growth uses completed reported years.** Confirmed and announced
  facts are aggregated per share by calendar year; estimates and the partial
  current year are excluded. CAGR is emitted only when every year in its
  3/5/10-year window exists and both endpoints are positive, and every result
  carries its period and comparison years.
- **Forecasts are deterministic and labelled.** Payment seasonality supplies
  the 24-month schedule, provider-announced events always win, and generated
  rows use `historicallyEstimated`. Growth uses the longest available standard
  CAGR or the disclosed 3% fallback; irregular and undated histories produce a
  limitation instead of invented dates. Full rules are in
  [`dividend-forecast.md`](dividend-forecast.md).
- **Portfolio totals remain separated by currency until D7.** Value, day
  change, forward dividend income and allocation are calculated per currency;
  missing quotes make the affected aggregate explicitly incomplete instead of
  contributing a fabricated zero. Search combines local-first results with
  enabled providers and persists a selected live instrument before the user's
  holding or watchlist row.
- **The calendar queries only the visible range and selected collection.** Its
  month, year and rolling agenda modes organize events by either ex-date or
  payment date, and unknown dates remain unplaced. Busy days disclose details
  progressively; confirmed and estimated events use words plus shape/letter
  markers. Year totals are held gross payments separated by currency—not sums
  of unrelated per-share amounts. Selecting a future display currency never
  relabels native money before D7 can supply an attributable daily FX rate.
- **Income forecasts remain certainty- and currency-separated.** D5 merges
  events found by ex-date or payment date, runs D2 per held instrument and
  applies today’s quantities to a 24-month cash timeline. Monthly, calendar
  quarter and annual buckets expose paid-date-passed, confirmed-upcoming and
  estimated components; TTM comparisons use reported payments only. The UI
  states that this is not broker reconciliation and shows every instrument’s
  rule-based explanation or limitation.
- **Dividend quality is normalized over known evidence only.** D6 emits no
  score without completed reported history and never turns an unavailable
  fundamental into a zero. The factor weights, thresholds and limitations are
  documented in [`dividend-quality-score.md`](dividend-quality-score.md), and
  every score carries its positive, risk and neutral explanations.
- **Tax estimates are ordered, explicit and deliberately limited.** D8 models
  German private-share taxation only, consumes one editable EUR allowance in
  payment order, uses the §32d church-tax/foreign-credit formula, and keeps
  withheld, creditable, actually applied and reclaimable amounts distinct.
  Foreign gross must first be converted to EUR with explicit FX evidence; an
  unsupported residence or unknown source country produces no invented net.
  The bundled table is dated 2024 and therefore visibly reviewable rather than
  silently presented as current. Full limits are in
  [`dividend-taxation.md`](dividend-taxation.md).
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
- **Sample data is generated from patterns, not fixed dates**, so dividend,
  earnings and corporate-event views stay populated whenever the app runs, and
  generated dividend history grows year on year so CAGR is computable.
- **Today relevance is deterministic and inspectable.** Held positions,
  attributable holding weight, information type, timing and confirmation each
  contribute disclosed points. Unrelated items are excluded, ties use stable
  ordering, and every visible score shows all of its reasons.
- **Research scores normalize only known evidence.** Valuation, quality,
  growth, momentum, dividend and event-risk dimensions are independently
  explainable; missing metrics and dimensions never become zero. Overall
  weights are renormalized over available dimensions and coverage is disclosed.
  Thresholds and limitations are recorded in
  [`research-score.md`](research-score.md).
- **Dividends will be shown gross *and* net**, with withholding, treaty cap and
  German tax modelled as an explainable estimate — see
  [`dividend-taxation.md`](dividend-taxation.md).

## 6. Known issues and follow-ups

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
