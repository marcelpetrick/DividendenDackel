import 'package:decimal/decimal.dart';
import 'package:dividendendackel/domain/entities/entities.dart';

/// Point-in-time valuation inputs. Multiples are plain ratios.
final class ValuationResearchMetrics {
  const ValuationResearchMetrics({
    this.priceEarnings,
    this.forwardPriceEarnings,
    this.priceSales,
    this.enterpriseValueToEbitda,
    this.historicalValuationPercentile,
  });

  final Decimal? priceEarnings;
  final Decimal? forwardPriceEarnings;
  final Decimal? priceSales;
  final Decimal? enterpriseValueToEbitda;

  /// Position in the instrument's own historical valuation range (0–100%).
  final Percentage? historicalValuationPercentile;
}

/// Profitability, cash-generation and balance-sheet inputs.
final class QualityResearchMetrics {
  const QualityResearchMetrics({
    this.netMargin,
    this.freeCashFlowMargin,
    this.debtToEquity,
    this.returnOnEquity,
    this.returnOnInvestedCapital,
  });

  final Percentage? netMargin;
  final Percentage? freeCashFlowMargin;
  final Decimal? debtToEquity;
  final Percentage? returnOnEquity;
  final Percentage? returnOnInvestedCapital;
}

/// Multi-year growth inputs; estimates remain explicitly labelled.
final class GrowthResearchMetrics {
  const GrowthResearchMetrics({
    this.revenueCagr,
    this.epsCagr,
    this.freeCashFlowCagr,
    this.analystGrowthEstimate,
  });

  final Percentage? revenueCagr;
  final Percentage? epsCagr;
  final Percentage? freeCashFlowCagr;
  final Percentage? analystGrowthEstimate;
}

/// Absolute and benchmark-relative price performance.
final class MomentumResearchMetrics {
  const MomentumResearchMetrics({
    this.oneMonth,
    this.threeMonths,
    this.sixMonths,
    this.relativeSixMonths,
  });

  final Percentage? oneMonth;
  final Percentage? threeMonths;
  final Percentage? sixMonths;
  final Percentage? relativeSixMonths;
}

/// Observed event-risk evidence.
///
/// Nullable flags distinguish "not observed by a complete source" from
/// "unknown". Callers must not pass `false` merely because no record was
/// fetched.
final class EventRiskResearchMetrics {
  const EventRiskResearchMetrics({
    this.daysUntilEarnings,
    this.recentGuidanceChange,
    this.abnormalVolatility,
    this.recentMaterialFiling,
    this.elevatedNewsActivity,
  });

  final int? daysUntilEarnings;
  final bool? recentGuidanceChange;
  final bool? abnormalVolatility;
  final bool? recentMaterialFiling;
  final bool? elevatedNewsActivity;
}

/// All optional evidence used for one research assessment.
final class ResearchScoreInput {
  const ResearchScoreInput({
    this.valuation = const ValuationResearchMetrics(),
    this.quality = const QualityResearchMetrics(),
    this.growth = const GrowthResearchMetrics(),
    this.momentum = const MomentumResearchMetrics(),
    this.dividend,
    this.eventRisk = const EventRiskResearchMetrics(),
  });

  final ValuationResearchMetrics valuation;
  final QualityResearchMetrics quality;
  final GrowthResearchMetrics growth;

  final MomentumResearchMetrics momentum;

  /// Explainable assessment produced by the dividend-quality calculator.
  final ScoredAssessment? dividend;

  final EventRiskResearchMetrics eventRisk;
}

/// Explainable six-dimension research score (Vision.md §15).
///
/// Missing metrics and dimensions are excluded, never scored as zero. The
/// result is descriptive research context, not a BUY/SELL recommendation.
final class ResearchScoreCalculator {
  const ResearchScoreCalculator();

  static const Map<ResearchDimension, int> _dimensionWeights =
      <ResearchDimension, int>{
        ResearchDimension.valuation: 20,
        ResearchDimension.quality: 20,
        ResearchDimension.growth: 20,
        ResearchDimension.momentum: 15,
        ResearchDimension.dividend: 15,
        ResearchDimension.eventRisk: 10,
      };

