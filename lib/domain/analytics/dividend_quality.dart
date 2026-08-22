import 'package:decimal/decimal.dart';
import 'package:dividendendackel/domain/analytics/dividend_growth.dart';
import 'package:dividendendackel/domain/entities/entities.dart';

/// Optional fundamentals that can strengthen a dividend-quality assessment.
///
/// Missing values are excluded from the denominator rather than treated as
/// bad values. That prevents a sparse provider from manufacturing a low score.
final class DividendQualityFundamentals {
  /// Creates the available point-in-time fundamentals.
  const DividendQualityFundamentals({
    this.forwardYield,
    this.payoutRatio,
    this.freeCashFlowCoversDividend,
    this.earningsGrowth,
    this.debtChange,
    this.freeCashFlowGrowth,
  });

  /// Forward gross dividend yield.
  final Percentage? forwardYield;

  /// Dividend divided by earnings, expressed as a rate.
  final Percentage? payoutRatio;

  /// Whether free cash flow covers the cash dividend.
  final bool? freeCashFlowCoversDividend;

  /// Latest year-over-year earnings change.
  final Percentage? earningsGrowth;

  /// Latest year-over-year debt change; a decrease is favourable.
  final Percentage? debtChange;

  /// Latest year-over-year free-cash-flow change.
  final Percentage? freeCashFlowGrowth;
}

/// Explainable Dividend Quality Score (Vision.md §14).
final class DividendQualityCalculator {
  /// Creates a calculator over the shared growth rules.
  const DividendQualityCalculator({
    this.growthCalculator = const DividendGrowthCalculator(),
  });

  /// Growth analytics used for reported annual totals and cuts.
  final DividendGrowthCalculator growthCalculator;

