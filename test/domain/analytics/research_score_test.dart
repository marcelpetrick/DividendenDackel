import 'package:decimal/decimal.dart';
import 'package:dividendendackel/domain/analytics/analytics.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const ResearchScoreCalculator calculator = ResearchScoreCalculator();
  final DateTime now = DateTime.utc(2026, 8, 23, 12);
  final Provenance provenance = Provenance(source: 'test', fetchedAt: now);

  Percentage percent(String value) => Percentage.parsePercent(value);
  ScoredAssessment dividend({int score = 80}) => ScoredAssessment(
    score: score,
    summary: 'Dividend evidence is supported by reported history.',
    factors: <ScoreFactor>[
      ScoreFactor(
        label: 'No dividend cut in 8 years',
        impact: FactorImpact.positive,
      ),
    ],
  );

  ResearchSnapshot? calculate(ResearchScoreInput input) => calculator.calculate(
    instrumentId: 'instrument',
    asOf: now,
    provenance: provenance,
    input: input,
  );

  test('scores all six dimensions and explains the weighted result', () {
    final ResearchSnapshot result = calculate(
      ResearchScoreInput(
        valuation: ValuationResearchMetrics(
          priceEarnings: Decimal.parse('12'),
          forwardPriceEarnings: Decimal.parse('16'),
          priceSales: Decimal.parse('1.5'),
          enterpriseValueToEbitda: Decimal.parse('8'),
          historicalValuationPercentile: percent('20'),
        ),
        quality: QualityResearchMetrics(
          netMargin: percent('25'),
          freeCashFlowMargin: percent('15'),
          debtToEquity: Decimal.parse('0.4'),
          returnOnEquity: percent('18'),
          returnOnInvestedCapital: percent('16'),
        ),
        growth: GrowthResearchMetrics(
          revenueCagr: percent('12'),
          epsCagr: percent('8'),
          freeCashFlowCagr: percent('5'),
          analystGrowthEstimate: percent('7'),
        ),
        momentum: MomentumResearchMetrics(
          oneMonth: percent('5'),
          threeMonths: percent('12'),
          sixMonths: percent('20'),
          relativeSixMonths: percent('4'),
        ),
        dividend: dividend(),
        eventRisk: const EventRiskResearchMetrics(
          daysUntilEarnings: 45,
          recentGuidanceChange: false,
          abnormalVolatility: false,
          recentMaterialFiling: false,
          elevatedNewsActivity: false,
        ),
      ),
    )!;

    expect(result.availableDimensions, ResearchDimension.values.toSet());
    expect(result.overall.score, 88);
    expect(result.overall.factors, hasLength(6));
    expect(result.overall.summary, contains('6 of 6 dimensions'));
    final Iterable<String> labels = result.overall.factors.map(
      (ScoreFactor factor) => factor.label,
    );
    for (final String expected in <String>[
      'Valuation 94/100',
      'Quality 94/100',
      'Growth 79/100',
      'Momentum 86/100',
      'Dividend 80/100',
      'Event risk 100/100',
    ]) {
      expect(labels, anyElement(contains(expected)));
    }
    expect(
      result[ResearchDimension.growth]!.factors.last.detail,
      contains('estimate'),
    );
  });

  test('omits missing evidence and reweights only available dimensions', () {
    final ResearchSnapshot result = calculate(
      ResearchScoreInput(
        quality: QualityResearchMetrics(netMargin: percent('10')),
      ),
    )!;

    expect(result.availableDimensions, <ResearchDimension>{
      ResearchDimension.quality,
    });
    expect(result.overall.score, 70);
    expect(result.overall.summary, contains('1 of 6 dimensions'));
    expect(result[ResearchDimension.valuation], isNull);
  });

  test('returns no score when every input is unknown', () {
    expect(calculate(const ResearchScoreInput()), isNull);
  });

  test('does not present a non-positive P/E as inexpensive', () {
    final ScoredAssessment valuation = calculate(
      ResearchScoreInput(
        valuation: ValuationResearchMetrics(priceEarnings: Decimal.parse('-3')),
      ),
    )![ResearchDimension.valuation]!;

    expect(valuation.score, 0);
    expect(valuation.risks.single.label, 'P/E -3');
    expect(
      valuation.risks.single.detail,
      contains('not treated as inexpensive'),
    );
  });

  test('event proximity and observed flags lower event-risk score', () {
    final ScoredAssessment eventRisk = calculate(
      const ResearchScoreInput(
        eventRisk: EventRiskResearchMetrics(
          daysUntilEarnings: 3,
          recentGuidanceChange: true,
          abnormalVolatility: true,
          recentMaterialFiling: true,
          elevatedNewsActivity: true,
        ),
      ),
    )![ResearchDimension.eventRisk]!;

    expect(eventRisk.score, 0);
    expect(eventRisk.risks, hasLength(5));
    expect(
      eventRisk.factors.every((ScoreFactor factor) => factor.label.isNotEmpty),
      isTrue,
    );
    expect(eventRisk.factors.last.detail, contains('not its likely outcome'));
  });

  test('rejects impossible percentile and upcoming-event inputs', () {
    expect(
      () => calculate(
        ResearchScoreInput(
          valuation: ValuationResearchMetrics(
            historicalValuationPercentile: percent('101'),
          ),
        ),
      ),
      throwsArgumentError,
    );
    expect(
      () => calculate(
        const ResearchScoreInput(
          eventRisk: EventRiskResearchMetrics(daysUntilEarnings: -1),
        ),
      ),
      throwsArgumentError,
    );
  });
}
