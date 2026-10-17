import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:speaking_coach/data/db/app_database.dart';
import 'package:speaking_coach/domain/conversation/session_enums.dart';

void main() {
  late AppDatabase db;
  final t0 = DateTime.utc(2026, 10, 17, 9);

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<int> newSession({int? providerId}) => db
      .into(db.sessions)
      .insert(
        SessionsCompanion.insert(
          mode: SessionMode.daily,
          startedAt: t0,
          status: SessionStatus.active,
          providerId: Value(providerId),
        ),
      );

  Future<int> newTurn(int sessionId) => db
      .into(db.turns)
      .insert(
        TurnsCompanion.insert(
          sessionId: sessionId,
          speaker: Speaker.user,
          transcript: 'I went to the park yesterday.',
          startedAt: t0,
        ),
      );

  test('profile defaults', () async {
    final id = await db.into(db.profiles).insert(ProfilesCompanion.insert());
    final p = await (db.select(
      db.profiles,
    )..where((r) => r.id.equals(id))).getSingle();
    expect(p.locale, 'ko');
    expect(p.targetMinutes, 30);
    expect(p.activeLevel, isNull);
  });

  test('session round-trips enums and timestamps', () async {
    final id = await newSession();
    final s = await (db.select(
      db.sessions,
    )..where((r) => r.id.equals(id))).getSingle();
    expect(s.mode, SessionMode.daily);
    expect(s.status, SessionStatus.active);
    expect(s.startedAt.toUtc(), t0);
    expect(s.endedAt, isNull);
  });

  test('update and delete a turn', () async {
    final turnId = await newTurn(await newSession());
    await (db.update(db.turns)..where((r) => r.id.equals(turnId))).write(
      const TurnsCompanion(wordCount: Value(6)),
    );
    final turn = await (db.select(
      db.turns,
    )..where((r) => r.id.equals(turnId))).getSingle();
    expect(turn.wordCount, 6);

    await (db.delete(db.turns)..where((r) => r.id.equals(turnId))).go();
    expect(await db.select(db.turns).get(), isEmpty);
  });

  test('speech metrics confidence stays null when unmeasured', () async {
    final sessionId = await newSession();
    await db
        .into(db.speechMetrics)
        .insert(
          SpeechMetricsCompanion.insert(
            sessionId: Value(sessionId),
            userMs: const Value(42000),
            assistantMs: const Value(18000),
            turnCount: const Value(7),
          ),
        );
    final m = await db.select(db.speechMetrics).getSingle();
    expect(m.userMs, 42000);
    expect(m.confidence, isNull);
  });

  test('deleting a session cascades to turns, metrics, corrections', () async {
    final sessionId = await newSession();
    final turnId = await newTurn(sessionId);
    await db
        .into(db.speechMetrics)
        .insert(SpeechMetricsCompanion.insert(sessionId: Value(sessionId)));
    await db
        .into(db.corrections)
        .insert(
          CorrectionsCompanion.insert(
            sessionId: sessionId,
            turnId: turnId,
            original: 'I go there yesterday.',
            suggested: 'I went there yesterday.',
          ),
        );

    await (db.delete(db.sessions)..where((r) => r.id.equals(sessionId))).go();

    expect(await db.select(db.turns).get(), isEmpty);
    expect(await db.select(db.speechMetrics).get(), isEmpty);
    expect(await db.select(db.corrections).get(), isEmpty);
  });

  test('deleting a provider keeps its sessions', () async {
    final providerId = await db
        .into(db.providers)
        .insert(
          ProvidersCompanion.insert(
            name: 'openai',
            vaultKeyRef: 'provider.openai',
          ),
        );
    final sessionId = await newSession(providerId: providerId);

    await (db.delete(db.providers)..where((r) => r.id.equals(providerId))).go();

    final s = await (db.select(
      db.sessions,
    )..where((r) => r.id.equals(sessionId))).getSingle();
    expect(s.providerId, isNull);
  });

  test('foreign keys are enforced', () async {
    expect(newTurn(999), throwsA(isA<SqliteException>()));
  });

  test('no table has a column that could hold a credential (S1)', () async {
    final suspicious = RegExp(
      'key|secret|token|password',
      caseSensitive: false,
    );
    for (final table in db.allTables) {
      final cols = await db
          .customSelect('PRAGMA table_info(${table.actualTableName})')
          .get();
      for (final c in cols) {
        final name = c.read<String>('name');
        if (name == 'vault_key_ref') continue;
        expect(
          suspicious.hasMatch(name),
          isFalse,
          reason: '${table.actualTableName}.$name',
        );
      }
    }
  });
}
