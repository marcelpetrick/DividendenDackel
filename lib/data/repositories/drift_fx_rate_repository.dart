import 'package:dividendendackel/core/errors/result.dart';
import 'package:dividendendackel/data/database/app_database.dart';
import 'package:dividendendackel/data/mappers/entity_mappers.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:dividendendackel/domain/repositories/repositories.dart';
import 'package:drift/drift.dart';

/// Drift-backed daily foreign-exchange reference rates.
final class DriftFxRateRepository implements FxRateRepository {
  /// Creates the repository.
  DriftFxRateRepository(this.db);

  /// Local database.
  final AppDatabase db;

  @override
  Stream<List<FxRate>> watchInRange(
    Currency base,
    Set<Currency> quotes,
    DateRange range,
  ) =>
      (db.select(db.fxRates)
            ..where(
              ($FxRatesTable table) =>
                  table.baseCurrency.equals(base.code) &
                  table.quoteCurrency.isIn(
                    quotes.map((Currency currency) => currency.code),
                  ) &
                  table.observedAt.isBiggerOrEqualValue(range.start.toUtc()) &
                  table.observedAt.isSmallerThanValue(range.end.toUtc()),
            )
            ..orderBy(<OrderClauseGenerator<$FxRatesTable>>[
              ($FxRatesTable table) => OrderingTerm.asc(table.observedAt),
              ($FxRatesTable table) => OrderingTerm.asc(table.quoteCurrency),
            ]))
          .watch()
          .map(
            (List<DbFxRate> rows) => rows
                .map((DbFxRate row) => row.toDomain())
                .toList(growable: false),
          );

  @override
  Stream<Map<Currency, FxRate>> watchLatest(
    Currency base,
    Set<Currency> quotes,
  ) =>
      (db.select(db.fxRates)
            ..where(
              ($FxRatesTable table) =>
                  table.baseCurrency.equals(base.code) &
                  table.quoteCurrency.isIn(
                    quotes.map((Currency currency) => currency.code),
                  ),
            )
            ..orderBy(<OrderClauseGenerator<$FxRatesTable>>[
              ($FxRatesTable table) => OrderingTerm.desc(table.observedAt),
            ]))
          .watch()
          .map((List<DbFxRate> rows) {
            final Map<Currency, FxRate> latest = <Currency, FxRate>{};
            for (final DbFxRate row in rows) {
              final FxRate rate = row.toDomain();
              latest.putIfAbsent(rate.quote, () => rate);
            }
            return latest;
          });

  @override
  Future<Result<void>> saveAll(List<FxRate> rates) =>
      Result.guardAsync<void>(() async {
        await db.batch((Batch batch) {
          for (final FxRate rate in rates) {
            batch.insert(
              db.fxRates,
              CompanionMappers.fxRate(rate),
              onConflict: DoUpdate<$FxRatesTable, DbFxRate>(
                ($FxRatesTable _) => CompanionMappers.fxRate(rate),
              ),
            );
          }
        });
      });
}
