/// Small non-secret app preferences (spec §9.1 `app_settings`). Never holds
/// credentials — those go to CredentialVault (docs/security.md S1).
abstract interface class SettingsStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
}

abstract final class SettingKeys {
  static const onboardingDone = 'onboarding.done';

  /// Read AI replies aloud by default ('true'/'false'; unset = true).
  static const speakReplies = 'voice.speak_replies';

  /// Listen again automatically after each AI turn ('true'/'false';
  /// unset = true).
  static const handsFree = 'voice.hands_free';

  /// Put recognized speech in the input box to fix before sending
  /// ('true'/'false'; unset = false).
  static const confirmSpeech = 'voice.confirm_speech';

  /// [LearnerLevel] name; unset until the placement assessment (slice D).
  static const learnerLevel = 'learner.level';

  /// [AiChoice] name; unset = ChatGPT.
  static const aiProvider = 'ai.provider';

  /// [LearningGoal] name; unset until chosen (onboarding or settings).
  static const learningGoal = 'learner.goal';

  /// Daily practice target in minutes; unset = no target.
  static const dailyGoalMinutes = 'learner.daily_minutes';
}
