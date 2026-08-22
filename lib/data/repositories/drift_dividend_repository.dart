import 'package:dividendendackel/core/errors/result.dart';
import 'package:dividendendackel/data/database/app_database.dart';
import 'package:dividendendackel/data/mappers/entity_mappers.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:dividendendackel/domain/repositories/repositories.dart';
import 'package:drift/drift.dart';

/// Drift-backed [DividendRepository].
final class DriftDividendRepository implements DividendRepository {
  /// Creates a repository over [db].
  DriftDividendRepository(this.db);

  /// The database this repository reads and writes.
  final AppDatabase db;

  @override
  Stream<List<DividendEvent>> watchForInstrument(String instrumentId) =>
      (db.select(db.dividendEvents)
            ..where(
              ($DividendEventsTable t) => t.instrumentId.equals(instrumentId),
            )
            ..orderBy(<OrderClauseGenerator<$DividendEventsTable>>[
              ($DividendEventsTable t) => OrderingTerm.desc(t.exDate),
            ]))
          .watch()
          .map(_toDomain);

  @override
  Stream<List<DividendEvent>> watchInRange(
    DateRange range,
    DividendDateMode mode, {
    Set<String>? instrumentIds,
  }) {
    final SimpleSelectStatement<$DividendEventsTable, DbDividendEvent> query =
        db.select(db.dividendEvents)
          ..where(($DividendEventsTable t) {
            // An event whose date for this mode is unknown cannot be placed on
            // the calendar, and inventing one would violate Vision.md §79.
            final GeneratedColumn<DateTime> column = switch (mode) {
              DividendDateMode.exDate => t.exDate,
              DividendDateMode.paymentDate => t.paymentDate,
            };
            final Expression<bool> inRange =
                column.isBiggerOrEqualValue(range.start.toUtc()) &
                column.isSmallerThanValue(range.end.toUtc());
            return instrumentIds == null
                ? inRange
                : inRange & t.instrumentId.isIn(instrumentIds);
          })
          ..orderBy(<OrderClauseGenerator<$DividendEventsTable>>[
            ($DividendEventsTable t) => OrderingTerm.asc(switch (mode) {
              DividendDateMode.exDate => t.exDate,
              DividendDateMode.paymentDate => t.paymentDate,
            }),
          ]);

    return query.watch().map(_toDomain);
  }

  @override
  Future<Result<void>> saveAll(
    List<DividendEvent> events, {
    required String Function(DividendEvent event) idOf,
  }) => Result.guardAsync<void>(() async {
    await db.batch((Batch batch) {
      for (final DividendEvent event in events) {
        batch.insert(
          db.dividendEvents,
          CompanionMappers.dividendEvent(event, id: idOf(event)),
          onConflict: DoUpdate<$DividendEventsTable, DbDividendEvent>(
            ($DividendEventsTable _) =>
                CompanionMappers.dividendEvent(event, id: idOf(event)),
          ),
        );
      }
    });
  });

  static List<DividendEvent> _toDomain(List<DbDividendEvent> rows) =>
      rows.map((DbDividendEvent r) => r.toDomain()).toList(growable: false);
}