  /// Returns `null` when no dimension has enough evidence to explain a score.
  ResearchSnapshot? calculate({
    required String instrumentId,
    required DateTime asOf,
    required Provenance provenance,
    required ResearchScoreInput input,
  }) {
    if (instrumentId.trim().isEmpty) {
      throw ArgumentError.value(
        instrumentId,
        'instrumentId',
        'A research score needs an instrument',
      );
    }
    final Percentage? percentile =
        input.valuation.historicalValuationPercentile;
    if (percentile != null &&
        (percentile.rate < Decimal.zero || percentile.rate > Decimal.one)) {
      throw ArgumentError.value(
        percentile,
        'historicalValuationPercentile',
        'Historical percentile must be between 0% and 100%',
      );
    }
    if (input.eventRisk.daysUntilEarnings case final int days when days < 0) {
      throw ArgumentError.value(
        days,
        'daysUntilEarnings',
        'Upcoming earnings cannot be in the past',
      );
    }

    final Map<ResearchDimension, ScoredAssessment> dimensions =
        <ResearchDimension, ScoredAssessment>{};
    _put(dimensions, ResearchDimension.valuation, _valuation(input.valuation));
    _put(dimensions, ResearchDimension.quality, _quality(input.quality));
    _put(dimensions, ResearchDimension.growth, _growth(input.growth));
    _put(dimensions, ResearchDimension.momentum, _momentum(input.momentum));
    if (input.dividend case final ScoredAssessment dividend) {
      dimensions[ResearchDimension.dividend] = dividend;
    }
    _put(dimensions, ResearchDimension.eventRisk, _eventRisk(input.eventRisk));
    if (dimensions.isEmpty) return null;

    int weightedTotal = 0;
    int availableWeight = 0;
    for (final MapEntry<ResearchDimension, ScoredAssessment> entry
        in dimensions.entries) {
      final int weight = _dimensionWeights[entry.key]!;
      weightedTotal += entry.value.score * weight;
      availableWeight += weight;
    }
    final int overallScore = (weightedTotal / availableWeight).round();
    final List<ScoreFactor> factors = <ScoreFactor>[
      for (final ResearchDimension dimension in ResearchDimension.values)
        if (dimensions[dimension] case final ScoredAssessment assessment)
          ScoreFactor(
            label:
                '${_dimensionLabel(dimension)} ${assessment.score}/100 — '
                '${assessment.summary}',
            impact: _impact(assessment.score, 100),
          ),
    ];
    final int available = dimensions.length;
    return ResearchSnapshot(
      instrumentId: instrumentId,
      takenAt: asOf,
      overall: ScoredAssessment(
        score: overallScore,
        summary:
            '${_overallSummary(overallScore)} Based on $available of '
            '${ResearchDimension.values.length} dimensions; missing '
            'dimensions are omitted.',
        factors: List<ScoreFactor>.unmodifiable(factors),
      ),
      dimensions: Map<ResearchDimension, ScoredAssessment>.unmodifiable(
        dimensions,
      ),
      provenance: provenance,
    );
  }

  static void _put(
    Map<ResearchDimension, ScoredAssessment> target,
    ResearchDimension dimension,
    ScoredAssessment? value,
  ) {
    if (value != null) target[dimension] = value;
  }

  static ScoredAssessment? _valuation(ValuationResearchMetrics metrics) {
    final _DimensionBuilder result = _DimensionBuilder('valuation');
    _multiple(
      result,
      'P/E',
      metrics.priceEarnings,
      excellent: '15',
      fair: '25',
      stretched: '35',
    );
    _multiple(
      result,
      'Forward P/E',
      metrics.forwardPriceEarnings,
      excellent: '15',
      fair: '25',
      stretched: '35',
      detail: 'Forward P/E uses provider estimates.',
    );
    _multiple(
      result,
      'P/S',
      metrics.priceSales,
      excellent: '2',
      fair: '5',
      stretched: '10',
    );
    _multiple(
      result,
      'EV/EBITDA',
      metrics.enterpriseValueToEbitda,
      excellent: '10',
      fair: '16',
      stretched: '24',
    );
    if (metrics.historicalValuationPercentile case final Percentage value) {
      final Decimal percent = value.percent;
      final int earned = percent <= Decimal.fromInt(30)
          ? 20
          : percent <= Decimal.fromInt(60)
          ? 14
          : percent <= Decimal.fromInt(80)
          ? 8
          : 2;
      result.add(
        earned: earned,
        maximum: 20,
        label: 'Historical valuation percentile ${value.format()}',
        detail: 'Lower means cheaper relative to the instrument’s own range.',
      );
    }
    return result.build();
  }

