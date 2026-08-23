import 'package:decimal/decimal.dart';
import 'package:dividendendackel/core/errors/failure.dart';
import 'package:dividendendackel/core/errors/result.dart';
import 'package:dividendendackel/data/database/app_database.dart';
import 'package:dividendendackel/data/mappers/entity_mappers.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:dividendendackel/domain/repositories/repositories.dart';
import 'package:drift/drift.dart';

/// Drift-backed portfolio metadata, current positions and immutable activity
/// ledger.
///
/// Market-data refreshes never call this repository. All writes here are
/// explicitly user-owned and transactionally scoped to one portfolio.
final class DriftPortfolioRepository implements PortfolioRepository {
  /// Creates a repository over [db].
  DriftPortfolioRepository(this.db);

  /// The database this repository reads and writes.
  final AppDatabase db;

  @override
  Stream<List<InvestmentPortfolio>> watchPortfolios() =>
      (db.select(db.investmentPortfolios)
            ..orderBy(<OrderClauseGenerator<$InvestmentPortfoliosTable>>[
              ($InvestmentPortfoliosTable t) => OrderingTerm.asc(t.isDemo),
              ($InvestmentPortfoliosTable t) => OrderingTerm.asc(t.name),
            ]))
          .watch()
          .map(
            (List<DbInvestmentPortfolio> rows) => rows
                .map((DbInvestmentPortfolio row) => row.toDomain())
                .toList(growable: false),
          );

  @override
  Future<Result<void>> savePortfolio(InvestmentPortfolio portfolio) =>
      Result.guardAsync<void>(() async {
        await db
            .into(db.investmentPortfolios)
            .insertOnConflictUpdate(
              CompanionMappers.investmentPortfolio(portfolio),
            );
      });

  @override
  Stream<List<Holding>> watchHoldings({
    String? portfolioId = InvestmentPortfolio.defaultId,
  }) {
    final SimpleSelectStatement<$HoldingsTable, DbHolding> query = db.select(
      db.holdings,
    );
    if (portfolioId != null) {
      query.where(
        ($HoldingsTable table) => table.portfolioId.equals(portfolioId),
      );
    }
    return query.watch().map(
      (List<DbHolding> rows) =>
          rows.map((DbHolding row) => row.toDomain()).toList(growable: false),
    );
  }

  @override
  Stream<Holding?> watchHolding(
    String instrumentId, {
    String portfolioId = InvestmentPortfolio.defaultId,
  }) =>
      (db.select(db.holdings)..where(
            ($HoldingsTable table) =>
                table.portfolioId.equals(portfolioId) &
                table.instrumentId.equals(instrumentId),
          ))
          .watchSingleOrNull()
          .map((DbHolding? row) => row?.toDomain());

  @override
  Stream<List<WatchlistEntry>> watchWatchlist({
    String? portfolioId = InvestmentPortfolio.defaultId,
  }) {
    final SimpleSelectStatement<$WatchlistEntriesTable, DbWatchlistEntry>
    query = db.select(db.watchlistEntries);
    if (portfolioId != null) {
      query.where(
        ($WatchlistEntriesTable table) => table.portfolioId.equals(portfolioId),
      );
    }
    query.orderBy(<OrderClauseGenerator<$WatchlistEntriesTable>>[
      ($WatchlistEntriesTable table) => OrderingTerm.desc(table.addedAt),
    ]);
    return query.watch().map(
      (List<DbWatchlistEntry> rows) => rows
          .map((DbWatchlistEntry row) => row.toDomain())
          .toList(growable: false),
    );
  }

