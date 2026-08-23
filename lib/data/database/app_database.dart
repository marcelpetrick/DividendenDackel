import 'package:dividendendackel/data/database/tables.dart';
// The generated part file references these enums by name, so they must be
// visible in this library even though nothing here mentions them directly.
import 'package:dividendendackel/domain/entities/corporate_event.dart';
import 'package:dividendendackel/domain/entities/dividend_event.dart';
import 'package:dividendendackel/domain/entities/earnings_event.dart';
import 'package:dividendendackel/domain/entities/news_item.dart';
import 'package:dividendendackel/domain/entities/portfolio.dart';
import 'package:dividendendackel/domain/entities/provenance.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

/// The local SQLite database (Vision.md §35).
///
/// The UI observes this database rather than provider responses: provider
/// updates are written here, and the streams below push the change into the
/// widgets. That is what makes the app usable offline (Vision.md §2.4, §44).
@DriftDatabase(
  tables: <Type>[
    Instruments,
    ProviderMappings,
    InvestmentPortfolios,
    Holdings,
    WatchlistEntries,
    PortfolioActivities,
    Quotes,
    PortfolioValuationSnapshots,
    FxRates,
    DividendEvents,
    EarningsEvents,
    CorporateEvents,
    NewsItems,
    NewsInstrumentLinks,
    Filings,
    ResearchSnapshots,
    AlertRules,
    ProviderStates,
    SyncJobs,
    SyncLogs,
    CacheMetadata,
  ],
)
class AppDatabase extends _$AppDatabase {
  /// Opens the database on the platform's application data directory.
  ///
  /// Works unchanged on Android and Linux; `drift_flutter` resolves the
  /// directory and supplies the bundled native sqlite3.
  AppDatabase() : super(_openConnection());

  /// Opens a database on [executor], for tests and migrations.
  AppDatabase.withExecutor(super.executor);

  /// Bumped whenever the schema changes. Never reused for a different schema.
  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
      await _createDefaultPortfolio();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // Vision.md §76: migrations must never silently delete the user's
      // portfolio. Each step is written explicitly, and a destructive reset is
      // not an acceptable default once releases exist. Schema version 1 is the
      // first app schema; every supported transition is additive and explicit,
      // while an unknown path fails loudly instead of dropping data.
      if (from < 1 || from >= to || to > 7) {
        throw StateError(
          'No migration is defined from schema version $from to $to. '
          'Refusing to modify the database rather than risk user data.',
        );
      }
      if (from < 2 && to >= 2) {
        await m.addColumn(dividendEvents, dividendEvents.reportedPeriodStart);
        await m.addColumn(dividendEvents, dividendEvents.reportedPeriodEnd);
      }
      if (from < 3 && to >= 3) {
        await m.createTable(fxRates);
      }
      if (from < 4 && to >= 4) {
        await m.createTable(corporateEvents);
      }
      if (from < 5 && to >= 5) {
        await m.createTable(investmentPortfolios);
        await _createDefaultPortfolio();
        if (await _tableExists('holdings')) {
          await m.alterTable(
            TableMigration(
              holdings,
              newColumns: <GeneratedColumn<Object>>[holdings.portfolioId],
              columnTransformer: <GeneratedColumn<Object>, Expression<Object>>{
                holdings.portfolioId: const Constant<String>(
                  InvestmentPortfolio.defaultId,
                ),
              },
            ),
          );
        }
        if (await _tableExists('watchlist_entries')) {
          await m.alterTable(
            TableMigration(
              watchlistEntries,
              newColumns: <GeneratedColumn<Object>>[
                watchlistEntries.portfolioId,
              ],
              columnTransformer: <GeneratedColumn<Object>, Expression<Object>>{
                watchlistEntries.portfolioId: const Constant<String>(
                  InvestmentPortfolio.defaultId,
                ),
              },
            ),
          );
        }
        await m.createTable(portfolioActivities);
        if (await _tableExists('holdings')) {
          await customStatement('''
            INSERT INTO portfolio_activities (
              portfolio_id, type, occurred_at, instrument_id, quantity,
              unit_price_amount, unit_price_currency, notes, source,
              fetched_at, updated_at, cache_state, confidence,
              reported_currency, original_symbol, provider_exchange
            )
            SELECT portfolio_id, 'openingBalance',
              COALESCE(purchase_date, fetched_at), instrument_id, quantity,
              average_price_amount, average_price_currency, notes, source,
              fetched_at, updated_at, cache_state, confidence,
              reported_currency, original_symbol, provider_exchange
            FROM holdings
            WHERE CAST(quantity AS REAL) > 0
          ''');
        }
      }
      if (from == 5 && to >= 6) {
        await customStatement(
          'CREATE UNIQUE INDEX idx_portfolio_activity_external '
          'ON portfolio_activities (portfolio_id, source, external_id)',
        );
      }
      if (from < 7 && to >= 7) {
        await m.createTable(portfolioValuationSnapshots);
      }
    },
    beforeOpen: (OpeningDetails details) async {
      // Referential integrity is off by default in SQLite and must be enabled
      // per connection, otherwise the cascade rules above never fire.
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  Future<void> _createDefaultPortfolio() async {
    final DateTime now = DateTime.now().toUtc();
    await into(investmentPortfolios).insertOnConflictUpdate(
      InvestmentPortfoliosCompanion.insert(
        id: InvestmentPortfolio.defaultId,
        name: 'My portfolio',
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  Future<bool> _tableExists(String name) async {
    final QueryRow? row = await customSelect(
      "SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = ? LIMIT 1",
      variables: <Variable<Object>>[Variable<String>(name)],
    ).getSingleOrNull();
    return row != null;
  }
}

QueryExecutor _openConnection() =>
    driftDatabase(name: 'dividendendackel', native: const DriftNativeOptions());
