import 'package:dividendendackel/data/database/tables.dart';
// The generated part file references these enums by name, so they must be
// visible in this library even though nothing here mentions them directly.
import 'package:dividendendackel/domain/entities/dividend_event.dart';
import 'package:dividendendackel/domain/entities/earnings_event.dart';
import 'package:dividendendackel/domain/entities/news_item.dart';
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
    Holdings,
    WatchlistEntries,
    Quotes,
    FxRates,
    DividendEvents,
    EarningsEvents,
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
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // Vision.md §76: migrations must never silently delete the user's
      // portfolio. Each step is written explicitly, and a destructive reset is
      // not an acceptable default once releases exist. Schema version 1 is the
      // first app schema; every supported transition is additive and explicit,
      // while an unknown path fails loudly instead of dropping data.
      if (from < 1 || from >= to || to > 3) {
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
    },
    beforeOpen: (OpeningDetails details) async {
      // Referential integrity is off by default in SQLite and must be enabled
      // per connection, otherwise the cascade rules above never fire.
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}

QueryExecutor _openConnection() =>
    driftDatabase(name: 'dividendendackel', native: const DriftNativeOptions());
