import 'package:decimal/decimal.dart';
import 'package:dividendendackel/app/providers.dart';
import 'package:dividendendackel/core/errors/result.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:dividendendackel/features/currency/fx_state.dart';
import 'package:dividendendackel/features/portfolio/portfolio_editor.dart';
import 'package:dividendendackel/features/portfolio/portfolio_screen.dart';
import 'package:dividendendackel/features/settings/currency_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_clock.dart';

void main() {
  final DateTime now = DateTime.utc(2026, 8, 23);
  final Provenance provenance = Provenance(source: 'test', fetchedAt: now);
  const Instrument instrument = Instrument(
    internalId: 'isin:DE0008404005',
    symbol: 'ALV',
    name: 'Allianz SE',
    currency: Currency.eur,
    mic: 'XETR',
    sector: 'Financials',
    country: 'DE',
  );

  Future<_FakePortfolioEditor> pumpPortfolio(
    WidgetTester tester, {
    List<Holding>? holdings,
    List<WatchlistEntry> watchlist = const <WatchlistEntry>[],
    Map<String, Quote>? quotes,
    List<DividendEvent>? dividends,
    List<PortfolioActivity> activities = const <PortfolioActivity>[],
    Currency displayCurrency = Currency.eur,
    List<FxRate> fxRates = const <FxRate>[],
  }) async {
    tester.view.physicalSize = const Size(900, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final _FakePortfolioEditor editor = _FakePortfolioEditor(
      results: const <Instrument>[instrument],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          clockProvider.overrideWithValue(FakeClock(now)),
          displayCurrencyStoreProvider.overrideWithValue(
            _DisplayCurrencyStore(displayCurrency),
          ),
          cachedFxRatesProvider.overrideWith(
            (Ref ref) => Stream<List<FxRate>>.value(fxRates),
          ),
          portfolioEditorProvider.overrideWithValue(editor),
          holdingsProvider.overrideWith(
            (Ref ref) =>
                Stream<List<Holding>>.value(holdings ?? const <Holding>[]),
          ),
          watchlistProvider.overrideWith(
            (Ref ref) => Stream<List<WatchlistEntry>>.value(watchlist),
          ),
          portfolioActivitiesProvider.overrideWith(
            (Ref ref) => Stream<List<PortfolioActivity>>.value(activities),
          ),
          dividendPaymentsForYearProvider.overrideWith(
            (Ref ref, int year) => Stream<List<DividendEvent>>.value(
              dividends ?? const <DividendEvent>[],
            ),
          ),
          instrumentsByIdProvider.overrideWith(
            (Ref ref) => Stream<Map<String, Instrument>>.value(
              <String, Instrument>{instrument.internalId: instrument},
            ),
          ),
          quotesProvider.overrideWith(
            (Ref ref) => Stream<Map<String, Quote>>.value(
              quotes ?? const <String, Quote>{},
            ),
          ),
          upcomingDividendsProvider.overrideWith(
            (Ref ref, int days) => Stream<List<DividendEvent>>.value(
              dividends ?? const <DividendEvent>[],
            ),
          ),
        ],
        child: const MaterialApp(home: PortfolioScreen()),
      ),
    );
    await tester.pump();
    await tester.pump();
    return editor;
  }

  testWidgets('shows value, change, allocation, yield and next dividend', (
    WidgetTester tester,
  ) async {
    final Holding holding = Holding(
      instrumentId: instrument.internalId,
      quantity: Decimal.fromInt(10),
      provenance: provenance,
    );
    final Quote quote = Quote(
      instrumentId: instrument.internalId,
      price: Money.parse('100', Currency.eur),
      previousClose: Money.parse('90', Currency.eur),
      asOf: now,
      provenance: provenance,
    );
    final DividendEvent dividend = DividendEvent(
      instrumentId: instrument.internalId,
      amountPerShare: Money.parse('10', Currency.eur),
      status: DividendStatus.announced,
      paymentDate: now.add(const Duration(days: 20)),
      provenance: provenance,
    );

    await pumpPortfolio(
      tester,
      holdings: <Holding>[holding],
      quotes: <String, Quote>{instrument.internalId: quote},
      dividends: <DividendEvent>[dividend],
    );

    expect(find.text('EUR portfolio'), findsOneWidget);
    expect(find.text('€1000.00'), findsWidgets);
    expect(find.text('100.0%'), findsWidgets);
    expect(find.text('10.0%'), findsWidgets);
    expect(find.textContaining('Next dividend'), findsOneWidget);
    expect(find.textContaining('Gross €100.00'), findsOneWidget);
    expect(find.textContaining('Net (estimated)'), findsWidgets);
    expect(find.text('Announced'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Portfolio health'), 300);
    expect(find.text('Portfolio health'), findsOneWidget);
    expect(
      find.text('Allianz SE is the largest priced position at 100.0%.'),
      findsOneWidget,
    );
    expect(find.text('Financials'), findsOneWidget);
    expect(find.text('DE'), findsOneWidget);
    expect(
      find.text('100.0% of expected dividend income comes from 1 company.'),
      findsOneWidget,
    );
  });

  testWidgets('searches and adds a fractional holding', (
    WidgetTester tester,
  ) async {
    final _FakePortfolioEditor editor = await pumpPortfolio(tester);

    await tester.tap(find.byKey(const ValueKey<String>('add-instrument')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Allianz');
    await tester.tap(find.byTooltip('Search'));
    await tester.pump();
    await tester.pump();
    await tester.tap(find.text('Allianz SE'));
    await tester.pump();
    await tester.enterText(
      find.byKey(const ValueKey<String>('holding-quantity')),
      '2.75',
    );
    await tester.enterText(
      find.byKey(const ValueKey<String>('holding-average-price')),
      '123.45',
    );
    await tester.tap(find.text('Add holding'));
    await tester.pumpAndSettle();

    expect(editor.addedHolding, instrument);
    expect(editor.quantity, Decimal.parse('2.75'));
    expect(editor.averagePrice, Money.parse('123.45', Currency.eur));
    expect(find.text('Allianz SE added to the portfolio.'), findsOneWidget);
  });

  testWidgets('simulates added shares, income and concentration impact', (
    WidgetTester tester,
  ) async {
    final Holding holding = Holding(
      instrumentId: instrument.internalId,
      quantity: Decimal.fromInt(10),
      provenance: provenance,
    );
    final Quote quote = Quote(
      instrumentId: instrument.internalId,
      price: Money.parse('100', Currency.eur),
      asOf: now,
      provenance: provenance,
    );
    final DividendEvent dividend = DividendEvent(
      instrumentId: instrument.internalId,
      amountPerShare: Money.parse('10', Currency.eur),
      status: DividendStatus.announced,
      paymentDate: now.add(const Duration(days: 20)),
      provenance: provenance,
    );
    await pumpPortfolio(
      tester,
      holdings: <Holding>[holding],
      quotes: <String, Quote>{instrument.internalId: quote},
      dividends: <DividendEvent>[dividend],
    );

    await tester.scrollUntilVisible(find.text('Simulate investment'), 250);
    await tester.tap(find.text('Simulate investment'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey<String>('simulation-investment')),
      '500',
    );
    await tester.pump();

    expect(find.text('5.0000'), findsOneWidget);
    expect(find.text('€50.00'), findsOneWidget);
    expect(find.text('€4.17'), findsOneWidget);
    expect(find.text('100.0% → 100.0% (0.0% points)'), findsOneWidget);
    expect(find.textContaining('Scenario only'), findsOneWidget);
  });

  testWidgets('shows a sourced converted total and currency exposure', (
    WidgetTester tester,
  ) async {
    final Holding holding = Holding(
      instrumentId: instrument.internalId,
      quantity: Decimal.fromInt(10),
      provenance: provenance,
    );
    final Quote quote = Quote(
      instrumentId: instrument.internalId,
      price: Money.parse('100', Currency.eur),
      asOf: now,
      provenance: provenance,
    );
    final FxRate rate = FxRate(
      base: Currency.eur,
      quote: Currency.usd,
      rate: Decimal.parse('2'),
      observedAt: DateTime.utc(2026, 8, 22),
      provenance: Provenance(source: 'ecb', fetchedAt: now),
    );

    await pumpPortfolio(
      tester,
      holdings: <Holding>[holding],
      quotes: <String, Quote>{instrument.internalId: quote},
      displayCurrency: Currency.usd,
      fxRates: <FxRate>[rate],
    );
    await tester.pump();

    expect(find.text('USD display view'), findsOneWidget);
    expect(find.text(r'$2000.00'), findsOneWidget);
    expect(find.text('Currency exposure'), findsOneWidget);
    expect(find.textContaining('EUR/USD 2 · ecb · 2026-08-22'), findsOneWidget);
  });

  testWidgets('adds a search result to the watchlist', (
    WidgetTester tester,
  ) async {
    final _FakePortfolioEditor editor = await pumpPortfolio(tester);

    await tester.tap(find.byKey(const ValueKey<String>('add-instrument')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'ALV');
    await tester.tap(find.byTooltip('Search'));
    await tester.pump();
    await tester.pump();
    await tester.tap(find.text('Allianz SE'));
    await tester.pump();
    await tester.tap(find.text('Add to watchlist'));
    await tester.pumpAndSettle();

    expect(editor.addedWatchlist, instrument);
    expect(find.text('Allianz SE added to the watchlist.'), findsOneWidget);
  });

  testWidgets('shows immutable activities and dividend reconciliation', (
    WidgetTester tester,
  ) async {
    final Holding holding = Holding(
      instrumentId: instrument.internalId,
      quantity: Decimal.fromInt(10),
      provenance: provenance,
    );
    final PortfolioActivity purchase = PortfolioActivity(
      id: 1,
      portfolioId: InvestmentPortfolio.defaultId,
      type: PortfolioActivityType.purchase,
      occurredAt: DateTime.utc(2026, 1),
      instrumentId: instrument.internalId,
      quantity: Decimal.fromInt(10),
      unitPrice: Money.parse('100', Currency.eur),
      provenance: provenance,
    );
    final PortfolioActivity actual = PortfolioActivity(
      id: 2,
      portfolioId: InvestmentPortfolio.defaultId,
      type: PortfolioActivityType.dividend,
      occurredAt: DateTime.utc(2026, 5, 20),
      instrumentId: instrument.internalId,
      cashAmount: Money.parse('105', Currency.eur),
      provenance: provenance,
    );
    final DividendEvent expected = DividendEvent(
      instrumentId: instrument.internalId,
      amountPerShare: Money.parse('10', Currency.eur),
      status: DividendStatus.confirmed,
      paymentDate: DateTime.utc(2026, 5, 20),
      provenance: provenance,
    );

    await pumpPortfolio(
      tester,
      holdings: <Holding>[holding],
      dividends: <DividendEvent>[expected],
      activities: <PortfolioActivity>[actual, purchase],
    );
    await tester.scrollUntilVisible(find.text('Activity ledger'), 500);

    expect(find.text('Activity ledger'), findsOneWidget);
    expect(find.textContaining('Expected 100.00 EUR'), findsOneWidget);
    expect(find.textContaining('Actual 105.00 EUR'), findsOneWidget);
    expect(find.textContaining('Purchase · ALV'), findsOneWidget);
    expect(find.byTooltip('Reverse activity'), findsNWidgets(2));
  });

  testWidgets('shows validation errors without closing the add flow', (
    WidgetTester tester,
  ) async {
    final _FakePortfolioEditor editor = await pumpPortfolio(tester);

    await tester.tap(find.byKey(const ValueKey<String>('add-instrument')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'ALV');
    await tester.tap(find.byTooltip('Search'));
    await tester.pump();
    await tester.pump();
    await tester.tap(find.text('Allianz SE'));
    await tester.pump();
    await tester.enterText(
      find.byKey(const ValueKey<String>('holding-quantity')),
      'not-a-number',
    );
    await tester.tap(find.text('Add holding'));
    await tester.pump();

    expect(find.text('Enter valid decimal numbers.'), findsOneWidget);
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(editor.addedHolding, isNull);
  });
}

final class _DisplayCurrencyStore implements DisplayCurrencyStore {
  _DisplayCurrencyStore(this.currency);
  final Currency currency;

  @override
  Future<Currency> load() async => currency;

  @override
  Future<void> save(Currency currency) async {}
}

final class _FakePortfolioEditor implements PortfolioEditor {
  _FakePortfolioEditor({required this.results});

  final List<Instrument> results;
  Instrument? addedHolding;
  Instrument? addedWatchlist;
  Decimal? quantity;
  Money? averagePrice;

  @override
  Future<Result<InstrumentSearchOutcome>> search(String query) async =>
      Success<InstrumentSearchOutcome>(
        InstrumentSearchOutcome(instruments: results),
      );

  @override
  Future<Result<void>> addHolding({
    required Instrument instrument,
    required Decimal quantity,
    Money? averagePurchasePrice,
  }) async {
    addedHolding = instrument;
    this.quantity = quantity;
    averagePrice = averagePurchasePrice;
    return const Success<void>(null);
  }

  @override
  Future<Result<void>> addToWatchlist(Instrument instrument) async {
    addedWatchlist = instrument;
    return const Success<void>(null);
  }
}
