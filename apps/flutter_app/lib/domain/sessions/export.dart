import 'dart:convert';

/// Saves export files somewhere the learner can reach and returns a
/// human-readable location.
abstract interface class DataExporter {
  Future<String> export(Map<String, String> files);
}

/// Lets the learner pick a backup file; null when cancelled.
abstract interface class BackupPicker {
  Future<String?> pick();
}

/// Non-secret preferences carried in a backup (never credentials, S1).
const backupSettingKeys = [
  'learner.level',
  'learner.goal',
  'learner.daily_minutes',
  'review.repeats',
  'voice.speak_replies',
  'voice.hands_free',
  'voice.confirm_speech',
  'voice.auto_barge_in',
  'voice.engine',
  'app.language',
];

/// Export files from [SessionRepository.exportAll] data (spec §9.2:
/// JSON/CSV, never credentials).
Map<String, String> exportFiles(Map<String, Object?> data) => {
  'speaking-coach.json': const JsonEncoder.withIndent('  ').convert(data),
  'speaking-coach-turns.csv': _turnsCsv(data),
};

String _turnsCsv(Map<String, Object?> data) {
  String cell(Object? v) {
    final s = v?.toString() ?? '';
    return RegExp(r'[",\n\r]').hasMatch(s) ? '"${s.replaceAll('"', '""')}"' : s;
  }

  final rows = [
    'session_id,started_at,mode,level,topic,speaker,quick_action,text',
  ];
  for (final s
      in (data['sessions'] as List? ?? const []).cast<Map<String, Object?>>()) {
    for (final t
        in (s['turns'] as List? ?? const []).cast<Map<String, Object?>>()) {
      rows.add(
        [
          s['id'],
          t['at'],
          s['mode'],
          s['level'],
          s['topic'],
          t['speaker'],
          t['quick_action'] == true ? 'yes' : '',
          t['text'],
        ].map(cell).join(','),
      );
    }
  }
  return '${rows.join('\r\n')}\r\n';
}

/// `format` of a backup file.
const backupFormat = 'speaking-coach-export';

/// A backup rebuilt from the turns CSV, so it can be restored too. The CSV
/// only has conversations (no feedback, reviews or settings); each session
/// starts at its first turn. Throws [FormatException] for any other CSV.
Map<String, Object?> backupFromTurnsCsv(String csv) {
  final rows = _parseCsv(csv.replaceFirst('﻿', ''));
  if (rows.isEmpty) throw const FormatException('empty CSV');
  final header = rows.first.map((h) => h.trim()).toList();
  const needed = ['session_id', 'started_at', 'mode', 'speaker', 'text'];
  if (!needed.every(header.contains)) {
    throw const FormatException('not a Speaking Coach turns CSV');
  }
  String? at(List<String> row, String name) {
    final i = header.indexOf(name);
    if (i < 0 || i >= row.length) return null;
    final v = row[i];
    return v.isEmpty ? null : v;
  }

  final sessions = <String, Map<String, Object?>>{};
  for (final row in rows.skip(1)) {
    final id = at(row, 'session_id');
    final time = at(row, 'started_at');
    if (id == null || time == null) continue;
    final s = sessions.putIfAbsent(
      id,
      () => {
        'mode': at(row, 'mode'),
        'level': at(row, 'level'),
        'topic': at(row, 'topic'),
        'started_at': time,
        'status': 'completed',
        'turns': <Map<String, Object?>>[],
      },
    );
    s['ended_at'] = time;
    (s['turns']! as List<Map<String, Object?>>).add({
      'speaker': at(row, 'speaker'),
      'text': at(row, 'text') ?? '',
      'at': time,
      if (at(row, 'quick_action') == 'yes') 'quick_action': true,
    });
  }
  return {
    'format': backupFormat,
    'version': 2,
    'sessions': sessions.values.toList(),
  };
}

/// RFC 4180: quoted cells may hold commas, quotes ("") and line breaks.
List<List<String>> _parseCsv(String text) {
  final rows = <List<String>>[];
  var row = <String>[];
  final cell = StringBuffer();
  var quoted = false;
  for (var i = 0; i < text.length; i++) {
    final c = text[i];
    if (quoted) {
      if (c != '"') {
        cell.write(c);
      } else if (i + 1 < text.length && text[i + 1] == '"') {
        cell.write('"');
        i++;
      } else {
        quoted = false;
      }
    } else if (c == '"') {
      quoted = true;
    } else if (c == ',') {
      row.add(cell.toString());
      cell.clear();
    } else if (c == '\n' || c == '\r') {
      if (c == '\r' && i + 1 < text.length && text[i + 1] == '\n') i++;
      row.add(cell.toString());
      cell.clear();
      if (row.any((v) => v.isNotEmpty)) rows.add(row);
      row = <String>[];
    } else {
      cell.write(c);
    }
  }
  row.add(cell.toString());
  if (row.any((v) => v.isNotEmpty)) rows.add(row);
  return rows;
}
