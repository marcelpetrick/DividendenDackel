import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:dividendendackel/core/errors/failure.dart';
import 'package:dividendendackel/core/errors/result.dart';
import 'package:dividendendackel/core/networking/request_coordinator.dart';
import 'package:dividendendackel/data/providers/market_data_provider.dart';
import 'package:dividendendackel/data/providers/provider_registry.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:dividendendackel/domain/repositories/repositories.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProviderRegistry', () {
    test('orders priorities first and appends remaining capable providers', () {
      final _FakeDividendProvider first = _FakeDividendProvider('first');
      final _FakeDividendProvider second = _FakeDividendProvider('second');
      final _FakeDividendProvider third = _FakeDividendProvider('third');
      final ProviderRegistry registry = ProviderRegistry(
        providers: <MarketDataProvider>[first, second, third],
        priorities: <ProviderDataType, List<String>>{
          ProviderDataType.dividends: <String>['third', 'first'],
        },
      );

      expect(
        registry
            .providersFor(ProviderDataType.dividends)
            .map((MarketDataProvider provider) => provider.id),
        <String>['third', 'first', 'second'],
      );
    });

    test('filters disabled and incapable providers', () {
      final ProviderRegistry registry = ProviderRegistry(
        providers: <MarketDataProvider>[
          _FakeDividendProvider('enabled'),
          _FakeDividendProvider('disabled'),
          const _NoCapabilityProvider('unrelated'),
        ],
        isEnabled: (String id) => id != 'disabled',
      );

      expect(
        registry
            .providersFor(ProviderDataType.dividends)
            .map((MarketDataProvider provider) => provider.id),
        <String>['enabled'],
      );
      expect(registry.providersFor(ProviderDataType.quote), isEmpty);
    });

    test('rejects duplicate and empty ids', () {
      expect(
        () => ProviderRegistry(
          providers: <MarketDataProvider>[
            _FakeDividendProvider('same'),
            _FakeDividendProvider('same'),
          ],
        ),
        throwsArgumentError,
      );
      expect(
        () => ProviderRegistry(
          providers: <MarketDataProvider>[_FakeDividendProvider('  ')],
        ),
        throwsArgumentError,
      );
    });

    test('rejects an advertised capability without its contract', () {
      expect(
        () => ProviderRegistry(
          providers: const <MarketDataProvider>[_MisdeclaredProvider()],
        ),
        throwsArgumentError,
      );
    });

    test('rejects invalid priority configuration', () {
      final _FakeDividendProvider provider = _FakeDividendProvider('one');
      expect(
        () => ProviderRegistry(
          providers: <MarketDataProvider>[provider],
          priorities: <ProviderDataType, List<String>>{
            ProviderDataType.dividends: <String>['missing'],
          },
        ),
        throwsArgumentError,
      );
      expect(
        () => ProviderRegistry(
          providers: <MarketDataProvider>[provider],
          priorities: <ProviderDataType, List<String>>{
            ProviderDataType.quote: <String>['one'],
          },
        ),
        throwsArgumentError,
      );
      expect(
        () => ProviderRegistry(
          providers: <MarketDataProvider>[provider],
          priorities: <ProviderDataType, List<String>>{
            ProviderDataType.dividends: <String>['one', 'one'],
          },
        ),
        throwsArgumentError,
      );
    });
  });

  group('ProviderFallbackChain', () {
    late RequestCoordinator coordinator;

    setUp(() {
      coordinator = RequestCoordinator(
        defaultPolicy: ProviderRequestPolicy(
          maxAttempts: 1,
          initialBackoff: Duration.zero,
          maxBackoff: Duration.zero,
        ),
      );
    });

    tearDown(() => coordinator.dispose());

    test('falls back in order and returns the first success', () async {
      final _FakeDividendProvider unavailable = _FakeDividendProvider(
        'unavailable',
        response: const Failed<List<DividendEvent>>(
          ProviderUnavailableFailure(),
        ),
      );
      final DividendEvent expected = _dividend();
      final _FakeDividendProvider working = _FakeDividendProvider(
        'working',
        response: Success<List<DividendEvent>>(<DividendEvent>[expected]),
      );
      final ProviderFallbackChain fallback = ProviderFallbackChain(
        registry: ProviderRegistry(
          providers: <MarketDataProvider>[unavailable, working],
        ),
        coordinator: coordinator,
      );

      final Result<List<DividendEvent>> result = await fallback.run(
        dataType: ProviderDataType.dividends,
        requestKey: 'dividends:test',
        operation: 'fetchDividends',
        invoke: (MarketDataProvider provider, CancellationToken token) =>
            (provider as DividendDataProvider).fetchDividends(
              _instrument,
              _range,
              cancellationToken: token,
            ),
      );

      expect(result.valueOrNull, <DividendEvent>[expected]);
      expect(unavailable.calls, 1);
      expect(working.calls, 1);
    });

    test('does not hide invalid-instrument failures behind fallback', () async {
      final _FakeDividendProvider invalid = _FakeDividendProvider(
        'invalid',
        response: const Failed<List<DividendEvent>>(
          InvalidInstrumentFailure(symbol: 'TEST'),
        ),
      );
      final _FakeDividendProvider unused = _FakeDividendProvider('unused');
      final ProviderFallbackChain fallback = ProviderFallbackChain(
        registry: ProviderRegistry(
          providers: <MarketDataProvider>[invalid, unused],
        ),
        coordinator: coordinator,
      );

      final Result<List<DividendEvent>> result = await fallback.run(
        dataType: ProviderDataType.dividends,
        requestKey: 'invalid',
        operation: 'fetchDividends',
        invoke: (MarketDataProvider provider, CancellationToken token) =>
            (provider as DividendDataProvider).fetchDividends(
              _instrument,
              _range,
              cancellationToken: token,
            ),
      );

      expect(result.failureOrNull, isA<InvalidInstrumentFailure>());
      expect(invalid.calls, 1);
      expect(unused.calls, 0);
    });

    test(
      'returns the final fallback failure when all providers fail',
      () async {
        final _FakeDividendProvider empty = _FakeDividendProvider(
          'empty',
          response: const Failed<List<DividendEvent>>(NoDataFailure()),
        );
        final ProviderUnavailableFailure expected =
            const ProviderUnavailableFailure(statusCode: 503);
        final _FakeDividendProvider down = _FakeDividendProvider(
          'down',
          response: Failed<List<DividendEvent>>(expected),
        );
        final ProviderFallbackChain fallback = ProviderFallbackChain(
          registry: ProviderRegistry(
            providers: <MarketDataProvider>[empty, down],
          ),
          coordinator: coordinator,
        );

        final Result<List<DividendEvent>> result = await fallback.run(
          dataType: ProviderDataType.dividends,
          requestKey: 'all-fail',
          operation: 'fetchDividends',
          invoke: (MarketDataProvider provider, CancellationToken token) =>
              (provider as DividendDataProvider).fetchDividends(
                _instrument,
                _range,
                cancellationToken: token,
              ),
        );

        expect(result.failureOrNull, expected);
      },
    );

    test('returns a typed failure when no provider is enabled', () async {
      final ProviderFallbackChain fallback = ProviderFallbackChain(
        registry: ProviderRegistry(providers: const <MarketDataProvider>[]),
        coordinator: coordinator,
      );

      final Result<int> result = await fallback.run<int>(
        dataType: ProviderDataType.quote,
        requestKey: 'none',
        operation: 'fetchQuote',
        invoke: (_, _) async => const Success<int>(1),
      );

      expect(result.failureOrNull, isA<ProviderUnavailableFailure>());
    });

    test(
      'deduplicates matching fallback requests through the coordinator',
      () async {
        final Completer<Result<List<DividendEvent>>> response =
            Completer<Result<List<DividendEvent>>>();
        final _FakeDividendProvider provider = _FakeDividendProvider(
          'provider',
          pendingResponse: response,
        );
        final ProviderFallbackChain fallback = ProviderFallbackChain(
          registry: ProviderRegistry(providers: <MarketDataProvider>[provider]),
          coordinator: coordinator,
        );

        Future<Result<List<DividendEvent>>> run() => fallback.run(
          dataType: ProviderDataType.dividends,
          requestKey: 'same',
          operation: 'fetchDividends',
          invoke: (MarketDataProvider candidate, CancellationToken token) =>
              (candidate as DividendDataProvider).fetchDividends(
                _instrument,
                _range,
                cancellationToken: token,
              ),
        );

        final Future<Result<List<DividendEvent>>> first = run();
        final Future<Result<List<DividendEvent>>> second = run();
        await _waitUntil(() => provider.calls == 1);
        response.complete(
          const Success<List<DividendEvent>>(<DividendEvent>[]),
        );

        expect((await first).isSuccess, isTrue);
        expect((await second).isSuccess, isTrue);
        expect(provider.calls, 1);
      },
    );
  });

  test('ProviderMarketDataService returns normalized domain records', () async {
    final RequestCoordinator coordinator = RequestCoordinator(
      defaultPolicy: ProviderRequestPolicy(maxAttempts: 1),
    );
    addTearDown(coordinator.dispose);
    final DividendEvent expected = _dividend();
    final _FakeDividendProvider provider = _FakeDividendProvider(
      'provider',
      response: Success<List<DividendEvent>>(<DividendEvent>[expected]),
    );
    final ProviderMarketDataService service = ProviderMarketDataService(
      ProviderFallbackChain(
        registry: ProviderRegistry(providers: <MarketDataProvider>[provider]),
        coordinator: coordinator,
      ),
    );

    final Result<List<DividendEvent>> result = await service.dividends(
      _instrument,
      _range,
    );

    expect(result.valueOrNull, <DividendEvent>[expected]);
    expect(result.valueOrNull!.single.provenance.source, 'provider');
  });
}

