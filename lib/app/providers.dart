import 'dart:async';

import 'package:dividendendackel/core/logging/logging.dart';
import 'package:dividendendackel/core/networking/request_coordinator.dart';
import 'package:dividendendackel/core/utils/clock.dart';
import 'package:dividendendackel/data/database/app_database.dart';
import 'package:dividendendackel/data/repositories/drift_cache_metadata_repository.dart';
import 'package:dividendendackel/data/repositories/drift_dividend_repository.dart';
import 'package:dividendendackel/data/repositories/drift_instrument_repository.dart';
import 'package:dividendendackel/data/repositories/drift_market_data_repository.dart';
import 'package:dividendendackel/data/repositories/drift_portfolio_repository.dart';
import 'package:dividendendackel/data/sample/sample_data_seeder.dart';
import 'package:dividendendackel/data/sample/sample_dataset.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:dividendendackel/domain/repositories/repositories.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Application-wide dependencies (Vision.md §54).
///
/// One state-management approach across the app. Screens read repositories
/// through these providers and never construct a database or a provider client
/// themselves.

/// The time source. Overridden in tests to make dates deterministic.
final Provider<Clock> clockProvider = Provider<Clock>(
  (Ref ref) => const SystemClock(),
);

/// Retains recent log records for the Data Status screen (Vision.md §42).
final Provider<InMemoryLogSink> logSinkProvider = Provider<InMemoryLogSink>((
  Ref ref,
) {
  final InMemoryLogSink sink = InMemoryLogSink();
  ref.onDispose(sink.dispose);
  return sink;
});

/// The root logger.
final Provider<AppLogger> loggerProvider = Provider<AppLogger>(
  (Ref ref) => AppLogger(
    sink: MultiLogSink(<LogSink>[ConsoleLogSink(), ref.watch(logSinkProvider)]),
    clock: ref.watch(clockProvider),
  ),
);

/// The local database. Overridden in tests with an in-memory executor.
final Provider<AppDatabase> databaseProvider = Provider<AppDatabase>((Ref ref) {
  final AppDatabase db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

/// Instrument repository.
final Provider<InstrumentRepository> instrumentRepositoryProvider =
    Provider<InstrumentRepository>(
      (Ref ref) => DriftInstrumentRepository(ref.watch(databaseProvider)),
    );

/// Portfolio repository.
final Provider<PortfolioRepository> portfolioRepositoryProvider =
    Provider<PortfolioRepository>(
      (Ref ref) => DriftPortfolioRepository(ref.watch(databaseProvider)),
    );

/// Dividend repository.
final Provider<DividendRepository> dividendRepositoryProvider =
    Provider<DividendRepository>(
      (Ref ref) => DriftDividendRepository(ref.watch(databaseProvider)),
    );

/// Market data repository.
final Provider<MarketDataRepository> marketDataRepositoryProvider =
    Provider<MarketDataRepository>(
      (Ref ref) => DriftMarketDataRepository(ref.watch(databaseProvider)),
    );

/// Cache-expiry metadata used by the request coordinator.
final Provider<CacheMetadataRepository> cacheMetadataRepositoryProvider =
    Provider<CacheMetadataRepository>(
      (Ref ref) => DriftCacheMetadataRepository(ref.watch(databaseProvider)),
    );

/// Bounded scheduler shared by every provider adapter.
final Provider<RequestCoordinator> requestCoordinatorProvider =
    Provider<RequestCoordinator>((Ref ref) {
      final RequestCoordinator coordinator = RequestCoordinator(
        clock: ref.watch(clockProvider),
        providerPolicies: <String, ProviderRequestPolicy>{
          // SEC asks automated clients to remain below 10 requests/second.
          'sec': ProviderRequestPolicy(
            maxConcurrent: 2,
            minimumSpacing: Duration(milliseconds: 110),
          ),
        },
      );
      ref.onDispose(() => unawaited(coordinator.dispose()));
      return coordinator;
    });

/// Seeds the bundled sample dataset on first run.
///
/// Without this the app would open onto empty screens and no API key would
/// change that, since no provider adapter exists yet. Seeding is idempotent, so
/// it is safe on every launch.
final FutureProvider<void> sampleDataProvider = FutureProvider<void>((
  Ref ref,
) async {
  final AppLogger log = ref
      .watch(loggerProvider)
      .scoped(component: 'sample-data');
  final InstrumentRepository instruments = ref.watch(
    instrumentRepositoryProvider,
  );

  final List<Instrument> existing = await instruments.watchAll().first;
  if (existing.isNotEmpty) {
    log.debug('sample data already present', operation: 'seed');
    return;
  }

  await log.timed('seed', () async {
    final SampleDataset dataset = await SampleDataset.loadFromBundle();
    final SampleDataSeeder seeder = SampleDataSeeder(
      instruments: instruments,
      portfolio: ref.watch(portfolioRepositoryProvider),
      dividends: ref.watch(dividendRepositoryProvider),
      marketData: ref.watch(marketDataRepositoryProvider),
      clock: ref.watch(clockProvider),
    );
    final Object? failure = (await seeder.seed(dataset)).failureOrNull;
    if (failure != null) {
      log.error('seeding failed', operation: 'seed', error: failure);
    }
  });
});

/// The user's holdings.
final StreamProvider<List<Holding>> holdingsProvider =
    StreamProvider<List<Holding>>(
      (Ref ref) => ref.watch(portfolioRepositoryProvider).watchHoldings(),
    );

/// The user's watchlist.
final StreamProvider<List<WatchlistEntry>> watchlistProvider =
    StreamProvider<List<WatchlistEntry>>(
      (Ref ref) => ref.watch(portfolioRepositoryProvider).watchWatchlist(),
    );

/// Every known instrument, keyed by internal id for quick lookup.
final StreamProvider<Map<String, Instrument>> instrumentsByIdProvider =
    StreamProvider<Map<String, Instrument>>(
      (Ref ref) => ref
          .watch(instrumentRepositoryProvider)
          .watchAll()
          .map(
            (List<Instrument> list) => <String, Instrument>{
              for (final Instrument i in list) i.internalId: i,
            },
          ),
    );

/// Instrument ids the user holds or watches.
final StreamProvider<Set<String>> followedInstrumentIdsProvider =
    StreamProvider<Set<String>>(
      (Ref ref) =>
          ref.watch(portfolioRepositoryProvider).watchFollowedInstrumentIds(),
    );

/// Latest quotes for the instruments the user follows.
final StreamProvider<Map<String, Quote>> quotesProvider =
    StreamProvider<Map<String, Quote>>((Ref ref) async* {
      final Set<String> followed = await ref.watch(
        followedInstrumentIdsProvider.future,
      );
      yield* ref.watch(marketDataRepositoryProvider).watchQuotes(followed);
    });

/// Upcoming dividends over the next `days`, by ex-date.
final upcomingDividendsProvider =
    StreamProvider.family<List<DividendEvent>, int>((Ref ref, int days) async* {
      final Set<String> followed = await ref.watch(
        followedInstrumentIdsProvider.future,
      );
      yield* ref
          .watch(dividendRepositoryProvider)
          .watchInRange(
            DateRange.days(ref.watch(clockProvider).now(), days),
            DividendDateMode.exDate,
            instrumentIds: followed,
          );
    });
