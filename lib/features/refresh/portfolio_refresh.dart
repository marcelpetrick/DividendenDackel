import 'package:dividendendackel/app/providers.dart';
import 'package:dividendendackel/core/errors/failure.dart';
import 'package:dividendendackel/core/errors/result.dart';
import 'package:dividendendackel/core/networking/cache_policy.dart';
import 'package:dividendendackel/core/networking/stale_while_revalidate.dart';
import 'package:dividendendackel/core/utils/clock.dart';
import 'package:dividendendackel/data/providers/market_data_provider.dart';
import 'package:dividendendackel/data/providers/provider_registry.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:dividendendackel/domain/repositories/repositories.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Summary of one portfolio refresh. Individual provider failures do not stop
/// independent instruments or data categories from being refreshed.
final class PortfolioRefreshReport {
  /// Creates a report.
  const PortfolioRefreshReport({
    required this.completedAt,
    required this.refreshed,
    required this.skipped,
    required this.failures,
  });

  /// Completion time.
  final DateTime completedAt;

  /// Cache entries updated from a provider.
  final int refreshed;

  /// Entries which were still fresh.
  final int skipped;

  /// Safe, typed failures. Cached rows remain untouched for all of them.
  final List<Failure> failures;
}

/// Runs provider revalidation for all supported categories of followed assets.
final class PortfolioRefreshRunner {
  /// Creates a refresh runner.
  const PortfolioRefreshRunner({
    required this.clock,
    required this.instruments,
    required this.portfolio,
    required this.dividends,
    required this.marketData,
    required this.providers,
    required this.registry,
    required this.revalidator,
  });

  final Clock clock;
  final InstrumentRepository instruments;
  final PortfolioRepository portfolio;
  final DividendRepository dividends;
  final MarketDataRepository marketData;
  final ProviderMarketDataService providers;
  final ProviderRegistry registry;
  final StaleWhileRevalidateExecutor revalidator;

