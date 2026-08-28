import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:dividendendackel/core/errors/result.dart';
import 'package:dividendendackel/core/logging/logging.dart';
import 'package:dividendendackel/core/networking/provider_status_monitor.dart';
import 'package:dividendendackel/core/networking/request_coordinator.dart';
import 'package:dividendendackel/core/utils/clock.dart';
import 'package:dividendendackel/data/database/app_database.dart';
import 'package:dividendendackel/data/providers/alpha_vantage_quote_provider.dart';
import 'package:dividendendackel/data/providers/finnhub_quote_provider.dart';
import 'package:dividendendackel/data/providers/frankfurter_fx_provider.dart';
import 'package:dividendendackel/data/providers/market_data_provider.dart';
import 'package:dividendendackel/data/providers/open_figi_provider.dart';
import 'package:dividendendackel/data/providers/provider_registry.dart';
import 'package:dividendendackel/data/providers/sec_edgar_provider.dart';
import 'package:dividendendackel/data/repositories/drift_cache_metadata_repository.dart';
import 'package:dividendendackel/data/repositories/drift_dividend_repository.dart';
import 'package:dividendendackel/data/repositories/drift_fx_rate_repository.dart';
import 'package:dividendendackel/data/repositories/drift_instrument_repository.dart';
import 'package:dividendendackel/data/repositories/drift_market_data_repository.dart';
import 'package:dividendendackel/data/repositories/drift_portfolio_repository.dart';
import 'package:dividendendackel/data/repositories/drift_provider_status_repository.dart';
import 'package:dividendendackel/data/repositories/drift_research_repository.dart';
import 'package:dividendendackel/data/sample/sample_data_seeder.dart';
import 'package:dividendendackel/data/sample/sample_dataset.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:dividendendackel/domain/repositories/repositories.dart';
import 'package:dividendendackel/domain/use_cases/portfolio_import.dart';
import 'package:dividendendackel/features/portfolio/portfolio_editor.dart';
import 'package:dividendendackel/features/portfolio/portfolio_selection.dart';
import 'package:dividendendackel/features/settings/data_source_settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

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

/// Daily FX reference-rate repository.
final Provider<FxRateRepository> fxRateRepositoryProvider =
    Provider<FxRateRepository>(
      (Ref ref) => DriftFxRateRepository(ref.watch(databaseProvider)),
    );

/// Explainable research-score history.
final Provider<ResearchRepository> researchRepositoryProvider =
    Provider<ResearchRepository>(
      (Ref ref) => DriftResearchRepository(ref.watch(databaseProvider)),
    );

/// Cache-expiry metadata used by the request coordinator.
final Provider<CacheMetadataRepository> cacheMetadataRepositoryProvider =
    Provider<CacheMetadataRepository>(
      (Ref ref) => DriftCacheMetadataRepository(ref.watch(databaseProvider)),
    );

/// Persisted provider health and cache telemetry.
final Provider<ProviderStatusRepository> providerStatusRepositoryProvider =
    Provider<ProviderStatusRepository>(
      (Ref ref) => DriftProviderStatusRepository(ref.watch(databaseProvider)),
    );

/// Bounded scheduler shared by every provider adapter.
final Provider<RequestCoordinator> requestCoordinatorProvider =
    Provider<RequestCoordinator>((Ref ref) {
      final RequestCoordinator coordinator = RequestCoordinator(
        clock: ref.watch(clockProvider),
        providerPolicies: <String, ProviderRequestPolicy>{
          // Alpha Vantage's free tier is 25 requests per day, one symbol per
          // call. The budget is what stops a single portfolio refresh from
          // spending a user's whole day in seconds; the spacing keeps a burst
          // from looking like abuse.
          'alpha_vantage': ProviderRequestPolicy(
            maxConcurrent: 1,
            minimumSpacing: Duration(milliseconds: 900),
            dailyRequestBudget: AlphaVantageQuoteProvider.freeTierDailyRequests,
          ),
          // Finnhub's free tier allows roughly one request a second. No daily
          // budget: the constraint is pace, not a day's allowance.
          'finnhub': ProviderRequestPolicy(
            maxConcurrent: 2,
            minimumSpacing: Duration(milliseconds: 1100),
          ),
          // OpenFIGI publishes its unauthenticated quota in-band as
          // `ratelimit-policy: 25;w=60`. One request every 2.4 s stays inside
          // it without tracking a rolling window, and a search issues at most
          // one request per venue.
          'openfigi': ProviderRequestPolicy(
            maxConcurrent: 1,
            minimumSpacing: Duration(milliseconds: 2400),
          ),
          // SEC asks automated clients to remain below 10 requests/second.
          'sec': ProviderRequestPolicy(
            // One logical operation may first resolve the public ticker index
            // and then fetch company data. At one operation per 220 ms, even
            // that two-request path remains below the SEC's 10 req/s ceiling.
            maxConcurrent: 1,
            minimumSpacing: Duration(milliseconds: 220),
          ),
        },
      );
      ref.onDispose(() => unawaited(coordinator.dispose()));
      return coordinator;
    });