  @override
  Future<Result<void>> saveHolding(Holding holding) => Result.guardAsync<void>(
    () async {
      await db.transaction(() async {
        await _requirePortfolio(holding.portfolioId);
        final DbHolding? existing = await _findHolding(
          holding.portfolioId,
          holding.instrumentId,
        );
        await _writeHolding(holding, existing?.id);

        final Decimal previous = existing == null
            ? Decimal.zero
            : EntityMappers.parseDecimal(existing.quantity, 'holding.quantity');
        final Decimal delta = holding.quantity - previous;
        if (delta != Decimal.zero) {
          final PortfolioActivityType type = existing == null
              ? PortfolioActivityType.openingBalance
              : PortfolioActivityType.holdingAdjustment;
          await _insertActivity(
            PortfolioActivity(
              portfolioId: holding.portfolioId,
              type: type,
              occurredAt: holding.purchaseDate ?? holding.provenance.fetchedAt,
              instrumentId: holding.instrumentId,
              quantity: type == PortfolioActivityType.openingBalance
                  ? holding.quantity
                  : delta,
              unitPrice: holding.averagePurchasePrice,
              notes: holding.notes,
              provenance: holding.provenance,
            ),
          );
        }
      });
    },
  );

  @override
  Future<Result<void>> updateQuantity(
    String instrumentId,
    Decimal quantity, {
    String portfolioId = InvestmentPortfolio.defaultId,
  }) => Result.guardAsync<void>(() async {
    if (quantity < Decimal.zero) {
      throw const InvalidInstrumentFailure(
        message: 'A holding quantity cannot be negative.',
      );
    }
    await db.transaction(() async {
      final DbHolding? existing = await _findHolding(portfolioId, instrumentId);
      if (existing == null) {
        throw const NoDataFailure(
          message: 'No holding exists for this instrument.',
        );
      }
      final Holding current = existing.toDomain();
      await _writeHolding(current.copyWith(quantity: quantity), existing.id);
      final Decimal delta = quantity - current.quantity;
      if (delta != Decimal.zero) {
        final DateTime now = DateTime.now().toUtc();
        await _insertActivity(
          PortfolioActivity(
            portfolioId: portfolioId,
            type: PortfolioActivityType.holdingAdjustment,
            occurredAt: now,
            instrumentId: instrumentId,
            quantity: delta,
            unitPrice: current.averagePurchasePrice,
            provenance: Provenance.user(now),
          ),
        );
      }
    });
  });

  @override
  Future<Result<void>> removeHolding(
    String instrumentId, {
    String portfolioId = InvestmentPortfolio.defaultId,
  }) => Result.guardAsync<void>(() async {
    await db.transaction(() async {
      final DbHolding? existing = await _findHolding(portfolioId, instrumentId);
      if (existing == null) return;
      final Holding current = existing.toDomain();
      if (!current.isEmpty) {
        final DateTime now = DateTime.now().toUtc();
        await _insertActivity(
          PortfolioActivity(
            portfolioId: portfolioId,
            type: PortfolioActivityType.holdingAdjustment,
            occurredAt: now,
            instrumentId: instrumentId,
            quantity: -current.quantity,
            unitPrice: current.averagePurchasePrice,
            provenance: Provenance.user(now),
            notes: 'Position removed',
          ),
        );
      }
      await (db.delete(
        db.holdings,
      )..where(($HoldingsTable table) => table.id.equals(existing.id))).go();
    });
  });

  @override
  Future<Result<void>> addToWatchlist(WatchlistEntry entry) =>
      Result.guardAsync<void>(() async {
        await _requirePortfolio(entry.portfolioId);
        await db
            .into(db.watchlistEntries)
            .insertOnConflictUpdate(CompanionMappers.watchlistEntry(entry));
      });

  @override
  Future<Result<void>> removeFromWatchlist(
    String instrumentId, {
    String portfolioId = InvestmentPortfolio.defaultId,
  }) => Result.guardAsync<void>(() async {
    await (db.delete(db.watchlistEntries)..where(
          ($WatchlistEntriesTable table) =>
              table.portfolioId.equals(portfolioId) &
              table.instrumentId.equals(instrumentId),
        ))
        .go();
  });

  @override
  Stream<List<PortfolioActivity>> watchActivities(String portfolioId) =>
      (db.select(db.portfolioActivities)
            ..where(
              ($PortfolioActivitiesTable table) =>
                  table.portfolioId.equals(portfolioId),
            )
            ..orderBy(<OrderClauseGenerator<$PortfolioActivitiesTable>>[
              ($PortfolioActivitiesTable table) =>
                  OrderingTerm.desc(table.occurredAt),
              ($PortfolioActivitiesTable table) => OrderingTerm.desc(table.id),
            ]))
          .watch()
          .map(
            (List<DbPortfolioActivity> rows) => rows
                .map((DbPortfolioActivity row) => row.toDomain())
                .toList(growable: false),
          );

