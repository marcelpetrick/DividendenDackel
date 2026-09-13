# Next steps: end-to-end testing on Linux, and the review it produces

Status: **release review complete; optional live smoke awaits credentials.**
Written 2026-08-28 against 0.61.0; reviewed on 2026-09-13.

The goal is a review of the whole application — what works, what does not, and
what is still missing — produced from automated journeys that drive the real
Linux desktop build with realistic holdings, rather than from reading the code
and hoping.

---

## 1. What "clicking for real" can mean here

Three levels exist, and the choice determines everything downstream.

| Level | What it drives | Verdict |
| --- | --- | --- |
| Widget tests | Widgets in isolation, no application | Already 668 of them; not end-to-end |
| **`integration_test`** | **The real compiled app, real database, real navigation; taps enter through the Flutter engine** | **The right level** |
| OS-level (`xdotool`, AT-SPI via `dogtail`) | Real X11 clicks against the window | Rejected |

Flutter paints its own widgets into a single canvas, so there are no native
controls for an OS-level tool to address. `xdotool` would need hard-coded pixel
coordinates that break on any layout change — and three separate test failures
in recent work were caused by assertions that accidentally depended on layout,
so that is not a theoretical risk. Flutter does expose AT-SPI on Linux, so
`dogtail` could address the semantics tree, but that is the same tree
`integration_test` addresses: more brittleness for no more fidelity.

`integration_test` launches the actual Linux binary and runs the real Riverpod
graph, the real Drift database, real navigation and real rendering. That is
genuinely end-to-end. Only the source of the input events differs.

## 2. Framework evaluation

Checked rather than assumed, on 2026-08-28:

- **Patrol 4.9.0** — documentation lists Android, iOS and macOS. **No Linux
  desktop support.** Ruled out.
- **flutter_gherkin 2.0.0** — a Gherkin layer over the legacy `flutter_driver`.
  Adds a dialect to learn and a deprecated substrate. Ruled out.
- **`integration_test`** — first-party, wired into
  `localPipeline.sh --stage integration` and running in CI under Xvfb. **Used.**
- **`flutter drive` with `integration_test_driver_extended`** — Flutter 3.47.4
  documents screenshot support only for Android, iOS and Web, and the plugin
  declares only Android and iOS native implementations. Linux screenshots are
  therefore not part of this test layer.

## 3. Two layers, deliberately separate

**Layer A — hermetic journeys, CI-gating.** Fake providers, fixed clock,
in-memory database, deterministic prices. Runs on every push. Proves the
application's own logic.

**Layer B — live smoke, opt-in, never gating.** Real OpenFIGI search and real
Alpha Vantage through `dev_secrets.env`. Run by hand or nightly. Proves the
integrations behave against reality.

The separation is the point. Layer B is subject to a 25-request daily quota,
network flakiness and third-party outages. Gating CI on it would mean the first
provider hiccup blocks every merge, and a gate that blocks merges for reasons
nobody controls gets switched off. Layer A must stay the one that gates.

## 4. Test data

Three of the four named instruments are already bundled:

```
ALV   Allianz SE                          XETRA    EUR
MUV2  Münchener Rückversicherungs-Ges.    XETRA    EUR
MSFT  Microsoft Corporation               NASDAQ   USD
```

**AWS is not a listed instrument.** It is a division of Amazon; the tradeable
security is **AMZN**, which the bundled set does not carry. That makes it the
better Layer B case: searching for it exercises OpenFIGI discovery finding
something the app does not ship, which is exactly the "Hannover Rück wird nicht
gefunden" report.

**Unilever earns its place.** The bundled set lists `ULVR — Unilever PLC —
London — GBP`, and Alpha Vantage quotes London in **GBX**, pence rather than
pounds. The adapter now refuses a venue whose unit disagrees with the holding,
so a journey must assert Unilever shows **no price** rather than one a hundred
times out. A test that proves a refusal is worth as much as one that proves a
success.

## 5. Journeys to cover

Nine, each its own test so a failure names the broken workflow rather than
"the journey".

1. **First run** — onboarding, then Today with an empty portfolio and no
   fabricated content.
