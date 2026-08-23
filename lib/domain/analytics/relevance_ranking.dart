/// Material information types used by the Today relevance model.
enum RelevanceKind {
  exDividend,
  dividendPayment,
  dividendAnnouncement,
  earnings,
  guidance,
  mergerOrAcquisition,
  managementChange,
  regulatoryEvent,
  capitalAction,
  shareBuyback,
  materialFiling,
  unusualPriceMovement,
  product,
  analyst,
  macro,
  companyEvent,
  generalNews,
}

/// Whether time means an upcoming schedule or a publication timestamp.
enum RelevanceTiming { scheduled, published }

/// Provider-independent input to the deterministic relevance model.
final class RelevanceSignal {
  const RelevanceSignal({
    required this.id,
    required this.instrumentIds,
    required this.at,
    required this.kind,
    required this.timing,
    this.confirmed = false,
  });

  final String id;
  final List<String> instrumentIds;
  final DateTime at;
  final RelevanceKind kind;
  final RelevanceTiming timing;
  final bool confirmed;
}

/// One disclosed reason a signal received relevance points.
final class RelevanceFactor {
  const RelevanceFactor({required this.points, required this.explanation});

  final int points;
  final String explanation;
}

/// Ranked signal with an explainable score from 0 to 100.
final class RankedRelevance {
  const RankedRelevance({
    required this.signal,
    required this.score,
    required this.factors,
  });

  final RelevanceSignal signal;
  final int score;
  final List<RelevanceFactor> factors;
}

/// Ranks portfolio information using only disclosed, deterministic factors.
final class RelevanceRanker {
  const RelevanceRanker();

  List<RankedRelevance> rank({
    required Iterable<RelevanceSignal> signals,
    required Set<String> holdingIds,
    required Set<String> watchlistIds,
    required Map<String, double> holdingWeights,
    required DateTime now,
  }) {
    final List<RankedRelevance> ranked = <RankedRelevance>[];
    for (final RelevanceSignal signal in signals) {
      final bool held = signal.instrumentIds.any(holdingIds.contains);
      final bool watched = signal.instrumentIds.any(watchlistIds.contains);
      if (!held && !watched) continue;

      final List<RelevanceFactor> factors = <RelevanceFactor>[];
      if (held) {
        factors.add(
          const RelevanceFactor(points: 35, explanation: 'Held position'),
        );
      } else {
        factors.add(
          const RelevanceFactor(points: 16, explanation: 'On watchlist'),
        );
      }

      final double weight = signal.instrumentIds.fold<double>(0, (
        double maximum,
        String id,
      ) {
        final double candidate = holdingWeights[id] ?? 0;
        return candidate > maximum ? candidate : maximum;
      });
      if (held && weight > 0) {
        final double bounded = weight.clamp(0, 1);
        final int points = (bounded * 15).round().clamp(1, 15);
        factors.add(
          RelevanceFactor(
            points: points,
            explanation:
                '${(bounded * 100).toStringAsFixed(1)}% portfolio weight '
                'within its currency',
          ),
        );
      }

      factors.add(_kindFactor(signal.kind));
      final RelevanceFactor? time = _timeFactor(signal, now);
      if (time != null) factors.add(time);
      if (signal.confirmed) {
        factors.add(
          const RelevanceFactor(points: 5, explanation: 'Confirmed event'),
        );
      }
      final int score = factors
          .fold<int>(
            0,
            (int total, RelevanceFactor factor) => total + factor.points,
          )
          .clamp(0, 100);
      ranked.add(
        RankedRelevance(
          signal: signal,
          score: score,
          factors: List<RelevanceFactor>.unmodifiable(factors),
        ),
      );
    }

    ranked.sort((RankedRelevance left, RankedRelevance right) {
      final int byScore = right.score.compareTo(left.score);
      if (byScore != 0) return byScore;
      final int byTime = left.signal.at.compareTo(right.signal.at);
      if (byTime != 0) return byTime;
      return left.signal.id.compareTo(right.signal.id);
    });
    return List<RankedRelevance>.unmodifiable(ranked);
  }

