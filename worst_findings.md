# Engineering self-review

## 0.65.9 release verification review

Base: `6d91da2` / public `v0.65.8`<br>
Review date: 2026-09-16

### Findings

#### 1. HIGH Data safety — Android upgrade guidance

Release APKs use an ephemeral debug signing key, so a later release may not be
accepted as an in-place update. Uninstalling to bypass that mismatch would
delete the local portfolio and credentials, and the CSV format is not a
lossless full-database backup. The release guide and generated/public release
notes now warn against destructive reinstall attempts and state the unresolved
persistent-signing requirement. A regression protects the generated warning.

#### 2. MEDIUM Delivery — published artifact evidence

Workflow success alone did not establish that the public tag and downloads
matched the tested release candidate. The public release flags and tag target
were checked independently; all four assets downloaded, all three artifact
hashes match `SHA256SUMS`, the Linux formats have the expected executable
payloads, and `apksigner` confirms the APK has one Android Debug certificate.

### Verdict

E4 has no unresolved implementation or publication defect. Reliable Android
in-place upgrades remain an explicit maintainer decision because they require a
persistent private signing identity and reviewed backup/upgrade strategy; no
key was generated or committed as part of this verification.

## 0.65.8 Android currency evidence review

Base: `a612b11`<br>
Review date: 2026-09-16

### Findings

#### 1. MEDIUM Code — gross/net currency labels

Held amounts used symbols alone, so `$` did not explicitly identify USD and
converted EUR net could be compared with native gross without clear units.
Fixed by appending the exact currency code when a symbol is present, while
preserving code-only currencies without duplication. Existing localized label
patterns and all calculation/FX provenance paths remain unchanged.

#### 2. MEDIUM Code — unrelated desktop evidence in the journey

The global USD finder could match desktop currency controls, while the API 29
phone collapsed those controls and had no USD text to find. Reproduced on the
local API 29 Pixel, then fixed by locating the held USD `GrossNetAmount` and
asserting its descendant labels rather than unrelated controls.

### Verdict

Five widget regressions cover English/German/Croatian, unavailable EUR FX and
currencies without a symbol. All ten compiled Android 10 journeys pass locally.
The full rendered pipeline also passes all 683 tests, Linux journeys, platform
builds and the Linux first-frame smoke check. Final CI must pass before any
public release.

## 0.65.5 documentation and release review

Base: `v0.61.8` (`659aa53`)<br>
Review date: 2026-09-15

### Findings

#### 1. HIGH Compliance — Finnhub retained-data removal

The provider review still said that Finnhub stated no retention limit. Its
current terms require subscribed data to be deleted when access ends, while
removing the key left cached quotes and freshness records in SQLite. The terms
record is corrected, and `09c87b0` now purges only Finnhub-sourced quote data
before deleting the credential; failure retains the key and reports the error.

#### 2. MEDIUM Documentation — live providers and route evidence

README, architecture and privacy text still described Alpha Vantage and
Finnhub as future adapters, omitted keyless OpenFIGI, and reported 14 routes
after `/portfolio/add` became the fifteenth. The provider inventory, privacy
table, route matrix, current version and 678-test count now match the code and
the final gate.

#### 3. MEDIUM Documentation — release workflow

The release guide said manual dispatch could republish an existing tag and its
primary artifact table omitted the AppImage. The actual workflow refuses an
existing tag, creates a new tag on the exact tested commit and publishes an
APK, AppImage, Linux archive and checksums. The guide now states that behavior.

#### 4. LOW Documentation — Markdown structure

The repository had malformed review headings, unlabeled code fences, bare
reference URLs, inconsistent Vision heading levels and no project Markdown
configuration. These are corrected, all 25 tracked Markdown files pass
`markdownlint-cli2`, and every local link target and 49 external link targets
were checked.

### Verdict

