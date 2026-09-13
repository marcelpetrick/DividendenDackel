# End-to-end application review

Review date: 2026-09-13

Platform: compiled Linux x86_64 application under Xvfb

Toolchain: Flutter 3.47.4 / Dart 3.13.3 / Java 21

## Verdict

The hermetic release journeys pass. They drive the compiled application through
the real router, Riverpod graph and in-memory Drift database with deterministic
provider and platform boundaries. All 14 declared routes have an exercised
journey, and a quality-gate test fails if a route is added without a matching
coverage marker.

One user-visible defect was found: Today rendered the English singular as
"1 holdings". It is fixed in English, German and Croatian and covered by both
widget and compiled integration tests.

## What works

| Journey | Evidence | Result |
| --- | --- | --- |
| First run | Completes all onboarding steps and reaches an honest empty Today screen | Pass |
| German holdings | Finds and adds Allianz and Münchener Rück through the real portfolio UI | Pass |
| Mixed currencies | Keeps a German EUR holding and Microsoft USD holding in their native currencies | Pass |
| Valuation | Shows a deterministic priced total when evidence exists and an explicit unavailable/offline state when it does not | Pass in both modes |
| Calendar and forecast | Opens the held-payment agenda and 24-month income forecast with estimates identified | Pass |
| Tax and currency | Keeps gross, estimated net and reported USD amounts visible and exposes editable tax assumptions | Pass |
| Research | Opens instrument detail, score context, dividend history and period-labelled CAGR | Pass |
| Settings and providers | Opens provider guidance, notifications, currency, About, bundled release notes and Data status | Pass |
| Offline and diagnostics | Retains saved content after provider failure and copies diagnostics through the desktop platform boundary | Pass |

The full local gate also passes 668 unit/widget tests, strict analysis, the
version scheme, Android 10 compatibility, and Android/Linux release builds.

## Route coverage audit

| Route | Compiled journey |
| --- | --- |
| `/today` | onboarding and priced/unpriced valuation |
| `/calendar` | dividend agenda and tax/currency |
| `/calendar/forecast` | 24-month forecast and offline refresh |
| `/portfolio` | German and mixed-currency holding entry |
| `/research` | research list |
| `/status` | provider status and diagnostic export |
| `/research/:instrumentId` | score and dividend-history detail |
| `/settings` | settings entry and tax navigation |
| `/settings/notifications` | notification modes |
| `/settings/data-sources` | provider list and Alpha Vantage guide |
| `/settings/currency` | display currency and ECB explanation |
| `/settings/tax` | estimate assumptions and allowance |
| `/about` | build identity and project information |
| `/about/changelog` | bundled changelog parsing and display |

## What is broken

No unresolved release-blocking product defect was confirmed. The singular
holding label found by the expanded journey is fixed in `414cab6`.

## What is missing

- Encrypted Android/Linux sync, widgets/Linux tray mode and advanced research
  history remain explicitly post-1.0 candidates (P7–P9), not incomplete MVP
  requirements.
- Financial Modeling Prep remains blocked on the required licensing review:
  its terms pages reject automated access. Its settings entry accurately says
  that it is not connected.
- Linux screenshots are not supplied by Flutter's `integration_test` plugin.
  The journeys assert rendered widgets and interactions but cannot detect a
  compositor, window-manager or HiDPI defect.
- Release APKs are debug-signed for direct installation, not Play Store signed.

## What cannot be verified without credentials

There is no `dev_secrets.env` in this checkout. A live Alpha Vantage response
for Allianz and a live Finnhub quote therefore cannot be exercised honestly.
Provider parsing, symbol/unit refusal, pacing and fallback behavior are covered
by fixture and hermetic tests; those tests do not prove that a third party has
not changed its live contract. A maintainer with real keys should run
`./tool/run-dev.sh` and verify ALV and MSFT before treating either keyed source
as operational evidence.
