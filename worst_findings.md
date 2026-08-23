# Engineering self-review

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
