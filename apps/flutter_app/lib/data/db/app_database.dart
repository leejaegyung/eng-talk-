import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../domain/conversation/session_enums.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Profiles, Providers, Sessions, Turns, SpeechMetrics, Corrections],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  /// On-device database in the app support directory.
  factory AppDatabase.open() =>
      AppDatabase(driftDatabase(name: 'speaking_coach'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
