# Implementation backlog

Derived from `Vision.md`. This file is the work queue for the autonomous
development loop: each iteration picks the **first unchecked task**, implements
it end-to-end following the loop in `Vision.md` §65, and ticks the box in the
same commit.

Legend: `[ ]` open · `[~]` in progress · `[x]` done.
Each task names the `Vision.md` sections it satisfies.

---

## Phase 0 — Baseline (done)

- [x] **B1** Scaffold Flutter app for Android + Linux — §5, §51
- [x] **B2** Pin `minSdk 29` / `targetSdk 36`, version `0.1.0+1` — §4.1, §58, §60, §61
- [x] **B3** Strict static analysis — §67
- [x] **R1** Local pipeline script + GitHub Actions PR CI (format, analyze,
      test, both platform builds, `minSdk` 29 assertion). *Pulled forward from
      Phase 5 on request: every later commit is then verified on a clean
      machine, not only on the development box.* — §58, §68, §70, §73
- [x] **R4a** README, GPLv3 `LICENSE`, `CONTRIBUTING.md`, `CHANGELOG.md`.
      *Pulled forward from Phase 5 on request.* — §75, §81, §82

---

## Phase 1 — Foundation

> **Reordered for delivery.** F9 (sample data) and F10 (app shell) now come
> before F6–F8 (cache, Request Coordinator, provider abstraction). The goal is
> a working, installable app driven by bundled sample data as early as
> possible; live provider plumbing is not needed for that and would otherwise
> delay it.

- [x] **F1** Typed error/failure model (`Failure` hierarchy: network, timeout,
      rateLimited, auth, providerUnavailable, parsing, invalidInstrument,
      noData, stale) plus a `Result<T>` type. Unit tests. — §55
- [x] **F2** Structured logging (component, provider, operation, duration,
      error category; verbose in debug, controlled in release; never logs
      portfolio contents). Unit tests. — §56, §80
- [x] **F3** Domain entities and value objects: `Money`/`Currency`,
      `Instrument` (internalId, symbol, exchange, MIC, ISIN, name, currency,
      country, providerMappings), `Holding`, `WatchlistEntry`, `Quote`,
      `DividendEvent` (+`DividendStatus`, `Confidence`), `EarningsEvent`,
      `NewsItem` (+`NewsCategory`), `Filing`, `ResearchSnapshot`, and a shared
      `Provenance` (source, fetchedAt, updatedAt, cacheState, confidence,
      currency, originalSymbol, exchange). Unit tests. — §35, §36, §45, §48
- [x] **F4** Drift/SQLite persistence: tables for every core entity,
      schema version 1, explicit migration scaffolding, open on Android and
      Linux. Migration test. — §35, §76
- [x] **F5** DAOs + repository interfaces in `domain/repositories`, Drift-backed
      implementations in `data/repositories`, exposing streams the UI observes.
      Repository tests. — §35, §53
- [x] **F9** Bundled sample data provider (realistic offline dataset) so the app
      is fully usable with zero API keys, plus fixture-based contract tests.
      — §44, §77
- [x] **Q8** App icon and branding for both platforms, replacing the default
      Flutter launcher icon: a Dackel fetching a coin, tying the name to the
      product's own fetch-and-retrieve metaphor. *Moved up from Phase 4 on
      request.* — §24
- [x] **F10** App shell: Riverpod, routing, responsive scaffold (bottom nav on
      Android, navigation rail on Linux), light/dark/system themes with
      accessible contrast, design tokens. Widget tests. — §6, §24, §25, §26, §54
- [x] **Q10** Theme selection: a System / Light / Dark control in Settings,
      persisted across launches, applied instantly. The two themes and the
      semantic palette exist (F10); what is missing is the user's choice and
      its persistence, which Vision.md §26 requires alongside System.
      Also verify both themes against WCAG AA contrast for body text, labels
      and the positive/negative/estimate tones, and check them at the largest
      supported text scale. — §26, §27
- [x] **F11** Settings + local API key storage (user-supplied keys, never
      embedded secrets), provider enable/disable, About screen with version,
      build number, commit SHA. — §34, §62, §80
- [x] **F6** Cache metadata + configurable TTL policy per data type with the
      defaults from the vision, and a `CacheState` (fresh/stale/missing)
      resolver. Unit tests for expiry. — §37
- [x] **F7** Request Coordinator: global + per-provider concurrency limits,
      per-provider rate limiting, timeouts, retry with exponential backoff,
      in-flight deduplication, priorities (high/medium/low), cancellation,
      and a broadcast status stream of active operations. Unit tests for
      dedup, limits, backoff, cancellation. — §29, §30, §31, §40, §78
- [x] **F8** `MarketDataProvider` interface, provider registry, per-data-type
      priority + fallback chain honouring rate limits, and normalization into
      domain models. Unit tests for fallback. — §32, §33
