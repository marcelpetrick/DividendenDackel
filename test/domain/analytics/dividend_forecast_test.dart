import 'package:decimal/decimal.dart';
import 'package:dividendendackel/domain/analytics/analytics.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const String instrumentId = 'isin:US0000000001';
  final Provenance reportedProvenance = Provenance(
    source: 'provider',
    fetchedAt: DateTime.utc(2026, 1, 1),
  );

  DividendEvent payment({
    required int year,
    required int month,
    required int day,
    required String amount,
    DividendFrequency frequency = DividendFrequency.quarterly,
    DividendStatus status = DividendStatus.confirmed,
    Currency currency = Currency.usd,
    DateTime? paymentDate,
    bool paymentDateOnly = false,
  }) {
    final DateTime exDate = DateTime.utc(year, month, day);
    return DividendEvent(
      instrumentId: instrumentId,
      amountPerShare: Money.parse(amount, currency),
      status: status,
      exDate: paymentDateOnly ? null : exDate,
      paymentDate:
          paymentDate ??
          (paymentDateOnly ? exDate : exDate.add(const Duration(days: 7))),
      frequency: frequency,
      provenance: reportedProvenance,
    );
  }

  List<DividendEvent> quarterlyHistory() {
    final Map<int, String> amounts = <int, String>{
      2022: '0.25',
      2023: '0.275',
      2024: '0.3025',
      2025: '0.33275',
    };
    return <DividendEvent>[
      for (final MapEntry<int, String> year in amounts.entries)
        for (final int month in <int>[2, 5, 8, 11])
          payment(year: year.key, month: month, day: 10, amount: year.value),
    ];
  }

  test(
    'uses instrument CAGR, frequency and seasonality for 24-month events',
    () {
      final DividendForecast forecast = DividendForecastEngine().forecast(
        instrumentId: instrumentId,
        currency: Currency.usd,
        events: quarterlyHistory(),
        asOf: DateTime.utc(2026, 6, 1),
      );

      expect(forecast.status, DividendForecastStatus.available);
      expect(forecast.frequency, DividendFrequency.quarterly);
      expect(forecast.horizonEnd, DateTime.utc(2028, 6, 1));
      expect(forecast.events, hasLength(8));
      expect(forecast.reportedEvents, isEmpty);
      expect(forecast.estimatedEvents, hasLength(8));
      expect(forecast.confidence, Confidence.medium);
      expect(
        forecast.growthAssumption?.basis,
        ForecastGrowthBasis.dividendCagr,
      );
      expect(forecast.growthAssumption?.cagrPeriodYears, 3);
      expect(forecast.explanation, contains('3-year dividend CAGR'));
      expect(
        forecast.events.first.amountPerShare.amount,
        Decimal.parse('0.366025'),
      );
      expect(forecast.events.first.exDate, DateTime.utc(2026, 8, 10));
      expect(forecast.events.first.paymentDate, DateTime.utc(2026, 8, 17));
      expect(forecast.events.first.provenance.source, 'forecast');
      expect(forecast.events.first.provenance.confidence, Confidence.medium);
    },
  );

  test('uses the explicit default rate when CAGR history is too short', () {
    final DividendForecast forecast = DividendForecastEngine().forecast(
      instrumentId: instrumentId,
      currency: Currency.usd,
      events: <DividendEvent>[
        payment(
          year: 2025,
          month: 5,
          day: 10,
          amount: '1',
          frequency: DividendFrequency.annual,
        ),
      ],
      asOf: DateTime.utc(2026, 6, 1),
    );

    expect(forecast.growthAssumption?.basis, ForecastGrowthBasis.defaultRate);
    expect(forecast.growthAssumption?.rate, Percentage.parsePercent('3'));
    expect(forecast.explanation, contains('documented default growth rate'));
    expect(forecast.confidence, Confidence.low);
    expect(
      forecast.events.map((DividendEvent event) => event.amountPerShare.amount),
      <Decimal>[Decimal.parse('1.0609'), Decimal.parse('1.092727')],
    );
  });

  test('keeps an announced value and uses it as the next estimate basis', () {
    final DividendEvent announced = payment(
      year: 2026,
      month: 5,
      day: 12,
      amount: '1.20',
      frequency: DividendFrequency.annual,
      status: DividendStatus.announced,
    );
    final DividendForecast forecast = DividendForecastEngine().forecast(
      instrumentId: instrumentId,
      currency: Currency.usd,
      events: <DividendEvent>[
        payment(
          year: 2025,
          month: 5,
          day: 10,
          amount: '1',
          frequency: DividendFrequency.annual,
        ),
        announced,
      ],
      asOf: DateTime.utc(2026, 1, 1),
    );

    expect(forecast.events, hasLength(2));
    expect(forecast.reportedEvents.single, same(announced));
    expect(forecast.estimatedEvents.single.exDate, DateTime.utc(2027, 5, 10));
    expect(
      forecast.estimatedEvents.single.amountPerShare.amount,
      Decimal.parse('1.236'),
    );
  });

  test('uses current-year reported payments as the next slot basis', () {
    final List<DividendEvent> events = quarterlyHistory()
      ..add(payment(year: 2026, month: 2, day: 11, amount: '0.40'));
    final DividendForecast forecast = DividendForecastEngine().forecast(
      instrumentId: instrumentId,
      currency: Currency.usd,
      events: events,
      asOf: DateTime.utc(2026, 6, 1),
      horizonMonths: 12,
    );

    final DividendEvent february2027 = forecast.events.singleWhere(
      (DividendEvent event) => event.exDate == DateTime.utc(2027, 2, 10),
    );
    expect(february2027.amountPerShare.amount, Decimal.parse('0.44'));
  });

  test('reports no history without turning estimates into evidence', () {
    final DividendForecast forecast = DividendForecastEngine().forecast(
      instrumentId: instrumentId,
      currency: Currency.usd,
      events: <DividendEvent>[
        payment(
          year: 2027,
          month: 5,
          day: 10,
          amount: '1',
          frequency: DividendFrequency.annual,
          status: DividendStatus.historicallyEstimated,
        ),
      ],
      asOf: DateTime.utc(2026, 1, 1),
    );

    expect(forecast.status, DividendForecastStatus.noReportedHistory);
    expect(forecast.events, isEmpty);
    expect(forecast.growthAssumption, isNull);
    expect(forecast.confidence, isNull);
  });

  test('does not invent dates for an irregular schedule', () {
    final DividendForecast forecast = DividendForecastEngine().forecast(
      instrumentId: instrumentId,
      currency: Currency.usd,
      events: <DividendEvent>[
        payment(
          year: 2024,
          month: 3,
          day: 1,
          amount: '1',
          frequency: DividendFrequency.irregular,
        ),
        payment(
          year: 2025,
          month: 9,
          day: 1,
          amount: '1',
          frequency: DividendFrequency.irregular,
        ),
      ],
      asOf: DateTime.utc(2026, 1, 1),
    );

    expect(forecast.status, DividendForecastStatus.irregularSchedule);
    expect(forecast.events, isEmpty);
    expect(forecast.explanation, contains('did not invent future dates'));
  });

  test('reports missing seasonality for undated annual facts', () {
    final DividendForecast forecast = DividendForecastEngine().forecast(
      instrumentId: instrumentId,
      currency: Currency.usd,
      events: <DividendEvent>[
        DividendEvent(
          instrumentId: instrumentId,
          amountPerShare: Money.parse('2', Currency.usd),
          status: DividendStatus.confirmed,
          reportedPeriodStart: DateTime.utc(2024, 1, 1),
          reportedPeriodEnd: DateTime.utc(2024, 12, 31),
          frequency: DividendFrequency.annual,
          provenance: reportedProvenance,
        ),
      ],
      asOf: DateTime.utc(2026, 1, 1),
    );

    expect(forecast.status, DividendForecastStatus.missingSeasonality);
    expect(forecast.events, isEmpty);
    expect(forecast.explanation, contains('dated payments'));
  });

  test('supports payment-date-only history without fabricating ex-dates', () {
    final DividendForecast forecast = DividendForecastEngine().forecast(
      instrumentId: instrumentId,
      currency: Currency.usd,
      events: <DividendEvent>[
        for (int year = 2023; year <= 2025; year++)
          for (final int month in <int>[3, 6, 9, 12])
            payment(
              year: year,
              month: month,
              day: 20,
              amount: '0.25',
              paymentDateOnly: true,
            ),
      ],
      asOf: DateTime.utc(2026, 1, 1),
      horizonMonths: 12,
    );

    expect(forecast.status, DividendForecastStatus.available);
    expect(forecast.events, hasLength(4));
    expect(
      forecast.events.every((DividendEvent event) => event.exDate == null),
      isTrue,
    );
    expect(
      forecast.events.map((DividendEvent event) => event.paymentDate?.month),
      <int>[3, 6, 9, 12],
    );
  });

  test('infers a standard frequency when providers omit the label', () {
    final DividendForecast forecast = DividendForecastEngine().forecast(
      instrumentId: instrumentId,
      currency: Currency.usd,
      events: <DividendEvent>[
        for (int year = 2024; year <= 2025; year++)
          for (final int month in <int>[2, 5, 8, 11])
            payment(
              year: year,
              month: month,
              day: 10,
              amount: '0.25',
              frequency: DividendFrequency.unknown,
            ),
      ],
      asOf: DateTime.utc(2026, 1, 1),
      horizonMonths: 12,
    );

    expect(forecast.frequency, DividendFrequency.quarterly);
    expect(forecast.events, hasLength(4));
  });

  test('clamps leap-day seasonality and keeps the horizon half-open', () {
    final DividendForecast forecast = DividendForecastEngine().forecast(
      instrumentId: instrumentId,
      currency: Currency.usd,
      events: <DividendEvent>[
        payment(
          year: 2024,
          month: 2,
          day: 29,
          amount: '1',
          frequency: DividendFrequency.annual,
        ),
      ],
      asOf: DateTime.utc(2025, 1, 1),
      horizonMonths: 12,
    );

    expect(forecast.events.single.exDate, DateTime.utc(2025, 2, 28));
    expect(
      forecast.events.every(
        (DividendEvent event) => event.exDate!.isBefore(forecast.horizonEnd),
      ),
      isTrue,
    );
  });

  test('keeps a payment in range when its ex-date was before the horizon', () {
    final DividendEvent announced = payment(
      year: 2025,
      month: 12,
      day: 25,
      amount: '1.1',
      frequency: DividendFrequency.annual,
      status: DividendStatus.announced,
      paymentDate: DateTime.utc(2026, 1, 5),
    );
    final DividendForecast forecast = DividendForecastEngine().forecast(
      instrumentId: instrumentId,
      currency: Currency.usd,
      events: <DividendEvent>[
        payment(
          year: 2024,
          month: 12,
          day: 25,
          amount: '1',
          frequency: DividendFrequency.annual,
          paymentDate: DateTime.utc(2025, 1, 5),
        ),
        announced,
      ],
      asOf: DateTime.utc(2026, 1, 1),
      horizonMonths: 12,
    );

    expect(forecast.events, <DividendEvent>[announced]);
  });

  test('treats equally conflicting provider frequencies as irregular', () {
    final DividendForecast forecast = DividendForecastEngine().forecast(
      instrumentId: instrumentId,
      currency: Currency.usd,
      events: <DividendEvent>[
        payment(
          year: 2024,
          month: 5,
          day: 1,
          amount: '1',
          frequency: DividendFrequency.annual,
        ),
        payment(
          year: 2025,
          month: 5,
          day: 1,
          amount: '1',
          frequency: DividendFrequency.semiAnnual,
        ),
      ],
      asOf: DateTime.utc(2026, 1, 1),
    );

    expect(forecast.status, DividendForecastStatus.irregularSchedule);
  });

  test('validates currency, amounts, rates and horizon', () {
    expect(
      () => DividendForecastEngine(
        fallbackGrowthRate: Percentage.parsePercent('-100'),
      ),
      throwsArgumentError,
    );
    expect(
      () => DividendForecastEngine().forecast(
        instrumentId: instrumentId,
        currency: Currency.usd,
        events: <DividendEvent>[
          payment(
            year: 2025,
            month: 1,
            day: 1,
            amount: '1',
            currency: Currency.eur,
          ),
        ],
        asOf: DateTime.utc(2026),
      ),
      throwsArgumentError,
    );
    expect(
      () => DividendForecastEngine().forecast(
        instrumentId: instrumentId,
        currency: Currency.usd,
        events: <DividendEvent>[
          payment(year: 2025, month: 1, day: 1, amount: '-1'),
        ],
        asOf: DateTime.utc(2026),
      ),
      throwsArgumentError,
    );
    expect(
      () => DividendForecastEngine().forecast(
        instrumentId: instrumentId,
        currency: Currency.usd,
        events: const <DividendEvent>[],
        asOf: DateTime.utc(2026),
        horizonMonths: 0,
      ),
      throwsArgumentError,
    );
  });
}
