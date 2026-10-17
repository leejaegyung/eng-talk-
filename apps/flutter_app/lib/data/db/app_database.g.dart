// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ProfilesTable extends Profiles with TableInfo<$ProfilesTable, Profile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _localeMeta = const VerificationMeta('locale');
  @override
  late final GeneratedColumn<String> locale = GeneratedColumn<String>(
    'locale',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('ko'),
  );
  static const VerificationMeta _targetMinutesMeta = const VerificationMeta(
    'targetMinutes',
  );
  @override
  late final GeneratedColumn<int> targetMinutes = GeneratedColumn<int>(
    'target_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(30),
  );
  static const VerificationMeta _activeLevelMeta = const VerificationMeta(
    'activeLevel',
  );
  @override
  late final GeneratedColumn<String> activeLevel = GeneratedColumn<String>(
    'active_level',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    locale,
    targetMinutes,
    activeLevel,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<Profile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('locale')) {
      context.handle(
        _localeMeta,
        locale.isAcceptableOrUnknown(data['locale']!, _localeMeta),
      );
    }
    if (data.containsKey('target_minutes')) {
      context.handle(
        _targetMinutesMeta,
        targetMinutes.isAcceptableOrUnknown(
          data['target_minutes']!,
          _targetMinutesMeta,
        ),
      );
    }
    if (data.containsKey('active_level')) {
      context.handle(
        _activeLevelMeta,
        activeLevel.isAcceptableOrUnknown(
          data['active_level']!,
          _activeLevelMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Profile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Profile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      locale: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}locale'],
      )!,
      targetMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_minutes'],
      )!,
      activeLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}active_level'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ProfilesTable createAlias(String alias) {
    return $ProfilesTable(attachedDatabase, alias);
  }
}

