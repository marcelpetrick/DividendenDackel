# Architecture

DividendenDackel is a local-first Flutter application for Android and Linux.
SQLite is the source of truth: remote providers update the database, repository
streams publish those changes, and the UI keeps rendering the last usable
records when the network is unavailable.

## Dependency direction

```text
features + app shell
        |
        v
domain entities, analytics and repository contracts
        ^
        |
data repositories, provider adapters and SQLite
        ^
        |
platform plugins (HTTP, secure storage, notifications)
```

- `lib/domain/` contains immutable entities, exact-money value objects,
  analytics and repository interfaces. It has no widget or database dependency.
- `lib/data/` owns Drift tables, migrations, mappers, repository
  implementations, sample seeding, tax assumptions and provider adapters.
- `lib/core/` contains cross-cutting failures, structured logging, caching and
  request coordination.
- `lib/features/` groups Riverpod state and widgets by user capability.
- `lib/app/` wires repositories and providers, routing, navigation and themes.

The UI never treats an HTTP response as durable state. An adapter normalizes a
response into domain records, a repository writes them transactionally, and a
Riverpod provider observes the corresponding database stream.

## Startup and refresh

The root `ProviderScope` constructs dependencies lazily. On first launch the
sample seeder writes a realistic offline dataset idempotently. The application
then performs one coalesced refresh cycle:

1. wait for local seeding;
2. refresh followed instruments through the provider registry;
3. refresh the required ECB exchange rates;
4. reconcile due local notifications.

Resume events reuse the same single-flight cycle. Provider work enters the
`RequestCoordinator`, which applies global and per-provider capacity, pacing,
priorities, deadlines, retry policy, in-flight deduplication and cancellation.
Retry delays do not hold a concurrency slot.

## Persistence and migrations

`AppDatabase` is a Drift database stored in the platform application-data
directory. The current schema is version 4 and contains portfolio ownership,
normalized market data, research snapshots, provider health and cache metadata.
Money and rates are decimal text; timestamps are ISO-8601 text; enums persist by
name.

Migrations are explicit and additive:

| From | Change |
| --- | --- |
| 1 → 2 | SEC dividend reporting-period boundaries |
| 2 → 3 | exact daily FX rates |
| 3 → 4 | corporate events |

Unknown or backward paths fail instead of resetting the database. Foreign keys
are enabled for every connection, while user-owned holdings deliberately do not
cascade-delete when provider data changes. Migration tests open historical
schemas and verify user data after upgrade.

## Data provenance and offline behavior

Normalized records carry source, fetch/update time, cache state, confidence,
currency and original instrument identity where applicable. Cache policy is per
data category. Expired records become stale but remain visible while a refresh
runs; failures never replace known data with fabricated placeholders.

SEC EDGAR and Frankfurter/ECB are the only live adapters in version 0.1.0.
Search, dividend facts, filings and FX rates use fixture-tested normalization.
The provider and licensing boundary is documented in
[`data-providers.md`](data-providers.md).

## State and presentation

Riverpod providers in `lib/app/providers.dart` are the composition root.
Feature-specific controllers live beside their screens. The responsive shell
uses bottom navigation on narrow Android layouts and a navigation rail on Linux.
Loading, empty, stale and failure states are shared components rather than
one-off screen behavior.

Analytics return values together with explanations, confidence and limitations.
Unknown evidence is omitted, never converted to zero. Currency totals remain
separate until an attributable daily FX rate can convert them, and all monetary
arithmetic uses `Decimal`.

## Security boundaries

The app has no server, account or embedded privileged API key. Optional user
credentials are isolated behind `ApiSecretStore` (Android Keystore-backed
storage or Linux Secret Service); ordinary preferences hold only non-sensitive
toggles. Logs carry operation metadata but exclude portfolio contents and
credentials. Provider URLs must be HTTPS, and external article/filing links are
validated before opening in the system browser.

See [`privacy.md`](privacy.md) for the user-visible data inventory.

## Verification

`./localPipeline.sh` is shared by local development, CI and release automation.
It checks the pinned Flutter toolchain, dependency resolution, formatting,
analysis, 500 unit/widget tests, the real Linux integration journey, Android 10
compatibility, both release builds and—unless disabled—a rendered Linux first
frame. Provider contracts use recorded fixtures and do not depend on network
availability.

New database tables require an explicit migration plus an upgrade test. New
provider adapters require a fixture contract test and a completed licensing
entry before registration. Release details are in [`releases.md`](releases.md).
