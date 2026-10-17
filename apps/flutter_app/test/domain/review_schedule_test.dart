import 'package:flutter_test/flutter_test.dart';
import 'package:speaking_coach/domain/sessions/review_schedule.dart';
import 'package:speaking_coach/domain/sessions/session_records.dart';

void main() {
  final now = DateTime.utc(2026, 10, 17);
  final item = ReviewItem(
    id: 1,
    original: 'I go there yesterday',
    suggested: 'I went there yesterday.',
    dueAt: now,
    intervalDays: 0,
    repetitions: 0,
  );

  test('intervals grow 1, 3, 7, 14, 30 then stay', () {
    var i = item;
    final days = <int>[];
    for (var n = 0; n < 7; n++) {
      i = ReviewSchedule.practiced(i, now);
      days.add(i.intervalDays);
    }
    expect(days, [1, 3, 7, 14, 30, 30, 30]);
    expect(i.repetitions, 7);
    expect(i.dueAt, now.add(const Duration(days: 30)));
  });

  test('later brings it back tomorrow without counting', () {
    final i = ReviewSchedule.later(ReviewSchedule.practiced(item, now), now);
    expect(i.intervalDays, 1);
    expect(i.repetitions, 1);
  });
}
