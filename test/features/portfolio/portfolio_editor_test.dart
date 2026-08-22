import 'package:decimal/decimal.dart';
import 'package:dividendendackel/core/errors/failure.dart';
import 'package:dividendendackel/core/errors/result.dart';
import 'package:dividendendackel/data/database/app_database.dart';
import 'package:dividendendackel/data/repositories/drift_instrument_repository.dart';
import 'package:dividendendackel/data/repositories/drift_portfolio_repository.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:dividendendackel/domain/repositories/repositories.dart';
import 'package:dividendendackel/features/portfolio/portfolio_editor.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_clock.dart';

void main() {
  late AppDatabase db;
  late InstrumentRepository instruments;
  late PortfolioRepository portfolio;
  late FakeClock clock;

  const Instrument localInstrument = Instrument(
    internalId: 'isin:US0000000001',
    symbol: 'AAA',
    name: 'Alpha Local',
    currency: Currency.usd,
  );
  const Instrument liveInstrument = Instrument(
    internalId: 'isin:US0000000001',
    symbol: 'AAA',
    name: 'Alpha Live',
    currency: Currency.usd,
    providerMappings: <ProviderMapping>[
      ProviderMapping(providerId: 'sec', symbol: 'AAA'),
    ],
  );
  const Instrument secondInstrument = Instrument(
    internalId: 'isin:US0000000002',
    symbol: 'BBB',
    name: 'Beta',
    currency: Currency.usd,
  );

  DefaultPortfolioEditor editorWith(
    Future<Result<List<Instrument>>> Function(String query) liveSearch,
  ) => DefaultPortfolioEditor(
    instruments: instruments,
    portfolio: portfolio,
    liveSearch: liveSearch,
    clock: clock,
  );

  setUp(() {
    db = AppDatabase.withExecutor(NativeDatabase.memory());
    instruments = DriftInstrumentRepository(db);
    portfolio = DriftPortfolioRepository(db);
    clock = FakeClock(DateTime.utc(2026, 8, 23, 12));
  });

  tearDown(() => db.close());

  test('merges local and live search with fresh metadata winning', () async {
    await instruments.save(localInstrument);
    final DefaultPortfolioEditor editor = editorWith(
      (_) async => const Success<List<Instrument>>(<Instrument>[
        liveInstrument,
        secondInstrument,
      ]),
    );

    final InstrumentSearchOutcome outcome = (await editor.search(
      'AAA',
    )).valueOrNull!;

    expect(outcome.instruments, <Instrument>[liveInstrument, secondInstrument]);
    expect(outcome.instruments.first.name, 'Alpha Live');
    expect(outcome.warning, isNull);
  });

  test('keeps local results when live search is unavailable', () async {
    await instruments.save(localInstrument);
    final DefaultPortfolioEditor editor = editorWith(
      (_) async => const Failed<List<Instrument>>(NetworkFailure()),
    );

    final InstrumentSearchOutcome outcome = (await editor.search(
      'Alpha',
    )).valueOrNull!;

    expect(outcome.instruments, <Instrument>[localInstrument]);
    expect(outcome.warning, isA<NetworkFailure>());
  });

  test('adds an exact holding and persists a live instrument first', () async {
    final DefaultPortfolioEditor editor = editorWith(
      (_) async => const Success<List<Instrument>>(<Instrument>[]),
    );

    final Result<void> result = await editor.addHolding(
      instrument: liveInstrument,
      quantity: Decimal.parse('2.75'),
      averagePurchasePrice: Money.parse('123.45', Currency.usd),
    );

    expect(result.isSuccess, isTrue);
    expect(
      (await instruments.findById(liveInstrument.internalId)).valueOrNull,
      liveInstrument,
    );
    final Holding saved = (await portfolio.watchHoldings().first).single;
    expect(saved.quantity, Decimal.parse('2.75'));
    expect(saved.averagePurchasePrice, Money.parse('123.45', Currency.usd));
    expect(saved.provenance.source, Provenance.userSource);
    expect(saved.provenance.fetchedAt, clock.now());
  });

  test('validates holding quantity and purchase-price currency', () async {
    final DefaultPortfolioEditor editor = editorWith(
      (_) async => const Success<List<Instrument>>(<Instrument>[]),
    );

    expect(
      (await editor.addHolding(
        instrument: liveInstrument,
        quantity: Decimal.zero,
      )).failureOrNull,
      isA<InvalidInstrumentFailure>(),
    );
    expect(
      (await editor.addHolding(
        instrument: liveInstrument,
        quantity: Decimal.one,
        averagePurchasePrice: Money.parse('-1', Currency.usd),
      )).failureOrNull,
      isA<InvalidInstrumentFailure>(),
    );
    expect(
      (await editor.addHolding(
        instrument: liveInstrument,
        quantity: Decimal.one,
        averagePurchasePrice: Money.parse('1', Currency.eur),
      )).failureOrNull,
      isA<InvalidInstrumentFailure>(),
    );
    expect(await portfolio.watchHoldings().first, isEmpty);
  });

  test(
    'adds a provider result to the watchlist with a user timestamp',
    () async {
      final DefaultPortfolioEditor editor = editorWith(
        (_) async => const Success<List<Instrument>>(<Instrument>[]),
      );

      expect((await editor.addToWatchlist(secondInstrument)).isSuccess, isTrue);

      final WatchlistEntry entry =
          (await portfolio.watchWatchlist().first).single;
      expect(entry.instrumentId, secondInstrument.internalId);
      expect(entry.addedAt, clock.now());
      expect(entry.provenance.source, Provenance.userSource);
      expect(
        (await instruments.findById(secondInstrument.internalId)).valueOrNull,
        secondInstrument,
      );
    },
  );
}
