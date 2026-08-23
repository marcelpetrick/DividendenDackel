# DividendenDackel 🐕

> *The dachshund that fetches your dividends.*

[![CI](https://github.com/marcelpetrick/DividendenDackel/actions/workflows/ci.yml/badge.svg?branch=master)](https://github.com/marcelpetrick/DividendenDackel/actions/workflows/ci.yml)

**DividendenDackel turns a local portfolio into a clear timeline of dividends, events, research changes, and upcoming income.**

A *Dackel* (dachshund) was bred to go down the hole and fetch what is hiding
there. This one fetches dividend dates, earnings and filings out of a pile of
financial data sources — and drops them at your feet, sorted by what actually
matters today. Short legs, long memory, local-first: it keeps everything it has
fetched, so it still has answers when the network does not.

It is a portfolio companion focused on dividends, upcoming portfolio events and
clear daily insights — deliberately *not* another chart-heavy trading app. The
question it answers is:

> What matters for my portfolio today, what happens next, and what should I understand about it?

**Author: Marcel Petrick <mail@marcelpetrick.it>**

**Note: project is generated with AI.**

**License: GPLv3 or later. See [`LICENSE`](LICENSE).**

---

## Status

**Early development — foundation phase.** The full specification lives in
[`Vision.md`](Vision.md); the ordered task queue lives in
[`docs/BACKLOG.md`](docs/BACKLOG.md).

What exists today is the engineering foundation, not yet the product UI:

- Flutter application targeting Android 10+ and Linux x86_64
- typed error model and `Result` type
- structured logging with credential and portfolio-content redaction
- strict static analysis, local pipeline script and CI

The Today screen, dividend calendar and portfolio are still ahead — see the
backlog for exactly what is done and what is not.

## Principles

- **Relevance before data volume.** "3 things matter for your portfolio today",
  not "84 new market articles".
- **Explain instead of command.** No BUY/SELL signals; every score explains why
  it exists.
- **Local-first.** The portfolio and cached market data stay usable offline. No
  login, no cloud account, no central portfolio database.
- **Transparent data.** Source, freshness, cache state and confirmation status
  are visible. Estimates are never presented as guarantees.
- **Beginner-first, expert-expandable.** Simple by default, detail on demand.

## Platforms

| Target | Requirement |
| --- | --- |
| Android | 10 (API 29) or newer, built against API 36 |
| Linux | x86_64 desktop, no Android runtime required |

## Build

Requires Flutter **3.47.1** (pinned — see [`localPipeline.sh`](localPipeline.sh)).

```sh
flutter pub get
flutter run -d linux          # Linux desktop
flutter run -d <android-id>   # Android device or emulator
```

Release artifacts:

```sh
flutter build linux --release   # build/linux/x64/release/bundle
flutter build apk --release     # build/app/outputs/flutter-apk/app-release.apk
```

## Quality gate

The same script runs locally and in CI, so the two cannot drift apart:

```sh
./localPipeline.sh --noRun              # everything, no app launch
./localPipeline.sh                      # everything plus rendered Linux smoke test
./localPipeline.sh --noRun --stage quality   # format, analyze, test
./localPipeline.sh --stage linux        # Linux bundle only
```

It checks the toolchain, formatting, static analysis, tests, that `minSdk` is
still 29 (Android 10 support is a product requirement), and both release
builds, then prints a stage-by-stage summary.

Individual commands:

```sh
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
```

## Data providers

**The app works with real data out of the box. You do not need an API key, and
you are not asked for one.**

It ships with two genuinely keyless public data sources, used by default:

| Source | Provides | Key required |
| --- | --- | --- |
| [SEC EDGAR](https://www.sec.gov/edgar) | Dividend history, filings and company facts for US-listed companies | none |
| [Frankfurter / ECB](https://frankfurter.dev) | Daily foreign-exchange reference rates | none |

SEC EDGAR publishes the actual declared dividend-per-share history a company
filed, which is what the dividend CAGR and the forecast are computed from — so
those numbers are real, not sample values. Both sources only require polite
use: an identifying `User-Agent` and respect for their rate limits, which the
Request Coordinator enforces.

Where those two do not reach — live quotes, non-US dividend calendars, news —
the app falls back to a **bundled sample dataset** so every screen is still
populated and explorable. Sample-derived values are labelled as such and are
never presented as market data.

Optionally, you can add your own key for a richer provider (Financial Modeling
Prep, Finnhub, Alpha Vantage) in Settings. That is an upgrade, not a
requirement.

### Why the app cannot provision keyed providers for you

Providers like FMP or Finnhub require a secret credential. Shipping one inside
the app would not make it secret — a compiled application can be inspected —
and it would breach those providers' terms. Vision.md §34 rules it out.
So the app uses sources that need no secret at all, and treats user-supplied
keys as opt-in.

Provider licensing terms are documented per provider in
[`docs/data-providers.md`](docs/data-providers.md) before any adapter is
merged.

## Not goals

DividendenDackel is not a broker, not an order execution platform, not a tax
filing application, not a social trading network, not an AI trading bot and not
an investment-advice service.
