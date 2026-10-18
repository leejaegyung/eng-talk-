import 'package:drift/drift.dart';

import '../../domain/conversation/session_enums.dart';

/// Schema v1 (spec §9.1). Credentials are never stored here — providers only
/// hold a `vault_key_ref` into CredentialVault (docs/security.md S1).

class Profiles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get locale => text().withDefault(const Constant('ko'))();
  IntColumn get targetMinutes => integer().withDefault(const Constant(30))();
  TextColumn get activeLevel => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class Providers extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Adapter kind, e.g. `openai`.
  TextColumn get name => text()();

  /// Chosen from the provider's model list at runtime, never hardcoded.
  TextColumn get modelId => text().nullable()();
  TextColumn get vaultKeyRef => text()();
  TextColumn get settingsJson => text().withDefault(const Constant('{}'))();
}

class Sessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get mode => textEnum<SessionMode>()();
  TextColumn get topic => text().nullable()();
  TextColumn get level => text().nullable()();

  /// v3: rest of the setup and the validated feedback (spec §8.4 JSON).
  TextColumn get goal => text().nullable()();
  TextColumn get role => text().nullable()();
  IntColumn get lengthMinutes => integer().withDefault(const Constant(30))();
  TextColumn get feedbackJson => text().nullable()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  TextColumn get status => textEnum<SessionStatus>()();
  IntColumn get providerId => integer().nullable().references(
    Providers,
    #id,
    onDelete: KeyAction.setNull,
  )();
}

class Turns extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId =>
      integer().references(Sessions, #id, onDelete: KeyAction.cascade)();
  TextColumn get speaker => textEnum<Speaker>()();
  TextColumn get transcript => text()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  IntColumn get wordCount => integer().withDefault(const Constant(0))();

  /// v3: quick-action line rather than the learner's own answer.
  BoolColumn get isRequest => boolean().withDefault(const Constant(false))();

  /// v3: estimated speaking time; null when not measured.
  IntColumn get speechMs => integer().nullable()();
}

class SpeechMetrics extends Table {
  IntColumn get sessionId =>
      integer().references(Sessions, #id, onDelete: KeyAction.cascade)();
  IntColumn get userMs => integer().withDefault(const Constant(0))();
  IntColumn get assistantMs => integer().withDefault(const Constant(0))();
  IntColumn get turnCount => integer().withDefault(const Constant(0))();

  /// Null when not measured — never fill in a guess (spec §11, S7).
  RealColumn get confidence => real().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {sessionId};
}

class Corrections extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId =>
      integer().references(Sessions, #id, onDelete: KeyAction.cascade)();
  IntColumn get turnId =>
      integer().references(Turns, #id, onDelete: KeyAction.cascade)();
  TextColumn get original => text()();
  TextColumn get suggested => text()();
  TextColumn get explanation => text().nullable()();
  BoolColumn get practiced => boolean().withDefault(const Constant(false))();

  /// v3
  TextColumn get severity => text().nullable()();
  TextColumn get practicePrompt => text().nullable()();

  /// v4: [ErrorCategory] wire value; null for older feedback.
  TextColumn get category => text().nullable()();

  /// v5: [ReviewKind] name; null = say it again.
  TextColumn get kind => text().nullable()();
}

/// v3: suggested expressions from feedback.
@DataClassName('ExpressionRow')
class Expressions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get phrase => text()();
  TextColumn get meaningKo => text().nullable()();
  IntColumn get sourceSessionId =>
      integer().references(Sessions, #id, onDelete: KeyAction.cascade)();
}

/// v3: spaced "say it again" review of corrections (spec §12.3).
@DataClassName('ReviewRow')
class ReviewQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get correctionId =>
      integer().references(Corrections, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get dueAt => dateTime()();
  IntColumn get intervalDays => integer().withDefault(const Constant(0))();
  IntColumn get repetitions => integer().withDefault(const Constant(0))();
}

/// v3: placement and level assessments.
class Assessments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId => integer().nullable().references(
    Sessions,
    #id,
    onDelete: KeyAction.setNull,
  )();
  TextColumn get rubricJson => text()();
  TextColumn get level => text()();
  DateTimeColumn get assessedAt => dateTime()();
}

/// Plain app preferences (v2). Credentials stay in CredentialVault.
class AppSettings extends Table {
  TextColumn get name => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {name};
}