No unresolved documentation, provider-retention or release-process mismatch
remains. The only unreachable direct HTTP checks were SEC pages that reject a
generic command-line user agent; the same pages were independently readable
through the web index and still state keyless APIs and a ten-request-per-second
fair-access ceiling.

## 0.65 UI/UX specialist review

Base: released `659aa53` plus the final audit changes<br>
Review date: 2026-09-15

### Findings

#### 1. HIGH UI `lib/features/today/today_screen.dart`

First run ended on an information-dense empty dashboard without an obvious
route to value. Fixed with a financially honest first-holding prompt wired to
the real add-instrument flow and covered by a compiled route journey.

#### 2. HIGH UI `lib/features/today/today_screen.dart`

Portfolio value, near-term events and daily movement previously shared ordinary
body hierarchy, while Linux retained one long column. Fixed with separate
native-currency KPI tiles, tabular figures and responsive bounded columns.

#### 3. MEDIUM UI `lib/features/research/research_screen.dart`

Research concealed whether an assessment or supporting evidence existed. Fixed
with explicit score and dimension previews, permanent non-recommendation copy
and a missing-evidence state that is never represented as zero.

#### 4. MEDIUM Architecture `lib/features/research/research_screen.dart`

The first adaptive Research grid eagerly built every instrument and could start
an unbounded set of cached assessment computations. Fixed with lazy list/grid
slivers and a 100-instrument regression that proves off-screen work stays idle.

#### 5. MEDIUM UI `lib/features/calendar/calendar_screen.dart`

Calendar navigation and secondary configuration had equal prominence, delaying
the schedule on phones. Fixed with a primary period/view band and a collapsed,
readable filter summary that preserves every detailed control.

### Verdict

No high- or medium-priority defect remains in the reviewed UI scope. Phone,
wide desktop, keyboard, dark theme, 200% text, empty/error/offline states,
mixed currencies, localization and platform builds are covered by the final
automated gate.

## 0.61.8 release-readiness review

Base: `origin/master` (`f3a6016`)<br>
Head reviewed: `b67a532` plus the Android journey fix<br>
Review date: 2026-09-13

### Findings

#### 1. MEDIUM Code `lib/features/today/today_screen.dart`

The expanded valuation journey exposed "1 holdings" on Today. Fixed with an
explicit singular in English, German and Croatian plus widget and compiled
integration regressions.

#### 2. MEDIUM Test architecture `integration_test/portfolio_journey_test.dart`

Six of fourteen routes, including Research, Data status and the provider setup,
had no compiled application coverage. Fixed with deterministic core, financial
and system journeys and a mechanical audit that fails when a declared route has
no journey marker.

#### 3. MEDIUM Test architecture `integration_test/journeys/system_journeys.dart`

The settings journey stopped after finding the About row because its centre was
still below the Android phone's hit-testable viewport. Fixed by explicitly
bringing the About and changelog controls fully on screen before tapping them;
the API 29 CI journey is the regression evidence.

#### 4. LOW Documentation `docs/STATUS.md`

The status page lagged the current version/test count and still described
Alpha Vantage and Finnhub as disconnected. Corrected to match the implemented
providers, expanded journey gate and current release artifacts.

### Verdict

Mergeable after these fixes. The branch review found no remaining Code or
Architecture defect; the complete release gate is green, and live keyed-provider
responses are recorded separately as unverified because no credential is
available in this checkout.

---

## Phase 6 P5 portfolio-performance review

Base: P3 (`9e1e211`)<br>
Review date: 2026-08-23

### Findings

#### 1. HIGH Architecture `lib/data/repositories/drift_portfolio_repository.dart`

A backdated position activity could leave newer valuation snapshots in place,
allowing TTWROR to consume totals derived before the corrected holding existed.
Fixed by invalidating portfolio and consolidated valuations from the economic
activity date inside the same transaction. Reversals invalidate from the
original activity date, and a regression proves earlier valid evidence remains.

#### 2. HIGH Code `lib/domain/analytics/portfolio_performance.dart`

