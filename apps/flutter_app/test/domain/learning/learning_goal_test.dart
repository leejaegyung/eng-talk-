import 'package:flutter_test/flutter_test.dart';
import 'package:speaking_coach/domain/conversation/session_enums.dart';
import 'package:speaking_coach/domain/learning/learning_goal.dart';

void main() {
  test('each goal suggests a practice mode', () {
    expect(LearningGoal.everyday.mode, SessionMode.daily);
    expect(LearningGoal.travel.mode, SessionMode.roleplay);
    expect(LearningGoal.work.mode, SessionMode.opinion);
    for (final g in LearningGoal.values) {
      expect(g.mode, isNot(SessionMode.assessment));
    }
  });

  test('session length fits the daily target', () {
    expect(sessionLengthFor(10).inMinutes, 20, reason: 'shortest offered');
    expect(sessionLengthFor(20).inMinutes, 20);
    expect(sessionLengthFor(30).inMinutes, 30);
    expect(sessionLengthFor(45).inMinutes, 45);
  });
}
