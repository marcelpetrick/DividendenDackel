import 'package:decimal/decimal.dart';
import 'package:dividendendackel/core/errors/failure.dart';
import 'package:dividendendackel/core/errors/result.dart';
import 'package:dividendendackel/data/database/app_database.dart';
import 'package:dividendendackel/data/mappers/entity_mappers.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:dividendendackel/domain/repositories/repositories.dart';
import 'package:drift/drift.dart';

/// Drift-backed [PortfolioRepository].
///
/// Every write here touches user-owned rows, so each one is deliberate and
/// scoped: nothing in this class removes an instrument or market data.
final class DriftPortfolioRepository implements PortfolioRepository {
  /// Creates a repository over [db].
  DriftPortfolioRepository(this.db);

  /// The database this repository reads and writes.
  final AppDatabase db;

  @override
  Stream<List<Holding>> watchHoldings() => db
      .select(db.holdings)
      .watch()
      .map(
        (List<DbHolding> rows) =>
            rows.map((DbHolding r) => r.toDomain()).toList(growable: false),
      );

  @override
  Stream<Holding?> watchHolding(String instrumentId) =>
      (db.select(db.holdings)
            ..where(($HoldingsTable t) => t.instrumentId.equals(instrumentId)))
          .watchSingleOrNull()
          .map((DbHolding? row) => row?.toDomain());

  @override
  Stream<List<WatchlistEntry>> watchWatchlist() =>
      (db.select(db.watchlistEntries)
            ..orderBy(<OrderClauseGenerator<$WatchlistEntriesTable>>[
              ($WatchlistEntriesTable t) => OrderingTerm.desc(t.addedAt),
            ]))
          .watch()
          .map(
            (List<DbWatchlistEntry> rows) => rows
                .map((DbWatchlistEntry r) => r.toDomain())
                .toList(growable: false),
          );

  @override
  Future<Result<void>> saveHolding(Holding holding) =>
      Result.guardAsync<void>(() async {
        await db.transaction(() async {
          final DbHolding? existing =
              await (db.select(db.holdings)..where(
                    ($HoldingsTable t) =>
                        t.instrumentId.equals(holding.instrumentId),
                  ))
                  .getSingleOrNull();
          await db
              .into(db.holdings)
              .insertOnConflictUpdate(
                CompanionMappers.holding(holding, id: existing?.id),
              );
        });
      });

  @override
  Future<Result<void>> updateQuantity(String instrumentId, Decimal quantity) =>
      Result.guardAsync<void>(() async {
        if (quantity < Decimal.zero) {
          throw const InvalidInstrumentFailure(
            message: 'A holding quantity cannot be negative.',
          );
        }
        final int updated =
            await (db.update(db.holdings)..where(
                  ($HoldingsTable t) => t.instrumentId.equals(instrumentId),
                ))
                .write(
                  HoldingsCompanion(
                    quantity: Value<String>(quantity.toString()),
                  ),
                );
        if (updated == 0) {
          throw const NoDataFailure(
            message: 'No holding exists for this instrument.',
          );
        }
      });

  @override
  Future<Result<void>> removeHolding(String instrumentId) =>
      Result.guardAsync<void>(() async {
        // Deletes the position only. The instrument and its cached market data
        // stay, so re-adding it later is instant and offline (Vision.md §2.4).
        await (db.delete(
              db.holdings,
            )..where(($HoldingsTable t) => t.instrumentId.equals(instrumentId)))
            .go();
      });

  @override
  Future<Result<void>> addToWatchlist(WatchlistEntry entry) =>
      Result.guardAsync<void>(() async {
        await db
            .into(db.watchlistEntries)
            .insertOnConflictUpdate(CompanionMappers.watchlistEntry(entry));
      });

  @override
  Future<Result<void>> removeFromWatchlist(String instrumentId) =>
      Result.guardAsync<void>(() async {
        await (db.delete(db.watchlistEntries)..where(
              ($WatchlistEntriesTable t) => t.instrumentId.equals(instrumentId),
            ))
            .go();
      });

  @override
  Stream<Set<String>> watchFollowedInstrumentIds() => db
      .customSelect(
        'SELECT instrument_id AS id FROM holdings '
        'UNION SELECT instrument_id AS id FROM watchlist_entries',
        readsFrom: <ResultSetImplementation<HasResultSet, Object>>{
          db.holdings,
          db.watchlistEntries,
        },
      )
      .watch()
      .map(
        (List<QueryRow> rows) =>
            rows.map((QueryRow r) => r.read<String>('id')).toSet(),
      );
}
