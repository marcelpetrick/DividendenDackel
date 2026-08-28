import 'dart:io';

import 'package:dividendendackel/data/database/app_database.dart';
import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'generated/schema.dart';

void main() {
  late SchemaVerifier verifier;

  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  test('a freshly created database matches the recorded schema', () async {
    // Pins the shape of schemaVersion 7. If a table or column changes without
    // the version being bumped and a new snapshot recorded, this fails --
    // which is what stops a released build meeting a database it cannot read.
    final AppDatabase db = AppDatabase.withExecutor(NativeDatabase.memory());
    addTearDown(db.close);

    await verifier.migrateAndValidate(db, AppDatabase.latestSchemaVersion);
  });

  test('a snapshot exists for the declared schema version', () {
    // Bumping schemaVersion without recording a snapshot leaves the next
    // release nothing to verify against, which is how a build ends up unable
    // to open a database an earlier one wrote.
    final File snapshot = File(
      'drift_schemas/drift_schema_v${AppDatabase.latestSchemaVersion}.json',
    );

    expect(
      snapshot.existsSync(),
      isTrue,
      reason:
          'Record it with: dart run drift_dev schema dump '
          'lib/data/database/app_database.dart drift_schemas/ '
          'then regenerate with: dart run drift_dev schema generate '
          'drift_schemas/ test/data/database/generated/',
    );
  });

  test('the declared version and the running schema agree', () {
    final AppDatabase db = AppDatabase.withExecutor(NativeDatabase.memory());
    addTearDown(db.close);

    expect(db.schemaVersion, AppDatabase.latestSchemaVersion);
  });
}