  static void _multiple(
    _DimensionBuilder result,
    String name,
    Decimal? value, {
    required String excellent,
    required String fair,
    required String stretched,
    String? detail,
  }) {
    if (value == null) return;
    final int earned = value <= Decimal.zero
        ? 0
        : value <= Decimal.parse(excellent)
        ? 20
        : value <= Decimal.parse(fair)
        ? 14
        : value <= Decimal.parse(stretched)
        ? 8
        : 2;
    result.add(
      earned: earned,
      maximum: 20,
      label: '$name ${value.toString()}',
      detail: value <= Decimal.zero
          ? 'A non-positive multiple is not treated as inexpensive.'
          : detail,
    );
  }

  static ScoredAssessment? _quality(QualityResearchMetrics metrics) {
    final _DimensionBuilder result = _DimensionBuilder('quality');
    _profitability(result, 'Net margin', metrics.netMargin);
    _profitability(result, 'Free-cash-flow margin', metrics.freeCashFlowMargin);
    if (metrics.debtToEquity case final Decimal value) {
      final int earned = value < Decimal.zero
          ? 0
          : value <= Decimal.parse('0.5')
          ? 20
          : value <= Decimal.one
          ? 15
          : value <= Decimal.fromInt(2)
          ? 8
          : 0;
      result.add(
        earned: earned,
        maximum: 20,
        label: 'Debt/equity ${value.toString()}',
        detail: value < Decimal.zero
            ? 'Negative equity makes this leverage ratio adverse.'
            : null,
      );
    }
    _returnMetric(result, 'ROE', metrics.returnOnEquity);
    _returnMetric(result, 'ROIC', metrics.returnOnInvestedCapital);
    return result.build();
  }

  static void _profitability(
    _DimensionBuilder result,
    String name,
    Percentage? value,
  ) {
    if (value == null) return;
    final Decimal percent = value.percent;
    final int earned = percent >= Decimal.fromInt(20)
        ? 20
        : percent >= Decimal.fromInt(10)
        ? 14
        : percent >= Decimal.zero
        ? 8
        : 0;
    result.add(earned: earned, maximum: 20, label: '$name ${value.format()}');
  }

  static void _returnMetric(
    _DimensionBuilder result,
    String name,
    Percentage? value,
  ) {
    if (value == null) return;
    final Decimal percent = value.percent;
    final int earned = percent >= Decimal.fromInt(15)
        ? 20
        : percent >= Decimal.fromInt(8)
        ? 14
        : percent >= Decimal.zero
        ? 7
        : 0;
    result.add(earned: earned, maximum: 20, label: '$name ${value.format()}');
  }

  static ScoredAssessment? _growth(GrowthResearchMetrics metrics) {
    final _DimensionBuilder result = _DimensionBuilder('growth');
    _growthMetric(result, 'Revenue CAGR', metrics.revenueCagr);
    _growthMetric(result, 'EPS CAGR', metrics.epsCagr);
    _growthMetric(result, 'Free-cash-flow CAGR', metrics.freeCashFlowCagr);
    _growthMetric(
      result,
      'Analyst growth estimate',
      metrics.analystGrowthEstimate,
      detail: 'This is an estimate, not a reported result.',
    );
    return result.build();
  }

  static void _growthMetric(
    _DimensionBuilder result,
    String name,
    Percentage? value, {
    String? detail,
  }) {
    if (value == null) return;
    final Decimal percent = value.percent;
    final int earned = percent >= Decimal.fromInt(10)
        ? 25
        : percent >= Decimal.fromInt(3)
        ? 18
        : percent >= Decimal.zero
        ? 11
        : 0;
    result.add(
      earned: earned,
      maximum: 25,
      label: '$name ${value.format(withSign: true)}',
      detail: detail,
    );
  }

  static ScoredAssessment? _momentum(MomentumResearchMetrics metrics) {
    final _DimensionBuilder result = _DimensionBuilder('momentum');
    _momentumMetric(result, '1-month return', metrics.oneMonth);
    _momentumMetric(result, '3-month return', metrics.threeMonths);
    _momentumMetric(result, '6-month return', metrics.sixMonths);
    _momentumMetric(
      result,
      '6-month relative return',
      metrics.relativeSixMonths,
      detail: 'Performance versus the configured benchmark.',
    );
    return result.build();
  }

  static void _momentumMetric(
    _DimensionBuilder result,
    String name,
    Percentage? value, {
    String? detail,
  }) {
    if (value == null) return;
    final Decimal percent = value.percent;
    final int earned = percent >= Decimal.fromInt(10)
        ? 25
        : percent >= Decimal.zero
        ? 18
        : percent >= Decimal.fromInt(-10)
        ? 9
        : 0;
    result.add(
      earned: earned,
      maximum: 25,
      label: '$name ${value.format(withSign: true)}',
      detail: detail,
    );
  }

