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

  /// [LearnerLevel] name; unset until the placement assessment (slice D).
  static const learnerLevel = 'learner.level';
}
