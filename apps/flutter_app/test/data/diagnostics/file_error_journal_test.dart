import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:speaking_coach/data/diagnostics/file_error_journal.dart';

void main() {
  late Directory dir;
  late File file;
  var now = DateTime.utc(2026, 10, 18, 9);

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('journal');
    file = File('${dir.path}/errors.jsonl');
  });
  tearDown(() => dir.delete(recursive: true));

  FileErrorJournal journal() => FileErrorJournal(file, now: () => now);

  test('keeps type, a short redacted message and app frames only', () async {
    final stack = StackTrace.fromString(
      '#0 thing (package:speaking_coach/features/x/y.dart:42:7)\n'
      '#1 other (package:flutter/src/widgets/framework.dart:100:3)\n'
      '#2 more (package:speaking_coach/app/app.dart:9:1)',
    );
    await journal().record(
      StateError('bad sk-FAKE-0123456789abcdef and ${'x' * 400}'),
      stack,
      source: 'flutter',
    );
    final e = (await journal().entries()).single;
    expect(e.type, 'StateError');
    expect(e.source, 'flutter');
    expect(e.message, contains('[REDACTED]'));
    expect(e.message, isNot(contains('sk-FAKE')));
    expect(e.message.length, lessThanOrEqualTo(201));
    expect(e.frames, ['features/x/y.dart:42', 'app/app.dart:9']);
  });

  test('newest first, capped, survives a reopen', () async {
    final j = journal();
    for (var i = 0; i < FileErrorJournal.maxEntries + 5; i++) {
      now = now.add(const Duration(seconds: 1));
      await j.record(Exception('e$i'), null, source: 'app');
    }
    final all = await journal().entries();
    expect(all, hasLength(FileErrorJournal.maxEntries));
    expect(all.first.message, contains('e${FileErrorJournal.maxEntries + 4}'));
  });

  test('clear removes everything; broken lines are skipped', () async {
    await file.writeAsString('not json\n');
    await journal().record(Exception('ok'), null, source: 'app');
    expect(await journal().entries(), hasLength(1));
    await journal().clear();
    expect(await journal().entries(), isEmpty);
  });
}