class Profile extends DataClass implements Insertable<Profile> {
  final int id;
  final String locale;
  final int targetMinutes;
  final String? activeLevel;
  final DateTime createdAt;
  const Profile({
    required this.id,
    required this.locale,
    required this.targetMinutes,
    this.activeLevel,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['locale'] = Variable<String>(locale);
    map['target_minutes'] = Variable<int>(targetMinutes);
    if (!nullToAbsent || activeLevel != null) {
      map['active_level'] = Variable<String>(activeLevel);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ProfilesCompanion toCompanion(bool nullToAbsent) {
    return ProfilesCompanion(
      id: Value(id),
      locale: Value(locale),
      targetMinutes: Value(targetMinutes),
      activeLevel: activeLevel == null && nullToAbsent
          ? const Value.absent()
          : Value(activeLevel),
      createdAt: Value(createdAt),
    );
  }

  factory Profile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Profile(
      id: serializer.fromJson<int>(json['id']),
      locale: serializer.fromJson<String>(json['locale']),
      targetMinutes: serializer.fromJson<int>(json['targetMinutes']),
      activeLevel: serializer.fromJson<String?>(json['activeLevel']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'locale': serializer.toJson<String>(locale),
      'targetMinutes': serializer.toJson<int>(targetMinutes),
      'activeLevel': serializer.toJson<String?>(activeLevel),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Profile copyWith({
    int? id,
    String? locale,
    int? targetMinutes,
    Value<String?> activeLevel = const Value.absent(),
    DateTime? createdAt,
  }) => Profile(
    id: id ?? this.id,
    locale: locale ?? this.locale,
    targetMinutes: targetMinutes ?? this.targetMinutes,
    activeLevel: activeLevel.present ? activeLevel.value : this.activeLevel,
    createdAt: createdAt ?? this.createdAt,
  );
  Profile copyWithCompanion(ProfilesCompanion data) {
    return Profile(
      id: data.id.present ? data.id.value : this.id,
      locale: data.locale.present ? data.locale.value : this.locale,
      targetMinutes: data.targetMinutes.present
          ? data.targetMinutes.value
          : this.targetMinutes,
      activeLevel: data.activeLevel.present
          ? data.activeLevel.value
          : this.activeLevel,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Profile(')
          ..write('id: $id, ')
          ..write('locale: $locale, ')
          ..write('targetMinutes: $targetMinutes, ')
          ..write('activeLevel: $activeLevel, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, locale, targetMinutes, activeLevel, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Profile &&
          other.id == this.id &&
          other.locale == this.locale &&
          other.targetMinutes == this.targetMinutes &&
          other.activeLevel == this.activeLevel &&
          other.createdAt == this.createdAt);
}

class ProfilesCompanion extends UpdateCompanion<Profile> {
  final Value<int> id;
  final Value<String> locale;
  final Value<int> targetMinutes;
  final Value<String?> activeLevel;
  final Value<DateTime> createdAt;
  const ProfilesCompanion({
    this.id = const Value.absent(),
    this.locale = const Value.absent(),
    this.targetMinutes = const Value.absent(),
    this.activeLevel = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ProfilesCompanion.insert({
    this.id = const Value.absent(),
    this.locale = const Value.absent(),
    this.targetMinutes = const Value.absent(),
    this.activeLevel = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  static Insertable<Profile> custom({
    Expression<int>? id,
    Expression<String>? locale,
    Expression<int>? targetMinutes,
    Expression<String>? activeLevel,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (locale != null) 'locale': locale,
      if (targetMinutes != null) 'target_minutes': targetMinutes,
      if (activeLevel != null) 'active_level': activeLevel,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ProfilesCompanion copyWith({
    Value<int>? id,
    Value<String>? locale,
    Value<int>? targetMinutes,
    Value<String?>? activeLevel,
    Value<DateTime>? createdAt,
  }) {
    return ProfilesCompanion(
      id: id ?? this.id,
      locale: locale ?? this.locale,
      targetMinutes: targetMinutes ?? this.targetMinutes,
      activeLevel: activeLevel ?? this.activeLevel,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (locale.present) {
      map['locale'] = Variable<String>(locale.value);
    }
    if (targetMinutes.present) {
      map['target_minutes'] = Variable<int>(targetMinutes.value);
    }
    if (activeLevel.present) {
      map['active_level'] = Variable<String>(activeLevel.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfilesCompanion(')
          ..write('id: $id, ')
          ..write('locale: $locale, ')
          ..write('targetMinutes: $targetMinutes, ')
          ..write('activeLevel: $activeLevel, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ProvidersTable extends Providers
    with TableInfo<$ProvidersTable, Provider> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProvidersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modelIdMeta = const VerificationMeta(
    'modelId',
  );
  @override
  late final GeneratedColumn<String> modelId = GeneratedColumn<String>(
    'model_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _vaultKeyRefMeta = const VerificationMeta(
    'vaultKeyRef',
  );
  @override
  late final GeneratedColumn<String> vaultKeyRef = GeneratedColumn<String>(
    'vault_key_ref',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _settingsJsonMeta = const VerificationMeta(
    'settingsJson',
  );
  @override
  late final GeneratedColumn<String> settingsJson = GeneratedColumn<String>(
    'settings_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    modelId,
    vaultKeyRef,
    settingsJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'providers';
  @override
  VerificationContext validateIntegrity(
    Insertable<Provider> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('model_id')) {
      context.handle(
        _modelIdMeta,
        modelId.isAcceptableOrUnknown(data['model_id']!, _modelIdMeta),
      );
    }
    if (data.containsKey('vault_key_ref')) {
      context.handle(
        _vaultKeyRefMeta,
        vaultKeyRef.isAcceptableOrUnknown(
          data['vault_key_ref']!,
          _vaultKeyRefMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_vaultKeyRefMeta);
    }
    if (data.containsKey('settings_json')) {
      context.handle(
        _settingsJsonMeta,
        settingsJson.isAcceptableOrUnknown(
          data['settings_json']!,
          _settingsJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Provider map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Provider(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      modelId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_id'],
      ),
      vaultKeyRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vault_key_ref'],
      )!,
      settingsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}settings_json'],
      )!,
    );
  }

  @override
  $ProvidersTable createAlias(String alias) {
    return $ProvidersTable(attachedDatabase, alias);
  }
}

class Provider extends DataClass implements Insertable<Provider> {
  final int id;

  /// Adapter kind, e.g. `openai`.
  final String name;

  /// Chosen from the provider's model list at runtime, never hardcoded.
  final String? modelId;
  final String vaultKeyRef;
  final String settingsJson;
  const Provider({
    required this.id,
    required this.name,
    this.modelId,
    required this.vaultKeyRef,
    required this.settingsJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || modelId != null) {
      map['model_id'] = Variable<String>(modelId);
    }
    map['vault_key_ref'] = Variable<String>(vaultKeyRef);
    map['settings_json'] = Variable<String>(settingsJson);
    return map;
  }

  ProvidersCompanion toCompanion(bool nullToAbsent) {
    return ProvidersCompanion(
      id: Value(id),
      name: Value(name),
      modelId: modelId == null && nullToAbsent
          ? const Value.absent()
          : Value(modelId),
      vaultKeyRef: Value(vaultKeyRef),
      settingsJson: Value(settingsJson),
    );
  }

  factory Provider.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Provider(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      modelId: serializer.fromJson<String?>(json['modelId']),
      vaultKeyRef: serializer.fromJson<String>(json['vaultKeyRef']),
      settingsJson: serializer.fromJson<String>(json['settingsJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'modelId': serializer.toJson<String?>(modelId),
      'vaultKeyRef': serializer.toJson<String>(vaultKeyRef),
      'settingsJson': serializer.toJson<String>(settingsJson),
    };
  }

  Provider copyWith({
    int? id,
    String? name,
    Value<String?> modelId = const Value.absent(),
    String? vaultKeyRef,
    String? settingsJson,
  }) => Provider(
    id: id ?? this.id,
    name: name ?? this.name,
    modelId: modelId.present ? modelId.value : this.modelId,
    vaultKeyRef: vaultKeyRef ?? this.vaultKeyRef,
    settingsJson: settingsJson ?? this.settingsJson,
  );
  Provider copyWithCompanion(ProvidersCompanion data) {
    return Provider(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      modelId: data.modelId.present ? data.modelId.value : this.modelId,
      vaultKeyRef: data.vaultKeyRef.present
          ? data.vaultKeyRef.value
          : this.vaultKeyRef,
      settingsJson: data.settingsJson.present
          ? data.settingsJson.value
          : this.settingsJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Provider(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('modelId: $modelId, ')
          ..write('vaultKeyRef: $vaultKeyRef, ')
          ..write('settingsJson: $settingsJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, modelId, vaultKeyRef, settingsJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Provider &&
          other.id == this.id &&
          other.name == this.name &&
          other.modelId == this.modelId &&
          other.vaultKeyRef == this.vaultKeyRef &&
          other.settingsJson == this.settingsJson);
}

class ProvidersCompanion extends UpdateCompanion<Provider> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> modelId;
  final Value<String> vaultKeyRef;
  final Value<String> settingsJson;
  const ProvidersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.modelId = const Value.absent(),
    this.vaultKeyRef = const Value.absent(),
    this.settingsJson = const Value.absent(),
  });
  ProvidersCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.modelId = const Value.absent(),
    required String vaultKeyRef,
    this.settingsJson = const Value.absent(),
  }) : name = Value(name),
       vaultKeyRef = Value(vaultKeyRef);
  static Insertable<Provider> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? modelId,
    Expression<String>? vaultKeyRef,
    Expression<String>? settingsJson,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (modelId != null) 'model_id': modelId,
      if (vaultKeyRef != null) 'vault_key_ref': vaultKeyRef,
      if (settingsJson != null) 'settings_json': settingsJson,
    });
  }

  ProvidersCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? modelId,
    Value<String>? vaultKeyRef,
    Value<String>? settingsJson,
  }) {
    return ProvidersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      modelId: modelId ?? this.modelId,
      vaultKeyRef: vaultKeyRef ?? this.vaultKeyRef,
      settingsJson: settingsJson ?? this.settingsJson,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (modelId.present) {
      map['model_id'] = Variable<String>(modelId.value);
    }
    if (vaultKeyRef.present) {
      map['vault_key_ref'] = Variable<String>(vaultKeyRef.value);
    }
    if (settingsJson.present) {
      map['settings_json'] = Variable<String>(settingsJson.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProvidersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('modelId: $modelId, ')
          ..write('vaultKeyRef: $vaultKeyRef, ')
          ..write('settingsJson: $settingsJson')
          ..write(')'))
        .toString();
  }
}

class $SessionsTable extends Sessions with TableInfo<$SessionsTable, Session> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<SessionMode, String> mode =
      GeneratedColumn<String>(
        'mode',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<SessionMode>($SessionsTable.$convertermode);
  static const VerificationMeta _topicMeta = const VerificationMeta('topic');
  @override
  late final GeneratedColumn<String> topic = GeneratedColumn<String>(
    'topic',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<String> level = GeneratedColumn<String>(
    'level',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _goalMeta = const VerificationMeta('goal');
  @override
  late final GeneratedColumn<String> goal = GeneratedColumn<String>(
    'goal',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lengthMinutesMeta = const VerificationMeta(
    'lengthMinutes',
  );
  @override
  late final GeneratedColumn<int> lengthMinutes = GeneratedColumn<int>(
    'length_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(30),
  );
  static const VerificationMeta _feedbackJsonMeta = const VerificationMeta(
    'feedbackJson',
  );
  @override
  late final GeneratedColumn<String> feedbackJson = GeneratedColumn<String>(
    'feedback_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SessionStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<SessionStatus>($SessionsTable.$converterstatus);
  static const VerificationMeta _providerIdMeta = const VerificationMeta(
    'providerId',
  );
  @override
  late final GeneratedColumn<int> providerId = GeneratedColumn<int>(
    'provider_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES providers (id) ON DELETE SET NULL',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    mode,
    topic,
    level,
    goal,
    role,
    lengthMinutes,
    feedbackJson,
    startedAt,
    endedAt,
    status,
    providerId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Session> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('topic')) {
      context.handle(
        _topicMeta,
        topic.isAcceptableOrUnknown(data['topic']!, _topicMeta),
      );
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    }
    if (data.containsKey('goal')) {
      context.handle(
        _goalMeta,
        goal.isAcceptableOrUnknown(data['goal']!, _goalMeta),
      );
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    }
    if (data.containsKey('length_minutes')) {
      context.handle(
        _lengthMinutesMeta,
        lengthMinutes.isAcceptableOrUnknown(
          data['length_minutes']!,
          _lengthMinutesMeta,
        ),
      );
    }
    if (data.containsKey('feedback_json')) {
      context.handle(
        _feedbackJsonMeta,
        feedbackJson.isAcceptableOrUnknown(
          data['feedback_json']!,
          _feedbackJsonMeta,
        ),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    if (data.containsKey('provider_id')) {
      context.handle(
        _providerIdMeta,
        providerId.isAcceptableOrUnknown(data['provider_id']!, _providerIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Session map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Session(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      mode: $SessionsTable.$convertermode.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}mode'],
        )!,
      ),
      topic: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}topic'],
      ),
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}level'],
      ),
      goal: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}goal'],
      ),
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      ),
      lengthMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}length_minutes'],
      )!,
      feedbackJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}feedback_json'],
      ),
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      ),
      status: $SessionsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      providerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}provider_id'],
      ),
    );
  }

  @override
  $SessionsTable createAlias(String alias) {
    return $SessionsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SessionMode, String, String> $convertermode =
      const EnumNameConverter<SessionMode>(SessionMode.values);
  static JsonTypeConverter2<SessionStatus, String, String> $converterstatus =
      const EnumNameConverter<SessionStatus>(SessionStatus.values);
}

class Session extends DataClass implements Insertable<Session> {
  final int id;
  final SessionMode mode;
  final String? topic;
  final String? level;

  /// v3: rest of the setup and the validated feedback (spec §8.4 JSON).
  final String? goal;
  final String? role;
  final int lengthMinutes;
  final String? feedbackJson;
  final DateTime startedAt;
  final DateTime? endedAt;
  final SessionStatus status;
  final int? providerId;
  const Session({
    required this.id,
    required this.mode,
    this.topic,
    this.level,
    this.goal,
    this.role,
    required this.lengthMinutes,
    this.feedbackJson,
    required this.startedAt,
    this.endedAt,
    required this.status,
    this.providerId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      map['mode'] = Variable<String>($SessionsTable.$convertermode.toSql(mode));
    }
    if (!nullToAbsent || topic != null) {
      map['topic'] = Variable<String>(topic);
    }
    if (!nullToAbsent || level != null) {
      map['level'] = Variable<String>(level);
    }
    if (!nullToAbsent || goal != null) {
      map['goal'] = Variable<String>(goal);
    }
    if (!nullToAbsent || role != null) {
      map['role'] = Variable<String>(role);
    }
    map['length_minutes'] = Variable<int>(lengthMinutes);
    if (!nullToAbsent || feedbackJson != null) {
      map['feedback_json'] = Variable<String>(feedbackJson);
    }
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    {
      map['status'] = Variable<String>(
        $SessionsTable.$converterstatus.toSql(status),
      );
    }
    if (!nullToAbsent || providerId != null) {
      map['provider_id'] = Variable<int>(providerId);
    }
    return map;
  }

  SessionsCompanion toCompanion(bool nullToAbsent) {
    return SessionsCompanion(
      id: Value(id),
      mode: Value(mode),
      topic: topic == null && nullToAbsent
          ? const Value.absent()
          : Value(topic),
      level: level == null && nullToAbsent
          ? const Value.absent()
          : Value(level),
      goal: goal == null && nullToAbsent ? const Value.absent() : Value(goal),
      role: role == null && nullToAbsent ? const Value.absent() : Value(role),
      lengthMinutes: Value(lengthMinutes),
      feedbackJson: feedbackJson == null && nullToAbsent
          ? const Value.absent()
          : Value(feedbackJson),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      status: Value(status),
      providerId: providerId == null && nullToAbsent
          ? const Value.absent()
          : Value(providerId),
    );
  }

  factory Session.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Session(
      id: serializer.fromJson<int>(json['id']),
      mode: $SessionsTable.$convertermode.fromJson(
        serializer.fromJson<String>(json['mode']),
      ),
      topic: serializer.fromJson<String?>(json['topic']),
      level: serializer.fromJson<String?>(json['level']),
      goal: serializer.fromJson<String?>(json['goal']),
      role: serializer.fromJson<String?>(json['role']),
      lengthMinutes: serializer.fromJson<int>(json['lengthMinutes']),
      feedbackJson: serializer.fromJson<String?>(json['feedbackJson']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      status: $SessionsTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      providerId: serializer.fromJson<int?>(json['providerId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'mode': serializer.toJson<String>(
        $SessionsTable.$convertermode.toJson(mode),
      ),
      'topic': serializer.toJson<String?>(topic),
      'level': serializer.toJson<String?>(level),
      'goal': serializer.toJson<String?>(goal),
      'role': serializer.toJson<String?>(role),
      'lengthMinutes': serializer.toJson<int>(lengthMinutes),
      'feedbackJson': serializer.toJson<String?>(feedbackJson),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'status': serializer.toJson<String>(
        $SessionsTable.$converterstatus.toJson(status),
      ),
      'providerId': serializer.toJson<int?>(providerId),
    };
  }

  Session copyWith({
    int? id,
    SessionMode? mode,
    Value<String?> topic = const Value.absent(),
    Value<String?> level = const Value.absent(),
    Value<String?> goal = const Value.absent(),
    Value<String?> role = const Value.absent(),
    int? lengthMinutes,
    Value<String?> feedbackJson = const Value.absent(),
    DateTime? startedAt,
    Value<DateTime?> endedAt = const Value.absent(),
    SessionStatus? status,
    Value<int?> providerId = const Value.absent(),
  }) => Session(
    id: id ?? this.id,
    mode: mode ?? this.mode,
    topic: topic.present ? topic.value : this.topic,
    level: level.present ? level.value : this.level,
    goal: goal.present ? goal.value : this.goal,
    role: role.present ? role.value : this.role,
    lengthMinutes: lengthMinutes ?? this.lengthMinutes,
    feedbackJson: feedbackJson.present ? feedbackJson.value : this.feedbackJson,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    status: status ?? this.status,
    providerId: providerId.present ? providerId.value : this.providerId,
  );
  Session copyWithCompanion(SessionsCompanion data) {
    return Session(
      id: data.id.present ? data.id.value : this.id,
      mode: data.mode.present ? data.mode.value : this.mode,
      topic: data.topic.present ? data.topic.value : this.topic,
      level: data.level.present ? data.level.value : this.level,
      goal: data.goal.present ? data.goal.value : this.goal,
      role: data.role.present ? data.role.value : this.role,
      lengthMinutes: data.lengthMinutes.present
          ? data.lengthMinutes.value
          : this.lengthMinutes,
      feedbackJson: data.feedbackJson.present
          ? data.feedbackJson.value
          : this.feedbackJson,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      status: data.status.present ? data.status.value : this.status,
      providerId: data.providerId.present
          ? data.providerId.value
          : this.providerId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Session(')
          ..write('id: $id, ')
          ..write('mode: $mode, ')
          ..write('topic: $topic, ')
          ..write('level: $level, ')
          ..write('goal: $goal, ')
          ..write('role: $role, ')
          ..write('lengthMinutes: $lengthMinutes, ')
          ..write('feedbackJson: $feedbackJson, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('status: $status, ')
          ..write('providerId: $providerId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    mode,
    topic,
    level,
    goal,
    role,
    lengthMinutes,
    feedbackJson,
    startedAt,
    endedAt,
    status,
    providerId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Session &&
          other.id == this.id &&
          other.mode == this.mode &&
          other.topic == this.topic &&
          other.level == this.level &&
          other.goal == this.goal &&
          other.role == this.role &&
          other.lengthMinutes == this.lengthMinutes &&
          other.feedbackJson == this.feedbackJson &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.status == this.status &&
          other.providerId == this.providerId);
}

class SessionsCompanion extends UpdateCompanion<Session> {
  final Value<int> id;
  final Value<SessionMode> mode;
  final Value<String?> topic;
  final Value<String?> level;
  final Value<String?> goal;
  final Value<String?> role;
  final Value<int> lengthMinutes;
  final Value<String?> feedbackJson;
  final Value<DateTime> startedAt;
  final Value<DateTime?> endedAt;
  final Value<SessionStatus> status;
  final Value<int?> providerId;
  const SessionsCompanion({
    this.id = const Value.absent(),
    this.mode = const Value.absent(),
    this.topic = const Value.absent(),
    this.level = const Value.absent(),
    this.goal = const Value.absent(),
    this.role = const Value.absent(),
    this.lengthMinutes = const Value.absent(),
    this.feedbackJson = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.status = const Value.absent(),
    this.providerId = const Value.absent(),
  });
  SessionsCompanion.insert({
    this.id = const Value.absent(),
    required SessionMode mode,
    this.topic = const Value.absent(),
    this.level = const Value.absent(),
    this.goal = const Value.absent(),
    this.role = const Value.absent(),
    this.lengthMinutes = const Value.absent(),
    this.feedbackJson = const Value.absent(),
    required DateTime startedAt,
    this.endedAt = const Value.absent(),
    required SessionStatus status,
    this.providerId = const Value.absent(),
  }) : mode = Value(mode),
       startedAt = Value(startedAt),
       status = Value(status);
  static Insertable<Session> custom({
    Expression<int>? id,
    Expression<String>? mode,
    Expression<String>? topic,
    Expression<String>? level,
    Expression<String>? goal,
    Expression<String>? role,
    Expression<int>? lengthMinutes,
    Expression<String>? feedbackJson,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<String>? status,
    Expression<int>? providerId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (mode != null) 'mode': mode,
      if (topic != null) 'topic': topic,
      if (level != null) 'level': level,
      if (goal != null) 'goal': goal,
      if (role != null) 'role': role,
      if (lengthMinutes != null) 'length_minutes': lengthMinutes,
      if (feedbackJson != null) 'feedback_json': feedbackJson,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (status != null) 'status': status,
      if (providerId != null) 'provider_id': providerId,
    });
  }

  SessionsCompanion copyWith({
    Value<int>? id,
    Value<SessionMode>? mode,
    Value<String?>? topic,
    Value<String?>? level,
    Value<String?>? goal,
    Value<String?>? role,
    Value<int>? lengthMinutes,
    Value<String?>? feedbackJson,
    Value<DateTime>? startedAt,
    Value<DateTime?>? endedAt,
    Value<SessionStatus>? status,
    Value<int?>? providerId,
  }) {
    return SessionsCompanion(
      id: id ?? this.id,
      mode: mode ?? this.mode,
      topic: topic ?? this.topic,
      level: level ?? this.level,
      goal: goal ?? this.goal,
      role: role ?? this.role,
      lengthMinutes: lengthMinutes ?? this.lengthMinutes,
      feedbackJson: feedbackJson ?? this.feedbackJson,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      status: status ?? this.status,
      providerId: providerId ?? this.providerId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(
        $SessionsTable.$convertermode.toSql(mode.value),
      );
    }
    if (topic.present) {
      map['topic'] = Variable<String>(topic.value);
    }
    if (level.present) {
      map['level'] = Variable<String>(level.value);
    }
    if (goal.present) {
      map['goal'] = Variable<String>(goal.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (lengthMinutes.present) {
      map['length_minutes'] = Variable<int>(lengthMinutes.value);
    }
    if (feedbackJson.present) {
      map['feedback_json'] = Variable<String>(feedbackJson.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $SessionsTable.$converterstatus.toSql(status.value),
      );
    }
    if (providerId.present) {
      map['provider_id'] = Variable<int>(providerId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionsCompanion(')
          ..write('id: $id, ')
          ..write('mode: $mode, ')
          ..write('topic: $topic, ')
          ..write('level: $level, ')
          ..write('goal: $goal, ')
          ..write('role: $role, ')
          ..write('lengthMinutes: $lengthMinutes, ')
          ..write('feedbackJson: $feedbackJson, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('status: $status, ')
          ..write('providerId: $providerId')
          ..write(')'))
        .toString();
  }
}

class $TurnsTable extends Turns with TableInfo<$TurnsTable, Turn> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TurnsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sessions (id) ON DELETE CASCADE',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<Speaker, String> speaker =
      GeneratedColumn<String>(
        'speaker',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Speaker>($TurnsTable.$converterspeaker);
  static const VerificationMeta _transcriptMeta = const VerificationMeta(
    'transcript',
  );
  @override
  late final GeneratedColumn<String> transcript = GeneratedColumn<String>(
    'transcript',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _wordCountMeta = const VerificationMeta(
    'wordCount',
  );
  @override
  late final GeneratedColumn<int> wordCount = GeneratedColumn<int>(
    'word_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isRequestMeta = const VerificationMeta(
    'isRequest',
  );
  @override
  late final GeneratedColumn<bool> isRequest = GeneratedColumn<bool>(
    'is_request',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_request" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _speechMsMeta = const VerificationMeta(
    'speechMs',
  );
  @override
  late final GeneratedColumn<int> speechMs = GeneratedColumn<int>(
    'speech_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    speaker,
    transcript,
    startedAt,
    endedAt,
    wordCount,
    isRequest,
    speechMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'turns';
  @override
  VerificationContext validateIntegrity(
    Insertable<Turn> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('transcript')) {
      context.handle(
        _transcriptMeta,
        transcript.isAcceptableOrUnknown(data['transcript']!, _transcriptMeta),
      );
    } else if (isInserting) {
      context.missing(_transcriptMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    if (data.containsKey('word_count')) {
      context.handle(
        _wordCountMeta,
        wordCount.isAcceptableOrUnknown(data['word_count']!, _wordCountMeta),
      );
    }
    if (data.containsKey('is_request')) {
      context.handle(
        _isRequestMeta,
        isRequest.isAcceptableOrUnknown(data['is_request']!, _isRequestMeta),
      );
    }
    if (data.containsKey('speech_ms')) {
      context.handle(
        _speechMsMeta,
        speechMs.isAcceptableOrUnknown(data['speech_ms']!, _speechMsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Turn map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Turn(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      )!,
      speaker: $TurnsTable.$converterspeaker.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}speaker'],
        )!,
      ),
      transcript: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transcript'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      ),
      wordCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}word_count'],
      )!,
      isRequest: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_request'],
      )!,
      speechMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}speech_ms'],
      ),
    );
  }

  @override
  $TurnsTable createAlias(String alias) {
    return $TurnsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Speaker, String, String> $converterspeaker =
      const EnumNameConverter<Speaker>(Speaker.values);
}

class Turn extends DataClass implements Insertable<Turn> {
  final int id;
  final int sessionId;
  final Speaker speaker;
  final String transcript;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int wordCount;

  /// v3: quick-action line rather than the learner's own answer.
  final bool isRequest;

  /// v3: estimated speaking time; null when not measured.
  final int? speechMs;
  const Turn({
    required this.id,
    required this.sessionId,
    required this.speaker,
    required this.transcript,
    required this.startedAt,
    this.endedAt,
    required this.wordCount,
    required this.isRequest,
    this.speechMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<int>(sessionId);
    {
      map['speaker'] = Variable<String>(
        $TurnsTable.$converterspeaker.toSql(speaker),
      );
    }
    map['transcript'] = Variable<String>(transcript);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    map['word_count'] = Variable<int>(wordCount);
    map['is_request'] = Variable<bool>(isRequest);
    if (!nullToAbsent || speechMs != null) {
      map['speech_ms'] = Variable<int>(speechMs);
    }
    return map;
  }

  TurnsCompanion toCompanion(bool nullToAbsent) {
    return TurnsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      speaker: Value(speaker),
      transcript: Value(transcript),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      wordCount: Value(wordCount),
      isRequest: Value(isRequest),
      speechMs: speechMs == null && nullToAbsent
          ? const Value.absent()
          : Value(speechMs),
    );
  }

  factory Turn.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Turn(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
      speaker: $TurnsTable.$converterspeaker.fromJson(
        serializer.fromJson<String>(json['speaker']),
      ),
      transcript: serializer.fromJson<String>(json['transcript']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      wordCount: serializer.fromJson<int>(json['wordCount']),
      isRequest: serializer.fromJson<bool>(json['isRequest']),
      speechMs: serializer.fromJson<int?>(json['speechMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<int>(sessionId),
      'speaker': serializer.toJson<String>(
        $TurnsTable.$converterspeaker.toJson(speaker),
      ),
      'transcript': serializer.toJson<String>(transcript),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'wordCount': serializer.toJson<int>(wordCount),
      'isRequest': serializer.toJson<bool>(isRequest),
      'speechMs': serializer.toJson<int?>(speechMs),
    };
  }

  Turn copyWith({
    int? id,
    int? sessionId,
    Speaker? speaker,
    String? transcript,
    DateTime? startedAt,
    Value<DateTime?> endedAt = const Value.absent(),
    int? wordCount,
    bool? isRequest,
    Value<int?> speechMs = const Value.absent(),
  }) => Turn(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    speaker: speaker ?? this.speaker,
    transcript: transcript ?? this.transcript,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    wordCount: wordCount ?? this.wordCount,
    isRequest: isRequest ?? this.isRequest,
    speechMs: speechMs.present ? speechMs.value : this.speechMs,
  );
  Turn copyWithCompanion(TurnsCompanion data) {
    return Turn(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      speaker: data.speaker.present ? data.speaker.value : this.speaker,
      transcript: data.transcript.present
          ? data.transcript.value
          : this.transcript,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      wordCount: data.wordCount.present ? data.wordCount.value : this.wordCount,
      isRequest: data.isRequest.present ? data.isRequest.value : this.isRequest,
      speechMs: data.speechMs.present ? data.speechMs.value : this.speechMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Turn(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('speaker: $speaker, ')
          ..write('transcript: $transcript, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('wordCount: $wordCount, ')
          ..write('isRequest: $isRequest, ')
          ..write('speechMs: $speechMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    speaker,
    transcript,
    startedAt,
    endedAt,
    wordCount,
    isRequest,
    speechMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Turn &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.speaker == this.speaker &&
          other.transcript == this.transcript &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.wordCount == this.wordCount &&
          other.isRequest == this.isRequest &&
          other.speechMs == this.speechMs);
}

class TurnsCompanion extends UpdateCompanion<Turn> {
  final Value<int> id;
  final Value<int> sessionId;
  final Value<Speaker> speaker;
  final Value<String> transcript;
  final Value<DateTime> startedAt;
  final Value<DateTime?> endedAt;
  final Value<int> wordCount;
  final Value<bool> isRequest;
  final Value<int?> speechMs;
  const TurnsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.speaker = const Value.absent(),
    this.transcript = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.wordCount = const Value.absent(),
    this.isRequest = const Value.absent(),
    this.speechMs = const Value.absent(),
  });
  TurnsCompanion.insert({
    this.id = const Value.absent(),
    required int sessionId,
    required Speaker speaker,
    required String transcript,
    required DateTime startedAt,
    this.endedAt = const Value.absent(),
    this.wordCount = const Value.absent(),
    this.isRequest = const Value.absent(),
    this.speechMs = const Value.absent(),
  }) : sessionId = Value(sessionId),
       speaker = Value(speaker),
       transcript = Value(transcript),
       startedAt = Value(startedAt);
  static Insertable<Turn> custom({
    Expression<int>? id,
    Expression<int>? sessionId,
    Expression<String>? speaker,
    Expression<String>? transcript,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<int>? wordCount,
    Expression<bool>? isRequest,
    Expression<int>? speechMs,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (speaker != null) 'speaker': speaker,
      if (transcript != null) 'transcript': transcript,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (wordCount != null) 'word_count': wordCount,
      if (isRequest != null) 'is_request': isRequest,
      if (speechMs != null) 'speech_ms': speechMs,
    });
  }

  TurnsCompanion copyWith({
    Value<int>? id,
    Value<int>? sessionId,
    Value<Speaker>? speaker,
    Value<String>? transcript,
    Value<DateTime>? startedAt,
    Value<DateTime?>? endedAt,
    Value<int>? wordCount,
    Value<bool>? isRequest,
    Value<int?>? speechMs,
  }) {
    return TurnsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      speaker: speaker ?? this.speaker,
      transcript: transcript ?? this.transcript,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      wordCount: wordCount ?? this.wordCount,
      isRequest: isRequest ?? this.isRequest,
      speechMs: speechMs ?? this.speechMs,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (speaker.present) {
      map['speaker'] = Variable<String>(
        $TurnsTable.$converterspeaker.toSql(speaker.value),
      );
    }
    if (transcript.present) {
      map['transcript'] = Variable<String>(transcript.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (wordCount.present) {
      map['word_count'] = Variable<int>(wordCount.value);
    }
    if (isRequest.present) {
      map['is_request'] = Variable<bool>(isRequest.value);
    }
    if (speechMs.present) {
      map['speech_ms'] = Variable<int>(speechMs.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TurnsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('speaker: $speaker, ')
          ..write('transcript: $transcript, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('wordCount: $wordCount, ')
          ..write('isRequest: $isRequest, ')
          ..write('speechMs: $speechMs')
          ..write(')'))
        .toString();
  }
}

class $SpeechMetricsTable extends SpeechMetrics
    with TableInfo<$SpeechMetricsTable, SpeechMetric> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SpeechMetricsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sessions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _userMsMeta = const VerificationMeta('userMs');
  @override
  late final GeneratedColumn<int> userMs = GeneratedColumn<int>(
    'user_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _assistantMsMeta = const VerificationMeta(
    'assistantMs',
  );
  @override
  late final GeneratedColumn<int> assistantMs = GeneratedColumn<int>(
    'assistant_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _turnCountMeta = const VerificationMeta(
    'turnCount',
  );
  @override
  late final GeneratedColumn<int> turnCount = GeneratedColumn<int>(
    'turn_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
    'confidence',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    sessionId,
    userMs,
    assistantMs,
    turnCount,
    confidence,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'speech_metrics';
  @override
  VerificationContext validateIntegrity(
    Insertable<SpeechMetric> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    }
    if (data.containsKey('user_ms')) {
      context.handle(
        _userMsMeta,
        userMs.isAcceptableOrUnknown(data['user_ms']!, _userMsMeta),
      );
    }
    if (data.containsKey('assistant_ms')) {
      context.handle(
        _assistantMsMeta,
        assistantMs.isAcceptableOrUnknown(
          data['assistant_ms']!,
          _assistantMsMeta,
        ),
      );
    }
    if (data.containsKey('turn_count')) {
      context.handle(
        _turnCountMeta,
        turnCount.isAcceptableOrUnknown(data['turn_count']!, _turnCountMeta),
      );
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sessionId};
  @override
  SpeechMetric map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SpeechMetric(
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      )!,
      userMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_ms'],
      )!,
      assistantMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}assistant_ms'],
      )!,
      turnCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}turn_count'],
      )!,
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence'],
      ),
    );
  }

  @override
  $SpeechMetricsTable createAlias(String alias) {
    return $SpeechMetricsTable(attachedDatabase, alias);
  }
}

class SpeechMetric extends DataClass implements Insertable<SpeechMetric> {
  final int sessionId;
  final int userMs;
  final int assistantMs;
  final int turnCount;

  /// Null when not measured — never fill in a guess (spec §11, S7).
  final double? confidence;
  const SpeechMetric({
    required this.sessionId,
    required this.userMs,
    required this.assistantMs,
    required this.turnCount,
    this.confidence,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['session_id'] = Variable<int>(sessionId);
    map['user_ms'] = Variable<int>(userMs);
    map['assistant_ms'] = Variable<int>(assistantMs);
    map['turn_count'] = Variable<int>(turnCount);
    if (!nullToAbsent || confidence != null) {
      map['confidence'] = Variable<double>(confidence);
    }
    return map;
  }

  SpeechMetricsCompanion toCompanion(bool nullToAbsent) {
    return SpeechMetricsCompanion(
      sessionId: Value(sessionId),
      userMs: Value(userMs),
      assistantMs: Value(assistantMs),
      turnCount: Value(turnCount),
      confidence: confidence == null && nullToAbsent
          ? const Value.absent()
          : Value(confidence),
    );
  }

  factory SpeechMetric.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SpeechMetric(
      sessionId: serializer.fromJson<int>(json['sessionId']),
      userMs: serializer.fromJson<int>(json['userMs']),
      assistantMs: serializer.fromJson<int>(json['assistantMs']),
      turnCount: serializer.fromJson<int>(json['turnCount']),
      confidence: serializer.fromJson<double?>(json['confidence']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sessionId': serializer.toJson<int>(sessionId),
      'userMs': serializer.toJson<int>(userMs),
      'assistantMs': serializer.toJson<int>(assistantMs),
      'turnCount': serializer.toJson<int>(turnCount),
      'confidence': serializer.toJson<double?>(confidence),
    };
  }

  SpeechMetric copyWith({
    int? sessionId,
    int? userMs,
    int? assistantMs,
    int? turnCount,
    Value<double?> confidence = const Value.absent(),
  }) => SpeechMetric(
    sessionId: sessionId ?? this.sessionId,
    userMs: userMs ?? this.userMs,
    assistantMs: assistantMs ?? this.assistantMs,
    turnCount: turnCount ?? this.turnCount,
    confidence: confidence.present ? confidence.value : this.confidence,
  );
  SpeechMetric copyWithCompanion(SpeechMetricsCompanion data) {
    return SpeechMetric(
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      userMs: data.userMs.present ? data.userMs.value : this.userMs,
      assistantMs: data.assistantMs.present
          ? data.assistantMs.value
          : this.assistantMs,
      turnCount: data.turnCount.present ? data.turnCount.value : this.turnCount,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SpeechMetric(')
          ..write('sessionId: $sessionId, ')
          ..write('userMs: $userMs, ')
          ..write('assistantMs: $assistantMs, ')
          ..write('turnCount: $turnCount, ')
          ..write('confidence: $confidence')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(sessionId, userMs, assistantMs, turnCount, confidence);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SpeechMetric &&
          other.sessionId == this.sessionId &&
          other.userMs == this.userMs &&
          other.assistantMs == this.assistantMs &&
          other.turnCount == this.turnCount &&
          other.confidence == this.confidence);
}

class SpeechMetricsCompanion extends UpdateCompanion<SpeechMetric> {
  final Value<int> sessionId;
  final Value<int> userMs;
  final Value<int> assistantMs;
  final Value<int> turnCount;
  final Value<double?> confidence;
  const SpeechMetricsCompanion({
    this.sessionId = const Value.absent(),
    this.userMs = const Value.absent(),
    this.assistantMs = const Value.absent(),
    this.turnCount = const Value.absent(),
    this.confidence = const Value.absent(),
  });
  SpeechMetricsCompanion.insert({
    this.sessionId = const Value.absent(),
    this.userMs = const Value.absent(),
    this.assistantMs = const Value.absent(),
    this.turnCount = const Value.absent(),
    this.confidence = const Value.absent(),
  });
  static Insertable<SpeechMetric> custom({
    Expression<int>? sessionId,
    Expression<int>? userMs,
    Expression<int>? assistantMs,
    Expression<int>? turnCount,
    Expression<double>? confidence,
  }) {
    return RawValuesInsertable({
      if (sessionId != null) 'session_id': sessionId,
      if (userMs != null) 'user_ms': userMs,
      if (assistantMs != null) 'assistant_ms': assistantMs,
      if (turnCount != null) 'turn_count': turnCount,
      if (confidence != null) 'confidence': confidence,
    });
  }

  SpeechMetricsCompanion copyWith({
    Value<int>? sessionId,
    Value<int>? userMs,
    Value<int>? assistantMs,
    Value<int>? turnCount,
    Value<double?>? confidence,
  }) {
    return SpeechMetricsCompanion(
      sessionId: sessionId ?? this.sessionId,
      userMs: userMs ?? this.userMs,
      assistantMs: assistantMs ?? this.assistantMs,
      turnCount: turnCount ?? this.turnCount,
      confidence: confidence ?? this.confidence,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (userMs.present) {
      map['user_ms'] = Variable<int>(userMs.value);
    }
    if (assistantMs.present) {
      map['assistant_ms'] = Variable<int>(assistantMs.value);
    }
    if (turnCount.present) {
      map['turn_count'] = Variable<int>(turnCount.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SpeechMetricsCompanion(')
          ..write('sessionId: $sessionId, ')
          ..write('userMs: $userMs, ')
          ..write('assistantMs: $assistantMs, ')
          ..write('turnCount: $turnCount, ')
          ..write('confidence: $confidence')
          ..write(')'))
        .toString();
  }
}

class $CorrectionsTable extends Corrections
    with TableInfo<$CorrectionsTable, Correction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CorrectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sessions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _turnIdMeta = const VerificationMeta('turnId');
  @override
  late final GeneratedColumn<int> turnId = GeneratedColumn<int>(
    'turn_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES turns (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _originalMeta = const VerificationMeta(
    'original',
  );
  @override
  late final GeneratedColumn<String> original = GeneratedColumn<String>(
    'original',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _suggestedMeta = const VerificationMeta(
    'suggested',
  );
  @override
  late final GeneratedColumn<String> suggested = GeneratedColumn<String>(
    'suggested',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _explanationMeta = const VerificationMeta(
    'explanation',
  );
  @override
  late final GeneratedColumn<String> explanation = GeneratedColumn<String>(
    'explanation',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _practicedMeta = const VerificationMeta(
    'practiced',
  );
  @override
  late final GeneratedColumn<bool> practiced = GeneratedColumn<bool>(
    'practiced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("practiced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _severityMeta = const VerificationMeta(
    'severity',
  );
  @override
  late final GeneratedColumn<String> severity = GeneratedColumn<String>(
    'severity',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _practicePromptMeta = const VerificationMeta(
    'practicePrompt',
  );
  @override
  late final GeneratedColumn<String> practicePrompt = GeneratedColumn<String>(
    'practice_prompt',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    turnId,
    original,
    suggested,
    explanation,
    practiced,
    severity,
    practicePrompt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'corrections';
  @override
  VerificationContext validateIntegrity(
    Insertable<Correction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('turn_id')) {
      context.handle(
        _turnIdMeta,
        turnId.isAcceptableOrUnknown(data['turn_id']!, _turnIdMeta),
      );
    } else if (isInserting) {
      context.missing(_turnIdMeta);
    }
    if (data.containsKey('original')) {
      context.handle(
        _originalMeta,
        original.isAcceptableOrUnknown(data['original']!, _originalMeta),
      );
    } else if (isInserting) {
      context.missing(_originalMeta);
    }
    if (data.containsKey('suggested')) {
      context.handle(
        _suggestedMeta,
        suggested.isAcceptableOrUnknown(data['suggested']!, _suggestedMeta),
      );
    } else if (isInserting) {
      context.missing(_suggestedMeta);
    }
    if (data.containsKey('explanation')) {
      context.handle(
        _explanationMeta,
        explanation.isAcceptableOrUnknown(
          data['explanation']!,
          _explanationMeta,
        ),
      );
    }
    if (data.containsKey('practiced')) {
      context.handle(
        _practicedMeta,
        practiced.isAcceptableOrUnknown(data['practiced']!, _practicedMeta),
      );
    }
    if (data.containsKey('severity')) {
      context.handle(
        _severityMeta,
        severity.isAcceptableOrUnknown(data['severity']!, _severityMeta),
      );
    }
    if (data.containsKey('practice_prompt')) {
      context.handle(
        _practicePromptMeta,
        practicePrompt.isAcceptableOrUnknown(
          data['practice_prompt']!,
          _practicePromptMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Correction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Correction(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      )!,
      turnId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}turn_id'],
      )!,
      original: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original'],
      )!,
      suggested: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}suggested'],
      )!,
      explanation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}explanation'],
      ),
      practiced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}practiced'],
      )!,
      severity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}severity'],
      ),
      practicePrompt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}practice_prompt'],
      ),
    );
  }

  @override
  $CorrectionsTable createAlias(String alias) {
    return $CorrectionsTable(attachedDatabase, alias);
  }
}

class Correction extends DataClass implements Insertable<Correction> {
  final int id;
  final int sessionId;
  final int turnId;
  final String original;
  final String suggested;
  final String? explanation;
  final bool practiced;

  /// v3
  final String? severity;
  final String? practicePrompt;
  const Correction({
    required this.id,
    required this.sessionId,
    required this.turnId,
    required this.original,
    required this.suggested,
    this.explanation,
    required this.practiced,
    this.severity,
    this.practicePrompt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<int>(sessionId);
    map['turn_id'] = Variable<int>(turnId);
    map['original'] = Variable<String>(original);
    map['suggested'] = Variable<String>(suggested);
    if (!nullToAbsent || explanation != null) {
      map['explanation'] = Variable<String>(explanation);
    }
    map['practiced'] = Variable<bool>(practiced);
    if (!nullToAbsent || severity != null) {
      map['severity'] = Variable<String>(severity);
    }
    if (!nullToAbsent || practicePrompt != null) {
      map['practice_prompt'] = Variable<String>(practicePrompt);
    }
    return map;
  }

  CorrectionsCompanion toCompanion(bool nullToAbsent) {
    return CorrectionsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      turnId: Value(turnId),
      original: Value(original),
      suggested: Value(suggested),
      explanation: explanation == null && nullToAbsent
          ? const Value.absent()
          : Value(explanation),
      practiced: Value(practiced),
      severity: severity == null && nullToAbsent
          ? const Value.absent()
          : Value(severity),
      practicePrompt: practicePrompt == null && nullToAbsent
          ? const Value.absent()
          : Value(practicePrompt),
    );
  }

  factory Correction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Correction(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
      turnId: serializer.fromJson<int>(json['turnId']),
      original: serializer.fromJson<String>(json['original']),
      suggested: serializer.fromJson<String>(json['suggested']),
      explanation: serializer.fromJson<String?>(json['explanation']),
      practiced: serializer.fromJson<bool>(json['practiced']),
      severity: serializer.fromJson<String?>(json['severity']),
      practicePrompt: serializer.fromJson<String?>(json['practicePrompt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<int>(sessionId),
      'turnId': serializer.toJson<int>(turnId),
      'original': serializer.toJson<String>(original),
      'suggested': serializer.toJson<String>(suggested),
      'explanation': serializer.toJson<String?>(explanation),
      'practiced': serializer.toJson<bool>(practiced),
      'severity': serializer.toJson<String?>(severity),
      'practicePrompt': serializer.toJson<String?>(practicePrompt),
    };
  }

  Correction copyWith({
    int? id,
    int? sessionId,
    int? turnId,
    String? original,
    String? suggested,
    Value<String?> explanation = const Value.absent(),
    bool? practiced,
    Value<String?> severity = const Value.absent(),
    Value<String?> practicePrompt = const Value.absent(),
  }) => Correction(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    turnId: turnId ?? this.turnId,
    original: original ?? this.original,
    suggested: suggested ?? this.suggested,
    explanation: explanation.present ? explanation.value : this.explanation,
    practiced: practiced ?? this.practiced,
    severity: severity.present ? severity.value : this.severity,
    practicePrompt: practicePrompt.present
        ? practicePrompt.value
        : this.practicePrompt,
  );
  Correction copyWithCompanion(CorrectionsCompanion data) {
    return Correction(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      turnId: data.turnId.present ? data.turnId.value : this.turnId,
      original: data.original.present ? data.original.value : this.original,
      suggested: data.suggested.present ? data.suggested.value : this.suggested,
      explanation: data.explanation.present
          ? data.explanation.value
          : this.explanation,
      practiced: data.practiced.present ? data.practiced.value : this.practiced,
      severity: data.severity.present ? data.severity.value : this.severity,
      practicePrompt: data.practicePrompt.present
          ? data.practicePrompt.value
          : this.practicePrompt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Correction(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('turnId: $turnId, ')
          ..write('original: $original, ')
          ..write('suggested: $suggested, ')
          ..write('explanation: $explanation, ')
          ..write('practiced: $practiced, ')
          ..write('severity: $severity, ')
          ..write('practicePrompt: $practicePrompt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    turnId,
    original,
    suggested,
    explanation,
    practiced,
    severity,
    practicePrompt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Correction &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.turnId == this.turnId &&
          other.original == this.original &&
          other.suggested == this.suggested &&
          other.explanation == this.explanation &&
          other.practiced == this.practiced &&
          other.severity == this.severity &&
          other.practicePrompt == this.practicePrompt);
}

class CorrectionsCompanion extends UpdateCompanion<Correction> {
  final Value<int> id;
  final Value<int> sessionId;
  final Value<int> turnId;
  final Value<String> original;
  final Value<String> suggested;
  final Value<String?> explanation;
  final Value<bool> practiced;
  final Value<String?> severity;
  final Value<String?> practicePrompt;
  const CorrectionsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.turnId = const Value.absent(),
    this.original = const Value.absent(),
    this.suggested = const Value.absent(),
    this.explanation = const Value.absent(),
    this.practiced = const Value.absent(),
    this.severity = const Value.absent(),
    this.practicePrompt = const Value.absent(),
  });
  CorrectionsCompanion.insert({
    this.id = const Value.absent(),
    required int sessionId,
    required int turnId,
    required String original,
    required String suggested,
    this.explanation = const Value.absent(),
    this.practiced = const Value.absent(),
    this.severity = const Value.absent(),
    this.practicePrompt = const Value.absent(),
  }) : sessionId = Value(sessionId),
       turnId = Value(turnId),
       original = Value(original),
       suggested = Value(suggested);
  static Insertable<Correction> custom({
    Expression<int>? id,
    Expression<int>? sessionId,
    Expression<int>? turnId,
    Expression<String>? original,
    Expression<String>? suggested,
    Expression<String>? explanation,
    Expression<bool>? practiced,
    Expression<String>? severity,
    Expression<String>? practicePrompt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (turnId != null) 'turn_id': turnId,
      if (original != null) 'original': original,
      if (suggested != null) 'suggested': suggested,
      if (explanation != null) 'explanation': explanation,
      if (practiced != null) 'practiced': practiced,
      if (severity != null) 'severity': severity,
      if (practicePrompt != null) 'practice_prompt': practicePrompt,
    });
  }

  CorrectionsCompanion copyWith({
    Value<int>? id,
    Value<int>? sessionId,
    Value<int>? turnId,
    Value<String>? original,
    Value<String>? suggested,
    Value<String?>? explanation,
    Value<bool>? practiced,
    Value<String?>? severity,
    Value<String?>? practicePrompt,
  }) {
    return CorrectionsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      turnId: turnId ?? this.turnId,
      original: original ?? this.original,
      suggested: suggested ?? this.suggested,
      explanation: explanation ?? this.explanation,
      practiced: practiced ?? this.practiced,
      severity: severity ?? this.severity,
      practicePrompt: practicePrompt ?? this.practicePrompt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (turnId.present) {
      map['turn_id'] = Variable<int>(turnId.value);
    }
    if (original.present) {
      map['original'] = Variable<String>(original.value);
    }
    if (suggested.present) {
      map['suggested'] = Variable<String>(suggested.value);
    }
    if (explanation.present) {
      map['explanation'] = Variable<String>(explanation.value);
    }
    if (practiced.present) {
      map['practiced'] = Variable<bool>(practiced.value);
    }
    if (severity.present) {
      map['severity'] = Variable<String>(severity.value);
    }
    if (practicePrompt.present) {
      map['practice_prompt'] = Variable<String>(practicePrompt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CorrectionsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('turnId: $turnId, ')
          ..write('original: $original, ')
          ..write('suggested: $suggested, ')
          ..write('explanation: $explanation, ')
          ..write('practiced: $practiced, ')
          ..write('severity: $severity, ')
          ..write('practicePrompt: $practicePrompt')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [name, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {name};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String name;
  final String value;
  const AppSetting({required this.name, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['name'] = Variable<String>(name);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(name: Value(name), value: Value(value));
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      name: serializer.fromJson<String>(json['name']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'name': serializer.toJson<String>(name),
      'value': serializer.toJson<String>(value),
    };
  }

  AppSetting copyWith({String? name, String? value}) =>
      AppSetting(name: name ?? this.name, value: value ?? this.value);
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      name: data.name.present ? data.name.value : this.name,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('name: $name, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(name, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.name == this.name &&
          other.value == this.value);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> name;
  final Value<String> value;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.name = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String name,
    required String value,
    this.rowid = const Value.absent(),
  }) : name = Value(name),
       value = Value(value);
  static Insertable<AppSetting> custom({
    Expression<String>? name,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (name != null) 'name': name,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? name,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      name: name ?? this.name,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('name: $name, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExpressionsTable extends Expressions
    with TableInfo<$ExpressionsTable, ExpressionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExpressionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _phraseMeta = const VerificationMeta('phrase');
  @override
  late final GeneratedColumn<String> phrase = GeneratedColumn<String>(
    'phrase',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _meaningKoMeta = const VerificationMeta(
    'meaningKo',
  );
  @override
  late final GeneratedColumn<String> meaningKo = GeneratedColumn<String>(
    'meaning_ko',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceSessionIdMeta = const VerificationMeta(
    'sourceSessionId',
  );
  @override
  late final GeneratedColumn<int> sourceSessionId = GeneratedColumn<int>(
    'source_session_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sessions (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    phrase,
    meaningKo,
    sourceSessionId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'expressions';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExpressionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('phrase')) {
      context.handle(
        _phraseMeta,
        phrase.isAcceptableOrUnknown(data['phrase']!, _phraseMeta),
      );
    } else if (isInserting) {
      context.missing(_phraseMeta);
    }
    if (data.containsKey('meaning_ko')) {
      context.handle(
        _meaningKoMeta,
        meaningKo.isAcceptableOrUnknown(data['meaning_ko']!, _meaningKoMeta),
      );
    }
    if (data.containsKey('source_session_id')) {
      context.handle(
        _sourceSessionIdMeta,
        sourceSessionId.isAcceptableOrUnknown(
          data['source_session_id']!,
          _sourceSessionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceSessionIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExpressionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExpressionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      phrase: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phrase'],
      )!,
      meaningKo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meaning_ko'],
      ),
      sourceSessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}source_session_id'],
      )!,
    );
  }

  @override
  $ExpressionsTable createAlias(String alias) {
    return $ExpressionsTable(attachedDatabase, alias);
  }
}

class ExpressionRow extends DataClass implements Insertable<ExpressionRow> {
  final int id;
  final String phrase;
  final String? meaningKo;
  final int sourceSessionId;
  const ExpressionRow({
    required this.id,
    required this.phrase,
    this.meaningKo,
    required this.sourceSessionId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['phrase'] = Variable<String>(phrase);
    if (!nullToAbsent || meaningKo != null) {
      map['meaning_ko'] = Variable<String>(meaningKo);
    }
    map['source_session_id'] = Variable<int>(sourceSessionId);
    return map;
  }

  ExpressionsCompanion toCompanion(bool nullToAbsent) {
    return ExpressionsCompanion(
      id: Value(id),
      phrase: Value(phrase),
      meaningKo: meaningKo == null && nullToAbsent
          ? const Value.absent()
          : Value(meaningKo),
      sourceSessionId: Value(sourceSessionId),
    );
  }

  factory ExpressionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExpressionRow(
      id: serializer.fromJson<int>(json['id']),
      phrase: serializer.fromJson<String>(json['phrase']),
      meaningKo: serializer.fromJson<String?>(json['meaningKo']),
      sourceSessionId: serializer.fromJson<int>(json['sourceSessionId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'phrase': serializer.toJson<String>(phrase),
      'meaningKo': serializer.toJson<String?>(meaningKo),
      'sourceSessionId': serializer.toJson<int>(sourceSessionId),
    };
  }

  ExpressionRow copyWith({
    int? id,
    String? phrase,
    Value<String?> meaningKo = const Value.absent(),
    int? sourceSessionId,
  }) => ExpressionRow(
    id: id ?? this.id,
    phrase: phrase ?? this.phrase,
    meaningKo: meaningKo.present ? meaningKo.value : this.meaningKo,
    sourceSessionId: sourceSessionId ?? this.sourceSessionId,
  );
  ExpressionRow copyWithCompanion(ExpressionsCompanion data) {
    return ExpressionRow(
      id: data.id.present ? data.id.value : this.id,
      phrase: data.phrase.present ? data.phrase.value : this.phrase,
      meaningKo: data.meaningKo.present ? data.meaningKo.value : this.meaningKo,
      sourceSessionId: data.sourceSessionId.present
          ? data.sourceSessionId.value
          : this.sourceSessionId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExpressionRow(')
          ..write('id: $id, ')
          ..write('phrase: $phrase, ')
          ..write('meaningKo: $meaningKo, ')
          ..write('sourceSessionId: $sourceSessionId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, phrase, meaningKo, sourceSessionId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExpressionRow &&
          other.id == this.id &&
          other.phrase == this.phrase &&
          other.meaningKo == this.meaningKo &&
          other.sourceSessionId == this.sourceSessionId);
}

class ExpressionsCompanion extends UpdateCompanion<ExpressionRow> {
  final Value<int> id;
  final Value<String> phrase;
  final Value<String?> meaningKo;
  final Value<int> sourceSessionId;
  const ExpressionsCompanion({
    this.id = const Value.absent(),
    this.phrase = const Value.absent(),
    this.meaningKo = const Value.absent(),
    this.sourceSessionId = const Value.absent(),
  });
  ExpressionsCompanion.insert({
    this.id = const Value.absent(),
    required String phrase,
    this.meaningKo = const Value.absent(),
    required int sourceSessionId,
  }) : phrase = Value(phrase),
       sourceSessionId = Value(sourceSessionId);
  static Insertable<ExpressionRow> custom({
    Expression<int>? id,
    Expression<String>? phrase,
    Expression<String>? meaningKo,
    Expression<int>? sourceSessionId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (phrase != null) 'phrase': phrase,
      if (meaningKo != null) 'meaning_ko': meaningKo,
      if (sourceSessionId != null) 'source_session_id': sourceSessionId,
    });
  }

  ExpressionsCompanion copyWith({
    Value<int>? id,
    Value<String>? phrase,
    Value<String?>? meaningKo,
    Value<int>? sourceSessionId,
  }) {
    return ExpressionsCompanion(
      id: id ?? this.id,
      phrase: phrase ?? this.phrase,
      meaningKo: meaningKo ?? this.meaningKo,
      sourceSessionId: sourceSessionId ?? this.sourceSessionId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (phrase.present) {
      map['phrase'] = Variable<String>(phrase.value);
    }
    if (meaningKo.present) {
      map['meaning_ko'] = Variable<String>(meaningKo.value);
    }
    if (sourceSessionId.present) {
      map['source_session_id'] = Variable<int>(sourceSessionId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExpressionsCompanion(')
          ..write('id: $id, ')
          ..write('phrase: $phrase, ')
          ..write('meaningKo: $meaningKo, ')
          ..write('sourceSessionId: $sourceSessionId')
          ..write(')'))
        .toString();
  }
}

class $ReviewQueueTable extends ReviewQueue
    with TableInfo<$ReviewQueueTable, ReviewRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReviewQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _correctionIdMeta = const VerificationMeta(
    'correctionId',
  );
  @override
  late final GeneratedColumn<int> correctionId = GeneratedColumn<int>(
    'correction_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES corrections (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _dueAtMeta = const VerificationMeta('dueAt');
  @override
  late final GeneratedColumn<DateTime> dueAt = GeneratedColumn<DateTime>(
    'due_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _intervalDaysMeta = const VerificationMeta(
    'intervalDays',
  );
  @override
  late final GeneratedColumn<int> intervalDays = GeneratedColumn<int>(
    'interval_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _repetitionsMeta = const VerificationMeta(
    'repetitions',
  );
  @override
  late final GeneratedColumn<int> repetitions = GeneratedColumn<int>(
    'repetitions',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    correctionId,
    dueAt,
    intervalDays,
    repetitions,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'review_queue';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReviewRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('correction_id')) {
      context.handle(
        _correctionIdMeta,
        correctionId.isAcceptableOrUnknown(
          data['correction_id']!,
          _correctionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_correctionIdMeta);
    }
    if (data.containsKey('due_at')) {
      context.handle(
        _dueAtMeta,
        dueAt.isAcceptableOrUnknown(data['due_at']!, _dueAtMeta),
      );
    } else if (isInserting) {
      context.missing(_dueAtMeta);
    }
    if (data.containsKey('interval_days')) {
      context.handle(
        _intervalDaysMeta,
        intervalDays.isAcceptableOrUnknown(
          data['interval_days']!,
          _intervalDaysMeta,
        ),
      );
    }
    if (data.containsKey('repetitions')) {
      context.handle(
        _repetitionsMeta,
        repetitions.isAcceptableOrUnknown(
          data['repetitions']!,
          _repetitionsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReviewRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReviewRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      correctionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}correction_id'],
      )!,
      dueAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_at'],
      )!,
      intervalDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}interval_days'],
      )!,
      repetitions: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}repetitions'],
      )!,
    );
  }

  @override
  $ReviewQueueTable createAlias(String alias) {
    return $ReviewQueueTable(attachedDatabase, alias);
  }
}

class ReviewRow extends DataClass implements Insertable<ReviewRow> {
  final int id;
  final int correctionId;
  final DateTime dueAt;
  final int intervalDays;
  final int repetitions;
  const ReviewRow({
    required this.id,
    required this.correctionId,
    required this.dueAt,
    required this.intervalDays,
    required this.repetitions,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['correction_id'] = Variable<int>(correctionId);
    map['due_at'] = Variable<DateTime>(dueAt);
    map['interval_days'] = Variable<int>(intervalDays);
    map['repetitions'] = Variable<int>(repetitions);
    return map;
  }

  ReviewQueueCompanion toCompanion(bool nullToAbsent) {
    return ReviewQueueCompanion(
      id: Value(id),
      correctionId: Value(correctionId),
      dueAt: Value(dueAt),
      intervalDays: Value(intervalDays),
      repetitions: Value(repetitions),
    );
  }

  factory ReviewRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReviewRow(
      id: serializer.fromJson<int>(json['id']),
      correctionId: serializer.fromJson<int>(json['correctionId']),
      dueAt: serializer.fromJson<DateTime>(json['dueAt']),
      intervalDays: serializer.fromJson<int>(json['intervalDays']),
      repetitions: serializer.fromJson<int>(json['repetitions']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'correctionId': serializer.toJson<int>(correctionId),
      'dueAt': serializer.toJson<DateTime>(dueAt),
      'intervalDays': serializer.toJson<int>(intervalDays),
      'repetitions': serializer.toJson<int>(repetitions),
    };
  }

  ReviewRow copyWith({
    int? id,
    int? correctionId,
    DateTime? dueAt,
    int? intervalDays,
    int? repetitions,
  }) => ReviewRow(
    id: id ?? this.id,
    correctionId: correctionId ?? this.correctionId,
    dueAt: dueAt ?? this.dueAt,
    intervalDays: intervalDays ?? this.intervalDays,
    repetitions: repetitions ?? this.repetitions,
  );
  ReviewRow copyWithCompanion(ReviewQueueCompanion data) {
    return ReviewRow(
      id: data.id.present ? data.id.value : this.id,
      correctionId: data.correctionId.present
          ? data.correctionId.value
          : this.correctionId,
      dueAt: data.dueAt.present ? data.dueAt.value : this.dueAt,
      intervalDays: data.intervalDays.present
          ? data.intervalDays.value
          : this.intervalDays,
      repetitions: data.repetitions.present
          ? data.repetitions.value
          : this.repetitions,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReviewRow(')
          ..write('id: $id, ')
          ..write('correctionId: $correctionId, ')
          ..write('dueAt: $dueAt, ')
          ..write('intervalDays: $intervalDays, ')
          ..write('repetitions: $repetitions')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, correctionId, dueAt, intervalDays, repetitions);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReviewRow &&
          other.id == this.id &&
          other.correctionId == this.correctionId &&
          other.dueAt == this.dueAt &&
          other.intervalDays == this.intervalDays &&
          other.repetitions == this.repetitions);
}

class ReviewQueueCompanion extends UpdateCompanion<ReviewRow> {
  final Value<int> id;
  final Value<int> correctionId;
  final Value<DateTime> dueAt;
  final Value<int> intervalDays;
  final Value<int> repetitions;
  const ReviewQueueCompanion({
    this.id = const Value.absent(),
    this.correctionId = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.intervalDays = const Value.absent(),
    this.repetitions = const Value.absent(),
  });
  ReviewQueueCompanion.insert({
    this.id = const Value.absent(),
    required int correctionId,
    required DateTime dueAt,
    this.intervalDays = const Value.absent(),
    this.repetitions = const Value.absent(),
  }) : correctionId = Value(correctionId),
       dueAt = Value(dueAt);
  static Insertable<ReviewRow> custom({
    Expression<int>? id,
    Expression<int>? correctionId,
    Expression<DateTime>? dueAt,
    Expression<int>? intervalDays,
    Expression<int>? repetitions,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (correctionId != null) 'correction_id': correctionId,
      if (dueAt != null) 'due_at': dueAt,
      if (intervalDays != null) 'interval_days': intervalDays,
      if (repetitions != null) 'repetitions': repetitions,
    });
  }

  ReviewQueueCompanion copyWith({
    Value<int>? id,
    Value<int>? correctionId,
    Value<DateTime>? dueAt,
    Value<int>? intervalDays,
    Value<int>? repetitions,
  }) {
    return ReviewQueueCompanion(
      id: id ?? this.id,
      correctionId: correctionId ?? this.correctionId,
      dueAt: dueAt ?? this.dueAt,
      intervalDays: intervalDays ?? this.intervalDays,
      repetitions: repetitions ?? this.repetitions,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (correctionId.present) {
      map['correction_id'] = Variable<int>(correctionId.value);
    }
    if (dueAt.present) {
      map['due_at'] = Variable<DateTime>(dueAt.value);
    }
    if (intervalDays.present) {
      map['interval_days'] = Variable<int>(intervalDays.value);
    }
    if (repetitions.present) {
      map['repetitions'] = Variable<int>(repetitions.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReviewQueueCompanion(')
          ..write('id: $id, ')
          ..write('correctionId: $correctionId, ')
          ..write('dueAt: $dueAt, ')
          ..write('intervalDays: $intervalDays, ')
          ..write('repetitions: $repetitions')
          ..write(')'))
        .toString();
  }
}

class $AssessmentsTable extends Assessments
    with TableInfo<$AssessmentsTable, Assessment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AssessmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sessions (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _rubricJsonMeta = const VerificationMeta(
    'rubricJson',
  );
  @override
  late final GeneratedColumn<String> rubricJson = GeneratedColumn<String>(
    'rubric_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<String> level = GeneratedColumn<String>(
    'level',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _assessedAtMeta = const VerificationMeta(
    'assessedAt',
  );
  @override
  late final GeneratedColumn<DateTime> assessedAt = GeneratedColumn<DateTime>(
    'assessed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    rubricJson,
    level,
    assessedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'assessments';
  @override
  VerificationContext validateIntegrity(
    Insertable<Assessment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    }
    if (data.containsKey('rubric_json')) {
      context.handle(
        _rubricJsonMeta,
        rubricJson.isAcceptableOrUnknown(data['rubric_json']!, _rubricJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_rubricJsonMeta);
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    } else if (isInserting) {
      context.missing(_levelMeta);
    }
    if (data.containsKey('assessed_at')) {
      context.handle(
        _assessedAtMeta,
        assessedAt.isAcceptableOrUnknown(data['assessed_at']!, _assessedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_assessedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Assessment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Assessment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      ),
      rubricJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rubric_json'],
      )!,
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}level'],
      )!,
      assessedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}assessed_at'],
      )!,
    );
  }

  @override
  $AssessmentsTable createAlias(String alias) {
    return $AssessmentsTable(attachedDatabase, alias);
  }
}

class Assessment extends DataClass implements Insertable<Assessment> {
  final int id;
  final int? sessionId;
  final String rubricJson;
  final String level;
  final DateTime assessedAt;
  const Assessment({
    required this.id,
    this.sessionId,
    required this.rubricJson,
    required this.level,
    required this.assessedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || sessionId != null) {
      map['session_id'] = Variable<int>(sessionId);
    }
    map['rubric_json'] = Variable<String>(rubricJson);
    map['level'] = Variable<String>(level);
    map['assessed_at'] = Variable<DateTime>(assessedAt);
    return map;
  }

  AssessmentsCompanion toCompanion(bool nullToAbsent) {
    return AssessmentsCompanion(
      id: Value(id),
      sessionId: sessionId == null && nullToAbsent
          ? const Value.absent()
          : Value(sessionId),
      rubricJson: Value(rubricJson),
      level: Value(level),
      assessedAt: Value(assessedAt),
    );
  }

  factory Assessment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Assessment(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<int?>(json['sessionId']),
      rubricJson: serializer.fromJson<String>(json['rubricJson']),
      level: serializer.fromJson<String>(json['level']),
      assessedAt: serializer.fromJson<DateTime>(json['assessedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<int?>(sessionId),
      'rubricJson': serializer.toJson<String>(rubricJson),
      'level': serializer.toJson<String>(level),
      'assessedAt': serializer.toJson<DateTime>(assessedAt),
    };
  }

  Assessment copyWith({
    int? id,
    Value<int?> sessionId = const Value.absent(),
    String? rubricJson,
    String? level,
    DateTime? assessedAt,
  }) => Assessment(
    id: id ?? this.id,
    sessionId: sessionId.present ? sessionId.value : this.sessionId,
    rubricJson: rubricJson ?? this.rubricJson,
    level: level ?? this.level,
    assessedAt: assessedAt ?? this.assessedAt,
  );
  Assessment copyWithCompanion(AssessmentsCompanion data) {
    return Assessment(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      rubricJson: data.rubricJson.present
          ? data.rubricJson.value
          : this.rubricJson,
      level: data.level.present ? data.level.value : this.level,
      assessedAt: data.assessedAt.present
          ? data.assessedAt.value
          : this.assessedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Assessment(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('rubricJson: $rubricJson, ')
          ..write('level: $level, ')
          ..write('assessedAt: $assessedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, sessionId, rubricJson, level, assessedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Assessment &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.rubricJson == this.rubricJson &&
          other.level == this.level &&
          other.assessedAt == this.assessedAt);
}

class AssessmentsCompanion extends UpdateCompanion<Assessment> {
  final Value<int> id;
  final Value<int?> sessionId;
  final Value<String> rubricJson;
  final Value<String> level;
  final Value<DateTime> assessedAt;
  const AssessmentsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.rubricJson = const Value.absent(),
    this.level = const Value.absent(),
    this.assessedAt = const Value.absent(),
  });
  AssessmentsCompanion.insert({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    required String rubricJson,
    required String level,
    required DateTime assessedAt,
  }) : rubricJson = Value(rubricJson),
       level = Value(level),
       assessedAt = Value(assessedAt);
  static Insertable<Assessment> custom({
    Expression<int>? id,
    Expression<int>? sessionId,
    Expression<String>? rubricJson,
    Expression<String>? level,
    Expression<DateTime>? assessedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (rubricJson != null) 'rubric_json': rubricJson,
      if (level != null) 'level': level,
      if (assessedAt != null) 'assessed_at': assessedAt,
    });
  }

  AssessmentsCompanion copyWith({
    Value<int>? id,
    Value<int?>? sessionId,
    Value<String>? rubricJson,
    Value<String>? level,
    Value<DateTime>? assessedAt,
  }) {
    return AssessmentsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      rubricJson: rubricJson ?? this.rubricJson,
      level: level ?? this.level,
      assessedAt: assessedAt ?? this.assessedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (rubricJson.present) {
      map['rubric_json'] = Variable<String>(rubricJson.value);
    }
    if (level.present) {
      map['level'] = Variable<String>(level.value);
    }
    if (assessedAt.present) {
      map['assessed_at'] = Variable<DateTime>(assessedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AssessmentsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('rubricJson: $rubricJson, ')
          ..write('level: $level, ')
          ..write('assessedAt: $assessedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProfilesTable profiles = $ProfilesTable(this);
  late final $ProvidersTable providers = $ProvidersTable(this);
  late final $SessionsTable sessions = $SessionsTable(this);
  late final $TurnsTable turns = $TurnsTable(this);
  late final $SpeechMetricsTable speechMetrics = $SpeechMetricsTable(this);
  late final $CorrectionsTable corrections = $CorrectionsTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $ExpressionsTable expressions = $ExpressionsTable(this);
  late final $ReviewQueueTable reviewQueue = $ReviewQueueTable(this);
  late final $AssessmentsTable assessments = $AssessmentsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    profiles,
    providers,
    sessions,
    turns,
    speechMetrics,
    corrections,
    appSettings,
    expressions,
    reviewQueue,
    assessments,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'providers',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('sessions', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('turns', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('speech_metrics', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('corrections', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'turns',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('corrections', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('expressions', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'corrections',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('review_queue', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('assessments', kind: UpdateKind.update)],
    ),
  ]);
}

typedef $$ProfilesTableCreateCompanionBuilder = ProfilesCompanion Function({
  Value<int> id,
  Value<String> locale,
  Value<int> targetMinutes,
  Value<String?> activeLevel,
  Value<DateTime> createdAt,
});
typedef $$ProfilesTableUpdateCompanionBuilder = ProfilesCompanion Function({
  Value<int> id,
  Value<String> locale,
  Value<int> targetMinutes,
  Value<String?> activeLevel,
  Value<DateTime> createdAt,
});

class $$ProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locale => $composableBuilder(
    column: $table.locale,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetMinutes => $composableBuilder(
    column: $table.targetMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get activeLevel => $composableBuilder(
    column: $table.activeLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locale => $composableBuilder(
    column: $table.locale,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetMinutes => $composableBuilder(
    column: $table.targetMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activeLevel => $composableBuilder(
    column: $table.activeLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get locale =>
      $composableBuilder(column: $table.locale, builder: (column) => column);

  GeneratedColumn<int> get targetMinutes => $composableBuilder(
    column: $table.targetMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get activeLevel => $composableBuilder(
    column: $table.activeLevel,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProfilesTable,
          Profile,
          $$ProfilesTableFilterComposer,
          $$ProfilesTableOrderingComposer,
          $$ProfilesTableAnnotationComposer,
          $$ProfilesTableCreateCompanionBuilder,
          $$ProfilesTableUpdateCompanionBuilder,
          (Profile, BaseReferences<_$AppDatabase, $ProfilesTable, Profile>),
          Profile,
          PrefetchHooks Function()
        > {
  $$ProfilesTableTableManager(_$AppDatabase db, $ProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> locale = const Value.absent(),
                Value<int> targetMinutes = const Value.absent(),
                Value<String?> activeLevel = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ProfilesCompanion(
                id: id,
                locale: locale,
                targetMinutes: targetMinutes,
                activeLevel: activeLevel,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> locale = const Value.absent(),
                Value<int> targetMinutes = const Value.absent(),
                Value<String?> activeLevel = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ProfilesCompanion.insert(
                id: id,
                locale: locale,
                targetMinutes: targetMinutes,
                activeLevel: activeLevel,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ProfilesTable, Profile>(table),
                  BaseReferences<_$AppDatabase, $ProfilesTable, Profile>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProfilesTable,
      Profile,
      $$ProfilesTableFilterComposer,
      $$ProfilesTableOrderingComposer,
      $$ProfilesTableAnnotationComposer,
      $$ProfilesTableCreateCompanionBuilder,
      $$ProfilesTableUpdateCompanionBuilder,
      (Profile, BaseReferences<_$AppDatabase, $ProfilesTable, Profile>),
      Profile,
      PrefetchHooks Function()
    >;
typedef $$ProvidersTableCreateCompanionBuilder = ProvidersCompanion Function({
  Value<int> id,
  required String name,
  Value<String?> modelId,
  required String vaultKeyRef,
  Value<String> settingsJson,
});
typedef $$ProvidersTableUpdateCompanionBuilder = ProvidersCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String?> modelId,
  Value<String> vaultKeyRef,
  Value<String> settingsJson,
});

final class $$ProvidersTableReferences
    extends BaseReferences<_$AppDatabase, $ProvidersTable, Provider> {
  $$ProvidersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SessionsTable, List<Session>> _sessionsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.sessions,
    aliasName: 'providers__id__sessions__provider_id',
  );

  $$SessionsTableProcessedTableManager get sessionsRefs {
    final manager = $$SessionsTableTableManager(
      $_db,
      $_db.sessions,
    ).filter((f) => f.providerId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_sessionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ProvidersTableFilterComposer
    extends Composer<_$AppDatabase, $ProvidersTable> {
  $$ProvidersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modelId => $composableBuilder(
    column: $table.modelId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vaultKeyRef => $composableBuilder(
    column: $table.vaultKeyRef,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get settingsJson => $composableBuilder(
    column: $table.settingsJson,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> sessionsRefs(
    Expression<bool> Function($$SessionsTableFilterComposer f) f,
  ) {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.providerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProvidersTableOrderingComposer
    extends Composer<_$AppDatabase, $ProvidersTable> {
  $$ProvidersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modelId => $composableBuilder(
    column: $table.modelId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vaultKeyRef => $composableBuilder(
    column: $table.vaultKeyRef,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get settingsJson => $composableBuilder(
    column: $table.settingsJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProvidersTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProvidersTable> {
  $$ProvidersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get modelId =>
      $composableBuilder(column: $table.modelId, builder: (column) => column);

  GeneratedColumn<String> get vaultKeyRef => $composableBuilder(
    column: $table.vaultKeyRef,
    builder: (column) => column,
  );

  GeneratedColumn<String> get settingsJson => $composableBuilder(
    column: $table.settingsJson,
    builder: (column) => column,
  );

  Expression<T> sessionsRefs<T extends Object>(
    Expression<T> Function($$SessionsTableAnnotationComposer a) f,
  ) {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.providerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProvidersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProvidersTable,
          Provider,
          $$ProvidersTableFilterComposer,
          $$ProvidersTableOrderingComposer,
          $$ProvidersTableAnnotationComposer,
          $$ProvidersTableCreateCompanionBuilder,
          $$ProvidersTableUpdateCompanionBuilder,
          (Provider, $$ProvidersTableReferences),
          Provider,
          PrefetchHooks Function({bool sessionsRefs})
        > {
  $$ProvidersTableTableManager(_$AppDatabase db, $ProvidersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProvidersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProvidersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProvidersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> modelId = const Value.absent(),
                Value<String> vaultKeyRef = const Value.absent(),
                Value<String> settingsJson = const Value.absent(),
              }) => ProvidersCompanion(
                id: id,
                name: name,
                modelId: modelId,
                vaultKeyRef: vaultKeyRef,
                settingsJson: settingsJson,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> modelId = const Value.absent(),
                required String vaultKeyRef,
                Value<String> settingsJson = const Value.absent(),
              }) => ProvidersCompanion.insert(
                id: id,
                name: name,
                modelId: modelId,
                vaultKeyRef: vaultKeyRef,
                settingsJson: settingsJson,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ProvidersTable, Provider>(table),
                  $$ProvidersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (sessionsRefs) db.sessions],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (sessionsRefs)
                    await $_getPrefetchedData<
                      Provider,
                      $ProvidersTable,
                      Session
                    >(
                      currentTable: table,
                      referencedTable: $$ProvidersTableReferences
                          ._sessionsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ProvidersTableReferences(
                            db,
                            table,
                            p0,
                          ).sessionsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.providerId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ProvidersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProvidersTable,
      Provider,
      $$ProvidersTableFilterComposer,
      $$ProvidersTableOrderingComposer,
      $$ProvidersTableAnnotationComposer,
      $$ProvidersTableCreateCompanionBuilder,
      $$ProvidersTableUpdateCompanionBuilder,
      (Provider, $$ProvidersTableReferences),
      Provider,
      PrefetchHooks Function({bool sessionsRefs})
    >;
typedef $$SessionsTableCreateCompanionBuilder = SessionsCompanion Function({
  Value<int> id,
  required SessionMode mode,
  Value<String?> topic,
  Value<String?> level,
  Value<String?> goal,
  Value<String?> role,
  Value<int> lengthMinutes,
  Value<String?> feedbackJson,
  required DateTime startedAt,
  Value<DateTime?> endedAt,
  required SessionStatus status,
  Value<int?> providerId,
});
typedef $$SessionsTableUpdateCompanionBuilder = SessionsCompanion Function({
  Value<int> id,
  Value<SessionMode> mode,
  Value<String?> topic,
  Value<String?> level,
  Value<String?> goal,
  Value<String?> role,
  Value<int> lengthMinutes,
  Value<String?> feedbackJson,
  Value<DateTime> startedAt,
  Value<DateTime?> endedAt,
  Value<SessionStatus> status,
  Value<int?> providerId,
});

final class $$SessionsTableReferences
    extends BaseReferences<_$AppDatabase, $SessionsTable, Session> {
  $$SessionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProvidersTable _providerIdTable(_$AppDatabase db) =>
      db.providers.createAlias('sessions__provider_id__providers__id');

  $$ProvidersTableProcessedTableManager? get providerId {
    final $_column = $_itemColumn<int>('provider_id');
    if ($_column == null) return null;
    final manager = $$ProvidersTableTableManager(
      $_db,
      $_db.providers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_providerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$TurnsTable, List<Turn>> _turnsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.turns,
    aliasName: 'sessions__id__turns__session_id',
  );

  $$TurnsTableProcessedTableManager get turnsRefs {
    final manager = $$TurnsTableTableManager(
      $_db,
      $_db.turns,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_turnsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SpeechMetricsTable, List<SpeechMetric>>
  _speechMetricsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.speechMetrics,
    aliasName: 'sessions__id__speech_metrics__session_id',
  );

  $$SpeechMetricsTableProcessedTableManager get speechMetricsRefs {
    final manager = $$SpeechMetricsTableTableManager(
      $_db,
      $_db.speechMetrics,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_speechMetricsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CorrectionsTable, List<Correction>>
  _correctionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.corrections,
    aliasName: 'sessions__id__corrections__session_id',
  );

  $$CorrectionsTableProcessedTableManager get correctionsRefs {
    final manager = $$CorrectionsTableTableManager(
      $_db,
      $_db.corrections,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_correctionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ExpressionsTable, List<ExpressionRow>>
  _expressionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.expressions,
    aliasName: 'sessions__id__expressions__source_session_id',
  );

  $$ExpressionsTableProcessedTableManager get expressionsRefs {
    final manager = $$ExpressionsTableTableManager(
      $_db,
      $_db.expressions,
    ).filter((f) => f.sourceSessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_expressionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AssessmentsTable, List<Assessment>>
  _assessmentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.assessments,
    aliasName: 'sessions__id__assessments__session_id',
  );

  $$AssessmentsTableProcessedTableManager get assessmentsRefs {
    final manager = $$AssessmentsTableTableManager(
      $_db,
      $_db.assessments,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_assessmentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SessionsTableFilterComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SessionMode, SessionMode, String> get mode =>
      $composableBuilder(
        column: $table.mode,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get topic => $composableBuilder(
    column: $table.topic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get goal => $composableBuilder(
    column: $table.goal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lengthMinutes => $composableBuilder(
    column: $table.lengthMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get feedbackJson => $composableBuilder(
    column: $table.feedbackJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SessionStatus, SessionStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  $$ProvidersTableFilterComposer get providerId {
    final $$ProvidersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.providerId,
      referencedTable: $db.providers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProvidersTableFilterComposer(
            $db: $db,
            $table: $db.providers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> turnsRefs(
    Expression<bool> Function($$TurnsTableFilterComposer f) f,
  ) {
    final $$TurnsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.turns,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TurnsTableFilterComposer(
            $db: $db,
            $table: $db.turns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> speechMetricsRefs(
    Expression<bool> Function($$SpeechMetricsTableFilterComposer f) f,
  ) {
    final $$SpeechMetricsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.speechMetrics,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SpeechMetricsTableFilterComposer(
            $db: $db,
            $table: $db.speechMetrics,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> correctionsRefs(
    Expression<bool> Function($$CorrectionsTableFilterComposer f) f,
  ) {
    final $$CorrectionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.corrections,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CorrectionsTableFilterComposer(
            $db: $db,
            $table: $db.corrections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> expressionsRefs(
    Expression<bool> Function($$ExpressionsTableFilterComposer f) f,
  ) {
    final $$ExpressionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expressions,
      getReferencedColumn: (t) => t.sourceSessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpressionsTableFilterComposer(
            $db: $db,
            $table: $db.expressions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> assessmentsRefs(
    Expression<bool> Function($$AssessmentsTableFilterComposer f) f,
  ) {
    final $$AssessmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.assessments,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssessmentsTableFilterComposer(
            $db: $db,
            $table: $db.assessments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get topic => $composableBuilder(
    column: $table.topic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get goal => $composableBuilder(
    column: $table.goal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lengthMinutes => $composableBuilder(
    column: $table.lengthMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get feedbackJson => $composableBuilder(
    column: $table.feedbackJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProvidersTableOrderingComposer get providerId {
    final $$ProvidersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.providerId,
      referencedTable: $db.providers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProvidersTableOrderingComposer(
            $db: $db,
            $table: $db.providers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SessionMode, String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<String> get topic =>
      $composableBuilder(column: $table.topic, builder: (column) => column);

  GeneratedColumn<String> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<String> get goal =>
      $composableBuilder(column: $table.goal, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<int> get lengthMinutes => $composableBuilder(
    column: $table.lengthMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get feedbackJson => $composableBuilder(
    column: $table.feedbackJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SessionStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  $$ProvidersTableAnnotationComposer get providerId {
    final $$ProvidersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.providerId,
      referencedTable: $db.providers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProvidersTableAnnotationComposer(
            $db: $db,
            $table: $db.providers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> turnsRefs<T extends Object>(
    Expression<T> Function($$TurnsTableAnnotationComposer a) f,
  ) {
    final $$TurnsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.turns,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TurnsTableAnnotationComposer(
            $db: $db,
            $table: $db.turns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> speechMetricsRefs<T extends Object>(
    Expression<T> Function($$SpeechMetricsTableAnnotationComposer a) f,
  ) {
    final $$SpeechMetricsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.speechMetrics,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SpeechMetricsTableAnnotationComposer(
            $db: $db,
            $table: $db.speechMetrics,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> correctionsRefs<T extends Object>(
    Expression<T> Function($$CorrectionsTableAnnotationComposer a) f,
  ) {
    final $$CorrectionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.corrections,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CorrectionsTableAnnotationComposer(
            $db: $db,
            $table: $db.corrections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> expressionsRefs<T extends Object>(
    Expression<T> Function($$ExpressionsTableAnnotationComposer a) f,
  ) {
    final $$ExpressionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expressions,
      getReferencedColumn: (t) => t.sourceSessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpressionsTableAnnotationComposer(
            $db: $db,
            $table: $db.expressions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> assessmentsRefs<T extends Object>(
    Expression<T> Function($$AssessmentsTableAnnotationComposer a) f,
  ) {
    final $$AssessmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.assessments,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssessmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.assessments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionsTable,
          Session,
          $$SessionsTableFilterComposer,
          $$SessionsTableOrderingComposer,
          $$SessionsTableAnnotationComposer,
          $$SessionsTableCreateCompanionBuilder,
          $$SessionsTableUpdateCompanionBuilder,
          (Session, $$SessionsTableReferences),
          Session,
          PrefetchHooks Function({
            bool providerId,
            bool turnsRefs,
            bool speechMetricsRefs,
            bool correctionsRefs,
            bool expressionsRefs,
            bool assessmentsRefs,
          })
        > {
  $$SessionsTableTableManager(_$AppDatabase db, $SessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<SessionMode> mode = const Value.absent(),
                Value<String?> topic = const Value.absent(),
                Value<String?> level = const Value.absent(),
                Value<String?> goal = const Value.absent(),
                Value<String?> role = const Value.absent(),
                Value<int> lengthMinutes = const Value.absent(),
                Value<String?> feedbackJson = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<SessionStatus> status = const Value.absent(),
                Value<int?> providerId = const Value.absent(),
              }) => SessionsCompanion(
                id: id,
                mode: mode,
                topic: topic,
                level: level,
                goal: goal,
                role: role,
                lengthMinutes: lengthMinutes,
                feedbackJson: feedbackJson,
                startedAt: startedAt,
                endedAt: endedAt,
                status: status,
                providerId: providerId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required SessionMode mode,
                Value<String?> topic = const Value.absent(),
                Value<String?> level = const Value.absent(),
                Value<String?> goal = const Value.absent(),
                Value<String?> role = const Value.absent(),
                Value<int> lengthMinutes = const Value.absent(),
                Value<String?> feedbackJson = const Value.absent(),
                required DateTime startedAt,
                Value<DateTime?> endedAt = const Value.absent(),
                required SessionStatus status,
                Value<int?> providerId = const Value.absent(),
              }) => SessionsCompanion.insert(
                id: id,
                mode: mode,
                topic: topic,
                level: level,
                goal: goal,
                role: role,
                lengthMinutes: lengthMinutes,
                feedbackJson: feedbackJson,
                startedAt: startedAt,
                endedAt: endedAt,
                status: status,
                providerId: providerId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SessionsTable, Session>(table),
                  $$SessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                providerId = false,
                turnsRefs = false,
                speechMetricsRefs = false,
                correctionsRefs = false,
                expressionsRefs = false,
                assessmentsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (turnsRefs) db.turns,
                    if (speechMetricsRefs) db.speechMetrics,
                    if (correctionsRefs) db.corrections,
                    if (expressionsRefs) db.expressions,
                    if (assessmentsRefs) db.assessments,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (providerId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.providerId,
                            referencedTable: $$SessionsTableReferences
                                ._providerIdTable(db),
                            referencedColumn: $$SessionsTableReferences
                                ._providerIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (turnsRefs)
                        await $_getPrefetchedData<
                          Session,
                          $SessionsTable,
                          Turn
                        >(
                          currentTable: table,
                          referencedTable: $$SessionsTableReferences
                              ._turnsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).turnsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (speechMetricsRefs)
                        await $_getPrefetchedData<
                          Session,
                          $SessionsTable,
                          SpeechMetric
                        >(
                          currentTable: table,
                          referencedTable: $$SessionsTableReferences
                              ._speechMetricsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).speechMetricsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (correctionsRefs)
                        await $_getPrefetchedData<
                          Session,
                          $SessionsTable,
                          Correction
                        >(
                          currentTable: table,
                          referencedTable: $$SessionsTableReferences
                              ._correctionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).correctionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (expressionsRefs)
                        await $_getPrefetchedData<
                          Session,
                          $SessionsTable,
                          ExpressionRow
                        >(
                          currentTable: table,
                          referencedTable: $$SessionsTableReferences
                              ._expressionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).expressionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sourceSessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (assessmentsRefs)
                        await $_getPrefetchedData<
                          Session,
                          $SessionsTable,
                          Assessment
                        >(
                          currentTable: table,
                          referencedTable: $$SessionsTableReferences
                              ._assessmentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).assessmentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$SessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionsTable,
      Session,
      $$SessionsTableFilterComposer,
      $$SessionsTableOrderingComposer,
      $$SessionsTableAnnotationComposer,
      $$SessionsTableCreateCompanionBuilder,
      $$SessionsTableUpdateCompanionBuilder,
      (Session, $$SessionsTableReferences),
      Session,
      PrefetchHooks Function({
        bool providerId,
        bool turnsRefs,
        bool speechMetricsRefs,
        bool correctionsRefs,
        bool expressionsRefs,
        bool assessmentsRefs,
      })
    >;
typedef $$TurnsTableCreateCompanionBuilder = TurnsCompanion Function({
  Value<int> id,
  required int sessionId,
  required Speaker speaker,
  required String transcript,
  required DateTime startedAt,
  Value<DateTime?> endedAt,
  Value<int> wordCount,
  Value<bool> isRequest,
  Value<int?> speechMs,
});
typedef $$TurnsTableUpdateCompanionBuilder = TurnsCompanion Function({
  Value<int> id,
  Value<int> sessionId,
  Value<Speaker> speaker,
  Value<String> transcript,
  Value<DateTime> startedAt,
  Value<DateTime?> endedAt,
  Value<int> wordCount,
  Value<bool> isRequest,
  Value<int?> speechMs,
});

final class $$TurnsTableReferences
    extends BaseReferences<_$AppDatabase, $TurnsTable, Turn> {
  $$TurnsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.sessions.createAlias('turns__session_id__sessions__id');

  $$SessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<int>('session_id')!;

    final manager = $$SessionsTableTableManager(
      $_db,
      $_db.sessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$CorrectionsTable, List<Correction>>
  _correctionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.corrections,
    aliasName: 'turns__id__corrections__turn_id',
  );

  $$CorrectionsTableProcessedTableManager get correctionsRefs {
    final manager = $$CorrectionsTableTableManager(
      $_db,
      $_db.corrections,
    ).filter((f) => f.turnId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_correctionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TurnsTableFilterComposer extends Composer<_$AppDatabase, $TurnsTable> {
  $$TurnsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Speaker, Speaker, String> get speaker =>
      $composableBuilder(
        column: $table.speaker,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get transcript => $composableBuilder(
    column: $table.transcript,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get wordCount => $composableBuilder(
    column: $table.wordCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRequest => $composableBuilder(
    column: $table.isRequest,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get speechMs => $composableBuilder(
    column: $table.speechMs,
    builder: (column) => ColumnFilters(column),
  );

  $$SessionsTableFilterComposer get sessionId {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> correctionsRefs(
    Expression<bool> Function($$CorrectionsTableFilterComposer f) f,
  ) {
    final $$CorrectionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.corrections,
      getReferencedColumn: (t) => t.turnId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CorrectionsTableFilterComposer(
            $db: $db,
            $table: $db.corrections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TurnsTableOrderingComposer
    extends Composer<_$AppDatabase, $TurnsTable> {
  $$TurnsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get speaker => $composableBuilder(
    column: $table.speaker,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transcript => $composableBuilder(
    column: $table.transcript,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get wordCount => $composableBuilder(
    column: $table.wordCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRequest => $composableBuilder(
    column: $table.isRequest,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get speechMs => $composableBuilder(
    column: $table.speechMs,
    builder: (column) => ColumnOrderings(column),
  );

  $$SessionsTableOrderingComposer get sessionId {
    final $$SessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableOrderingComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TurnsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TurnsTable> {
  $$TurnsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Speaker, String> get speaker =>
      $composableBuilder(column: $table.speaker, builder: (column) => column);

  GeneratedColumn<String> get transcript => $composableBuilder(
    column: $table.transcript,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<int> get wordCount =>
      $composableBuilder(column: $table.wordCount, builder: (column) => column);

  GeneratedColumn<bool> get isRequest =>
      $composableBuilder(column: $table.isRequest, builder: (column) => column);

  GeneratedColumn<int> get speechMs =>
      $composableBuilder(column: $table.speechMs, builder: (column) => column);

  $$SessionsTableAnnotationComposer get sessionId {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> correctionsRefs<T extends Object>(
    Expression<T> Function($$CorrectionsTableAnnotationComposer a) f,
  ) {
    final $$CorrectionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.corrections,
      getReferencedColumn: (t) => t.turnId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CorrectionsTableAnnotationComposer(
            $db: $db,
            $table: $db.corrections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TurnsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TurnsTable,
          Turn,
          $$TurnsTableFilterComposer,
          $$TurnsTableOrderingComposer,
          $$TurnsTableAnnotationComposer,
          $$TurnsTableCreateCompanionBuilder,
          $$TurnsTableUpdateCompanionBuilder,
          (Turn, $$TurnsTableReferences),
          Turn,
          PrefetchHooks Function({bool sessionId, bool correctionsRefs})
        > {
  $$TurnsTableTableManager(_$AppDatabase db, $TurnsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TurnsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TurnsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TurnsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sessionId = const Value.absent(),
                Value<Speaker> speaker = const Value.absent(),
                Value<String> transcript = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<int> wordCount = const Value.absent(),
                Value<bool> isRequest = const Value.absent(),
                Value<int?> speechMs = const Value.absent(),
              }) => TurnsCompanion(
                id: id,
                sessionId: sessionId,
                speaker: speaker,
                transcript: transcript,
                startedAt: startedAt,
                endedAt: endedAt,
                wordCount: wordCount,
                isRequest: isRequest,
                speechMs: speechMs,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sessionId,
                required Speaker speaker,
                required String transcript,
                required DateTime startedAt,
                Value<DateTime?> endedAt = const Value.absent(),
                Value<int> wordCount = const Value.absent(),
                Value<bool> isRequest = const Value.absent(),
                Value<int?> speechMs = const Value.absent(),
              }) => TurnsCompanion.insert(
                id: id,
                sessionId: sessionId,
                speaker: speaker,
                transcript: transcript,
                startedAt: startedAt,
                endedAt: endedAt,
                wordCount: wordCount,
                isRequest: isRequest,
                speechMs: speechMs,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TurnsTable, Turn>(table),
                  $$TurnsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({sessionId = false, correctionsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (correctionsRefs) db.corrections,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (sessionId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.sessionId,
                            referencedTable: $$TurnsTableReferences
                                ._sessionIdTable(db),
                            referencedColumn: $$TurnsTableReferences
                                ._sessionIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (correctionsRefs)
                        await $_getPrefetchedData<
                          Turn,
                          $TurnsTable,
                          Correction
                        >(
                          currentTable: table,
                          referencedTable: $$TurnsTableReferences
                              ._correctionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TurnsTableReferences(
                                db,
                                table,
                                p0,
                              ).correctionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.turnId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$TurnsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TurnsTable,
      Turn,
      $$TurnsTableFilterComposer,
      $$TurnsTableOrderingComposer,
      $$TurnsTableAnnotationComposer,
      $$TurnsTableCreateCompanionBuilder,
      $$TurnsTableUpdateCompanionBuilder,
      (Turn, $$TurnsTableReferences),
      Turn,
      PrefetchHooks Function({bool sessionId, bool correctionsRefs})
    >;
typedef $$SpeechMetricsTableCreateCompanionBuilder =
    SpeechMetricsCompanion Function({
      Value<int> sessionId,
      Value<int> userMs,
      Value<int> assistantMs,
      Value<int> turnCount,
      Value<double?> confidence,
    });
typedef $$SpeechMetricsTableUpdateCompanionBuilder =
    SpeechMetricsCompanion Function({
      Value<int> sessionId,
      Value<int> userMs,
      Value<int> assistantMs,
      Value<int> turnCount,
      Value<double?> confidence,
    });

final class $$SpeechMetricsTableReferences
    extends BaseReferences<_$AppDatabase, $SpeechMetricsTable, SpeechMetric> {
  $$SpeechMetricsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.sessions.createAlias('speech_metrics__session_id__sessions__id');

  $$SessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<int>('session_id')!;

    final manager = $$SessionsTableTableManager(
      $_db,
      $_db.sessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SpeechMetricsTableFilterComposer
    extends Composer<_$AppDatabase, $SpeechMetricsTable> {
  $$SpeechMetricsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get userMs => $composableBuilder(
    column: $table.userMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get assistantMs => $composableBuilder(
    column: $table.assistantMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get turnCount => $composableBuilder(
    column: $table.turnCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  $$SessionsTableFilterComposer get sessionId {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SpeechMetricsTableOrderingComposer
    extends Composer<_$AppDatabase, $SpeechMetricsTable> {
  $$SpeechMetricsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get userMs => $composableBuilder(
    column: $table.userMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get assistantMs => $composableBuilder(
    column: $table.assistantMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get turnCount => $composableBuilder(
    column: $table.turnCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  $$SessionsTableOrderingComposer get sessionId {
    final $$SessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableOrderingComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SpeechMetricsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SpeechMetricsTable> {
  $$SpeechMetricsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get userMs =>
      $composableBuilder(column: $table.userMs, builder: (column) => column);

  GeneratedColumn<int> get assistantMs => $composableBuilder(
    column: $table.assistantMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get turnCount =>
      $composableBuilder(column: $table.turnCount, builder: (column) => column);

  GeneratedColumn<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  $$SessionsTableAnnotationComposer get sessionId {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SpeechMetricsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SpeechMetricsTable,
          SpeechMetric,
          $$SpeechMetricsTableFilterComposer,
          $$SpeechMetricsTableOrderingComposer,
          $$SpeechMetricsTableAnnotationComposer,
          $$SpeechMetricsTableCreateCompanionBuilder,
          $$SpeechMetricsTableUpdateCompanionBuilder,
          (SpeechMetric, $$SpeechMetricsTableReferences),
          SpeechMetric,
          PrefetchHooks Function({bool sessionId})
        > {
  $$SpeechMetricsTableTableManager(_$AppDatabase db, $SpeechMetricsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SpeechMetricsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SpeechMetricsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SpeechMetricsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> sessionId = const Value.absent(),
                Value<int> userMs = const Value.absent(),
                Value<int> assistantMs = const Value.absent(),
                Value<int> turnCount = const Value.absent(),
                Value<double?> confidence = const Value.absent(),
              }) => SpeechMetricsCompanion(
                sessionId: sessionId,
                userMs: userMs,
                assistantMs: assistantMs,
                turnCount: turnCount,
                confidence: confidence,
              ),
          createCompanionCallback:
              ({
                Value<int> sessionId = const Value.absent(),
                Value<int> userMs = const Value.absent(),
                Value<int> assistantMs = const Value.absent(),
                Value<int> turnCount = const Value.absent(),
                Value<double?> confidence = const Value.absent(),
              }) => SpeechMetricsCompanion.insert(
                sessionId: sessionId,
                userMs: userMs,
                assistantMs: assistantMs,
                turnCount: turnCount,
                confidence: confidence,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SpeechMetricsTable, SpeechMetric>(table),
                  $$SpeechMetricsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sessionId,
                        referencedTable: $$SpeechMetricsTableReferences
                            ._sessionIdTable(db),
                        referencedColumn: $$SpeechMetricsTableReferences
                            ._sessionIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SpeechMetricsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SpeechMetricsTable,
      SpeechMetric,
      $$SpeechMetricsTableFilterComposer,
      $$SpeechMetricsTableOrderingComposer,
      $$SpeechMetricsTableAnnotationComposer,
      $$SpeechMetricsTableCreateCompanionBuilder,
      $$SpeechMetricsTableUpdateCompanionBuilder,
      (SpeechMetric, $$SpeechMetricsTableReferences),
      SpeechMetric,
      PrefetchHooks Function({bool sessionId})
    >;
typedef $$CorrectionsTableCreateCompanionBuilder =
    CorrectionsCompanion Function({
      Value<int> id,
      required int sessionId,
      required int turnId,
      required String original,
      required String suggested,
      Value<String?> explanation,
      Value<bool> practiced,
      Value<String?> severity,
      Value<String?> practicePrompt,
    });
typedef $$CorrectionsTableUpdateCompanionBuilder =
    CorrectionsCompanion Function({
      Value<int> id,
      Value<int> sessionId,
      Value<int> turnId,
      Value<String> original,
      Value<String> suggested,
      Value<String?> explanation,
      Value<bool> practiced,
      Value<String?> severity,
      Value<String?> practicePrompt,
    });

final class $$CorrectionsTableReferences
    extends BaseReferences<_$AppDatabase, $CorrectionsTable, Correction> {
  $$CorrectionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.sessions.createAlias('corrections__session_id__sessions__id');

  $$SessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<int>('session_id')!;

    final manager = $$SessionsTableTableManager(
      $_db,
      $_db.sessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TurnsTable _turnIdTable(_$AppDatabase db) =>
      db.turns.createAlias('corrections__turn_id__turns__id');

  $$TurnsTableProcessedTableManager get turnId {
    final $_column = $_itemColumn<int>('turn_id')!;

    final manager = $$TurnsTableTableManager(
      $_db,
      $_db.turns,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_turnIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ReviewQueueTable, List<ReviewRow>>
  _reviewQueueRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.reviewQueue,
    aliasName: 'corrections__id__review_queue__correction_id',
  );

  $$ReviewQueueTableProcessedTableManager get reviewQueueRefs {
    final manager = $$ReviewQueueTableTableManager(
      $_db,
      $_db.reviewQueue,
    ).filter((f) => f.correctionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_reviewQueueRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CorrectionsTableFilterComposer
    extends Composer<_$AppDatabase, $CorrectionsTable> {
  $$CorrectionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get original => $composableBuilder(
    column: $table.original,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get suggested => $composableBuilder(
    column: $table.suggested,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get explanation => $composableBuilder(
    column: $table.explanation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get practiced => $composableBuilder(
    column: $table.practiced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get severity => $composableBuilder(
    column: $table.severity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get practicePrompt => $composableBuilder(
    column: $table.practicePrompt,
    builder: (column) => ColumnFilters(column),
  );

  $$SessionsTableFilterComposer get sessionId {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TurnsTableFilterComposer get turnId {
    final $$TurnsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.turnId,
      referencedTable: $db.turns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TurnsTableFilterComposer(
            $db: $db,
            $table: $db.turns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> reviewQueueRefs(
    Expression<bool> Function($$ReviewQueueTableFilterComposer f) f,
  ) {
    final $$ReviewQueueTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reviewQueue,
      getReferencedColumn: (t) => t.correctionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReviewQueueTableFilterComposer(
            $db: $db,
            $table: $db.reviewQueue,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CorrectionsTableOrderingComposer
    extends Composer<_$AppDatabase, $CorrectionsTable> {
  $$CorrectionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get original => $composableBuilder(
    column: $table.original,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get suggested => $composableBuilder(
    column: $table.suggested,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get explanation => $composableBuilder(
    column: $table.explanation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get practiced => $composableBuilder(
    column: $table.practiced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get severity => $composableBuilder(
    column: $table.severity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get practicePrompt => $composableBuilder(
    column: $table.practicePrompt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SessionsTableOrderingComposer get sessionId {
    final $$SessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableOrderingComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TurnsTableOrderingComposer get turnId {
    final $$TurnsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.turnId,
      referencedTable: $db.turns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TurnsTableOrderingComposer(
            $db: $db,
            $table: $db.turns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CorrectionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CorrectionsTable> {
  $$CorrectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get original =>
      $composableBuilder(column: $table.original, builder: (column) => column);

  GeneratedColumn<String> get suggested =>
      $composableBuilder(column: $table.suggested, builder: (column) => column);

  GeneratedColumn<String> get explanation => $composableBuilder(
    column: $table.explanation,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get practiced =>
      $composableBuilder(column: $table.practiced, builder: (column) => column);

  GeneratedColumn<String> get severity =>
      $composableBuilder(column: $table.severity, builder: (column) => column);

  GeneratedColumn<String> get practicePrompt => $composableBuilder(
    column: $table.practicePrompt,
    builder: (column) => column,
  );

  $$SessionsTableAnnotationComposer get sessionId {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TurnsTableAnnotationComposer get turnId {
    final $$TurnsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.turnId,
      referencedTable: $db.turns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TurnsTableAnnotationComposer(
            $db: $db,
            $table: $db.turns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> reviewQueueRefs<T extends Object>(
    Expression<T> Function($$ReviewQueueTableAnnotationComposer a) f,
  ) {
    final $$ReviewQueueTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reviewQueue,
      getReferencedColumn: (t) => t.correctionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReviewQueueTableAnnotationComposer(
            $db: $db,
            $table: $db.reviewQueue,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CorrectionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CorrectionsTable,
          Correction,
          $$CorrectionsTableFilterComposer,
          $$CorrectionsTableOrderingComposer,
          $$CorrectionsTableAnnotationComposer,
          $$CorrectionsTableCreateCompanionBuilder,
          $$CorrectionsTableUpdateCompanionBuilder,
          (Correction, $$CorrectionsTableReferences),
          Correction,
          PrefetchHooks Function({
            bool sessionId,
            bool turnId,
            bool reviewQueueRefs,
          })
        > {
  $$CorrectionsTableTableManager(_$AppDatabase db, $CorrectionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CorrectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CorrectionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CorrectionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sessionId = const Value.absent(),
                Value<int> turnId = const Value.absent(),
                Value<String> original = const Value.absent(),
                Value<String> suggested = const Value.absent(),
                Value<String?> explanation = const Value.absent(),
                Value<bool> practiced = const Value.absent(),
                Value<String?> severity = const Value.absent(),
                Value<String?> practicePrompt = const Value.absent(),
              }) => CorrectionsCompanion(
                id: id,
                sessionId: sessionId,
                turnId: turnId,
                original: original,
                suggested: suggested,
                explanation: explanation,
                practiced: practiced,
                severity: severity,
                practicePrompt: practicePrompt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sessionId,
                required int turnId,
                required String original,
                required String suggested,
                Value<String?> explanation = const Value.absent(),
                Value<bool> practiced = const Value.absent(),
                Value<String?> severity = const Value.absent(),
                Value<String?> practicePrompt = const Value.absent(),
              }) => CorrectionsCompanion.insert(
                id: id,
                sessionId: sessionId,
                turnId: turnId,
                original: original,
                suggested: suggested,
                explanation: explanation,
                practiced: practiced,
                severity: severity,
                practicePrompt: practicePrompt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CorrectionsTable, Correction>(table),
                  $$CorrectionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({sessionId = false, turnId = false, reviewQueueRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (reviewQueueRefs) db.reviewQueue,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (sessionId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.sessionId,
                            referencedTable: $$CorrectionsTableReferences
                                ._sessionIdTable(db),
                            referencedColumn: $$CorrectionsTableReferences
                                ._sessionIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (turnId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.turnId,
                            referencedTable: $$CorrectionsTableReferences
                                ._turnIdTable(db),
                            referencedColumn: $$CorrectionsTableReferences
                                ._turnIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (reviewQueueRefs)
                        await $_getPrefetchedData<
                          Correction,
                          $CorrectionsTable,
                          ReviewRow
                        >(
                          currentTable: table,
                          referencedTable: $$CorrectionsTableReferences
                              ._reviewQueueRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CorrectionsTableReferences(
                                db,
                                table,
                                p0,
                              ).reviewQueueRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.correctionId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CorrectionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CorrectionsTable,
      Correction,
      $$CorrectionsTableFilterComposer,
      $$CorrectionsTableOrderingComposer,
      $$CorrectionsTableAnnotationComposer,
      $$CorrectionsTableCreateCompanionBuilder,
      $$CorrectionsTableUpdateCompanionBuilder,
      (Correction, $$CorrectionsTableReferences),
      Correction,
      PrefetchHooks Function({
        bool sessionId,
        bool turnId,
        bool reviewQueueRefs,
      })
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String name,
      required String value,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> name,
      Value<String> value,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> name = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => AppSettingsCompanion(name: name, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String name,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                name: name,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppSettingsTable, AppSetting>(table),
                  BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;
typedef $$ExpressionsTableCreateCompanionBuilder =
    ExpressionsCompanion Function({
      Value<int> id,
      required String phrase,
      Value<String?> meaningKo,
      required int sourceSessionId,
    });
typedef $$ExpressionsTableUpdateCompanionBuilder =
    ExpressionsCompanion Function({
      Value<int> id,
      Value<String> phrase,
      Value<String?> meaningKo,
      Value<int> sourceSessionId,
    });

final class $$ExpressionsTableReferences
    extends BaseReferences<_$AppDatabase, $ExpressionsTable, ExpressionRow> {
  $$ExpressionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SessionsTable _sourceSessionIdTable(_$AppDatabase db) =>
      db.sessions.createAlias('expressions__source_session_id__sessions__id');

  $$SessionsTableProcessedTableManager get sourceSessionId {
    final $_column = $_itemColumn<int>('source_session_id')!;

    final manager = $$SessionsTableTableManager(
      $_db,
      $_db.sessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sourceSessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ExpressionsTableFilterComposer
    extends Composer<_$AppDatabase, $ExpressionsTable> {
  $$ExpressionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phrase => $composableBuilder(
    column: $table.phrase,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get meaningKo => $composableBuilder(
    column: $table.meaningKo,
    builder: (column) => ColumnFilters(column),
  );

  $$SessionsTableFilterComposer get sourceSessionId {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceSessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExpressionsTableOrderingComposer
    extends Composer<_$AppDatabase, $ExpressionsTable> {
  $$ExpressionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phrase => $composableBuilder(
    column: $table.phrase,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get meaningKo => $composableBuilder(
    column: $table.meaningKo,
    builder: (column) => ColumnOrderings(column),
  );

  $$SessionsTableOrderingComposer get sourceSessionId {
    final $$SessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceSessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableOrderingComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExpressionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExpressionsTable> {
  $$ExpressionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get phrase =>
      $composableBuilder(column: $table.phrase, builder: (column) => column);

  GeneratedColumn<String> get meaningKo =>
      $composableBuilder(column: $table.meaningKo, builder: (column) => column);

  $$SessionsTableAnnotationComposer get sourceSessionId {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceSessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExpressionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExpressionsTable,
          ExpressionRow,
          $$ExpressionsTableFilterComposer,
          $$ExpressionsTableOrderingComposer,
          $$ExpressionsTableAnnotationComposer,
          $$ExpressionsTableCreateCompanionBuilder,
          $$ExpressionsTableUpdateCompanionBuilder,
          (ExpressionRow, $$ExpressionsTableReferences),
          ExpressionRow,
          PrefetchHooks Function({bool sourceSessionId})
        > {
  $$ExpressionsTableTableManager(_$AppDatabase db, $ExpressionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExpressionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExpressionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExpressionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> phrase = const Value.absent(),
                Value<String?> meaningKo = const Value.absent(),
                Value<int> sourceSessionId = const Value.absent(),
              }) => ExpressionsCompanion(
                id: id,
                phrase: phrase,
                meaningKo: meaningKo,
                sourceSessionId: sourceSessionId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String phrase,
                Value<String?> meaningKo = const Value.absent(),
                required int sourceSessionId,
              }) => ExpressionsCompanion.insert(
                id: id,
                phrase: phrase,
                meaningKo: meaningKo,
                sourceSessionId: sourceSessionId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ExpressionsTable, ExpressionRow>(table),
                  $$ExpressionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sourceSessionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sourceSessionId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sourceSessionId,
                        referencedTable: $$ExpressionsTableReferences
                            ._sourceSessionIdTable(db),
                        referencedColumn: $$ExpressionsTableReferences
                            ._sourceSessionIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ExpressionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExpressionsTable,
      ExpressionRow,
      $$ExpressionsTableFilterComposer,
      $$ExpressionsTableOrderingComposer,
      $$ExpressionsTableAnnotationComposer,
      $$ExpressionsTableCreateCompanionBuilder,
      $$ExpressionsTableUpdateCompanionBuilder,
      (ExpressionRow, $$ExpressionsTableReferences),
      ExpressionRow,
      PrefetchHooks Function({bool sourceSessionId})
    >;
typedef $$ReviewQueueTableCreateCompanionBuilder =
    ReviewQueueCompanion Function({
      Value<int> id,
      required int correctionId,
      required DateTime dueAt,
      Value<int> intervalDays,
      Value<int> repetitions,
    });
typedef $$ReviewQueueTableUpdateCompanionBuilder =
    ReviewQueueCompanion Function({
      Value<int> id,
      Value<int> correctionId,
      Value<DateTime> dueAt,
      Value<int> intervalDays,
      Value<int> repetitions,
    });

final class $$ReviewQueueTableReferences
    extends BaseReferences<_$AppDatabase, $ReviewQueueTable, ReviewRow> {
  $$ReviewQueueTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CorrectionsTable _correctionIdTable(_$AppDatabase db) => db
      .corrections
      .createAlias('review_queue__correction_id__corrections__id');

  $$CorrectionsTableProcessedTableManager get correctionId {
    final $_column = $_itemColumn<int>('correction_id')!;

    final manager = $$CorrectionsTableTableManager(
      $_db,
      $_db.corrections,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_correctionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ReviewQueueTableFilterComposer
    extends Composer<_$AppDatabase, $ReviewQueueTable> {
  $$ReviewQueueTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get intervalDays => $composableBuilder(
    column: $table.intervalDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get repetitions => $composableBuilder(
    column: $table.repetitions,
    builder: (column) => ColumnFilters(column),
  );

  $$CorrectionsTableFilterComposer get correctionId {
    final $$CorrectionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.correctionId,
      referencedTable: $db.corrections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CorrectionsTableFilterComposer(
            $db: $db,
            $table: $db.corrections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReviewQueueTableOrderingComposer
    extends Composer<_$AppDatabase, $ReviewQueueTable> {
  $$ReviewQueueTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get intervalDays => $composableBuilder(
    column: $table.intervalDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get repetitions => $composableBuilder(
    column: $table.repetitions,
    builder: (column) => ColumnOrderings(column),
  );

  $$CorrectionsTableOrderingComposer get correctionId {
    final $$CorrectionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.correctionId,
      referencedTable: $db.corrections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CorrectionsTableOrderingComposer(
            $db: $db,
            $table: $db.corrections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReviewQueueTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReviewQueueTable> {
  $$ReviewQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get dueAt =>
      $composableBuilder(column: $table.dueAt, builder: (column) => column);

  GeneratedColumn<int> get intervalDays => $composableBuilder(
    column: $table.intervalDays,
    builder: (column) => column,
  );

  GeneratedColumn<int> get repetitions => $composableBuilder(
    column: $table.repetitions,
    builder: (column) => column,
  );

  $$CorrectionsTableAnnotationComposer get correctionId {
    final $$CorrectionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.correctionId,
      referencedTable: $db.corrections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CorrectionsTableAnnotationComposer(
            $db: $db,
            $table: $db.corrections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReviewQueueTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReviewQueueTable,
          ReviewRow,
          $$ReviewQueueTableFilterComposer,
          $$ReviewQueueTableOrderingComposer,
          $$ReviewQueueTableAnnotationComposer,
          $$ReviewQueueTableCreateCompanionBuilder,
          $$ReviewQueueTableUpdateCompanionBuilder,
          (ReviewRow, $$ReviewQueueTableReferences),
          ReviewRow,
          PrefetchHooks Function({bool correctionId})
        > {
  $$ReviewQueueTableTableManager(_$AppDatabase db, $ReviewQueueTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReviewQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReviewQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReviewQueueTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> correctionId = const Value.absent(),
                Value<DateTime> dueAt = const Value.absent(),
                Value<int> intervalDays = const Value.absent(),
                Value<int> repetitions = const Value.absent(),
              }) => ReviewQueueCompanion(
                id: id,
                correctionId: correctionId,
                dueAt: dueAt,
                intervalDays: intervalDays,
                repetitions: repetitions,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int correctionId,
                required DateTime dueAt,
                Value<int> intervalDays = const Value.absent(),
                Value<int> repetitions = const Value.absent(),
              }) => ReviewQueueCompanion.insert(
                id: id,
                correctionId: correctionId,
                dueAt: dueAt,
                intervalDays: intervalDays,
                repetitions: repetitions,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ReviewQueueTable, ReviewRow>(table),
                  $$ReviewQueueTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({correctionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (correctionId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.correctionId,
                        referencedTable: $$ReviewQueueTableReferences
                            ._correctionIdTable(db),
                        referencedColumn: $$ReviewQueueTableReferences
                            ._correctionIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ReviewQueueTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReviewQueueTable,
      ReviewRow,
      $$ReviewQueueTableFilterComposer,
      $$ReviewQueueTableOrderingComposer,
      $$ReviewQueueTableAnnotationComposer,
      $$ReviewQueueTableCreateCompanionBuilder,
      $$ReviewQueueTableUpdateCompanionBuilder,
      (ReviewRow, $$ReviewQueueTableReferences),
      ReviewRow,
      PrefetchHooks Function({bool correctionId})
    >;
typedef $$AssessmentsTableCreateCompanionBuilder =
    AssessmentsCompanion Function({
      Value<int> id,
      Value<int?> sessionId,
      required String rubricJson,
      required String level,
      required DateTime assessedAt,
    });
typedef $$AssessmentsTableUpdateCompanionBuilder =
    AssessmentsCompanion Function({
      Value<int> id,
      Value<int?> sessionId,
      Value<String> rubricJson,
      Value<String> level,
      Value<DateTime> assessedAt,
    });

final class $$AssessmentsTableReferences
    extends BaseReferences<_$AppDatabase, $AssessmentsTable, Assessment> {
  $$AssessmentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.sessions.createAlias('assessments__session_id__sessions__id');

  $$SessionsTableProcessedTableManager? get sessionId {
    final $_column = $_itemColumn<int>('session_id');
    if ($_column == null) return null;
    final manager = $$SessionsTableTableManager(
      $_db,
      $_db.sessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AssessmentsTableFilterComposer
    extends Composer<_$AppDatabase, $AssessmentsTable> {
  $$AssessmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rubricJson => $composableBuilder(
    column: $table.rubricJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get assessedAt => $composableBuilder(
    column: $table.assessedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SessionsTableFilterComposer get sessionId {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AssessmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $AssessmentsTable> {
  $$AssessmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rubricJson => $composableBuilder(
    column: $table.rubricJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get assessedAt => $composableBuilder(
    column: $table.assessedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SessionsTableOrderingComposer get sessionId {
    final $$SessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableOrderingComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AssessmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AssessmentsTable> {
  $$AssessmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get rubricJson => $composableBuilder(
    column: $table.rubricJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<DateTime> get assessedAt => $composableBuilder(
    column: $table.assessedAt,
    builder: (column) => column,
  );

  $$SessionsTableAnnotationComposer get sessionId {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AssessmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AssessmentsTable,
          Assessment,
          $$AssessmentsTableFilterComposer,
          $$AssessmentsTableOrderingComposer,
          $$AssessmentsTableAnnotationComposer,
          $$AssessmentsTableCreateCompanionBuilder,
          $$AssessmentsTableUpdateCompanionBuilder,
          (Assessment, $$AssessmentsTableReferences),
          Assessment,
          PrefetchHooks Function({bool sessionId})
        > {
  $$AssessmentsTableTableManager(_$AppDatabase db, $AssessmentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AssessmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AssessmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AssessmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> sessionId = const Value.absent(),
                Value<String> rubricJson = const Value.absent(),
                Value<String> level = const Value.absent(),
                Value<DateTime> assessedAt = const Value.absent(),
              }) => AssessmentsCompanion(
                id: id,
                sessionId: sessionId,
                rubricJson: rubricJson,
                level: level,
                assessedAt: assessedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> sessionId = const Value.absent(),
                required String rubricJson,
                required String level,
                required DateTime assessedAt,
              }) => AssessmentsCompanion.insert(
                id: id,
                sessionId: sessionId,
                rubricJson: rubricJson,
                level: level,
                assessedAt: assessedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AssessmentsTable, Assessment>(table),
                  $$AssessmentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sessionId,
                        referencedTable: $$AssessmentsTableReferences
                            ._sessionIdTable(db),
                        referencedColumn: $$AssessmentsTableReferences
                            ._sessionIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$AssessmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AssessmentsTable,
      Assessment,
      $$AssessmentsTableFilterComposer,
      $$AssessmentsTableOrderingComposer,
      $$AssessmentsTableAnnotationComposer,
      $$AssessmentsTableCreateCompanionBuilder,
      $$AssessmentsTableUpdateCompanionBuilder,
      (Assessment, $$AssessmentsTableReferences),
      Assessment,
      PrefetchHooks Function({bool sessionId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db, _db.profiles);
  $$ProvidersTableTableManager get providers =>
      $$ProvidersTableTableManager(_db, _db.providers);
  $$SessionsTableTableManager get sessions =>
      $$SessionsTableTableManager(_db, _db.sessions);
  $$TurnsTableTableManager get turns =>
      $$TurnsTableTableManager(_db, _db.turns);
  $$SpeechMetricsTableTableManager get speechMetrics =>
      $$SpeechMetricsTableTableManager(_db, _db.speechMetrics);
  $$CorrectionsTableTableManager get corrections =>
      $$CorrectionsTableTableManager(_db, _db.corrections);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$ExpressionsTableTableManager get expressions =>
      $$ExpressionsTableTableManager(_db, _db.expressions);
  $$ReviewQueueTableTableManager get reviewQueue =>
      $$ReviewQueueTableTableManager(_db, _db.reviewQueue);
  $$AssessmentsTableTableManager get assessments =>
      $$AssessmentsTableTableManager(_db, _db.assessments);
}
