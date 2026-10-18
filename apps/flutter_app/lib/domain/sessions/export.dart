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