  static ScoredAssessment? _eventRisk(EventRiskResearchMetrics metrics) {
    final _DimensionBuilder result = _DimensionBuilder('event risk');
    if (metrics.daysUntilEarnings case final int days) {
      final int earned = days <= 7
          ? 0
          : days <= 30
          ? 12
          : 25;
      result.add(
        earned: earned,
        maximum: 25,
        label: days == 0
            ? 'Earnings are due today'
            : 'Earnings are due in $days day${days == 1 ? '' : 's'}',
      );
    }
    _riskFlag(
      result,
      metrics.recentGuidanceChange,
      present: 'Recent guidance change observed',
      absent: 'No recent guidance change in the observed data',
    );
    _riskFlag(
      result,
      metrics.abnormalVolatility,
      present: 'Abnormal volatility observed',
      absent: 'No abnormal volatility in the observed data',
    );
    _riskFlag(
      result,
      metrics.recentMaterialFiling,
      present: 'Recent material filing observed',
      absent: 'No recent material filing in the observed data',
    );
    _riskFlag(
      result,
      metrics.elevatedNewsActivity,
      present: 'Elevated news activity observed',
      absent: 'No elevated news activity in the observed data',
    );
    return result.build();
  }

  static void _riskFlag(
    _DimensionBuilder result,
    bool? value, {
    required String present,
    required String absent,
  }) {
    if (value == null) return;
    result.add(
      earned: value ? 0 : 25,
      maximum: 25,
      label: value ? present : absent,
      forceImpact: value ? FactorImpact.negative : FactorImpact.neutral,
      detail: value
          ? 'The score describes proximity or activity, not its likely outcome.'
          : 'Only the supplied observation window is assessed.',
    );
  }

  static FactorImpact _impact(int earned, int maximum) {
    final int scaled = earned * 100;
    if (scaled >= maximum * 70) return FactorImpact.positive;
    if (scaled >= maximum * 40) return FactorImpact.neutral;
    return FactorImpact.negative;
  }

  static String _dimensionLabel(ResearchDimension dimension) =>
      switch (dimension) {
        ResearchDimension.valuation => 'Valuation',
        ResearchDimension.quality => 'Quality',
        ResearchDimension.growth => 'Growth',
        ResearchDimension.momentum => 'Momentum',
        ResearchDimension.dividend => 'Dividend',
        ResearchDimension.eventRisk => 'Event risk',
      };

  static String _overallSummary(int score) => switch (score) {
    >= 75 => 'Available evidence is broadly strong.',
    >= 50 => 'Available evidence is mixed.',
    _ => 'Available evidence contains material risks.',
  };
}

final class _DimensionBuilder {
  _DimensionBuilder(this.name);

  final String name;
  final List<_ResearchFactorScore> _scores = <_ResearchFactorScore>[];

  void add({
    required int earned,
    required int maximum,
    required String label,
    String? detail,
    FactorImpact? forceImpact,
  }) {
    _scores.add(
      _ResearchFactorScore(
        earned: earned,
        maximum: maximum,
        factor: ScoreFactor(
          label: label,
          impact:
              forceImpact ?? ResearchScoreCalculator._impact(earned, maximum),
          detail: detail,
        ),
      ),
    );
  }

  ScoredAssessment? build() {
    if (_scores.isEmpty) return null;
    final int earned = _scores.fold<int>(
      0,
      (int total, _ResearchFactorScore item) => total + item.earned,
    );
    final int maximum = _scores.fold<int>(
      0,
      (int total, _ResearchFactorScore item) => total + item.maximum,
    );
    final int score = (earned * 100 / maximum).round().clamp(0, 100);
    return ScoredAssessment(
      score: score,
      summary: switch (score) {
        >= 75 => 'Strong $name evidence among available metrics.',
        >= 50 => 'Mixed $name evidence among available metrics.',
        _ => 'Material $name risks among available metrics.',
      },
      factors: List<ScoreFactor>.unmodifiable(
        _scores.map((_ResearchFactorScore item) => item.factor),
      ),
    );
  }
}

final class _ResearchFactorScore {
  const _ResearchFactorScore({
    required this.earned,
    required this.maximum,
    required this.factor,
  });

  final int earned;
  final int maximum;
  final ScoreFactor factor;
}