/// Persists every provider request outcome for the Data Status screen.
final Provider<ProviderStatusMonitor> providerStatusMonitorProvider =
    Provider<ProviderStatusMonitor>((Ref ref) {
      final ProviderStatusMonitor monitor = ProviderStatusMonitor(
        coordinator: ref.watch(requestCoordinatorProvider),
        repository: ref.watch(providerStatusRepositoryProvider),
      );
      ref.onDispose(() => unawaited(monitor.dispose()));
      return monitor;
    });

/// Persisted provider status snapshots, including previous app sessions.
final StreamProvider<List<ProviderStatus>> providerStatusesProvider =
    StreamProvider<List<ProviderStatus>>((Ref ref) {
      ref.watch(providerStatusMonitorProvider);
      return ref.watch(providerStatusRepositoryProvider).watchAll();
    });

/// Live queued, running and retrying provider operations.
final StreamProvider<List<RequestStatus>> activeOperationsProvider =
    StreamProvider<List<RequestStatus>>((Ref ref) async* {
      final RequestCoordinator coordinator = ref.watch(
        requestCoordinatorProvider,
      );
      yield coordinator.activeOperations;
      await for (final RequestStatus _ in coordinator.statuses) {
        yield coordinator.activeOperations;
      }
    });

/// Shared HTTP transport for live provider adapters.
final Provider<http.Client> providerHttpClientProvider = Provider<http.Client>((
  Ref ref,
) {
  final http.Client client = http.Client();
  ref.onDispose(client.close);
  return client;
});

/// Keyless SEC EDGAR adapter.
final Provider<SecEdgarProvider> secEdgarProvider = Provider<SecEdgarProvider>(
  (Ref ref) => SecEdgarProvider(
    ref.watch(providerHttpClientProvider),
    ref.watch(clockProvider),
  ),
);

/// Keyless OpenFIGI adapter for instrument identity outside the US.
final Provider<OpenFigiProvider> openFigiProvider = Provider<OpenFigiProvider>(
  (Ref ref) => OpenFigiProvider(ref.watch(providerHttpClientProvider)),
);

/// A provider key supplied at build time, for development only.
///
/// `./tool/run-dev.sh` passes the contents of the git-ignored dev_secrets.env
/// as --dart-define values so a developer does not have to retype a key into
/// the settings screen on every device.
///
/// Guarded by [kDebugMode] rather than only by the define being absent. A
/// release build must never read a credential from anywhere but the user's own
/// secure storage, and a guard that depends on the build command being right is
/// not a guard (Vision.md §34, §80).
Future<String?> _developmentKey(String define) async {
  if (!kDebugMode) return null;
  final String value = switch (define) {
    'ALPHA_VANTAGE_API_KEY' => const String.fromEnvironment(
      'ALPHA_VANTAGE_API_KEY',
    ),
    'FINNHUB_API_KEY' => const String.fromEnvironment('FINNHUB_API_KEY'),
    _ => '',
  };
  return value.isEmpty ? null : value;
}

/// Quote adapter using the user's own Alpha Vantage credential.
///
/// The credential is read straight from secure storage for each request and is
/// never held in provider or widget state (Vision.md §34, §80).
final Provider<AlphaVantageQuoteProvider> alphaVantageQuoteProvider =
    Provider<AlphaVantageQuoteProvider>(
      (Ref ref) => AlphaVantageQuoteProvider(
        ref.watch(providerHttpClientProvider),
        ref.watch(clockProvider),
        () async =>
            await ref
                .read(apiSecretStoreProvider)
                .read(
                  PlatformDataSourceSettingsStore.secretKey(
                    MarketDataSource.alphaVantage,
                  ),
                ) ??
            await _developmentKey('ALPHA_VANTAGE_API_KEY'),
      ),
    );