  /// Refreshes each enabled/supported category. Cached streams are never
  /// cleared before or after provider requests.
  Future<PortfolioRefreshReport> refresh({bool force = false}) async {
    final DateTime now = clock.now().toUtc();
    final Set<String> followed = await portfolio
        .watchFollowedInstrumentIds()
        .first;
    if (followed.isEmpty) {
      return PortfolioRefreshReport(
        completedAt: now,
        refreshed: 0,
        skipped: 0,
        failures: const <Failure>[],
      );
    }
    final List<Instrument> known = await instruments.watchAll().first;
    final List<Instrument> targets = known
        .where(
          (Instrument instrument) => followed.contains(instrument.internalId),
        )
        .toList(growable: false);

    int refreshed = 0;
    int skipped = 0;
    final List<Failure> failures = <Failure>[];

    Future<void> record<T>(
      Future<Result<RevalidationOutcome<T>>> operation,
    ) async {
      try {
        final Result<RevalidationOutcome<T>> result = await operation;
        switch (result) {
          case Success<RevalidationOutcome<T>>(:final value):
            switch (value.disposition) {
              case RevalidationDisposition.refreshed:
                refreshed++;
              case RevalidationDisposition.skippedFresh:
                skipped++;
            }
          case Failed<RevalidationOutcome<T>>(:final failure):
            failures.add(failure);
        }
      } on Object catch (error) {
        failures.add(
          UnexpectedFailure(
            technicalDetail: 'Refresh operation failed unexpectedly: $error',
            cause: error,
          ),
        );
      }
    }

    for (final Instrument instrument in targets) {
      if (_supports(ProviderDataType.quote)) {
        final Quote? cached = await marketData
            .watchQuote(instrument.internalId)
            .first;
        await record<Quote>(
          revalidator.run<Quote>(
            cacheKey: _key(ProviderDataType.quote, instrument),
            dataType: CacheDataType.quotes,
            now: now,
            cachedFetchedAt: _providerFetchedAt(cached?.provenance),
            cachedSource: cached?.provenance.source,
            force: force,
            fetch: () => providers.quote(instrument),
            persist: marketData.saveQuote,
            sourceOf: (Quote value) => value.provenance.source,
          ),
        );
      }

      if (_supports(ProviderDataType.dividends)) {
        final List<DividendEvent> cached = await dividends
            .watchForInstrument(instrument.internalId)
            .first;
        await record<List<DividendEvent>>(
          revalidator.run<List<DividendEvent>>(
            cacheKey: _key(ProviderDataType.dividends, instrument),
            dataType: CacheDataType.announcedDividends,
            now: now,
            cachedFetchedAt: _newestProviderFetch(cached),
            cachedSource: _sourceOf(cached),
            force: force,
            fetch: () => providers.dividends(
              instrument,
              DateRange(
                now.subtract(const Duration(days: 365 * 15)),
                now.add(const Duration(days: 365 * 2)),
              ),
            ),
            persist: (List<DividendEvent> values) =>
                dividends.saveAll(values, idOf: dividendEventIdentity),
            sourceOf: _sourceOf,
          ),
        );
      }

      final DateRange futureRange = DateRange(
        now.subtract(const Duration(days: 7)),
        now.add(const Duration(days: 365 * 2)),
      );
      if (_supports(ProviderDataType.earnings)) {
        final List<EarningsEvent> cached = await marketData
            .watchEarningsInRange(
              futureRange,
              instrumentIds: <String>{instrument.internalId},
            )
            .first;
        await record<List<EarningsEvent>>(
          revalidator.run<List<EarningsEvent>>(
            cacheKey: _key(ProviderDataType.earnings, instrument),
            dataType: CacheDataType.earningsCalendar,
            now: now,
            cachedFetchedAt: _newestProviderFetch(cached),
            cachedSource: _sourceOf(cached),
            force: force,
            fetch: () => providers.earnings(instrument, futureRange),
            persist: (List<EarningsEvent> values) =>
                marketData.saveEarnings(values, idOf: earningsEventIdentity),
            sourceOf: _sourceOf,
          ),
        );
      }

      if (_supports(ProviderDataType.companyEvents)) {
        final List<CorporateEvent> cached = await marketData
            .watchCorporateEventsInRange(
              futureRange,
              instrumentIds: <String>{instrument.internalId},
            )
            .first;
        await record<List<CorporateEvent>>(
          revalidator.run<List<CorporateEvent>>(
            cacheKey: _key(ProviderDataType.companyEvents, instrument),
            dataType: CacheDataType.companyEvents,
            now: now,
            cachedFetchedAt: _newestProviderFetch(cached),
            cachedSource: _sourceOf(cached),
            force: force,
            fetch: () => providers.companyEvents(instrument, futureRange),
            persist: marketData.saveCorporateEvents,
            sourceOf: _sourceOf,
          ),
        );
      }

      if (_supports(ProviderDataType.news)) {
        final List<NewsItem> cached = await marketData
            .watchRecentNews(
              instrumentIds: <String>{instrument.internalId},
              limit: 50,
            )
            .first;
        await record<List<NewsItem>>(
          revalidator.run<List<NewsItem>>(
            cacheKey: _key(ProviderDataType.news, instrument),
            dataType: CacheDataType.news,
            now: now,
            cachedFetchedAt: _newestProviderFetch(cached),
            cachedSource: _sourceOf(cached),
            force: force,
            fetch: () => providers.news(instrument),
            persist: marketData.saveNews,
            sourceOf: _sourceOf,
          ),
        );
      }

      if (_supports(ProviderDataType.filings)) {
        final DateRange filingRange = DateRange(
          now.subtract(const Duration(days: 365 * 2)),
          now.add(const Duration(days: 1)),
        );
        final List<Filing> cached = await marketData
            .watchRecentFilings(
              instrumentIds: <String>{instrument.internalId},
              limit: 100,
            )
            .first;
        await record<List<Filing>>(
          revalidator.run<List<Filing>>(
            cacheKey: _key(ProviderDataType.filings, instrument),
            dataType: CacheDataType.secFilings,
            now: now,
            cachedFetchedAt: _newestProviderFetch(cached),
            cachedSource: _sourceOf(cached),
            force: force,
            fetch: () => providers.filings(instrument, filingRange),
            persist: marketData.saveFilings,
            sourceOf: _sourceOf,
          ),
        );
      }
    }

    return PortfolioRefreshReport(
      completedAt: clock.now().toUtc(),
      refreshed: refreshed,
      skipped: skipped,
      failures: List<Failure>.unmodifiable(failures),
    );
  }

  bool _supports(ProviderDataType type) =>
      registry.providersFor(type).isNotEmpty;

  static String _key(ProviderDataType type, Instrument instrument) =>
      'market:${type.name}:${instrument.internalId}';

  static DateTime? _providerFetchedAt(Provenance? provenance) =>
      provenance == null || provenance.source == Provenance.sampleSource
      ? null
      : provenance.fetchedAt;

