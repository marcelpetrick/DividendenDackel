import 'package:dividendendackel/domain/analytics/analytics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const RelevanceRanker ranker = RelevanceRanker();
  final DateTime now = DateTime.utc(2026, 8, 23, 12);

  RelevanceSignal signal({
    required String id,
    String instrumentId = 'held',
    RelevanceKind kind = RelevanceKind.generalNews,
    RelevanceTiming timing = RelevanceTiming.published,
    DateTime? at,
    bool confirmed = false,
  }) => RelevanceSignal(
    id: id,
    instrumentIds: <String>[instrumentId],
    at: at ?? now.subtract(const Duration(hours: 2)),
    kind: kind,
    timing: timing,
    confirmed: confirmed,
  );

  List<RankedRelevance> rank(
    Iterable<RelevanceSignal> signals, {
    Set<String> holdings = const <String>{'held'},
    Set<String> watchlist = const <String>{'watched'},
    Map<String, double> weights = const <String, double>{'held': 0.5},
  }) => ranker.rank(
    signals: signals,
    holdingIds: holdings,
    watchlistIds: watchlist,
    holdingWeights: weights,
    now: now,
  );

  test('a held position outranks an otherwise equal watchlist item', () {
    final List<RankedRelevance> ranked = rank(<RelevanceSignal>[
      signal(id: 'watch', instrumentId: 'watched'),
      signal(id: 'hold'),
    ]);

    expect(ranked.map((RankedRelevance item) => item.signal.id), <String>[
      'hold',
      'watch',
    ]);
    expect(ranked.first.factors.first.explanation, 'Held position');
  });

  test('material category and recency affect order with explanations', () {
    final List<RankedRelevance> ranked = rank(<RelevanceSignal>[
      signal(id: 'old-general', at: now.subtract(const Duration(days: 6))),
      signal(id: 'guidance', kind: RelevanceKind.guidance),
    ]);

    expect(ranked.first.signal.id, 'guidance');
    expect(
      ranked.first.factors.map((RelevanceFactor factor) => factor.explanation),
      containsAll(<String>['Guidance change', 'Published recently']),
    );
  });

  test(
    'holding weight changes rank only when attributable quote data exists',
    () {
      final List<RankedRelevance> ranked = rank(
        <RelevanceSignal>[
          signal(id: 'small'),
          signal(id: 'large', instrumentId: 'large'),
        ],
        holdings: const <String>{'held', 'large'},
        weights: const <String, double>{'held': 0.1, 'large': 0.8},
      );

      expect(ranked.first.signal.id, 'large');
      expect(
        ranked.first.factors.any(
          (RelevanceFactor factor) => factor.explanation.contains('80.0%'),
        ),
        isTrue,
      );
    },
  );

  test('scheduled events distinguish today, tomorrow and later', () {
    final List<RankedRelevance> ranked = rank(<RelevanceSignal>[
      signal(
        id: 'later',
        timing: RelevanceTiming.scheduled,
        at: now.add(const Duration(days: 3)),
      ),
      signal(id: 'today', timing: RelevanceTiming.scheduled, at: now),
      signal(
        id: 'tomorrow',
        timing: RelevanceTiming.scheduled,
        at: now.add(const Duration(days: 1)),
      ),
    ]);

    expect(ranked.map((RankedRelevance item) => item.signal.id), <String>[
      'today',
      'tomorrow',
      'later',
    ]);
  });

  test('ignores unrelated signals and clamps fully explained scores', () {
    final List<RankedRelevance> ranked = rank(
      <RelevanceSignal>[
        signal(id: 'unrelated', instrumentId: 'other'),
        signal(
          id: 'material',
          kind: RelevanceKind.unusualPriceMovement,
          confirmed: true,
        ),
      ],
      weights: const <String, double>{'held': 10},
    );

    expect(ranked, hasLength(1));
    expect(ranked.single.signal.id, 'material');
    expect(ranked.single.score, inInclusiveRange(0, 100));
    expect(
      ranked.single.factors.fold<int>(
        0,
        (int total, RelevanceFactor factor) => total + factor.points,
      ),
      greaterThanOrEqualTo(ranked.single.score),
    );
  });

  test('ties are deterministic by time then stable id', () {
    final List<RankedRelevance> ranked = rank(<RelevanceSignal>[
      signal(id: 'b'),
      signal(id: 'a'),
    ]);

    expect(ranked.map((RankedRelevance item) => item.signal.id), <String>[
      'a',
      'b',
    ]);
  });

  test('future publication timestamps do not receive recency points', () {
    final RankedRelevance ranked = rank(<RelevanceSignal>[
      signal(id: 'future', at: now.add(const Duration(minutes: 1))),
    ]).single;

    expect(
      ranked.factors.map((RelevanceFactor factor) => factor.explanation),
      isNot(contains('Published recently')),
    );
  });
}