/// Quote adapter using the user's own Finnhub credential.
final Provider<FinnhubQuoteProvider> finnhubQuoteProvider =
    Provider<FinnhubQuoteProvider>(
      (Ref ref) => FinnhubQuoteProvider(
        ref.watch(providerHttpClientProvider),
        ref.watch(clockProvider),
        () async =>
            await ref
                .read(apiSecretStoreProvider)
                .read(
                  PlatformDataSourceSettingsStore.secretKey(
                    MarketDataSource.finnhub,
                  ),
                ) ??
            await _developmentKey('FINNHUB_API_KEY'),
      ),
    );

/// Keyless Frankfurter adapter, explicitly restricted to ECB rates.
final Provider<FrankfurterFxProvider> frankfurterFxProvider =
    Provider<FrankfurterFxProvider>(
      (Ref ref) => FrankfurterFxProvider(
        ref.watch(providerHttpClientProvider),
        ref.watch(clockProvider),
      ),
    );

/// Validated market-data adapters and their per-capability fallback order.
final Provider<ProviderRegistry> providerRegistryProvider =
    Provider<ProviderRegistry>((Ref ref) {
      final DataSourceSettingsState settings = ref.watch(
        dataSourceSettingsProvider,
      );
      return ProviderRegistry(
        providers: <MarketDataProvider>[
          ref.watch(secEdgarProvider),
          ref.watch(frankfurterFxProvider),
          ref.watch(openFigiProvider),
          ref.watch(alphaVantageQuoteProvider),
          ref.watch(finnhubQuoteProvider),
        ],
        priorities: const <ProviderDataType, List<String>>{
          // SEC first: it answers US tickers precisely and without a venue
          // guess. OpenFIGI then covers everything SEC does not list, which is
          // every non-US listing.
          ProviderDataType.instrumentSearch: <String>['sec', 'openfigi'],
          ProviderDataType.dividends: <String>['sec'],
          ProviderDataType.filings: <String>['sec'],
          // Finnhub first for what it covers: its free tier is paced per
          // second, while Alpha Vantage's is 25 requests for the whole day, so
          // spending the scarcer allowance only where it is the sole option
          // leaves it for the German listings nothing else can price.
          ProviderDataType.quote: <String>['finnhub', 'alpha_vantage'],
          ProviderDataType.fxRates: <String>['frankfurter'],
        },
        isEnabled: (String providerId) => settings.configurations.any(
          (DataSourceConfiguration configuration) =>
              configuration.source.providerId == providerId &&
              configuration.enabled,
        ),
      );
    });

/// Executes provider fallback through the shared bounded coordinator.
final Provider<ProviderFallbackChain> providerFallbackChainProvider =
    Provider<ProviderFallbackChain>((Ref ref) {
      // Activate telemetry before any request can enter the coordinator.
      ref.watch(providerStatusMonitorProvider);
      return ProviderFallbackChain(
        registry: ref.watch(providerRegistryProvider),
        coordinator: ref.watch(requestCoordinatorProvider),
      );
    });

/// Domain-facing live market-data API used by refresh workflows.
final Provider<ProviderMarketDataService> providerMarketDataServiceProvider =
    Provider<ProviderMarketDataService>(
      (Ref ref) =>
          ProviderMarketDataService(ref.watch(providerFallbackChainProvider)),
    );

/// Search and mutation workflow for holdings and the watchlist.
final Provider<PortfolioEditor> portfolioEditorProvider =
    Provider<PortfolioEditor>(
      (Ref ref) => DefaultPortfolioEditor(
        instruments: ref.watch(instrumentRepositoryProvider),
        portfolio: ref.watch(portfolioRepositoryProvider),
        liveSearch: ref.watch(providerMarketDataServiceProvider).search,
        clock: ref.watch(clockProvider),
      ),
    );

