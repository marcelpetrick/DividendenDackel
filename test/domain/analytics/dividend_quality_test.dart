import 'package:dividendendackel/domain/analytics/analytics.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final DateTime now = DateTime.utc(2026, 8, 23);
  final Provenance provenance = Provenance(source: 'test', fetchedAt: now);

  List<DividendEvent> annual(List<String> amounts) => <DividendEvent>[
    for (int index = 0; index < amounts.length; index++)
      DividendEvent(
        instrumentId: 'a',
        amountPerShare: Money.parse(amounts[index], Currency.eur),
        status: DividendStatus.confirmed,
        paymentDate: DateTime.utc(2025 - (amounts.length - 1) + index, 5),
        frequency: DividendFrequency.annual,
        provenance: provenance,
      ),
  ];

  test('rewards durable growth and explains every contributing factor', () {
    final ScoredAssessment result = const DividendQualityCalculator().calculate(
      instrumentId: 'a',
      currency: Currency.eur,
      events: annual(<String>['1', '1.05', '1.1', '1.2', '1.3', '1.4']),
      asOf: now,
      fundamentals: DividendQualityFundamentals(
        forwardYield: Percentage.parsePercent('4'),
        payoutRatio: Percentage.parsePercent('55'),
        freeCashFlowCoversDividend: true,
        earningsGrowth: Percentage.parsePercent('6'),
        debtChange: Percentage.parsePercent('-3'),
        freeCashFlowGrowth: Percentage.parsePercent('5'),
      ),
    )!;

    expect(result.score, greaterThanOrEqualTo(75));
    expect(result.factors, isNotEmpty);
    expect(
      result.positives.map((factor) => factor.label),
      contains('No cut in 5 years'),
    );
    expect(
      result.positives.map((factor) => factor.label),
      contains('Free cash flow covers the dividend'),
    );
    expect(
      result.factors.any((factor) => factor.label.contains('5Y dividend CAGR')),
      isTrue,
    );
  });

  test('surfaces cuts and unsustainable fundamentals as risks', () {
    final ScoredAssessment result = const DividendQualityCalculator().calculate(
      instrumentId: 'a',
      currency: Currency.eur,
      events: annual(<String>['2', '2.2', '1.2', '1.0']),
      asOf: now,
      fundamentals: DividendQualityFundamentals(
        forwardYield: Percentage.parsePercent('12'),
        payoutRatio: Percentage.parsePercent('115'),
        freeCashFlowCoversDividend: false,
        earningsGrowth: Percentage.parsePercent('-8'),
        debtChange: Percentage.parsePercent('15'),
        freeCashFlowGrowth: Percentage.parsePercent('-10'),
      ),
    )!;

    expect(result.score, lessThan(35));
    expect(
      result.risks.map((factor) => factor.label),
      contains('No current no-cut streak'),
    );
    expect(
      result.risks.any((factor) => factor.label.startsWith('Payout ratio')),
      isTrue,
    );
    expect(result.risks, hasLength(greaterThanOrEqualTo(5)));
  });

  test('does not score missing fundamentals as zero', () {
    final List<DividendEvent> events = annual(<String>['1', '0.9']);
    final ScoredAssessment withoutMissing = const DividendQualityCalculator()
        .calculate(
          instrumentId: 'a',
          currency: Currency.eur,
          events: events,
          asOf: now,
        )!;
    final ScoredAssessment knownFailure = const DividendQualityCalculator()
        .calculate(
          instrumentId: 'a',
          currency: Currency.eur,
          events: events,
          asOf: now,
          fundamentals: const DividendQualityFundamentals(
            freeCashFlowCoversDividend: false,
          ),
        )!;

    expect(withoutMissing.score, greaterThan(knownFailure.score));
    expect(
      withoutMissing.factors.any(
        (factor) => factor.label.contains('cash flow'),
      ),
      isFalse,
    );
  });

  test('refuses a score without completed reported history', () {
    final ScoredAssessment? result = const DividendQualityCalculator()
        .calculate(
          instrumentId: 'a',
          currency: Currency.eur,
          events: <DividendEvent>[
            DividendEvent(
              instrumentId: 'a',
              amountPerShare: Money.parse('1', Currency.eur),
              status: DividendStatus.historicallyEstimated,
              paymentDate: DateTime.utc(2025, 5),
              provenance: provenance,
            ),
          ],
          asOf: now,
        );

    expect(result, isNull);
  });
}
