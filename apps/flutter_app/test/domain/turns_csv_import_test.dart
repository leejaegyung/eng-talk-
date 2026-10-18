import 'package:flutter_test/flutter_test.dart';
import 'package:speaking_coach/domain/sessions/export.dart';

void main() {
  test('the turns CSV round-trips into backup sessions', () {
    final csv = exportFiles({
      'sessions': [
        {
          'id': 7,
          'mode': 'daily',
          'level': 'l2',
          'topic': 'Food, "spicy"',
          'turns': [
            {
              'speaker': 'assistant',
              'text': 'Hi!\nWhat did you eat?',
              'at': '2026-10-17T09:00:00.000Z',
            },
            {
              'speaker': 'user',
              'text': 'Kimchi, rice',
              'at': '2026-10-17T09:00:05.000Z',
            },
            {
              'speaker': 'user',
              'text': 'Hint please',
              'at': '2026-10-17T09:00:09.000Z',
              'quick_action': true,
            },
          ],
        },
        {
          'id': 8,
          'mode': 'roleplay',
          'turns': [
            {
              'speaker': 'user',
              'text': 'Hello',
              'at': '2026-10-18T10:00:00.000Z',
            },
          ],
        },
      ],
    })['speaking-coach-turns.csv']!;

    final backup = backupFromTurnsCsv('﻿$csv');

    expect(backup['format'], backupFormat);
    final sessions = (backup['sessions']! as List).cast<Map<String, Object?>>();
    expect(sessions, hasLength(2));
    final first = sessions.first;
    expect(first['mode'], 'daily');
    expect(first['level'], 'l2');
    expect(first['topic'], 'Food, "spicy"');
    expect(first['started_at'], '2026-10-17T09:00:00.000Z');
    expect(first['ended_at'], '2026-10-17T09:00:09.000Z');
    final turns = (first['turns']! as List).cast<Map<String, Object?>>();
    expect(turns.map((t) => t['text']), [
      'Hi!\nWhat did you eat?',
      'Kimchi, rice',
      'Hint please',
    ]);
    expect(turns.last['quick_action'], true);
    expect(sessions.last['level'], isNull);
  });

  test('other CSVs are not backups', () {
    expect(
      () => backupFromTurnsCsv('name,price\napple,3\n'),
      throwsFormatException,
    );
    expect(() => backupFromTurnsCsv(''), throwsFormatException);
  });
}