/// Local CSV preview/apply workflow. Selected file bytes never leave the app.
final Provider<PortfolioImportService> portfolioImportServiceProvider =
    Provider<PortfolioImportService>(
      (Ref ref) => PortfolioImportService(
        portfolios: ref.watch(portfolioRepositoryProvider),
        instruments: ref.watch(instrumentRepositoryProvider),
        clock: ref.watch(clockProvider),
      ),
    );

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

  final Result<bool> hasAny = await instruments.hasAny();
  if (hasAny.valueOrNull == true) {
    log.debug('sample data already present', operation: 'seed');
    return;
  }
  if (hasAny.failureOrNull case final Object failure) {
    log.error(
      'could not inspect local data before seeding',
      operation: 'seed',
      error: failure,
    );
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
    final Object? failure = (await seeder.seed(
      dataset,
      includePortfolio: false,
    )).failureOrNull;
    if (failure != null) {
      log.error('seeding failed', operation: 'seed', error: failure);
      return;
    }
    final DateTime now = ref.watch(clockProvider).now().toUtc();
    final DateTime day = DateTime.utc(now.year, now.month, now.day);
    final Provenance fxProvenance = Provenance.sample(now)
        .copyWith(reportedCurrency: Currency.eur);
    final Object? fxFailure =
        (await ref.watch(fxRateRepositoryProvider).saveAll(<FxRate>[
          FxRate(
            base: Currency.eur,
            quote: Currency.usd,
            rate: Decimal.parse('1.17'),
            observedAt: day,
            provenance: fxProvenance.copyWith(reportedCurrency: Currency.usd),
          ),
          FxRate(
            base: Currency.eur,
            quote: Currency.gbp,
            rate: Decimal.parse('0.87'),
            observedAt: day,
            provenance: fxProvenance.copyWith(reportedCurrency: Currency.gbp),
          ),
          FxRate(
            base: Currency.eur,
            quote: Currency.chf,
            rate: Decimal.parse('0.94'),
            observedAt: day,
            provenance: fxProvenance.copyWith(reportedCurrency: Currency.chf),
          ),
        ])).failureOrNull;
    if (fxFailure != null) {
      log.error(
        'sample FX seeding failed',
        operation: 'seed',
        error: fxFailure,
      );
    }
  });
});

/// User-owned portfolio containers.
final StreamProvider<List<InvestmentPortfolio>> portfoliosProvider =
    StreamProvider<List<InvestmentPortfolio>>(
      (Ref ref) => ref.watch(portfolioRepositoryProvider).watchPortfolios(),
    );

/// Valid selected scope, falling back to the first portfolio after deletion.
final Provider<String?> effectivePortfolioIdProvider = Provider<String?>((
  Ref ref,
) {
  final String? selected = ref.watch(selectedPortfolioIdProvider);
  final AsyncValue<List<InvestmentPortfolio>> portfoliosValue = ref.watch(
    portfoliosProvider,
  );
  final List<InvestmentPortfolio>? portfolios = portfoliosValue.value;
  if (!portfoliosValue.hasValue || portfolios == null || portfolios.isEmpty) {
    return null;
  }
  if (selected == null) return null;
  return portfolios.any((InvestmentPortfolio item) => item.id == selected)
      ? selected
      : portfolios.first.id;
});

/// Holdings in the selected portfolio or aggregated consolidated scope.
final StreamProvider<List<Holding>> holdingsProvider =
    StreamProvider<List<Holding>>((Ref ref) {
      final String? portfolioId = ref.watch(effectivePortfolioIdProvider);
      final Stream<List<Holding>> source = ref
          .watch(portfolioRepositoryProvider)
          .watchHoldings(portfolioId: portfolioId);
      return portfolioId == null
          ? source.map(PortfolioScopeProjector.consolidateHoldings)
          : source;
    });

/// Watchlist in the selected portfolio or deduplicated consolidated scope.
final StreamProvider<List<WatchlistEntry>> watchlistProvider =
    StreamProvider<List<WatchlistEntry>>((Ref ref) {
      final String? portfolioId = ref.watch(effectivePortfolioIdProvider);
      final Stream<List<WatchlistEntry>> source = ref
          .watch(portfolioRepositoryProvider)
          .watchWatchlist(portfolioId: portfolioId);
      return portfolioId == null
          ? source.map(PortfolioScopeProjector.consolidateWatchlist)
          : source;
    });

/// Immutable activities in the selected portfolio or consolidated scope.
final StreamProvider<List<PortfolioActivity>> portfolioActivitiesProvider =
    StreamProvider<List<PortfolioActivity>>(
      (Ref ref) => ref
          .watch(portfolioRepositoryProvider)
          .watchActivities(ref.watch(effectivePortfolioIdProvider)),
    );

/// Local end-of-day valuations for the selected or consolidated scope.
final StreamProvider<List<PortfolioValuationSnapshot>>
portfolioValuationSnapshotsProvider =
    StreamProvider<List<PortfolioValuationSnapshot>>((Ref ref) {
      final String scopeId =
          ref.watch(effectivePortfolioIdProvider) ??
          InvestmentPortfolio.consolidatedId;
      return ref
          .watch(portfolioRepositoryProvider)
          .watchValuationSnapshots(scopeId);
    });

