import 'package:dividendendackel/core/errors/result.dart';
import 'package:dividendendackel/data/database/app_database.dart';
import 'package:dividendendackel/data/mappers/entity_mappers.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:dividendendackel/domain/repositories/repositories.dart';
import 'package:drift/drift.dart';

/// Drift-backed [MarketDataRepository].
final class DriftMarketDataRepository implements MarketDataRepository {
  /// Creates a repository over [db].
  DriftMarketDataRepository(this.db);

  /// The database this repository reads and writes.
  final AppDatabase db;

  @override
  Stream<Quote?> watchQuote(String instrumentId) =>
      (db.select(db.quotes)
            ..where(($QuotesTable t) => t.instrumentId.equals(instrumentId)))
          .watchSingleOrNull()
          .map((DbQuote? row) => row?.toDomain());

  @override
  Stream<Map<String, Quote>> watchQuotes(Set<String> instrumentIds) =>
      (db.select(db.quotes)
            ..where(($QuotesTable t) => t.instrumentId.isIn(instrumentIds)))
          .watch()
          .map(
            (List<DbQuote> rows) => <String, Quote>{
              for (final DbQuote row in rows) row.instrumentId: row.toDomain(),
            },
          );

  @override
  Stream<List<EarningsEvent>> watchEarningsInRange(
    DateRange range, {
    Set<String>? instrumentIds,
  }) =>
      (db.select(db.earningsEvents)
            ..where(($EarningsEventsTable t) {
              final Expression<bool> inRange =
                  t.scheduledFor.isBiggerOrEqualValue(range.start.toUtc()) &
                  t.scheduledFor.isSmallerThanValue(range.end.toUtc());
              return instrumentIds == null
                  ? inRange
                  : inRange & t.instrumentId.isIn(instrumentIds);
            })
            ..orderBy(<OrderClauseGenerator<$EarningsEventsTable>>[
              ($EarningsEventsTable t) => OrderingTerm.asc(t.scheduledFor),
            ]))
          .watch()
          .map(
            (List<DbEarningsEvent> rows) => rows
                .map((DbEarningsEvent r) => r.toDomain())
                .toList(growable: false),
          );

  @override
  Stream<List<CorporateEvent>> watchCorporateEventsInRange(
    DateRange range, {
    Set<String>? instrumentIds,
  }) =>
      (db.select(db.corporateEvents)
            ..where(($CorporateEventsTable t) {
              final Expression<bool> inRange =
                  t.scheduledFor.isBiggerOrEqualValue(range.start.toUtc()) &
                  t.scheduledFor.isSmallerThanValue(range.end.toUtc());
              final Expression<bool> active =
                  t.status.isNotValue(CorporateEventStatus.completed.name) &
                  t.status.isNotValue(CorporateEventStatus.cancelled.name);
              return instrumentIds == null
                  ? inRange & active
                  : inRange & active & t.instrumentId.isIn(instrumentIds);
            })
            ..orderBy(<OrderClauseGenerator<$CorporateEventsTable>>[
              ($CorporateEventsTable t) => OrderingTerm.asc(t.scheduledFor),
            ]))
          .watch()
          .map(
            (List<DbCorporateEvent> rows) => rows
                .map((DbCorporateEvent row) => row.toDomain())
                .toList(growable: false),
          );

  @override
  Stream<List<NewsItem>> watchRecentNews({
    Set<String>? instrumentIds,
    int limit = 50,
  }) {
    final SimpleSelectStatement<$NewsItemsTable, DbNewsItem> query = db.select(
      db.newsItems,
    );
    if (instrumentIds != null) {
      final JoinedSelectStatement<HasResultSet, dynamic> linkedIds =
          db.selectOnly(db.newsInstrumentLinks)
            ..addColumns(<Expression<Object>>[db.newsInstrumentLinks.newsId])
            ..where(db.newsInstrumentLinks.instrumentId.isIn(instrumentIds));
      query.where(($NewsItemsTable item) => item.id.isInQuery(linkedIds));
    }
    query
      ..orderBy(<OrderClauseGenerator<$NewsItemsTable>>[
        ($NewsItemsTable t) => OrderingTerm.desc(t.publishedAt),
      ])
      ..limit(limit);

    return query.watch().asyncMap((List<DbNewsItem> rows) async {
      final List<DbNewsInstrumentLink> links =
          await (db.select(db.newsInstrumentLinks)..where(
                ($NewsInstrumentLinksTable t) => t.newsId.isIn(
                  rows.map((DbNewsItem r) => r.id).toList(growable: false),
                ),
              ))
              .get();

      final List<NewsItem> items = rows
          .map(
            (DbNewsItem row) => row.toDomain(
              links
                  .where((DbNewsInstrumentLink l) => l.newsId == row.id)
                  .map((DbNewsInstrumentLink l) => l.instrumentId)
                  .toList(growable: false),
            ),
          )
          .toList(growable: false);

      return items;
    });
  }

  @override
  Stream<List<Filing>> watchRecentFilings({
    Set<String>? instrumentIds,
    int limit = 50,
  }) =>
      (db.select(db.filings)
            ..where(
              ($FilingsTable t) => instrumentIds == null
                  ? const Constant<bool>(true)
                  : t.instrumentId.isIn(instrumentIds),
            )
            ..orderBy(<OrderClauseGenerator<$FilingsTable>>[
              ($FilingsTable t) => OrderingTerm.desc(t.filedAt),
            ])
            ..limit(limit))
          .watch()
          .map(
            (List<DbFiling> rows) =>
                rows.map((DbFiling r) => r.toDomain()).toList(growable: false),
          );

  @override
  Future<Result<void>> saveQuote(Quote quote) =>
      Result.guardAsync<void>(() async {
        await db
            .into(db.quotes)
            .insertOnConflictUpdate(CompanionMappers.quote(quote));
      });

  @override
  Future<Result<void>> saveEarnings(
    List<EarningsEvent> events, {
    required String Function(EarningsEvent event) idOf,
  }) => Result.guardAsync<void>(() async {
    await db.transaction(() async {
      for (final EarningsEvent event in events) {
        await db
            .into(db.earningsEvents)
            .insertOnConflictUpdate(
              CompanionMappers.earningsEvent(event, id: idOf(event)),
            );
      }
    });
  });

  @override
  Future<Result<void>> saveCorporateEvents(List<CorporateEvent> events) =>
      Result.guardAsync<void>(() async {
        await db.transaction(() async {
          for (final CorporateEvent event in events) {
            await db
                .into(db.corporateEvents)
                .insertOnConflictUpdate(CompanionMappers.corporateEvent(event));
          }
        });
      });

  @override
  Future<Result<void>> saveNews(List<NewsItem> items) =>
      Result.guardAsync<void>(() async {
        await db.transaction(() async {
          for (final NewsItem item in items) {
            await db
                .into(db.newsItems)
                .insertOnConflictUpdate(CompanionMappers.newsItem(item));
            await (db.delete(db.newsInstrumentLinks)..where(
                  ($NewsInstrumentLinksTable link) =>
                      link.newsId.equals(item.id),
                ))
                .go();
            for (final String instrumentId
                in item.relatedInstrumentIds.toSet()) {
              await db
                  .into(db.newsInstrumentLinks)
                  .insert(
                    NewsInstrumentLinksCompanion.insert(
                      newsId: item.id,
                      instrumentId: instrumentId,
                    ),
                  );
            }
          }
        });
      });
}
