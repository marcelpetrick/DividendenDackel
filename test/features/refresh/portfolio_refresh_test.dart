import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:dividendendackel/core/errors/failure.dart';
import 'package:dividendendackel/core/errors/result.dart';
import 'package:dividendendackel/core/networking/cache_policy.dart';
import 'package:dividendendackel/core/networking/request_coordinator.dart';
import 'package:dividendendackel/core/networking/stale_while_revalidate.dart';
import 'package:dividendendackel/data/database/app_database.dart';
import 'package:dividendendackel/data/providers/market_data_provider.dart';
import 'package:dividendendackel/data/providers/provider_registry.dart';
import 'package:dividendendackel/data/repositories/drift_cache_metadata_repository.dart';
import 'package:dividendendackel/data/repositories/drift_dividend_repository.dart';
import 'package:dividendendackel/data/repositories/drift_instrument_repository.dart';
import 'package:dividendendackel/data/repositories/drift_market_data_repository.dart';
import 'package:dividendendackel/data/repositories/drift_portfolio_repository.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:dividendendackel/features/refresh/portfolio_refresh.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_clock.dart';

void main() {
  final DateTime now = DateTime.utc(2026, 8, 23, 12);
  const Instrument instrument = Instrument(
    internalId: 'sym:TEST@XNAS',
    symbol: 'TEST',
    name: 'Test Company',
    currency: Currency.usd,
    mic: 'XNAS',
  );
  late AppDatabase db;
  late RequestCoordinator coordinator;
  late DriftMarketDataRepository marketData;
  late _QuoteProvider provider;
  late PortfolioRefreshRunner runner;

  setUp(() async {
    db = AppDatabase.withExecutor(NativeDatabase.memory());
    final FakeClock clock = FakeClock(now);
    final DriftInstrumentRepository instruments = DriftInstrumentRepository(db);
    final DriftPortfolioRepository portfolio = DriftPortfolioRepository(db);
    marketData = DriftMarketDataRepository(db);
    provider = _QuoteProvider();
    coordinator = RequestCoordinator(clock: clock);
    final ProviderRegistry registry = ProviderRegistry(
      providers: <MarketDataProvider>[provider],
    );
    await instruments.save(instrument);
    await portfolio.saveHolding(
      Holding(
        instrumentId: instrument.internalId,
        quantity: Decimal.one,
        provenance: Provenance.user(now),
      ),
    );
    await marketData.saveQuote(
      Quote(
        instrumentId: instrument.internalId,
        price: Money.parse('100', Currency.usd),
        asOf: now.subtract(const Duration(days: 1)),
        provenance: Provenance.sample(now.subtract(const Duration(days: 1))),
      ),
    );
    runner = PortfolioRefreshRunner(
      clock: clock,
      instruments: instruments,
      portfolio: portfolio,
      dividends: DriftDividendRepository(db),
      marketData: marketData,
      providers: ProviderMarketDataService(
        ProviderFallbackChain(registry: registry, coordinator: coordinator),
      ),
      registry: registry,
      revalidator: StaleWhileRevalidateExecutor(
        metadata: DriftCacheMetadataRepository(db),
        policy: CachePolicy(),
      ),
    );
  });

  tearDown(() async {
    await coordinator.dispose();
    await db.close();
  });

  test(
    'keeps cached quote visible until background persistence completes',
    () async {
      final Future<PortfolioRefreshReport> refreshing = runner.refresh();
      await provider.started.future;

      expect(
        (await marketData.watchQuote(instrument.internalId).first)?.price,
        Money.parse('100', Currency.usd),
      );

      provider.complete(
        Success<Quote>(
          Quote(
            instrumentId: instrument.internalId,
            price: Money.parse('101', Currency.usd),
            asOf: now,
            provenance: Provenance(source: 'quotes', fetchedAt: now),
          ),
        ),
      );
      final PortfolioRefreshReport report = await refreshing;

      expect(report.refreshed, 1);
      expect(report.failures, isEmpty);
      expect(
        (await marketData.watchQuote(instrument.internalId).first)?.price,
        Money.parse('101', Currency.usd),
      );
    },
  );

  test('keeps cached quote and reports failure when offline', () async {
    final Future<PortfolioRefreshReport> refreshing = runner.refresh();
    await provider.started.future;
    provider.complete(const Failed<Quote>(NetworkFailure()));

    final PortfolioRefreshReport report = await refreshing;

    expect(report.failures.single, isA<NetworkFailure>());
    expect(
      (await marketData.watchQuote(instrument.internalId).first)?.price,
      Money.parse('100', Currency.usd),
    );
  });
}

final class _QuoteProvider implements QuoteDataProvider {
  final Completer<void> started = Completer<void>();
  final Completer<Result<Quote>> _result = Completer<Result<Quote>>();

  @override
  String get id => 'quotes';

  @override
  Set<ProviderDataType> get capabilities => const <ProviderDataType>{
    ProviderDataType.quote,
  };

  void complete(Result<Quote> result) => _result.complete(result);

  @override
  Future<Result<Quote>> fetchQuote(
    Instrument instrument, {
    required CancellationToken cancellationToken,
  }) async {
    if (!started.isCompleted) started.complete();
    return _result.future;
  }
}
