import 'package:dividendendackel/core/errors/result.dart';
import 'package:dividendendackel/data/database/app_database.dart';
import 'package:dividendendackel/data/repositories/drift_instrument_repository.dart';
import 'package:dividendendackel/data/repositories/drift_research_repository.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late DriftResearchRepository repository;
  final DateTime now = DateTime.utc(2026, 8, 23, 12);

  setUp(() async {
    db = AppDatabase.withExecutor(NativeDatabase.memory());
    repository = DriftResearchRepository(db);
    await DriftInstrumentRepository(db).save(
      const Instrument(
        internalId: 'instrument',
        symbol: 'TEST',
        name: 'Test AG',
        currency: Currency.eur,
      ),
    );
  });

  tearDown(() => db.close());

  ScoredAssessment assessment(int score, String label) => ScoredAssessment(
    score: score,
    summary: 'Summary $score',
    factors: <ScoreFactor>[
      ScoreFactor(
        label: label,
        impact: score >= 50 ? FactorImpact.positive : FactorImpact.negative,
        detail: 'Evidence detail',
      ),
    ],
  );

  ResearchSnapshot snapshot({
    required DateTime at,
    int score = 67,
    String label = 'Known evidence',
  }) => ResearchSnapshot(
    instrumentId: 'instrument',
    takenAt: at,
    overall: assessment(score, label),
    dimensions: <ResearchDimension, ScoredAssessment>{
      ResearchDimension.dividend: assessment(score, 'Dividend history'),
      ResearchDimension.eventRisk: assessment(55, 'Earnings in 20 days'),
    },
    provenance: Provenance(
      source: 'derived:test',
      fetchedAt: at.subtract(const Duration(minutes: 2)),
      cacheState: CacheState.stale,
      confidence: Confidence.medium,
      reportedCurrency: Currency.eur,
      originalSymbol: 'TEST',
      exchange: 'XETR',
    ),
  );

  test('round-trips all explanations, dimensions and provenance', () async {
    final ResearchSnapshot original = snapshot(at: now);

    final Result<void> saved = await repository.saveIfChanged(original);
    final ResearchSnapshot stored =
        (await repository.watchHistory('instrument').first).single;

    expect(saved.isSuccess, isTrue);
    expect(stored.takenAt, now);
    expect(stored.overall, original.overall);
    expect(stored.dimensions, original.dimensions);
    expect(stored.provenance, original.provenance);
  });

  test('does not add noise when the newest assessment is unchanged', () async {
    await repository.saveIfChanged(snapshot(at: now));
    await repository.saveIfChanged(
      snapshot(at: now.add(const Duration(hours: 1))),
    );

    expect(await repository.watchHistory('instrument').first, hasLength(1));
  });

  test('retains changed scores newest first and respects the limit', () async {
    await repository.saveIfChanged(snapshot(at: now, score: 60));
    await repository.saveIfChanged(
      snapshot(at: now.add(const Duration(hours: 1)), score: 70),
    );
    await repository.saveIfChanged(
      snapshot(at: now.add(const Duration(hours: 2)), score: 80),
    );

    final List<ResearchSnapshot> history = await repository
        .watchHistory('instrument', limit: 2)
        .first;
    expect(history.map((ResearchSnapshot item) => item.overall.score), <int>[
      80,
      70,
    ]);
  });

  test('rejects a non-positive history limit', () {
    expect(
      () => repository.watchHistory('instrument', limit: 0),
      throwsRangeError,
    );
  });
}
