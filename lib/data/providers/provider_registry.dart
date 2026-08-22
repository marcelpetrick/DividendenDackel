import 'dart:collection';

import 'package:dividendendackel/core/errors/failure.dart';
import 'package:dividendendackel/core/errors/result.dart';
import 'package:dividendendackel/core/networking/request_coordinator.dart';
import 'package:dividendendackel/data/providers/market_data_provider.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:dividendendackel/domain/repositories/repositories.dart';

/// Validated provider collection and per-data-type priority order.
final class ProviderRegistry {
  /// Creates a registry.
  ProviderRegistry({
    required List<MarketDataProvider> providers,
    Map<ProviderDataType, List<String>> priorities = const {},
    bool Function(String providerId)? isEnabled,
  }) : _providers = Map<String, MarketDataProvider>.unmodifiable(
         <String, MarketDataProvider>{
           for (final MarketDataProvider provider in providers)
             provider.id: provider,
         },
       ),
       _registrationOrder = List<MarketDataProvider>.unmodifiable(providers),
       _priorities = UnmodifiableMapView<ProviderDataType, List<String>>(
         <ProviderDataType, List<String>>{
           for (final MapEntry<ProviderDataType, List<String>> entry
               in priorities.entries)
             entry.key: List<String>.unmodifiable(entry.value),
         },
       ),
       _isEnabled = isEnabled ?? _alwaysEnabled {
    if (_providers.length != providers.length) {
      throw ArgumentError('Provider ids must be unique and non-empty.');
    }
    for (final MarketDataProvider provider in providers) {
      if (provider.id.trim().isEmpty) {
        throw ArgumentError.value(provider.id, 'provider.id', 'is empty');
      }
      for (final ProviderDataType capability in provider.capabilities) {
        if (!providerImplementsCapability(provider, capability)) {
          throw ArgumentError(
            '${provider.id} advertises ${capability.name} without '
            'implementing its contract.',
          );
        }
      }
    }
    for (final MapEntry<ProviderDataType, List<String>> entry
        in _priorities.entries) {
      if (entry.value.toSet().length != entry.value.length) {
        throw ArgumentError(
          'Priority for ${entry.key.name} contains duplicate providers.',
        );
      }
      for (final String id in entry.value) {
        final MarketDataProvider? provider = _providers[id];
        if (provider == null) {
          throw ArgumentError(
            'Priority for ${entry.key.name} references unknown provider $id.',
          );
        }
        if (!provider.capabilities.contains(entry.key)) {
          throw ArgumentError(
            '$id is prioritized for unsupported ${entry.key.name} data.',
          );
        }
      }
    }
  }

  final Map<String, MarketDataProvider> _providers;
  final List<MarketDataProvider> _registrationOrder;
  final Map<ProviderDataType, List<String>> _priorities;
  final bool Function(String providerId) _isEnabled;

  static bool _alwaysEnabled(String providerId) => true;

  /// Registered provider by id.
  MarketDataProvider? provider(String id) => _providers[id];

  /// Enabled capable providers in explicit priority then registration order.
  List<MarketDataProvider> providersFor(ProviderDataType dataType) {
    final List<String> preferred = _priorities[dataType] ?? const <String>[];
    final Set<String> alreadyAdded = <String>{};
    final List<MarketDataProvider> ordered = <MarketDataProvider>[];

    void addWhenAvailable(MarketDataProvider provider) {
      if (alreadyAdded.add(provider.id) &&
          provider.capabilities.contains(dataType) &&
          _isEnabled(provider.id)) {
        ordered.add(provider);
      }
    }

    for (final String id in preferred) {
      addWhenAvailable(_providers[id]!);
    }
    for (final MarketDataProvider provider in _registrationOrder) {
      addWhenAvailable(provider);
    }
    return List<MarketDataProvider>.unmodifiable(ordered);
  }
}

/// Runs a per-data-type provider fallback chain through the coordinator.
final class ProviderFallbackChain {
  /// Creates the fallback service.
  const ProviderFallbackChain({
    required this.registry,
    required this.coordinator,
  });

  /// Provider registry.
  final ProviderRegistry registry;

  /// Shared bounded request scheduler.
  final RequestCoordinator coordinator;

  /// Executes [invoke] against providers in configured order.
  Future<Result<T>> run<T>({
    required ProviderDataType dataType,
    required String requestKey,
    required String operation,
    required Future<Result<T>> Function(
      MarketDataProvider provider,
      CancellationToken cancellationToken,
    )
    invoke,
    RequestPriority priority = RequestPriority.medium,
  }) async {
    final List<MarketDataProvider> providers = registry.providersFor(dataType);
    if (providers.isEmpty) {
      return Failed<T>(
        ProviderUnavailableFailure(
          technicalDetail: 'No enabled provider supports ${dataType.name}',
        ),
      );
    }

    Failure? lastFailure;
    for (final MarketDataProvider provider in providers) {
      final CoordinatedRequest<T> coordinated = coordinator.submit<T>(
        CoordinatorRequest<T>(
          key: '${provider.id}:$requestKey',
          provider: provider.id,
          operation: operation,
          priority: priority,
          execute: (CancellationToken token) => invoke(provider, token),
        ),
      );
      final Result<T> result = await coordinated.result;
      if (result.isSuccess) {
        return result;
      }
      lastFailure = result.failureOrNull;
      if (!_allowsFallback(lastFailure!)) {
        return result;
      }
    }
    return Failed<T>(lastFailure!);
  }

