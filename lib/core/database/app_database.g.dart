// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $KanjiEntriesTable extends KanjiEntries
    with TableInfo<$KanjiEntriesTable, KanjiEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KanjiEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _characterMeta = const VerificationMeta(
    'character',
  );
  @override
  late final GeneratedColumn<String> character = GeneratedColumn<String>(
    'character',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 4,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jlptLevelMeta = const VerificationMeta(
    'jlptLevel',
  );
  @override
  late final GeneratedColumn<int> jlptLevel = GeneratedColumn<int>(
    'jlpt_level',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _meaningsMeta = const VerificationMeta(
    'meanings',
  );
  @override
  late final GeneratedColumn<String> meanings = GeneratedColumn<String>(
    'meanings',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _meaningsIdMeta = const VerificationMeta(
    'meaningsId',
  );
  @override
  late final GeneratedColumn<String> meaningsId = GeneratedColumn<String>(
    'meanings_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _onyomiMeta = const VerificationMeta('onyomi');
  @override
  late final GeneratedColumn<String> onyomi = GeneratedColumn<String>(
    'onyomi',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kunyomiMeta = const VerificationMeta(
    'kunyomi',
  );
  @override
  late final GeneratedColumn<String> kunyomi = GeneratedColumn<String>(
    'kunyomi',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameReadingsMeta = const VerificationMeta(
    'nameReadings',
  );
  @override
  late final GeneratedColumn<String> nameReadings = GeneratedColumn<String>(
    'name_readings',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _strokeCountMeta = const VerificationMeta(
    'strokeCount',
  );
  @override
  late final GeneratedColumn<int> strokeCount = GeneratedColumn<int>(
    'stroke_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _gradeMeta = const VerificationMeta('grade');
  @override
  late final GeneratedColumn<int> grade = GeneratedColumn<int>(
    'grade',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _heisigKeywordMeta = const VerificationMeta(
    'heisigKeyword',
  );
  @override
  late final GeneratedColumn<String> heisigKeyword = GeneratedColumn<String>(
    'heisig_keyword',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _frequencyMeta = const VerificationMeta(
    'frequency',
  );
  @override
  late final GeneratedColumn<int> frequency = GeneratedColumn<int>(
    'frequency',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unicodeMeta = const VerificationMeta(
    'unicode',
  );
  @override
  late final GeneratedColumn<String> unicode = GeneratedColumn<String>(
    'unicode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _cachedAtMeta = const VerificationMeta(
    'cachedAt',
  );
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
    'cached_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    character,
    jlptLevel,
    meanings,
    meaningsId,
    onyomi,
    kunyomi,
    nameReadings,
    strokeCount,
    grade,
    heisigKeyword,
    frequency,
    unicode,
    cachedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'kanji_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<KanjiEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('character')) {
      context.handle(
        _characterMeta,
        character.isAcceptableOrUnknown(data['character']!, _characterMeta),
      );
    } else if (isInserting) {
      context.missing(_characterMeta);
    }
    if (data.containsKey('jlpt_level')) {
      context.handle(
        _jlptLevelMeta,
        jlptLevel.isAcceptableOrUnknown(data['jlpt_level']!, _jlptLevelMeta),
      );
    }
    if (data.containsKey('meanings')) {
      context.handle(
        _meaningsMeta,
        meanings.isAcceptableOrUnknown(data['meanings']!, _meaningsMeta),
      );
    } else if (isInserting) {
      context.missing(_meaningsMeta);
    }
    if (data.containsKey('meanings_id')) {
      context.handle(
        _meaningsIdMeta,
        meaningsId.isAcceptableOrUnknown(data['meanings_id']!, _meaningsIdMeta),
      );
    }
    if (data.containsKey('onyomi')) {
      context.handle(
        _onyomiMeta,
        onyomi.isAcceptableOrUnknown(data['onyomi']!, _onyomiMeta),
      );
    } else if (isInserting) {
      context.missing(_onyomiMeta);
    }
    if (data.containsKey('kunyomi')) {
      context.handle(
        _kunyomiMeta,
        kunyomi.isAcceptableOrUnknown(data['kunyomi']!, _kunyomiMeta),
      );
    } else if (isInserting) {
      context.missing(_kunyomiMeta);
    }
    if (data.containsKey('name_readings')) {
      context.handle(
        _nameReadingsMeta,
        nameReadings.isAcceptableOrUnknown(
          data['name_readings']!,
          _nameReadingsMeta,
        ),
      );
    }
    if (data.containsKey('stroke_count')) {
      context.handle(
        _strokeCountMeta,
        strokeCount.isAcceptableOrUnknown(
          data['stroke_count']!,
          _strokeCountMeta,
        ),
      );
    }
    if (data.containsKey('grade')) {
      context.handle(
        _gradeMeta,
        grade.isAcceptableOrUnknown(data['grade']!, _gradeMeta),
      );
    }
    if (data.containsKey('heisig_keyword')) {
      context.handle(
        _heisigKeywordMeta,
        heisigKeyword.isAcceptableOrUnknown(
          data['heisig_keyword']!,
          _heisigKeywordMeta,
        ),
      );
    }
    if (data.containsKey('frequency')) {
      context.handle(
        _frequencyMeta,
        frequency.isAcceptableOrUnknown(data['frequency']!, _frequencyMeta),
      );
    }
    if (data.containsKey('unicode')) {
      context.handle(
        _unicodeMeta,
        unicode.isAcceptableOrUnknown(data['unicode']!, _unicodeMeta),
      );
    }
    if (data.containsKey('cached_at')) {
      context.handle(
        _cachedAtMeta,
        cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {character};
  @override
  KanjiEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KanjiEntry(
      character: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}character'],
      )!,
      jlptLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}jlpt_level'],
      ),
      meanings: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meanings'],
      )!,
      meaningsId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meanings_id'],
      ),
      onyomi: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}onyomi'],
      )!,
      kunyomi: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kunyomi'],
      )!,
      nameReadings: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_readings'],
      )!,
      strokeCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stroke_count'],
      )!,
      grade: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}grade'],
      ),
      heisigKeyword: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}heisig_keyword'],
      ),
      frequency: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}frequency'],
      ),
      unicode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unicode'],
      )!,
      cachedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cached_at'],
      )!,
    );
  }

  @override
  $KanjiEntriesTable createAlias(String alias) {
    return $KanjiEntriesTable(attachedDatabase, alias);
  }
}

