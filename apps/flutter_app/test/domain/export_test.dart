import 'package:flutter_test/flutter_test.dart';
import 'package:speaking_coach/domain/sessions/export.dart';

void main() {
  final data = <String, Object?>{
    'sessions': [
      {
        'id': 1,
        'mode': 'daily',
        'level': 'L2',
        'topic': 'Food, "spicy"',
        'turns': [
          {'speaker': 'user', 'text': 'I like it,\nvery much', 'at': 't0'},
          {
            'speaker': 'user',
            'text': 'Hint?',
            'at': 't1',
            'quick_action': true,
          },
        ],
      },
    ],
  };

  test('JSON and CSV files', () {
    final files = exportFiles(data);
    expect(files.keys, ['speaking-coach.json', 'speaking-coach-turns.csv']);
    expect(
      files['speaking-coach.json'],
      contains('"topic": "Food, \\"spicy\\""'),
    );
  });

  test('CSV escapes commas, quotes and newlines', () {
    final lines = exportFiles(data)['speaking-coach-turns.csv']!.split('\r\n');
    expect(lines.first, startsWith('session_id,'));
    expect(
      lines[1],
      '1,t0,daily,L2,"Food, ""spicy""",user,,"I like it,\nvery much"',
    );
    expect(lines[2], endsWith(',user,yes,Hint?'));
  });
}