- [x] **F8a** SEC EDGAR adapter — **keyless**, enabled by default. Ticker/ISIN
      to CIK resolution, `companyfacts` dividend-per-share history, filings and
      company facts for US listings. Polite `User-Agent` and the 10 req/s limit
      enforced by the coordinator. Real dividend history, no user setup.
      — §32, §46, §77
- [x] **F8b** FX rate adapter (Frankfurter / ECB) — **keyless**, enabled by
      default. Daily reference rates powering multi-currency totals (D7).
      — §32, §46, §77
- [x] **F12** Data Status screen: provider health, active operations, cache hit
      rate, rate-limit reset times, last error. Widget test. — §41, §42, §43

---

## Phase 2 — Dividend core

- [x] **D1** Dividend CAGR (3/5/10-year), years without a cut, latest increase
      and decrease. Always rendered with its period. Unit tests. — §12
- [x] **D2** Deterministic, explainable dividend forecast engine (frequency,
      last dividend, growth, seasonality, announced values) emitting an explicit
      status and confidence. Unit tests. — §11, §48
      - growth from the instrument's own dividend CAGR where history allows;
      - an explicit, documented **fallback growth rate** when history is too
        short, rather than assuming zero growth or refusing to forecast;
      - the chosen basis is stated in the UI ("estimated from 8 years of
        payments" vs "estimated from a default growth rate"), because §11
        forbids pretending a rule-based calculation is more than it is.
- [x] **D3** Instrument search + add holding / add to watchlist flows, portfolio
      overview (value, day change, allocation, yield, next dividend). Widget
      and integration tests. — §8, §51
- [x] **D4** Dividend calendar: month, year and agenda views, ex-date vs
      payment-date toggle with beginner explanations, per-event confirmation
      status and expected payment for the held quantity. — §9
      Concrete capabilities (informed by reviewing Parqet's calendar as
      Vision.md §89 suggests; implementation and design are our own):
      - scope filter: portfolio / watchlist / all known instruments;
      - weekend toggle, since most payouts fall on weekdays and weekend
        columns waste space on a phone;
      - per-day event cap with a "show N more" affordance, so a heavy month
        stays readable;
      - tap or hover a day to expand its events with the key figures, rather
        than cramming them into the cell (§2.3 progressive disclosure);
      - estimated events carry a **shape/letter marker, not just a colour**,
        which §27 requires anyway;
      - display-currency selector, feeding D7.
- [x] **D5** Monthly + annual dividend forecast with bar visualization,
      confirmed vs estimated split, share of annual income, current-month
      already-paid breakdown. — §10
      Concrete capabilities:
      - breakdown by month, **quarter** and year, plus a payout table;
      - forecast horizon of **24 months**, matching what the category treats as
        useful;
      - trailing-twelve-months income as the baseline figure;
      - year-over-year comparison of dividend income;
      - cumulative income curve across the year;
      - every estimated figure separated from confirmed, never summed silently
        into one number (§9.4).
- [x] **D6** Dividend Quality Score with per-factor positive/risk explanations.
      Unit tests. — §14
- [x] **D8** Dividend tax model: gross and net for every dividend figure, with
      foreign withholding tax, the treaty cap, the creditable and reclaimable
      split, Kapitalertragsteuer, Solidaritätszuschlag, optional Kirchensteuer
      and the Sparerpauschbetrag tracked across the year. Returns an
      explainable breakdown, never a bare number, and states its assumptions.
      Versioned, dated, user-editable withholding table. Design and limits in
      [`dividend-taxation.md`](dividend-taxation.md). Unit tests per country
      case. — §2.3, §2.5, §48, §50
- [x] **D9** Net/gross throughout the UI: both figures side by side on the
      calendar, forecast, portfolio income and Today, never summed into one;
      a tax profile in Settings with visible, editable defaults; a plain
      "estimate, not tax advice" label. — §2.2, §2.5, §10
- [x] **D7** Multi-currency handling: per-instrument currency, a display
      currency, explicit FX rates with their own provenance and staleness, and
      currency exposure. Totals must never silently mix currencies. Unit tests.
      Design and limits in [`currency-conversion.md`](currency-conversion.md).
      — §20, §45

---

## Phase 3 — Daily insight

- [x] **T1** Today screen: portfolio summary, "Today matters", "Next 3 days",
      expected dividends (7/30/365 days), changes since last refresh. Useful
      without live quotes. Widget tests. — §7, §83, §84
- [x] **T2** Earnings events + upcoming corporate events. — §7, §51
- [x] **T3** News ingestion, categories, source links (no republishing). — §18
- [x] **T4** Relevance ranking for "what matters today". Unit tests. — §17
- [x] **T5** Research score (valuation, quality, growth, momentum, dividend,
      event risk) with human-readable explanations. Unit tests. — §15
- [x] **T6** Research detail screen incl. dividend history, bull/bear case and
      "What would change the assessment?". — §16

---

## Phase 4 — Quality

- [x] **Q1** Stale-while-revalidate everywhere + full offline behaviour with
      "Last updated …" instead of empty screens. — §38, §44
- [x] **Q2** Loading, empty and error states for every screen; failure copy from
      the vision; never fabricate missing values. — §79, §87
- [x] **Q3** Accessibility pass: scalable text, semantic labels, focus states,
      keyboard navigation on Linux, non-colour-only status indicators. — §27
- [x] **Q4** Portfolio health (concentration, sector/country/currency exposure,
      dividend-income concentration) with contextual insights. — §20
- [x] **Q5** Dividend simulator (additional investment → shares, added income,
      new weight, concentration impact). — §21
- [x] **Q6** Beginner onboarding: three short steps, then straight to Today.
      — §23
- [x] **Q7** Local notifications with disabled/important-only/all modes and
      non-manipulative wording. — §22, §85
- [x] **Q9** Performance pass: fast cached Today, no jank in calendar scrolling,
      lazy deep research, no full-history loads at startup. — §78

---

## Delivery verification

- [x] **E1** `integration_test` end-to-end coverage of the real flows: add a
      holding, see it in the portfolio, open the calendar, see a dividend
      event and the monthly forecast, go offline and still see data. Runs on
      Linux locally and is wired into the pipeline. — §57
- [x] **E2** Release artifact verification: build the release APK and the Linux
      bundle, launch the Linux bundle and assert it starts and renders, and
      record the artifact sizes. Wired into `localPipeline.sh`. — §59, §88

---

## Continuous — self-review

- [x] **S1** Recurring engineering self-review recorded in `worst_findings.md`,
      ordered by impact, each finding either fixed or explicitly justified.
      Re-run after every phase. Adopted from the author's CuteLingoExpress
      convention. — §66

---

## Phase 6 — Post-1.0 candidates (Vision.md §52, §89)

Not part of MVP 1. Reprioritized after the 2026-08-23 official Parqet review in
[`parqet-comparison.md`](parqet-comparison.md). The order protects the
local-first model and improves the dividend workflow before broadening the app.

- [x] **P1** Local activity ledger for purchases, sales, deposits, withdrawals,
      dividends, taxes and fees, including corrections/reversals and
      forecast-versus-paid dividend reconciliation.
- [x] **P2** Local import with preview, validation, idempotent duplicate
      handling, atomic application and undo: documented CSV first, then
      Portfolio Performance CSV. Source documents never leave the device.
- [ ] **P3** Calendar export as a local `.ics` snapshot importable into Google
      Calendar, Outlook and Apple Calendar. Preserve portfolio/date filters and
      mark estimates in text; do not create a public subscription URL.
- [ ] **P4** Multiple portfolios and explicit consolidated views, preserving
      per-portfolio tax, currency and provenance boundaries.
- [ ] **P5** Explainable cash-flow and performance analytics after P1: monthly,
      quarterly and annual detail, XIRR, TTWROR and optional benchmarks with
      formulas, period, coverage and cash-flow treatment visible.
- [ ] **P6** Local broker-document import extensions; consider credential-based
      autosync only after a provider-specific threat model, licensing review and
      reconciliation design.
- [ ] **P7** Encrypted Android/Linux sync, optional and never required for local
      use.
- [ ] **P8** Home-screen widgets and Linux tray mode.
- [ ] **P9** Advanced research history.
- [ ] **P10** German/English localization.

---

## Phase 5 — Delivery

- [x] **R1** *Done early — see Phase 0.*
- [x] **R2** Dependency + toolchain freshness workflows and `dependabot.yml`.
      — §71, §72
- [x] **R3** Release workflow on `v*` tags: version/tag match, full pipeline,
      raw APK, Linux tarball, checksums, generated release notes with build
      metadata, public GitHub Release with no drafts or pre-releases. Pinned
      action SHAs, minimal permissions. *Pulled forward from Phase 5 on
      request.* — §69, §70, §73
- [x] **R4b** Remaining documentation set: `docs/architecture.md`,
      `docs/data-providers.md`, `docs/research-score.md`, `docs/privacy.md` and
      `docs/releases.md`. (`README.md`, `LICENSE`, `CONTRIBUTING.md` and
      `CHANGELOG.md` are done — see R4a.) — §47, §75, §81, §82
- [ ] **R5** *Optional* keyed provider adapters (Financial Modeling Prep,
      Finnhub, Alpha Vantage) behind the provider interface, activated only
      when the user supplies a key, each with fixture contract tests and a
      licensing entry in `docs/data-providers.md`. No adapter merges without
      that documentation. The keyless SEC EDGAR and FX adapters are F8a/F8b and
      ship enabled. — §46, §47, §77
- [x] **R6** Release readiness: smoke-test Android 10 and Linux builds, verify
      migration path, tag `v0.1.0`. — §59, §88
