import 'package:decimal/decimal.dart';
import 'package:dividendendackel/domain/analytics/portfolio_overview.dart';
import 'package:dividendendackel/domain/analytics/portfolio_performance.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const String instrumentId = 'asset';
  final Provenance provenance = Provenance.user(DateTime.utc(2025));

  PortfolioActivity trade({
    required int id,
    required PortfolioActivityType type,
    required DateTime at,
    String price = '100',
    String quantity = '1',
    Currency currency = Currency.eur,
  }) => PortfolioActivity(
    id: id,
    portfolioId: InvestmentPortfolio.defaultId,
    type: type,
    occurredAt: at,
    instrumentId: instrumentId,
    quantity: Decimal.parse(quantity),
    unitPrice: Money.parse(price, currency),
    provenance: provenance,
  );

  PortfolioActivity cash({
    required int id,
    required PortfolioActivityType type,
    required DateTime at,
    required String amount,
    Currency currency = Currency.eur,
  }) => PortfolioActivity(
    id: id,
    portfolioId: InvestmentPortfolio.defaultId,
    type: type,
    occurredAt: at,
    instrumentId: type == PortfolioActivityType.dividend ? instrumentId : null,
    cashAmount: Money.parse(amount, currency),
    provenance: provenance,
  );

  PortfolioPerformanceReport calculate({
    required List<PortfolioActivity> activities,
    Map<Currency, Money>? currentValues,
    Set<Currency>? complete,
    Map<Currency, DateTime>? currentValuationDates,
    List<PortfolioValuationSnapshot> valuations =
        const <PortfolioValuationSnapshot>[],
    PerformanceGrouping grouping = PerformanceGrouping.monthly,
    DateTime? asOf,
  }) => PortfolioPerformanceCalculator.calculate(
    activities: activities,
    instrumentCurrencies: const <String, Currency>{instrumentId: Currency.eur},
    valuations: valuations,
    currentValues:
        currentValues ??
        <Currency, Money>{Currency.eur: Money.parse('110', Currency.eur)},
    completeValueCurrencies: complete ?? <Currency>{Currency.eur},
    currentValuationDates:
        currentValuationDates ??
        <Currency, DateTime>{
          Currency.eur: asOf ?? DateTime.utc(2026, 1, 1),
          if (currentValues?.containsKey(Currency.usd) ?? false)
            Currency.usd: asOf ?? DateTime.utc(2026, 1, 1),
        },
    asOf: asOf ?? DateTime.utc(2026, 1, 1),
    grouping: grouping,
    periodCount: 4,
  );

  test('calculates a one-year money-weighted XIRR from exact cash flows', () {
    final PortfolioCurrencyPerformance result = calculate(
      activities: <PortfolioActivity>[
        trade(
          id: 1,
          type: PortfolioActivityType.purchase,
          at: DateTime.utc(2025, 1, 1),
        ),
      ],
    ).byCurrency[Currency.eur]!;

    expect(result.xirr, isNotNull);
    expect(result.xirr!.rate.percent.toDouble(), closeTo(10, 0.0001));
    expect(result.xirr!.start, DateTime.utc(2025, 1, 1));
    expect(result.xirr!.end, DateTime.utc(2026, 1, 1));
    expect(result.xirr!.formula, contains('net present value'));
    expect(result.currentValue, Money.parse('110', Currency.eur));
  });

  test('neutralizes reversed rows and never mixes currencies', () {
    final PortfolioActivity original = trade(
      id: 1,
      type: PortfolioActivityType.purchase,
      at: DateTime.utc(2025, 1, 1),
    );
    final PortfolioActivity reversal = PortfolioActivity(
      id: 2,
      portfolioId: InvestmentPortfolio.defaultId,
      type: PortfolioActivityType.reversal,
      occurredAt: DateTime.utc(2025, 1, 2),
      reversesActivityId: 1,
      provenance: provenance,
    );
    final PortfolioPerformanceReport report = calculate(
      activities: <PortfolioActivity>[
        original,
        reversal,
        cash(
          id: 3,
          type: PortfolioActivityType.dividend,
          at: DateTime.utc(2025, 12),
          amount: '5',
          currency: Currency.usd,
        ),
      ],
      currentValues: <Currency, Money>{
        Currency.eur: Money.zero(Currency.eur),
        Currency.usd: Money.zero(Currency.usd),
      },
      complete: <Currency>{Currency.eur, Currency.usd},
    );

    expect(report.byCurrency[Currency.eur]!.periods, everyElement(isNotNull));
    expect(
      report.byCurrency[Currency.eur]!.periods.every(
        (PerformancePeriodBreakdown item) => item.purchases.isZero,
      ),
      isTrue,
    );
    expect(
      report.byCurrency[Currency.usd]!.periods
          .map((PerformancePeriodBreakdown item) => item.dividends.amount)
          .fold(Decimal.zero, (Decimal left, Decimal right) => left + right),
      Decimal.fromInt(5),
    );
  });

  test('refuses XIRR when a trade price or current valuation is missing', () {
    final PortfolioActivity unpriced = PortfolioActivity(
      id: 1,
      portfolioId: InvestmentPortfolio.defaultId,
      type: PortfolioActivityType.purchase,
      occurredAt: DateTime.utc(2025, 11),
      instrumentId: instrumentId,
      quantity: Decimal.one,
      provenance: provenance,
    );
    final PortfolioCurrencyPerformance result = calculate(
      activities: <PortfolioActivity>[unpriced],
      complete: const <Currency>{},
    ).byCurrency[Currency.eur]!;

    expect(result.xirr, isNull);
    expect(
      result.limitations,
      contains(contains('excludes unpriced positions')),
    );
    expect(
      result.periods.singleWhere((item) => !item.isEmpty).isComplete,
      isFalse,
    );
  });

  test('chains TTWROR segments and adjusts for a purchase contribution', () {
    final List<PortfolioValuationSnapshot> valuations =
        <PortfolioValuationSnapshot>[
          PortfolioValuationSnapshot(
            scopeId: InvestmentPortfolio.defaultId,
            currency: Currency.eur,
            value: Money.parse('100', Currency.eur),
            observedAt: DateTime.utc(2025, 1, 1),
            positionCount: 1,
            pricedPositionCount: 1,
          ),
          PortfolioValuationSnapshot(
            scopeId: InvestmentPortfolio.defaultId,
            currency: Currency.eur,
            value: Money.parse('120', Currency.eur),
            observedAt: DateTime.utc(2025, 7, 1),
            positionCount: 1,
            pricedPositionCount: 1,
          ),
        ];
    final PortfolioCurrencyPerformance result = calculate(
      activities: <PortfolioActivity>[
        trade(
          id: 1,
          type: PortfolioActivityType.purchase,
          at: DateTime.utc(2025, 7, 1, 12),
          price: '20',
        ),
      ],
      valuations: valuations,
      currentValues: <Currency, Money>{
        Currency.eur: Money.parse('132', Currency.eur),
      },
    ).byCurrency[Currency.eur]!;

    expect(result.ttwror, isNotNull);
    expect(result.ttwror!.rate.percent.toDouble(), closeTo(10, 0.0001));
    expect(result.ttwror!.start, DateTime.utc(2025, 1, 1));
    expect(result.ttwror!.end, DateTime.utc(2026, 1, 1));
    expect(result.ttwror!.formula, contains('chains'));
  });

  test('groups exact monthly, quarterly and annual cash-flow detail', () {
    final List<PortfolioActivity> activities = <PortfolioActivity>[
      trade(
        id: 1,
        type: PortfolioActivityType.purchase,
        at: DateTime.utc(2025, 11, 3),
        price: '25',
        quantity: '4',
      ),
      cash(
        id: 2,
        type: PortfolioActivityType.dividend,
        at: DateTime.utc(2025, 12, 2),
        amount: '5',
      ),
      cash(
        id: 3,
        type: PortfolioActivityType.fee,
        at: DateTime.utc(2025, 12, 2),
        amount: '1',
      ),
      cash(
        id: 4,
        type: PortfolioActivityType.deposit,
        at: DateTime.utc(2025, 12, 2),
        amount: '50',
      ),
    ];

    final PerformancePeriodBreakdown december = calculate(
      activities: activities,
      asOf: DateTime.utc(2025, 12, 20),
    ).byCurrency[Currency.eur]!.periods.first;
    expect(december.dividends, Money.parse('5', Currency.eur));
    expect(december.fees, Money.parse('1', Currency.eur));
    expect(december.deposits, Money.parse('50', Currency.eur));
    expect(december.netInvested, Money.parse('-4', Currency.eur));

    final PerformancePeriodBreakdown quarter = calculate(
      activities: activities,
      grouping: PerformanceGrouping.quarterly,
      asOf: DateTime.utc(2025, 12, 20),
    ).byCurrency[Currency.eur]!.periods.first;
    final PerformancePeriodBreakdown year = calculate(
      activities: activities,
      grouping: PerformanceGrouping.annual,
      asOf: DateTime.utc(2025, 12, 20),
    ).byCurrency[Currency.eur]!.periods.first;
    expect(quarter.purchases, Money.parse('100', Currency.eur));
    expect(year.purchases, Money.parse('100', Currency.eur));
    expect(
      calculate(
        activities: activities,
        asOf: DateTime.utc(2025, 12, 20),
      ).byCurrency[Currency.eur]!.limitations,
      contains(contains('Deposits and withdrawals')),
    );
  });

  test('keeps TTWROR unavailable until two complete valuations exist', () {
    final PortfolioCurrencyPerformance result = calculate(
      activities: <PortfolioActivity>[
        trade(
          id: 1,
          type: PortfolioActivityType.purchase,
          at: DateTime.utc(2025),
        ),
      ],
    ).byCurrency[Currency.eur]!;

    expect(result.ttwror, isNull);
    expect(
      result.limitations,
      contains(contains('at least two complete end-of-day')),
    );
    expect(
      result.limitations,
      contains(contains('Benchmark comparison unavailable')),
    );
  });

  test('requires a complete valuation on every TTWROR cash-flow day', () {
    final PortfolioCurrencyPerformance result = calculate(
      activities: <PortfolioActivity>[
        trade(
          id: 1,
          type: PortfolioActivityType.purchase,
          at: DateTime.utc(2025, 7, 1),
          price: '20',
        ),
      ],
      valuations: <PortfolioValuationSnapshot>[
        PortfolioValuationSnapshot(
          scopeId: InvestmentPortfolio.defaultId,
          currency: Currency.eur,
          value: Money.parse('100', Currency.eur),
          observedAt: DateTime.utc(2025, 1, 1),
          positionCount: 1,
          pricedPositionCount: 1,
        ),
      ],
      currentValues: <Currency, Money>{
        Currency.eur: Money.parse('132', Currency.eur),
      },
    ).byCurrency[Currency.eur]!;

    expect(result.ttwror, isNull);
    expect(
      result.limitations,
      contains(contains('every security cash-flow day')),
    );
  });

  test('does not backdate current holdings to an older quote', () {
    final DateTime now = DateTime.utc(2026, 1, 2);
    const Instrument instrument = Instrument(
      internalId: instrumentId,
      symbol: 'AAA',
      name: 'Asset',
      currency: Currency.eur,
    );
    final Holding holding = Holding(
      instrumentId: instrumentId,
      quantity: Decimal.one,
      provenance: provenance,
    );
    final PortfolioOverview overview = const PortfolioOverviewCalculator()
        .calculate(
          holdings: <Holding>[holding],
          instruments: const <String, Instrument>{instrumentId: instrument},
          quotes: <String, Quote>{
            instrumentId: Quote(
              instrumentId: instrumentId,
              price: Money.parse('100', Currency.eur),
              asOf: DateTime.utc(2026, 1, 1),
              provenance: provenance,
            ),
          },
          dividends: const <DividendEvent>[],
          asOf: now,
        );

    final List<PortfolioValuationSnapshot> snapshots =
        PortfolioPerformanceCalculator.currentValuations(
          scopeId: InvestmentPortfolio.defaultId,
          overview: overview,
          activities: <PortfolioActivity>[
            trade(id: 1, type: PortfolioActivityType.purchase, at: now),
          ],
          instrumentCurrencies: const <String, Currency>{
            instrumentId: Currency.eur,
          },
        );

    expect(snapshots, isEmpty);
  });
}