The first calculation path could label today's holdings with an older quote
date and could adjust a cash flow across a sparse TTWROR interval without
knowing its timing. Fixed by refusing current valuation evidence after any
later position change and requiring a complete valuation on every security
cash-flow day inside the TTWROR window. Both refusal paths have unit coverage.

#### 3. MEDIUM Code `lib/features/portfolio/performance_card.dart`

If current instrument metadata was temporarily unavailable, a holding whose
currency was still evident from its purchase could be mistaken for a sold-out
zero balance. Fixed by correlating ledger currency with every current holding
identity before deciding that zero is complete; widget coverage verifies the
unpriced-position limitation remains visible.

### Verdict

P5 passes the complete local/CI/release gate. Native currencies remain separate,
money and persisted values stay exact-decimal, XIRR uses a coherent terminal
valuation date, TTWROR uses only defensible valuation segments, and benchmark
comparison is explicitly unavailable without like-for-like history. All 565
tests, the real Linux journey, Android 10 compatibility, both release builds
and a rendered Linux first frame pass.

---

## Phase 6 P3 calendar-export review

Base: P6 (`ea76c6c`)<br>
Review date: 2026-08-23

### Findings

#### 1. HIGH Architecture `lib/features/calendar/calendar_export_writer.dart`

The first implementation used `file_selector.getSaveLocation` for both target
platforms, but the plugin explicitly does not implement save-location selection
on Android. Fixed with a narrow native `ACTION_CREATE_DOCUMENT` channel on
Android 10+ while retaining the native Linux save dialog. The Android path is
covered at the Dart channel boundary and compiled as an APK without requesting
broad storage permission.

#### 2. MEDIUM UI `lib/features/calendar/calendar_screen.dart`

An initially labelled export button added a complete control row at 200% text
on phone layouts and made the existing Year selector miss hit testing. Fixed by
placing a compact, tooltip-labelled export icon beside the date explanation;
the large-text regression and export interaction both have widget coverage.

### Verdict

P3 passes the full local gate. Export is an explicit local snapshot of the
active scope, range and date mode; standard all-day events have stable
identities and UTF-8-safe folding, estimates are unambiguous in three fields,
and cancellation or failure cannot mutate portfolio data. All 552 tests, Linux
integration, Android 10 compatibility and both release builds pass.

---

## Phase 6 P6 broker-import review

Base: P4 (`ca8beea`)<br>
Review date: 2026-08-23

### Findings

#### 1. HIGH Code `lib/domain/use_cases/portfolio_import.dart`

Interactive Brokers permits both month-first and day-first slash dates in Flex
configuration, so accepting a value such as `03/04/2026` would silently assign
the wrong economic date. Fixed by accepting only the broker's default
`yyyyMMdd` or unambiguous ISO format and reporting every other row in preview.

#### 2. MEDIUM Code `lib/domain/use_cases/portfolio_import.dart`

Custom Flex exports can contain canceled trades, derivative asset classes and
summary/order detail alongside executions. Importing those as ordinary stock
trades would duplicate or misrepresent positions. Fixed by refusing the `Ca`
code, every non-stock security activity and every non-execution trade detail.

#### 3. MEDIUM Code `lib/domain/use_cases/portfolio_import.dart`

Broker trade/transaction ids may repeat across accounts in a multi-account
file, while persisting the account id itself would retain unnecessary sensitive
metadata. Fixed by hashing account id or alias into the duplicate identity;
tests prove equal ids remain distinct and raw account values are absent.

### Verdict

P6 is complete for the documented Interactive Brokers Flex CSV extension. It
reuses local preview, partial row rejection, source-scoped deduplication, atomic
apply and reversal-based undo; no broker credentials, source files or raw
account identifiers are retained. Unsupported assets and ambiguous evidence are
refused rather than approximated.

---

## Phase 6 P4 multiple-portfolio review

Base: P2 (`0c025c5`) plus release fixes through `4002254`<br>
Review date: 2026-08-23

