import 'package:dividendendackel/domain/entities/provenance.dart';

/// Which way a factor pushes a score.
enum FactorImpact {
  /// Supports the score.
  positive,

  /// Weighs against the score.
  negative,

  /// Context that does not push either way.
  neutral,
}

/// One human-readable reason behind a score.
///
/// Vision.md §15 requires every score to explain itself, and §85 forbids hidden
/// scoring logic — so a score is never a bare number, it is a number plus the
/// factors that produced it, in the wording shown to the user.
final class ScoreFactor {
  /// Creates a factor.
  ///
  /// [label] must be non-empty: an unexplained factor would defeat the point.
  ScoreFactor({required this.label, required this.impact, this.detail}) {
    if (label.trim().isEmpty) {
      throw ArgumentError.value(
        label,
        'label',
        'Every score factor must explain itself',
      );
    }
  }

  /// Short explanation, e.g. `No cut in 8 years`.
  final String label;

  /// Which way it pushes.
  final FactorImpact impact;

  /// Optional longer detail for progressive disclosure (Vision.md §2.3).
  final String? detail;

  @override
  String toString() => '${impact.name}: $label';

  @override
  bool operator ==(Object other) =>
      other is ScoreFactor &&
      other.label == label &&
      other.impact == impact &&
      other.detail == detail;

  @override
  int get hashCode => Object.hash(label, impact, detail);
}

/// A 0–100 score together with the reasoning behind it.
final class ScoredAssessment {
  /// Creates an assessment.
  ///
  /// [score] must be between 0 and 100, and at least one factor is required —
  /// a score with no explanation may not exist (Vision.md §15, §85).
  ScoredAssessment({
    required this.score,
    required this.summary,
    required this.factors,
  }) {
    if (score < 0 || score > 100) {
      throw RangeError.range(score, 0, 100, 'score');
    }
    if (factors.isEmpty) {
      throw ArgumentError.value(
        factors,
        'factors',
        'A score must explain why it exists',
      );
    }
  }

  /// The score, from 0 to 100.
  final int score;

  /// One-line explanation in the wording shown to the user.
  final String summary;

  /// The reasons behind the score.
  final List<ScoreFactor> factors;

  /// Factors supporting the score.
  List<ScoreFactor> get positives => factors
      .where((ScoreFactor f) => f.impact == FactorImpact.positive)
      .toList(growable: false);

  /// Factors weighing against the score.
  List<ScoreFactor> get risks => factors
      .where((ScoreFactor f) => f.impact == FactorImpact.negative)
      .toList(growable: false);

  @override
  String toString() => 'ScoredAssessment($score/100)';

  @override
  bool operator ==(Object other) =>
      other is ScoredAssessment &&
      other.score == score &&
      other.summary == summary &&
      _listEquals(other.factors, factors);

  @override
  int get hashCode => Object.hash(score, summary, Object.hashAll(factors));

  static bool _listEquals(List<ScoreFactor> a, List<ScoreFactor> b) {
    if (a.length != b.length) {
      return false;
    }
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) {
        return false;
      }
    }
    return true;
  }
}

/// The dimensions a research score is built from (Vision.md §15).
enum ResearchDimension {
  /// P/E, EV/EBITDA and comparison with historical ranges.
  valuation,

  /// Margins, free cash flow, debt, returns on capital.
  quality,

  /// Revenue, EPS and free-cash-flow growth.
  growth,

  /// Relative price performance over 1, 3 and 6 months.
  momentum,

  /// Yield, payout ratio, dividend growth, consistency and coverage.
  dividend,

  /// Earnings proximity, guidance changes, filings, unusual activity.
  eventRisk,
}

/// A point-in-time research assessment of an instrument.
///
/// Explicitly not a BUY/SELL signal (Vision.md §15). Snapshots are retained so
/// the app can say *what changed* since the last refresh (Vision.md §7) and
/// show a research-score history (Vision.md §16).
final class ResearchSnapshot implements HasProvenance {
  /// Creates a snapshot.
  const ResearchSnapshot({
    required this.instrumentId,
    required this.takenAt,
    required this.overall,
    required this.provenance,
    this.dimensions = const <ResearchDimension, ScoredAssessment>{},
  });

  /// The assessed instrument, by app-internal id.
  final String instrumentId;

  /// When the assessment was computed.
  final DateTime takenAt;

  /// The combined assessment.
  final ScoredAssessment overall;

  /// Per-dimension assessments. A dimension is absent when its inputs are
  /// missing, rather than being scored as zero.
  final Map<ResearchDimension, ScoredAssessment> dimensions;

  @override
  final Provenance provenance;

  /// The assessment for [dimension], or `null` when it could not be computed.
  ScoredAssessment? operator [](ResearchDimension dimension) =>
      dimensions[dimension];

  /// Dimensions that could be computed from the available data.
  Set<ResearchDimension> get availableDimensions => dimensions.keys.toSet();

  /// Change in the overall score against [previous], or `null` when there is
  /// nothing to compare against.
  int? changeAgainst(ResearchSnapshot? previous) =>
      previous == null ? null : overall.score - previous.overall.score;

  @override
  String toString() =>
      'ResearchSnapshot($instrumentId, ${overall.score}/100, $takenAt)';

  @override
  bool operator ==(Object other) =>
      other is ResearchSnapshot &&
      other.instrumentId == instrumentId &&
      other.takenAt == takenAt &&
      other.overall == overall;

  @override
  int get hashCode => Object.hash(instrumentId, takenAt, overall);
}