  static RelevanceFactor _kindFactor(RelevanceKind kind) => switch (kind) {
    RelevanceKind.dividendAnnouncement => const RelevanceFactor(
      points: 24,
      explanation: 'Dividend announcement',
    ),
    RelevanceKind.earnings => const RelevanceFactor(
      points: 23,
      explanation: 'Earnings event',
    ),
    RelevanceKind.guidance => const RelevanceFactor(
      points: 25,
      explanation: 'Guidance change',
    ),
    RelevanceKind.mergerOrAcquisition => const RelevanceFactor(
      points: 25,
      explanation: 'Merger or acquisition',
    ),
    RelevanceKind.managementChange => const RelevanceFactor(
      points: 19,
      explanation: 'Management change',
    ),
    RelevanceKind.regulatoryEvent => const RelevanceFactor(
      points: 22,
      explanation: 'Regulatory event',
    ),
    RelevanceKind.capitalAction => const RelevanceFactor(
      points: 22,
      explanation: 'Capital action',
    ),
    RelevanceKind.shareBuyback => const RelevanceFactor(
      points: 21,
      explanation: 'Share buyback',
    ),
    RelevanceKind.materialFiling => const RelevanceFactor(
      points: 23,
      explanation: 'Material filing',
    ),
    RelevanceKind.unusualPriceMovement => const RelevanceFactor(
      points: 25,
      explanation: 'Unusual price movement',
    ),
    RelevanceKind.exDividend => const RelevanceFactor(
      points: 17,
      explanation: 'Ex-dividend date',
    ),
    RelevanceKind.dividendPayment => const RelevanceFactor(
      points: 15,
      explanation: 'Dividend payment',
    ),
    RelevanceKind.product => const RelevanceFactor(
      points: 12,
      explanation: 'Product or operational update',
    ),
    RelevanceKind.analyst => const RelevanceFactor(
      points: 9,
      explanation: 'Analyst update',
    ),
    RelevanceKind.macro => const RelevanceFactor(
      points: 4,
      explanation: 'Macro news',
    ),
    RelevanceKind.companyEvent => const RelevanceFactor(
      points: 14,
      explanation: 'Company event',
    ),
    RelevanceKind.generalNews => const RelevanceFactor(
      points: 6,
      explanation: 'Company news',
    ),
  };

  static RelevanceFactor? _timeFactor(RelevanceSignal signal, DateTime now) {
    if (signal.timing == RelevanceTiming.scheduled) {
      final DateTime today = DateTime.utc(now.year, now.month, now.day);
      final DateTime day = DateTime.utc(
        signal.at.year,
        signal.at.month,
        signal.at.day,
      );
      final int days = day.difference(today).inDays;
      return switch (days) {
        0 => const RelevanceFactor(points: 20, explanation: 'Happens today'),
        1 => const RelevanceFactor(points: 17, explanation: 'Happens tomorrow'),
        2 ||
        3 => RelevanceFactor(points: 13, explanation: 'Happens in $days days'),
        >= 4 && <= 7 => RelevanceFactor(
          points: 7,
          explanation: 'Happens within 7 days',
        ),
        _ => null,
      };
    }
    final Duration age = now.toUtc().difference(signal.at.toUtc());
    if (age.isNegative) return null;
    if (age <= const Duration(hours: 6)) {
      return const RelevanceFactor(
        points: 18,
        explanation: 'Published recently',
      );
    }
    if (age <= const Duration(hours: 24)) {
      return const RelevanceFactor(points: 14, explanation: 'Published today');
    }
    if (age <= const Duration(days: 3)) {
      return const RelevanceFactor(
        points: 9,
        explanation: 'Published within 3 days',
      );
    }
    if (age <= const Duration(days: 7)) {
      return const RelevanceFactor(
        points: 4,
        explanation: 'Published within 7 days',
      );
    }
    return null;
  }
}
