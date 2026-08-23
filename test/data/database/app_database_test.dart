import 'package:dividendendackel/data/database/app_database.dart';
import 'package:dividendendackel/domain/entities/dividend_event.dart';
import 'package:dividendendackel/domain/entities/portfolio.dart';
// drift exports query-builder helpers that collide with the matcher names.
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.withExecutor(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> insertAllianz() => db
      .into(db.instruments)
      .insert(
        InstrumentsCompanion.insert(
          internalId: 'isin:DE0008404005',
          symbol: 'ALV',
          name: 'Allianz SE',
          currencyCode: 'EUR',
          mic: const Value<String>('XETR'),
        ),
      );

  group('AppDatabase', () {
    test('opens at schema version 7 with every table created', () async {
      expect(db.schemaVersion, 7);

      final List<String> tables =
          await db
                .customSelect(
                  "SELECT name FROM sqlite_master WHERE type = 'table' "
                  "AND name NOT LIKE 'sqlite_%'",
                )
                .map((QueryRow row) => row.read<String>('name'))
                .get()
            ..sort();

      // Vision.md §35 names the entities the local database must hold.
      expect(
        tables,
        containsAll(<String>[
          'alert_rules',
          'cache_metadata',
          'corporate_events',
          'dividend_events',
          'earnings_events',
          'filings',
          'fx_rates',
          'holdings',
          'instruments',
          'news_items',
          'investment_portfolios',
          'portfolio_activities',
          'portfolio_valuation_snapshots',
          'provider_states',
          'quotes',
          'research_snapshots',
          'sync_jobs',
          'sync_logs',
          'watchlist_entries',
        ]),
      );
    });

    test('migrates schema 6 by adding local valuation history', () async {
      await db.close();
      final AppDatabase migrated = AppDatabase.withExecutor(
        NativeDatabase.memory(
          setup: (database) {
            database.execute('PRAGMA user_version = 6');
          },
        ),
      );
      db = migrated;

      final List<String> tables = await migrated
          .customSelect("SELECT name FROM sqlite_master WHERE type = 'table'")
          .map((QueryRow row) => row.read<String>('name'))
          .get();
      expect(tables, contains('portfolio_valuation_snapshots'));
    });

    test(
      'enforces unique imported identities per portfolio and source',
      () async {
        final List<QueryRow> indexes = await db
            .customSelect('PRAGMA index_list(portfolio_activities)')
            .get();

        expect(
          indexes.any(
            (QueryRow row) =>
                row.read<String>('name') == 'idx_portfolio_activity_external' &&
                row.read<int>('unique') == 1,
          ),
          isTrue,
        );
      },
    );

    test('migrates schema 5 by adding the import identity index', () async {
      await db.close();
      final AppDatabase migrated = AppDatabase.withExecutor(
        NativeDatabase.memory(
          setup: (database) {
            database
              ..execute('''
                CREATE TABLE portfolio_activities (
                  portfolio_id TEXT NOT NULL,
                  source TEXT NOT NULL,
                  external_id TEXT
                )
              ''')
              ..execute('PRAGMA user_version = 5');
          },
        ),
      );
      db = migrated;

      final List<QueryRow> indexes = await migrated
          .customSelect('PRAGMA index_list(portfolio_activities)')
          .get();
      expect(
        indexes.any(
          (QueryRow row) =>
              row.read<String>('name') == 'idx_portfolio_activity_external' &&
              row.read<int>('unique') == 1,
        ),
        isTrue,
      );
    });

    test('stores money as exact decimal text, never as a float', () async {
      await insertAllianz();
      await db
          .into(db.dividendEvents)
          .insert(
            DividendEventsCompanion.insert(
              id: 'alv-2026-05',
              instrumentId: 'isin:DE0008404005',
              amountPerShare: '13.8000',
              amountCurrency: 'EUR',
              status: DividendStatus.confirmed,
              source: 'fmp',
              fetchedAt: DateTime.utc(2026, 8, 22),
            ),
          );

      final String stored = await db
          .customSelect('SELECT amount_per_share AS a FROM dividend_events')
          .map((QueryRow row) => row.read<String>('a'))
          .getSingle();

      // A REAL column would have turned this into 13.800000000000001.
      expect(stored, '13.8000');
    });

    test('stores timestamps as ISO-8601 text', () async {
      await insertAllianz();
      await db
          .into(db.quotes)
          .insert(
            QuotesCompanion.insert(
              instrumentId: 'isin:DE0008404005',
              priceAmount: '287.50',
              priceCurrency: 'EUR',
              asOf: DateTime.utc(2026, 8, 22, 17, 30),
              source: 'fmp',
              fetchedAt: DateTime.utc(2026, 8, 22, 17, 30),
            ),
          );

      final String stored = await db
          .customSelect('SELECT as_of AS t FROM quotes')
          .map((QueryRow row) => row.read<String>('t'))
          .getSingle();

      expect(stored, contains('2026-08-22'));
    });

    test('round-trips a timestamp unchanged', () async {
      final DateTime asOf = DateTime.utc(2026, 8, 22, 17, 30, 45);
      await insertAllianz();
      await db
          .into(db.quotes)
          .insert(
            QuotesCompanion.insert(
              instrumentId: 'isin:DE0008404005',
              priceAmount: '287.50',
              priceCurrency: 'EUR',
              asOf: asOf,
              source: 'fmp',
              fetchedAt: asOf,
            ),
          );

      final DbQuote row = await db.select(db.quotes).getSingle();
      expect(row.asOf.toUtc(), asOf);
    });

    test('enforces foreign keys', () async {
      // Without PRAGMA foreign_keys = ON this insert would silently succeed.
      await expectLater(
        db
            .into(db.quotes)
            .insert(
              QuotesCompanion.insert(
                instrumentId: 'does-not-exist',
                priceAmount: '1',
                priceCurrency: 'EUR',
                asOf: DateTime.utc(2026),
                source: 'fmp',
                fetchedAt: DateTime.utc(2026),
              ),
            ),
        throwsA(isA<SqliteException>()),
      );
    });

    test('cascades market data when an instrument is removed', () async {
      await insertAllianz();
      await db
          .into(db.dividendEvents)
          .insert(
            DividendEventsCompanion.insert(
              id: 'alv-2026-05',
              instrumentId: 'isin:DE0008404005',
              amountPerShare: '13.80',
              amountCurrency: 'EUR',
              status: DividendStatus.confirmed,
              source: 'fmp',
              fetchedAt: DateTime.utc(2026),
            ),
          );

      await (db.delete(db.instruments)..where(
            ($InstrumentsTable t) => t.internalId.equals('isin:DE0008404005'),
          ))
          .go();

      expect(await db.select(db.dividendEvents).get(), isEmpty);
    });

    test(
      'refuses to delete a held instrument, protecting the portfolio',
      () async {
        // Vision.md §76: a refresh must never silently delete the user's
        // portfolio. Holdings intentionally do not cascade.
        await insertAllianz();
        await db
            .into(db.holdings)
            .insert(
              HoldingsCompanion.insert(
                instrumentId: 'isin:DE0008404005',
                quantity: '20',
                source: 'user',
                fetchedAt: DateTime.utc(2026),
              ),
            );

        await expectLater(
          (db.delete(db.instruments)..where(
                ($InstrumentsTable t) =>
                    t.internalId.equals('isin:DE0008404005'),
              ))
              .go(),
          throwsA(isA<SqliteException>()),
        );
        expect(await db.select(db.holdings).get(), hasLength(1));
      },
    );

    test('persists enum values as readable text', () async {
      await insertAllianz();
      await db
          .into(db.dividendEvents)
          .insert(
            DividendEventsCompanion.insert(
              id: 'alv-est',
              instrumentId: 'isin:DE0008404005',
              amountPerShare: '14.00',
              amountCurrency: 'EUR',
              status: DividendStatus.historicallyEstimated,
              source: 'local',
              fetchedAt: DateTime.utc(2026),
            ),
          );

      final String stored = await db
          .customSelect('SELECT status AS s FROM dividend_events')
          .map((QueryRow row) => row.read<String>('s'))
          .getSingle();

      // Text, not an ordinal: reordering the enum must not rewrite history.
      expect(stored, 'historicallyEstimated');

      final DbDividendEvent row = await db
          .select(db.dividendEvents)
          .getSingle();
      expect(row.status, DividendStatus.historicallyEstimated);
    });

    test('allows an unconfirmed payment date', () async {
      await insertAllianz();
      await db
          .into(db.dividendEvents)
          .insert(
            DividendEventsCompanion.insert(
              id: 'alv-no-pay-date',
              instrumentId: 'isin:DE0008404005',
              amountPerShare: '13.80',
              amountCurrency: 'EUR',
              status: DividendStatus.announced,
              exDate: Value<DateTime>(DateTime.utc(2026, 5, 8)),
              source: 'fmp',
              fetchedAt: DateTime.utc(2026),
            ),
          );

      final DbDividendEvent row = await db
          .select(db.dividendEvents)
          .getSingle();
      expect(row.paymentDate, isNull);
      expect(row.exDate, isNotNull);
    });

    test(
      'migrates v4 ownership into the default portfolio and ledger',
      () async {
        await db.close();
        final AppDatabase migrated = AppDatabase.withExecutor(
          NativeDatabase.memory(
            setup: (database) {
              database
                ..execute('''
                CREATE TABLE instruments (
                  internal_id TEXT NOT NULL PRIMARY KEY,
                  symbol TEXT NOT NULL,
                  name TEXT NOT NULL,
                  currency_code TEXT NOT NULL,
                  exchange TEXT, mic TEXT, isin TEXT, country TEXT, sector TEXT
                )
              ''')
                ..execute('''
                CREATE TABLE holdings (
                  id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
                  instrument_id TEXT NOT NULL,
                  quantity TEXT NOT NULL,
                  average_price_amount TEXT,
                  average_price_currency TEXT,
                  purchase_date TEXT,
                  notes TEXT,
                  source TEXT NOT NULL,
                  fetched_at TEXT NOT NULL,
                  updated_at TEXT,
                  cache_state TEXT NOT NULL DEFAULT 'fresh',
                  confidence TEXT NOT NULL DEFAULT 'high',
                  reported_currency TEXT,
                  original_symbol TEXT,
                  provider_exchange TEXT
                )
              ''')
                ..execute('''
                CREATE TABLE watchlist_entries (
                  instrument_id TEXT NOT NULL PRIMARY KEY,
                  added_at TEXT NOT NULL,
                  notes TEXT,
                  source TEXT NOT NULL,
                  fetched_at TEXT NOT NULL,
                  updated_at TEXT,
                  cache_state TEXT NOT NULL DEFAULT 'fresh',
                  confidence TEXT NOT NULL DEFAULT 'high',
                  reported_currency TEXT,
                  original_symbol TEXT,
                  provider_exchange TEXT
                )
              ''')
                ..execute(
                  'INSERT INTO instruments (internal_id, symbol, name, currency_code) '
                  "VALUES ('asset', 'AAA', 'Asset AG', 'EUR')",
                )
                ..execute(
                  'INSERT INTO holdings (instrument_id, quantity, '
                  'average_price_amount, average_price_currency, source, fetched_at) '
                  "VALUES ('asset', '12.5', '80', 'EUR', 'user', "
                  "'2026-08-22T12:00:00.000Z')",
                )
                ..execute(
                  'INSERT INTO watchlist_entries (instrument_id, added_at, source, fetched_at) '
                  "VALUES ('asset', '2026-08-22T12:00:00.000Z', 'user', "
                  "'2026-08-22T12:00:00.000Z')",
                )
                ..execute('PRAGMA user_version = 4');
            },
          ),
        );
        db = migrated;

        final DbHolding holding = await migrated
            .select(migrated.holdings)
            .getSingle();
        final DbWatchlistEntry watched = await migrated
            .select(migrated.watchlistEntries)
            .getSingle();
        final DbPortfolioActivity opening = await migrated
            .select(migrated.portfolioActivities)
            .getSingle();

        expect(holding.portfolioId, 'default');
        expect(holding.quantity, '12.5');
        expect(watched.portfolioId, 'default');
        expect(opening.type, PortfolioActivityType.openingBalance);
        expect(opening.quantity, '12.5');
        expect(
          await migrated.select(migrated.investmentPortfolios).get(),
          hasLength(1),
        );
      },
    );

    test('migrates schema 1 through 7 without losing dividend rows', () async {
      await db.close();
      final AppDatabase migrated = AppDatabase.withExecutor(
        NativeDatabase.memory(
          setup: (database) {
            database
              ..execute(
                'CREATE TABLE dividend_events ('
                'id TEXT NOT NULL PRIMARY KEY, marker TEXT)',
              )
              ..execute(
                "INSERT INTO dividend_events (id, marker) VALUES ('kept', 'yes')",
              )
              ..execute('PRAGMA user_version = 1');
          },
        ),
      );
      db = migrated;

      final List<String> columns = await migrated
          .customSelect('PRAGMA table_info(dividend_events)')
          .map((QueryRow row) => row.read<String>('name'))
          .get();
      final String marker = await migrated
          .customSelect("SELECT marker FROM dividend_events WHERE id = 'kept'")
          .map((QueryRow row) => row.read<String>('marker'))
          .getSingle();

      expect(
        columns,
        containsAll(<String>['reported_period_start', 'reported_period_end']),
      );
      expect(marker, 'yes');
      final List<String> tables = await migrated
          .customSelect("SELECT name FROM sqlite_master WHERE type = 'table'")
          .map((QueryRow row) => row.read<String>('name'))
          .get();
      expect(tables, contains('fx_rates'));
      expect(tables, contains('corporate_events'));
      expect(tables, contains('investment_portfolios'));
      expect(tables, contains('portfolio_activities'));
      expect(tables, contains('portfolio_valuation_snapshots'));
    });

    test('migrates schema 2 by adding the FX table', () async {
      await db.close();
      final AppDatabase migrated = AppDatabase.withExecutor(
        NativeDatabase.memory(
          setup: (database) {
            database.execute('PRAGMA user_version = 2');
          },
        ),
      );
      db = migrated;

      final List<String> tables = await migrated
          .customSelect("SELECT name FROM sqlite_master WHERE type = 'table'")
          .map((QueryRow row) => row.read<String>('name'))
          .get();

      expect(tables, contains('fx_rates'));
      expect(tables, contains('corporate_events'));
    });

    test('migrates schema 3 by adding company events', () async {
      await db.close();
      final AppDatabase migrated = AppDatabase.withExecutor(
        NativeDatabase.memory(
          setup: (database) {
            database.execute('PRAGMA user_version = 3');
          },
        ),
      );
      db = migrated;

      final List<String> tables = await migrated
          .customSelect("SELECT name FROM sqlite_master WHERE type = 'table'")
          .map((QueryRow row) => row.read<String>('name'))
          .get();

      expect(tables, contains('corporate_events'));
    });

    test(
      'pushes database changes to watchers, which is how the UI updates',
      () async {
        final Future<List<DbInstrument>> firstNonEmpty = db
            .select(db.instruments)
            .watch()
            .firstWhere((List<DbInstrument> rows) => rows.isNotEmpty);

        await insertAllianz();

        expect((await firstNonEmpty).single.name, 'Allianz SE');
      },
    );

    test('refuses an undefined upgrade rather than dropping data', () async {
      final MigrationStrategy strategy = db.migration;

      await expectLater(
        strategy.onUpgrade(Migrator(db), 0, 4),
        throwsA(isA<StateError>()),
      );
    });
  });
}
