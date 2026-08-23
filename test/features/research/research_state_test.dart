import 'package:decimal/decimal.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:dividendendackel/features/research/research_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final DateTime now = DateTime.utc(2026, 8, 23, 12);
  final Provenance sample = Provenance.sample(now);
  const Instrument instrument = Instrument(
    internalId: 'instrument',
    symbol: 'TEST',
    name: 'Test AG',
    currency: Currency.eur,
  );

  DividendEvent dividend({
    required String amount,
    DateTime? paymentDate,
    int? reportedYear,
  }) => DividendEvent(
    instrumentId: instrument.internalId,
    amountPerShare: Money.parse(amount, Currency.eur),
    status: DividendStatus.confirmed,
    paymentDate: paymentDate,
    reportedPeriodEnd: reportedYear == null
        ? null
        : DateTime.utc(reportedYear, 12, 31),
    provenance: sample,
  );

  test('builds dividend and event-risk dimensions from cached records', () {
    final List<DividendEvent> dividends = <DividendEvent>[
      for (int year = 2022; year <= 2025; year++)
        dividend(amount: '${year - 2020}', reportedYear: year),
      dividend(amount: '4', paymentDate: now.add(const Duration(days: 40))),
    ];
    final List<NewsItem> news = <NewsItem>[
      NewsItem(
        id: 'guidance',
        headline: 'Outlook updated',
        sourceName: 'Publisher',
        publishedAt: now.subtract(const Duration(days: 1)),
        url: Uri.parse('https://example.test/guidance'),
        category: NewsCategory.guidance,
        relatedInstrumentIds: const <String>['instrument'],
        provenance: sample,
      ),
    ];
    final ResearchSnapshot result = buildResearchSnapshot(
      instrument: instrument,
      quote: Quote(
        instrumentId: instrument.internalId,
        price: Money.parse('100', Currency.eur),
        previousClose: Money.parse('99', Currency.eur),
        asOf: now,
        provenance: sample,
      ),
      dividends: dividends,
      earnings: <EarningsEvent>[
        EarningsEvent(
          instrumentId: instrument.internalId,
          scheduledFor: now.add(const Duration(days: 5)),
          status: EarningsStatus.confirmed,
          provenance: sample,
        ),
      ],
      news: news,
      filings: <Filing>[
        Filing(
          id: 'filing',
          instrumentId: instrument.internalId,
          formType: '8-K',
          filedAt: now.subtract(const Duration(days: 2)),
          url: Uri.parse('https://example.test/filing'),
          provenance: sample,
        ),
      ],
      asOf: now,
    )!;

    expect(result.availableDimensions, <ResearchDimension>{
      ResearchDimension.dividend,
      ResearchDimension.eventRisk,
    });
    expect(
      result[ResearchDimension.dividend]!.factors.map(
        (ScoreFactor factor) => factor.label,
      ),
      contains('Forward yield 4.0%'),
    );
    expect(
      result[ResearchDimension.eventRisk]!.risks.map(
        (ScoreFactor factor) => factor.label,
      ),
      containsAll(<String>[
        'Earnings are due in 5 days',
        'Recent guidance change observed',
        'Recent material filing observed',
      ]),
    );
    expect(result.provenance.source, Provenance.sampleSource);
    expect(result.provenance.confidence, Confidence.medium);
  });

  test('does not infer a safe event score from an ordinary daily quote', () {
    final ResearchSnapshot? result = buildResearchSnapshot(
      instrument: instrument,
      quote: Quote(
        instrumentId: instrument.internalId,
        price: Money(Decimal.fromInt(100), Currency.eur),
        previousClose: Money(Decimal.fromInt(99), Currency.eur),
        asOf: now,
        provenance: sample,
      ),
      dividends: const <DividendEvent>[],
      earnings: const <EarningsEvent>[],
      news: const <NewsItem>[],
      filings: const <Filing>[],
      asOf: now,
    );

    expect(result, isNull);
  });

  test('returns no assessment when every evidence source is empty', () {
    expect(
      buildResearchSnapshot(
        instrument: instrument,
        quote: null,
        dividends: const <DividendEvent>[],
        earnings: const <EarningsEvent>[],
        news: const <NewsItem>[],
        filings: const <Filing>[],
        asOf: now,
      ),
      isNull,
    );
  });

  test(
    'flags an attributable unusual daily movement without claiming cause',
    () {
      final ResearchSnapshot result = buildResearchSnapshot(
        instrument: instrument,
        quote: Quote(
          instrumentId: instrument.internalId,
          price: Money.parse('90', Currency.eur),
          previousClose: Money.parse('100', Currency.eur),
          asOf: now,
          provenance: sample,
        ),
        dividends: const <DividendEvent>[],
        earnings: const <EarningsEvent>[],
        news: const <NewsItem>[],
        filings: const <Filing>[],
        asOf: now,
      )!;

      final ScoreFactor factor =
          result[ResearchDimension.eventRisk]!.risks.single;
      expect(factor.label, 'Abnormal volatility observed');
      expect(factor.detail, contains('not its likely outcome'));
    },
  );
}