/// Applied local import batches available for precise undo.
final StreamProvider<List<PortfolioImportBatch>>
portfolioImportBatchesProvider = StreamProvider<List<PortfolioImportBatch>>((
  Ref ref,
) {
  final String? portfolioId = ref.watch(effectivePortfolioIdProvider);
  return portfolioId == null
      ? Stream<List<PortfolioImportBatch>>.value(const <PortfolioImportBatch>[])
      : ref.watch(portfolioRepositoryProvider).watchImportBatches(portfolioId);
});

/// Instrument ids the user holds or watches.
final StreamProvider<Set<String>> followedInstrumentIdsProvider =
    StreamProvider<Set<String>>(
      (Ref ref) => ref
          .watch(portfolioRepositoryProvider)
          .watchFollowedInstrumentIds(
            portfolioId: ref.watch(effectivePortfolioIdProvider),
          ),
    );

/// Held or watched instruments, keyed by internal id for quick lookup.
final StreamProvider<Map<String, Instrument>> instrumentsByIdProvider =
    StreamProvider<Map<String, Instrument>>((Ref ref) async* {
      final Set<String> followed = await ref.watch(
        followedInstrumentIdsProvider.future,
      );
      yield* ref
          .watch(instrumentRepositoryProvider)
          .watchByIds(followed)
          .map(
            (List<Instrument> list) => <String, Instrument>{
              for (final Instrument i in list) i.internalId: i,
            },
          );
    });

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
      final DateTime now = ref.watch(clockProvider).now();
      final DateTime start = DateTime.utc(now.year, now.month, now.day);
      yield* ref
          .watch(dividendRepositoryProvider)
          .watchInRange(
            DateRange.days(start, days),
            DividendDateMode.exDate,
            instrumentIds: followed,
          );
    });

/// Dividend payments expected to reach the account over the requested window.
final upcomingDividendPaymentsProvider =
    StreamProvider.family<List<DividendEvent>, int>((Ref ref, int days) async* {
      final Set<String> followed = await ref.watch(
        followedInstrumentIdsProvider.future,
      );
      final DateTime now = ref.watch(clockProvider).now();
      final DateTime start = DateTime.utc(now.year, now.month, now.day);
      yield* ref
          .watch(dividendRepositoryProvider)
          .watchInRange(
            DateRange.days(start, days),
            DividendDateMode.paymentDate,
            instrumentIds: followed,
          );
    });

/// Dated dividend payments for one calendar year, used for reconciliation.
final dividendPaymentsForYearProvider =
    StreamProvider.family<List<DividendEvent>, int>((Ref ref, int year) async* {
      final List<Holding> holdings = await ref.watch(holdingsProvider.future);
      yield* ref
          .watch(dividendRepositoryProvider)
          .watchInRange(
            DateRange(DateTime.utc(year), DateTime.utc(year + 1)),
            DividendDateMode.paymentDate,
            instrumentIds: <String>{
              for (final Holding holding in holdings) holding.instrumentId,
            },
          );
    });

/// Upcoming earnings for held or watched instruments.
final upcomingEarningsProvider =
    StreamProvider.family<List<EarningsEvent>, int>((Ref ref, int days) async* {
      final Set<String> followed = await ref.watch(
        followedInstrumentIdsProvider.future,
      );
      final DateTime now = ref.watch(clockProvider).now();
      final DateTime start = DateTime.utc(now.year, now.month, now.day);
      yield* ref
          .watch(marketDataRepositoryProvider)
          .watchEarningsInRange(
            DateRange.days(start, days),
            instrumentIds: followed,
          );
    });

/// Upcoming non-dividend, non-earnings company events.
final upcomingCorporateEventsProvider =
    StreamProvider.family<List<CorporateEvent>, int>((
      Ref ref,
      int days,
    ) async* {
      final Set<String> followed = await ref.watch(
        followedInstrumentIdsProvider.future,
      );

      final DateTime now = ref.watch(clockProvider).now();
      final DateTime start = DateTime.utc(now.year, now.month, now.day);
      yield* ref
          .watch(marketDataRepositoryProvider)
          .watchCorporateEventsInRange(
            DateRange.days(start, days),
            instrumentIds: followed,
          );
    });

/// Recent headline metadata concerning held or watched instruments.
final recentPortfolioNewsProvider = StreamProvider<List<NewsItem>>((
  Ref ref,
) async* {
  final Set<String> followed = await ref.watch(
    followedInstrumentIdsProvider.future,
  );
  yield* ref
      .watch(marketDataRepositoryProvider)
      .watchRecentNews(instrumentIds: followed, limit: 20);
});