class KanjiEntry extends DataClass implements Insertable<KanjiEntry> {
  final String character;
  final int? jlptLevel;
  final String meanings;
  final String? meaningsId;
  final String onyomi;
  final String kunyomi;
  final String nameReadings;
  final int strokeCount;
  final int? grade;
  final String? heisigKeyword;
  final int? frequency;
  final String unicode;
  final DateTime cachedAt;
  const KanjiEntry({
    required this.character,
    this.jlptLevel,
    required this.meanings,
    this.meaningsId,
    required this.onyomi,
    required this.kunyomi,
    required this.nameReadings,
    required this.strokeCount,
    this.grade,
    this.heisigKeyword,
    this.frequency,
    required this.unicode,
    required this.cachedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['character'] = Variable<String>(character);
    if (!nullToAbsent || jlptLevel != null) {
      map['jlpt_level'] = Variable<int>(jlptLevel);
    }
    map['meanings'] = Variable<String>(meanings);
    if (!nullToAbsent || meaningsId != null) {
      map['meanings_id'] = Variable<String>(meaningsId);
    }
    map['onyomi'] = Variable<String>(onyomi);
    map['kunyomi'] = Variable<String>(kunyomi);
    map['name_readings'] = Variable<String>(nameReadings);
    map['stroke_count'] = Variable<int>(strokeCount);
    if (!nullToAbsent || grade != null) {
      map['grade'] = Variable<int>(grade);
    }
    if (!nullToAbsent || heisigKeyword != null) {
      map['heisig_keyword'] = Variable<String>(heisigKeyword);
    }
    if (!nullToAbsent || frequency != null) {
      map['frequency'] = Variable<int>(frequency);
    }
    map['unicode'] = Variable<String>(unicode);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  KanjiEntriesCompanion toCompanion(bool nullToAbsent) {
    return KanjiEntriesCompanion(
      character: Value(character),
      jlptLevel: jlptLevel == null && nullToAbsent
          ? const Value.absent()
          : Value(jlptLevel),
      meanings: Value(meanings),
      meaningsId: meaningsId == null && nullToAbsent
          ? const Value.absent()
          : Value(meaningsId),
      onyomi: Value(onyomi),
      kunyomi: Value(kunyomi),
      nameReadings: Value(nameReadings),
      strokeCount: Value(strokeCount),
      grade: grade == null && nullToAbsent
          ? const Value.absent()
          : Value(grade),
      heisigKeyword: heisigKeyword == null && nullToAbsent
          ? const Value.absent()
          : Value(heisigKeyword),
      frequency: frequency == null && nullToAbsent
          ? const Value.absent()
          : Value(frequency),
      unicode: Value(unicode),
      cachedAt: Value(cachedAt),
    );
  }

  factory KanjiEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KanjiEntry(
      character: serializer.fromJson<String>(json['character']),
      jlptLevel: serializer.fromJson<int?>(json['jlptLevel']),
      meanings: serializer.fromJson<String>(json['meanings']),
      meaningsId: serializer.fromJson<String?>(json['meaningsId']),
      onyomi: serializer.fromJson<String>(json['onyomi']),
      kunyomi: serializer.fromJson<String>(json['kunyomi']),
      nameReadings: serializer.fromJson<String>(json['nameReadings']),
      strokeCount: serializer.fromJson<int>(json['strokeCount']),
      grade: serializer.fromJson<int?>(json['grade']),
      heisigKeyword: serializer.fromJson<String?>(json['heisigKeyword']),
      frequency: serializer.fromJson<int?>(json['frequency']),
      unicode: serializer.fromJson<String>(json['unicode']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'character': serializer.toJson<String>(character),
      'jlptLevel': serializer.toJson<int?>(jlptLevel),
      'meanings': serializer.toJson<String>(meanings),
      'meaningsId': serializer.toJson<String?>(meaningsId),
      'onyomi': serializer.toJson<String>(onyomi),
      'kunyomi': serializer.toJson<String>(kunyomi),
      'nameReadings': serializer.toJson<String>(nameReadings),
      'strokeCount': serializer.toJson<int>(strokeCount),
      'grade': serializer.toJson<int?>(grade),
      'heisigKeyword': serializer.toJson<String?>(heisigKeyword),
      'frequency': serializer.toJson<int?>(frequency),
      'unicode': serializer.toJson<String>(unicode),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  KanjiEntry copyWith({
    String? character,
    Value<int?> jlptLevel = const Value.absent(),
    String? meanings,
    Value<String?> meaningsId = const Value.absent(),
    String? onyomi,
    String? kunyomi,
    String? nameReadings,
    int? strokeCount,
    Value<int?> grade = const Value.absent(),
    Value<String?> heisigKeyword = const Value.absent(),
    Value<int?> frequency = const Value.absent(),
    String? unicode,
    DateTime? cachedAt,
  }) => KanjiEntry(
    character: character ?? this.character,
    jlptLevel: jlptLevel.present ? jlptLevel.value : this.jlptLevel,
    meanings: meanings ?? this.meanings,
    meaningsId: meaningsId.present ? meaningsId.value : this.meaningsId,
    onyomi: onyomi ?? this.onyomi,
    kunyomi: kunyomi ?? this.kunyomi,
    nameReadings: nameReadings ?? this.nameReadings,
    strokeCount: strokeCount ?? this.strokeCount,
    grade: grade.present ? grade.value : this.grade,
    heisigKeyword: heisigKeyword.present
        ? heisigKeyword.value
        : this.heisigKeyword,
    frequency: frequency.present ? frequency.value : this.frequency,
    unicode: unicode ?? this.unicode,
    cachedAt: cachedAt ?? this.cachedAt,
  );
  KanjiEntry copyWithCompanion(KanjiEntriesCompanion data) {
    return KanjiEntry(
      character: data.character.present ? data.character.value : this.character,
      jlptLevel: data.jlptLevel.present ? data.jlptLevel.value : this.jlptLevel,
      meanings: data.meanings.present ? data.meanings.value : this.meanings,
      meaningsId: data.meaningsId.present
          ? data.meaningsId.value
          : this.meaningsId,
      onyomi: data.onyomi.present ? data.onyomi.value : this.onyomi,
      kunyomi: data.kunyomi.present ? data.kunyomi.value : this.kunyomi,
      nameReadings: data.nameReadings.present
          ? data.nameReadings.value
          : this.nameReadings,
      strokeCount: data.strokeCount.present
          ? data.strokeCount.value
          : this.strokeCount,
      grade: data.grade.present ? data.grade.value : this.grade,
      heisigKeyword: data.heisigKeyword.present
          ? data.heisigKeyword.value
          : this.heisigKeyword,
      frequency: data.frequency.present ? data.frequency.value : this.frequency,
      unicode: data.unicode.present ? data.unicode.value : this.unicode,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KanjiEntry(')
          ..write('character: $character, ')
          ..write('jlptLevel: $jlptLevel, ')
          ..write('meanings: $meanings, ')
          ..write('meaningsId: $meaningsId, ')
          ..write('onyomi: $onyomi, ')
          ..write('kunyomi: $kunyomi, ')
          ..write('nameReadings: $nameReadings, ')
          ..write('strokeCount: $strokeCount, ')
          ..write('grade: $grade, ')
          ..write('heisigKeyword: $heisigKeyword, ')
          ..write('frequency: $frequency, ')
          ..write('unicode: $unicode, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    character,
    jlptLevel,
    meanings,
    meaningsId,
    onyomi,
    kunyomi,
    nameReadings,
    strokeCount,
    grade,
    heisigKeyword,
    frequency,
    unicode,
    cachedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KanjiEntry &&
          other.character == this.character &&
          other.jlptLevel == this.jlptLevel &&
          other.meanings == this.meanings &&
          other.meaningsId == this.meaningsId &&
          other.onyomi == this.onyomi &&
          other.kunyomi == this.kunyomi &&
          other.nameReadings == this.nameReadings &&
          other.strokeCount == this.strokeCount &&
          other.grade == this.grade &&
          other.heisigKeyword == this.heisigKeyword &&
          other.frequency == this.frequency &&
          other.unicode == this.unicode &&
          other.cachedAt == this.cachedAt);
}

class KanjiEntriesCompanion extends UpdateCompanion<KanjiEntry> {
  final Value<String> character;
  final Value<int?> jlptLevel;
  final Value<String> meanings;
  final Value<String?> meaningsId;
  final Value<String> onyomi;
  final Value<String> kunyomi;
  final Value<String> nameReadings;
  final Value<int> strokeCount;
  final Value<int?> grade;
  final Value<String?> heisigKeyword;
  final Value<int?> frequency;
  final Value<String> unicode;
  final Value<DateTime> cachedAt;
  final Value<int> rowid;
  const KanjiEntriesCompanion({
    this.character = const Value.absent(),
    this.jlptLevel = const Value.absent(),
    this.meanings = const Value.absent(),
    this.meaningsId = const Value.absent(),
    this.onyomi = const Value.absent(),
    this.kunyomi = const Value.absent(),
    this.nameReadings = const Value.absent(),
    this.strokeCount = const Value.absent(),
    this.grade = const Value.absent(),
    this.heisigKeyword = const Value.absent(),
    this.frequency = const Value.absent(),
    this.unicode = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  KanjiEntriesCompanion.insert({
    required String character,
    this.jlptLevel = const Value.absent(),
    required String meanings,
    this.meaningsId = const Value.absent(),
    required String onyomi,
    required String kunyomi,
    this.nameReadings = const Value.absent(),
    this.strokeCount = const Value.absent(),
    this.grade = const Value.absent(),
    this.heisigKeyword = const Value.absent(),
    this.frequency = const Value.absent(),
    this.unicode = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : character = Value(character),
       meanings = Value(meanings),
       onyomi = Value(onyomi),
       kunyomi = Value(kunyomi);
  static Insertable<KanjiEntry> custom({
    Expression<String>? character,
    Expression<int>? jlptLevel,
    Expression<String>? meanings,
    Expression<String>? meaningsId,
    Expression<String>? onyomi,
    Expression<String>? kunyomi,
    Expression<String>? nameReadings,
    Expression<int>? strokeCount,
    Expression<int>? grade,
    Expression<String>? heisigKeyword,
    Expression<int>? frequency,
    Expression<String>? unicode,
    Expression<DateTime>? cachedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (character != null) 'character': character,
      if (jlptLevel != null) 'jlpt_level': jlptLevel,
      if (meanings != null) 'meanings': meanings,
      if (meaningsId != null) 'meanings_id': meaningsId,
      if (onyomi != null) 'onyomi': onyomi,
      if (kunyomi != null) 'kunyomi': kunyomi,
      if (nameReadings != null) 'name_readings': nameReadings,
      if (strokeCount != null) 'stroke_count': strokeCount,
      if (grade != null) 'grade': grade,
      if (heisigKeyword != null) 'heisig_keyword': heisigKeyword,
      if (frequency != null) 'frequency': frequency,
      if (unicode != null) 'unicode': unicode,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  KanjiEntriesCompanion copyWith({
    Value<String>? character,
    Value<int?>? jlptLevel,
    Value<String>? meanings,
    Value<String?>? meaningsId,
    Value<String>? onyomi,
    Value<String>? kunyomi,
    Value<String>? nameReadings,
    Value<int>? strokeCount,
    Value<int?>? grade,
    Value<String?>? heisigKeyword,
    Value<int?>? frequency,
    Value<String>? unicode,
    Value<DateTime>? cachedAt,
    Value<int>? rowid,
  }) {
    return KanjiEntriesCompanion(
      character: character ?? this.character,
      jlptLevel: jlptLevel ?? this.jlptLevel,
      meanings: meanings ?? this.meanings,
      meaningsId: meaningsId ?? this.meaningsId,
      onyomi: onyomi ?? this.onyomi,
      kunyomi: kunyomi ?? this.kunyomi,
      nameReadings: nameReadings ?? this.nameReadings,
      strokeCount: strokeCount ?? this.strokeCount,
      grade: grade ?? this.grade,
      heisigKeyword: heisigKeyword ?? this.heisigKeyword,
      frequency: frequency ?? this.frequency,
      unicode: unicode ?? this.unicode,
      cachedAt: cachedAt ?? this.cachedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (character.present) {
      map['character'] = Variable<String>(character.value);
    }
    if (jlptLevel.present) {
      map['jlpt_level'] = Variable<int>(jlptLevel.value);
    }
    if (meanings.present) {
      map['meanings'] = Variable<String>(meanings.value);
    }
    if (meaningsId.present) {
      map['meanings_id'] = Variable<String>(meaningsId.value);
    }
    if (onyomi.present) {
      map['onyomi'] = Variable<String>(onyomi.value);
    }
    if (kunyomi.present) {
      map['kunyomi'] = Variable<String>(kunyomi.value);
    }
    if (nameReadings.present) {
      map['name_readings'] = Variable<String>(nameReadings.value);
    }
    if (strokeCount.present) {
      map['stroke_count'] = Variable<int>(strokeCount.value);
    }
    if (grade.present) {
      map['grade'] = Variable<int>(grade.value);
    }
    if (heisigKeyword.present) {
      map['heisig_keyword'] = Variable<String>(heisigKeyword.value);
    }
    if (frequency.present) {
      map['frequency'] = Variable<int>(frequency.value);
    }
    if (unicode.present) {
      map['unicode'] = Variable<String>(unicode.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KanjiEntriesCompanion(')
          ..write('character: $character, ')
          ..write('jlptLevel: $jlptLevel, ')
          ..write('meanings: $meanings, ')
          ..write('meaningsId: $meaningsId, ')
          ..write('onyomi: $onyomi, ')
          ..write('kunyomi: $kunyomi, ')
          ..write('nameReadings: $nameReadings, ')
          ..write('strokeCount: $strokeCount, ')
          ..write('grade: $grade, ')
          ..write('heisigKeyword: $heisigKeyword, ')
          ..write('frequency: $frequency, ')
          ..write('unicode: $unicode, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VocabularyEntriesTable extends VocabularyEntries
    with TableInfo<$VocabularyEntriesTable, VocabularyEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VocabularyEntriesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _kanjiCharacterMeta = const VerificationMeta(
    'kanjiCharacter',
  );
  @override
  late final GeneratedColumn<String> kanjiCharacter = GeneratedColumn<String>(
    'kanji_character',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _wordMeta = const VerificationMeta('word');
  @override
  late final GeneratedColumn<String> word = GeneratedColumn<String>(
    'word',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _readingMeta = const VerificationMeta(
    'reading',
  );
  @override
  late final GeneratedColumn<String> reading = GeneratedColumn<String>(
    'reading',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _meaningsMeta = const VerificationMeta(
    'meanings',
  );
  @override
  late final GeneratedColumn<String> meanings = GeneratedColumn<String>(
    'meanings',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _meaningsIdMeta = const VerificationMeta(
    'meaningsId',
  );
  @override
  late final GeneratedColumn<String> meaningsId = GeneratedColumn<String>(
    'meanings_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _prioritiesMeta = const VerificationMeta(
    'priorities',
  );
  @override
  late final GeneratedColumn<String> priorities = GeneratedColumn<String>(
    'priorities',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _cachedAtMeta = const VerificationMeta(
    'cachedAt',
  );
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
    'cached_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    kanjiCharacter,
    word,
    reading,
    meanings,
    meaningsId,
    priorities,
    cachedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vocabulary_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<VocabularyEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('kanji_character')) {
      context.handle(
        _kanjiCharacterMeta,
        kanjiCharacter.isAcceptableOrUnknown(
          data['kanji_character']!,
          _kanjiCharacterMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_kanjiCharacterMeta);
    }
    if (data.containsKey('word')) {
      context.handle(
        _wordMeta,
        word.isAcceptableOrUnknown(data['word']!, _wordMeta),
      );
    } else if (isInserting) {
      context.missing(_wordMeta);
    }
    if (data.containsKey('reading')) {
      context.handle(
        _readingMeta,
        reading.isAcceptableOrUnknown(data['reading']!, _readingMeta),
      );
    } else if (isInserting) {
      context.missing(_readingMeta);
    }
    if (data.containsKey('meanings')) {
      context.handle(
        _meaningsMeta,
        meanings.isAcceptableOrUnknown(data['meanings']!, _meaningsMeta),
      );
    } else if (isInserting) {
      context.missing(_meaningsMeta);
    }
    if (data.containsKey('meanings_id')) {
      context.handle(
        _meaningsIdMeta,
        meaningsId.isAcceptableOrUnknown(data['meanings_id']!, _meaningsIdMeta),
      );
    }
    if (data.containsKey('priorities')) {
      context.handle(
        _prioritiesMeta,
        priorities.isAcceptableOrUnknown(data['priorities']!, _prioritiesMeta),
      );
    }
    if (data.containsKey('cached_at')) {
      context.handle(
        _cachedAtMeta,
        cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VocabularyEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VocabularyEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      kanjiCharacter: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kanji_character'],
      )!,
      word: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}word'],
      )!,
      reading: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reading'],
      )!,
      meanings: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meanings'],
      )!,
      meaningsId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meanings_id'],
      ),
      priorities: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}priorities'],
      )!,
      cachedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cached_at'],
      )!,
    );
  }

  @override
  $VocabularyEntriesTable createAlias(String alias) {
    return $VocabularyEntriesTable(attachedDatabase, alias);
  }
}

class VocabularyEntry extends DataClass implements Insertable<VocabularyEntry> {
  final int id;
  final String kanjiCharacter;
  final String word;
  final String reading;
  final String meanings;
  final String? meaningsId;
  final String priorities;
  final DateTime cachedAt;
  const VocabularyEntry({
    required this.id,
    required this.kanjiCharacter,
    required this.word,
    required this.reading,
    required this.meanings,
    this.meaningsId,
    required this.priorities,
    required this.cachedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['kanji_character'] = Variable<String>(kanjiCharacter);
    map['word'] = Variable<String>(word);
    map['reading'] = Variable<String>(reading);
    map['meanings'] = Variable<String>(meanings);
    if (!nullToAbsent || meaningsId != null) {
      map['meanings_id'] = Variable<String>(meaningsId);
    }
    map['priorities'] = Variable<String>(priorities);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  VocabularyEntriesCompanion toCompanion(bool nullToAbsent) {
    return VocabularyEntriesCompanion(
      id: Value(id),
      kanjiCharacter: Value(kanjiCharacter),
      word: Value(word),
      reading: Value(reading),
      meanings: Value(meanings),
      meaningsId: meaningsId == null && nullToAbsent
          ? const Value.absent()
          : Value(meaningsId),
      priorities: Value(priorities),
      cachedAt: Value(cachedAt),
    );
  }

  factory VocabularyEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VocabularyEntry(
      id: serializer.fromJson<int>(json['id']),
      kanjiCharacter: serializer.fromJson<String>(json['kanjiCharacter']),
      word: serializer.fromJson<String>(json['word']),
      reading: serializer.fromJson<String>(json['reading']),
      meanings: serializer.fromJson<String>(json['meanings']),
      meaningsId: serializer.fromJson<String?>(json['meaningsId']),
      priorities: serializer.fromJson<String>(json['priorities']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'kanjiCharacter': serializer.toJson<String>(kanjiCharacter),
      'word': serializer.toJson<String>(word),
      'reading': serializer.toJson<String>(reading),
      'meanings': serializer.toJson<String>(meanings),
      'meaningsId': serializer.toJson<String?>(meaningsId),
      'priorities': serializer.toJson<String>(priorities),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  VocabularyEntry copyWith({
    int? id,
    String? kanjiCharacter,
    String? word,
    String? reading,
    String? meanings,
    Value<String?> meaningsId = const Value.absent(),
    String? priorities,
    DateTime? cachedAt,
  }) => VocabularyEntry(
    id: id ?? this.id,
    kanjiCharacter: kanjiCharacter ?? this.kanjiCharacter,
    word: word ?? this.word,
    reading: reading ?? this.reading,
    meanings: meanings ?? this.meanings,
    meaningsId: meaningsId.present ? meaningsId.value : this.meaningsId,
    priorities: priorities ?? this.priorities,
    cachedAt: cachedAt ?? this.cachedAt,
  );
  VocabularyEntry copyWithCompanion(VocabularyEntriesCompanion data) {
    return VocabularyEntry(
      id: data.id.present ? data.id.value : this.id,
      kanjiCharacter: data.kanjiCharacter.present
          ? data.kanjiCharacter.value
          : this.kanjiCharacter,
      word: data.word.present ? data.word.value : this.word,
      reading: data.reading.present ? data.reading.value : this.reading,
      meanings: data.meanings.present ? data.meanings.value : this.meanings,
      meaningsId: data.meaningsId.present
          ? data.meaningsId.value
          : this.meaningsId,
      priorities: data.priorities.present
          ? data.priorities.value
          : this.priorities,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VocabularyEntry(')
          ..write('id: $id, ')
          ..write('kanjiCharacter: $kanjiCharacter, ')
          ..write('word: $word, ')
          ..write('reading: $reading, ')
          ..write('meanings: $meanings, ')
          ..write('meaningsId: $meaningsId, ')
          ..write('priorities: $priorities, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    kanjiCharacter,
    word,
    reading,
    meanings,
    meaningsId,
    priorities,
    cachedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VocabularyEntry &&
          other.id == this.id &&
          other.kanjiCharacter == this.kanjiCharacter &&
          other.word == this.word &&
          other.reading == this.reading &&
          other.meanings == this.meanings &&
          other.meaningsId == this.meaningsId &&
          other.priorities == this.priorities &&
          other.cachedAt == this.cachedAt);
}

class VocabularyEntriesCompanion extends UpdateCompanion<VocabularyEntry> {
  final Value<int> id;
  final Value<String> kanjiCharacter;
  final Value<String> word;
  final Value<String> reading;
  final Value<String> meanings;
  final Value<String?> meaningsId;
  final Value<String> priorities;
  final Value<DateTime> cachedAt;
  const VocabularyEntriesCompanion({
    this.id = const Value.absent(),
    this.kanjiCharacter = const Value.absent(),
    this.word = const Value.absent(),
    this.reading = const Value.absent(),
    this.meanings = const Value.absent(),
    this.meaningsId = const Value.absent(),
    this.priorities = const Value.absent(),
    this.cachedAt = const Value.absent(),
  });
  VocabularyEntriesCompanion.insert({
    this.id = const Value.absent(),
    required String kanjiCharacter,
    required String word,
    required String reading,
    required String meanings,
    this.meaningsId = const Value.absent(),
    this.priorities = const Value.absent(),
    this.cachedAt = const Value.absent(),
  }) : kanjiCharacter = Value(kanjiCharacter),
       word = Value(word),
       reading = Value(reading),
       meanings = Value(meanings);
  static Insertable<VocabularyEntry> custom({
    Expression<int>? id,
    Expression<String>? kanjiCharacter,
    Expression<String>? word,
    Expression<String>? reading,
    Expression<String>? meanings,
    Expression<String>? meaningsId,
    Expression<String>? priorities,
    Expression<DateTime>? cachedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kanjiCharacter != null) 'kanji_character': kanjiCharacter,
      if (word != null) 'word': word,
      if (reading != null) 'reading': reading,
      if (meanings != null) 'meanings': meanings,
      if (meaningsId != null) 'meanings_id': meaningsId,
      if (priorities != null) 'priorities': priorities,
      if (cachedAt != null) 'cached_at': cachedAt,
    });
  }

  VocabularyEntriesCompanion copyWith({
    Value<int>? id,
    Value<String>? kanjiCharacter,
    Value<String>? word,
    Value<String>? reading,
    Value<String>? meanings,
    Value<String?>? meaningsId,
    Value<String>? priorities,
    Value<DateTime>? cachedAt,
  }) {
    return VocabularyEntriesCompanion(
      id: id ?? this.id,
      kanjiCharacter: kanjiCharacter ?? this.kanjiCharacter,
      word: word ?? this.word,
      reading: reading ?? this.reading,
      meanings: meanings ?? this.meanings,
      meaningsId: meaningsId ?? this.meaningsId,
      priorities: priorities ?? this.priorities,
      cachedAt: cachedAt ?? this.cachedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (kanjiCharacter.present) {
      map['kanji_character'] = Variable<String>(kanjiCharacter.value);
    }
    if (word.present) {
      map['word'] = Variable<String>(word.value);
    }
    if (reading.present) {
      map['reading'] = Variable<String>(reading.value);
    }
    if (meanings.present) {
      map['meanings'] = Variable<String>(meanings.value);
    }
    if (meaningsId.present) {
      map['meanings_id'] = Variable<String>(meaningsId.value);
    }
    if (priorities.present) {
      map['priorities'] = Variable<String>(priorities.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VocabularyEntriesCompanion(')
          ..write('id: $id, ')
          ..write('kanjiCharacter: $kanjiCharacter, ')
          ..write('word: $word, ')
          ..write('reading: $reading, ')
          ..write('meanings: $meanings, ')
          ..write('meaningsId: $meaningsId, ')
          ..write('priorities: $priorities, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }
}

class $UserKanjiProgressEntriesTable extends UserKanjiProgressEntries
    with TableInfo<$UserKanjiProgressEntriesTable, UserKanjiProgressEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserKanjiProgressEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _kanjiCharacterMeta = const VerificationMeta(
    'kanjiCharacter',
  );
  @override
  late final GeneratedColumn<String> kanjiCharacter = GeneratedColumn<String>(
    'kanji_character',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('unseen'),
  );
  static const VerificationMeta _correctCountMeta = const VerificationMeta(
    'correctCount',
  );
  @override
  late final GeneratedColumn<int> correctCount = GeneratedColumn<int>(
    'correct_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _wrongCountMeta = const VerificationMeta(
    'wrongCount',
  );
  @override
  late final GeneratedColumn<int> wrongCount = GeneratedColumn<int>(
    'wrong_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _easeMeta = const VerificationMeta('ease');
  @override
  late final GeneratedColumn<double> ease = GeneratedColumn<double>(
    'ease',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(2.5),
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
  static const VerificationMeta _lastReviewedAtMeta = const VerificationMeta(
    'lastReviewedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastReviewedAt =
      GeneratedColumn<DateTime>(
        'last_reviewed_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _nextReviewAtMeta = const VerificationMeta(
    'nextReviewAt',
  );
  @override
  late final GeneratedColumn<DateTime> nextReviewAt = GeneratedColumn<DateTime>(
    'next_review_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _firstLearnedAtMeta = const VerificationMeta(
    'firstLearnedAt',
  );
  @override
  late final GeneratedColumn<DateTime> firstLearnedAt =
      GeneratedColumn<DateTime>(
        'first_learned_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    kanjiCharacter,
    status,
    correctCount,
    wrongCount,
    ease,
    intervalDays,
    repetitions,
    lastReviewedAt,
    nextReviewAt,
    firstLearnedAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_kanji_progress_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserKanjiProgressEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('kanji_character')) {
      context.handle(
        _kanjiCharacterMeta,
        kanjiCharacter.isAcceptableOrUnknown(
          data['kanji_character']!,
          _kanjiCharacterMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_kanjiCharacterMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('correct_count')) {
      context.handle(
        _correctCountMeta,
        correctCount.isAcceptableOrUnknown(
          data['correct_count']!,
          _correctCountMeta,
        ),
      );
    }
    if (data.containsKey('wrong_count')) {
      context.handle(
        _wrongCountMeta,
        wrongCount.isAcceptableOrUnknown(data['wrong_count']!, _wrongCountMeta),
      );
    }
    if (data.containsKey('ease')) {
      context.handle(
        _easeMeta,
        ease.isAcceptableOrUnknown(data['ease']!, _easeMeta),
      );
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
    if (data.containsKey('last_reviewed_at')) {
      context.handle(
        _lastReviewedAtMeta,
        lastReviewedAt.isAcceptableOrUnknown(
          data['last_reviewed_at']!,
          _lastReviewedAtMeta,
        ),
      );
    }
    if (data.containsKey('next_review_at')) {
      context.handle(
        _nextReviewAtMeta,
        nextReviewAt.isAcceptableOrUnknown(
          data['next_review_at']!,
          _nextReviewAtMeta,
        ),
      );
    }
    if (data.containsKey('first_learned_at')) {
      context.handle(
        _firstLearnedAtMeta,
        firstLearnedAt.isAcceptableOrUnknown(
          data['first_learned_at']!,
          _firstLearnedAtMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {kanjiCharacter};
  @override
  UserKanjiProgressEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserKanjiProgressEntry(
      kanjiCharacter: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kanji_character'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      correctCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}correct_count'],
      )!,
      wrongCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}wrong_count'],
      )!,
      ease: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}ease'],
      )!,
      intervalDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}interval_days'],
      )!,
      repetitions: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}repetitions'],
      )!,
      lastReviewedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_reviewed_at'],
      ),
      nextReviewAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_review_at'],
      ),
      firstLearnedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}first_learned_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $UserKanjiProgressEntriesTable createAlias(String alias) {
    return $UserKanjiProgressEntriesTable(attachedDatabase, alias);
  }
}

class UserKanjiProgressEntry extends DataClass
    implements Insertable<UserKanjiProgressEntry> {
  final String kanjiCharacter;
  final String status;
  final int correctCount;
  final int wrongCount;
  final double ease;
  final int intervalDays;
  final int repetitions;
  final DateTime? lastReviewedAt;
  final DateTime? nextReviewAt;
  final DateTime? firstLearnedAt;
  final DateTime updatedAt;
  const UserKanjiProgressEntry({
    required this.kanjiCharacter,
    required this.status,
    required this.correctCount,
    required this.wrongCount,
    required this.ease,
    required this.intervalDays,
    required this.repetitions,
    this.lastReviewedAt,
    this.nextReviewAt,
    this.firstLearnedAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['kanji_character'] = Variable<String>(kanjiCharacter);
    map['status'] = Variable<String>(status);
    map['correct_count'] = Variable<int>(correctCount);
    map['wrong_count'] = Variable<int>(wrongCount);
    map['ease'] = Variable<double>(ease);
    map['interval_days'] = Variable<int>(intervalDays);
    map['repetitions'] = Variable<int>(repetitions);
    if (!nullToAbsent || lastReviewedAt != null) {
      map['last_reviewed_at'] = Variable<DateTime>(lastReviewedAt);
    }
    if (!nullToAbsent || nextReviewAt != null) {
      map['next_review_at'] = Variable<DateTime>(nextReviewAt);
    }
    if (!nullToAbsent || firstLearnedAt != null) {
      map['first_learned_at'] = Variable<DateTime>(firstLearnedAt);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  UserKanjiProgressEntriesCompanion toCompanion(bool nullToAbsent) {
    return UserKanjiProgressEntriesCompanion(
      kanjiCharacter: Value(kanjiCharacter),
      status: Value(status),
      correctCount: Value(correctCount),
      wrongCount: Value(wrongCount),
      ease: Value(ease),
      intervalDays: Value(intervalDays),
      repetitions: Value(repetitions),
      lastReviewedAt: lastReviewedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReviewedAt),
      nextReviewAt: nextReviewAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextReviewAt),
      firstLearnedAt: firstLearnedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(firstLearnedAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory UserKanjiProgressEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserKanjiProgressEntry(
      kanjiCharacter: serializer.fromJson<String>(json['kanjiCharacter']),
      status: serializer.fromJson<String>(json['status']),
      correctCount: serializer.fromJson<int>(json['correctCount']),
      wrongCount: serializer.fromJson<int>(json['wrongCount']),
      ease: serializer.fromJson<double>(json['ease']),
      intervalDays: serializer.fromJson<int>(json['intervalDays']),
      repetitions: serializer.fromJson<int>(json['repetitions']),
      lastReviewedAt: serializer.fromJson<DateTime?>(json['lastReviewedAt']),
      nextReviewAt: serializer.fromJson<DateTime?>(json['nextReviewAt']),
      firstLearnedAt: serializer.fromJson<DateTime?>(json['firstLearnedAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'kanjiCharacter': serializer.toJson<String>(kanjiCharacter),
      'status': serializer.toJson<String>(status),
      'correctCount': serializer.toJson<int>(correctCount),
      'wrongCount': serializer.toJson<int>(wrongCount),
      'ease': serializer.toJson<double>(ease),
      'intervalDays': serializer.toJson<int>(intervalDays),
      'repetitions': serializer.toJson<int>(repetitions),
      'lastReviewedAt': serializer.toJson<DateTime?>(lastReviewedAt),
      'nextReviewAt': serializer.toJson<DateTime?>(nextReviewAt),
      'firstLearnedAt': serializer.toJson<DateTime?>(firstLearnedAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  UserKanjiProgressEntry copyWith({
    String? kanjiCharacter,
    String? status,
    int? correctCount,
    int? wrongCount,
    double? ease,
    int? intervalDays,
    int? repetitions,
    Value<DateTime?> lastReviewedAt = const Value.absent(),
    Value<DateTime?> nextReviewAt = const Value.absent(),
    Value<DateTime?> firstLearnedAt = const Value.absent(),
    DateTime? updatedAt,
  }) => UserKanjiProgressEntry(
    kanjiCharacter: kanjiCharacter ?? this.kanjiCharacter,
    status: status ?? this.status,
    correctCount: correctCount ?? this.correctCount,
    wrongCount: wrongCount ?? this.wrongCount,
    ease: ease ?? this.ease,
    intervalDays: intervalDays ?? this.intervalDays,
    repetitions: repetitions ?? this.repetitions,
    lastReviewedAt: lastReviewedAt.present
        ? lastReviewedAt.value
        : this.lastReviewedAt,
    nextReviewAt: nextReviewAt.present ? nextReviewAt.value : this.nextReviewAt,
    firstLearnedAt: firstLearnedAt.present
        ? firstLearnedAt.value
        : this.firstLearnedAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  UserKanjiProgressEntry copyWithCompanion(
    UserKanjiProgressEntriesCompanion data,
  ) {
    return UserKanjiProgressEntry(
      kanjiCharacter: data.kanjiCharacter.present
          ? data.kanjiCharacter.value
          : this.kanjiCharacter,
      status: data.status.present ? data.status.value : this.status,
      correctCount: data.correctCount.present
          ? data.correctCount.value
          : this.correctCount,
      wrongCount: data.wrongCount.present
          ? data.wrongCount.value
          : this.wrongCount,
      ease: data.ease.present ? data.ease.value : this.ease,
      intervalDays: data.intervalDays.present
          ? data.intervalDays.value
          : this.intervalDays,
      repetitions: data.repetitions.present
          ? data.repetitions.value
          : this.repetitions,
      lastReviewedAt: data.lastReviewedAt.present
          ? data.lastReviewedAt.value
          : this.lastReviewedAt,
      nextReviewAt: data.nextReviewAt.present
          ? data.nextReviewAt.value
          : this.nextReviewAt,
      firstLearnedAt: data.firstLearnedAt.present
          ? data.firstLearnedAt.value
          : this.firstLearnedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserKanjiProgressEntry(')
          ..write('kanjiCharacter: $kanjiCharacter, ')
          ..write('status: $status, ')
          ..write('correctCount: $correctCount, ')
          ..write('wrongCount: $wrongCount, ')
          ..write('ease: $ease, ')
          ..write('intervalDays: $intervalDays, ')
          ..write('repetitions: $repetitions, ')
          ..write('lastReviewedAt: $lastReviewedAt, ')
          ..write('nextReviewAt: $nextReviewAt, ')
          ..write('firstLearnedAt: $firstLearnedAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    kanjiCharacter,
    status,
    correctCount,
    wrongCount,
    ease,
    intervalDays,
    repetitions,
    lastReviewedAt,
    nextReviewAt,
    firstLearnedAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserKanjiProgressEntry &&
          other.kanjiCharacter == this.kanjiCharacter &&
          other.status == this.status &&
          other.correctCount == this.correctCount &&
          other.wrongCount == this.wrongCount &&
          other.ease == this.ease &&
          other.intervalDays == this.intervalDays &&
          other.repetitions == this.repetitions &&
          other.lastReviewedAt == this.lastReviewedAt &&
          other.nextReviewAt == this.nextReviewAt &&
          other.firstLearnedAt == this.firstLearnedAt &&
          other.updatedAt == this.updatedAt);
}

class UserKanjiProgressEntriesCompanion
    extends UpdateCompanion<UserKanjiProgressEntry> {
  final Value<String> kanjiCharacter;
  final Value<String> status;
  final Value<int> correctCount;
  final Value<int> wrongCount;
  final Value<double> ease;
  final Value<int> intervalDays;
  final Value<int> repetitions;
  final Value<DateTime?> lastReviewedAt;
  final Value<DateTime?> nextReviewAt;
  final Value<DateTime?> firstLearnedAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const UserKanjiProgressEntriesCompanion({
    this.kanjiCharacter = const Value.absent(),
    this.status = const Value.absent(),
    this.correctCount = const Value.absent(),
    this.wrongCount = const Value.absent(),
    this.ease = const Value.absent(),
    this.intervalDays = const Value.absent(),
    this.repetitions = const Value.absent(),
    this.lastReviewedAt = const Value.absent(),
    this.nextReviewAt = const Value.absent(),
    this.firstLearnedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserKanjiProgressEntriesCompanion.insert({
    required String kanjiCharacter,
    this.status = const Value.absent(),
    this.correctCount = const Value.absent(),
    this.wrongCount = const Value.absent(),
    this.ease = const Value.absent(),
    this.intervalDays = const Value.absent(),
    this.repetitions = const Value.absent(),
    this.lastReviewedAt = const Value.absent(),
    this.nextReviewAt = const Value.absent(),
    this.firstLearnedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : kanjiCharacter = Value(kanjiCharacter);
  static Insertable<UserKanjiProgressEntry> custom({
    Expression<String>? kanjiCharacter,
    Expression<String>? status,
    Expression<int>? correctCount,
    Expression<int>? wrongCount,
    Expression<double>? ease,
    Expression<int>? intervalDays,
    Expression<int>? repetitions,
    Expression<DateTime>? lastReviewedAt,
    Expression<DateTime>? nextReviewAt,
    Expression<DateTime>? firstLearnedAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (kanjiCharacter != null) 'kanji_character': kanjiCharacter,
      if (status != null) 'status': status,
      if (correctCount != null) 'correct_count': correctCount,
      if (wrongCount != null) 'wrong_count': wrongCount,
      if (ease != null) 'ease': ease,
      if (intervalDays != null) 'interval_days': intervalDays,
      if (repetitions != null) 'repetitions': repetitions,
      if (lastReviewedAt != null) 'last_reviewed_at': lastReviewedAt,
      if (nextReviewAt != null) 'next_review_at': nextReviewAt,
      if (firstLearnedAt != null) 'first_learned_at': firstLearnedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserKanjiProgressEntriesCompanion copyWith({
    Value<String>? kanjiCharacter,
    Value<String>? status,
    Value<int>? correctCount,
    Value<int>? wrongCount,
    Value<double>? ease,
    Value<int>? intervalDays,
    Value<int>? repetitions,
    Value<DateTime?>? lastReviewedAt,
    Value<DateTime?>? nextReviewAt,
    Value<DateTime?>? firstLearnedAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return UserKanjiProgressEntriesCompanion(
      kanjiCharacter: kanjiCharacter ?? this.kanjiCharacter,
      status: status ?? this.status,
      correctCount: correctCount ?? this.correctCount,
      wrongCount: wrongCount ?? this.wrongCount,
      ease: ease ?? this.ease,
      intervalDays: intervalDays ?? this.intervalDays,
      repetitions: repetitions ?? this.repetitions,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      nextReviewAt: nextReviewAt ?? this.nextReviewAt,
      firstLearnedAt: firstLearnedAt ?? this.firstLearnedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (kanjiCharacter.present) {
      map['kanji_character'] = Variable<String>(kanjiCharacter.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (correctCount.present) {
      map['correct_count'] = Variable<int>(correctCount.value);
    }
    if (wrongCount.present) {
      map['wrong_count'] = Variable<int>(wrongCount.value);
    }
    if (ease.present) {
      map['ease'] = Variable<double>(ease.value);
    }
    if (intervalDays.present) {
      map['interval_days'] = Variable<int>(intervalDays.value);
    }
    if (repetitions.present) {
      map['repetitions'] = Variable<int>(repetitions.value);
    }
    if (lastReviewedAt.present) {
      map['last_reviewed_at'] = Variable<DateTime>(lastReviewedAt.value);
    }
    if (nextReviewAt.present) {
      map['next_review_at'] = Variable<DateTime>(nextReviewAt.value);
    }
    if (firstLearnedAt.present) {
      map['first_learned_at'] = Variable<DateTime>(firstLearnedAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserKanjiProgressEntriesCompanion(')
          ..write('kanjiCharacter: $kanjiCharacter, ')
          ..write('status: $status, ')
          ..write('correctCount: $correctCount, ')
          ..write('wrongCount: $wrongCount, ')
          ..write('ease: $ease, ')
          ..write('intervalDays: $intervalDays, ')
          ..write('repetitions: $repetitions, ')
          ..write('lastReviewedAt: $lastReviewedAt, ')
          ..write('nextReviewAt: $nextReviewAt, ')
          ..write('firstLearnedAt: $firstLearnedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DailyProgressEntriesTable extends DailyProgressEntries
    with TableInfo<$DailyProgressEntriesTable, DailyProgressEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyProgressEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _newKanjiCountMeta = const VerificationMeta(
    'newKanjiCount',
  );
  @override
  late final GeneratedColumn<int> newKanjiCount = GeneratedColumn<int>(
    'new_kanji_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _reviewedKanjiCountMeta =
      const VerificationMeta('reviewedKanjiCount');
  @override
  late final GeneratedColumn<int> reviewedKanjiCount = GeneratedColumn<int>(
    'reviewed_kanji_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _correctAnswersMeta = const VerificationMeta(
    'correctAnswers',
  );
  @override
  late final GeneratedColumn<int> correctAnswers = GeneratedColumn<int>(
    'correct_answers',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _wrongAnswersMeta = const VerificationMeta(
    'wrongAnswers',
  );
  @override
  late final GeneratedColumn<int> wrongAnswers = GeneratedColumn<int>(
    'wrong_answers',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _dailyGoalMeta = const VerificationMeta(
    'dailyGoal',
  );
  @override
  late final GeneratedColumn<int> dailyGoal = GeneratedColumn<int>(
    'daily_goal',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(10),
  );
  static const VerificationMeta _goalCompletedMeta = const VerificationMeta(
    'goalCompleted',
  );
  @override
  late final GeneratedColumn<bool> goalCompleted = GeneratedColumn<bool>(
    'goal_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("goal_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    date,
    newKanjiCount,
    reviewedKanjiCount,
    correctAnswers,
    wrongAnswers,
    dailyGoal,
    goalCompleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_progress_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailyProgressEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('new_kanji_count')) {
      context.handle(
        _newKanjiCountMeta,
        newKanjiCount.isAcceptableOrUnknown(
          data['new_kanji_count']!,
          _newKanjiCountMeta,
        ),
      );
    }
    if (data.containsKey('reviewed_kanji_count')) {
      context.handle(
        _reviewedKanjiCountMeta,
        reviewedKanjiCount.isAcceptableOrUnknown(
          data['reviewed_kanji_count']!,
          _reviewedKanjiCountMeta,
        ),
      );
    }
    if (data.containsKey('correct_answers')) {
      context.handle(
        _correctAnswersMeta,
        correctAnswers.isAcceptableOrUnknown(
          data['correct_answers']!,
          _correctAnswersMeta,
        ),
      );
    }
    if (data.containsKey('wrong_answers')) {
      context.handle(
        _wrongAnswersMeta,
        wrongAnswers.isAcceptableOrUnknown(
          data['wrong_answers']!,
          _wrongAnswersMeta,
        ),
      );
    }
    if (data.containsKey('daily_goal')) {
      context.handle(
        _dailyGoalMeta,
        dailyGoal.isAcceptableOrUnknown(data['daily_goal']!, _dailyGoalMeta),
      );
    }
    if (data.containsKey('goal_completed')) {
      context.handle(
        _goalCompletedMeta,
        goalCompleted.isAcceptableOrUnknown(
          data['goal_completed']!,
          _goalCompletedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {date};
  @override
  DailyProgressEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyProgressEntry(
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      newKanjiCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}new_kanji_count'],
      )!,
      reviewedKanjiCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reviewed_kanji_count'],
      )!,
      correctAnswers: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}correct_answers'],
      )!,
      wrongAnswers: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}wrong_answers'],
      )!,
      dailyGoal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}daily_goal'],
      )!,
      goalCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}goal_completed'],
      )!,
    );
  }

  @override
  $DailyProgressEntriesTable createAlias(String alias) {
    return $DailyProgressEntriesTable(attachedDatabase, alias);
  }
}

class DailyProgressEntry extends DataClass
    implements Insertable<DailyProgressEntry> {
  final String date;
  final int newKanjiCount;
  final int reviewedKanjiCount;
  final int correctAnswers;
  final int wrongAnswers;
  final int dailyGoal;
  final bool goalCompleted;
  const DailyProgressEntry({
    required this.date,
    required this.newKanjiCount,
    required this.reviewedKanjiCount,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.dailyGoal,
    required this.goalCompleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['date'] = Variable<String>(date);
    map['new_kanji_count'] = Variable<int>(newKanjiCount);
    map['reviewed_kanji_count'] = Variable<int>(reviewedKanjiCount);
    map['correct_answers'] = Variable<int>(correctAnswers);
    map['wrong_answers'] = Variable<int>(wrongAnswers);
    map['daily_goal'] = Variable<int>(dailyGoal);
    map['goal_completed'] = Variable<bool>(goalCompleted);
    return map;
  }

  DailyProgressEntriesCompanion toCompanion(bool nullToAbsent) {
    return DailyProgressEntriesCompanion(
      date: Value(date),
      newKanjiCount: Value(newKanjiCount),
      reviewedKanjiCount: Value(reviewedKanjiCount),
      correctAnswers: Value(correctAnswers),
      wrongAnswers: Value(wrongAnswers),
      dailyGoal: Value(dailyGoal),
      goalCompleted: Value(goalCompleted),
    );
  }

  factory DailyProgressEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyProgressEntry(
      date: serializer.fromJson<String>(json['date']),
      newKanjiCount: serializer.fromJson<int>(json['newKanjiCount']),
      reviewedKanjiCount: serializer.fromJson<int>(json['reviewedKanjiCount']),
      correctAnswers: serializer.fromJson<int>(json['correctAnswers']),
      wrongAnswers: serializer.fromJson<int>(json['wrongAnswers']),
      dailyGoal: serializer.fromJson<int>(json['dailyGoal']),
      goalCompleted: serializer.fromJson<bool>(json['goalCompleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'date': serializer.toJson<String>(date),
      'newKanjiCount': serializer.toJson<int>(newKanjiCount),
      'reviewedKanjiCount': serializer.toJson<int>(reviewedKanjiCount),
      'correctAnswers': serializer.toJson<int>(correctAnswers),
      'wrongAnswers': serializer.toJson<int>(wrongAnswers),
      'dailyGoal': serializer.toJson<int>(dailyGoal),
      'goalCompleted': serializer.toJson<bool>(goalCompleted),
    };
  }

  DailyProgressEntry copyWith({
    String? date,
    int? newKanjiCount,
    int? reviewedKanjiCount,
    int? correctAnswers,
    int? wrongAnswers,
    int? dailyGoal,
    bool? goalCompleted,
  }) => DailyProgressEntry(
    date: date ?? this.date,
    newKanjiCount: newKanjiCount ?? this.newKanjiCount,
    reviewedKanjiCount: reviewedKanjiCount ?? this.reviewedKanjiCount,
    correctAnswers: correctAnswers ?? this.correctAnswers,
    wrongAnswers: wrongAnswers ?? this.wrongAnswers,
    dailyGoal: dailyGoal ?? this.dailyGoal,
    goalCompleted: goalCompleted ?? this.goalCompleted,
  );
  DailyProgressEntry copyWithCompanion(DailyProgressEntriesCompanion data) {
    return DailyProgressEntry(
      date: data.date.present ? data.date.value : this.date,
      newKanjiCount: data.newKanjiCount.present
          ? data.newKanjiCount.value
          : this.newKanjiCount,
      reviewedKanjiCount: data.reviewedKanjiCount.present
          ? data.reviewedKanjiCount.value
          : this.reviewedKanjiCount,
      correctAnswers: data.correctAnswers.present
          ? data.correctAnswers.value
          : this.correctAnswers,
      wrongAnswers: data.wrongAnswers.present
          ? data.wrongAnswers.value
          : this.wrongAnswers,
      dailyGoal: data.dailyGoal.present ? data.dailyGoal.value : this.dailyGoal,
      goalCompleted: data.goalCompleted.present
          ? data.goalCompleted.value
          : this.goalCompleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyProgressEntry(')
          ..write('date: $date, ')
          ..write('newKanjiCount: $newKanjiCount, ')
          ..write('reviewedKanjiCount: $reviewedKanjiCount, ')
          ..write('correctAnswers: $correctAnswers, ')
          ..write('wrongAnswers: $wrongAnswers, ')
          ..write('dailyGoal: $dailyGoal, ')
          ..write('goalCompleted: $goalCompleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    date,
    newKanjiCount,
    reviewedKanjiCount,
    correctAnswers,
    wrongAnswers,
    dailyGoal,
    goalCompleted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyProgressEntry &&
          other.date == this.date &&
          other.newKanjiCount == this.newKanjiCount &&
          other.reviewedKanjiCount == this.reviewedKanjiCount &&
          other.correctAnswers == this.correctAnswers &&
          other.wrongAnswers == this.wrongAnswers &&
          other.dailyGoal == this.dailyGoal &&
          other.goalCompleted == this.goalCompleted);
}

class DailyProgressEntriesCompanion
    extends UpdateCompanion<DailyProgressEntry> {
  final Value<String> date;
  final Value<int> newKanjiCount;
  final Value<int> reviewedKanjiCount;
  final Value<int> correctAnswers;
  final Value<int> wrongAnswers;
  final Value<int> dailyGoal;
  final Value<bool> goalCompleted;
  final Value<int> rowid;
  const DailyProgressEntriesCompanion({
    this.date = const Value.absent(),
    this.newKanjiCount = const Value.absent(),
    this.reviewedKanjiCount = const Value.absent(),
    this.correctAnswers = const Value.absent(),
    this.wrongAnswers = const Value.absent(),
    this.dailyGoal = const Value.absent(),
    this.goalCompleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DailyProgressEntriesCompanion.insert({
    required String date,
    this.newKanjiCount = const Value.absent(),
    this.reviewedKanjiCount = const Value.absent(),
    this.correctAnswers = const Value.absent(),
    this.wrongAnswers = const Value.absent(),
    this.dailyGoal = const Value.absent(),
    this.goalCompleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : date = Value(date);
  static Insertable<DailyProgressEntry> custom({
    Expression<String>? date,
    Expression<int>? newKanjiCount,
    Expression<int>? reviewedKanjiCount,
    Expression<int>? correctAnswers,
    Expression<int>? wrongAnswers,
    Expression<int>? dailyGoal,
    Expression<bool>? goalCompleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (date != null) 'date': date,
      if (newKanjiCount != null) 'new_kanji_count': newKanjiCount,
      if (reviewedKanjiCount != null)
        'reviewed_kanji_count': reviewedKanjiCount,
      if (correctAnswers != null) 'correct_answers': correctAnswers,
      if (wrongAnswers != null) 'wrong_answers': wrongAnswers,
      if (dailyGoal != null) 'daily_goal': dailyGoal,
      if (goalCompleted != null) 'goal_completed': goalCompleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DailyProgressEntriesCompanion copyWith({
    Value<String>? date,
    Value<int>? newKanjiCount,
    Value<int>? reviewedKanjiCount,
    Value<int>? correctAnswers,
    Value<int>? wrongAnswers,
    Value<int>? dailyGoal,
    Value<bool>? goalCompleted,
    Value<int>? rowid,
  }) {
    return DailyProgressEntriesCompanion(
      date: date ?? this.date,
      newKanjiCount: newKanjiCount ?? this.newKanjiCount,
      reviewedKanjiCount: reviewedKanjiCount ?? this.reviewedKanjiCount,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      wrongAnswers: wrongAnswers ?? this.wrongAnswers,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      goalCompleted: goalCompleted ?? this.goalCompleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (newKanjiCount.present) {
      map['new_kanji_count'] = Variable<int>(newKanjiCount.value);
    }
    if (reviewedKanjiCount.present) {
      map['reviewed_kanji_count'] = Variable<int>(reviewedKanjiCount.value);
    }
    if (correctAnswers.present) {
      map['correct_answers'] = Variable<int>(correctAnswers.value);
    }
    if (wrongAnswers.present) {
      map['wrong_answers'] = Variable<int>(wrongAnswers.value);
    }
    if (dailyGoal.present) {
      map['daily_goal'] = Variable<int>(dailyGoal.value);
    }
    if (goalCompleted.present) {
      map['goal_completed'] = Variable<bool>(goalCompleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyProgressEntriesCompanion(')
          ..write('date: $date, ')
          ..write('newKanjiCount: $newKanjiCount, ')
          ..write('reviewedKanjiCount: $reviewedKanjiCount, ')
          ..write('correctAnswers: $correctAnswers, ')
          ..write('wrongAnswers: $wrongAnswers, ')
          ..write('dailyGoal: $dailyGoal, ')
          ..write('goalCompleted: $goalCompleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $QuizResultEntriesTable extends QuizResultEntries
    with TableInfo<$QuizResultEntriesTable, QuizResultEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuizResultEntriesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _jlptLevelMeta = const VerificationMeta(
    'jlptLevel',
  );
  @override
  late final GeneratedColumn<int> jlptLevel = GeneratedColumn<int>(
    'jlpt_level',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _quizTypeMeta = const VerificationMeta(
    'quizType',
  );
  @override
  late final GeneratedColumn<String> quizType = GeneratedColumn<String>(
    'quiz_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalQuestionsMeta = const VerificationMeta(
    'totalQuestions',
  );
  @override
  late final GeneratedColumn<int> totalQuestions = GeneratedColumn<int>(
    'total_questions',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _correctAnswersMeta = const VerificationMeta(
    'correctAnswers',
  );
  @override
  late final GeneratedColumn<int> correctAnswers = GeneratedColumn<int>(
    'correct_answers',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accuracyMeta = const VerificationMeta(
    'accuracy',
  );
  @override
  late final GeneratedColumn<double> accuracy = GeneratedColumn<double>(
    'accuracy',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    date,
    jlptLevel,
    quizType,
    totalQuestions,
    correctAnswers,
    accuracy,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'quiz_result_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<QuizResultEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    }
    if (data.containsKey('jlpt_level')) {
      context.handle(
        _jlptLevelMeta,
        jlptLevel.isAcceptableOrUnknown(data['jlpt_level']!, _jlptLevelMeta),
      );
    }
    if (data.containsKey('quiz_type')) {
      context.handle(
        _quizTypeMeta,
        quizType.isAcceptableOrUnknown(data['quiz_type']!, _quizTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_quizTypeMeta);
    }
    if (data.containsKey('total_questions')) {
      context.handle(
        _totalQuestionsMeta,
        totalQuestions.isAcceptableOrUnknown(
          data['total_questions']!,
          _totalQuestionsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalQuestionsMeta);
    }
    if (data.containsKey('correct_answers')) {
      context.handle(
        _correctAnswersMeta,
        correctAnswers.isAcceptableOrUnknown(
          data['correct_answers']!,
          _correctAnswersMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_correctAnswersMeta);
    }
    if (data.containsKey('accuracy')) {
      context.handle(
        _accuracyMeta,
        accuracy.isAcceptableOrUnknown(data['accuracy']!, _accuracyMeta),
      );
    } else if (isInserting) {
      context.missing(_accuracyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QuizResultEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QuizResultEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      jlptLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}jlpt_level'],
      ),
      quizType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quiz_type'],
      )!,
      totalQuestions: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_questions'],
      )!,
      correctAnswers: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}correct_answers'],
      )!,
      accuracy: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}accuracy'],
      )!,
    );
  }

  @override
  $QuizResultEntriesTable createAlias(String alias) {
    return $QuizResultEntriesTable(attachedDatabase, alias);
  }
}

class QuizResultEntry extends DataClass implements Insertable<QuizResultEntry> {
  final int id;
  final DateTime date;
  final int? jlptLevel;
  final String quizType;
  final int totalQuestions;
  final int correctAnswers;
  final double accuracy;
  const QuizResultEntry({
    required this.id,
    required this.date,
    this.jlptLevel,
    required this.quizType,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.accuracy,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || jlptLevel != null) {
      map['jlpt_level'] = Variable<int>(jlptLevel);
    }
    map['quiz_type'] = Variable<String>(quizType);
    map['total_questions'] = Variable<int>(totalQuestions);
    map['correct_answers'] = Variable<int>(correctAnswers);
    map['accuracy'] = Variable<double>(accuracy);
    return map;
  }

  QuizResultEntriesCompanion toCompanion(bool nullToAbsent) {
    return QuizResultEntriesCompanion(
      id: Value(id),
      date: Value(date),
      jlptLevel: jlptLevel == null && nullToAbsent
          ? const Value.absent()
          : Value(jlptLevel),
      quizType: Value(quizType),
      totalQuestions: Value(totalQuestions),
      correctAnswers: Value(correctAnswers),
      accuracy: Value(accuracy),
    );
  }

  factory QuizResultEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QuizResultEntry(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      jlptLevel: serializer.fromJson<int?>(json['jlptLevel']),
      quizType: serializer.fromJson<String>(json['quizType']),
      totalQuestions: serializer.fromJson<int>(json['totalQuestions']),
      correctAnswers: serializer.fromJson<int>(json['correctAnswers']),
      accuracy: serializer.fromJson<double>(json['accuracy']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<DateTime>(date),
      'jlptLevel': serializer.toJson<int?>(jlptLevel),
      'quizType': serializer.toJson<String>(quizType),
      'totalQuestions': serializer.toJson<int>(totalQuestions),
      'correctAnswers': serializer.toJson<int>(correctAnswers),
      'accuracy': serializer.toJson<double>(accuracy),
    };
  }

  QuizResultEntry copyWith({
    int? id,
    DateTime? date,
    Value<int?> jlptLevel = const Value.absent(),
    String? quizType,
    int? totalQuestions,
    int? correctAnswers,
    double? accuracy,
  }) => QuizResultEntry(
    id: id ?? this.id,
    date: date ?? this.date,
    jlptLevel: jlptLevel.present ? jlptLevel.value : this.jlptLevel,
    quizType: quizType ?? this.quizType,
    totalQuestions: totalQuestions ?? this.totalQuestions,
    correctAnswers: correctAnswers ?? this.correctAnswers,
    accuracy: accuracy ?? this.accuracy,
  );
  QuizResultEntry copyWithCompanion(QuizResultEntriesCompanion data) {
    return QuizResultEntry(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      jlptLevel: data.jlptLevel.present ? data.jlptLevel.value : this.jlptLevel,
      quizType: data.quizType.present ? data.quizType.value : this.quizType,
      totalQuestions: data.totalQuestions.present
          ? data.totalQuestions.value
          : this.totalQuestions,
      correctAnswers: data.correctAnswers.present
          ? data.correctAnswers.value
          : this.correctAnswers,
      accuracy: data.accuracy.present ? data.accuracy.value : this.accuracy,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QuizResultEntry(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('jlptLevel: $jlptLevel, ')
          ..write('quizType: $quizType, ')
          ..write('totalQuestions: $totalQuestions, ')
          ..write('correctAnswers: $correctAnswers, ')
          ..write('accuracy: $accuracy')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    date,
    jlptLevel,
    quizType,
    totalQuestions,
    correctAnswers,
    accuracy,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuizResultEntry &&
          other.id == this.id &&
          other.date == this.date &&
          other.jlptLevel == this.jlptLevel &&
          other.quizType == this.quizType &&
          other.totalQuestions == this.totalQuestions &&
          other.correctAnswers == this.correctAnswers &&
          other.accuracy == this.accuracy);
}

class QuizResultEntriesCompanion extends UpdateCompanion<QuizResultEntry> {
  final Value<int> id;
  final Value<DateTime> date;
  final Value<int?> jlptLevel;
  final Value<String> quizType;
  final Value<int> totalQuestions;
  final Value<int> correctAnswers;
  final Value<double> accuracy;
  const QuizResultEntriesCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.jlptLevel = const Value.absent(),
    this.quizType = const Value.absent(),
    this.totalQuestions = const Value.absent(),
    this.correctAnswers = const Value.absent(),
    this.accuracy = const Value.absent(),
  });
  QuizResultEntriesCompanion.insert({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.jlptLevel = const Value.absent(),
    required String quizType,
    required int totalQuestions,
    required int correctAnswers,
    required double accuracy,
  }) : quizType = Value(quizType),
       totalQuestions = Value(totalQuestions),
       correctAnswers = Value(correctAnswers),
       accuracy = Value(accuracy);
  static Insertable<QuizResultEntry> custom({
    Expression<int>? id,
    Expression<DateTime>? date,
    Expression<int>? jlptLevel,
    Expression<String>? quizType,
    Expression<int>? totalQuestions,
    Expression<int>? correctAnswers,
    Expression<double>? accuracy,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (jlptLevel != null) 'jlpt_level': jlptLevel,
      if (quizType != null) 'quiz_type': quizType,
      if (totalQuestions != null) 'total_questions': totalQuestions,
      if (correctAnswers != null) 'correct_answers': correctAnswers,
      if (accuracy != null) 'accuracy': accuracy,
    });
  }

  QuizResultEntriesCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? date,
    Value<int?>? jlptLevel,
    Value<String>? quizType,
    Value<int>? totalQuestions,
    Value<int>? correctAnswers,
    Value<double>? accuracy,
  }) {
    return QuizResultEntriesCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      jlptLevel: jlptLevel ?? this.jlptLevel,
      quizType: quizType ?? this.quizType,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      accuracy: accuracy ?? this.accuracy,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (jlptLevel.present) {
      map['jlpt_level'] = Variable<int>(jlptLevel.value);
    }
    if (quizType.present) {
      map['quiz_type'] = Variable<String>(quizType.value);
    }
    if (totalQuestions.present) {
      map['total_questions'] = Variable<int>(totalQuestions.value);
    }
    if (correctAnswers.present) {
      map['correct_answers'] = Variable<int>(correctAnswers.value);
    }
    if (accuracy.present) {
      map['accuracy'] = Variable<double>(accuracy.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuizResultEntriesCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('jlptLevel: $jlptLevel, ')
          ..write('quizType: $quizType, ')
          ..write('totalQuestions: $totalQuestions, ')
          ..write('correctAnswers: $correctAnswers, ')
          ..write('accuracy: $accuracy')
          ..write(')'))
        .toString();
  }
}

class $SimilarKanjiEntriesTable extends SimilarKanjiEntries
    with TableInfo<$SimilarKanjiEntriesTable, SimilarKanjiEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SimilarKanjiEntriesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _kanji1Meta = const VerificationMeta('kanji1');
  @override
  late final GeneratedColumn<String> kanji1 = GeneratedColumn<String>(
    'kanji1',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kanji2Meta = const VerificationMeta('kanji2');
  @override
  late final GeneratedColumn<String> kanji2 = GeneratedColumn<String>(
    'kanji2',
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
  @override
  List<GeneratedColumn> get $columns => [id, kanji1, kanji2, explanation];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'similar_kanji_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<SimilarKanjiEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('kanji1')) {
      context.handle(
        _kanji1Meta,
        kanji1.isAcceptableOrUnknown(data['kanji1']!, _kanji1Meta),
      );
    } else if (isInserting) {
      context.missing(_kanji1Meta);
    }
    if (data.containsKey('kanji2')) {
      context.handle(
        _kanji2Meta,
        kanji2.isAcceptableOrUnknown(data['kanji2']!, _kanji2Meta),
      );
    } else if (isInserting) {
      context.missing(_kanji2Meta);
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SimilarKanjiEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SimilarKanjiEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      kanji1: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kanji1'],
      )!,
      kanji2: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kanji2'],
      )!,
      explanation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}explanation'],
      ),
    );
  }

  @override
  $SimilarKanjiEntriesTable createAlias(String alias) {
    return $SimilarKanjiEntriesTable(attachedDatabase, alias);
  }
}

class SimilarKanjiEntry extends DataClass
    implements Insertable<SimilarKanjiEntry> {
  final int id;
  final String kanji1;
  final String kanji2;
  final String? explanation;
  const SimilarKanjiEntry({
    required this.id,
    required this.kanji1,
    required this.kanji2,
    this.explanation,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['kanji1'] = Variable<String>(kanji1);
    map['kanji2'] = Variable<String>(kanji2);
    if (!nullToAbsent || explanation != null) {
      map['explanation'] = Variable<String>(explanation);
    }
    return map;
  }

  SimilarKanjiEntriesCompanion toCompanion(bool nullToAbsent) {
    return SimilarKanjiEntriesCompanion(
      id: Value(id),
      kanji1: Value(kanji1),
      kanji2: Value(kanji2),
      explanation: explanation == null && nullToAbsent
          ? const Value.absent()
          : Value(explanation),
    );
  }

  factory SimilarKanjiEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SimilarKanjiEntry(
      id: serializer.fromJson<int>(json['id']),
      kanji1: serializer.fromJson<String>(json['kanji1']),
      kanji2: serializer.fromJson<String>(json['kanji2']),
      explanation: serializer.fromJson<String?>(json['explanation']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'kanji1': serializer.toJson<String>(kanji1),
      'kanji2': serializer.toJson<String>(kanji2),
      'explanation': serializer.toJson<String?>(explanation),
    };
  }

  SimilarKanjiEntry copyWith({
    int? id,
    String? kanji1,
    String? kanji2,
    Value<String?> explanation = const Value.absent(),
  }) => SimilarKanjiEntry(
    id: id ?? this.id,
    kanji1: kanji1 ?? this.kanji1,
    kanji2: kanji2 ?? this.kanji2,
    explanation: explanation.present ? explanation.value : this.explanation,
  );
  SimilarKanjiEntry copyWithCompanion(SimilarKanjiEntriesCompanion data) {
    return SimilarKanjiEntry(
      id: data.id.present ? data.id.value : this.id,
      kanji1: data.kanji1.present ? data.kanji1.value : this.kanji1,
      kanji2: data.kanji2.present ? data.kanji2.value : this.kanji2,
      explanation: data.explanation.present
          ? data.explanation.value
          : this.explanation,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SimilarKanjiEntry(')
          ..write('id: $id, ')
          ..write('kanji1: $kanji1, ')
          ..write('kanji2: $kanji2, ')
          ..write('explanation: $explanation')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, kanji1, kanji2, explanation);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SimilarKanjiEntry &&
          other.id == this.id &&
          other.kanji1 == this.kanji1 &&
          other.kanji2 == this.kanji2 &&
          other.explanation == this.explanation);
}

class SimilarKanjiEntriesCompanion extends UpdateCompanion<SimilarKanjiEntry> {
  final Value<int> id;
  final Value<String> kanji1;
  final Value<String> kanji2;
  final Value<String?> explanation;
  const SimilarKanjiEntriesCompanion({
    this.id = const Value.absent(),
    this.kanji1 = const Value.absent(),
    this.kanji2 = const Value.absent(),
    this.explanation = const Value.absent(),
  });
  SimilarKanjiEntriesCompanion.insert({
    this.id = const Value.absent(),
    required String kanji1,
    required String kanji2,
    this.explanation = const Value.absent(),
  }) : kanji1 = Value(kanji1),
       kanji2 = Value(kanji2);
  static Insertable<SimilarKanjiEntry> custom({
    Expression<int>? id,
    Expression<String>? kanji1,
    Expression<String>? kanji2,
    Expression<String>? explanation,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kanji1 != null) 'kanji1': kanji1,
      if (kanji2 != null) 'kanji2': kanji2,
      if (explanation != null) 'explanation': explanation,
    });
  }

  SimilarKanjiEntriesCompanion copyWith({
    Value<int>? id,
    Value<String>? kanji1,
    Value<String>? kanji2,
    Value<String?>? explanation,
  }) {
    return SimilarKanjiEntriesCompanion(
      id: id ?? this.id,
      kanji1: kanji1 ?? this.kanji1,
      kanji2: kanji2 ?? this.kanji2,
      explanation: explanation ?? this.explanation,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (kanji1.present) {
      map['kanji1'] = Variable<String>(kanji1.value);
    }
    if (kanji2.present) {
      map['kanji2'] = Variable<String>(kanji2.value);
    }
    if (explanation.present) {
      map['explanation'] = Variable<String>(explanation.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SimilarKanjiEntriesCompanion(')
          ..write('id: $id, ')
          ..write('kanji1: $kanji1, ')
          ..write('kanji2: $kanji2, ')
          ..write('explanation: $explanation')
          ..write(')'))
        .toString();
  }
}

class $JlptVocabEntriesTable extends JlptVocabEntries
    with TableInfo<$JlptVocabEntriesTable, JlptVocabEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JlptVocabEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _wordMeta = const VerificationMeta('word');
  @override
  late final GeneratedColumn<String> word = GeneratedColumn<String>(
    'word',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _meaningMeta = const VerificationMeta(
    'meaning',
  );
  @override
  late final GeneratedColumn<String> meaning = GeneratedColumn<String>(
    'meaning',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _meaningIdMeta = const VerificationMeta(
    'meaningId',
  );
  @override
  late final GeneratedColumn<String> meaningId = GeneratedColumn<String>(
    'meaning_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _furiganaMeta = const VerificationMeta(
    'furigana',
  );
  @override
  late final GeneratedColumn<String> furigana = GeneratedColumn<String>(
    'furigana',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _romajiMeta = const VerificationMeta('romaji');
  @override
  late final GeneratedColumn<String> romaji = GeneratedColumn<String>(
    'romaji',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<int> level = GeneratedColumn<int>(
    'level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    word,
    meaning,
    meaningId,
    furigana,
    romaji,
    level,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'jlpt_vocab_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<JlptVocabEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('word')) {
      context.handle(
        _wordMeta,
        word.isAcceptableOrUnknown(data['word']!, _wordMeta),
      );
    } else if (isInserting) {
      context.missing(_wordMeta);
    }
    if (data.containsKey('meaning')) {
      context.handle(
        _meaningMeta,
        meaning.isAcceptableOrUnknown(data['meaning']!, _meaningMeta),
      );
    } else if (isInserting) {
      context.missing(_meaningMeta);
    }
    if (data.containsKey('meaning_id')) {
      context.handle(
        _meaningIdMeta,
        meaningId.isAcceptableOrUnknown(data['meaning_id']!, _meaningIdMeta),
      );
    }
    if (data.containsKey('furigana')) {
      context.handle(
        _furiganaMeta,
        furigana.isAcceptableOrUnknown(data['furigana']!, _furiganaMeta),
      );
    } else if (isInserting) {
      context.missing(_furiganaMeta);
    }
    if (data.containsKey('romaji')) {
      context.handle(
        _romajiMeta,
        romaji.isAcceptableOrUnknown(data['romaji']!, _romajiMeta),
      );
    } else if (isInserting) {
      context.missing(_romajiMeta);
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    } else if (isInserting) {
      context.missing(_levelMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {word};
  @override
  JlptVocabEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return JlptVocabEntry(
      word: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}word'],
      )!,
      meaning: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meaning'],
      )!,
      meaningId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meaning_id'],
      ),
      furigana: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}furigana'],
      )!,
      romaji: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}romaji'],
      )!,
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}level'],
      )!,
    );
  }

  @override
  $JlptVocabEntriesTable createAlias(String alias) {
    return $JlptVocabEntriesTable(attachedDatabase, alias);
  }
}

class JlptVocabEntry extends DataClass implements Insertable<JlptVocabEntry> {
  final String word;
  final String meaning;
  final String? meaningId;
  final String furigana;
  final String romaji;
  final int level;
  const JlptVocabEntry({
    required this.word,
    required this.meaning,
    this.meaningId,
    required this.furigana,
    required this.romaji,
    required this.level,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['word'] = Variable<String>(word);
    map['meaning'] = Variable<String>(meaning);
    if (!nullToAbsent || meaningId != null) {
      map['meaning_id'] = Variable<String>(meaningId);
    }
    map['furigana'] = Variable<String>(furigana);
    map['romaji'] = Variable<String>(romaji);
    map['level'] = Variable<int>(level);
    return map;
  }

  JlptVocabEntriesCompanion toCompanion(bool nullToAbsent) {
    return JlptVocabEntriesCompanion(
      word: Value(word),
      meaning: Value(meaning),
      meaningId: meaningId == null && nullToAbsent
          ? const Value.absent()
          : Value(meaningId),
      furigana: Value(furigana),
      romaji: Value(romaji),
      level: Value(level),
    );
  }

  factory JlptVocabEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return JlptVocabEntry(
      word: serializer.fromJson<String>(json['word']),
      meaning: serializer.fromJson<String>(json['meaning']),
      meaningId: serializer.fromJson<String?>(json['meaningId']),
      furigana: serializer.fromJson<String>(json['furigana']),
      romaji: serializer.fromJson<String>(json['romaji']),
      level: serializer.fromJson<int>(json['level']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'word': serializer.toJson<String>(word),
      'meaning': serializer.toJson<String>(meaning),
      'meaningId': serializer.toJson<String?>(meaningId),
      'furigana': serializer.toJson<String>(furigana),
      'romaji': serializer.toJson<String>(romaji),
      'level': serializer.toJson<int>(level),
    };
  }

  JlptVocabEntry copyWith({
    String? word,
    String? meaning,
    Value<String?> meaningId = const Value.absent(),
    String? furigana,
    String? romaji,
    int? level,
  }) => JlptVocabEntry(
    word: word ?? this.word,
    meaning: meaning ?? this.meaning,
    meaningId: meaningId.present ? meaningId.value : this.meaningId,
    furigana: furigana ?? this.furigana,
    romaji: romaji ?? this.romaji,
    level: level ?? this.level,
  );
  JlptVocabEntry copyWithCompanion(JlptVocabEntriesCompanion data) {
    return JlptVocabEntry(
      word: data.word.present ? data.word.value : this.word,
      meaning: data.meaning.present ? data.meaning.value : this.meaning,
      meaningId: data.meaningId.present ? data.meaningId.value : this.meaningId,
      furigana: data.furigana.present ? data.furigana.value : this.furigana,
      romaji: data.romaji.present ? data.romaji.value : this.romaji,
      level: data.level.present ? data.level.value : this.level,
    );
  }

  @override
  String toString() {
    return (StringBuffer('JlptVocabEntry(')
          ..write('word: $word, ')
          ..write('meaning: $meaning, ')
          ..write('meaningId: $meaningId, ')
          ..write('furigana: $furigana, ')
          ..write('romaji: $romaji, ')
          ..write('level: $level')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(word, meaning, meaningId, furigana, romaji, level);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JlptVocabEntry &&
          other.word == this.word &&
          other.meaning == this.meaning &&
          other.meaningId == this.meaningId &&
          other.furigana == this.furigana &&
          other.romaji == this.romaji &&
          other.level == this.level);
}

class JlptVocabEntriesCompanion extends UpdateCompanion<JlptVocabEntry> {
  final Value<String> word;
  final Value<String> meaning;
  final Value<String?> meaningId;
  final Value<String> furigana;
  final Value<String> romaji;
  final Value<int> level;
  final Value<int> rowid;
  const JlptVocabEntriesCompanion({
    this.word = const Value.absent(),
    this.meaning = const Value.absent(),
    this.meaningId = const Value.absent(),
    this.furigana = const Value.absent(),
    this.romaji = const Value.absent(),
    this.level = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  JlptVocabEntriesCompanion.insert({
    required String word,
    required String meaning,
    this.meaningId = const Value.absent(),
    required String furigana,
    required String romaji,
    required int level,
    this.rowid = const Value.absent(),
  }) : word = Value(word),
       meaning = Value(meaning),
       furigana = Value(furigana),
       romaji = Value(romaji),
       level = Value(level);
  static Insertable<JlptVocabEntry> custom({
    Expression<String>? word,
    Expression<String>? meaning,
    Expression<String>? meaningId,
    Expression<String>? furigana,
    Expression<String>? romaji,
    Expression<int>? level,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (word != null) 'word': word,
      if (meaning != null) 'meaning': meaning,
      if (meaningId != null) 'meaning_id': meaningId,
      if (furigana != null) 'furigana': furigana,
      if (romaji != null) 'romaji': romaji,
      if (level != null) 'level': level,
      if (rowid != null) 'rowid': rowid,
    });
  }

  JlptVocabEntriesCompanion copyWith({
    Value<String>? word,
    Value<String>? meaning,
    Value<String?>? meaningId,
    Value<String>? furigana,
    Value<String>? romaji,
    Value<int>? level,
    Value<int>? rowid,
  }) {
    return JlptVocabEntriesCompanion(
      word: word ?? this.word,
      meaning: meaning ?? this.meaning,
      meaningId: meaningId ?? this.meaningId,
      furigana: furigana ?? this.furigana,
      romaji: romaji ?? this.romaji,
      level: level ?? this.level,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (word.present) {
      map['word'] = Variable<String>(word.value);
    }
    if (meaning.present) {
      map['meaning'] = Variable<String>(meaning.value);
    }
    if (meaningId.present) {
      map['meaning_id'] = Variable<String>(meaningId.value);
    }
    if (furigana.present) {
      map['furigana'] = Variable<String>(furigana.value);
    }
    if (romaji.present) {
      map['romaji'] = Variable<String>(romaji.value);
    }
    if (level.present) {
      map['level'] = Variable<int>(level.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JlptVocabEntriesCompanion(')
          ..write('word: $word, ')
          ..write('meaning: $meaning, ')
          ..write('meaningId: $meaningId, ')
          ..write('furigana: $furigana, ')
          ..write('romaji: $romaji, ')
          ..write('level: $level, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $KanjiEntriesTable kanjiEntries = $KanjiEntriesTable(this);
  late final $VocabularyEntriesTable vocabularyEntries =
      $VocabularyEntriesTable(this);
  late final $UserKanjiProgressEntriesTable userKanjiProgressEntries =
      $UserKanjiProgressEntriesTable(this);
  late final $DailyProgressEntriesTable dailyProgressEntries =
      $DailyProgressEntriesTable(this);
  late final $QuizResultEntriesTable quizResultEntries =
      $QuizResultEntriesTable(this);
  late final $SimilarKanjiEntriesTable similarKanjiEntries =
      $SimilarKanjiEntriesTable(this);
  late final $JlptVocabEntriesTable jlptVocabEntries = $JlptVocabEntriesTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    kanjiEntries,
    vocabularyEntries,
    userKanjiProgressEntries,
    dailyProgressEntries,
    quizResultEntries,
    similarKanjiEntries,
    jlptVocabEntries,
  ];
}

typedef $$KanjiEntriesTableCreateCompanionBuilder =
    KanjiEntriesCompanion Function({
      required String character,
      Value<int?> jlptLevel,
      required String meanings,
      Value<String?> meaningsId,
      required String onyomi,
      required String kunyomi,
      Value<String> nameReadings,
      Value<int> strokeCount,
      Value<int?> grade,
      Value<String?> heisigKeyword,
      Value<int?> frequency,
      Value<String> unicode,
      Value<DateTime> cachedAt,
      Value<int> rowid,
    });
typedef $$KanjiEntriesTableUpdateCompanionBuilder =
    KanjiEntriesCompanion Function({
      Value<String> character,
      Value<int?> jlptLevel,
      Value<String> meanings,
      Value<String?> meaningsId,
      Value<String> onyomi,
      Value<String> kunyomi,
      Value<String> nameReadings,
      Value<int> strokeCount,
      Value<int?> grade,
      Value<String?> heisigKeyword,
      Value<int?> frequency,
      Value<String> unicode,
      Value<DateTime> cachedAt,
      Value<int> rowid,
    });

class $$KanjiEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $KanjiEntriesTable> {
  $$KanjiEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get character => $composableBuilder(
    column: $table.character,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get jlptLevel => $composableBuilder(
    column: $table.jlptLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get meanings => $composableBuilder(
    column: $table.meanings,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get meaningsId => $composableBuilder(
    column: $table.meaningsId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get onyomi => $composableBuilder(
    column: $table.onyomi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kunyomi => $composableBuilder(
    column: $table.kunyomi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameReadings => $composableBuilder(
    column: $table.nameReadings,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get strokeCount => $composableBuilder(
    column: $table.strokeCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get grade => $composableBuilder(
    column: $table.grade,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get heisigKeyword => $composableBuilder(
    column: $table.heisigKeyword,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unicode => $composableBuilder(
    column: $table.unicode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$KanjiEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $KanjiEntriesTable> {
  $$KanjiEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get character => $composableBuilder(
    column: $table.character,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get jlptLevel => $composableBuilder(
    column: $table.jlptLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get meanings => $composableBuilder(
    column: $table.meanings,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get meaningsId => $composableBuilder(
    column: $table.meaningsId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get onyomi => $composableBuilder(
    column: $table.onyomi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kunyomi => $composableBuilder(
    column: $table.kunyomi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameReadings => $composableBuilder(
    column: $table.nameReadings,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get strokeCount => $composableBuilder(
    column: $table.strokeCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get grade => $composableBuilder(
    column: $table.grade,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get heisigKeyword => $composableBuilder(
    column: $table.heisigKeyword,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unicode => $composableBuilder(
    column: $table.unicode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$KanjiEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $KanjiEntriesTable> {
  $$KanjiEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get character =>
      $composableBuilder(column: $table.character, builder: (column) => column);

  GeneratedColumn<int> get jlptLevel =>
      $composableBuilder(column: $table.jlptLevel, builder: (column) => column);

  GeneratedColumn<String> get meanings =>
      $composableBuilder(column: $table.meanings, builder: (column) => column);

  GeneratedColumn<String> get meaningsId => $composableBuilder(
    column: $table.meaningsId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get onyomi =>
      $composableBuilder(column: $table.onyomi, builder: (column) => column);

  GeneratedColumn<String> get kunyomi =>
      $composableBuilder(column: $table.kunyomi, builder: (column) => column);

  GeneratedColumn<String> get nameReadings => $composableBuilder(
    column: $table.nameReadings,
    builder: (column) => column,
  );

  GeneratedColumn<int> get strokeCount => $composableBuilder(
    column: $table.strokeCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get grade =>
      $composableBuilder(column: $table.grade, builder: (column) => column);

  GeneratedColumn<String> get heisigKeyword => $composableBuilder(
    column: $table.heisigKeyword,
    builder: (column) => column,
  );

  GeneratedColumn<int> get frequency =>
      $composableBuilder(column: $table.frequency, builder: (column) => column);

  GeneratedColumn<String> get unicode =>
      $composableBuilder(column: $table.unicode, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$KanjiEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $KanjiEntriesTable,
          KanjiEntry,
          $$KanjiEntriesTableFilterComposer,
          $$KanjiEntriesTableOrderingComposer,
          $$KanjiEntriesTableAnnotationComposer,
          $$KanjiEntriesTableCreateCompanionBuilder,
          $$KanjiEntriesTableUpdateCompanionBuilder,
          (
            KanjiEntry,
            BaseReferences<_$AppDatabase, $KanjiEntriesTable, KanjiEntry>,
          ),
          KanjiEntry,
          PrefetchHooks Function()
        > {
  $$KanjiEntriesTableTableManager(_$AppDatabase db, $KanjiEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KanjiEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$KanjiEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KanjiEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> character = const Value.absent(),
                Value<int?> jlptLevel = const Value.absent(),
                Value<String> meanings = const Value.absent(),
                Value<String?> meaningsId = const Value.absent(),
                Value<String> onyomi = const Value.absent(),
                Value<String> kunyomi = const Value.absent(),
                Value<String> nameReadings = const Value.absent(),
                Value<int> strokeCount = const Value.absent(),
                Value<int?> grade = const Value.absent(),
                Value<String?> heisigKeyword = const Value.absent(),
                Value<int?> frequency = const Value.absent(),
                Value<String> unicode = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => KanjiEntriesCompanion(
                character: character,
                jlptLevel: jlptLevel,
                meanings: meanings,
                meaningsId: meaningsId,
                onyomi: onyomi,
                kunyomi: kunyomi,
                nameReadings: nameReadings,
                strokeCount: strokeCount,
                grade: grade,
                heisigKeyword: heisigKeyword,
                frequency: frequency,
                unicode: unicode,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String character,
                Value<int?> jlptLevel = const Value.absent(),
                required String meanings,
                Value<String?> meaningsId = const Value.absent(),
                required String onyomi,
                required String kunyomi,
                Value<String> nameReadings = const Value.absent(),
                Value<int> strokeCount = const Value.absent(),
                Value<int?> grade = const Value.absent(),
                Value<String?> heisigKeyword = const Value.absent(),
                Value<int?> frequency = const Value.absent(),
                Value<String> unicode = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => KanjiEntriesCompanion.insert(
                character: character,
                jlptLevel: jlptLevel,
                meanings: meanings,
                meaningsId: meaningsId,
                onyomi: onyomi,
                kunyomi: kunyomi,
                nameReadings: nameReadings,
                strokeCount: strokeCount,
                grade: grade,
                heisigKeyword: heisigKeyword,
                frequency: frequency,
                unicode: unicode,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$KanjiEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $KanjiEntriesTable,
      KanjiEntry,
      $$KanjiEntriesTableFilterComposer,
      $$KanjiEntriesTableOrderingComposer,
      $$KanjiEntriesTableAnnotationComposer,
      $$KanjiEntriesTableCreateCompanionBuilder,
      $$KanjiEntriesTableUpdateCompanionBuilder,
      (
        KanjiEntry,
        BaseReferences<_$AppDatabase, $KanjiEntriesTable, KanjiEntry>,
      ),
      KanjiEntry,
      PrefetchHooks Function()
    >;
typedef $$VocabularyEntriesTableCreateCompanionBuilder =
    VocabularyEntriesCompanion Function({
      Value<int> id,
      required String kanjiCharacter,
      required String word,
      required String reading,
      required String meanings,
      Value<String?> meaningsId,
      Value<String> priorities,
      Value<DateTime> cachedAt,
    });
typedef $$VocabularyEntriesTableUpdateCompanionBuilder =
    VocabularyEntriesCompanion Function({
      Value<int> id,
      Value<String> kanjiCharacter,
      Value<String> word,
      Value<String> reading,
      Value<String> meanings,
      Value<String?> meaningsId,
      Value<String> priorities,
      Value<DateTime> cachedAt,
    });

class $$VocabularyEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $VocabularyEntriesTable> {
  $$VocabularyEntriesTableFilterComposer({
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

  ColumnFilters<String> get kanjiCharacter => $composableBuilder(
    column: $table.kanjiCharacter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get word => $composableBuilder(
    column: $table.word,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reading => $composableBuilder(
    column: $table.reading,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get meanings => $composableBuilder(
    column: $table.meanings,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get meaningsId => $composableBuilder(
    column: $table.meaningsId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get priorities => $composableBuilder(
    column: $table.priorities,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VocabularyEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $VocabularyEntriesTable> {
  $$VocabularyEntriesTableOrderingComposer({
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

  ColumnOrderings<String> get kanjiCharacter => $composableBuilder(
    column: $table.kanjiCharacter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get word => $composableBuilder(
    column: $table.word,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reading => $composableBuilder(
    column: $table.reading,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get meanings => $composableBuilder(
    column: $table.meanings,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get meaningsId => $composableBuilder(
    column: $table.meaningsId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get priorities => $composableBuilder(
    column: $table.priorities,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VocabularyEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $VocabularyEntriesTable> {
  $$VocabularyEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kanjiCharacter => $composableBuilder(
    column: $table.kanjiCharacter,
    builder: (column) => column,
  );

  GeneratedColumn<String> get word =>
      $composableBuilder(column: $table.word, builder: (column) => column);

  GeneratedColumn<String> get reading =>
      $composableBuilder(column: $table.reading, builder: (column) => column);

  GeneratedColumn<String> get meanings =>
      $composableBuilder(column: $table.meanings, builder: (column) => column);

  GeneratedColumn<String> get meaningsId => $composableBuilder(
    column: $table.meaningsId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get priorities => $composableBuilder(
    column: $table.priorities,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$VocabularyEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VocabularyEntriesTable,
          VocabularyEntry,
          $$VocabularyEntriesTableFilterComposer,
          $$VocabularyEntriesTableOrderingComposer,
          $$VocabularyEntriesTableAnnotationComposer,
          $$VocabularyEntriesTableCreateCompanionBuilder,
          $$VocabularyEntriesTableUpdateCompanionBuilder,
          (
            VocabularyEntry,
            BaseReferences<
              _$AppDatabase,
              $VocabularyEntriesTable,
              VocabularyEntry
            >,
          ),
          VocabularyEntry,
          PrefetchHooks Function()
        > {
  $$VocabularyEntriesTableTableManager(
    _$AppDatabase db,
    $VocabularyEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VocabularyEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VocabularyEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VocabularyEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> kanjiCharacter = const Value.absent(),
                Value<String> word = const Value.absent(),
                Value<String> reading = const Value.absent(),
                Value<String> meanings = const Value.absent(),
                Value<String?> meaningsId = const Value.absent(),
                Value<String> priorities = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
              }) => VocabularyEntriesCompanion(
                id: id,
                kanjiCharacter: kanjiCharacter,
                word: word,
                reading: reading,
                meanings: meanings,
                meaningsId: meaningsId,
                priorities: priorities,
                cachedAt: cachedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String kanjiCharacter,
                required String word,
                required String reading,
                required String meanings,
                Value<String?> meaningsId = const Value.absent(),
                Value<String> priorities = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
              }) => VocabularyEntriesCompanion.insert(
                id: id,
                kanjiCharacter: kanjiCharacter,
                word: word,
                reading: reading,
                meanings: meanings,
                meaningsId: meaningsId,
                priorities: priorities,
                cachedAt: cachedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VocabularyEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VocabularyEntriesTable,
      VocabularyEntry,
      $$VocabularyEntriesTableFilterComposer,
      $$VocabularyEntriesTableOrderingComposer,
      $$VocabularyEntriesTableAnnotationComposer,
      $$VocabularyEntriesTableCreateCompanionBuilder,
      $$VocabularyEntriesTableUpdateCompanionBuilder,
      (
        VocabularyEntry,
        BaseReferences<_$AppDatabase, $VocabularyEntriesTable, VocabularyEntry>,
      ),
      VocabularyEntry,
      PrefetchHooks Function()
    >;
typedef $$UserKanjiProgressEntriesTableCreateCompanionBuilder =
    UserKanjiProgressEntriesCompanion Function({
      required String kanjiCharacter,
      Value<String> status,
      Value<int> correctCount,
      Value<int> wrongCount,
      Value<double> ease,
      Value<int> intervalDays,
      Value<int> repetitions,
      Value<DateTime?> lastReviewedAt,
      Value<DateTime?> nextReviewAt,
      Value<DateTime?> firstLearnedAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$UserKanjiProgressEntriesTableUpdateCompanionBuilder =
    UserKanjiProgressEntriesCompanion Function({
      Value<String> kanjiCharacter,
      Value<String> status,
      Value<int> correctCount,
      Value<int> wrongCount,
      Value<double> ease,
      Value<int> intervalDays,
      Value<int> repetitions,
      Value<DateTime?> lastReviewedAt,
      Value<DateTime?> nextReviewAt,
      Value<DateTime?> firstLearnedAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$UserKanjiProgressEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $UserKanjiProgressEntriesTable> {
  $$UserKanjiProgressEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get kanjiCharacter => $composableBuilder(
    column: $table.kanjiCharacter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get correctCount => $composableBuilder(
    column: $table.correctCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get wrongCount => $composableBuilder(
    column: $table.wrongCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get ease => $composableBuilder(
    column: $table.ease,
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

  ColumnFilters<DateTime> get lastReviewedAt => $composableBuilder(
    column: $table.lastReviewedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextReviewAt => $composableBuilder(
    column: $table.nextReviewAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get firstLearnedAt => $composableBuilder(
    column: $table.firstLearnedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserKanjiProgressEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $UserKanjiProgressEntriesTable> {
  $$UserKanjiProgressEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get kanjiCharacter => $composableBuilder(
    column: $table.kanjiCharacter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get correctCount => $composableBuilder(
    column: $table.correctCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get wrongCount => $composableBuilder(
    column: $table.wrongCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get ease => $composableBuilder(
    column: $table.ease,
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

  ColumnOrderings<DateTime> get lastReviewedAt => $composableBuilder(
    column: $table.lastReviewedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextReviewAt => $composableBuilder(
    column: $table.nextReviewAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get firstLearnedAt => $composableBuilder(
    column: $table.firstLearnedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserKanjiProgressEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserKanjiProgressEntriesTable> {
  $$UserKanjiProgressEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get kanjiCharacter => $composableBuilder(
    column: $table.kanjiCharacter,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get correctCount => $composableBuilder(
    column: $table.correctCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get wrongCount => $composableBuilder(
    column: $table.wrongCount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get ease =>
      $composableBuilder(column: $table.ease, builder: (column) => column);

  GeneratedColumn<int> get intervalDays => $composableBuilder(
    column: $table.intervalDays,
    builder: (column) => column,
  );

  GeneratedColumn<int> get repetitions => $composableBuilder(
    column: $table.repetitions,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastReviewedAt => $composableBuilder(
    column: $table.lastReviewedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get nextReviewAt => $composableBuilder(
    column: $table.nextReviewAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get firstLearnedAt => $composableBuilder(
    column: $table.firstLearnedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$UserKanjiProgressEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserKanjiProgressEntriesTable,
          UserKanjiProgressEntry,
          $$UserKanjiProgressEntriesTableFilterComposer,
          $$UserKanjiProgressEntriesTableOrderingComposer,
          $$UserKanjiProgressEntriesTableAnnotationComposer,
          $$UserKanjiProgressEntriesTableCreateCompanionBuilder,
          $$UserKanjiProgressEntriesTableUpdateCompanionBuilder,
          (
            UserKanjiProgressEntry,
            BaseReferences<
              _$AppDatabase,
              $UserKanjiProgressEntriesTable,
              UserKanjiProgressEntry
            >,
          ),
          UserKanjiProgressEntry,
          PrefetchHooks Function()
        > {
  $$UserKanjiProgressEntriesTableTableManager(
    _$AppDatabase db,
    $UserKanjiProgressEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserKanjiProgressEntriesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$UserKanjiProgressEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$UserKanjiProgressEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> kanjiCharacter = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> correctCount = const Value.absent(),
                Value<int> wrongCount = const Value.absent(),
                Value<double> ease = const Value.absent(),
                Value<int> intervalDays = const Value.absent(),
                Value<int> repetitions = const Value.absent(),
                Value<DateTime?> lastReviewedAt = const Value.absent(),
                Value<DateTime?> nextReviewAt = const Value.absent(),
                Value<DateTime?> firstLearnedAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserKanjiProgressEntriesCompanion(
                kanjiCharacter: kanjiCharacter,
                status: status,
                correctCount: correctCount,
                wrongCount: wrongCount,
                ease: ease,
                intervalDays: intervalDays,
                repetitions: repetitions,
                lastReviewedAt: lastReviewedAt,
                nextReviewAt: nextReviewAt,
                firstLearnedAt: firstLearnedAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String kanjiCharacter,
                Value<String> status = const Value.absent(),
                Value<int> correctCount = const Value.absent(),
                Value<int> wrongCount = const Value.absent(),
                Value<double> ease = const Value.absent(),
                Value<int> intervalDays = const Value.absent(),
                Value<int> repetitions = const Value.absent(),
                Value<DateTime?> lastReviewedAt = const Value.absent(),
                Value<DateTime?> nextReviewAt = const Value.absent(),
                Value<DateTime?> firstLearnedAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserKanjiProgressEntriesCompanion.insert(
                kanjiCharacter: kanjiCharacter,
                status: status,
                correctCount: correctCount,
                wrongCount: wrongCount,
                ease: ease,
                intervalDays: intervalDays,
                repetitions: repetitions,
                lastReviewedAt: lastReviewedAt,
                nextReviewAt: nextReviewAt,
                firstLearnedAt: firstLearnedAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserKanjiProgressEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserKanjiProgressEntriesTable,
      UserKanjiProgressEntry,
      $$UserKanjiProgressEntriesTableFilterComposer,
      $$UserKanjiProgressEntriesTableOrderingComposer,
      $$UserKanjiProgressEntriesTableAnnotationComposer,
      $$UserKanjiProgressEntriesTableCreateCompanionBuilder,
      $$UserKanjiProgressEntriesTableUpdateCompanionBuilder,
      (
        UserKanjiProgressEntry,
        BaseReferences<
          _$AppDatabase,
          $UserKanjiProgressEntriesTable,
          UserKanjiProgressEntry
        >,
      ),
      UserKanjiProgressEntry,
      PrefetchHooks Function()
    >;
typedef $$DailyProgressEntriesTableCreateCompanionBuilder =
    DailyProgressEntriesCompanion Function({
      required String date,
      Value<int> newKanjiCount,
      Value<int> reviewedKanjiCount,
      Value<int> correctAnswers,
      Value<int> wrongAnswers,
      Value<int> dailyGoal,
      Value<bool> goalCompleted,
      Value<int> rowid,
    });
typedef $$DailyProgressEntriesTableUpdateCompanionBuilder =
    DailyProgressEntriesCompanion Function({
      Value<String> date,
      Value<int> newKanjiCount,
      Value<int> reviewedKanjiCount,
      Value<int> correctAnswers,
      Value<int> wrongAnswers,
      Value<int> dailyGoal,
      Value<bool> goalCompleted,
      Value<int> rowid,
    });

class $$DailyProgressEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $DailyProgressEntriesTable> {
  $$DailyProgressEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get newKanjiCount => $composableBuilder(
    column: $table.newKanjiCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reviewedKanjiCount => $composableBuilder(
    column: $table.reviewedKanjiCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get correctAnswers => $composableBuilder(
    column: $table.correctAnswers,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get wrongAnswers => $composableBuilder(
    column: $table.wrongAnswers,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dailyGoal => $composableBuilder(
    column: $table.dailyGoal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get goalCompleted => $composableBuilder(
    column: $table.goalCompleted,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DailyProgressEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $DailyProgressEntriesTable> {
  $$DailyProgressEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get newKanjiCount => $composableBuilder(
    column: $table.newKanjiCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reviewedKanjiCount => $composableBuilder(
    column: $table.reviewedKanjiCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get correctAnswers => $composableBuilder(
    column: $table.correctAnswers,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get wrongAnswers => $composableBuilder(
    column: $table.wrongAnswers,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dailyGoal => $composableBuilder(
    column: $table.dailyGoal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get goalCompleted => $composableBuilder(
    column: $table.goalCompleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DailyProgressEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailyProgressEntriesTable> {
  $$DailyProgressEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get newKanjiCount => $composableBuilder(
    column: $table.newKanjiCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reviewedKanjiCount => $composableBuilder(
    column: $table.reviewedKanjiCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get correctAnswers => $composableBuilder(
    column: $table.correctAnswers,
    builder: (column) => column,
  );

  GeneratedColumn<int> get wrongAnswers => $composableBuilder(
    column: $table.wrongAnswers,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dailyGoal =>
      $composableBuilder(column: $table.dailyGoal, builder: (column) => column);

  GeneratedColumn<bool> get goalCompleted => $composableBuilder(
    column: $table.goalCompleted,
    builder: (column) => column,
  );
}

class $$DailyProgressEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DailyProgressEntriesTable,
          DailyProgressEntry,
          $$DailyProgressEntriesTableFilterComposer,
          $$DailyProgressEntriesTableOrderingComposer,
          $$DailyProgressEntriesTableAnnotationComposer,
          $$DailyProgressEntriesTableCreateCompanionBuilder,
          $$DailyProgressEntriesTableUpdateCompanionBuilder,
          (
            DailyProgressEntry,
            BaseReferences<
              _$AppDatabase,
              $DailyProgressEntriesTable,
              DailyProgressEntry
            >,
          ),
          DailyProgressEntry,
          PrefetchHooks Function()
        > {
  $$DailyProgressEntriesTableTableManager(
    _$AppDatabase db,
    $DailyProgressEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyProgressEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyProgressEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$DailyProgressEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> date = const Value.absent(),
                Value<int> newKanjiCount = const Value.absent(),
                Value<int> reviewedKanjiCount = const Value.absent(),
                Value<int> correctAnswers = const Value.absent(),
                Value<int> wrongAnswers = const Value.absent(),
                Value<int> dailyGoal = const Value.absent(),
                Value<bool> goalCompleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailyProgressEntriesCompanion(
                date: date,
                newKanjiCount: newKanjiCount,
                reviewedKanjiCount: reviewedKanjiCount,
                correctAnswers: correctAnswers,
                wrongAnswers: wrongAnswers,
                dailyGoal: dailyGoal,
                goalCompleted: goalCompleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String date,
                Value<int> newKanjiCount = const Value.absent(),
                Value<int> reviewedKanjiCount = const Value.absent(),
                Value<int> correctAnswers = const Value.absent(),
                Value<int> wrongAnswers = const Value.absent(),
                Value<int> dailyGoal = const Value.absent(),
                Value<bool> goalCompleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailyProgressEntriesCompanion.insert(
                date: date,
                newKanjiCount: newKanjiCount,
                reviewedKanjiCount: reviewedKanjiCount,
                correctAnswers: correctAnswers,
                wrongAnswers: wrongAnswers,
                dailyGoal: dailyGoal,
                goalCompleted: goalCompleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DailyProgressEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DailyProgressEntriesTable,
      DailyProgressEntry,
      $$DailyProgressEntriesTableFilterComposer,
      $$DailyProgressEntriesTableOrderingComposer,
      $$DailyProgressEntriesTableAnnotationComposer,
      $$DailyProgressEntriesTableCreateCompanionBuilder,
      $$DailyProgressEntriesTableUpdateCompanionBuilder,
      (
        DailyProgressEntry,
        BaseReferences<
          _$AppDatabase,
          $DailyProgressEntriesTable,
          DailyProgressEntry
        >,
      ),
      DailyProgressEntry,
      PrefetchHooks Function()
    >;
typedef $$QuizResultEntriesTableCreateCompanionBuilder =
    QuizResultEntriesCompanion Function({
      Value<int> id,
      Value<DateTime> date,
      Value<int?> jlptLevel,
      required String quizType,
      required int totalQuestions,
      required int correctAnswers,
      required double accuracy,
    });
typedef $$QuizResultEntriesTableUpdateCompanionBuilder =
    QuizResultEntriesCompanion Function({
      Value<int> id,
      Value<DateTime> date,
      Value<int?> jlptLevel,
      Value<String> quizType,
      Value<int> totalQuestions,
      Value<int> correctAnswers,
      Value<double> accuracy,
    });

class $$QuizResultEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $QuizResultEntriesTable> {
  $$QuizResultEntriesTableFilterComposer({
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

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get jlptLevel => $composableBuilder(
    column: $table.jlptLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get quizType => $composableBuilder(
    column: $table.quizType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalQuestions => $composableBuilder(
    column: $table.totalQuestions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get correctAnswers => $composableBuilder(
    column: $table.correctAnswers,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get accuracy => $composableBuilder(
    column: $table.accuracy,
    builder: (column) => ColumnFilters(column),
  );
}

class $$QuizResultEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $QuizResultEntriesTable> {
  $$QuizResultEntriesTableOrderingComposer({
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

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get jlptLevel => $composableBuilder(
    column: $table.jlptLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get quizType => $composableBuilder(
    column: $table.quizType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalQuestions => $composableBuilder(
    column: $table.totalQuestions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get correctAnswers => $composableBuilder(
    column: $table.correctAnswers,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get accuracy => $composableBuilder(
    column: $table.accuracy,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$QuizResultEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $QuizResultEntriesTable> {
  $$QuizResultEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get jlptLevel =>
      $composableBuilder(column: $table.jlptLevel, builder: (column) => column);

  GeneratedColumn<String> get quizType =>
      $composableBuilder(column: $table.quizType, builder: (column) => column);

  GeneratedColumn<int> get totalQuestions => $composableBuilder(
    column: $table.totalQuestions,
    builder: (column) => column,
  );

  GeneratedColumn<int> get correctAnswers => $composableBuilder(
    column: $table.correctAnswers,
    builder: (column) => column,
  );

  GeneratedColumn<double> get accuracy =>
      $composableBuilder(column: $table.accuracy, builder: (column) => column);
}

class $$QuizResultEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $QuizResultEntriesTable,
          QuizResultEntry,
          $$QuizResultEntriesTableFilterComposer,
          $$QuizResultEntriesTableOrderingComposer,
          $$QuizResultEntriesTableAnnotationComposer,
          $$QuizResultEntriesTableCreateCompanionBuilder,
          $$QuizResultEntriesTableUpdateCompanionBuilder,
          (
            QuizResultEntry,
            BaseReferences<
              _$AppDatabase,
              $QuizResultEntriesTable,
              QuizResultEntry
            >,
          ),
          QuizResultEntry,
          PrefetchHooks Function()
        > {
  $$QuizResultEntriesTableTableManager(
    _$AppDatabase db,
    $QuizResultEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuizResultEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QuizResultEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QuizResultEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<int?> jlptLevel = const Value.absent(),
                Value<String> quizType = const Value.absent(),
                Value<int> totalQuestions = const Value.absent(),
                Value<int> correctAnswers = const Value.absent(),
                Value<double> accuracy = const Value.absent(),
              }) => QuizResultEntriesCompanion(
                id: id,
                date: date,
                jlptLevel: jlptLevel,
                quizType: quizType,
                totalQuestions: totalQuestions,
                correctAnswers: correctAnswers,
                accuracy: accuracy,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<int?> jlptLevel = const Value.absent(),
                required String quizType,
                required int totalQuestions,
                required int correctAnswers,
                required double accuracy,
              }) => QuizResultEntriesCompanion.insert(
                id: id,
                date: date,
                jlptLevel: jlptLevel,
                quizType: quizType,
                totalQuestions: totalQuestions,
                correctAnswers: correctAnswers,
                accuracy: accuracy,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$QuizResultEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $QuizResultEntriesTable,
      QuizResultEntry,
      $$QuizResultEntriesTableFilterComposer,
      $$QuizResultEntriesTableOrderingComposer,
      $$QuizResultEntriesTableAnnotationComposer,
      $$QuizResultEntriesTableCreateCompanionBuilder,
      $$QuizResultEntriesTableUpdateCompanionBuilder,
      (
        QuizResultEntry,
        BaseReferences<_$AppDatabase, $QuizResultEntriesTable, QuizResultEntry>,
      ),
      QuizResultEntry,
      PrefetchHooks Function()
    >;
typedef $$SimilarKanjiEntriesTableCreateCompanionBuilder =
    SimilarKanjiEntriesCompanion Function({
      Value<int> id,
      required String kanji1,
      required String kanji2,
      Value<String?> explanation,
    });
typedef $$SimilarKanjiEntriesTableUpdateCompanionBuilder =
    SimilarKanjiEntriesCompanion Function({
      Value<int> id,
      Value<String> kanji1,
      Value<String> kanji2,
      Value<String?> explanation,
    });

class $$SimilarKanjiEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $SimilarKanjiEntriesTable> {
  $$SimilarKanjiEntriesTableFilterComposer({
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

  ColumnFilters<String> get kanji1 => $composableBuilder(
    column: $table.kanji1,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kanji2 => $composableBuilder(
    column: $table.kanji2,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get explanation => $composableBuilder(
    column: $table.explanation,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SimilarKanjiEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $SimilarKanjiEntriesTable> {
  $$SimilarKanjiEntriesTableOrderingComposer({
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

  ColumnOrderings<String> get kanji1 => $composableBuilder(
    column: $table.kanji1,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kanji2 => $composableBuilder(
    column: $table.kanji2,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get explanation => $composableBuilder(
    column: $table.explanation,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SimilarKanjiEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SimilarKanjiEntriesTable> {
  $$SimilarKanjiEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kanji1 =>
      $composableBuilder(column: $table.kanji1, builder: (column) => column);

  GeneratedColumn<String> get kanji2 =>
      $composableBuilder(column: $table.kanji2, builder: (column) => column);

  GeneratedColumn<String> get explanation => $composableBuilder(
    column: $table.explanation,
    builder: (column) => column,
  );
}

class $$SimilarKanjiEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SimilarKanjiEntriesTable,
          SimilarKanjiEntry,
          $$SimilarKanjiEntriesTableFilterComposer,
          $$SimilarKanjiEntriesTableOrderingComposer,
          $$SimilarKanjiEntriesTableAnnotationComposer,
          $$SimilarKanjiEntriesTableCreateCompanionBuilder,
          $$SimilarKanjiEntriesTableUpdateCompanionBuilder,
          (
            SimilarKanjiEntry,
            BaseReferences<
              _$AppDatabase,
              $SimilarKanjiEntriesTable,
              SimilarKanjiEntry
            >,
          ),
          SimilarKanjiEntry,
          PrefetchHooks Function()
        > {
  $$SimilarKanjiEntriesTableTableManager(
    _$AppDatabase db,
    $SimilarKanjiEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SimilarKanjiEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SimilarKanjiEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$SimilarKanjiEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> kanji1 = const Value.absent(),
                Value<String> kanji2 = const Value.absent(),
                Value<String?> explanation = const Value.absent(),
              }) => SimilarKanjiEntriesCompanion(
                id: id,
                kanji1: kanji1,
                kanji2: kanji2,
                explanation: explanation,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String kanji1,
                required String kanji2,
                Value<String?> explanation = const Value.absent(),
              }) => SimilarKanjiEntriesCompanion.insert(
                id: id,
                kanji1: kanji1,
                kanji2: kanji2,
                explanation: explanation,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SimilarKanjiEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SimilarKanjiEntriesTable,
      SimilarKanjiEntry,
      $$SimilarKanjiEntriesTableFilterComposer,
      $$SimilarKanjiEntriesTableOrderingComposer,
      $$SimilarKanjiEntriesTableAnnotationComposer,
      $$SimilarKanjiEntriesTableCreateCompanionBuilder,
      $$SimilarKanjiEntriesTableUpdateCompanionBuilder,
      (
        SimilarKanjiEntry,
        BaseReferences<
          _$AppDatabase,
          $SimilarKanjiEntriesTable,
          SimilarKanjiEntry
        >,
      ),
      SimilarKanjiEntry,
      PrefetchHooks Function()
    >;
typedef $$JlptVocabEntriesTableCreateCompanionBuilder =
    JlptVocabEntriesCompanion Function({
      required String word,
      required String meaning,
      Value<String?> meaningId,
      required String furigana,
      required String romaji,
      required int level,
      Value<int> rowid,
    });
typedef $$JlptVocabEntriesTableUpdateCompanionBuilder =
    JlptVocabEntriesCompanion Function({
      Value<String> word,
      Value<String> meaning,
      Value<String?> meaningId,
      Value<String> furigana,
      Value<String> romaji,
      Value<int> level,
      Value<int> rowid,
    });

class $$JlptVocabEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $JlptVocabEntriesTable> {
  $$JlptVocabEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get word => $composableBuilder(
    column: $table.word,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get meaning => $composableBuilder(
    column: $table.meaning,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get meaningId => $composableBuilder(
    column: $table.meaningId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get furigana => $composableBuilder(
    column: $table.furigana,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get romaji => $composableBuilder(
    column: $table.romaji,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );
}

class $$JlptVocabEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $JlptVocabEntriesTable> {
  $$JlptVocabEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get word => $composableBuilder(
    column: $table.word,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get meaning => $composableBuilder(
    column: $table.meaning,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get meaningId => $composableBuilder(
    column: $table.meaningId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get furigana => $composableBuilder(
    column: $table.furigana,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get romaji => $composableBuilder(
    column: $table.romaji,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$JlptVocabEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $JlptVocabEntriesTable> {
  $$JlptVocabEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get word =>
      $composableBuilder(column: $table.word, builder: (column) => column);

  GeneratedColumn<String> get meaning =>
      $composableBuilder(column: $table.meaning, builder: (column) => column);

  GeneratedColumn<String> get meaningId =>
      $composableBuilder(column: $table.meaningId, builder: (column) => column);

  GeneratedColumn<String> get furigana =>
      $composableBuilder(column: $table.furigana, builder: (column) => column);

  GeneratedColumn<String> get romaji =>
      $composableBuilder(column: $table.romaji, builder: (column) => column);

  GeneratedColumn<int> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);
}

class $$JlptVocabEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $JlptVocabEntriesTable,
          JlptVocabEntry,
          $$JlptVocabEntriesTableFilterComposer,
          $$JlptVocabEntriesTableOrderingComposer,
          $$JlptVocabEntriesTableAnnotationComposer,
          $$JlptVocabEntriesTableCreateCompanionBuilder,
          $$JlptVocabEntriesTableUpdateCompanionBuilder,
          (
            JlptVocabEntry,
            BaseReferences<
              _$AppDatabase,
              $JlptVocabEntriesTable,
              JlptVocabEntry
            >,
          ),
          JlptVocabEntry,
          PrefetchHooks Function()
        > {
  $$JlptVocabEntriesTableTableManager(
    _$AppDatabase db,
    $JlptVocabEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$JlptVocabEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$JlptVocabEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$JlptVocabEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> word = const Value.absent(),
                Value<String> meaning = const Value.absent(),
                Value<String?> meaningId = const Value.absent(),
                Value<String> furigana = const Value.absent(),
                Value<String> romaji = const Value.absent(),
                Value<int> level = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => JlptVocabEntriesCompanion(
                word: word,
                meaning: meaning,
                meaningId: meaningId,
                furigana: furigana,
                romaji: romaji,
                level: level,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String word,
                required String meaning,
                Value<String?> meaningId = const Value.absent(),
                required String furigana,
                required String romaji,
                required int level,
                Value<int> rowid = const Value.absent(),
              }) => JlptVocabEntriesCompanion.insert(
                word: word,
                meaning: meaning,
                meaningId: meaningId,
                furigana: furigana,
                romaji: romaji,
                level: level,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$JlptVocabEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $JlptVocabEntriesTable,
      JlptVocabEntry,
      $$JlptVocabEntriesTableFilterComposer,
      $$JlptVocabEntriesTableOrderingComposer,
      $$JlptVocabEntriesTableAnnotationComposer,
      $$JlptVocabEntriesTableCreateCompanionBuilder,
      $$JlptVocabEntriesTableUpdateCompanionBuilder,
      (
        JlptVocabEntry,
        BaseReferences<_$AppDatabase, $JlptVocabEntriesTable, JlptVocabEntry>,
      ),
      JlptVocabEntry,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$KanjiEntriesTableTableManager get kanjiEntries =>
      $$KanjiEntriesTableTableManager(_db, _db.kanjiEntries);
  $$VocabularyEntriesTableTableManager get vocabularyEntries =>
      $$VocabularyEntriesTableTableManager(_db, _db.vocabularyEntries);
  $$UserKanjiProgressEntriesTableTableManager get userKanjiProgressEntries =>
      $$UserKanjiProgressEntriesTableTableManager(
        _db,
        _db.userKanjiProgressEntries,
      );
  $$DailyProgressEntriesTableTableManager get dailyProgressEntries =>
      $$DailyProgressEntriesTableTableManager(_db, _db.dailyProgressEntries);
  $$QuizResultEntriesTableTableManager get quizResultEntries =>
      $$QuizResultEntriesTableTableManager(_db, _db.quizResultEntries);
  $$SimilarKanjiEntriesTableTableManager get similarKanjiEntries =>
      $$SimilarKanjiEntriesTableTableManager(_db, _db.similarKanjiEntries);
  $$JlptVocabEntriesTableTableManager get jlptVocabEntries =>
      $$JlptVocabEntriesTableTableManager(_db, _db.jlptVocabEntries);
}
