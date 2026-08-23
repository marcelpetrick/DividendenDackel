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