### Findings

#### 1. HIGH Code `lib/features/tax/tax_estimates.dart`

The first consolidated implementation fed combined holdings into one tax
profile, which could spend one portfolio's annual allowance against another.
Fixed by making consolidated tax estimates explicitly unavailable and showing
that boundary in the UI.

#### 2. MEDIUM Code — currency and tax settings

`lib/features/settings/currency_settings.dart` and
`lib/features/settings/tax_settings.dart` originally stored display currency
and tax assumptions as global preferences.
They now use portfolio-scoped keys, safe migration of the prior default
portfolio value and isolation tests; the consolidated view has its own display
preference but never a combined tax estimate.

#### 3. MEDIUM Code `lib/features/portfolio/portfolio_selection.dart`

A delayed startup preference read could overwrite a portfolio the user selected
immediately after launch. Fixed with a revision guard and a deterministic race
regression test.

#### 4. MEDIUM Code `lib/features/portfolio/portfolio_screen.dart`

The first consolidated ledger still exposed reversal buttons and omitted the
owning portfolio from each activity, crossing the promised read-only and
provenance boundaries. Fixed by disabling every ledger mutation in consolidated
scope and appending the portfolio name to each activity; widget coverage checks
both conditions.

#### 5. LOW Code `lib/features/portfolio/portfolio_management_dialog.dart`

Portfolio ids initially used only the clock's microsecond value, allowing a
collision under a fixed clock or exceptionally fast repeated creation. Fixed
by checking existing ids and adding a stable numeric suffix.

### Verdict

P4 passes the full quality gate: every mutation is portfolio-scoped,
destructive operations are confirmed and the final container is protected,
consolidation is explicitly read-only, unknown/mixed cost is not fabricated,
and fresh installs receive reference data without demo portfolio contents.

---

## Phase 6 P2 local-import review

Base: P1 (`621c252`)<br>
Review date: 2026-08-23

### Findings

#### 1. HIGH Code `lib/data/repositories/drift_portfolio_repository.dart`

Batch undo was initially keyed only by the generated batch id, so an unlikely
same-time/same-file collision across portfolios could reverse both portfolios.
Fixed by requiring the portfolio identity at the repository boundary, filtering
all undo reads by it, and covering a deliberate collision with a regression
test.

#### 2. MEDIUM Code `lib/data/repositories/drift_portfolio_repository.dart`

Duplicate detection initially put every external identity into one SQL `IN`
clause, which could exceed Android SQLite's bind-variable limit on a large but
valid CSV. Fixed with bounded 500-identity query chunks and a 1,200-row test.

#### 3. MEDIUM Code `lib/domain/use_cases/portfolio_import.dart`

Portfolio Performance's transaction currency was initially applied to its
gross amount, which could silently relabel a security price when fees were in a
different currency. Fixed by independently selecting gross-amount and
transaction currencies; tests retain a USD gross trade and EUR fee separately.

#### 4. LOW Code `lib/data/repositories/drift_portfolio_repository.dart`

Import history originally watched only rows with a batch id, so a manual
reversal of an imported activity was excluded and the batch could remain shown
as active. Fixed by considering all portfolio reversals while grouping only
original imported rows.

### Verdict

P2 is complete after the fixes: source files stay local and ephemeral, preview
is non-mutating, duplicates are stable and Android-safe, apply and position
rebuild are atomic, undo is portfolio-scoped and auditable, schema migration is
additive, and the complete local CI pipeline is green with both release builds.

---

## Phase 6 P1 activity-ledger review

Base: `v0.43.0` (`2157bbe`)<br>
Review date: 2026-08-23

### Findings

#### 1. HIGH Code `lib/data/repositories/drift_portfolio_repository.dart`

A reversal initially carried no instrument identity, so an instrument-scoped
projection rebuild could not see that reversal and would leave the original
purchase or sale active. Fixed by normalizing every reversal with its target's
instrument identity before insertion, then rebuilding inside the same
transaction. Regression coverage verifies both the position effect and that a
second reversal is rejected.

