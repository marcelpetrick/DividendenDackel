import 'package:dividendendackel/data/database/app_database.dart';
import 'package:dividendendackel/domain/entities/dividend_event.dart';
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
    test('opens at schema version 1 with every table created', () async {
      expect(db.schemaVersion, 1);

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
          'dividend_events',
          'earnings_events',
          'filings',
          'holdings',
          'instruments',
          'news_items',
          'provider_states',
          'quotes',
          'research_snapshots',
          'sync_jobs',
          'sync_logs',
          'watchlist_entries',
        ]),
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
        strategy.onUpgrade(Migrator(db), 0, 1),
        throwsA(isA<StateError>()),
      );
    });
  });
}
