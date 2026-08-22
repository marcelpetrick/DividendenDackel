import 'package:decimal/decimal.dart';
import 'package:dividendendackel/domain/analytics/analytics.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const String instrumentId = 'isin:US0000000001';
  final DateTime asOf = DateTime.utc(2026, 8, 23);
  final Provenance provenance = Provenance(source: 'test', fetchedAt: asOf);
  const DividendGrowthCalculator calculator = DividendGrowthCalculator();

  DividendEvent annual(
    int year,
    String amount, {
    String id = instrumentId,
    Currency currency = Currency.usd,
    DividendStatus status = DividendStatus.confirmed,
    DateTime? exDate,
    DateTime? periodEnd,
  }) => DividendEvent(
    instrumentId: id,
    amountPerShare: Money.parse(amount, currency),
    status: status,
    exDate: exDate ?? DateTime.utc(year, 6),
    reportedPeriodEnd: periodEnd,
    frequency: DividendFrequency.annual,
    provenance: provenance,
  );

  DividendGrowthAnalysis calculate(List<DividendEvent> events) =>
      calculator.calculate(
        instrumentId: instrumentId,
        currency: Currency.usd,
        events: events,
        asOf: asOf,
      );

  test('calculates period-labelled 3, 5 and 10 year CAGR', () {
    Decimal amount = Decimal.one;
    final List<DividendEvent> events = <DividendEvent>[];
    for (int year = 2015; year <= 2025; year++) {
      events.add(annual(year, amount.toString()));
      amount *= Decimal.parse('1.1');
    }

    final DividendGrowthAnalysis result = calculate(events);

    expect(result.cagrs.keys, <int>{3, 5, 10});
    for (final DividendCagr cagr in result.cagrs.values) {
      expect(cagr.rate.rate, closeToDecimal(Decimal.parse('0.1')));
      expect(cagr.endYear - cagr.startYear, cagr.periodYears);
      expect(cagr.format(), '${cagr.periodYears}Y dividend CAGR: +10.0% p.a.');
    }
  });

  test('aggregates payments before comparing annual dividends', () {
    final List<DividendEvent> events = <DividendEvent>[
      for (int year = 2022; year <= 2025; year++)
        for (final int month in <int>[3, 6, 9, 12])
          DividendEvent(
            instrumentId: instrumentId,
            amountPerShare: Money.parse(
              year == 2025 ? '0.30' : '0.25',
              Currency.usd,
            ),
            status: DividendStatus.confirmed,
            exDate: DateTime.utc(year, month),
            frequency: DividendFrequency.quarterly,
            provenance: provenance,
          ),
    ];

    final DividendGrowthAnalysis result = calculate(events);

    expect(result.annualTotals.last.amount, Money.parse('1.20', Currency.usd));
    expect(
      result.cagrs[3]!.beginningAnnualDividend,
      Money.parse('1', Currency.usd),
    );
    expect(
      result.cagrs[3]!.endingAnnualDividend,
      Money.parse('1.2', Currency.usd),
    );
  });

  test('excludes estimates and the incomplete current calendar year', () {
    final DividendGrowthAnalysis result = calculate(<DividendEvent>[
      annual(2024, '1'),
      annual(2025, '1.1'),
      annual(2025, '99', status: DividendStatus.historicallyEstimated),
      annual(2026, '8', status: DividendStatus.announced),
    ]);

    expect(
      result.annualTotals.map((AnnualDividendTotal total) => total.year),
      <int>[2024, 2025],
    );
    expect(result.annualTotals.last.amount, Money.parse('1.1', Currency.usd));
  });

  test('uses reporting period instead of an unrelated event date', () {
    final DividendGrowthAnalysis result = calculate(<DividendEvent>[
      annual(
        2026,
        '2.5',
        exDate: DateTime.utc(2026, 2),
        periodEnd: DateTime.utc(2025, 12, 31),
      ),
    ]);

    expect(result.annualTotals.single.year, 2025);
  });

  test('reports latest increase, latest cut and no-cut streak', () {
    final DividendGrowthAnalysis result = calculate(<DividendEvent>[
      annual(2019, '1.00'),
      annual(2020, '1.10'),
      annual(2021, '0.90'),
      annual(2022, '0.90'),
      annual(2023, '1.00'),
    ]);

    expect(result.yearsWithoutCut, 2);
    expect(result.latestIncrease?.previousYear, 2022);
    expect(result.latestIncrease?.currentYear, 2023);
    expect(result.latestIncrease?.rate?.format(withSign: true), '+11.1%');
    expect(result.latestDecrease?.previousYear, 2020);
    expect(result.latestDecrease?.currentYear, 2021);
    expect(result.latestDecrease?.rate?.format(withSign: true), '-18.2%');
  });

  test('missing years break streaks and suppress misleading CAGR', () {
    final DividendGrowthAnalysis result = calculate(<DividendEvent>[
      annual(2020, '1'),
      annual(2022, '1.1'),
      annual(2025, '1.2'),
    ]);

    expect(result.yearsWithoutCut, 0);
    expect(result.cagrs, isEmpty);
    expect(result.latestIncrease, isNull);
    expect(result.latestDecrease, isNull);
  });

  test('zero starting values do not produce an undefined CAGR', () {
    final DividendGrowthAnalysis result = calculate(<DividendEvent>[
      annual(2022, '0'),
      annual(2023, '1'),
      annual(2024, '1'),
      annual(2025, '1'),
    ]);

    expect(result.cagrs[3], isNull);
    expect(result.latestIncrease?.rate, isNull);
  });

  test(
    'returns an explicit empty analysis when no reported history exists',
    () {
      final DividendGrowthAnalysis result = calculate(<DividendEvent>[
        annual(2027, '1', status: DividendStatus.historicallyEstimated),
      ]);

      expect(result.annualTotals, isEmpty);
      expect(result.cagrs, isEmpty);
      expect(result.yearsWithoutCut, 0);
    },
  );

  test('ignores other instruments but rejects mixed target currencies', () {
    final DividendGrowthAnalysis valid = calculate(<DividendEvent>[
      annual(2025, '1'),
      annual(2025, '2', id: 'other', currency: Currency.eur),
    ]);
    expect(valid.annualTotals.single.amount.currency, Currency.usd);

    expect(
      () =>
          calculate(<DividendEvent>[annual(2025, '1', currency: Currency.eur)]),
      throwsArgumentError,
    );
  });

  test('rejects negative reported dividends', () {
    expect(
      () => calculate(<DividendEvent>[annual(2025, '-1')]),
      throwsArgumentError,
    );
  });
}

Matcher closeToDecimal(Decimal expected) => predicate<Decimal>(
  (Decimal actual) => (actual - expected).abs() <= Decimal.parse('0.000000001'),
  'within 0.000000001 of $expected',
);