2. **Add German holdings** — search ALV and MUV2, enter quantity and purchase
   price, see them in Portfolio.
3. **Add US holdings** — MSFT alongside the German ones, a mixed-currency
   portfolio.
4. **Valuation** — total value, day change and allocation, run twice: once with
   prices available and once without.
5. **Calendar and forecast** — dividend agenda, the 24-month forecast, and that
   every estimate is labelled as one.
6. **Tax and currency** — gross against estimated net, display-currency
   conversion, and that the two are never combined.
7. **Research** — open an instrument, read the score explanation and the CAGR
   label. *Route currently untested.*
8. **Settings and providers** — data sources, the setup guide, Data status, and
   the diagnostics copy action. *All currently untested.*
9. **Offline and failure states** — remove the provider and confirm cached data
   survives, estimates stay labelled, and nothing is invented.

## 6. Where coverage stands today

The compiled journey suite now exercises all **14 of 14 routes**, including
Research, Data status, provider setup, notifications, About and the bundled
changelog. A unit test compares the router's declared paths with explicit
coverage markers beside the integration journeys; adding or removing a route
without updating its journey fails the quality gate.

## 7. The deliverable

`docs/e2e-review.md`, built from three inputs:

1. **Journey results** — which of the nine pass, and precisely where a failure
   occurs.
2. **A route-coverage audit**, mechanical: every route in `app_router.dart`
   against what the journeys visit, so "not implemented" and "not tested" are
   never conflated.
3. **Screenshots** at each milestone, if step 0 confirms they work.

Structured as **What works · What is broken · What is missing · What cannot be
verified without credentials.** The last section is real and stays its own
heading rather than being folded quietly into the others.

## 8. What this cannot tell us

- **Not real OS input.** Events enter through the engine, so a window-manager,
  HiDPI or compositor problem will not appear.
- **Layer A proves logic, not integrations.** A fake can be wrong in the same
  way the code is wrong. Only Layer B catches a provider changing its contract.
- **Android is out of scope here.** The existing API 29 journey stays as it is.
- **Rendering is not asserted.** A widget can be found and still be invisible or
  misplaced. Screenshots let a human judge; they do not assert.

## 9. Sequence

| Step | Work |
| --- | --- |
| 0 | Done — Linux screenshots are unsupported; keep the compiled `flutter test` path |
| 1 | Done — shared real-database harness with deterministic platform/provider boundaries |
| 2 | Done — journeys 1–4 cover onboarding, holdings, currencies and priced/unpriced valuation |
| 3 | Done — journeys 5–7 cover forecast, tax/currency and research explanations |
| 4 | Done — journeys 8–9 cover system routes; cached/offline behaviour remains asserted |
| 5 | Done — route-coverage audit fails if any declared route lacks a journey marker |
| 6 | Pending credentials — Layer B cannot be meaningful without a real Alpha Vantage key |
| 7 | Done — the green release gate and findings are recorded in `docs/e2e-review.md` |

Steps 1–5 are the bulk and each is independently committable and CI-gating.
Step 6 is small but needs a real Alpha Vantage key to mean anything. Step 7 is
the review itself.

## 10. Open question, to settle before step 2

Should Layer A supply fake prices, so valuation, forecast and tax are exercised
end to end, or run with no quote provider at all, matching what a user without
a key sees today?

**Both, as one journey parameterised over priced and unpriced.** The unpriced
path is what users are hitting right now — no keyless source prices a German
listing — and nothing currently tests it.

---

## Also outstanding, unrelated to this plan

- **`ALV.DEX` is unverified.** Alpha Vantage's demo key refuses non-demo
  symbols, so no one has yet watched a real key return a real Allianz price.
- **Financial Modeling Prep is blocked**, not skipped: its terms pages answer
  HTTP 403 to automated requests, and `docs/data-providers.md` requires that
  review before an adapter merges.
- **Croatian plurals** need a native speaker. The language has three forms and
  the call sites offer two; the structure is verified, the idiom is not.
- **Backlog P7, P8 and P9** — encrypted sync, home-screen widgets and Linux tray
  mode, advanced research history. Each is a piece of work in its own right.