  @override
  Future<Result<int>> recordActivity(PortfolioActivity activity) =>
      Result.guardAsync<int>(() async {
        if (activity.id != null) {
          throw ArgumentError('A new activity cannot already have an id.');
        }
        return db.transaction<int>(() async {
          await _requirePortfolio(activity.portfolioId);
          if (activity.type == PortfolioActivityType.reversal) {
            return _recordReversal(activity);
          }
          final int id = await _insertActivity(activity);
          if (activity.shareDelta != null) {
            await _rebuildHolding(activity.portfolioId, activity.instrumentId!);
          }
          return id;
        });
      });

  @override
  Future<Result<int>> reverseActivity(
    int activityId, {
    required DateTime occurredAt,
  }) => Result.guardAsync<int>(() async {
    return db.transaction<int>(() async {
      final DbPortfolioActivity target =
          await (db.select(db.portfolioActivities)..where(
                ($PortfolioActivitiesTable table) =>
                    table.id.equals(activityId),
              ))
              .getSingleOrNull() ??
          (throw const NoDataFailure(message: 'Activity not found.'));
      return _recordReversal(
        PortfolioActivity(
          portfolioId: target.portfolioId,
          type: PortfolioActivityType.reversal,
          occurredAt: occurredAt,
          reversesActivityId: activityId,
          provenance: Provenance.user(occurredAt),
        ),
      );
    });
  });

  @override
  Stream<Set<String>> watchFollowedInstrumentIds({String? portfolioId}) {
    final String filter = portfolioId == null ? '' : ' WHERE portfolio_id = ?';
    final List<Variable<Object>> variables = portfolioId == null
        ? const <Variable<Object>>[]
        : <Variable<Object>>[Variable<String>(portfolioId)];
    return db
        .customSelect(
          'SELECT instrument_id AS id FROM holdings$filter '
          'UNION SELECT instrument_id AS id FROM watchlist_entries$filter',
          variables: <Variable<Object>>[...variables, ...variables],
          readsFrom: <ResultSetImplementation<HasResultSet, Object>>{
            db.holdings,
            db.watchlistEntries,
          },
        )
        .watch()
        .map(
          (List<QueryRow> rows) =>
              rows.map((QueryRow row) => row.read<String>('id')).toSet(),
        );
  }

  Future<DbHolding?> _findHolding(String portfolioId, String instrumentId) =>
      (db.select(db.holdings)..where(
            ($HoldingsTable table) =>
                table.portfolioId.equals(portfolioId) &
                table.instrumentId.equals(instrumentId),
          ))
          .getSingleOrNull();

  Future<void> _writeHolding(Holding holding, int? id) => db
      .into(db.holdings)
      .insertOnConflictUpdate(CompanionMappers.holding(holding, id: id));

  Future<int> _insertActivity(PortfolioActivity activity) => db
      .into(db.portfolioActivities)
      .insert(CompanionMappers.portfolioActivity(activity));

  Future<int> _recordReversal(PortfolioActivity reversal) async {
    final int targetId = reversal.reversesActivityId!;
    final DbPortfolioActivity target =
        await (db.select(db.portfolioActivities)..where(
              ($PortfolioActivitiesTable table) => table.id.equals(targetId),
            ))
            .getSingleOrNull() ??
        (throw const NoDataFailure(message: 'Activity not found.'));
    if (target.portfolioId != reversal.portfolioId ||
        target.type == PortfolioActivityType.reversal) {
      throw const InvalidInstrumentFailure(
        message: 'This activity cannot be reversed.',
      );
    }
    final DbPortfolioActivity? existing =
        await (db.select(db.portfolioActivities)..where(
              ($PortfolioActivitiesTable table) =>
                  table.reversesActivityId.equals(targetId),
            ))
            .getSingleOrNull();
    if (existing != null) {
      throw const InvalidInstrumentFailure(
        message: 'This activity has already been reversed.',
      );
    }
    final PortfolioActivity normalizedReversal = PortfolioActivity(
      portfolioId: reversal.portfolioId,
      type: PortfolioActivityType.reversal,
      occurredAt: reversal.occurredAt,
      instrumentId: target.instrumentId,
      reversesActivityId: targetId,
      notes: reversal.notes,
      provenance: reversal.provenance,
    );
    final int id = await _insertActivity(normalizedReversal);
    if (target.instrumentId != null && target.quantity != null) {
      await _rebuildHolding(target.portfolioId, target.instrumentId!);
    }
    return id;
  }

