import 'dart:convert';

import 'package:dividendendackel/core/errors/failure.dart';
import 'package:dividendendackel/core/errors/result.dart';
import 'package:dividendendackel/data/database/app_database.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:dividendendackel/domain/repositories/repositories.dart';
import 'package:drift/drift.dart';

/// Drift-backed history for explainable research assessments.
final class DriftResearchRepository implements ResearchRepository {
  DriftResearchRepository(this.db);

  final AppDatabase db;

  @override
  Stream<List<ResearchSnapshot>> watchHistory(
    String instrumentId, {
    int limit = 50,
  }) {
    if (limit <= 0) {
      throw RangeError.range(limit, 1, null, 'limit');
    }
    return (db.select(db.researchSnapshots)
          ..where(
            ($ResearchSnapshotsTable row) =>
                row.instrumentId.equals(instrumentId),
          )
          ..orderBy(<OrderClauseGenerator<$ResearchSnapshotsTable>>[
            ($ResearchSnapshotsTable row) => OrderingTerm.desc(row.takenAt),
            ($ResearchSnapshotsTable row) => OrderingTerm.desc(row.id),
          ])
          ..limit(limit))
        .watch()
        .map(
          (List<DbResearchSnapshot> rows) => rows
              .map(_ResearchSnapshotCodec.decodeRow)
              .toList(growable: false),
        );
  }

  @override
  Future<Result<void>> saveIfChanged(ResearchSnapshot snapshot) =>
      Result.guardAsync<void>(() async {
        final String factors = _ResearchSnapshotCodec.encodeFactors(
          snapshot.overall.factors,
        );
        final String dimensions = _ResearchSnapshotCodec.encodeDimensions(
          snapshot.dimensions,
        );
        final DbResearchSnapshot? latest =
            await (db.select(db.researchSnapshots)
                  ..where(
                    ($ResearchSnapshotsTable row) =>
                        row.instrumentId.equals(snapshot.instrumentId),
                  )
                  ..orderBy(<OrderClauseGenerator<$ResearchSnapshotsTable>>[
                    ($ResearchSnapshotsTable row) =>
                        OrderingTerm.desc(row.takenAt),
                    ($ResearchSnapshotsTable row) => OrderingTerm.desc(row.id),
                  ])
                  ..limit(1))
                .getSingleOrNull();
        if (latest != null &&
            latest.overallScore == snapshot.overall.score &&
            latest.overallSummary == snapshot.overall.summary &&
            latest.overallFactorsJson == factors &&
            latest.dimensionsJson == dimensions) {
          return;
        }

        final Provenance provenance = snapshot.provenance;
        await db
            .into(db.researchSnapshots)
            .insert(
              ResearchSnapshotsCompanion.insert(
                instrumentId: snapshot.instrumentId,
                takenAt: snapshot.takenAt.toUtc(),
                overallScore: snapshot.overall.score,
                overallSummary: snapshot.overall.summary,
                overallFactorsJson: factors,
                dimensionsJson: Value<String>(dimensions),
                source: provenance.source,
                fetchedAt: provenance.fetchedAt.toUtc(),
                updatedAt: Value<DateTime?>(provenance.updatedAt?.toUtc()),
                cacheState: Value<CacheState>(provenance.cacheState),
                confidence: Value<Confidence>(provenance.confidence),
                reportedCurrency: Value<String?>(
                  provenance.reportedCurrency?.code,
                ),
                originalSymbol: Value<String?>(provenance.originalSymbol),
                providerExchange: Value<String?>(provenance.exchange),
              ),
            );
      });
}

abstract final class _ResearchSnapshotCodec {
  static String encodeFactors(List<ScoreFactor> factors) => jsonEncode(
    factors
        .map(
          (ScoreFactor factor) => <String, Object?>{
            'label': factor.label,
            'impact': factor.impact.name,
            if (factor.detail != null) 'detail': factor.detail,
          },
        )
        .toList(growable: false),
  );

  static String encodeDimensions(
    Map<ResearchDimension, ScoredAssessment> dimensions,
  ) => jsonEncode(<String, Object?>{
    for (final ResearchDimension dimension in ResearchDimension.values)
      if (dimensions[dimension] case final ScoredAssessment assessment)
        dimension.name: <String, Object?>{
          'score': assessment.score,
          'summary': assessment.summary,
          'factors': jsonDecode(encodeFactors(assessment.factors)),
        },
  });

  static ResearchSnapshot decodeRow(DbResearchSnapshot row) {
    try {
      final Map<ResearchDimension, ScoredAssessment> dimensions =
          <ResearchDimension, ScoredAssessment>{};
      final Map<String, dynamic> rawDimensions =
          jsonDecode(row.dimensionsJson) as Map<String, dynamic>;
      for (final MapEntry<String, dynamic> entry in rawDimensions.entries) {
        final ResearchDimension dimension = ResearchDimension.values.byName(
          entry.key,
        );
        dimensions[dimension] = _decodeAssessment(
          entry.value as Map<String, dynamic>,
        );
      }
      return ResearchSnapshot(
        instrumentId: row.instrumentId,
        takenAt: row.takenAt.toUtc(),
        overall: ScoredAssessment(
          score: row.overallScore,
          summary: row.overallSummary,
          factors: _decodeFactors(jsonDecode(row.overallFactorsJson)),
        ),
        dimensions: Map<ResearchDimension, ScoredAssessment>.unmodifiable(
          dimensions,
        ),
        provenance: Provenance(
          source: row.source,
          fetchedAt: row.fetchedAt.toUtc(),
          updatedAt: row.updatedAt?.toUtc(),
          cacheState: row.cacheState,
          confidence: row.confidence,
          reportedCurrency: row.reportedCurrency == null
              ? null
              : Currency.parse(row.reportedCurrency!),
          originalSymbol: row.originalSymbol,
          exchange: row.providerExchange,
        ),
      );
    } on Object catch (error) {
      throw ParsingFailure(
        technicalDetail:
            'Malformed research snapshot ${row.id} for '
            '${row.instrumentId}: $error',
        cause: error,
      );
    }
  }

  static ScoredAssessment _decodeAssessment(Map<String, dynamic> raw) =>
      ScoredAssessment(
        score: raw['score'] as int,
        summary: raw['summary'] as String,
        factors: _decodeFactors(raw['factors']),
      );

  static List<ScoreFactor> _decodeFactors(Object? raw) => (raw as List<dynamic>)
      .cast<Map<String, dynamic>>()
      .map(
        (Map<String, dynamic> factor) => ScoreFactor(
          label: factor['label'] as String,
          impact: FactorImpact.values.byName(factor['impact'] as String),
          detail: factor['detail'] as String?,
        ),
      )
      .toList(growable: false);
}