const Instrument _instrument = Instrument(
  internalId: 'sym:TEST@XNAS',
  symbol: 'TEST',
  name: 'Test Incorporated',
  currency: Currency.usd,
  mic: 'XNAS',
);

final DateRange _range = DateRange(DateTime.utc(2026), DateTime.utc(2027));

DividendEvent _dividend() => DividendEvent(
  instrumentId: _instrument.internalId,
  amountPerShare: Money(Decimal.parse('0.25'), Currency.usd),
  status: DividendStatus.confirmed,
  exDate: DateTime.utc(2026, 3, 1),
  provenance: Provenance(source: 'provider', fetchedAt: DateTime.utc(2026)),
);

final class _FakeDividendProvider implements DividendDataProvider {
  _FakeDividendProvider(
    this.id, {
    this.response = const Success<List<DividendEvent>>(<DividendEvent>[]),
    this.pendingResponse,
  });

  @override
  final String id;

  final Result<List<DividendEvent>> response;
  final Completer<Result<List<DividendEvent>>>? pendingResponse;
  int calls = 0;

  @override
  Set<ProviderDataType> get capabilities => const <ProviderDataType>{
    ProviderDataType.dividends,
  };

  @override
  Future<Result<List<DividendEvent>>> fetchDividends(
    Instrument instrument,
    DateRange range, {
    required CancellationToken cancellationToken,
  }) {
    calls++;
    return pendingResponse?.future ??
        Future<Result<List<DividendEvent>>>.value(response);
  }
}

final class _NoCapabilityProvider implements MarketDataProvider {
  const _NoCapabilityProvider(this.id);

  @override
  final String id;

  @override
  Set<ProviderDataType> get capabilities => const <ProviderDataType>{};
}

final class _MisdeclaredProvider implements MarketDataProvider {
  const _MisdeclaredProvider();

  @override
  String get id => 'misdeclared';

  @override
  Set<ProviderDataType> get capabilities => const <ProviderDataType>{
    ProviderDataType.dividends,
  };
}

Future<void> _waitUntil(bool Function() condition) async {
  for (int attempt = 0; attempt < 100 && !condition(); attempt++) {
    await Future<void>.delayed(const Duration(milliseconds: 1));
  }
  expect(condition(), isTrue);
}
