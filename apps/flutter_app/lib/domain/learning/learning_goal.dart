import '../conversation/session_enums.dart';

/// Why the learner practices (spec §3.1 onboarding), persisted by name.
/// Picks the mode suggested on home and preselected in setup.
enum LearningGoal {
  everyday(SessionMode.daily),
  travel(SessionMode.roleplay),
  work(SessionMode.opinion),
  interview(SessionMode.roleplay),
  confidence(SessionMode.random);

  const LearningGoal(this.mode);

  final SessionMode mode;
}

/// Daily practice targets offered, in minutes.
const dailyGoalOptions = [10, 20, 30, 45];

/// Session lengths offered in setup (spec §2.4).
const sessionLengths = [
  Duration(minutes: 20),
  Duration(minutes: 30),
  Duration(minutes: 45),
];

/// The session length that fits a daily target best: the longest one not
/// over it, else the shortest.
Duration sessionLengthFor(int dailyMinutes) => sessionLengths.lastWhere(
  (l) => l.inMinutes <= dailyMinutes,
  orElse: () => sessionLengths.first,
);