  static DateTime? _newestProviderFetch<T extends HasProvenance>(
    List<T> values,
  ) {
    DateTime? newest;
    for (final T value in values) {
      final DateTime? fetchedAt = _providerFetchedAt(value.provenance);
      if (fetchedAt != null && (newest == null || fetchedAt.isAfter(newest))) {
        newest = fetchedAt;
      }
    }
    return newest;
  }

  static String _sourceOf<T extends HasProvenance>(List<T> values) {
    for (final T value in values) {
      if (value.provenance.source != Provenance.sampleSource) {
        return value.provenance.source;
      }
    }
    return '';
  }
}

/// Stable identity for provider dividends across repeated fetches.
String dividendEventIdentity(DividendEvent event) {
  String date(DateTime? value) => value?.toUtc().toIso8601String() ?? '-';
  final bool hasDate = <DateTime?>[
    event.exDate,
    event.paymentDate,
    event.declarationDate,
    event.recordDate,
    event.reportedPeriodStart,
    event.reportedPeriodEnd,
  ].any((DateTime? value) => value != null);
  final String fallback = hasDate
      ? ''
      : ':${event.amountPerShare.currency.code}:${event.amountPerShare.amount}';
  return '${event.provenance.source}:${event.instrumentId}:'
      '${date(event.exDate)}:${date(event.paymentDate)}:'
      '${date(event.declarationDate)}:${date(event.recordDate)}:'
      '${date(event.reportedPeriodStart)}:${date(event.reportedPeriodEnd)}'
      '$fallback';
}

/// Stable identity for provider earnings across repeated fetches.
String earningsEventIdentity(EarningsEvent event) =>
    '${event.provenance.source}:${event.instrumentId}:'
    '${event.scheduledFor.toUtc().toIso8601String()}:'
    '${event.fiscalPeriod ?? '-'}';

/// User-visible refresh status shared by every top-level screen.
final class PortfolioRefreshState {
  const PortfolioRefreshState({
    this.isRefreshing = false,
    this.lastCompletedAt,
    this.failureCount = 0,
  });

  final bool isRefreshing;
  final DateTime? lastCompletedAt;
  final int failureCount;
}

final Provider<PortfolioRefreshRunner> portfolioRefreshRunnerProvider =
    Provider<PortfolioRefreshRunner>((Ref ref) {
      return PortfolioRefreshRunner(
        clock: ref.watch(clockProvider),
        instruments: ref.watch(instrumentRepositoryProvider),
        portfolio: ref.watch(portfolioRepositoryProvider),
        dividends: ref.watch(dividendRepositoryProvider),
        marketData: ref.watch(marketDataRepositoryProvider),
        providers: ref.watch(providerMarketDataServiceProvider),
        registry: ref.watch(providerRegistryProvider),
        revalidator: StaleWhileRevalidateExecutor(
          metadata: ref.watch(cacheMetadataRepositoryProvider),
          policy: CachePolicy(),
        ),
      );
    });

/// Allows shell tests and special embeds to suppress lifecycle network work.
final Provider<bool> automaticPortfolioRefreshEnabledProvider = Provider<bool>(
  (Ref ref) => true,
);

final class PortfolioRefreshController extends Notifier<PortfolioRefreshState> {
  @override
  PortfolioRefreshState build() => const PortfolioRefreshState();

  /// Starts a refresh unless one is already active.
  Future<void> refresh({bool force = false}) async {
    if (state.isRefreshing) return;
    state = PortfolioRefreshState(
      isRefreshing: true,
      lastCompletedAt: state.lastCompletedAt,
      failureCount: state.failureCount,
    );
    try {
      final PortfolioRefreshReport report = await ref
          .read(portfolioRefreshRunnerProvider)
          .refresh(force: force);
      state = PortfolioRefreshState(
        lastCompletedAt: report.refreshed > 0 || report.skipped > 0
            ? report.completedAt
            : state.lastCompletedAt,
        failureCount: report.failures.length,
      );
    } on Object {
      state = PortfolioRefreshState(
        lastCompletedAt: state.lastCompletedAt,
        failureCount: 1,
      );
    }
  }
}

final NotifierProvider<PortfolioRefreshController, PortfolioRefreshState>
portfolioRefreshProvider =
    NotifierProvider<PortfolioRefreshController, PortfolioRefreshState>(
      PortfolioRefreshController.new,
    );
