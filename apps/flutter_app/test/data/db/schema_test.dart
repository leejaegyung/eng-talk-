import 'dart:io';

import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:speaking_coach/data/db/app_database.dart';

void main() {
  test('created database matches the Drift table definitions', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await db.validateDatabaseSchema();
  });

  // Bumping schemaVersion requires `dart run drift_dev make-migrations`,
  // which snapshots the schema and generates step-by-step migration tests.
  test('schema snapshot exists for the current schemaVersion', () {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final snapshot = File(
      'drift_schemas/app_database/drift_schema_v${db.schemaVersion}.json',
    );
    expect(snapshot.existsSync(), isTrue, reason: snapshot.path);
  });
}