  /// Returns `null` when no completed reported dividend year exists.
  ScoredAssessment? calculate({
    required String instrumentId,
    required Currency currency,
    required List<DividendEvent> events,
    required DateTime asOf,
    DividendQualityFundamentals fundamentals =
        const DividendQualityFundamentals(),
  }) {
    final DividendGrowthAnalysis growth = growthCalculator.calculate(
      instrumentId: instrumentId,
      currency: currency,
      events: events,
      asOf: asOf,
    );
    if (growth.annualTotals.isEmpty) return null;

    final List<_FactorScore> scores = <_FactorScore>[];
    final int noCutYears = growth.yearsWithoutCut;
    final int noCutPoints = switch (noCutYears) {
      >= 8 => 25,
      >= 5 => 20,
      >= 3 => 14,
      >= 1 => 7,
      _ => 0,
    };
    if (noCutYears > 0 || growth.latestDecrease != null) {
      scores.add(
        _FactorScore(
          earned: noCutPoints,
          maximum: 25,
          factor: ScoreFactor(
            label: noCutYears == 0
                ? 'No current no-cut streak'
                : 'No cut in $noCutYears year${noCutYears == 1 ? '' : 's'}',
            impact: noCutPoints >= 14
                ? FactorImpact.positive
                : FactorImpact.negative,
            detail: 'Based on consecutive completed reported calendar years.',
          ),
        ),
      );
    }

    final DividendCagr? cagr = _longestCagr(growth.cagrs);
    if (cagr != null) {
      final Decimal percent = cagr.rate.percent;
      final int points = percent >= Decimal.fromInt(8)
          ? 20
          : percent >= Decimal.fromInt(3)
          ? 15
          : percent > Decimal.zero
          ? 9
          : 0;
      scores.add(
        _FactorScore(
          earned: points,
          maximum: 20,
          factor: ScoreFactor(
            label: cagr.format(),
            impact: points >= 9 ? FactorImpact.positive : FactorImpact.negative,
          ),
        ),
      );
    }

    final int historyYears = growth.annualTotals.length;
    final int historyPoints = historyYears >= 10
        ? 15
        : historyYears >= 5
        ? 11
        : historyYears >= 3
        ? 7
        : 3;
    scores.add(
      _FactorScore(
        earned: historyPoints,
        maximum: 15,
        factor: ScoreFactor(
          label:
              '$historyYears completed payment year${historyYears == 1 ? '' : 's'}',
          impact: historyYears >= 5
              ? FactorImpact.positive
              : FactorImpact.neutral,
        ),
      ),
    );

    final Percentage? yield = fundamentals.forwardYield;
    if (yield != null) {
      final Decimal percent = yield.percent;
      final bool unusuallyHigh = percent > Decimal.fromInt(8);
      final bool invalid = percent <= Decimal.zero;
      scores.add(
        _FactorScore(
          earned: invalid
              ? 0
              : unusuallyHigh
              ? 3
              : percent >= Decimal.one
              ? 10
              : 5,
          maximum: 10,
          factor: ScoreFactor(
            label: 'Forward yield ${yield.format()}',
            impact: invalid || unusuallyHigh
                ? FactorImpact.negative
                : percent >= Decimal.one
                ? FactorImpact.positive
                : FactorImpact.neutral,
            detail: unusuallyHigh
                ? 'A very high yield can reflect a falling price or an unsustainable payout.'
                : null,
          ),
        ),
      );
    }

    final Percentage? payout = fundamentals.payoutRatio;
    if (payout != null) {
      final Decimal percent = payout.percent;
      final int points = percent <= Decimal.zero
          ? 0
          : percent <= Decimal.fromInt(60)
          ? 15
          : percent <= Decimal.fromInt(80)
          ? 10
          : percent <= Decimal.fromInt(100)
          ? 4
          : 0;
      scores.add(
        _FactorScore(
          earned: points,
          maximum: 15,
          factor: ScoreFactor(
            label: 'Payout ratio ${payout.format()}',
            impact: points >= 10
                ? FactorImpact.positive
                : FactorImpact.negative,
          ),
        ),
      );
    }
    _booleanFactor(
      scores,
      fundamentals.freeCashFlowCoversDividend,
      maximum: 15,
      positive: 'Free cash flow covers the dividend',
      negative: 'Free cash flow does not cover the dividend',
    );
    _trendFactor(
      scores,
      fundamentals.earningsGrowth,
      maximum: 5,
      noun: 'Earnings',
      positiveWhenNegative: false,
    );
    _trendFactor(
      scores,
      fundamentals.debtChange,
      maximum: 5,
      noun: 'Debt',
      positiveWhenNegative: true,
    );
    _trendFactor(
      scores,
      fundamentals.freeCashFlowGrowth,
      maximum: 5,
      noun: 'Free cash flow',
      positiveWhenNegative: false,
    );

    final int earned = scores.fold(
      0,
      (int sum, _FactorScore item) => sum + item.earned,
    );
    final int maximum = scores.fold(
      0,
      (int sum, _FactorScore item) => sum + item.maximum,
    );
    final int score = ((earned * 100) / maximum).round().clamp(0, 100);
    return ScoredAssessment(
      score: score,
      summary: switch (score) {
        >= 75 => 'Strong dividend quality on the available evidence.',
        >= 50 => 'Mixed dividend quality with strengths and risks.',
        _ => 'Dividend quality has material risks on the available evidence.',
      },
      factors: List<ScoreFactor>.unmodifiable(
        scores.map((_FactorScore item) => item.factor),
      ),
    );
  }

  static DividendCagr? _longestCagr(Map<int, DividendCagr> values) {
    for (final int period in <int>[10, 5, 3]) {
      if (values[period] case final DividendCagr value) return value;
    }
    return null;
  }

  static void _booleanFactor(
    List<_FactorScore> scores,
    bool? value, {
    required int maximum,
    required String positive,
    required String negative,
  }) {
    if (value == null) return;
    scores.add(
      _FactorScore(
        earned: value ? maximum : 0,
        maximum: maximum,
        factor: ScoreFactor(
          label: value ? positive : negative,
          impact: value ? FactorImpact.positive : FactorImpact.negative,
        ),
      ),
    );
  }

  static void _trendFactor(
    List<_FactorScore> scores,
    Percentage? change, {
    required int maximum,
    required String noun,
    required bool positiveWhenNegative,
  }) {
    if (change == null) return;
    final bool favourable = positiveWhenNegative
        ? !change.isPositive
        : !change.isNegative;
    scores.add(
      _FactorScore(
        earned: favourable ? maximum : 0,
        maximum: maximum,
        factor: ScoreFactor(
          label: '$noun ${change.format(withSign: true)} year over year',
          impact: favourable ? FactorImpact.positive : FactorImpact.negative,
        ),
      ),
    );
  }
}

final class _FactorScore {
  const _FactorScore({
    required this.earned,
    required this.maximum,
    required this.factor,
  });
  final int earned;
  final int maximum;
  final ScoreFactor factor;
}
