import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final DateTime now = DateTime.utc(2026, 8, 22);
  final Provenance provenance = Provenance(source: 'local', fetchedAt: now);

  ScoredAssessment assessment({int score = 67}) => ScoredAssessment(
    score: score,
    summary: 'Dividend appears well covered',
    factors: <ScoreFactor>[
      ScoreFactor(
        label: '5Y dividend CAGR +8.1%',
        impact: FactorImpact.positive,
      ),
      ScoreFactor(label: 'No cut in 8 years', impact: FactorImpact.positive),
      ScoreFactor(
        label: 'Payout ratio increased',
        impact: FactorImpact.negative,
      ),
    ],
  );

  group('ScoreFactor', () {
    test('must explain itself', () {
      expect(
        () => ScoreFactor(label: '   ', impact: FactorImpact.positive),
        throwsArgumentError,
      );
    });
  });

  group('ScoredAssessment', () {
    test('separates supporting factors from risks', () {
      // Vision.md §14 shows exactly this shape: a score, positives, risks.
      final ScoredAssessment score = assessment();

      expect(score.score, 67);
      expect(score.positives, hasLength(2));
      expect(score.risks, hasLength(1));
      expect(score.risks.single.label, 'Payout ratio increased');
    });

    test('refuses to exist without an explanation', () {
      expect(
        () => ScoredAssessment(
          score: 67,
          summary: 'unexplained',
          factors: const <ScoreFactor>[],
        ),
        throwsArgumentError,
      );
    });

    test('rejects a score outside 0 to 100', () {
      expect(
        () => ScoredAssessment(
          score: 101,
          summary: 's',
          factors: <ScoreFactor>[
            ScoreFactor(label: 'l', impact: FactorImpact.neutral),
          ],
        ),
        throwsRangeError,
      );
    });

    test('accepts the boundary scores', () {
      for (final int score in <int>[0, 100]) {
        expect(assessment(score: score).score, score);
      }
    });
  });

  group('ResearchSnapshot', () {
    ResearchSnapshot snapshotAt(DateTime at, {int score = 67}) =>
        ResearchSnapshot(
          instrumentId: 'isin:DE0008404005',
          takenAt: at,
          overall: assessment(score: score),
          dimensions: <ResearchDimension, ScoredAssessment>{
            ResearchDimension.dividend: assessment(score: score),
          },
          provenance: provenance,
        );

    test('omits dimensions it could not compute rather than scoring zero', () {
      final ResearchSnapshot snapshot = snapshotAt(now);

      expect(snapshot[ResearchDimension.dividend], isNotNull);
      expect(snapshot[ResearchDimension.momentum], isNull);
      expect(snapshot.availableDimensions, <ResearchDimension>{
        ResearchDimension.dividend,
      });
    });

    test('reports how the score changed since the previous snapshot', () {
      final ResearchSnapshot previous = snapshotAt(
        now.subtract(const Duration(days: 7)),
        score: 61,
      );

      expect(snapshotAt(now).changeAgainst(previous), 6);
    });

    test('reports no change when there is nothing to compare against', () {
      expect(snapshotAt(now).changeAgainst(null), isNull);
    });

    test('covers every dimension the vision names', () {
      expect(ResearchDimension.values, <ResearchDimension>[
        ResearchDimension.valuation,
        ResearchDimension.quality,
        ResearchDimension.growth,
        ResearchDimension.momentum,
        ResearchDimension.dividend,
        ResearchDimension.eventRisk,
      ]);
    });
  });
}
