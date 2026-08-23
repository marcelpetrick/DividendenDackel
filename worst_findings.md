# Engineering self-review

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
