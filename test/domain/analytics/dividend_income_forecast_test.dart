import 'package:decimal/decimal.dart';
import 'package:dividendendackel/domain/analytics/analytics.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final DateTime now = DateTime.utc(2026, 8, 23);
  final Provenance reported = Provenance(source: 'test', fetchedAt: now);
  final Holding holding = Holding(
    instrumentId: 'a',
    quantity: Decimal.fromInt(10),
    provenance: reported,
  );

  DividendEvent event(
    String amount,
    DateTime? paymentDate, {
    DividendStatus status = DividendStatus.confirmed,
    String instrumentId = 'a',
    Currency currency = Currency.eur,
  }) => DividendEvent(
    instrumentId: instrumentId,
    amountPerShare: Money.parse(amount, currency),
    status: status,
    paymentDate: paymentDate,
    provenance: reported,
  );

  DividendForecast forecast(List<DividendEvent> events) => DividendForecast(
    instrumentId: 'a',
    currency: Currency.eur,
    status: DividendForecastStatus.available,
    frequency: DividendFrequency.quarterly,
    events: events,
    asOf: now,
    horizonEnd: DateTime.utc(2028, 8, 23),
    explanation: 'test forecast',
  );

  test('separates paid, confirmed and estimated monthly income', () {
    final PortfolioDividendIncomeForecast result =
        const DividendIncomeForecastCalculator().calculate(
          holdings: <Holding>[holding],
          historicalEvents: <DividendEvent>[
            event('1', DateTime.utc(2026, 8, 5)),
          ],
          forecasts: <DividendForecast>[
            forecast(<DividendEvent>[
              event(
                '2',
                DateTime.utc(2026, 8, 28),
                status: DividendStatus.announced,
              ),
              event(
                '3',
                DateTime.utc(2026, 9, 10),
                status: DividendStatus.historicallyEstimated,
              ),
            ]),
          ],
          asOf: now,
        );

    expect(result.months, hasLength(24));
    expect(result.months.first.start, DateTime(2026, 8));
    expect(result.horizonEnd, DateTime(2028, 8));
    final DividendIncomeBreakdown august =
        result.months.first.byCurrency[Currency.eur]!;
    expect(august.paid, Money.parse('10', Currency.eur));
    expect(august.confirmedUpcoming, Money.parse('20', Currency.eur));
    expect(august.estimated, Money.zero(Currency.eur));
    expect(
      result.months[1].byCurrency[Currency.eur]!.estimated,
      Money.parse('30', Currency.eur),
    );
  });

  test('provides calendar quarter, year, annual share and cumulative data', () {
    final PortfolioDividendIncomeForecast result =
        const DividendIncomeForecastCalculator().calculate(
          holdings: <Holding>[holding],
          historicalEvents: const <DividendEvent>[],
          forecasts: <DividendForecast>[
            forecast(<DividendEvent>[
              event(
                '1',
                DateTime.utc(2026, 9, 1),
                status: DividendStatus.announced,
              ),
              event(
                '3',
                DateTime.utc(2026, 12, 1),
                status: DividendStatus.historicallyEstimated,
              ),
            ]),
          ],
          asOf: now,
        );

    expect(result.quarters.first.start, DateTime(2026, 7));
    expect(
      result.quarters.first.byCurrency[Currency.eur]!.total,
      Money.parse('10', Currency.eur),
    );
    expect(
      result.years.first.byCurrency[Currency.eur]!.total,
      Money.parse('40', Currency.eur),
    );
    expect(
      result.months[1].shareOfYearByCurrency[Currency.eur]!.format(),
      '25.0%',
    );
    expect(
      result.months[4].cumulativeByCurrency[Currency.eur],
      Money.parse('40', Currency.eur),
    );
  });

  test('calculates TTM and year-over-year only from confirmed payments', () {
    final PortfolioDividendIncomeForecast result =
        const DividendIncomeForecastCalculator().calculate(
          holdings: <Holding>[holding],
          historicalEvents: <DividendEvent>[
            event('2', DateTime.utc(2026, 7, 1)),
            event('1', DateTime.utc(2025, 7, 1)),
            event(
              '99',
              DateTime.utc(2026, 6, 1),
              status: DividendStatus.historicallyEstimated,
            ),
            event('99', null),
          ],
          forecasts: const <DividendForecast>[],
          asOf: now,
        );

    expect(
      result.trailingTwelveMonths[Currency.eur],
      Money.parse('20', Currency.eur),
    );
    expect(
      result.previousTrailingTwelveMonths[Currency.eur],
      Money.parse('10', Currency.eur),
    );
    expect(result.yearOverYearChange[Currency.eur]!.format(), '100.0%');
  });

  test('keeps currencies separate and ignores instruments not held', () {
    final Holding usdHolding = Holding(
      instrumentId: 'usd',
      quantity: Decimal.one,
      provenance: reported,
    );
    final PortfolioDividendIncomeForecast result =
        const DividendIncomeForecastCalculator().calculate(
          holdings: <Holding>[holding, usdHolding],
          historicalEvents: <DividendEvent>[
            event('1', DateTime.utc(2026, 7, 1)),
            event(
              '5',
              DateTime.utc(2026, 7, 1),
              instrumentId: 'usd',
              currency: Currency.usd,
            ),
            event('100', DateTime.utc(2026, 7, 1), instrumentId: 'not-held'),
          ],
          forecasts: const <DividendForecast>[],
          asOf: now,
        );

    expect(result.trailingTwelveMonths.keys, <Currency>{
      Currency.eur,
      Currency.usd,
    });
    expect(
      result.trailingTwelveMonths[Currency.usd],
      Money.parse('5', Currency.usd),
    );
  });
}
