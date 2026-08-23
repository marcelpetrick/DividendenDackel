import 'package:dividendendackel/core/errors/result.dart';
import 'package:dividendendackel/data/database/app_database.dart';
import 'package:dividendendackel/data/mappers/entity_mappers.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:dividendendackel/domain/repositories/repositories.dart';
import 'package:drift/drift.dart';

/// Drift-backed [InstrumentRepository].
final class DriftInstrumentRepository implements InstrumentRepository {
  /// Creates a repository over [db].
  DriftInstrumentRepository(this.db);

  /// The database this repository reads and writes.
  final AppDatabase db;

  @override
  Future<Result<bool>> hasAny() => Result.guardAsync<bool>(() async {
    final DbInstrument? row = await (db.select(
      db.instruments,
    )..limit(1)).getSingleOrNull();
    return row != null;
  });

  @override
  Stream<Instrument?> watchInstrument(String internalId) {
    final Stream<DbInstrument?> rows =
        (db.select(db.instruments)
              ..where(($InstrumentsTable t) => t.internalId.equals(internalId)))
            .watchSingleOrNull();

    return rows.asyncMap((DbInstrument? row) async {
      if (row == null) {
        return null;
      }
      return row.toDomain(await _mappingsFor(<String>[internalId]));
    });
  }

  @override
  Stream<List<Instrument>> watchAll() {
    final Stream<List<DbInstrument>> rows =
        (db.select(db.instruments)
              ..orderBy(<OrderClauseGenerator<$InstrumentsTable>>[
                ($InstrumentsTable t) => OrderingTerm.asc(t.name),
              ]))
            .watch();

    return rows.asyncMap(_attachMappings);
  }

  @override
  Stream<List<Instrument>> watchByIds(Set<String> internalIds) {
    if (internalIds.isEmpty) {
      return Stream<List<Instrument>>.value(const <Instrument>[]);
    }
    final Stream<List<DbInstrument>> rows =
        (db.select(db.instruments)
              ..where(($InstrumentsTable t) => t.internalId.isIn(internalIds))
              ..orderBy(<OrderClauseGenerator<$InstrumentsTable>>[
                ($InstrumentsTable t) => OrderingTerm.asc(t.name),
              ]))
            .watch();
    return rows.asyncMap(_attachMappings);
  }

  @override
  Future<Result<Instrument?>> findById(String internalId) =>
      Result.guardAsync<Instrument?>(() async {
        final DbInstrument? row =
            await (db.select(db.instruments)..where(
                  ($InstrumentsTable t) => t.internalId.equals(internalId),
                ))
                .getSingleOrNull();
        if (row == null) {
          return null;
        }
        return row.toDomain(await _mappingsFor(<String>[internalId]));
      });

  @override
  Future<Result<List<Instrument>>> search(String query, {int limit = 20}) =>
      Result.guardAsync<List<Instrument>>(() async {
        final String trimmed = query.trim();
        if (trimmed.isEmpty) {
          return const <Instrument>[];
        }
        final String pattern = '%${trimmed.toUpperCase()}%';
        final List<DbInstrument> rows =
            await (db.select(db.instruments)
                  ..where(
                    ($InstrumentsTable t) =>
                        t.name.upper().like(pattern) |
                        t.symbol.upper().like(pattern) |
                        t.isin.upper().like(pattern),
                  )
                  ..orderBy(<OrderClauseGenerator<$InstrumentsTable>>[
                    ($InstrumentsTable t) => OrderingTerm.asc(t.name),
                  ])
                  ..limit(limit))
                .get();
        return _attachMappings(rows);
      });

  @override
  Future<Result<void>> save(Instrument instrument) =>
      Result.guardAsync<void>(() async {
        await db.transaction(() async {
          await db
              .into(db.instruments)
              .insertOnConflictUpdate(CompanionMappers.instrument(instrument));
          // Mappings are replaced wholesale: a provider that stops listing an
          // instrument should not leave a stale symbol behind.
          await (db.delete(db.providerMappings)..where(
                ($ProviderMappingsTable t) =>
                    t.instrumentId.equals(instrument.internalId),
              ))
              .go();
          for (final ProviderMappingsCompanion mapping
              in CompanionMappers.providerMappings(instrument)) {
            await db.into(db.providerMappings).insert(mapping);
          }
        });
      });

  Future<List<Instrument>> _attachMappings(List<DbInstrument> rows) async {
    if (rows.isEmpty) {
      return const <Instrument>[];
    }
    final List<DbProviderMapping> mappings = await _mappingsFor(
      rows.map((DbInstrument r) => r.internalId).toList(growable: false),
    );
    return rows
        .map(
          (DbInstrument row) => row.toDomain(
            mappings
                .where(
                  (DbProviderMapping m) => m.instrumentId == row.internalId,
                )
                .toList(growable: false),
          ),
        )
        .toList(growable: false);
  }

  Future<List<DbProviderMapping>> _mappingsFor(List<String> instrumentIds) =>
      (db.select(db.providerMappings)..where(
            ($ProviderMappingsTable t) => t.instrumentId.isIn(instrumentIds),
          ))
          .get();
}