  Future<void> _rebuildHolding(String portfolioId, String instrumentId) async {
    final List<PortfolioActivity> activities =
        (await (db.select(db.portfolioActivities)
                  ..where(
                    ($PortfolioActivitiesTable table) =>
                        table.portfolioId.equals(portfolioId) &
                        table.instrumentId.equals(instrumentId),
                  )
                  ..orderBy(<OrderClauseGenerator<$PortfolioActivitiesTable>>[
                    ($PortfolioActivitiesTable table) =>
                        OrderingTerm.asc(table.occurredAt),
                    ($PortfolioActivitiesTable table) =>
                        OrderingTerm.asc(table.id),
                  ]))
                .get())
            .map((DbPortfolioActivity row) => row.toDomain())
            .toList(growable: false);
    final Set<int> reversed = activities
        .where(
          (PortfolioActivity item) =>
              item.type == PortfolioActivityType.reversal,
        )
        .map((PortfolioActivity item) => item.reversesActivityId!)
        .toSet();

    Decimal quantity = Decimal.zero;
    Money? cost;
    bool costKnown = true;
    DateTime? purchaseDate;
    String? notes;
    Provenance? provenance;
    for (final PortfolioActivity activity in activities) {
      if (activity.type == PortfolioActivityType.reversal ||
          reversed.contains(activity.id)) {
        continue;
      }
      final Decimal? delta = activity.shareDelta;
      if (delta == null) continue;
      if (quantity + delta < Decimal.zero) {
        throw const InvalidInstrumentFailure(
          message: 'This activity would sell more shares than are held.',
        );
      }
      if (delta > Decimal.zero) {
        purchaseDate ??= activity.occurredAt;
        final Money? price = activity.unitPrice;
        if (price == null) {
          costKnown = false;
        } else if (cost == null) {
          cost = price * delta;
        } else if (cost.currency == price.currency) {
          cost += price * delta;
        } else {
          costKnown = false;
        }
      } else if (costKnown && cost != null && quantity > Decimal.zero) {
        final Money average = cost.dividedBy(quantity, scale: 12);
        cost += average * delta;
      }
      quantity += delta;
      notes = activity.notes ?? notes;
      provenance = activity.provenance;
    }

    final DbHolding? existing = await _findHolding(portfolioId, instrumentId);
    if (quantity == Decimal.zero) {
      if (existing != null) {
        await (db.delete(
          db.holdings,
        )..where(($HoldingsTable table) => table.id.equals(existing.id))).go();
      }
      return;
    }

    final Money? average = costKnown && cost != null
        ? cost.dividedBy(quantity, scale: 12)
        : null;
    await _writeHolding(
      Holding(
        portfolioId: portfolioId,
        instrumentId: instrumentId,
        quantity: quantity,
        averagePurchasePrice: average,
        purchaseDate: purchaseDate,
        notes: notes,
        provenance: provenance ?? Provenance.user(DateTime.now().toUtc()),
      ),
      existing?.id,
    );
  }

  Future<void> _requirePortfolio(String portfolioId) async {
    final DbInvestmentPortfolio? existing =
        await (db.select(db.investmentPortfolios)..where(
              ($InvestmentPortfoliosTable table) =>
                  table.id.equals(portfolioId),
            ))
            .getSingleOrNull();
    if (existing == null) {
      throw const NoDataFailure(message: 'Portfolio not found.');
    }
  }
}
