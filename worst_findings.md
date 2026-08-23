# Engineering self-review

## Phase 6 P4 multiple-portfolio review

Base: P2 (`0c025c5`) plus release fixes through `4002254`<br>
Review date: 2026-08-23

### Findings

#1 HIGH Code `lib/features/tax/tax_estimates.dart`

The first consolidated implementation fed combined holdings into one tax
profile, which could spend one portfolio's annual allowance against another.
Fixed by making consolidated tax estimates explicitly unavailable and showing
that boundary in the UI.

#2 MEDIUM Code `lib/features/settings/currency_settings.dart` and
`lib/features/settings/tax_settings.dart`

Display currency and tax assumptions were originally global preferences.
Fixed with portfolio-scoped keys, safe migration of the prior default portfolio
value and isolation tests; the consolidated view has its own display preference
but never a combined tax estimate.

#3 MEDIUM Code `lib/features/portfolio/portfolio_selection.dart`

A delayed startup preference read could overwrite a portfolio the user selected
immediately after launch. Fixed with a revision guard and a deterministic race
regression test.

#4 MEDIUM Code `lib/features/portfolio/portfolio_screen.dart`

The first consolidated ledger still exposed reversal buttons and omitted the
owning portfolio from each activity, crossing the promised read-only and
provenance boundaries. Fixed by disabling every ledger mutation in consolidated
scope and appending the portfolio name to each activity; widget coverage checks
both conditions.

#5 LOW Code `lib/features/portfolio/portfolio_management_dialog.dart`

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

#1 HIGH Code `lib/data/repositories/drift_portfolio_repository.dart`

Batch undo was initially keyed only by the generated batch id, so an unlikely
same-time/same-file collision across portfolios could reverse both portfolios.
Fixed by requiring the portfolio identity at the repository boundary, filtering
all undo reads by it, and covering a deliberate collision with a regression
test.

#2 MEDIUM Code `lib/data/repositories/drift_portfolio_repository.dart`

Duplicate detection initially put every external identity into one SQL `IN`
clause, which could exceed Android SQLite's bind-variable limit on a large but
valid CSV. Fixed with bounded 500-identity query chunks and a 1,200-row test.

#3 MEDIUM Code `lib/domain/use_cases/portfolio_import.dart`

Portfolio Performance's transaction currency was initially applied to its
gross amount, which could silently relabel a security price when fees were in a
different currency. Fixed by independently selecting gross-amount and
transaction currencies; tests retain a USD gross trade and EUR fee separately.

#4 LOW Code `lib/data/repositories/drift_portfolio_repository.dart`

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

#1 HIGH Code `lib/data/repositories/drift_portfolio_repository.dart`

A reversal initially carried no instrument identity, so an instrument-scoped
projection rebuild could not see that reversal and would leave the original
purchase or sale active. Fixed by normalizing every reversal with its target's
instrument identity before insertion, then rebuilding inside the same
transaction. Regression coverage verifies both the position effect and that a
second reversal is rejected.

#2 MEDIUM Test architecture `test/features/portfolio/portfolio_screen_test.dart`

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

## Findings

#1 MEDIUM Code `lib/features/notifications/notification_state.dart:400`

Startup, resume and settings changes could run notification reconciliation at
the same time, with each run reading the same delivered-event snapshot and
showing the same notification. Fixed by a single-flight
`NotificationReconciler`, a coalesced refresh/FX/notification lifecycle cycle,
and a concurrency regression test.

#2 MEDIUM Code `lib/features/notifications/notification_state.dart:145`

Dividend delivery keys previously used only event kind, instrument and day, so
two legitimate same-company payments on one day collided and one was silently
suppressed. Fixed by deriving the stable identity from all distinguishing
dividend fields and covering same-day payments in a regression test.

## Verdict

Mergeable after the fixes above and a green full local release pipeline. No
remaining correctness or architecture finding was confirmed in the reviewed
diff.

---

## Phase 5 release review

Base: `0c388a5`<br>
Head reviewed: `afeda06` plus the R6 working tree<br>
Review date: 2026-08-23

### Findings

#1 MEDIUM Architecture `.github/workflows/ci.yml:83`

Android 10 support was asserted only through `minSdk 29` and an APK build, so a
phone-layout or API-29 runtime regression could still merge. Fixed by running
the real portfolio journey on an API 29 emulator in both CI and the release
workflow, with the new third-party action pinned to its immutable release SHA.

#2 MEDIUM Code `integration_test/portfolio_journey_test.dart:140`

The cross-platform journey assumed desktop-sized viewports and failed to reach
lazy portfolio/forecast content on Android. Fixed with bounded
scroll-until-visible interactions and verified on both API 29 and Linux.

### Verdict

Release-ready after the fixes above: full rendered pipeline green, API 29
journey and release APK cold launch green, migrations verified, and workflow
syntax clean.