#### 2. MEDIUM Test architecture `test/features/portfolio/portfolio_screen_test.dart`

New activity streams were not overridden in hermetic shell/widget tests, which
opened the platform database and left Drift timers alive. Fixed by overriding
both activity and reconciliation streams; the focused shell suite and full
test suite now finish without pending-timer failures.

### Verdict

P1 is complete after the fixes: schema-v4 ownership migration is preserving,
ledger writes and position projections are atomic, financial arithmetic is
exact-decimal, reversal history is immutable, currency lines never mix, and
the format/analyze/full-test gate is green.

---

## Previous release review

Base: `origin/master` @ `c4e86d5`  
Head reviewed: `c2ba62e`  
Files changed: 161  
Lines changed: +37,263 / -6,614  
Review date: 2026-08-23

### Findings

#### 1. MEDIUM Code `lib/features/notifications/notification_state.dart:400`

Startup, resume and settings changes could run notification reconciliation at
the same time, with each run reading the same delivered-event snapshot and
showing the same notification. Fixed by a single-flight
`NotificationReconciler`, a coalesced refresh/FX/notification lifecycle cycle,
and a concurrency regression test.

#### 2. MEDIUM Code `lib/features/notifications/notification_state.dart:145`

Dividend delivery keys previously used only event kind, instrument and day, so
two legitimate same-company payments on one day collided and one was silently
suppressed. Fixed by deriving the stable identity from all distinguishing
dividend fields and covering same-day payments in a regression test.

### Verdict

Mergeable after the fixes above and a green full local release pipeline. No
remaining correctness or architecture finding was confirmed in the reviewed
diff.

---

## Phase 5 release review

Base: `0c388a5`<br>
Head reviewed: `afeda06` plus the R6 working tree<br>
Review date: 2026-08-23

### Findings

#### 1. MEDIUM Architecture `.github/workflows/ci.yml:83`

Android 10 support was asserted only through `minSdk 29` and an APK build, so a
phone-layout or API-29 runtime regression could still merge. Fixed by running
the real portfolio journey on an API 29 emulator in both CI and the release
workflow, with the new third-party action pinned to its immutable release SHA.

#### 2. MEDIUM Code `integration_test/portfolio_journey_test.dart:140`

The cross-platform journey assumed desktop-sized viewports and failed to reach
lazy portfolio/forecast content on Android. Fixed with bounded
scroll-until-visible interactions and verified on both API 29 and Linux.

### Verdict

Release-ready after the fixes above: full rendered pipeline green, API 29
journey and release APK cold launch green, migrations verified, and workflow
syntax clean.

## Localization review

Base: `master` @ `74e6e95`
Head reviewed: P10 working tree
Review date: 2026-08-24

### Findings

#### 1. MEDIUM Code `lib/app/app.dart`

The first-run loading accessibility label initially used a localization lookup
above `MaterialApp`, where no application localization was installed and the
label therefore always remained English. Fixed by translating it directly with
the already selected locale, and covered the catalog and live application path.

#### 2. MEDIUM Code `lib/features/research/research_detail_screen.dart`

Instrument names and externally supplied sector/country metadata initially
passed through phrase translation, which could alter portfolio/provider
content. Fixed by explicitly marking every such field as non-translatable while
keeping surrounding application labels localized.

#### 3. LOW Code `lib/features/settings/settings_screen.dart`

Language controls initially remained active while a preference write was in
flight, allowing out-of-order writes to persist a different language from the
one displayed. Fixed by disabling the group during load/save; the live
English/Croatian/German journey verifies the applied locale and persisted value.

### Verdict

Mergeable after these fixes. The full local release pipeline is green: 571
tests, Linux integration, version policy, Android 10 compatibility, Linux and
Android release builds, and a rendered Linux first-frame smoke test.

---