  static bool _allowsFallback(Failure failure) => switch (failure.category) {
    FailureCategory.network ||
    FailureCategory.timeout ||
    FailureCategory.rateLimited ||
    FailureCategory.authentication ||
    FailureCategory.providerUnavailable ||
    FailureCategory.parsing ||
    FailureCategory.noData ||
    FailureCategory.stale => true,
    FailureCategory.invalidInstrument ||
    FailureCategory.cancelled ||
    FailureCategory.unexpected => false,
  };
}

/// Domain-facing market-data operations with fallback already applied.
final class ProviderMarketDataService {
  /// Creates the service.
  const ProviderMarketDataService(this.fallback);

  /// Fallback executor.
  final ProviderFallbackChain fallback;

  /// Searches providers for normalized instruments.
  Future<Result<List<Instrument>>> search(String query, {int limit = 20}) =>
      fallback.run<List<Instrument>>(
        dataType: ProviderDataType.instrumentSearch,
        requestKey: 'search:${query.trim().toLowerCase()}:$limit',
        operation: 'searchInstruments',
        priority: RequestPriority.high,
        invoke: (MarketDataProvider provider, CancellationToken token) =>
            (provider as InstrumentSearchProvider).searchInstruments(
              query,
              limit: limit,
              cancellationToken: token,
            ),
      );

  /// Fetches a normalized latest quote.
  Future<Result<Quote>> quote(Instrument instrument) => fallback.run<Quote>(
    dataType: ProviderDataType.quote,
    requestKey: 'quote:${instrument.internalId}',
    operation: 'fetchQuote',
    invoke: (MarketDataProvider provider, CancellationToken token) =>
        (provider as QuoteDataProvider).fetchQuote(
          instrument,
          cancellationToken: token,
        ),
  );

  /// Fetches normalized dividend events.
  Future<Result<List<DividendEvent>>> dividends(
    Instrument instrument,
    DateRange range,
  ) => fallback.run<List<DividendEvent>>(
    dataType: ProviderDataType.dividends,
    requestKey:
        'dividends:${instrument.internalId}:${range.start.toIso8601String()}:'
        '${range.end.toIso8601String()}',
    operation: 'fetchDividends',
    priority: RequestPriority.high,
    invoke: (MarketDataProvider provider, CancellationToken token) =>
        (provider as DividendDataProvider).fetchDividends(
          instrument,
          range,
          cancellationToken: token,
        ),
  );

  /// Fetches normalized earnings events.
  Future<Result<List<EarningsEvent>>> earnings(
    Instrument instrument,
    DateRange range,
  ) => fallback.run<List<EarningsEvent>>(
    dataType: ProviderDataType.earnings,
    requestKey:
        'earnings:${instrument.internalId}:${range.start.toIso8601String()}:'
        '${range.end.toIso8601String()}',
    operation: 'fetchEarnings',
    priority: RequestPriority.high,
    invoke: (MarketDataProvider provider, CancellationToken token) =>
        (provider as EarningsDataProvider).fetchEarnings(
          instrument,
          range,
          cancellationToken: token,
        ),
  );

  /// Fetches normalized news metadata.
  Future<Result<List<NewsItem>>> news(
    Instrument instrument, {
    int limit = 50,
  }) => fallback.run<List<NewsItem>>(
    dataType: ProviderDataType.news,
    requestKey: 'news:${instrument.internalId}:$limit',
    operation: 'fetchNews',
    priority: RequestPriority.high,
    invoke: (MarketDataProvider provider, CancellationToken token) =>
        (provider as NewsDataProvider).fetchNews(
          instrument,
          limit: limit,
          cancellationToken: token,
        ),
  );

  /// Fetches normalized filing metadata.
  Future<Result<List<Filing>>> filings(
    Instrument instrument,
    DateRange range,
  ) => fallback.run<List<Filing>>(
    dataType: ProviderDataType.filings,
    requestKey:
        'filings:${instrument.internalId}:${range.start.toIso8601String()}:'
        '${range.end.toIso8601String()}',
    operation: 'fetchFilings',
    priority: RequestPriority.high,
    invoke: (MarketDataProvider provider, CancellationToken token) =>
        (provider as FilingDataProvider).fetchFilings(
          instrument,
          range,
          cancellationToken: token,
        ),
  );

  /// Fetches normalized daily foreign-exchange reference rates.
  Future<Result<List<FxRate>>> fxRates(
    Currency base,
    Set<Currency> quotes,
    DateRange range,
  ) => fallback.run<List<FxRate>>(
    dataType: ProviderDataType.fxRates,
    requestKey:
        'fx:${base.code}:'
        '${quotes.map((Currency currency) => currency.code).toList()..sort()}:'
        '${range.start.toIso8601String()}:${range.end.toIso8601String()}',
    operation: 'fetchFxRates',
    invoke: (MarketDataProvider provider, CancellationToken token) =>
        (provider as FxRateDataProvider).fetchFxRates(
          base,
          quotes,
          range,
          cancellationToken: token,
        ),
  );
}
