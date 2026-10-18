import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../domain/conversation/session_enums.dart';
import 'app_database.steps.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Profiles,
    Providers,
    Sessions,
    Turns,
    SpeechMetrics,
    Corrections,
    AppSettings,
    Expressions,
    ReviewQueue,
    Assessments,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  /// On-device database in the app support directory.
  factory AppDatabase.open() =>
      AppDatabase(driftDatabase(name: 'speaking_coach'));

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: stepByStep(
      from1To2: (m, schema) => m.createTable(schema.appSettings),
      from2To3: (m, schema) async {
        final s = schema.sessions;
        final t = schema.turns;
        final c = schema.corrections;
        for (final (table, column) in [
          (s, s.goal),
          (s, s.role),
          (s, s.lengthMinutes),
          (s, s.feedbackJson),
          (t, t.isRequest),
          (t, t.speechMs),
          (c, c.severity),
          (c, c.practicePrompt),
        ]) {
          await m.addColumn(table, column);
        }
        await m.createTable(schema.expressions);
        await m.createTable(schema.reviewQueue);
        await m.createTable(schema.assessments);
      },
      from3To4: (m, schema) =>
          m.addColumn(schema.corrections, schema.corrections.category),
    ),
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
