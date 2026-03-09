// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $DebtsTableTable extends DebtsTable
    with TableInfo<$DebtsTableTable, DebtsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DebtsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _creditorNameMeta = const VerificationMeta(
    'creditorName',
  );
  @override
  late final GeneratedColumn<String> creditorName = GeneratedColumn<String>(
    'creditor_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originalBalanceMeta = const VerificationMeta(
    'originalBalance',
  );
  @override
  late final GeneratedColumn<double> originalBalance = GeneratedColumn<double>(
    'original_balance',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currentBalanceMeta = const VerificationMeta(
    'currentBalance',
  );
  @override
  late final GeneratedColumn<double> currentBalance = GeneratedColumn<double>(
    'current_balance',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _aprMeta = const VerificationMeta('apr');
  @override
  late final GeneratedColumn<double> apr = GeneratedColumn<double>(
    'apr',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _minimumPaymentMeta = const VerificationMeta(
    'minimumPayment',
  );
  @override
  late final GeneratedColumn<double> minimumPayment = GeneratedColumn<double>(
    'minimum_payment',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
    'due_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _paymentFrequencyMeta = const VerificationMeta(
    'paymentFrequency',
  );
  @override
  late final GeneratedColumn<String> paymentFrequency = GeneratedColumn<String>(
    'payment_frequency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _tagsJsonMeta = const VerificationMeta(
    'tagsJson',
  );
  @override
  late final GeneratedColumn<String> tagsJson = GeneratedColumn<String>(
    'tags_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _financialTermsJsonMeta =
      const VerificationMeta('financialTermsJson');
  @override
  late final GeneratedColumn<String> financialTermsJson =
      GeneratedColumn<String>(
        'financial_terms_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('{}'),
      );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remindersEnabledMeta = const VerificationMeta(
    'remindersEnabled',
  );
  @override
  late final GeneratedColumn<bool> remindersEnabled = GeneratedColumn<bool>(
    'reminders_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("reminders_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _customPriorityMeta = const VerificationMeta(
    'customPriority',
  );
  @override
  late final GeneratedColumn<int> customPriority = GeneratedColumn<int>(
    'custom_priority',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    creditorName,
    type,
    currency,
    originalBalance,
    currentBalance,
    apr,
    minimumPayment,
    dueDate,
    paymentFrequency,
    createdAt,
    updatedAt,
    notes,
    tagsJson,
    financialTermsJson,
    status,
    remindersEnabled,
    customPriority,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'debts_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<DebtsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('creditor_name')) {
      context.handle(
        _creditorNameMeta,
        creditorName.isAcceptableOrUnknown(
          data['creditor_name']!,
          _creditorNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_creditorNameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    if (data.containsKey('original_balance')) {
      context.handle(
        _originalBalanceMeta,
        originalBalance.isAcceptableOrUnknown(
          data['original_balance']!,
          _originalBalanceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_originalBalanceMeta);
    }
    if (data.containsKey('current_balance')) {
      context.handle(
        _currentBalanceMeta,
        currentBalance.isAcceptableOrUnknown(
          data['current_balance']!,
          _currentBalanceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currentBalanceMeta);
    }
    if (data.containsKey('apr')) {
      context.handle(
        _aprMeta,
        apr.isAcceptableOrUnknown(data['apr']!, _aprMeta),
      );
    } else if (isInserting) {
      context.missing(_aprMeta);
    }
    if (data.containsKey('minimum_payment')) {
      context.handle(
        _minimumPaymentMeta,
        minimumPayment.isAcceptableOrUnknown(
          data['minimum_payment']!,
          _minimumPaymentMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_minimumPaymentMeta);
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    }
    if (data.containsKey('payment_frequency')) {
      context.handle(
        _paymentFrequencyMeta,
        paymentFrequency.isAcceptableOrUnknown(
          data['payment_frequency']!,
          _paymentFrequencyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_paymentFrequencyMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('tags_json')) {
      context.handle(
        _tagsJsonMeta,
        tagsJson.isAcceptableOrUnknown(data['tags_json']!, _tagsJsonMeta),
      );
    }
    if (data.containsKey('financial_terms_json')) {
      context.handle(
        _financialTermsJsonMeta,
        financialTermsJson.isAcceptableOrUnknown(
          data['financial_terms_json']!,
          _financialTermsJsonMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('reminders_enabled')) {
      context.handle(
        _remindersEnabledMeta,
        remindersEnabled.isAcceptableOrUnknown(
          data['reminders_enabled']!,
          _remindersEnabledMeta,
        ),
      );
    }
    if (data.containsKey('custom_priority')) {
      context.handle(
        _customPriorityMeta,
        customPriority.isAcceptableOrUnknown(
          data['custom_priority']!,
          _customPriorityMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DebtsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DebtsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      creditorName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}creditor_name'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      originalBalance: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}original_balance'],
      )!,
      currentBalance: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}current_balance'],
      )!,
      apr: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}apr'],
      )!,
      minimumPayment: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}minimum_payment'],
      )!,
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_date'],
      ),
      paymentFrequency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_frequency'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      tagsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tags_json'],
      )!,
      financialTermsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}financial_terms_json'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      remindersEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}reminders_enabled'],
      )!,
      customPriority: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}custom_priority'],
      )!,
    );
  }

  @override
  $DebtsTableTable createAlias(String alias) {
    return $DebtsTableTable(attachedDatabase, alias);
  }
}

class DebtsTableData extends DataClass implements Insertable<DebtsTableData> {
  final String id;
  final String title;
  final String creditorName;
  final String type;
  final String currency;
  final double originalBalance;
  final double currentBalance;
  final double apr;
  final double minimumPayment;
  final DateTime? dueDate;
  final String paymentFrequency;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String notes;
  final String tagsJson;
  final String financialTermsJson;
  final String status;
  final bool remindersEnabled;
  final int customPriority;
  const DebtsTableData({
    required this.id,
    required this.title,
    required this.creditorName,
    required this.type,
    required this.currency,
    required this.originalBalance,
    required this.currentBalance,
    required this.apr,
    required this.minimumPayment,
    this.dueDate,
    required this.paymentFrequency,
    required this.createdAt,
    required this.updatedAt,
    required this.notes,
    required this.tagsJson,
    required this.financialTermsJson,
    required this.status,
    required this.remindersEnabled,
    required this.customPriority,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['creditor_name'] = Variable<String>(creditorName);
    map['type'] = Variable<String>(type);
    map['currency'] = Variable<String>(currency);
    map['original_balance'] = Variable<double>(originalBalance);
    map['current_balance'] = Variable<double>(currentBalance);
    map['apr'] = Variable<double>(apr);
    map['minimum_payment'] = Variable<double>(minimumPayment);
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    map['payment_frequency'] = Variable<String>(paymentFrequency);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['notes'] = Variable<String>(notes);
    map['tags_json'] = Variable<String>(tagsJson);
    map['financial_terms_json'] = Variable<String>(financialTermsJson);
    map['status'] = Variable<String>(status);
    map['reminders_enabled'] = Variable<bool>(remindersEnabled);
    map['custom_priority'] = Variable<int>(customPriority);
    return map;
  }

  DebtsTableCompanion toCompanion(bool nullToAbsent) {
    return DebtsTableCompanion(
      id: Value(id),
      title: Value(title),
      creditorName: Value(creditorName),
      type: Value(type),
      currency: Value(currency),
      originalBalance: Value(originalBalance),
      currentBalance: Value(currentBalance),
      apr: Value(apr),
      minimumPayment: Value(minimumPayment),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      paymentFrequency: Value(paymentFrequency),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      notes: Value(notes),
      tagsJson: Value(tagsJson),
      financialTermsJson: Value(financialTermsJson),
      status: Value(status),
      remindersEnabled: Value(remindersEnabled),
      customPriority: Value(customPriority),
    );
  }

  factory DebtsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DebtsTableData(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      creditorName: serializer.fromJson<String>(json['creditorName']),
      type: serializer.fromJson<String>(json['type']),
      currency: serializer.fromJson<String>(json['currency']),
      originalBalance: serializer.fromJson<double>(json['originalBalance']),
      currentBalance: serializer.fromJson<double>(json['currentBalance']),
      apr: serializer.fromJson<double>(json['apr']),
      minimumPayment: serializer.fromJson<double>(json['minimumPayment']),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      paymentFrequency: serializer.fromJson<String>(json['paymentFrequency']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      notes: serializer.fromJson<String>(json['notes']),
      tagsJson: serializer.fromJson<String>(json['tagsJson']),
      financialTermsJson: serializer.fromJson<String>(
        json['financialTermsJson'],
      ),
      status: serializer.fromJson<String>(json['status']),
      remindersEnabled: serializer.fromJson<bool>(json['remindersEnabled']),
      customPriority: serializer.fromJson<int>(json['customPriority']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'creditorName': serializer.toJson<String>(creditorName),
      'type': serializer.toJson<String>(type),
      'currency': serializer.toJson<String>(currency),
      'originalBalance': serializer.toJson<double>(originalBalance),
      'currentBalance': serializer.toJson<double>(currentBalance),
      'apr': serializer.toJson<double>(apr),
      'minimumPayment': serializer.toJson<double>(minimumPayment),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'paymentFrequency': serializer.toJson<String>(paymentFrequency),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'notes': serializer.toJson<String>(notes),
      'tagsJson': serializer.toJson<String>(tagsJson),
      'financialTermsJson': serializer.toJson<String>(financialTermsJson),
      'status': serializer.toJson<String>(status),
      'remindersEnabled': serializer.toJson<bool>(remindersEnabled),
      'customPriority': serializer.toJson<int>(customPriority),
    };
  }

  DebtsTableData copyWith({
    String? id,
    String? title,
    String? creditorName,
    String? type,
    String? currency,
    double? originalBalance,
    double? currentBalance,
    double? apr,
    double? minimumPayment,
    Value<DateTime?> dueDate = const Value.absent(),
    String? paymentFrequency,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? notes,
    String? tagsJson,
    String? financialTermsJson,
    String? status,
    bool? remindersEnabled,
    int? customPriority,
  }) => DebtsTableData(
    id: id ?? this.id,
    title: title ?? this.title,
    creditorName: creditorName ?? this.creditorName,
    type: type ?? this.type,
    currency: currency ?? this.currency,
    originalBalance: originalBalance ?? this.originalBalance,
    currentBalance: currentBalance ?? this.currentBalance,
    apr: apr ?? this.apr,
    minimumPayment: minimumPayment ?? this.minimumPayment,
    dueDate: dueDate.present ? dueDate.value : this.dueDate,
    paymentFrequency: paymentFrequency ?? this.paymentFrequency,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    notes: notes ?? this.notes,
    tagsJson: tagsJson ?? this.tagsJson,
    financialTermsJson: financialTermsJson ?? this.financialTermsJson,
    status: status ?? this.status,
    remindersEnabled: remindersEnabled ?? this.remindersEnabled,
    customPriority: customPriority ?? this.customPriority,
  );
  DebtsTableData copyWithCompanion(DebtsTableCompanion data) {
    return DebtsTableData(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      creditorName: data.creditorName.present
          ? data.creditorName.value
          : this.creditorName,
      type: data.type.present ? data.type.value : this.type,
      currency: data.currency.present ? data.currency.value : this.currency,
      originalBalance: data.originalBalance.present
          ? data.originalBalance.value
          : this.originalBalance,
      currentBalance: data.currentBalance.present
          ? data.currentBalance.value
          : this.currentBalance,
      apr: data.apr.present ? data.apr.value : this.apr,
      minimumPayment: data.minimumPayment.present
          ? data.minimumPayment.value
          : this.minimumPayment,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      paymentFrequency: data.paymentFrequency.present
          ? data.paymentFrequency.value
          : this.paymentFrequency,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      notes: data.notes.present ? data.notes.value : this.notes,
      tagsJson: data.tagsJson.present ? data.tagsJson.value : this.tagsJson,
      financialTermsJson: data.financialTermsJson.present
          ? data.financialTermsJson.value
          : this.financialTermsJson,
      status: data.status.present ? data.status.value : this.status,
      remindersEnabled: data.remindersEnabled.present
          ? data.remindersEnabled.value
          : this.remindersEnabled,
      customPriority: data.customPriority.present
          ? data.customPriority.value
          : this.customPriority,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DebtsTableData(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('creditorName: $creditorName, ')
          ..write('type: $type, ')
          ..write('currency: $currency, ')
          ..write('originalBalance: $originalBalance, ')
          ..write('currentBalance: $currentBalance, ')
          ..write('apr: $apr, ')
          ..write('minimumPayment: $minimumPayment, ')
          ..write('dueDate: $dueDate, ')
          ..write('paymentFrequency: $paymentFrequency, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('notes: $notes, ')
          ..write('tagsJson: $tagsJson, ')
          ..write('financialTermsJson: $financialTermsJson, ')
          ..write('status: $status, ')
          ..write('remindersEnabled: $remindersEnabled, ')
          ..write('customPriority: $customPriority')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    creditorName,
    type,
    currency,
    originalBalance,
    currentBalance,
    apr,
    minimumPayment,
    dueDate,
    paymentFrequency,
    createdAt,
    updatedAt,
    notes,
    tagsJson,
    financialTermsJson,
    status,
    remindersEnabled,
    customPriority,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DebtsTableData &&
          other.id == this.id &&
          other.title == this.title &&
          other.creditorName == this.creditorName &&
          other.type == this.type &&
          other.currency == this.currency &&
          other.originalBalance == this.originalBalance &&
          other.currentBalance == this.currentBalance &&
          other.apr == this.apr &&
          other.minimumPayment == this.minimumPayment &&
          other.dueDate == this.dueDate &&
          other.paymentFrequency == this.paymentFrequency &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.notes == this.notes &&
          other.tagsJson == this.tagsJson &&
          other.financialTermsJson == this.financialTermsJson &&
          other.status == this.status &&
          other.remindersEnabled == this.remindersEnabled &&
          other.customPriority == this.customPriority);
}

class DebtsTableCompanion extends UpdateCompanion<DebtsTableData> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> creditorName;
  final Value<String> type;
  final Value<String> currency;
  final Value<double> originalBalance;
  final Value<double> currentBalance;
  final Value<double> apr;
  final Value<double> minimumPayment;
  final Value<DateTime?> dueDate;
  final Value<String> paymentFrequency;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> notes;
  final Value<String> tagsJson;
  final Value<String> financialTermsJson;
  final Value<String> status;
  final Value<bool> remindersEnabled;
  final Value<int> customPriority;
  final Value<int> rowid;
  const DebtsTableCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.creditorName = const Value.absent(),
    this.type = const Value.absent(),
    this.currency = const Value.absent(),
    this.originalBalance = const Value.absent(),
    this.currentBalance = const Value.absent(),
    this.apr = const Value.absent(),
    this.minimumPayment = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.paymentFrequency = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.notes = const Value.absent(),
    this.tagsJson = const Value.absent(),
    this.financialTermsJson = const Value.absent(),
    this.status = const Value.absent(),
    this.remindersEnabled = const Value.absent(),
    this.customPriority = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DebtsTableCompanion.insert({
    required String id,
    required String title,
    required String creditorName,
    required String type,
    required String currency,
    required double originalBalance,
    required double currentBalance,
    required double apr,
    required double minimumPayment,
    this.dueDate = const Value.absent(),
    required String paymentFrequency,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.notes = const Value.absent(),
    this.tagsJson = const Value.absent(),
    this.financialTermsJson = const Value.absent(),
    required String status,
    this.remindersEnabled = const Value.absent(),
    this.customPriority = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       creditorName = Value(creditorName),
       type = Value(type),
       currency = Value(currency),
       originalBalance = Value(originalBalance),
       currentBalance = Value(currentBalance),
       apr = Value(apr),
       minimumPayment = Value(minimumPayment),
       paymentFrequency = Value(paymentFrequency),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       status = Value(status);
  static Insertable<DebtsTableData> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? creditorName,
    Expression<String>? type,
    Expression<String>? currency,
    Expression<double>? originalBalance,
    Expression<double>? currentBalance,
    Expression<double>? apr,
    Expression<double>? minimumPayment,
    Expression<DateTime>? dueDate,
    Expression<String>? paymentFrequency,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? notes,
    Expression<String>? tagsJson,
    Expression<String>? financialTermsJson,
    Expression<String>? status,
    Expression<bool>? remindersEnabled,
    Expression<int>? customPriority,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (creditorName != null) 'creditor_name': creditorName,
      if (type != null) 'type': type,
      if (currency != null) 'currency': currency,
      if (originalBalance != null) 'original_balance': originalBalance,
      if (currentBalance != null) 'current_balance': currentBalance,
      if (apr != null) 'apr': apr,
      if (minimumPayment != null) 'minimum_payment': minimumPayment,
      if (dueDate != null) 'due_date': dueDate,
      if (paymentFrequency != null) 'payment_frequency': paymentFrequency,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (notes != null) 'notes': notes,
      if (tagsJson != null) 'tags_json': tagsJson,
      if (financialTermsJson != null)
        'financial_terms_json': financialTermsJson,
      if (status != null) 'status': status,
      if (remindersEnabled != null) 'reminders_enabled': remindersEnabled,
      if (customPriority != null) 'custom_priority': customPriority,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DebtsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? creditorName,
    Value<String>? type,
    Value<String>? currency,
    Value<double>? originalBalance,
    Value<double>? currentBalance,
    Value<double>? apr,
    Value<double>? minimumPayment,
    Value<DateTime?>? dueDate,
    Value<String>? paymentFrequency,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? notes,
    Value<String>? tagsJson,
    Value<String>? financialTermsJson,
    Value<String>? status,
    Value<bool>? remindersEnabled,
    Value<int>? customPriority,
    Value<int>? rowid,
  }) {
    return DebtsTableCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      creditorName: creditorName ?? this.creditorName,
      type: type ?? this.type,
      currency: currency ?? this.currency,
      originalBalance: originalBalance ?? this.originalBalance,
      currentBalance: currentBalance ?? this.currentBalance,
      apr: apr ?? this.apr,
      minimumPayment: minimumPayment ?? this.minimumPayment,
      dueDate: dueDate ?? this.dueDate,
      paymentFrequency: paymentFrequency ?? this.paymentFrequency,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notes: notes ?? this.notes,
      tagsJson: tagsJson ?? this.tagsJson,
      financialTermsJson: financialTermsJson ?? this.financialTermsJson,
      status: status ?? this.status,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
      customPriority: customPriority ?? this.customPriority,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (creditorName.present) {
      map['creditor_name'] = Variable<String>(creditorName.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (originalBalance.present) {
      map['original_balance'] = Variable<double>(originalBalance.value);
    }
    if (currentBalance.present) {
      map['current_balance'] = Variable<double>(currentBalance.value);
    }
    if (apr.present) {
      map['apr'] = Variable<double>(apr.value);
    }
    if (minimumPayment.present) {
      map['minimum_payment'] = Variable<double>(minimumPayment.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (paymentFrequency.present) {
      map['payment_frequency'] = Variable<String>(paymentFrequency.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (tagsJson.present) {
      map['tags_json'] = Variable<String>(tagsJson.value);
    }
    if (financialTermsJson.present) {
      map['financial_terms_json'] = Variable<String>(financialTermsJson.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (remindersEnabled.present) {
      map['reminders_enabled'] = Variable<bool>(remindersEnabled.value);
    }
    if (customPriority.present) {
      map['custom_priority'] = Variable<int>(customPriority.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DebtsTableCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('creditorName: $creditorName, ')
          ..write('type: $type, ')
          ..write('currency: $currency, ')
          ..write('originalBalance: $originalBalance, ')
          ..write('currentBalance: $currentBalance, ')
          ..write('apr: $apr, ')
          ..write('minimumPayment: $minimumPayment, ')
          ..write('dueDate: $dueDate, ')
          ..write('paymentFrequency: $paymentFrequency, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('notes: $notes, ')
          ..write('tagsJson: $tagsJson, ')
          ..write('financialTermsJson: $financialTermsJson, ')
          ..write('status: $status, ')
          ..write('remindersEnabled: $remindersEnabled, ')
          ..write('customPriority: $customPriority, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PaymentsTableTable extends PaymentsTable
    with TableInfo<$PaymentsTableTable, PaymentsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaymentsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _debtIdMeta = const VerificationMeta('debtId');
  @override
  late final GeneratedColumn<String> debtId = GeneratedColumn<String>(
    'debt_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES debts_table (id)',
    ),
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _methodMeta = const VerificationMeta('method');
  @override
  late final GeneratedColumn<String> method = GeneratedColumn<String>(
    'method',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceTypeMeta = const VerificationMeta(
    'sourceType',
  );
  @override
  late final GeneratedColumn<String> sourceType = GeneratedColumn<String>(
    'source_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _tagsJsonMeta = const VerificationMeta(
    'tagsJson',
  );
  @override
  late final GeneratedColumn<String> tagsJson = GeneratedColumn<String>(
    'tags_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    debtId,
    amount,
    date,
    method,
    sourceType,
    notes,
    tagsJson,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payments_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<PaymentsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('debt_id')) {
      context.handle(
        _debtIdMeta,
        debtId.isAcceptableOrUnknown(data['debt_id']!, _debtIdMeta),
      );
    } else if (isInserting) {
      context.missing(_debtIdMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('method')) {
      context.handle(
        _methodMeta,
        method.isAcceptableOrUnknown(data['method']!, _methodMeta),
      );
    }
    if (data.containsKey('source_type')) {
      context.handle(
        _sourceTypeMeta,
        sourceType.isAcceptableOrUnknown(data['source_type']!, _sourceTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceTypeMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('tags_json')) {
      context.handle(
        _tagsJsonMeta,
        tagsJson.isAcceptableOrUnknown(data['tags_json']!, _tagsJsonMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PaymentsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PaymentsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      debtId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}debt_id'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      method: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}method'],
      ),
      sourceType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_type'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      tagsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tags_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PaymentsTableTable createAlias(String alias) {
    return $PaymentsTableTable(attachedDatabase, alias);
  }
}

class PaymentsTableData extends DataClass
    implements Insertable<PaymentsTableData> {
  final String id;
  final String debtId;
  final double amount;
  final DateTime date;
  final String? method;
  final String sourceType;
  final String notes;
  final String tagsJson;
  final DateTime createdAt;
  const PaymentsTableData({
    required this.id,
    required this.debtId,
    required this.amount,
    required this.date,
    this.method,
    required this.sourceType,
    required this.notes,
    required this.tagsJson,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['debt_id'] = Variable<String>(debtId);
    map['amount'] = Variable<double>(amount);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || method != null) {
      map['method'] = Variable<String>(method);
    }
    map['source_type'] = Variable<String>(sourceType);
    map['notes'] = Variable<String>(notes);
    map['tags_json'] = Variable<String>(tagsJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PaymentsTableCompanion toCompanion(bool nullToAbsent) {
    return PaymentsTableCompanion(
      id: Value(id),
      debtId: Value(debtId),
      amount: Value(amount),
      date: Value(date),
      method: method == null && nullToAbsent
          ? const Value.absent()
          : Value(method),
      sourceType: Value(sourceType),
      notes: Value(notes),
      tagsJson: Value(tagsJson),
      createdAt: Value(createdAt),
    );
  }

  factory PaymentsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PaymentsTableData(
      id: serializer.fromJson<String>(json['id']),
      debtId: serializer.fromJson<String>(json['debtId']),
      amount: serializer.fromJson<double>(json['amount']),
      date: serializer.fromJson<DateTime>(json['date']),
      method: serializer.fromJson<String?>(json['method']),
      sourceType: serializer.fromJson<String>(json['sourceType']),
      notes: serializer.fromJson<String>(json['notes']),
      tagsJson: serializer.fromJson<String>(json['tagsJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'debtId': serializer.toJson<String>(debtId),
      'amount': serializer.toJson<double>(amount),
      'date': serializer.toJson<DateTime>(date),
      'method': serializer.toJson<String?>(method),
      'sourceType': serializer.toJson<String>(sourceType),
      'notes': serializer.toJson<String>(notes),
      'tagsJson': serializer.toJson<String>(tagsJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PaymentsTableData copyWith({
    String? id,
    String? debtId,
    double? amount,
    DateTime? date,
    Value<String?> method = const Value.absent(),
    String? sourceType,
    String? notes,
    String? tagsJson,
    DateTime? createdAt,
  }) => PaymentsTableData(
    id: id ?? this.id,
    debtId: debtId ?? this.debtId,
    amount: amount ?? this.amount,
    date: date ?? this.date,
    method: method.present ? method.value : this.method,
    sourceType: sourceType ?? this.sourceType,
    notes: notes ?? this.notes,
    tagsJson: tagsJson ?? this.tagsJson,
    createdAt: createdAt ?? this.createdAt,
  );
  PaymentsTableData copyWithCompanion(PaymentsTableCompanion data) {
    return PaymentsTableData(
      id: data.id.present ? data.id.value : this.id,
      debtId: data.debtId.present ? data.debtId.value : this.debtId,
      amount: data.amount.present ? data.amount.value : this.amount,
      date: data.date.present ? data.date.value : this.date,
      method: data.method.present ? data.method.value : this.method,
      sourceType: data.sourceType.present
          ? data.sourceType.value
          : this.sourceType,
      notes: data.notes.present ? data.notes.value : this.notes,
      tagsJson: data.tagsJson.present ? data.tagsJson.value : this.tagsJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PaymentsTableData(')
          ..write('id: $id, ')
          ..write('debtId: $debtId, ')
          ..write('amount: $amount, ')
          ..write('date: $date, ')
          ..write('method: $method, ')
          ..write('sourceType: $sourceType, ')
          ..write('notes: $notes, ')
          ..write('tagsJson: $tagsJson, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    debtId,
    amount,
    date,
    method,
    sourceType,
    notes,
    tagsJson,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PaymentsTableData &&
          other.id == this.id &&
          other.debtId == this.debtId &&
          other.amount == this.amount &&
          other.date == this.date &&
          other.method == this.method &&
          other.sourceType == this.sourceType &&
          other.notes == this.notes &&
          other.tagsJson == this.tagsJson &&
          other.createdAt == this.createdAt);
}

class PaymentsTableCompanion extends UpdateCompanion<PaymentsTableData> {
  final Value<String> id;
  final Value<String> debtId;
  final Value<double> amount;
  final Value<DateTime> date;
  final Value<String?> method;
  final Value<String> sourceType;
  final Value<String> notes;
  final Value<String> tagsJson;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const PaymentsTableCompanion({
    this.id = const Value.absent(),
    this.debtId = const Value.absent(),
    this.amount = const Value.absent(),
    this.date = const Value.absent(),
    this.method = const Value.absent(),
    this.sourceType = const Value.absent(),
    this.notes = const Value.absent(),
    this.tagsJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PaymentsTableCompanion.insert({
    required String id,
    required String debtId,
    required double amount,
    required DateTime date,
    this.method = const Value.absent(),
    required String sourceType,
    this.notes = const Value.absent(),
    this.tagsJson = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       debtId = Value(debtId),
       amount = Value(amount),
       date = Value(date),
       sourceType = Value(sourceType),
       createdAt = Value(createdAt);
  static Insertable<PaymentsTableData> custom({
    Expression<String>? id,
    Expression<String>? debtId,
    Expression<double>? amount,
    Expression<DateTime>? date,
    Expression<String>? method,
    Expression<String>? sourceType,
    Expression<String>? notes,
    Expression<String>? tagsJson,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (debtId != null) 'debt_id': debtId,
      if (amount != null) 'amount': amount,
      if (date != null) 'date': date,
      if (method != null) 'method': method,
      if (sourceType != null) 'source_type': sourceType,
      if (notes != null) 'notes': notes,
      if (tagsJson != null) 'tags_json': tagsJson,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PaymentsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? debtId,
    Value<double>? amount,
    Value<DateTime>? date,
    Value<String?>? method,
    Value<String>? sourceType,
    Value<String>? notes,
    Value<String>? tagsJson,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return PaymentsTableCompanion(
      id: id ?? this.id,
      debtId: debtId ?? this.debtId,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      method: method ?? this.method,
      sourceType: sourceType ?? this.sourceType,
      notes: notes ?? this.notes,
      tagsJson: tagsJson ?? this.tagsJson,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (debtId.present) {
      map['debt_id'] = Variable<String>(debtId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (method.present) {
      map['method'] = Variable<String>(method.value);
    }
    if (sourceType.present) {
      map['source_type'] = Variable<String>(sourceType.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (tagsJson.present) {
      map['tags_json'] = Variable<String>(tagsJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PaymentsTableCompanion(')
          ..write('id: $id, ')
          ..write('debtId: $debtId, ')
          ..write('amount: $amount, ')
          ..write('date: $date, ')
          ..write('method: $method, ')
          ..write('sourceType: $sourceType, ')
          ..write('notes: $notes, ')
          ..write('tagsJson: $tagsJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ImportedDocumentsTableTable extends ImportedDocumentsTable
    with TableInfo<$ImportedDocumentsTableTable, ImportedDocumentsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImportedDocumentsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localPathMeta = const VerificationMeta(
    'localPath',
  );
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
    'local_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _storageRefMeta = const VerificationMeta(
    'storageRef',
  );
  @override
  late final GeneratedColumn<String> storageRef = GeneratedColumn<String>(
    'storage_ref',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceTypeMeta = const VerificationMeta(
    'sourceType',
  );
  @override
  late final GeneratedColumn<String> sourceType = GeneratedColumn<String>(
    'source_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mimeTypeMeta = const VerificationMeta(
    'mimeType',
  );
  @override
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
    'mime_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lifecycleStateMeta = const VerificationMeta(
    'lifecycleState',
  );
  @override
  late final GeneratedColumn<String> lifecycleState = GeneratedColumn<String>(
    'lifecycle_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('imported'),
  );
  static const VerificationMeta _linkedDebtIdMeta = const VerificationMeta(
    'linkedDebtId',
  );
  @override
  late final GeneratedColumn<String> linkedDebtId = GeneratedColumn<String>(
    'linked_debt_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rawOcrTextMeta = const VerificationMeta(
    'rawOcrText',
  );
  @override
  late final GeneratedColumn<String> rawOcrText = GeneratedColumn<String>(
    'raw_ocr_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _parseStatusMeta = const VerificationMeta(
    'parseStatus',
  );
  @override
  late final GeneratedColumn<String> parseStatus = GeneratedColumn<String>(
    'parse_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _parseVersionMeta = const VerificationMeta(
    'parseVersion',
  );
  @override
  late final GeneratedColumn<String> parseVersion = GeneratedColumn<String>(
    'parse_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _retentionExpiresAtMeta =
      const VerificationMeta('retentionExpiresAt');
  @override
  late final GeneratedColumn<DateTime> retentionExpiresAt =
      GeneratedColumn<DateTime>(
        'retention_expires_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _rawOcrExpiresAtMeta = const VerificationMeta(
    'rawOcrExpiresAt',
  );
  @override
  late final GeneratedColumn<DateTime> rawOcrExpiresAt =
      GeneratedColumn<DateTime>(
        'raw_ocr_expires_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _processedAtMeta = const VerificationMeta(
    'processedAt',
  );
  @override
  late final GeneratedColumn<DateTime> processedAt = GeneratedColumn<DateTime>(
    'processed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _linkedAtMeta = const VerificationMeta(
    'linkedAt',
  );
  @override
  late final GeneratedColumn<DateTime> linkedAt = GeneratedColumn<DateTime>(
    'linked_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pendingDeletionAtMeta = const VerificationMeta(
    'pendingDeletionAt',
  );
  @override
  late final GeneratedColumn<DateTime> pendingDeletionAt =
      GeneratedColumn<DateTime>(
        'pending_deletion_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _purgedAtMeta = const VerificationMeta(
    'purgedAt',
  );
  @override
  late final GeneratedColumn<DateTime> purgedAt = GeneratedColumn<DateTime>(
    'purged_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _encryptedAtMeta = const VerificationMeta(
    'encryptedAt',
  );
  @override
  late final GeneratedColumn<DateTime> encryptedAt = GeneratedColumn<DateTime>(
    'encrypted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hasRawOcrTextMeta = const VerificationMeta(
    'hasRawOcrText',
  );
  @override
  late final GeneratedColumn<bool> hasRawOcrText = GeneratedColumn<bool>(
    'has_raw_ocr_text',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_raw_ocr_text" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    localPath,
    storageRef,
    sourceType,
    mimeType,
    createdAt,
    lifecycleState,
    linkedDebtId,
    rawOcrText,
    parseStatus,
    parseVersion,
    deleted,
    retentionExpiresAt,
    rawOcrExpiresAt,
    processedAt,
    linkedAt,
    pendingDeletionAt,
    purgedAt,
    encryptedAt,
    hasRawOcrText,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'imported_documents_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<ImportedDocumentsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('local_path')) {
      context.handle(
        _localPathMeta,
        localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta),
      );
    }
    if (data.containsKey('storage_ref')) {
      context.handle(
        _storageRefMeta,
        storageRef.isAcceptableOrUnknown(data['storage_ref']!, _storageRefMeta),
      );
    }
    if (data.containsKey('source_type')) {
      context.handle(
        _sourceTypeMeta,
        sourceType.isAcceptableOrUnknown(data['source_type']!, _sourceTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceTypeMeta);
    }
    if (data.containsKey('mime_type')) {
      context.handle(
        _mimeTypeMeta,
        mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_mimeTypeMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('lifecycle_state')) {
      context.handle(
        _lifecycleStateMeta,
        lifecycleState.isAcceptableOrUnknown(
          data['lifecycle_state']!,
          _lifecycleStateMeta,
        ),
      );
    }
    if (data.containsKey('linked_debt_id')) {
      context.handle(
        _linkedDebtIdMeta,
        linkedDebtId.isAcceptableOrUnknown(
          data['linked_debt_id']!,
          _linkedDebtIdMeta,
        ),
      );
    }
    if (data.containsKey('raw_ocr_text')) {
      context.handle(
        _rawOcrTextMeta,
        rawOcrText.isAcceptableOrUnknown(
          data['raw_ocr_text']!,
          _rawOcrTextMeta,
        ),
      );
    }
    if (data.containsKey('parse_status')) {
      context.handle(
        _parseStatusMeta,
        parseStatus.isAcceptableOrUnknown(
          data['parse_status']!,
          _parseStatusMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_parseStatusMeta);
    }
    if (data.containsKey('parse_version')) {
      context.handle(
        _parseVersionMeta,
        parseVersion.isAcceptableOrUnknown(
          data['parse_version']!,
          _parseVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_parseVersionMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('retention_expires_at')) {
      context.handle(
        _retentionExpiresAtMeta,
        retentionExpiresAt.isAcceptableOrUnknown(
          data['retention_expires_at']!,
          _retentionExpiresAtMeta,
        ),
      );
    }
    if (data.containsKey('raw_ocr_expires_at')) {
      context.handle(
        _rawOcrExpiresAtMeta,
        rawOcrExpiresAt.isAcceptableOrUnknown(
          data['raw_ocr_expires_at']!,
          _rawOcrExpiresAtMeta,
        ),
      );
    }
    if (data.containsKey('processed_at')) {
      context.handle(
        _processedAtMeta,
        processedAt.isAcceptableOrUnknown(
          data['processed_at']!,
          _processedAtMeta,
        ),
      );
    }
    if (data.containsKey('linked_at')) {
      context.handle(
        _linkedAtMeta,
        linkedAt.isAcceptableOrUnknown(data['linked_at']!, _linkedAtMeta),
      );
    }
    if (data.containsKey('pending_deletion_at')) {
      context.handle(
        _pendingDeletionAtMeta,
        pendingDeletionAt.isAcceptableOrUnknown(
          data['pending_deletion_at']!,
          _pendingDeletionAtMeta,
        ),
      );
    }
    if (data.containsKey('purged_at')) {
      context.handle(
        _purgedAtMeta,
        purgedAt.isAcceptableOrUnknown(data['purged_at']!, _purgedAtMeta),
      );
    }
    if (data.containsKey('encrypted_at')) {
      context.handle(
        _encryptedAtMeta,
        encryptedAt.isAcceptableOrUnknown(
          data['encrypted_at']!,
          _encryptedAtMeta,
        ),
      );
    }
    if (data.containsKey('has_raw_ocr_text')) {
      context.handle(
        _hasRawOcrTextMeta,
        hasRawOcrText.isAcceptableOrUnknown(
          data['has_raw_ocr_text']!,
          _hasRawOcrTextMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ImportedDocumentsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ImportedDocumentsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      localPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_path'],
      )!,
      storageRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}storage_ref'],
      ),
      sourceType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_type'],
      )!,
      mimeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime_type'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      lifecycleState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lifecycle_state'],
      )!,
      linkedDebtId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}linked_debt_id'],
      ),
      rawOcrText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_ocr_text'],
      ),
      parseStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parse_status'],
      )!,
      parseVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parse_version'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      retentionExpiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}retention_expires_at'],
      ),
      rawOcrExpiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}raw_ocr_expires_at'],
      ),
      processedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}processed_at'],
      ),
      linkedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}linked_at'],
      ),
      pendingDeletionAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}pending_deletion_at'],
      ),
      purgedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}purged_at'],
      ),
      encryptedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}encrypted_at'],
      ),
      hasRawOcrText: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_raw_ocr_text'],
      )!,
    );
  }

  @override
  $ImportedDocumentsTableTable createAlias(String alias) {
    return $ImportedDocumentsTableTable(attachedDatabase, alias);
  }
}

class ImportedDocumentsTableData extends DataClass
    implements Insertable<ImportedDocumentsTableData> {
  final String id;
  final String localPath;
  final String? storageRef;
  final String sourceType;
  final String mimeType;
  final DateTime createdAt;
  final String lifecycleState;
  final String? linkedDebtId;
  final String? rawOcrText;
  final String parseStatus;
  final String parseVersion;
  final bool deleted;
  final DateTime? retentionExpiresAt;
  final DateTime? rawOcrExpiresAt;
  final DateTime? processedAt;
  final DateTime? linkedAt;
  final DateTime? pendingDeletionAt;
  final DateTime? purgedAt;
  final DateTime? encryptedAt;
  final bool hasRawOcrText;
  const ImportedDocumentsTableData({
    required this.id,
    required this.localPath,
    this.storageRef,
    required this.sourceType,
    required this.mimeType,
    required this.createdAt,
    required this.lifecycleState,
    this.linkedDebtId,
    this.rawOcrText,
    required this.parseStatus,
    required this.parseVersion,
    required this.deleted,
    this.retentionExpiresAt,
    this.rawOcrExpiresAt,
    this.processedAt,
    this.linkedAt,
    this.pendingDeletionAt,
    this.purgedAt,
    this.encryptedAt,
    required this.hasRawOcrText,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['local_path'] = Variable<String>(localPath);
    if (!nullToAbsent || storageRef != null) {
      map['storage_ref'] = Variable<String>(storageRef);
    }
    map['source_type'] = Variable<String>(sourceType);
    map['mime_type'] = Variable<String>(mimeType);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['lifecycle_state'] = Variable<String>(lifecycleState);
    if (!nullToAbsent || linkedDebtId != null) {
      map['linked_debt_id'] = Variable<String>(linkedDebtId);
    }
    if (!nullToAbsent || rawOcrText != null) {
      map['raw_ocr_text'] = Variable<String>(rawOcrText);
    }
    map['parse_status'] = Variable<String>(parseStatus);
    map['parse_version'] = Variable<String>(parseVersion);
    map['deleted'] = Variable<bool>(deleted);
    if (!nullToAbsent || retentionExpiresAt != null) {
      map['retention_expires_at'] = Variable<DateTime>(retentionExpiresAt);
    }
    if (!nullToAbsent || rawOcrExpiresAt != null) {
      map['raw_ocr_expires_at'] = Variable<DateTime>(rawOcrExpiresAt);
    }
    if (!nullToAbsent || processedAt != null) {
      map['processed_at'] = Variable<DateTime>(processedAt);
    }
    if (!nullToAbsent || linkedAt != null) {
      map['linked_at'] = Variable<DateTime>(linkedAt);
    }
    if (!nullToAbsent || pendingDeletionAt != null) {
      map['pending_deletion_at'] = Variable<DateTime>(pendingDeletionAt);
    }
    if (!nullToAbsent || purgedAt != null) {
      map['purged_at'] = Variable<DateTime>(purgedAt);
    }
    if (!nullToAbsent || encryptedAt != null) {
      map['encrypted_at'] = Variable<DateTime>(encryptedAt);
    }
    map['has_raw_ocr_text'] = Variable<bool>(hasRawOcrText);
    return map;
  }

  ImportedDocumentsTableCompanion toCompanion(bool nullToAbsent) {
    return ImportedDocumentsTableCompanion(
      id: Value(id),
      localPath: Value(localPath),
      storageRef: storageRef == null && nullToAbsent
          ? const Value.absent()
          : Value(storageRef),
      sourceType: Value(sourceType),
      mimeType: Value(mimeType),
      createdAt: Value(createdAt),
      lifecycleState: Value(lifecycleState),
      linkedDebtId: linkedDebtId == null && nullToAbsent
          ? const Value.absent()
          : Value(linkedDebtId),
      rawOcrText: rawOcrText == null && nullToAbsent
          ? const Value.absent()
          : Value(rawOcrText),
      parseStatus: Value(parseStatus),
      parseVersion: Value(parseVersion),
      deleted: Value(deleted),
      retentionExpiresAt: retentionExpiresAt == null && nullToAbsent
          ? const Value.absent()
          : Value(retentionExpiresAt),
      rawOcrExpiresAt: rawOcrExpiresAt == null && nullToAbsent
          ? const Value.absent()
          : Value(rawOcrExpiresAt),
      processedAt: processedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(processedAt),
      linkedAt: linkedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(linkedAt),
      pendingDeletionAt: pendingDeletionAt == null && nullToAbsent
          ? const Value.absent()
          : Value(pendingDeletionAt),
      purgedAt: purgedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(purgedAt),
      encryptedAt: encryptedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(encryptedAt),
      hasRawOcrText: Value(hasRawOcrText),
    );
  }

  factory ImportedDocumentsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ImportedDocumentsTableData(
      id: serializer.fromJson<String>(json['id']),
      localPath: serializer.fromJson<String>(json['localPath']),
      storageRef: serializer.fromJson<String?>(json['storageRef']),
      sourceType: serializer.fromJson<String>(json['sourceType']),
      mimeType: serializer.fromJson<String>(json['mimeType']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lifecycleState: serializer.fromJson<String>(json['lifecycleState']),
      linkedDebtId: serializer.fromJson<String?>(json['linkedDebtId']),
      rawOcrText: serializer.fromJson<String?>(json['rawOcrText']),
      parseStatus: serializer.fromJson<String>(json['parseStatus']),
      parseVersion: serializer.fromJson<String>(json['parseVersion']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      retentionExpiresAt: serializer.fromJson<DateTime?>(
        json['retentionExpiresAt'],
      ),
      rawOcrExpiresAt: serializer.fromJson<DateTime?>(json['rawOcrExpiresAt']),
      processedAt: serializer.fromJson<DateTime?>(json['processedAt']),
      linkedAt: serializer.fromJson<DateTime?>(json['linkedAt']),
      pendingDeletionAt: serializer.fromJson<DateTime?>(
        json['pendingDeletionAt'],
      ),
      purgedAt: serializer.fromJson<DateTime?>(json['purgedAt']),
      encryptedAt: serializer.fromJson<DateTime?>(json['encryptedAt']),
      hasRawOcrText: serializer.fromJson<bool>(json['hasRawOcrText']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'localPath': serializer.toJson<String>(localPath),
      'storageRef': serializer.toJson<String?>(storageRef),
      'sourceType': serializer.toJson<String>(sourceType),
      'mimeType': serializer.toJson<String>(mimeType),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lifecycleState': serializer.toJson<String>(lifecycleState),
      'linkedDebtId': serializer.toJson<String?>(linkedDebtId),
      'rawOcrText': serializer.toJson<String?>(rawOcrText),
      'parseStatus': serializer.toJson<String>(parseStatus),
      'parseVersion': serializer.toJson<String>(parseVersion),
      'deleted': serializer.toJson<bool>(deleted),
      'retentionExpiresAt': serializer.toJson<DateTime?>(retentionExpiresAt),
      'rawOcrExpiresAt': serializer.toJson<DateTime?>(rawOcrExpiresAt),
      'processedAt': serializer.toJson<DateTime?>(processedAt),
      'linkedAt': serializer.toJson<DateTime?>(linkedAt),
      'pendingDeletionAt': serializer.toJson<DateTime?>(pendingDeletionAt),
      'purgedAt': serializer.toJson<DateTime?>(purgedAt),
      'encryptedAt': serializer.toJson<DateTime?>(encryptedAt),
      'hasRawOcrText': serializer.toJson<bool>(hasRawOcrText),
    };
  }

  ImportedDocumentsTableData copyWith({
    String? id,
    String? localPath,
    Value<String?> storageRef = const Value.absent(),
    String? sourceType,
    String? mimeType,
    DateTime? createdAt,
    String? lifecycleState,
    Value<String?> linkedDebtId = const Value.absent(),
    Value<String?> rawOcrText = const Value.absent(),
    String? parseStatus,
    String? parseVersion,
    bool? deleted,
    Value<DateTime?> retentionExpiresAt = const Value.absent(),
    Value<DateTime?> rawOcrExpiresAt = const Value.absent(),
    Value<DateTime?> processedAt = const Value.absent(),
    Value<DateTime?> linkedAt = const Value.absent(),
    Value<DateTime?> pendingDeletionAt = const Value.absent(),
    Value<DateTime?> purgedAt = const Value.absent(),
    Value<DateTime?> encryptedAt = const Value.absent(),
    bool? hasRawOcrText,
  }) => ImportedDocumentsTableData(
    id: id ?? this.id,
    localPath: localPath ?? this.localPath,
    storageRef: storageRef.present ? storageRef.value : this.storageRef,
    sourceType: sourceType ?? this.sourceType,
    mimeType: mimeType ?? this.mimeType,
    createdAt: createdAt ?? this.createdAt,
    lifecycleState: lifecycleState ?? this.lifecycleState,
    linkedDebtId: linkedDebtId.present ? linkedDebtId.value : this.linkedDebtId,
    rawOcrText: rawOcrText.present ? rawOcrText.value : this.rawOcrText,
    parseStatus: parseStatus ?? this.parseStatus,
    parseVersion: parseVersion ?? this.parseVersion,
    deleted: deleted ?? this.deleted,
    retentionExpiresAt: retentionExpiresAt.present
        ? retentionExpiresAt.value
        : this.retentionExpiresAt,
    rawOcrExpiresAt: rawOcrExpiresAt.present
        ? rawOcrExpiresAt.value
        : this.rawOcrExpiresAt,
    processedAt: processedAt.present ? processedAt.value : this.processedAt,
    linkedAt: linkedAt.present ? linkedAt.value : this.linkedAt,
    pendingDeletionAt: pendingDeletionAt.present
        ? pendingDeletionAt.value
        : this.pendingDeletionAt,
    purgedAt: purgedAt.present ? purgedAt.value : this.purgedAt,
    encryptedAt: encryptedAt.present ? encryptedAt.value : this.encryptedAt,
    hasRawOcrText: hasRawOcrText ?? this.hasRawOcrText,
  );
  ImportedDocumentsTableData copyWithCompanion(
    ImportedDocumentsTableCompanion data,
  ) {
    return ImportedDocumentsTableData(
      id: data.id.present ? data.id.value : this.id,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      storageRef: data.storageRef.present
          ? data.storageRef.value
          : this.storageRef,
      sourceType: data.sourceType.present
          ? data.sourceType.value
          : this.sourceType,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lifecycleState: data.lifecycleState.present
          ? data.lifecycleState.value
          : this.lifecycleState,
      linkedDebtId: data.linkedDebtId.present
          ? data.linkedDebtId.value
          : this.linkedDebtId,
      rawOcrText: data.rawOcrText.present
          ? data.rawOcrText.value
          : this.rawOcrText,
      parseStatus: data.parseStatus.present
          ? data.parseStatus.value
          : this.parseStatus,
      parseVersion: data.parseVersion.present
          ? data.parseVersion.value
          : this.parseVersion,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      retentionExpiresAt: data.retentionExpiresAt.present
          ? data.retentionExpiresAt.value
          : this.retentionExpiresAt,
      rawOcrExpiresAt: data.rawOcrExpiresAt.present
          ? data.rawOcrExpiresAt.value
          : this.rawOcrExpiresAt,
      processedAt: data.processedAt.present
          ? data.processedAt.value
          : this.processedAt,
      linkedAt: data.linkedAt.present ? data.linkedAt.value : this.linkedAt,
      pendingDeletionAt: data.pendingDeletionAt.present
          ? data.pendingDeletionAt.value
          : this.pendingDeletionAt,
      purgedAt: data.purgedAt.present ? data.purgedAt.value : this.purgedAt,
      encryptedAt: data.encryptedAt.present
          ? data.encryptedAt.value
          : this.encryptedAt,
      hasRawOcrText: data.hasRawOcrText.present
          ? data.hasRawOcrText.value
          : this.hasRawOcrText,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ImportedDocumentsTableData(')
          ..write('id: $id, ')
          ..write('localPath: $localPath, ')
          ..write('storageRef: $storageRef, ')
          ..write('sourceType: $sourceType, ')
          ..write('mimeType: $mimeType, ')
          ..write('createdAt: $createdAt, ')
          ..write('lifecycleState: $lifecycleState, ')
          ..write('linkedDebtId: $linkedDebtId, ')
          ..write('rawOcrText: $rawOcrText, ')
          ..write('parseStatus: $parseStatus, ')
          ..write('parseVersion: $parseVersion, ')
          ..write('deleted: $deleted, ')
          ..write('retentionExpiresAt: $retentionExpiresAt, ')
          ..write('rawOcrExpiresAt: $rawOcrExpiresAt, ')
          ..write('processedAt: $processedAt, ')
          ..write('linkedAt: $linkedAt, ')
          ..write('pendingDeletionAt: $pendingDeletionAt, ')
          ..write('purgedAt: $purgedAt, ')
          ..write('encryptedAt: $encryptedAt, ')
          ..write('hasRawOcrText: $hasRawOcrText')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    localPath,
    storageRef,
    sourceType,
    mimeType,
    createdAt,
    lifecycleState,
    linkedDebtId,
    rawOcrText,
    parseStatus,
    parseVersion,
    deleted,
    retentionExpiresAt,
    rawOcrExpiresAt,
    processedAt,
    linkedAt,
    pendingDeletionAt,
    purgedAt,
    encryptedAt,
    hasRawOcrText,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ImportedDocumentsTableData &&
          other.id == this.id &&
          other.localPath == this.localPath &&
          other.storageRef == this.storageRef &&
          other.sourceType == this.sourceType &&
          other.mimeType == this.mimeType &&
          other.createdAt == this.createdAt &&
          other.lifecycleState == this.lifecycleState &&
          other.linkedDebtId == this.linkedDebtId &&
          other.rawOcrText == this.rawOcrText &&
          other.parseStatus == this.parseStatus &&
          other.parseVersion == this.parseVersion &&
          other.deleted == this.deleted &&
          other.retentionExpiresAt == this.retentionExpiresAt &&
          other.rawOcrExpiresAt == this.rawOcrExpiresAt &&
          other.processedAt == this.processedAt &&
          other.linkedAt == this.linkedAt &&
          other.pendingDeletionAt == this.pendingDeletionAt &&
          other.purgedAt == this.purgedAt &&
          other.encryptedAt == this.encryptedAt &&
          other.hasRawOcrText == this.hasRawOcrText);
}

class ImportedDocumentsTableCompanion
    extends UpdateCompanion<ImportedDocumentsTableData> {
  final Value<String> id;
  final Value<String> localPath;
  final Value<String?> storageRef;
  final Value<String> sourceType;
  final Value<String> mimeType;
  final Value<DateTime> createdAt;
  final Value<String> lifecycleState;
  final Value<String?> linkedDebtId;
  final Value<String?> rawOcrText;
  final Value<String> parseStatus;
  final Value<String> parseVersion;
  final Value<bool> deleted;
  final Value<DateTime?> retentionExpiresAt;
  final Value<DateTime?> rawOcrExpiresAt;
  final Value<DateTime?> processedAt;
  final Value<DateTime?> linkedAt;
  final Value<DateTime?> pendingDeletionAt;
  final Value<DateTime?> purgedAt;
  final Value<DateTime?> encryptedAt;
  final Value<bool> hasRawOcrText;
  final Value<int> rowid;
  const ImportedDocumentsTableCompanion({
    this.id = const Value.absent(),
    this.localPath = const Value.absent(),
    this.storageRef = const Value.absent(),
    this.sourceType = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lifecycleState = const Value.absent(),
    this.linkedDebtId = const Value.absent(),
    this.rawOcrText = const Value.absent(),
    this.parseStatus = const Value.absent(),
    this.parseVersion = const Value.absent(),
    this.deleted = const Value.absent(),
    this.retentionExpiresAt = const Value.absent(),
    this.rawOcrExpiresAt = const Value.absent(),
    this.processedAt = const Value.absent(),
    this.linkedAt = const Value.absent(),
    this.pendingDeletionAt = const Value.absent(),
    this.purgedAt = const Value.absent(),
    this.encryptedAt = const Value.absent(),
    this.hasRawOcrText = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ImportedDocumentsTableCompanion.insert({
    required String id,
    this.localPath = const Value.absent(),
    this.storageRef = const Value.absent(),
    required String sourceType,
    required String mimeType,
    required DateTime createdAt,
    this.lifecycleState = const Value.absent(),
    this.linkedDebtId = const Value.absent(),
    this.rawOcrText = const Value.absent(),
    required String parseStatus,
    required String parseVersion,
    this.deleted = const Value.absent(),
    this.retentionExpiresAt = const Value.absent(),
    this.rawOcrExpiresAt = const Value.absent(),
    this.processedAt = const Value.absent(),
    this.linkedAt = const Value.absent(),
    this.pendingDeletionAt = const Value.absent(),
    this.purgedAt = const Value.absent(),
    this.encryptedAt = const Value.absent(),
    this.hasRawOcrText = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sourceType = Value(sourceType),
       mimeType = Value(mimeType),
       createdAt = Value(createdAt),
       parseStatus = Value(parseStatus),
       parseVersion = Value(parseVersion);
  static Insertable<ImportedDocumentsTableData> custom({
    Expression<String>? id,
    Expression<String>? localPath,
    Expression<String>? storageRef,
    Expression<String>? sourceType,
    Expression<String>? mimeType,
    Expression<DateTime>? createdAt,
    Expression<String>? lifecycleState,
    Expression<String>? linkedDebtId,
    Expression<String>? rawOcrText,
    Expression<String>? parseStatus,
    Expression<String>? parseVersion,
    Expression<bool>? deleted,
    Expression<DateTime>? retentionExpiresAt,
    Expression<DateTime>? rawOcrExpiresAt,
    Expression<DateTime>? processedAt,
    Expression<DateTime>? linkedAt,
    Expression<DateTime>? pendingDeletionAt,
    Expression<DateTime>? purgedAt,
    Expression<DateTime>? encryptedAt,
    Expression<bool>? hasRawOcrText,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (localPath != null) 'local_path': localPath,
      if (storageRef != null) 'storage_ref': storageRef,
      if (sourceType != null) 'source_type': sourceType,
      if (mimeType != null) 'mime_type': mimeType,
      if (createdAt != null) 'created_at': createdAt,
      if (lifecycleState != null) 'lifecycle_state': lifecycleState,
      if (linkedDebtId != null) 'linked_debt_id': linkedDebtId,
      if (rawOcrText != null) 'raw_ocr_text': rawOcrText,
      if (parseStatus != null) 'parse_status': parseStatus,
      if (parseVersion != null) 'parse_version': parseVersion,
      if (deleted != null) 'deleted': deleted,
      if (retentionExpiresAt != null)
        'retention_expires_at': retentionExpiresAt,
      if (rawOcrExpiresAt != null) 'raw_ocr_expires_at': rawOcrExpiresAt,
      if (processedAt != null) 'processed_at': processedAt,
      if (linkedAt != null) 'linked_at': linkedAt,
      if (pendingDeletionAt != null) 'pending_deletion_at': pendingDeletionAt,
      if (purgedAt != null) 'purged_at': purgedAt,
      if (encryptedAt != null) 'encrypted_at': encryptedAt,
      if (hasRawOcrText != null) 'has_raw_ocr_text': hasRawOcrText,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ImportedDocumentsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? localPath,
    Value<String?>? storageRef,
    Value<String>? sourceType,
    Value<String>? mimeType,
    Value<DateTime>? createdAt,
    Value<String>? lifecycleState,
    Value<String?>? linkedDebtId,
    Value<String?>? rawOcrText,
    Value<String>? parseStatus,
    Value<String>? parseVersion,
    Value<bool>? deleted,
    Value<DateTime?>? retentionExpiresAt,
    Value<DateTime?>? rawOcrExpiresAt,
    Value<DateTime?>? processedAt,
    Value<DateTime?>? linkedAt,
    Value<DateTime?>? pendingDeletionAt,
    Value<DateTime?>? purgedAt,
    Value<DateTime?>? encryptedAt,
    Value<bool>? hasRawOcrText,
    Value<int>? rowid,
  }) {
    return ImportedDocumentsTableCompanion(
      id: id ?? this.id,
      localPath: localPath ?? this.localPath,
      storageRef: storageRef ?? this.storageRef,
      sourceType: sourceType ?? this.sourceType,
      mimeType: mimeType ?? this.mimeType,
      createdAt: createdAt ?? this.createdAt,
      lifecycleState: lifecycleState ?? this.lifecycleState,
      linkedDebtId: linkedDebtId ?? this.linkedDebtId,
      rawOcrText: rawOcrText ?? this.rawOcrText,
      parseStatus: parseStatus ?? this.parseStatus,
      parseVersion: parseVersion ?? this.parseVersion,
      deleted: deleted ?? this.deleted,
      retentionExpiresAt: retentionExpiresAt ?? this.retentionExpiresAt,
      rawOcrExpiresAt: rawOcrExpiresAt ?? this.rawOcrExpiresAt,
      processedAt: processedAt ?? this.processedAt,
      linkedAt: linkedAt ?? this.linkedAt,
      pendingDeletionAt: pendingDeletionAt ?? this.pendingDeletionAt,
      purgedAt: purgedAt ?? this.purgedAt,
      encryptedAt: encryptedAt ?? this.encryptedAt,
      hasRawOcrText: hasRawOcrText ?? this.hasRawOcrText,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (storageRef.present) {
      map['storage_ref'] = Variable<String>(storageRef.value);
    }
    if (sourceType.present) {
      map['source_type'] = Variable<String>(sourceType.value);
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (lifecycleState.present) {
      map['lifecycle_state'] = Variable<String>(lifecycleState.value);
    }
    if (linkedDebtId.present) {
      map['linked_debt_id'] = Variable<String>(linkedDebtId.value);
    }
    if (rawOcrText.present) {
      map['raw_ocr_text'] = Variable<String>(rawOcrText.value);
    }
    if (parseStatus.present) {
      map['parse_status'] = Variable<String>(parseStatus.value);
    }
    if (parseVersion.present) {
      map['parse_version'] = Variable<String>(parseVersion.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (retentionExpiresAt.present) {
      map['retention_expires_at'] = Variable<DateTime>(
        retentionExpiresAt.value,
      );
    }
    if (rawOcrExpiresAt.present) {
      map['raw_ocr_expires_at'] = Variable<DateTime>(rawOcrExpiresAt.value);
    }
    if (processedAt.present) {
      map['processed_at'] = Variable<DateTime>(processedAt.value);
    }
    if (linkedAt.present) {
      map['linked_at'] = Variable<DateTime>(linkedAt.value);
    }
    if (pendingDeletionAt.present) {
      map['pending_deletion_at'] = Variable<DateTime>(pendingDeletionAt.value);
    }
    if (purgedAt.present) {
      map['purged_at'] = Variable<DateTime>(purgedAt.value);
    }
    if (encryptedAt.present) {
      map['encrypted_at'] = Variable<DateTime>(encryptedAt.value);
    }
    if (hasRawOcrText.present) {
      map['has_raw_ocr_text'] = Variable<bool>(hasRawOcrText.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ImportedDocumentsTableCompanion(')
          ..write('id: $id, ')
          ..write('localPath: $localPath, ')
          ..write('storageRef: $storageRef, ')
          ..write('sourceType: $sourceType, ')
          ..write('mimeType: $mimeType, ')
          ..write('createdAt: $createdAt, ')
          ..write('lifecycleState: $lifecycleState, ')
          ..write('linkedDebtId: $linkedDebtId, ')
          ..write('rawOcrText: $rawOcrText, ')
          ..write('parseStatus: $parseStatus, ')
          ..write('parseVersion: $parseVersion, ')
          ..write('deleted: $deleted, ')
          ..write('retentionExpiresAt: $retentionExpiresAt, ')
          ..write('rawOcrExpiresAt: $rawOcrExpiresAt, ')
          ..write('processedAt: $processedAt, ')
          ..write('linkedAt: $linkedAt, ')
          ..write('pendingDeletionAt: $pendingDeletionAt, ')
          ..write('purgedAt: $purgedAt, ')
          ..write('encryptedAt: $encryptedAt, ')
          ..write('hasRawOcrText: $hasRawOcrText, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ParsedExtractionsTableTable extends ParsedExtractionsTable
    with TableInfo<$ParsedExtractionsTableTable, ParsedExtractionsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ParsedExtractionsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _documentIdMeta = const VerificationMeta(
    'documentId',
  );
  @override
  late final GeneratedColumn<String> documentId = GeneratedColumn<String>(
    'document_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES imported_documents_table (id)',
    ),
  );
  static const VerificationMeta _classificationMeta = const VerificationMeta(
    'classification',
  );
  @override
  late final GeneratedColumn<String> classification = GeneratedColumn<String>(
    'classification',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
    'confidence',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ambiguityNotesMeta = const VerificationMeta(
    'ambiguityNotes',
  );
  @override
  late final GeneratedColumn<String> ambiguityNotes = GeneratedColumn<String>(
    'ambiguity_notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    documentId,
    classification,
    confidence,
    payloadJson,
    ambiguityNotes,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'parsed_extractions_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<ParsedExtractionsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('document_id')) {
      context.handle(
        _documentIdMeta,
        documentId.isAcceptableOrUnknown(data['document_id']!, _documentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_documentIdMeta);
    }
    if (data.containsKey('classification')) {
      context.handle(
        _classificationMeta,
        classification.isAcceptableOrUnknown(
          data['classification']!,
          _classificationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_classificationMeta);
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    } else if (isInserting) {
      context.missing(_confidenceMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('ambiguity_notes')) {
      context.handle(
        _ambiguityNotesMeta,
        ambiguityNotes.isAcceptableOrUnknown(
          data['ambiguity_notes']!,
          _ambiguityNotesMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ParsedExtractionsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ParsedExtractionsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      documentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}document_id'],
      )!,
      classification: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}classification'],
      )!,
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      ambiguityNotes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ambiguity_notes'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ParsedExtractionsTableTable createAlias(String alias) {
    return $ParsedExtractionsTableTable(attachedDatabase, alias);
  }
}

class ParsedExtractionsTableData extends DataClass
    implements Insertable<ParsedExtractionsTableData> {
  final String id;
  final String documentId;
  final String classification;
  final double confidence;
  final String payloadJson;
  final String ambiguityNotes;
  final DateTime createdAt;
  const ParsedExtractionsTableData({
    required this.id,
    required this.documentId,
    required this.classification,
    required this.confidence,
    required this.payloadJson,
    required this.ambiguityNotes,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['document_id'] = Variable<String>(documentId);
    map['classification'] = Variable<String>(classification);
    map['confidence'] = Variable<double>(confidence);
    map['payload_json'] = Variable<String>(payloadJson);
    map['ambiguity_notes'] = Variable<String>(ambiguityNotes);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ParsedExtractionsTableCompanion toCompanion(bool nullToAbsent) {
    return ParsedExtractionsTableCompanion(
      id: Value(id),
      documentId: Value(documentId),
      classification: Value(classification),
      confidence: Value(confidence),
      payloadJson: Value(payloadJson),
      ambiguityNotes: Value(ambiguityNotes),
      createdAt: Value(createdAt),
    );
  }

  factory ParsedExtractionsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ParsedExtractionsTableData(
      id: serializer.fromJson<String>(json['id']),
      documentId: serializer.fromJson<String>(json['documentId']),
      classification: serializer.fromJson<String>(json['classification']),
      confidence: serializer.fromJson<double>(json['confidence']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      ambiguityNotes: serializer.fromJson<String>(json['ambiguityNotes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'documentId': serializer.toJson<String>(documentId),
      'classification': serializer.toJson<String>(classification),
      'confidence': serializer.toJson<double>(confidence),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'ambiguityNotes': serializer.toJson<String>(ambiguityNotes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ParsedExtractionsTableData copyWith({
    String? id,
    String? documentId,
    String? classification,
    double? confidence,
    String? payloadJson,
    String? ambiguityNotes,
    DateTime? createdAt,
  }) => ParsedExtractionsTableData(
    id: id ?? this.id,
    documentId: documentId ?? this.documentId,
    classification: classification ?? this.classification,
    confidence: confidence ?? this.confidence,
    payloadJson: payloadJson ?? this.payloadJson,
    ambiguityNotes: ambiguityNotes ?? this.ambiguityNotes,
    createdAt: createdAt ?? this.createdAt,
  );
  ParsedExtractionsTableData copyWithCompanion(
    ParsedExtractionsTableCompanion data,
  ) {
    return ParsedExtractionsTableData(
      id: data.id.present ? data.id.value : this.id,
      documentId: data.documentId.present
          ? data.documentId.value
          : this.documentId,
      classification: data.classification.present
          ? data.classification.value
          : this.classification,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      ambiguityNotes: data.ambiguityNotes.present
          ? data.ambiguityNotes.value
          : this.ambiguityNotes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ParsedExtractionsTableData(')
          ..write('id: $id, ')
          ..write('documentId: $documentId, ')
          ..write('classification: $classification, ')
          ..write('confidence: $confidence, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('ambiguityNotes: $ambiguityNotes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    documentId,
    classification,
    confidence,
    payloadJson,
    ambiguityNotes,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ParsedExtractionsTableData &&
          other.id == this.id &&
          other.documentId == this.documentId &&
          other.classification == this.classification &&
          other.confidence == this.confidence &&
          other.payloadJson == this.payloadJson &&
          other.ambiguityNotes == this.ambiguityNotes &&
          other.createdAt == this.createdAt);
}

class ParsedExtractionsTableCompanion
    extends UpdateCompanion<ParsedExtractionsTableData> {
  final Value<String> id;
  final Value<String> documentId;
  final Value<String> classification;
  final Value<double> confidence;
  final Value<String> payloadJson;
  final Value<String> ambiguityNotes;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ParsedExtractionsTableCompanion({
    this.id = const Value.absent(),
    this.documentId = const Value.absent(),
    this.classification = const Value.absent(),
    this.confidence = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.ambiguityNotes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ParsedExtractionsTableCompanion.insert({
    required String id,
    required String documentId,
    required String classification,
    required double confidence,
    required String payloadJson,
    this.ambiguityNotes = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       documentId = Value(documentId),
       classification = Value(classification),
       confidence = Value(confidence),
       payloadJson = Value(payloadJson),
       createdAt = Value(createdAt);
  static Insertable<ParsedExtractionsTableData> custom({
    Expression<String>? id,
    Expression<String>? documentId,
    Expression<String>? classification,
    Expression<double>? confidence,
    Expression<String>? payloadJson,
    Expression<String>? ambiguityNotes,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (documentId != null) 'document_id': documentId,
      if (classification != null) 'classification': classification,
      if (confidence != null) 'confidence': confidence,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (ambiguityNotes != null) 'ambiguity_notes': ambiguityNotes,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ParsedExtractionsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? documentId,
    Value<String>? classification,
    Value<double>? confidence,
    Value<String>? payloadJson,
    Value<String>? ambiguityNotes,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return ParsedExtractionsTableCompanion(
      id: id ?? this.id,
      documentId: documentId ?? this.documentId,
      classification: classification ?? this.classification,
      confidence: confidence ?? this.confidence,
      payloadJson: payloadJson ?? this.payloadJson,
      ambiguityNotes: ambiguityNotes ?? this.ambiguityNotes,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (documentId.present) {
      map['document_id'] = Variable<String>(documentId.value);
    }
    if (classification.present) {
      map['classification'] = Variable<String>(classification.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (ambiguityNotes.present) {
      map['ambiguity_notes'] = Variable<String>(ambiguityNotes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ParsedExtractionsTableCompanion(')
          ..write('id: $id, ')
          ..write('documentId: $documentId, ')
          ..write('classification: $classification, ')
          ..write('confidence: $confidence, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('ambiguityNotes: $ambiguityNotes, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReminderRulesTableTable extends ReminderRulesTable
    with TableInfo<$ReminderRulesTableTable, ReminderRulesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReminderRulesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _debtIdMeta = const VerificationMeta('debtId');
  @override
  late final GeneratedColumn<String> debtId = GeneratedColumn<String>(
    'debt_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES debts_table (id)',
    ),
  );
  static const VerificationMeta _daysBeforeMeta = const VerificationMeta(
    'daysBefore',
  );
  @override
  late final GeneratedColumn<int> daysBefore = GeneratedColumn<int>(
    'days_before',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(2),
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [id, debtId, daysBefore, enabled];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reminder_rules_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReminderRulesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('debt_id')) {
      context.handle(
        _debtIdMeta,
        debtId.isAcceptableOrUnknown(data['debt_id']!, _debtIdMeta),
      );
    } else if (isInserting) {
      context.missing(_debtIdMeta);
    }
    if (data.containsKey('days_before')) {
      context.handle(
        _daysBeforeMeta,
        daysBefore.isAcceptableOrUnknown(data['days_before']!, _daysBeforeMeta),
      );
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReminderRulesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReminderRulesTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      debtId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}debt_id'],
      )!,
      daysBefore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}days_before'],
      )!,
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
    );
  }

  @override
  $ReminderRulesTableTable createAlias(String alias) {
    return $ReminderRulesTableTable(attachedDatabase, alias);
  }
}

class ReminderRulesTableData extends DataClass
    implements Insertable<ReminderRulesTableData> {
  final String id;
  final String debtId;
  final int daysBefore;
  final bool enabled;
  const ReminderRulesTableData({
    required this.id,
    required this.debtId,
    required this.daysBefore,
    required this.enabled,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['debt_id'] = Variable<String>(debtId);
    map['days_before'] = Variable<int>(daysBefore);
    map['enabled'] = Variable<bool>(enabled);
    return map;
  }

  ReminderRulesTableCompanion toCompanion(bool nullToAbsent) {
    return ReminderRulesTableCompanion(
      id: Value(id),
      debtId: Value(debtId),
      daysBefore: Value(daysBefore),
      enabled: Value(enabled),
    );
  }

  factory ReminderRulesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReminderRulesTableData(
      id: serializer.fromJson<String>(json['id']),
      debtId: serializer.fromJson<String>(json['debtId']),
      daysBefore: serializer.fromJson<int>(json['daysBefore']),
      enabled: serializer.fromJson<bool>(json['enabled']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'debtId': serializer.toJson<String>(debtId),
      'daysBefore': serializer.toJson<int>(daysBefore),
      'enabled': serializer.toJson<bool>(enabled),
    };
  }

  ReminderRulesTableData copyWith({
    String? id,
    String? debtId,
    int? daysBefore,
    bool? enabled,
  }) => ReminderRulesTableData(
    id: id ?? this.id,
    debtId: debtId ?? this.debtId,
    daysBefore: daysBefore ?? this.daysBefore,
    enabled: enabled ?? this.enabled,
  );
  ReminderRulesTableData copyWithCompanion(ReminderRulesTableCompanion data) {
    return ReminderRulesTableData(
      id: data.id.present ? data.id.value : this.id,
      debtId: data.debtId.present ? data.debtId.value : this.debtId,
      daysBefore: data.daysBefore.present
          ? data.daysBefore.value
          : this.daysBefore,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReminderRulesTableData(')
          ..write('id: $id, ')
          ..write('debtId: $debtId, ')
          ..write('daysBefore: $daysBefore, ')
          ..write('enabled: $enabled')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, debtId, daysBefore, enabled);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReminderRulesTableData &&
          other.id == this.id &&
          other.debtId == this.debtId &&
          other.daysBefore == this.daysBefore &&
          other.enabled == this.enabled);
}

class ReminderRulesTableCompanion
    extends UpdateCompanion<ReminderRulesTableData> {
  final Value<String> id;
  final Value<String> debtId;
  final Value<int> daysBefore;
  final Value<bool> enabled;
  final Value<int> rowid;
  const ReminderRulesTableCompanion({
    this.id = const Value.absent(),
    this.debtId = const Value.absent(),
    this.daysBefore = const Value.absent(),
    this.enabled = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReminderRulesTableCompanion.insert({
    required String id,
    required String debtId,
    this.daysBefore = const Value.absent(),
    this.enabled = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       debtId = Value(debtId);
  static Insertable<ReminderRulesTableData> custom({
    Expression<String>? id,
    Expression<String>? debtId,
    Expression<int>? daysBefore,
    Expression<bool>? enabled,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (debtId != null) 'debt_id': debtId,
      if (daysBefore != null) 'days_before': daysBefore,
      if (enabled != null) 'enabled': enabled,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReminderRulesTableCompanion copyWith({
    Value<String>? id,
    Value<String>? debtId,
    Value<int>? daysBefore,
    Value<bool>? enabled,
    Value<int>? rowid,
  }) {
    return ReminderRulesTableCompanion(
      id: id ?? this.id,
      debtId: debtId ?? this.debtId,
      daysBefore: daysBefore ?? this.daysBefore,
      enabled: enabled ?? this.enabled,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (debtId.present) {
      map['debt_id'] = Variable<String>(debtId.value);
    }
    if (daysBefore.present) {
      map['days_before'] = Variable<int>(daysBefore.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReminderRulesTableCompanion(')
          ..write('id: $id, ')
          ..write('debtId: $debtId, ')
          ..write('daysBefore: $daysBefore, ')
          ..write('enabled: $enabled, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ScenariosTableTable extends ScenariosTable
    with TableInfo<$ScenariosTableTable, ScenariosTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScenariosTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _strategyTypeMeta = const VerificationMeta(
    'strategyType',
  );
  @override
  late final GeneratedColumn<String> strategyType = GeneratedColumn<String>(
    'strategy_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _extraPaymentMeta = const VerificationMeta(
    'extraPayment',
  );
  @override
  late final GeneratedColumn<double> extraPayment = GeneratedColumn<double>(
    'extra_payment',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _budgetMeta = const VerificationMeta('budget');
  @override
  late final GeneratedColumn<double> budget = GeneratedColumn<double>(
    'budget',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _baselineInterestMeta = const VerificationMeta(
    'baselineInterest',
  );
  @override
  late final GeneratedColumn<double> baselineInterest = GeneratedColumn<double>(
    'baseline_interest',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _optimizedInterestMeta = const VerificationMeta(
    'optimizedInterest',
  );
  @override
  late final GeneratedColumn<double> optimizedInterest =
      GeneratedColumn<double>(
        'optimized_interest',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _monthsToPayoffMeta = const VerificationMeta(
    'monthsToPayoff',
  );
  @override
  late final GeneratedColumn<int> monthsToPayoff = GeneratedColumn<int>(
    'months_to_payoff',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    strategyType,
    extraPayment,
    budget,
    createdAt,
    label,
    baselineInterest,
    optimizedInterest,
    monthsToPayoff,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'scenarios_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScenariosTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('strategy_type')) {
      context.handle(
        _strategyTypeMeta,
        strategyType.isAcceptableOrUnknown(
          data['strategy_type']!,
          _strategyTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_strategyTypeMeta);
    }
    if (data.containsKey('extra_payment')) {
      context.handle(
        _extraPaymentMeta,
        extraPayment.isAcceptableOrUnknown(
          data['extra_payment']!,
          _extraPaymentMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_extraPaymentMeta);
    }
    if (data.containsKey('budget')) {
      context.handle(
        _budgetMeta,
        budget.isAcceptableOrUnknown(data['budget']!, _budgetMeta),
      );
    } else if (isInserting) {
      context.missing(_budgetMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('baseline_interest')) {
      context.handle(
        _baselineInterestMeta,
        baselineInterest.isAcceptableOrUnknown(
          data['baseline_interest']!,
          _baselineInterestMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_baselineInterestMeta);
    }
    if (data.containsKey('optimized_interest')) {
      context.handle(
        _optimizedInterestMeta,
        optimizedInterest.isAcceptableOrUnknown(
          data['optimized_interest']!,
          _optimizedInterestMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_optimizedInterestMeta);
    }
    if (data.containsKey('months_to_payoff')) {
      context.handle(
        _monthsToPayoffMeta,
        monthsToPayoff.isAcceptableOrUnknown(
          data['months_to_payoff']!,
          _monthsToPayoffMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_monthsToPayoffMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ScenariosTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScenariosTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      strategyType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}strategy_type'],
      )!,
      extraPayment: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}extra_payment'],
      )!,
      budget: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}budget'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      baselineInterest: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}baseline_interest'],
      )!,
      optimizedInterest: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}optimized_interest'],
      )!,
      monthsToPayoff: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}months_to_payoff'],
      )!,
    );
  }

  @override
  $ScenariosTableTable createAlias(String alias) {
    return $ScenariosTableTable(attachedDatabase, alias);
  }
}

class ScenariosTableData extends DataClass
    implements Insertable<ScenariosTableData> {
  final String id;
  final String strategyType;
  final double extraPayment;
  final double budget;
  final DateTime createdAt;
  final String label;
  final double baselineInterest;
  final double optimizedInterest;
  final int monthsToPayoff;
  const ScenariosTableData({
    required this.id,
    required this.strategyType,
    required this.extraPayment,
    required this.budget,
    required this.createdAt,
    required this.label,
    required this.baselineInterest,
    required this.optimizedInterest,
    required this.monthsToPayoff,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['strategy_type'] = Variable<String>(strategyType);
    map['extra_payment'] = Variable<double>(extraPayment);
    map['budget'] = Variable<double>(budget);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['label'] = Variable<String>(label);
    map['baseline_interest'] = Variable<double>(baselineInterest);
    map['optimized_interest'] = Variable<double>(optimizedInterest);
    map['months_to_payoff'] = Variable<int>(monthsToPayoff);
    return map;
  }

  ScenariosTableCompanion toCompanion(bool nullToAbsent) {
    return ScenariosTableCompanion(
      id: Value(id),
      strategyType: Value(strategyType),
      extraPayment: Value(extraPayment),
      budget: Value(budget),
      createdAt: Value(createdAt),
      label: Value(label),
      baselineInterest: Value(baselineInterest),
      optimizedInterest: Value(optimizedInterest),
      monthsToPayoff: Value(monthsToPayoff),
    );
  }

  factory ScenariosTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScenariosTableData(
      id: serializer.fromJson<String>(json['id']),
      strategyType: serializer.fromJson<String>(json['strategyType']),
      extraPayment: serializer.fromJson<double>(json['extraPayment']),
      budget: serializer.fromJson<double>(json['budget']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      label: serializer.fromJson<String>(json['label']),
      baselineInterest: serializer.fromJson<double>(json['baselineInterest']),
      optimizedInterest: serializer.fromJson<double>(json['optimizedInterest']),
      monthsToPayoff: serializer.fromJson<int>(json['monthsToPayoff']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'strategyType': serializer.toJson<String>(strategyType),
      'extraPayment': serializer.toJson<double>(extraPayment),
      'budget': serializer.toJson<double>(budget),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'label': serializer.toJson<String>(label),
      'baselineInterest': serializer.toJson<double>(baselineInterest),
      'optimizedInterest': serializer.toJson<double>(optimizedInterest),
      'monthsToPayoff': serializer.toJson<int>(monthsToPayoff),
    };
  }

  ScenariosTableData copyWith({
    String? id,
    String? strategyType,
    double? extraPayment,
    double? budget,
    DateTime? createdAt,
    String? label,
    double? baselineInterest,
    double? optimizedInterest,
    int? monthsToPayoff,
  }) => ScenariosTableData(
    id: id ?? this.id,
    strategyType: strategyType ?? this.strategyType,
    extraPayment: extraPayment ?? this.extraPayment,
    budget: budget ?? this.budget,
    createdAt: createdAt ?? this.createdAt,
    label: label ?? this.label,
    baselineInterest: baselineInterest ?? this.baselineInterest,
    optimizedInterest: optimizedInterest ?? this.optimizedInterest,
    monthsToPayoff: monthsToPayoff ?? this.monthsToPayoff,
  );
  ScenariosTableData copyWithCompanion(ScenariosTableCompanion data) {
    return ScenariosTableData(
      id: data.id.present ? data.id.value : this.id,
      strategyType: data.strategyType.present
          ? data.strategyType.value
          : this.strategyType,
      extraPayment: data.extraPayment.present
          ? data.extraPayment.value
          : this.extraPayment,
      budget: data.budget.present ? data.budget.value : this.budget,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      label: data.label.present ? data.label.value : this.label,
      baselineInterest: data.baselineInterest.present
          ? data.baselineInterest.value
          : this.baselineInterest,
      optimizedInterest: data.optimizedInterest.present
          ? data.optimizedInterest.value
          : this.optimizedInterest,
      monthsToPayoff: data.monthsToPayoff.present
          ? data.monthsToPayoff.value
          : this.monthsToPayoff,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScenariosTableData(')
          ..write('id: $id, ')
          ..write('strategyType: $strategyType, ')
          ..write('extraPayment: $extraPayment, ')
          ..write('budget: $budget, ')
          ..write('createdAt: $createdAt, ')
          ..write('label: $label, ')
          ..write('baselineInterest: $baselineInterest, ')
          ..write('optimizedInterest: $optimizedInterest, ')
          ..write('monthsToPayoff: $monthsToPayoff')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    strategyType,
    extraPayment,
    budget,
    createdAt,
    label,
    baselineInterest,
    optimizedInterest,
    monthsToPayoff,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScenariosTableData &&
          other.id == this.id &&
          other.strategyType == this.strategyType &&
          other.extraPayment == this.extraPayment &&
          other.budget == this.budget &&
          other.createdAt == this.createdAt &&
          other.label == this.label &&
          other.baselineInterest == this.baselineInterest &&
          other.optimizedInterest == this.optimizedInterest &&
          other.monthsToPayoff == this.monthsToPayoff);
}

class ScenariosTableCompanion extends UpdateCompanion<ScenariosTableData> {
  final Value<String> id;
  final Value<String> strategyType;
  final Value<double> extraPayment;
  final Value<double> budget;
  final Value<DateTime> createdAt;
  final Value<String> label;
  final Value<double> baselineInterest;
  final Value<double> optimizedInterest;
  final Value<int> monthsToPayoff;
  final Value<int> rowid;
  const ScenariosTableCompanion({
    this.id = const Value.absent(),
    this.strategyType = const Value.absent(),
    this.extraPayment = const Value.absent(),
    this.budget = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.label = const Value.absent(),
    this.baselineInterest = const Value.absent(),
    this.optimizedInterest = const Value.absent(),
    this.monthsToPayoff = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ScenariosTableCompanion.insert({
    required String id,
    required String strategyType,
    required double extraPayment,
    required double budget,
    required DateTime createdAt,
    required String label,
    required double baselineInterest,
    required double optimizedInterest,
    required int monthsToPayoff,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       strategyType = Value(strategyType),
       extraPayment = Value(extraPayment),
       budget = Value(budget),
       createdAt = Value(createdAt),
       label = Value(label),
       baselineInterest = Value(baselineInterest),
       optimizedInterest = Value(optimizedInterest),
       monthsToPayoff = Value(monthsToPayoff);
  static Insertable<ScenariosTableData> custom({
    Expression<String>? id,
    Expression<String>? strategyType,
    Expression<double>? extraPayment,
    Expression<double>? budget,
    Expression<DateTime>? createdAt,
    Expression<String>? label,
    Expression<double>? baselineInterest,
    Expression<double>? optimizedInterest,
    Expression<int>? monthsToPayoff,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (strategyType != null) 'strategy_type': strategyType,
      if (extraPayment != null) 'extra_payment': extraPayment,
      if (budget != null) 'budget': budget,
      if (createdAt != null) 'created_at': createdAt,
      if (label != null) 'label': label,
      if (baselineInterest != null) 'baseline_interest': baselineInterest,
      if (optimizedInterest != null) 'optimized_interest': optimizedInterest,
      if (monthsToPayoff != null) 'months_to_payoff': monthsToPayoff,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ScenariosTableCompanion copyWith({
    Value<String>? id,
    Value<String>? strategyType,
    Value<double>? extraPayment,
    Value<double>? budget,
    Value<DateTime>? createdAt,
    Value<String>? label,
    Value<double>? baselineInterest,
    Value<double>? optimizedInterest,
    Value<int>? monthsToPayoff,
    Value<int>? rowid,
  }) {
    return ScenariosTableCompanion(
      id: id ?? this.id,
      strategyType: strategyType ?? this.strategyType,
      extraPayment: extraPayment ?? this.extraPayment,
      budget: budget ?? this.budget,
      createdAt: createdAt ?? this.createdAt,
      label: label ?? this.label,
      baselineInterest: baselineInterest ?? this.baselineInterest,
      optimizedInterest: optimizedInterest ?? this.optimizedInterest,
      monthsToPayoff: monthsToPayoff ?? this.monthsToPayoff,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (strategyType.present) {
      map['strategy_type'] = Variable<String>(strategyType.value);
    }
    if (extraPayment.present) {
      map['extra_payment'] = Variable<double>(extraPayment.value);
    }
    if (budget.present) {
      map['budget'] = Variable<double>(budget.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (baselineInterest.present) {
      map['baseline_interest'] = Variable<double>(baselineInterest.value);
    }
    if (optimizedInterest.present) {
      map['optimized_interest'] = Variable<double>(optimizedInterest.value);
    }
    if (monthsToPayoff.present) {
      map['months_to_payoff'] = Variable<int>(monthsToPayoff.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScenariosTableCompanion(')
          ..write('id: $id, ')
          ..write('strategyType: $strategyType, ')
          ..write('extraPayment: $extraPayment, ')
          ..write('budget: $budget, ')
          ..write('createdAt: $createdAt, ')
          ..write('label: $label, ')
          ..write('baselineInterest: $baselineInterest, ')
          ..write('optimizedInterest: $optimizedInterest, ')
          ..write('monthsToPayoff: $monthsToPayoff, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppPreferencesTableTable extends AppPreferencesTable
    with TableInfo<$AppPreferencesTableTable, AppPreferencesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppPreferencesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<int> key = GeneratedColumn<int>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _themeModeMeta = const VerificationMeta(
    'themeMode',
  );
  @override
  late final GeneratedColumn<String> themeMode = GeneratedColumn<String>(
    'theme_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('system'),
  );
  static const VerificationMeta _currencyCodeMeta = const VerificationMeta(
    'currencyCode',
  );
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('USD'),
  );
  static const VerificationMeta _localeCodeMeta = const VerificationMeta(
    'localeCode',
  );
  @override
  late final GeneratedColumn<String> localeCode = GeneratedColumn<String>(
    'locale_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('en_US'),
  );
  static const VerificationMeta _defaultStrategyMeta = const VerificationMeta(
    'defaultStrategy',
  );
  @override
  late final GeneratedColumn<String> defaultStrategy = GeneratedColumn<String>(
    'default_strategy',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('avalanche'),
  );
  static const VerificationMeta _hideBalancesMeta = const VerificationMeta(
    'hideBalances',
  );
  @override
  late final GeneratedColumn<bool> hideBalances = GeneratedColumn<bool>(
    'hide_balances',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("hide_balances" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _appLockEnabledMeta = const VerificationMeta(
    'appLockEnabled',
  );
  @override
  late final GeneratedColumn<bool> appLockEnabled = GeneratedColumn<bool>(
    'app_lock_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("app_lock_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _aiConsentEnabledMeta = const VerificationMeta(
    'aiConsentEnabled',
  );
  @override
  late final GeneratedColumn<bool> aiConsentEnabled = GeneratedColumn<bool>(
    'ai_consent_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("ai_consent_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _notificationsEnabledMeta =
      const VerificationMeta('notificationsEnabled');
  @override
  late final GeneratedColumn<bool> notificationsEnabled = GeneratedColumn<bool>(
    'notifications_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("notifications_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _onboardingCompletedMeta =
      const VerificationMeta('onboardingCompleted');
  @override
  late final GeneratedColumn<bool> onboardingCompleted = GeneratedColumn<bool>(
    'onboarding_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("onboarding_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _weeklySummaryEnabledMeta =
      const VerificationMeta('weeklySummaryEnabled');
  @override
  late final GeneratedColumn<bool> weeklySummaryEnabled = GeneratedColumn<bool>(
    'weekly_summary_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("weekly_summary_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _rawOcrRetentionEnabledMeta =
      const VerificationMeta('rawOcrRetentionEnabled');
  @override
  late final GeneratedColumn<bool> rawOcrRetentionEnabled =
      GeneratedColumn<bool>(
        'raw_ocr_retention_enabled',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("raw_ocr_retention_enabled" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  static const VerificationMeta _rawOcrRetentionHoursMeta =
      const VerificationMeta('rawOcrRetentionHours');
  @override
  late final GeneratedColumn<int> rawOcrRetentionHours = GeneratedColumn<int>(
    'raw_ocr_retention_hours',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _documentRetentionModeMeta =
      const VerificationMeta('documentRetentionMode');
  @override
  late final GeneratedColumn<String> documentRetentionMode =
      GeneratedColumn<String>(
        'document_retention_mode',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('days30'),
      );
  static const VerificationMeta _purgeFailedImportsAfterHoursMeta =
      const VerificationMeta('purgeFailedImportsAfterHours');
  @override
  late final GeneratedColumn<int> purgeFailedImportsAfterHours =
      GeneratedColumn<int>(
        'purge_failed_imports_after_hours',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(24),
      );
  static const VerificationMeta _dataProtectionExplainerSeenMeta =
      const VerificationMeta('dataProtectionExplainerSeen');
  @override
  late final GeneratedColumn<bool> dataProtectionExplainerSeen =
      GeneratedColumn<bool>(
        'data_protection_explainer_seen',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("data_protection_explainer_seen" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  @override
  List<GeneratedColumn> get $columns => [
    key,
    themeMode,
    currencyCode,
    localeCode,
    defaultStrategy,
    hideBalances,
    appLockEnabled,
    aiConsentEnabled,
    notificationsEnabled,
    onboardingCompleted,
    weeklySummaryEnabled,
    rawOcrRetentionEnabled,
    rawOcrRetentionHours,
    documentRetentionMode,
    purgeFailedImportsAfterHours,
    dataProtectionExplainerSeen,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_preferences_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppPreferencesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    }
    if (data.containsKey('theme_mode')) {
      context.handle(
        _themeModeMeta,
        themeMode.isAcceptableOrUnknown(data['theme_mode']!, _themeModeMeta),
      );
    }
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(
          data['currency_code']!,
          _currencyCodeMeta,
        ),
      );
    }
    if (data.containsKey('locale_code')) {
      context.handle(
        _localeCodeMeta,
        localeCode.isAcceptableOrUnknown(data['locale_code']!, _localeCodeMeta),
      );
    }
    if (data.containsKey('default_strategy')) {
      context.handle(
        _defaultStrategyMeta,
        defaultStrategy.isAcceptableOrUnknown(
          data['default_strategy']!,
          _defaultStrategyMeta,
        ),
      );
    }
    if (data.containsKey('hide_balances')) {
      context.handle(
        _hideBalancesMeta,
        hideBalances.isAcceptableOrUnknown(
          data['hide_balances']!,
          _hideBalancesMeta,
        ),
      );
    }
    if (data.containsKey('app_lock_enabled')) {
      context.handle(
        _appLockEnabledMeta,
        appLockEnabled.isAcceptableOrUnknown(
          data['app_lock_enabled']!,
          _appLockEnabledMeta,
        ),
      );
    }
    if (data.containsKey('ai_consent_enabled')) {
      context.handle(
        _aiConsentEnabledMeta,
        aiConsentEnabled.isAcceptableOrUnknown(
          data['ai_consent_enabled']!,
          _aiConsentEnabledMeta,
        ),
      );
    }
    if (data.containsKey('notifications_enabled')) {
      context.handle(
        _notificationsEnabledMeta,
        notificationsEnabled.isAcceptableOrUnknown(
          data['notifications_enabled']!,
          _notificationsEnabledMeta,
        ),
      );
    }
    if (data.containsKey('onboarding_completed')) {
      context.handle(
        _onboardingCompletedMeta,
        onboardingCompleted.isAcceptableOrUnknown(
          data['onboarding_completed']!,
          _onboardingCompletedMeta,
        ),
      );
    }
    if (data.containsKey('weekly_summary_enabled')) {
      context.handle(
        _weeklySummaryEnabledMeta,
        weeklySummaryEnabled.isAcceptableOrUnknown(
          data['weekly_summary_enabled']!,
          _weeklySummaryEnabledMeta,
        ),
      );
    }
    if (data.containsKey('raw_ocr_retention_enabled')) {
      context.handle(
        _rawOcrRetentionEnabledMeta,
        rawOcrRetentionEnabled.isAcceptableOrUnknown(
          data['raw_ocr_retention_enabled']!,
          _rawOcrRetentionEnabledMeta,
        ),
      );
    }
    if (data.containsKey('raw_ocr_retention_hours')) {
      context.handle(
        _rawOcrRetentionHoursMeta,
        rawOcrRetentionHours.isAcceptableOrUnknown(
          data['raw_ocr_retention_hours']!,
          _rawOcrRetentionHoursMeta,
        ),
      );
    }
    if (data.containsKey('document_retention_mode')) {
      context.handle(
        _documentRetentionModeMeta,
        documentRetentionMode.isAcceptableOrUnknown(
          data['document_retention_mode']!,
          _documentRetentionModeMeta,
        ),
      );
    }
    if (data.containsKey('purge_failed_imports_after_hours')) {
      context.handle(
        _purgeFailedImportsAfterHoursMeta,
        purgeFailedImportsAfterHours.isAcceptableOrUnknown(
          data['purge_failed_imports_after_hours']!,
          _purgeFailedImportsAfterHoursMeta,
        ),
      );
    }
    if (data.containsKey('data_protection_explainer_seen')) {
      context.handle(
        _dataProtectionExplainerSeenMeta,
        dataProtectionExplainerSeen.isAcceptableOrUnknown(
          data['data_protection_explainer_seen']!,
          _dataProtectionExplainerSeenMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppPreferencesTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppPreferencesTableData(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}key'],
      )!,
      themeMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}theme_mode'],
      )!,
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      localeCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}locale_code'],
      )!,
      defaultStrategy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}default_strategy'],
      )!,
      hideBalances: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}hide_balances'],
      )!,
      appLockEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}app_lock_enabled'],
      )!,
      aiConsentEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}ai_consent_enabled'],
      )!,
      notificationsEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}notifications_enabled'],
      )!,
      onboardingCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}onboarding_completed'],
      )!,
      weeklySummaryEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}weekly_summary_enabled'],
      )!,
      rawOcrRetentionEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}raw_ocr_retention_enabled'],
      )!,
      rawOcrRetentionHours: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}raw_ocr_retention_hours'],
      )!,
      documentRetentionMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}document_retention_mode'],
      )!,
      purgeFailedImportsAfterHours: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}purge_failed_imports_after_hours'],
      )!,
      dataProtectionExplainerSeen: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}data_protection_explainer_seen'],
      )!,
    );
  }

  @override
  $AppPreferencesTableTable createAlias(String alias) {
    return $AppPreferencesTableTable(attachedDatabase, alias);
  }
}

class AppPreferencesTableData extends DataClass
    implements Insertable<AppPreferencesTableData> {
  final int key;
  final String themeMode;
  final String currencyCode;
  final String localeCode;
  final String defaultStrategy;
  final bool hideBalances;
  final bool appLockEnabled;
  final bool aiConsentEnabled;
  final bool notificationsEnabled;
  final bool onboardingCompleted;
  final bool weeklySummaryEnabled;
  final bool rawOcrRetentionEnabled;
  final int rawOcrRetentionHours;
  final String documentRetentionMode;
  final int purgeFailedImportsAfterHours;
  final bool dataProtectionExplainerSeen;
  const AppPreferencesTableData({
    required this.key,
    required this.themeMode,
    required this.currencyCode,
    required this.localeCode,
    required this.defaultStrategy,
    required this.hideBalances,
    required this.appLockEnabled,
    required this.aiConsentEnabled,
    required this.notificationsEnabled,
    required this.onboardingCompleted,
    required this.weeklySummaryEnabled,
    required this.rawOcrRetentionEnabled,
    required this.rawOcrRetentionHours,
    required this.documentRetentionMode,
    required this.purgeFailedImportsAfterHours,
    required this.dataProtectionExplainerSeen,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<int>(key);
    map['theme_mode'] = Variable<String>(themeMode);
    map['currency_code'] = Variable<String>(currencyCode);
    map['locale_code'] = Variable<String>(localeCode);
    map['default_strategy'] = Variable<String>(defaultStrategy);
    map['hide_balances'] = Variable<bool>(hideBalances);
    map['app_lock_enabled'] = Variable<bool>(appLockEnabled);
    map['ai_consent_enabled'] = Variable<bool>(aiConsentEnabled);
    map['notifications_enabled'] = Variable<bool>(notificationsEnabled);
    map['onboarding_completed'] = Variable<bool>(onboardingCompleted);
    map['weekly_summary_enabled'] = Variable<bool>(weeklySummaryEnabled);
    map['raw_ocr_retention_enabled'] = Variable<bool>(rawOcrRetentionEnabled);
    map['raw_ocr_retention_hours'] = Variable<int>(rawOcrRetentionHours);
    map['document_retention_mode'] = Variable<String>(documentRetentionMode);
    map['purge_failed_imports_after_hours'] = Variable<int>(
      purgeFailedImportsAfterHours,
    );
    map['data_protection_explainer_seen'] = Variable<bool>(
      dataProtectionExplainerSeen,
    );
    return map;
  }

  AppPreferencesTableCompanion toCompanion(bool nullToAbsent) {
    return AppPreferencesTableCompanion(
      key: Value(key),
      themeMode: Value(themeMode),
      currencyCode: Value(currencyCode),
      localeCode: Value(localeCode),
      defaultStrategy: Value(defaultStrategy),
      hideBalances: Value(hideBalances),
      appLockEnabled: Value(appLockEnabled),
      aiConsentEnabled: Value(aiConsentEnabled),
      notificationsEnabled: Value(notificationsEnabled),
      onboardingCompleted: Value(onboardingCompleted),
      weeklySummaryEnabled: Value(weeklySummaryEnabled),
      rawOcrRetentionEnabled: Value(rawOcrRetentionEnabled),
      rawOcrRetentionHours: Value(rawOcrRetentionHours),
      documentRetentionMode: Value(documentRetentionMode),
      purgeFailedImportsAfterHours: Value(purgeFailedImportsAfterHours),
      dataProtectionExplainerSeen: Value(dataProtectionExplainerSeen),
    );
  }

  factory AppPreferencesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppPreferencesTableData(
      key: serializer.fromJson<int>(json['key']),
      themeMode: serializer.fromJson<String>(json['themeMode']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      localeCode: serializer.fromJson<String>(json['localeCode']),
      defaultStrategy: serializer.fromJson<String>(json['defaultStrategy']),
      hideBalances: serializer.fromJson<bool>(json['hideBalances']),
      appLockEnabled: serializer.fromJson<bool>(json['appLockEnabled']),
      aiConsentEnabled: serializer.fromJson<bool>(json['aiConsentEnabled']),
      notificationsEnabled: serializer.fromJson<bool>(
        json['notificationsEnabled'],
      ),
      onboardingCompleted: serializer.fromJson<bool>(
        json['onboardingCompleted'],
      ),
      weeklySummaryEnabled: serializer.fromJson<bool>(
        json['weeklySummaryEnabled'],
      ),
      rawOcrRetentionEnabled: serializer.fromJson<bool>(
        json['rawOcrRetentionEnabled'],
      ),
      rawOcrRetentionHours: serializer.fromJson<int>(
        json['rawOcrRetentionHours'],
      ),
      documentRetentionMode: serializer.fromJson<String>(
        json['documentRetentionMode'],
      ),
      purgeFailedImportsAfterHours: serializer.fromJson<int>(
        json['purgeFailedImportsAfterHours'],
      ),
      dataProtectionExplainerSeen: serializer.fromJson<bool>(
        json['dataProtectionExplainerSeen'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<int>(key),
      'themeMode': serializer.toJson<String>(themeMode),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'localeCode': serializer.toJson<String>(localeCode),
      'defaultStrategy': serializer.toJson<String>(defaultStrategy),
      'hideBalances': serializer.toJson<bool>(hideBalances),
      'appLockEnabled': serializer.toJson<bool>(appLockEnabled),
      'aiConsentEnabled': serializer.toJson<bool>(aiConsentEnabled),
      'notificationsEnabled': serializer.toJson<bool>(notificationsEnabled),
      'onboardingCompleted': serializer.toJson<bool>(onboardingCompleted),
      'weeklySummaryEnabled': serializer.toJson<bool>(weeklySummaryEnabled),
      'rawOcrRetentionEnabled': serializer.toJson<bool>(rawOcrRetentionEnabled),
      'rawOcrRetentionHours': serializer.toJson<int>(rawOcrRetentionHours),
      'documentRetentionMode': serializer.toJson<String>(documentRetentionMode),
      'purgeFailedImportsAfterHours': serializer.toJson<int>(
        purgeFailedImportsAfterHours,
      ),
      'dataProtectionExplainerSeen': serializer.toJson<bool>(
        dataProtectionExplainerSeen,
      ),
    };
  }

  AppPreferencesTableData copyWith({
    int? key,
    String? themeMode,
    String? currencyCode,
    String? localeCode,
    String? defaultStrategy,
    bool? hideBalances,
    bool? appLockEnabled,
    bool? aiConsentEnabled,
    bool? notificationsEnabled,
    bool? onboardingCompleted,
    bool? weeklySummaryEnabled,
    bool? rawOcrRetentionEnabled,
    int? rawOcrRetentionHours,
    String? documentRetentionMode,
    int? purgeFailedImportsAfterHours,
    bool? dataProtectionExplainerSeen,
  }) => AppPreferencesTableData(
    key: key ?? this.key,
    themeMode: themeMode ?? this.themeMode,
    currencyCode: currencyCode ?? this.currencyCode,
    localeCode: localeCode ?? this.localeCode,
    defaultStrategy: defaultStrategy ?? this.defaultStrategy,
    hideBalances: hideBalances ?? this.hideBalances,
    appLockEnabled: appLockEnabled ?? this.appLockEnabled,
    aiConsentEnabled: aiConsentEnabled ?? this.aiConsentEnabled,
    notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    weeklySummaryEnabled: weeklySummaryEnabled ?? this.weeklySummaryEnabled,
    rawOcrRetentionEnabled:
        rawOcrRetentionEnabled ?? this.rawOcrRetentionEnabled,
    rawOcrRetentionHours: rawOcrRetentionHours ?? this.rawOcrRetentionHours,
    documentRetentionMode: documentRetentionMode ?? this.documentRetentionMode,
    purgeFailedImportsAfterHours:
        purgeFailedImportsAfterHours ?? this.purgeFailedImportsAfterHours,
    dataProtectionExplainerSeen:
        dataProtectionExplainerSeen ?? this.dataProtectionExplainerSeen,
  );
  AppPreferencesTableData copyWithCompanion(AppPreferencesTableCompanion data) {
    return AppPreferencesTableData(
      key: data.key.present ? data.key.value : this.key,
      themeMode: data.themeMode.present ? data.themeMode.value : this.themeMode,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      localeCode: data.localeCode.present
          ? data.localeCode.value
          : this.localeCode,
      defaultStrategy: data.defaultStrategy.present
          ? data.defaultStrategy.value
          : this.defaultStrategy,
      hideBalances: data.hideBalances.present
          ? data.hideBalances.value
          : this.hideBalances,
      appLockEnabled: data.appLockEnabled.present
          ? data.appLockEnabled.value
          : this.appLockEnabled,
      aiConsentEnabled: data.aiConsentEnabled.present
          ? data.aiConsentEnabled.value
          : this.aiConsentEnabled,
      notificationsEnabled: data.notificationsEnabled.present
          ? data.notificationsEnabled.value
          : this.notificationsEnabled,
      onboardingCompleted: data.onboardingCompleted.present
          ? data.onboardingCompleted.value
          : this.onboardingCompleted,
      weeklySummaryEnabled: data.weeklySummaryEnabled.present
          ? data.weeklySummaryEnabled.value
          : this.weeklySummaryEnabled,
      rawOcrRetentionEnabled: data.rawOcrRetentionEnabled.present
          ? data.rawOcrRetentionEnabled.value
          : this.rawOcrRetentionEnabled,
      rawOcrRetentionHours: data.rawOcrRetentionHours.present
          ? data.rawOcrRetentionHours.value
          : this.rawOcrRetentionHours,
      documentRetentionMode: data.documentRetentionMode.present
          ? data.documentRetentionMode.value
          : this.documentRetentionMode,
      purgeFailedImportsAfterHours: data.purgeFailedImportsAfterHours.present
          ? data.purgeFailedImportsAfterHours.value
          : this.purgeFailedImportsAfterHours,
      dataProtectionExplainerSeen: data.dataProtectionExplainerSeen.present
          ? data.dataProtectionExplainerSeen.value
          : this.dataProtectionExplainerSeen,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppPreferencesTableData(')
          ..write('key: $key, ')
          ..write('themeMode: $themeMode, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('localeCode: $localeCode, ')
          ..write('defaultStrategy: $defaultStrategy, ')
          ..write('hideBalances: $hideBalances, ')
          ..write('appLockEnabled: $appLockEnabled, ')
          ..write('aiConsentEnabled: $aiConsentEnabled, ')
          ..write('notificationsEnabled: $notificationsEnabled, ')
          ..write('onboardingCompleted: $onboardingCompleted, ')
          ..write('weeklySummaryEnabled: $weeklySummaryEnabled, ')
          ..write('rawOcrRetentionEnabled: $rawOcrRetentionEnabled, ')
          ..write('rawOcrRetentionHours: $rawOcrRetentionHours, ')
          ..write('documentRetentionMode: $documentRetentionMode, ')
          ..write(
            'purgeFailedImportsAfterHours: $purgeFailedImportsAfterHours, ',
          )
          ..write('dataProtectionExplainerSeen: $dataProtectionExplainerSeen')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    key,
    themeMode,
    currencyCode,
    localeCode,
    defaultStrategy,
    hideBalances,
    appLockEnabled,
    aiConsentEnabled,
    notificationsEnabled,
    onboardingCompleted,
    weeklySummaryEnabled,
    rawOcrRetentionEnabled,
    rawOcrRetentionHours,
    documentRetentionMode,
    purgeFailedImportsAfterHours,
    dataProtectionExplainerSeen,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppPreferencesTableData &&
          other.key == this.key &&
          other.themeMode == this.themeMode &&
          other.currencyCode == this.currencyCode &&
          other.localeCode == this.localeCode &&
          other.defaultStrategy == this.defaultStrategy &&
          other.hideBalances == this.hideBalances &&
          other.appLockEnabled == this.appLockEnabled &&
          other.aiConsentEnabled == this.aiConsentEnabled &&
          other.notificationsEnabled == this.notificationsEnabled &&
          other.onboardingCompleted == this.onboardingCompleted &&
          other.weeklySummaryEnabled == this.weeklySummaryEnabled &&
          other.rawOcrRetentionEnabled == this.rawOcrRetentionEnabled &&
          other.rawOcrRetentionHours == this.rawOcrRetentionHours &&
          other.documentRetentionMode == this.documentRetentionMode &&
          other.purgeFailedImportsAfterHours ==
              this.purgeFailedImportsAfterHours &&
          other.dataProtectionExplainerSeen ==
              this.dataProtectionExplainerSeen);
}

class AppPreferencesTableCompanion
    extends UpdateCompanion<AppPreferencesTableData> {
  final Value<int> key;
  final Value<String> themeMode;
  final Value<String> currencyCode;
  final Value<String> localeCode;
  final Value<String> defaultStrategy;
  final Value<bool> hideBalances;
  final Value<bool> appLockEnabled;
  final Value<bool> aiConsentEnabled;
  final Value<bool> notificationsEnabled;
  final Value<bool> onboardingCompleted;
  final Value<bool> weeklySummaryEnabled;
  final Value<bool> rawOcrRetentionEnabled;
  final Value<int> rawOcrRetentionHours;
  final Value<String> documentRetentionMode;
  final Value<int> purgeFailedImportsAfterHours;
  final Value<bool> dataProtectionExplainerSeen;
  const AppPreferencesTableCompanion({
    this.key = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.localeCode = const Value.absent(),
    this.defaultStrategy = const Value.absent(),
    this.hideBalances = const Value.absent(),
    this.appLockEnabled = const Value.absent(),
    this.aiConsentEnabled = const Value.absent(),
    this.notificationsEnabled = const Value.absent(),
    this.onboardingCompleted = const Value.absent(),
    this.weeklySummaryEnabled = const Value.absent(),
    this.rawOcrRetentionEnabled = const Value.absent(),
    this.rawOcrRetentionHours = const Value.absent(),
    this.documentRetentionMode = const Value.absent(),
    this.purgeFailedImportsAfterHours = const Value.absent(),
    this.dataProtectionExplainerSeen = const Value.absent(),
  });
  AppPreferencesTableCompanion.insert({
    this.key = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.localeCode = const Value.absent(),
    this.defaultStrategy = const Value.absent(),
    this.hideBalances = const Value.absent(),
    this.appLockEnabled = const Value.absent(),
    this.aiConsentEnabled = const Value.absent(),
    this.notificationsEnabled = const Value.absent(),
    this.onboardingCompleted = const Value.absent(),
    this.weeklySummaryEnabled = const Value.absent(),
    this.rawOcrRetentionEnabled = const Value.absent(),
    this.rawOcrRetentionHours = const Value.absent(),
    this.documentRetentionMode = const Value.absent(),
    this.purgeFailedImportsAfterHours = const Value.absent(),
    this.dataProtectionExplainerSeen = const Value.absent(),
  });
  static Insertable<AppPreferencesTableData> custom({
    Expression<int>? key,
    Expression<String>? themeMode,
    Expression<String>? currencyCode,
    Expression<String>? localeCode,
    Expression<String>? defaultStrategy,
    Expression<bool>? hideBalances,
    Expression<bool>? appLockEnabled,
    Expression<bool>? aiConsentEnabled,
    Expression<bool>? notificationsEnabled,
    Expression<bool>? onboardingCompleted,
    Expression<bool>? weeklySummaryEnabled,
    Expression<bool>? rawOcrRetentionEnabled,
    Expression<int>? rawOcrRetentionHours,
    Expression<String>? documentRetentionMode,
    Expression<int>? purgeFailedImportsAfterHours,
    Expression<bool>? dataProtectionExplainerSeen,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (themeMode != null) 'theme_mode': themeMode,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (localeCode != null) 'locale_code': localeCode,
      if (defaultStrategy != null) 'default_strategy': defaultStrategy,
      if (hideBalances != null) 'hide_balances': hideBalances,
      if (appLockEnabled != null) 'app_lock_enabled': appLockEnabled,
      if (aiConsentEnabled != null) 'ai_consent_enabled': aiConsentEnabled,
      if (notificationsEnabled != null)
        'notifications_enabled': notificationsEnabled,
      if (onboardingCompleted != null)
        'onboarding_completed': onboardingCompleted,
      if (weeklySummaryEnabled != null)
        'weekly_summary_enabled': weeklySummaryEnabled,
      if (rawOcrRetentionEnabled != null)
        'raw_ocr_retention_enabled': rawOcrRetentionEnabled,
      if (rawOcrRetentionHours != null)
        'raw_ocr_retention_hours': rawOcrRetentionHours,
      if (documentRetentionMode != null)
        'document_retention_mode': documentRetentionMode,
      if (purgeFailedImportsAfterHours != null)
        'purge_failed_imports_after_hours': purgeFailedImportsAfterHours,
      if (dataProtectionExplainerSeen != null)
        'data_protection_explainer_seen': dataProtectionExplainerSeen,
    });
  }

  AppPreferencesTableCompanion copyWith({
    Value<int>? key,
    Value<String>? themeMode,
    Value<String>? currencyCode,
    Value<String>? localeCode,
    Value<String>? defaultStrategy,
    Value<bool>? hideBalances,
    Value<bool>? appLockEnabled,
    Value<bool>? aiConsentEnabled,
    Value<bool>? notificationsEnabled,
    Value<bool>? onboardingCompleted,
    Value<bool>? weeklySummaryEnabled,
    Value<bool>? rawOcrRetentionEnabled,
    Value<int>? rawOcrRetentionHours,
    Value<String>? documentRetentionMode,
    Value<int>? purgeFailedImportsAfterHours,
    Value<bool>? dataProtectionExplainerSeen,
  }) {
    return AppPreferencesTableCompanion(
      key: key ?? this.key,
      themeMode: themeMode ?? this.themeMode,
      currencyCode: currencyCode ?? this.currencyCode,
      localeCode: localeCode ?? this.localeCode,
      defaultStrategy: defaultStrategy ?? this.defaultStrategy,
      hideBalances: hideBalances ?? this.hideBalances,
      appLockEnabled: appLockEnabled ?? this.appLockEnabled,
      aiConsentEnabled: aiConsentEnabled ?? this.aiConsentEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      weeklySummaryEnabled: weeklySummaryEnabled ?? this.weeklySummaryEnabled,
      rawOcrRetentionEnabled:
          rawOcrRetentionEnabled ?? this.rawOcrRetentionEnabled,
      rawOcrRetentionHours: rawOcrRetentionHours ?? this.rawOcrRetentionHours,
      documentRetentionMode:
          documentRetentionMode ?? this.documentRetentionMode,
      purgeFailedImportsAfterHours:
          purgeFailedImportsAfterHours ?? this.purgeFailedImportsAfterHours,
      dataProtectionExplainerSeen:
          dataProtectionExplainerSeen ?? this.dataProtectionExplainerSeen,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<int>(key.value);
    }
    if (themeMode.present) {
      map['theme_mode'] = Variable<String>(themeMode.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (localeCode.present) {
      map['locale_code'] = Variable<String>(localeCode.value);
    }
    if (defaultStrategy.present) {
      map['default_strategy'] = Variable<String>(defaultStrategy.value);
    }
    if (hideBalances.present) {
      map['hide_balances'] = Variable<bool>(hideBalances.value);
    }
    if (appLockEnabled.present) {
      map['app_lock_enabled'] = Variable<bool>(appLockEnabled.value);
    }
    if (aiConsentEnabled.present) {
      map['ai_consent_enabled'] = Variable<bool>(aiConsentEnabled.value);
    }
    if (notificationsEnabled.present) {
      map['notifications_enabled'] = Variable<bool>(notificationsEnabled.value);
    }
    if (onboardingCompleted.present) {
      map['onboarding_completed'] = Variable<bool>(onboardingCompleted.value);
    }
    if (weeklySummaryEnabled.present) {
      map['weekly_summary_enabled'] = Variable<bool>(
        weeklySummaryEnabled.value,
      );
    }
    if (rawOcrRetentionEnabled.present) {
      map['raw_ocr_retention_enabled'] = Variable<bool>(
        rawOcrRetentionEnabled.value,
      );
    }
    if (rawOcrRetentionHours.present) {
      map['raw_ocr_retention_hours'] = Variable<int>(
        rawOcrRetentionHours.value,
      );
    }
    if (documentRetentionMode.present) {
      map['document_retention_mode'] = Variable<String>(
        documentRetentionMode.value,
      );
    }
    if (purgeFailedImportsAfterHours.present) {
      map['purge_failed_imports_after_hours'] = Variable<int>(
        purgeFailedImportsAfterHours.value,
      );
    }
    if (dataProtectionExplainerSeen.present) {
      map['data_protection_explainer_seen'] = Variable<bool>(
        dataProtectionExplainerSeen.value,
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppPreferencesTableCompanion(')
          ..write('key: $key, ')
          ..write('themeMode: $themeMode, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('localeCode: $localeCode, ')
          ..write('defaultStrategy: $defaultStrategy, ')
          ..write('hideBalances: $hideBalances, ')
          ..write('appLockEnabled: $appLockEnabled, ')
          ..write('aiConsentEnabled: $aiConsentEnabled, ')
          ..write('notificationsEnabled: $notificationsEnabled, ')
          ..write('onboardingCompleted: $onboardingCompleted, ')
          ..write('weeklySummaryEnabled: $weeklySummaryEnabled, ')
          ..write('rawOcrRetentionEnabled: $rawOcrRetentionEnabled, ')
          ..write('rawOcrRetentionHours: $rawOcrRetentionHours, ')
          ..write('documentRetentionMode: $documentRetentionMode, ')
          ..write(
            'purgeFailedImportsAfterHours: $purgeFailedImportsAfterHours, ',
          )
          ..write('dataProtectionExplainerSeen: $dataProtectionExplainerSeen')
          ..write(')'))
        .toString();
  }
}

class $SubscriptionStateTableTable extends SubscriptionStateTable
    with TableInfo<$SubscriptionStateTableTable, SubscriptionStateTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubscriptionStateTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<int> key = GeneratedColumn<int>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _isPremiumMeta = const VerificationMeta(
    'isPremium',
  );
  @override
  late final GeneratedColumn<bool> isPremium = GeneratedColumn<bool>(
    'is_premium',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_premium" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _expiresAtMeta = const VerificationMeta(
    'expiresAt',
  );
  @override
  late final GeneratedColumn<DateTime> expiresAt = GeneratedColumn<DateTime>(
    'expires_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _planIdMeta = const VerificationMeta('planId');
  @override
  late final GeneratedColumn<String> planId = GeneratedColumn<String>(
    'plan_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _billingProviderMeta = const VerificationMeta(
    'billingProvider',
  );
  @override
  late final GeneratedColumn<String> billingProvider = GeneratedColumn<String>(
    'billing_provider',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('free'),
  );
  static const VerificationMeta _lastVerifiedAtMeta = const VerificationMeta(
    'lastVerifiedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastVerifiedAt =
      GeneratedColumn<DateTime>(
        'last_verified_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _unlockedFeaturesJsonMeta =
      const VerificationMeta('unlockedFeaturesJson');
  @override
  late final GeneratedColumn<String> unlockedFeaturesJson =
      GeneratedColumn<String>(
        'unlocked_features_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      );
  @override
  List<GeneratedColumn> get $columns => [
    key,
    isPremium,
    expiresAt,
    productId,
    planId,
    billingProvider,
    status,
    lastVerifiedAt,
    unlockedFeaturesJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'subscription_state_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<SubscriptionStateTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    }
    if (data.containsKey('is_premium')) {
      context.handle(
        _isPremiumMeta,
        isPremium.isAcceptableOrUnknown(data['is_premium']!, _isPremiumMeta),
      );
    }
    if (data.containsKey('expires_at')) {
      context.handle(
        _expiresAtMeta,
        expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta),
      );
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    }
    if (data.containsKey('plan_id')) {
      context.handle(
        _planIdMeta,
        planId.isAcceptableOrUnknown(data['plan_id']!, _planIdMeta),
      );
    }
    if (data.containsKey('billing_provider')) {
      context.handle(
        _billingProviderMeta,
        billingProvider.isAcceptableOrUnknown(
          data['billing_provider']!,
          _billingProviderMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('last_verified_at')) {
      context.handle(
        _lastVerifiedAtMeta,
        lastVerifiedAt.isAcceptableOrUnknown(
          data['last_verified_at']!,
          _lastVerifiedAtMeta,
        ),
      );
    }
    if (data.containsKey('unlocked_features_json')) {
      context.handle(
        _unlockedFeaturesJsonMeta,
        unlockedFeaturesJson.isAcceptableOrUnknown(
          data['unlocked_features_json']!,
          _unlockedFeaturesJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SubscriptionStateTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SubscriptionStateTableData(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}key'],
      )!,
      isPremium: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_premium'],
      )!,
      expiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expires_at'],
      ),
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      ),
      planId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plan_id'],
      ),
      billingProvider: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}billing_provider'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      lastVerifiedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_verified_at'],
      ),
      unlockedFeaturesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unlocked_features_json'],
      )!,
    );
  }

  @override
  $SubscriptionStateTableTable createAlias(String alias) {
    return $SubscriptionStateTableTable(attachedDatabase, alias);
  }
}

class SubscriptionStateTableData extends DataClass
    implements Insertable<SubscriptionStateTableData> {
  final int key;
  final bool isPremium;
  final DateTime? expiresAt;
  final String? productId;
  final String? planId;
  final String? billingProvider;
  final String status;
  final DateTime? lastVerifiedAt;
  final String unlockedFeaturesJson;
  const SubscriptionStateTableData({
    required this.key,
    required this.isPremium,
    this.expiresAt,
    this.productId,
    this.planId,
    this.billingProvider,
    required this.status,
    this.lastVerifiedAt,
    required this.unlockedFeaturesJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<int>(key);
    map['is_premium'] = Variable<bool>(isPremium);
    if (!nullToAbsent || expiresAt != null) {
      map['expires_at'] = Variable<DateTime>(expiresAt);
    }
    if (!nullToAbsent || productId != null) {
      map['product_id'] = Variable<String>(productId);
    }
    if (!nullToAbsent || planId != null) {
      map['plan_id'] = Variable<String>(planId);
    }
    if (!nullToAbsent || billingProvider != null) {
      map['billing_provider'] = Variable<String>(billingProvider);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || lastVerifiedAt != null) {
      map['last_verified_at'] = Variable<DateTime>(lastVerifiedAt);
    }
    map['unlocked_features_json'] = Variable<String>(unlockedFeaturesJson);
    return map;
  }

  SubscriptionStateTableCompanion toCompanion(bool nullToAbsent) {
    return SubscriptionStateTableCompanion(
      key: Value(key),
      isPremium: Value(isPremium),
      expiresAt: expiresAt == null && nullToAbsent
          ? const Value.absent()
          : Value(expiresAt),
      productId: productId == null && nullToAbsent
          ? const Value.absent()
          : Value(productId),
      planId: planId == null && nullToAbsent
          ? const Value.absent()
          : Value(planId),
      billingProvider: billingProvider == null && nullToAbsent
          ? const Value.absent()
          : Value(billingProvider),
      status: Value(status),
      lastVerifiedAt: lastVerifiedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastVerifiedAt),
      unlockedFeaturesJson: Value(unlockedFeaturesJson),
    );
  }

  factory SubscriptionStateTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SubscriptionStateTableData(
      key: serializer.fromJson<int>(json['key']),
      isPremium: serializer.fromJson<bool>(json['isPremium']),
      expiresAt: serializer.fromJson<DateTime?>(json['expiresAt']),
      productId: serializer.fromJson<String?>(json['productId']),
      planId: serializer.fromJson<String?>(json['planId']),
      billingProvider: serializer.fromJson<String?>(json['billingProvider']),
      status: serializer.fromJson<String>(json['status']),
      lastVerifiedAt: serializer.fromJson<DateTime?>(json['lastVerifiedAt']),
      unlockedFeaturesJson: serializer.fromJson<String>(
        json['unlockedFeaturesJson'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<int>(key),
      'isPremium': serializer.toJson<bool>(isPremium),
      'expiresAt': serializer.toJson<DateTime?>(expiresAt),
      'productId': serializer.toJson<String?>(productId),
      'planId': serializer.toJson<String?>(planId),
      'billingProvider': serializer.toJson<String?>(billingProvider),
      'status': serializer.toJson<String>(status),
      'lastVerifiedAt': serializer.toJson<DateTime?>(lastVerifiedAt),
      'unlockedFeaturesJson': serializer.toJson<String>(unlockedFeaturesJson),
    };
  }

  SubscriptionStateTableData copyWith({
    int? key,
    bool? isPremium,
    Value<DateTime?> expiresAt = const Value.absent(),
    Value<String?> productId = const Value.absent(),
    Value<String?> planId = const Value.absent(),
    Value<String?> billingProvider = const Value.absent(),
    String? status,
    Value<DateTime?> lastVerifiedAt = const Value.absent(),
    String? unlockedFeaturesJson,
  }) => SubscriptionStateTableData(
    key: key ?? this.key,
    isPremium: isPremium ?? this.isPremium,
    expiresAt: expiresAt.present ? expiresAt.value : this.expiresAt,
    productId: productId.present ? productId.value : this.productId,
    planId: planId.present ? planId.value : this.planId,
    billingProvider: billingProvider.present
        ? billingProvider.value
        : this.billingProvider,
    status: status ?? this.status,
    lastVerifiedAt: lastVerifiedAt.present
        ? lastVerifiedAt.value
        : this.lastVerifiedAt,
    unlockedFeaturesJson: unlockedFeaturesJson ?? this.unlockedFeaturesJson,
  );
  SubscriptionStateTableData copyWithCompanion(
    SubscriptionStateTableCompanion data,
  ) {
    return SubscriptionStateTableData(
      key: data.key.present ? data.key.value : this.key,
      isPremium: data.isPremium.present ? data.isPremium.value : this.isPremium,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
      productId: data.productId.present ? data.productId.value : this.productId,
      planId: data.planId.present ? data.planId.value : this.planId,
      billingProvider: data.billingProvider.present
          ? data.billingProvider.value
          : this.billingProvider,
      status: data.status.present ? data.status.value : this.status,
      lastVerifiedAt: data.lastVerifiedAt.present
          ? data.lastVerifiedAt.value
          : this.lastVerifiedAt,
      unlockedFeaturesJson: data.unlockedFeaturesJson.present
          ? data.unlockedFeaturesJson.value
          : this.unlockedFeaturesJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SubscriptionStateTableData(')
          ..write('key: $key, ')
          ..write('isPremium: $isPremium, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('productId: $productId, ')
          ..write('planId: $planId, ')
          ..write('billingProvider: $billingProvider, ')
          ..write('status: $status, ')
          ..write('lastVerifiedAt: $lastVerifiedAt, ')
          ..write('unlockedFeaturesJson: $unlockedFeaturesJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    key,
    isPremium,
    expiresAt,
    productId,
    planId,
    billingProvider,
    status,
    lastVerifiedAt,
    unlockedFeaturesJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SubscriptionStateTableData &&
          other.key == this.key &&
          other.isPremium == this.isPremium &&
          other.expiresAt == this.expiresAt &&
          other.productId == this.productId &&
          other.planId == this.planId &&
          other.billingProvider == this.billingProvider &&
          other.status == this.status &&
          other.lastVerifiedAt == this.lastVerifiedAt &&
          other.unlockedFeaturesJson == this.unlockedFeaturesJson);
}

class SubscriptionStateTableCompanion
    extends UpdateCompanion<SubscriptionStateTableData> {
  final Value<int> key;
  final Value<bool> isPremium;
  final Value<DateTime?> expiresAt;
  final Value<String?> productId;
  final Value<String?> planId;
  final Value<String?> billingProvider;
  final Value<String> status;
  final Value<DateTime?> lastVerifiedAt;
  final Value<String> unlockedFeaturesJson;
  const SubscriptionStateTableCompanion({
    this.key = const Value.absent(),
    this.isPremium = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.productId = const Value.absent(),
    this.planId = const Value.absent(),
    this.billingProvider = const Value.absent(),
    this.status = const Value.absent(),
    this.lastVerifiedAt = const Value.absent(),
    this.unlockedFeaturesJson = const Value.absent(),
  });
  SubscriptionStateTableCompanion.insert({
    this.key = const Value.absent(),
    this.isPremium = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.productId = const Value.absent(),
    this.planId = const Value.absent(),
    this.billingProvider = const Value.absent(),
    this.status = const Value.absent(),
    this.lastVerifiedAt = const Value.absent(),
    this.unlockedFeaturesJson = const Value.absent(),
  });
  static Insertable<SubscriptionStateTableData> custom({
    Expression<int>? key,
    Expression<bool>? isPremium,
    Expression<DateTime>? expiresAt,
    Expression<String>? productId,
    Expression<String>? planId,
    Expression<String>? billingProvider,
    Expression<String>? status,
    Expression<DateTime>? lastVerifiedAt,
    Expression<String>? unlockedFeaturesJson,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (isPremium != null) 'is_premium': isPremium,
      if (expiresAt != null) 'expires_at': expiresAt,
      if (productId != null) 'product_id': productId,
      if (planId != null) 'plan_id': planId,
      if (billingProvider != null) 'billing_provider': billingProvider,
      if (status != null) 'status': status,
      if (lastVerifiedAt != null) 'last_verified_at': lastVerifiedAt,
      if (unlockedFeaturesJson != null)
        'unlocked_features_json': unlockedFeaturesJson,
    });
  }

  SubscriptionStateTableCompanion copyWith({
    Value<int>? key,
    Value<bool>? isPremium,
    Value<DateTime?>? expiresAt,
    Value<String?>? productId,
    Value<String?>? planId,
    Value<String?>? billingProvider,
    Value<String>? status,
    Value<DateTime?>? lastVerifiedAt,
    Value<String>? unlockedFeaturesJson,
  }) {
    return SubscriptionStateTableCompanion(
      key: key ?? this.key,
      isPremium: isPremium ?? this.isPremium,
      expiresAt: expiresAt ?? this.expiresAt,
      productId: productId ?? this.productId,
      planId: planId ?? this.planId,
      billingProvider: billingProvider ?? this.billingProvider,
      status: status ?? this.status,
      lastVerifiedAt: lastVerifiedAt ?? this.lastVerifiedAt,
      unlockedFeaturesJson: unlockedFeaturesJson ?? this.unlockedFeaturesJson,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<int>(key.value);
    }
    if (isPremium.present) {
      map['is_premium'] = Variable<bool>(isPremium.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<DateTime>(expiresAt.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (planId.present) {
      map['plan_id'] = Variable<String>(planId.value);
    }
    if (billingProvider.present) {
      map['billing_provider'] = Variable<String>(billingProvider.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (lastVerifiedAt.present) {
      map['last_verified_at'] = Variable<DateTime>(lastVerifiedAt.value);
    }
    if (unlockedFeaturesJson.present) {
      map['unlocked_features_json'] = Variable<String>(
        unlockedFeaturesJson.value,
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubscriptionStateTableCompanion(')
          ..write('key: $key, ')
          ..write('isPremium: $isPremium, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('productId: $productId, ')
          ..write('planId: $planId, ')
          ..write('billingProvider: $billingProvider, ')
          ..write('status: $status, ')
          ..write('lastVerifiedAt: $lastVerifiedAt, ')
          ..write('unlockedFeaturesJson: $unlockedFeaturesJson')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $DebtsTableTable debtsTable = $DebtsTableTable(this);
  late final $PaymentsTableTable paymentsTable = $PaymentsTableTable(this);
  late final $ImportedDocumentsTableTable importedDocumentsTable =
      $ImportedDocumentsTableTable(this);
  late final $ParsedExtractionsTableTable parsedExtractionsTable =
      $ParsedExtractionsTableTable(this);
  late final $ReminderRulesTableTable reminderRulesTable =
      $ReminderRulesTableTable(this);
  late final $ScenariosTableTable scenariosTable = $ScenariosTableTable(this);
  late final $AppPreferencesTableTable appPreferencesTable =
      $AppPreferencesTableTable(this);
  late final $SubscriptionStateTableTable subscriptionStateTable =
      $SubscriptionStateTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    debtsTable,
    paymentsTable,
    importedDocumentsTable,
    parsedExtractionsTable,
    reminderRulesTable,
    scenariosTable,
    appPreferencesTable,
    subscriptionStateTable,
  ];
}

typedef $$DebtsTableTableCreateCompanionBuilder =
    DebtsTableCompanion Function({
      required String id,
      required String title,
      required String creditorName,
      required String type,
      required String currency,
      required double originalBalance,
      required double currentBalance,
      required double apr,
      required double minimumPayment,
      Value<DateTime?> dueDate,
      required String paymentFrequency,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<String> notes,
      Value<String> tagsJson,
      Value<String> financialTermsJson,
      required String status,
      Value<bool> remindersEnabled,
      Value<int> customPriority,
      Value<int> rowid,
    });
typedef $$DebtsTableTableUpdateCompanionBuilder =
    DebtsTableCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> creditorName,
      Value<String> type,
      Value<String> currency,
      Value<double> originalBalance,
      Value<double> currentBalance,
      Value<double> apr,
      Value<double> minimumPayment,
      Value<DateTime?> dueDate,
      Value<String> paymentFrequency,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> notes,
      Value<String> tagsJson,
      Value<String> financialTermsJson,
      Value<String> status,
      Value<bool> remindersEnabled,
      Value<int> customPriority,
      Value<int> rowid,
    });

final class $$DebtsTableTableReferences
    extends BaseReferences<_$AppDatabase, $DebtsTableTable, DebtsTableData> {
  $$DebtsTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PaymentsTableTable, List<PaymentsTableData>>
  _paymentsTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.paymentsTable,
    aliasName: $_aliasNameGenerator(db.debtsTable.id, db.paymentsTable.debtId),
  );

  $$PaymentsTableTableProcessedTableManager get paymentsTableRefs {
    final manager = $$PaymentsTableTableTableManager(
      $_db,
      $_db.paymentsTable,
    ).filter((f) => f.debtId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_paymentsTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $ReminderRulesTableTable,
    List<ReminderRulesTableData>
  >
  _reminderRulesTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.reminderRulesTable,
        aliasName: $_aliasNameGenerator(
          db.debtsTable.id,
          db.reminderRulesTable.debtId,
        ),
      );

  $$ReminderRulesTableTableProcessedTableManager get reminderRulesTableRefs {
    final manager = $$ReminderRulesTableTableTableManager(
      $_db,
      $_db.reminderRulesTable,
    ).filter((f) => f.debtId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _reminderRulesTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DebtsTableTableFilterComposer
    extends Composer<_$AppDatabase, $DebtsTableTable> {
  $$DebtsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get creditorName => $composableBuilder(
    column: $table.creditorName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get originalBalance => $composableBuilder(
    column: $table.originalBalance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get currentBalance => $composableBuilder(
    column: $table.currentBalance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get apr => $composableBuilder(
    column: $table.apr,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get minimumPayment => $composableBuilder(
    column: $table.minimumPayment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentFrequency => $composableBuilder(
    column: $table.paymentFrequency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tagsJson => $composableBuilder(
    column: $table.tagsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get financialTermsJson => $composableBuilder(
    column: $table.financialTermsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get remindersEnabled => $composableBuilder(
    column: $table.remindersEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get customPriority => $composableBuilder(
    column: $table.customPriority,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> paymentsTableRefs(
    Expression<bool> Function($$PaymentsTableTableFilterComposer f) f,
  ) {
    final $$PaymentsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.paymentsTable,
      getReferencedColumn: (t) => t.debtId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentsTableTableFilterComposer(
            $db: $db,
            $table: $db.paymentsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> reminderRulesTableRefs(
    Expression<bool> Function($$ReminderRulesTableTableFilterComposer f) f,
  ) {
    final $$ReminderRulesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reminderRulesTable,
      getReferencedColumn: (t) => t.debtId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReminderRulesTableTableFilterComposer(
            $db: $db,
            $table: $db.reminderRulesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DebtsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $DebtsTableTable> {
  $$DebtsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get creditorName => $composableBuilder(
    column: $table.creditorName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get originalBalance => $composableBuilder(
    column: $table.originalBalance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get currentBalance => $composableBuilder(
    column: $table.currentBalance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get apr => $composableBuilder(
    column: $table.apr,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get minimumPayment => $composableBuilder(
    column: $table.minimumPayment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentFrequency => $composableBuilder(
    column: $table.paymentFrequency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tagsJson => $composableBuilder(
    column: $table.tagsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get financialTermsJson => $composableBuilder(
    column: $table.financialTermsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get remindersEnabled => $composableBuilder(
    column: $table.remindersEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get customPriority => $composableBuilder(
    column: $table.customPriority,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DebtsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $DebtsTableTable> {
  $$DebtsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get creditorName => $composableBuilder(
    column: $table.creditorName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<double> get originalBalance => $composableBuilder(
    column: $table.originalBalance,
    builder: (column) => column,
  );

  GeneratedColumn<double> get currentBalance => $composableBuilder(
    column: $table.currentBalance,
    builder: (column) => column,
  );

  GeneratedColumn<double> get apr =>
      $composableBuilder(column: $table.apr, builder: (column) => column);

  GeneratedColumn<double> get minimumPayment => $composableBuilder(
    column: $table.minimumPayment,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<String> get paymentFrequency => $composableBuilder(
    column: $table.paymentFrequency,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get tagsJson =>
      $composableBuilder(column: $table.tagsJson, builder: (column) => column);

  GeneratedColumn<String> get financialTermsJson => $composableBuilder(
    column: $table.financialTermsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<bool> get remindersEnabled => $composableBuilder(
    column: $table.remindersEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<int> get customPriority => $composableBuilder(
    column: $table.customPriority,
    builder: (column) => column,
  );

  Expression<T> paymentsTableRefs<T extends Object>(
    Expression<T> Function($$PaymentsTableTableAnnotationComposer a) f,
  ) {
    final $$PaymentsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.paymentsTable,
      getReferencedColumn: (t) => t.debtId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.paymentsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> reminderRulesTableRefs<T extends Object>(
    Expression<T> Function($$ReminderRulesTableTableAnnotationComposer a) f,
  ) {
    final $$ReminderRulesTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.reminderRulesTable,
          getReferencedColumn: (t) => t.debtId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ReminderRulesTableTableAnnotationComposer(
                $db: $db,
                $table: $db.reminderRulesTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$DebtsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DebtsTableTable,
          DebtsTableData,
          $$DebtsTableTableFilterComposer,
          $$DebtsTableTableOrderingComposer,
          $$DebtsTableTableAnnotationComposer,
          $$DebtsTableTableCreateCompanionBuilder,
          $$DebtsTableTableUpdateCompanionBuilder,
          (DebtsTableData, $$DebtsTableTableReferences),
          DebtsTableData,
          PrefetchHooks Function({
            bool paymentsTableRefs,
            bool reminderRulesTableRefs,
          })
        > {
  $$DebtsTableTableTableManager(_$AppDatabase db, $DebtsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DebtsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DebtsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DebtsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> creditorName = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<double> originalBalance = const Value.absent(),
                Value<double> currentBalance = const Value.absent(),
                Value<double> apr = const Value.absent(),
                Value<double> minimumPayment = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                Value<String> paymentFrequency = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<String> tagsJson = const Value.absent(),
                Value<String> financialTermsJson = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<bool> remindersEnabled = const Value.absent(),
                Value<int> customPriority = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DebtsTableCompanion(
                id: id,
                title: title,
                creditorName: creditorName,
                type: type,
                currency: currency,
                originalBalance: originalBalance,
                currentBalance: currentBalance,
                apr: apr,
                minimumPayment: minimumPayment,
                dueDate: dueDate,
                paymentFrequency: paymentFrequency,
                createdAt: createdAt,
                updatedAt: updatedAt,
                notes: notes,
                tagsJson: tagsJson,
                financialTermsJson: financialTermsJson,
                status: status,
                remindersEnabled: remindersEnabled,
                customPriority: customPriority,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required String creditorName,
                required String type,
                required String currency,
                required double originalBalance,
                required double currentBalance,
                required double apr,
                required double minimumPayment,
                Value<DateTime?> dueDate = const Value.absent(),
                required String paymentFrequency,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<String> notes = const Value.absent(),
                Value<String> tagsJson = const Value.absent(),
                Value<String> financialTermsJson = const Value.absent(),
                required String status,
                Value<bool> remindersEnabled = const Value.absent(),
                Value<int> customPriority = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DebtsTableCompanion.insert(
                id: id,
                title: title,
                creditorName: creditorName,
                type: type,
                currency: currency,
                originalBalance: originalBalance,
                currentBalance: currentBalance,
                apr: apr,
                minimumPayment: minimumPayment,
                dueDate: dueDate,
                paymentFrequency: paymentFrequency,
                createdAt: createdAt,
                updatedAt: updatedAt,
                notes: notes,
                tagsJson: tagsJson,
                financialTermsJson: financialTermsJson,
                status: status,
                remindersEnabled: remindersEnabled,
                customPriority: customPriority,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DebtsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({paymentsTableRefs = false, reminderRulesTableRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (paymentsTableRefs) db.paymentsTable,
                    if (reminderRulesTableRefs) db.reminderRulesTable,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (paymentsTableRefs)
                        await $_getPrefetchedData<
                          DebtsTableData,
                          $DebtsTableTable,
                          PaymentsTableData
                        >(
                          currentTable: table,
                          referencedTable: $$DebtsTableTableReferences
                              ._paymentsTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DebtsTableTableReferences(
                                db,
                                table,
                                p0,
                              ).paymentsTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.debtId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (reminderRulesTableRefs)
                        await $_getPrefetchedData<
                          DebtsTableData,
                          $DebtsTableTable,
                          ReminderRulesTableData
                        >(
                          currentTable: table,
                          referencedTable: $$DebtsTableTableReferences
                              ._reminderRulesTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DebtsTableTableReferences(
                                db,
                                table,
                                p0,
                              ).reminderRulesTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.debtId == item.id,
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

typedef $$DebtsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DebtsTableTable,
      DebtsTableData,
      $$DebtsTableTableFilterComposer,
      $$DebtsTableTableOrderingComposer,
      $$DebtsTableTableAnnotationComposer,
      $$DebtsTableTableCreateCompanionBuilder,
      $$DebtsTableTableUpdateCompanionBuilder,
      (DebtsTableData, $$DebtsTableTableReferences),
      DebtsTableData,
      PrefetchHooks Function({
        bool paymentsTableRefs,
        bool reminderRulesTableRefs,
      })
    >;
typedef $$PaymentsTableTableCreateCompanionBuilder =
    PaymentsTableCompanion Function({
      required String id,
      required String debtId,
      required double amount,
      required DateTime date,
      Value<String?> method,
      required String sourceType,
      Value<String> notes,
      Value<String> tagsJson,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$PaymentsTableTableUpdateCompanionBuilder =
    PaymentsTableCompanion Function({
      Value<String> id,
      Value<String> debtId,
      Value<double> amount,
      Value<DateTime> date,
      Value<String?> method,
      Value<String> sourceType,
      Value<String> notes,
      Value<String> tagsJson,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$PaymentsTableTableReferences
    extends
        BaseReferences<_$AppDatabase, $PaymentsTableTable, PaymentsTableData> {
  $$PaymentsTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $DebtsTableTable _debtIdTable(_$AppDatabase db) =>
      db.debtsTable.createAlias(
        $_aliasNameGenerator(db.paymentsTable.debtId, db.debtsTable.id),
      );

  $$DebtsTableTableProcessedTableManager get debtId {
    final $_column = $_itemColumn<String>('debt_id')!;

    final manager = $$DebtsTableTableTableManager(
      $_db,
      $_db.debtsTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_debtIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PaymentsTableTableFilterComposer
    extends Composer<_$AppDatabase, $PaymentsTableTable> {
  $$PaymentsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tagsJson => $composableBuilder(
    column: $table.tagsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$DebtsTableTableFilterComposer get debtId {
    final $$DebtsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.debtId,
      referencedTable: $db.debtsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DebtsTableTableFilterComposer(
            $db: $db,
            $table: $db.debtsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaymentsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PaymentsTableTable> {
  $$PaymentsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tagsJson => $composableBuilder(
    column: $table.tagsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$DebtsTableTableOrderingComposer get debtId {
    final $$DebtsTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.debtId,
      referencedTable: $db.debtsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DebtsTableTableOrderingComposer(
            $db: $db,
            $table: $db.debtsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaymentsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PaymentsTableTable> {
  $$PaymentsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get method =>
      $composableBuilder(column: $table.method, builder: (column) => column);

  GeneratedColumn<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get tagsJson =>
      $composableBuilder(column: $table.tagsJson, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$DebtsTableTableAnnotationComposer get debtId {
    final $$DebtsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.debtId,
      referencedTable: $db.debtsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DebtsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.debtsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaymentsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PaymentsTableTable,
          PaymentsTableData,
          $$PaymentsTableTableFilterComposer,
          $$PaymentsTableTableOrderingComposer,
          $$PaymentsTableTableAnnotationComposer,
          $$PaymentsTableTableCreateCompanionBuilder,
          $$PaymentsTableTableUpdateCompanionBuilder,
          (PaymentsTableData, $$PaymentsTableTableReferences),
          PaymentsTableData,
          PrefetchHooks Function({bool debtId})
        > {
  $$PaymentsTableTableTableManager(_$AppDatabase db, $PaymentsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PaymentsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PaymentsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PaymentsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> debtId = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String?> method = const Value.absent(),
                Value<String> sourceType = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<String> tagsJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PaymentsTableCompanion(
                id: id,
                debtId: debtId,
                amount: amount,
                date: date,
                method: method,
                sourceType: sourceType,
                notes: notes,
                tagsJson: tagsJson,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String debtId,
                required double amount,
                required DateTime date,
                Value<String?> method = const Value.absent(),
                required String sourceType,
                Value<String> notes = const Value.absent(),
                Value<String> tagsJson = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => PaymentsTableCompanion.insert(
                id: id,
                debtId: debtId,
                amount: amount,
                date: date,
                method: method,
                sourceType: sourceType,
                notes: notes,
                tagsJson: tagsJson,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PaymentsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({debtId = false}) {
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
                    if (debtId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.debtId,
                                referencedTable: $$PaymentsTableTableReferences
                                    ._debtIdTable(db),
                                referencedColumn: $$PaymentsTableTableReferences
                                    ._debtIdTable(db)
                                    .id,
                              )
                              as T;
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

typedef $$PaymentsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PaymentsTableTable,
      PaymentsTableData,
      $$PaymentsTableTableFilterComposer,
      $$PaymentsTableTableOrderingComposer,
      $$PaymentsTableTableAnnotationComposer,
      $$PaymentsTableTableCreateCompanionBuilder,
      $$PaymentsTableTableUpdateCompanionBuilder,
      (PaymentsTableData, $$PaymentsTableTableReferences),
      PaymentsTableData,
      PrefetchHooks Function({bool debtId})
    >;
typedef $$ImportedDocumentsTableTableCreateCompanionBuilder =
    ImportedDocumentsTableCompanion Function({
      required String id,
      Value<String> localPath,
      Value<String?> storageRef,
      required String sourceType,
      required String mimeType,
      required DateTime createdAt,
      Value<String> lifecycleState,
      Value<String?> linkedDebtId,
      Value<String?> rawOcrText,
      required String parseStatus,
      required String parseVersion,
      Value<bool> deleted,
      Value<DateTime?> retentionExpiresAt,
      Value<DateTime?> rawOcrExpiresAt,
      Value<DateTime?> processedAt,
      Value<DateTime?> linkedAt,
      Value<DateTime?> pendingDeletionAt,
      Value<DateTime?> purgedAt,
      Value<DateTime?> encryptedAt,
      Value<bool> hasRawOcrText,
      Value<int> rowid,
    });
typedef $$ImportedDocumentsTableTableUpdateCompanionBuilder =
    ImportedDocumentsTableCompanion Function({
      Value<String> id,
      Value<String> localPath,
      Value<String?> storageRef,
      Value<String> sourceType,
      Value<String> mimeType,
      Value<DateTime> createdAt,
      Value<String> lifecycleState,
      Value<String?> linkedDebtId,
      Value<String?> rawOcrText,
      Value<String> parseStatus,
      Value<String> parseVersion,
      Value<bool> deleted,
      Value<DateTime?> retentionExpiresAt,
      Value<DateTime?> rawOcrExpiresAt,
      Value<DateTime?> processedAt,
      Value<DateTime?> linkedAt,
      Value<DateTime?> pendingDeletionAt,
      Value<DateTime?> purgedAt,
      Value<DateTime?> encryptedAt,
      Value<bool> hasRawOcrText,
      Value<int> rowid,
    });

final class $$ImportedDocumentsTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ImportedDocumentsTableTable,
          ImportedDocumentsTableData
        > {
  $$ImportedDocumentsTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<
    $ParsedExtractionsTableTable,
    List<ParsedExtractionsTableData>
  >
  _parsedExtractionsTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.parsedExtractionsTable,
        aliasName: $_aliasNameGenerator(
          db.importedDocumentsTable.id,
          db.parsedExtractionsTable.documentId,
        ),
      );

  $$ParsedExtractionsTableTableProcessedTableManager
  get parsedExtractionsTableRefs {
    final manager = $$ParsedExtractionsTableTableTableManager(
      $_db,
      $_db.parsedExtractionsTable,
    ).filter((f) => f.documentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _parsedExtractionsTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ImportedDocumentsTableTableFilterComposer
    extends Composer<_$AppDatabase, $ImportedDocumentsTableTable> {
  $$ImportedDocumentsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get storageRef => $composableBuilder(
    column: $table.storageRef,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lifecycleState => $composableBuilder(
    column: $table.lifecycleState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get linkedDebtId => $composableBuilder(
    column: $table.linkedDebtId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawOcrText => $composableBuilder(
    column: $table.rawOcrText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parseStatus => $composableBuilder(
    column: $table.parseStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parseVersion => $composableBuilder(
    column: $table.parseVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get retentionExpiresAt => $composableBuilder(
    column: $table.retentionExpiresAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get rawOcrExpiresAt => $composableBuilder(
    column: $table.rawOcrExpiresAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get processedAt => $composableBuilder(
    column: $table.processedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get linkedAt => $composableBuilder(
    column: $table.linkedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get pendingDeletionAt => $composableBuilder(
    column: $table.pendingDeletionAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get purgedAt => $composableBuilder(
    column: $table.purgedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get encryptedAt => $composableBuilder(
    column: $table.encryptedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasRawOcrText => $composableBuilder(
    column: $table.hasRawOcrText,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> parsedExtractionsTableRefs(
    Expression<bool> Function($$ParsedExtractionsTableTableFilterComposer f) f,
  ) {
    final $$ParsedExtractionsTableTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.parsedExtractionsTable,
          getReferencedColumn: (t) => t.documentId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ParsedExtractionsTableTableFilterComposer(
                $db: $db,
                $table: $db.parsedExtractionsTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ImportedDocumentsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ImportedDocumentsTableTable> {
  $$ImportedDocumentsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get storageRef => $composableBuilder(
    column: $table.storageRef,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lifecycleState => $composableBuilder(
    column: $table.lifecycleState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get linkedDebtId => $composableBuilder(
    column: $table.linkedDebtId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawOcrText => $composableBuilder(
    column: $table.rawOcrText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parseStatus => $composableBuilder(
    column: $table.parseStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parseVersion => $composableBuilder(
    column: $table.parseVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get retentionExpiresAt => $composableBuilder(
    column: $table.retentionExpiresAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get rawOcrExpiresAt => $composableBuilder(
    column: $table.rawOcrExpiresAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get processedAt => $composableBuilder(
    column: $table.processedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get linkedAt => $composableBuilder(
    column: $table.linkedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get pendingDeletionAt => $composableBuilder(
    column: $table.pendingDeletionAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get purgedAt => $composableBuilder(
    column: $table.purgedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get encryptedAt => $composableBuilder(
    column: $table.encryptedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasRawOcrText => $composableBuilder(
    column: $table.hasRawOcrText,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ImportedDocumentsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ImportedDocumentsTableTable> {
  $$ImportedDocumentsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<String> get storageRef => $composableBuilder(
    column: $table.storageRef,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get lifecycleState => $composableBuilder(
    column: $table.lifecycleState,
    builder: (column) => column,
  );

  GeneratedColumn<String> get linkedDebtId => $composableBuilder(
    column: $table.linkedDebtId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rawOcrText => $composableBuilder(
    column: $table.rawOcrText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get parseStatus => $composableBuilder(
    column: $table.parseStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get parseVersion => $composableBuilder(
    column: $table.parseVersion,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<DateTime> get retentionExpiresAt => $composableBuilder(
    column: $table.retentionExpiresAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get rawOcrExpiresAt => $composableBuilder(
    column: $table.rawOcrExpiresAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get processedAt => $composableBuilder(
    column: $table.processedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get linkedAt =>
      $composableBuilder(column: $table.linkedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get pendingDeletionAt => $composableBuilder(
    column: $table.pendingDeletionAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get purgedAt =>
      $composableBuilder(column: $table.purgedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get encryptedAt => $composableBuilder(
    column: $table.encryptedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get hasRawOcrText => $composableBuilder(
    column: $table.hasRawOcrText,
    builder: (column) => column,
  );

  Expression<T> parsedExtractionsTableRefs<T extends Object>(
    Expression<T> Function($$ParsedExtractionsTableTableAnnotationComposer a) f,
  ) {
    final $$ParsedExtractionsTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.parsedExtractionsTable,
          getReferencedColumn: (t) => t.documentId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ParsedExtractionsTableTableAnnotationComposer(
                $db: $db,
                $table: $db.parsedExtractionsTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ImportedDocumentsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ImportedDocumentsTableTable,
          ImportedDocumentsTableData,
          $$ImportedDocumentsTableTableFilterComposer,
          $$ImportedDocumentsTableTableOrderingComposer,
          $$ImportedDocumentsTableTableAnnotationComposer,
          $$ImportedDocumentsTableTableCreateCompanionBuilder,
          $$ImportedDocumentsTableTableUpdateCompanionBuilder,
          (ImportedDocumentsTableData, $$ImportedDocumentsTableTableReferences),
          ImportedDocumentsTableData,
          PrefetchHooks Function({bool parsedExtractionsTableRefs})
        > {
  $$ImportedDocumentsTableTableTableManager(
    _$AppDatabase db,
    $ImportedDocumentsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ImportedDocumentsTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ImportedDocumentsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ImportedDocumentsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> localPath = const Value.absent(),
                Value<String?> storageRef = const Value.absent(),
                Value<String> sourceType = const Value.absent(),
                Value<String> mimeType = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> lifecycleState = const Value.absent(),
                Value<String?> linkedDebtId = const Value.absent(),
                Value<String?> rawOcrText = const Value.absent(),
                Value<String> parseStatus = const Value.absent(),
                Value<String> parseVersion = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<DateTime?> retentionExpiresAt = const Value.absent(),
                Value<DateTime?> rawOcrExpiresAt = const Value.absent(),
                Value<DateTime?> processedAt = const Value.absent(),
                Value<DateTime?> linkedAt = const Value.absent(),
                Value<DateTime?> pendingDeletionAt = const Value.absent(),
                Value<DateTime?> purgedAt = const Value.absent(),
                Value<DateTime?> encryptedAt = const Value.absent(),
                Value<bool> hasRawOcrText = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ImportedDocumentsTableCompanion(
                id: id,
                localPath: localPath,
                storageRef: storageRef,
                sourceType: sourceType,
                mimeType: mimeType,
                createdAt: createdAt,
                lifecycleState: lifecycleState,
                linkedDebtId: linkedDebtId,
                rawOcrText: rawOcrText,
                parseStatus: parseStatus,
                parseVersion: parseVersion,
                deleted: deleted,
                retentionExpiresAt: retentionExpiresAt,
                rawOcrExpiresAt: rawOcrExpiresAt,
                processedAt: processedAt,
                linkedAt: linkedAt,
                pendingDeletionAt: pendingDeletionAt,
                purgedAt: purgedAt,
                encryptedAt: encryptedAt,
                hasRawOcrText: hasRawOcrText,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> localPath = const Value.absent(),
                Value<String?> storageRef = const Value.absent(),
                required String sourceType,
                required String mimeType,
                required DateTime createdAt,
                Value<String> lifecycleState = const Value.absent(),
                Value<String?> linkedDebtId = const Value.absent(),
                Value<String?> rawOcrText = const Value.absent(),
                required String parseStatus,
                required String parseVersion,
                Value<bool> deleted = const Value.absent(),
                Value<DateTime?> retentionExpiresAt = const Value.absent(),
                Value<DateTime?> rawOcrExpiresAt = const Value.absent(),
                Value<DateTime?> processedAt = const Value.absent(),
                Value<DateTime?> linkedAt = const Value.absent(),
                Value<DateTime?> pendingDeletionAt = const Value.absent(),
                Value<DateTime?> purgedAt = const Value.absent(),
                Value<DateTime?> encryptedAt = const Value.absent(),
                Value<bool> hasRawOcrText = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ImportedDocumentsTableCompanion.insert(
                id: id,
                localPath: localPath,
                storageRef: storageRef,
                sourceType: sourceType,
                mimeType: mimeType,
                createdAt: createdAt,
                lifecycleState: lifecycleState,
                linkedDebtId: linkedDebtId,
                rawOcrText: rawOcrText,
                parseStatus: parseStatus,
                parseVersion: parseVersion,
                deleted: deleted,
                retentionExpiresAt: retentionExpiresAt,
                rawOcrExpiresAt: rawOcrExpiresAt,
                processedAt: processedAt,
                linkedAt: linkedAt,
                pendingDeletionAt: pendingDeletionAt,
                purgedAt: purgedAt,
                encryptedAt: encryptedAt,
                hasRawOcrText: hasRawOcrText,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ImportedDocumentsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({parsedExtractionsTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (parsedExtractionsTableRefs) db.parsedExtractionsTable,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (parsedExtractionsTableRefs)
                    await $_getPrefetchedData<
                      ImportedDocumentsTableData,
                      $ImportedDocumentsTableTable,
                      ParsedExtractionsTableData
                    >(
                      currentTable: table,
                      referencedTable: $$ImportedDocumentsTableTableReferences
                          ._parsedExtractionsTableRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ImportedDocumentsTableTableReferences(
                            db,
                            table,
                            p0,
                          ).parsedExtractionsTableRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.documentId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ImportedDocumentsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ImportedDocumentsTableTable,
      ImportedDocumentsTableData,
      $$ImportedDocumentsTableTableFilterComposer,
      $$ImportedDocumentsTableTableOrderingComposer,
      $$ImportedDocumentsTableTableAnnotationComposer,
      $$ImportedDocumentsTableTableCreateCompanionBuilder,
      $$ImportedDocumentsTableTableUpdateCompanionBuilder,
      (ImportedDocumentsTableData, $$ImportedDocumentsTableTableReferences),
      ImportedDocumentsTableData,
      PrefetchHooks Function({bool parsedExtractionsTableRefs})
    >;
typedef $$ParsedExtractionsTableTableCreateCompanionBuilder =
    ParsedExtractionsTableCompanion Function({
      required String id,
      required String documentId,
      required String classification,
      required double confidence,
      required String payloadJson,
      Value<String> ambiguityNotes,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$ParsedExtractionsTableTableUpdateCompanionBuilder =
    ParsedExtractionsTableCompanion Function({
      Value<String> id,
      Value<String> documentId,
      Value<String> classification,
      Value<double> confidence,
      Value<String> payloadJson,
      Value<String> ambiguityNotes,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$ParsedExtractionsTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ParsedExtractionsTableTable,
          ParsedExtractionsTableData
        > {
  $$ParsedExtractionsTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ImportedDocumentsTableTable _documentIdTable(_$AppDatabase db) =>
      db.importedDocumentsTable.createAlias(
        $_aliasNameGenerator(
          db.parsedExtractionsTable.documentId,
          db.importedDocumentsTable.id,
        ),
      );

  $$ImportedDocumentsTableTableProcessedTableManager get documentId {
    final $_column = $_itemColumn<String>('document_id')!;

    final manager = $$ImportedDocumentsTableTableTableManager(
      $_db,
      $_db.importedDocumentsTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_documentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ParsedExtractionsTableTableFilterComposer
    extends Composer<_$AppDatabase, $ParsedExtractionsTableTable> {
  $$ParsedExtractionsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get classification => $composableBuilder(
    column: $table.classification,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ambiguityNotes => $composableBuilder(
    column: $table.ambiguityNotes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ImportedDocumentsTableTableFilterComposer get documentId {
    final $$ImportedDocumentsTableTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.documentId,
          referencedTable: $db.importedDocumentsTable,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ImportedDocumentsTableTableFilterComposer(
                $db: $db,
                $table: $db.importedDocumentsTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$ParsedExtractionsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ParsedExtractionsTableTable> {
  $$ParsedExtractionsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get classification => $composableBuilder(
    column: $table.classification,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ambiguityNotes => $composableBuilder(
    column: $table.ambiguityNotes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ImportedDocumentsTableTableOrderingComposer get documentId {
    final $$ImportedDocumentsTableTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.documentId,
          referencedTable: $db.importedDocumentsTable,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ImportedDocumentsTableTableOrderingComposer(
                $db: $db,
                $table: $db.importedDocumentsTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$ParsedExtractionsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ParsedExtractionsTableTable> {
  $$ParsedExtractionsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get classification => $composableBuilder(
    column: $table.classification,
    builder: (column) => column,
  );

  GeneratedColumn<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ambiguityNotes => $composableBuilder(
    column: $table.ambiguityNotes,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ImportedDocumentsTableTableAnnotationComposer get documentId {
    final $$ImportedDocumentsTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.documentId,
          referencedTable: $db.importedDocumentsTable,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ImportedDocumentsTableTableAnnotationComposer(
                $db: $db,
                $table: $db.importedDocumentsTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$ParsedExtractionsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ParsedExtractionsTableTable,
          ParsedExtractionsTableData,
          $$ParsedExtractionsTableTableFilterComposer,
          $$ParsedExtractionsTableTableOrderingComposer,
          $$ParsedExtractionsTableTableAnnotationComposer,
          $$ParsedExtractionsTableTableCreateCompanionBuilder,
          $$ParsedExtractionsTableTableUpdateCompanionBuilder,
          (ParsedExtractionsTableData, $$ParsedExtractionsTableTableReferences),
          ParsedExtractionsTableData,
          PrefetchHooks Function({bool documentId})
        > {
  $$ParsedExtractionsTableTableTableManager(
    _$AppDatabase db,
    $ParsedExtractionsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ParsedExtractionsTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ParsedExtractionsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ParsedExtractionsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> documentId = const Value.absent(),
                Value<String> classification = const Value.absent(),
                Value<double> confidence = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<String> ambiguityNotes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ParsedExtractionsTableCompanion(
                id: id,
                documentId: documentId,
                classification: classification,
                confidence: confidence,
                payloadJson: payloadJson,
                ambiguityNotes: ambiguityNotes,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String documentId,
                required String classification,
                required double confidence,
                required String payloadJson,
                Value<String> ambiguityNotes = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => ParsedExtractionsTableCompanion.insert(
                id: id,
                documentId: documentId,
                classification: classification,
                confidence: confidence,
                payloadJson: payloadJson,
                ambiguityNotes: ambiguityNotes,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ParsedExtractionsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({documentId = false}) {
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
                    if (documentId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.documentId,
                                referencedTable:
                                    $$ParsedExtractionsTableTableReferences
                                        ._documentIdTable(db),
                                referencedColumn:
                                    $$ParsedExtractionsTableTableReferences
                                        ._documentIdTable(db)
                                        .id,
                              )
                              as T;
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

typedef $$ParsedExtractionsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ParsedExtractionsTableTable,
      ParsedExtractionsTableData,
      $$ParsedExtractionsTableTableFilterComposer,
      $$ParsedExtractionsTableTableOrderingComposer,
      $$ParsedExtractionsTableTableAnnotationComposer,
      $$ParsedExtractionsTableTableCreateCompanionBuilder,
      $$ParsedExtractionsTableTableUpdateCompanionBuilder,
      (ParsedExtractionsTableData, $$ParsedExtractionsTableTableReferences),
      ParsedExtractionsTableData,
      PrefetchHooks Function({bool documentId})
    >;
typedef $$ReminderRulesTableTableCreateCompanionBuilder =
    ReminderRulesTableCompanion Function({
      required String id,
      required String debtId,
      Value<int> daysBefore,
      Value<bool> enabled,
      Value<int> rowid,
    });
typedef $$ReminderRulesTableTableUpdateCompanionBuilder =
    ReminderRulesTableCompanion Function({
      Value<String> id,
      Value<String> debtId,
      Value<int> daysBefore,
      Value<bool> enabled,
      Value<int> rowid,
    });

final class $$ReminderRulesTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ReminderRulesTableTable,
          ReminderRulesTableData
        > {
  $$ReminderRulesTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $DebtsTableTable _debtIdTable(_$AppDatabase db) =>
      db.debtsTable.createAlias(
        $_aliasNameGenerator(db.reminderRulesTable.debtId, db.debtsTable.id),
      );

  $$DebtsTableTableProcessedTableManager get debtId {
    final $_column = $_itemColumn<String>('debt_id')!;

    final manager = $$DebtsTableTableTableManager(
      $_db,
      $_db.debtsTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_debtIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ReminderRulesTableTableFilterComposer
    extends Composer<_$AppDatabase, $ReminderRulesTableTable> {
  $$ReminderRulesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get daysBefore => $composableBuilder(
    column: $table.daysBefore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );

  $$DebtsTableTableFilterComposer get debtId {
    final $$DebtsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.debtId,
      referencedTable: $db.debtsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DebtsTableTableFilterComposer(
            $db: $db,
            $table: $db.debtsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReminderRulesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ReminderRulesTableTable> {
  $$ReminderRulesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get daysBefore => $composableBuilder(
    column: $table.daysBefore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );

  $$DebtsTableTableOrderingComposer get debtId {
    final $$DebtsTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.debtId,
      referencedTable: $db.debtsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DebtsTableTableOrderingComposer(
            $db: $db,
            $table: $db.debtsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReminderRulesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReminderRulesTableTable> {
  $$ReminderRulesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get daysBefore => $composableBuilder(
    column: $table.daysBefore,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  $$DebtsTableTableAnnotationComposer get debtId {
    final $$DebtsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.debtId,
      referencedTable: $db.debtsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DebtsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.debtsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReminderRulesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReminderRulesTableTable,
          ReminderRulesTableData,
          $$ReminderRulesTableTableFilterComposer,
          $$ReminderRulesTableTableOrderingComposer,
          $$ReminderRulesTableTableAnnotationComposer,
          $$ReminderRulesTableTableCreateCompanionBuilder,
          $$ReminderRulesTableTableUpdateCompanionBuilder,
          (ReminderRulesTableData, $$ReminderRulesTableTableReferences),
          ReminderRulesTableData,
          PrefetchHooks Function({bool debtId})
        > {
  $$ReminderRulesTableTableTableManager(
    _$AppDatabase db,
    $ReminderRulesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReminderRulesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReminderRulesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReminderRulesTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> debtId = const Value.absent(),
                Value<int> daysBefore = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReminderRulesTableCompanion(
                id: id,
                debtId: debtId,
                daysBefore: daysBefore,
                enabled: enabled,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String debtId,
                Value<int> daysBefore = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReminderRulesTableCompanion.insert(
                id: id,
                debtId: debtId,
                daysBefore: daysBefore,
                enabled: enabled,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ReminderRulesTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({debtId = false}) {
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
                    if (debtId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.debtId,
                                referencedTable:
                                    $$ReminderRulesTableTableReferences
                                        ._debtIdTable(db),
                                referencedColumn:
                                    $$ReminderRulesTableTableReferences
                                        ._debtIdTable(db)
                                        .id,
                              )
                              as T;
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

typedef $$ReminderRulesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReminderRulesTableTable,
      ReminderRulesTableData,
      $$ReminderRulesTableTableFilterComposer,
      $$ReminderRulesTableTableOrderingComposer,
      $$ReminderRulesTableTableAnnotationComposer,
      $$ReminderRulesTableTableCreateCompanionBuilder,
      $$ReminderRulesTableTableUpdateCompanionBuilder,
      (ReminderRulesTableData, $$ReminderRulesTableTableReferences),
      ReminderRulesTableData,
      PrefetchHooks Function({bool debtId})
    >;
typedef $$ScenariosTableTableCreateCompanionBuilder =
    ScenariosTableCompanion Function({
      required String id,
      required String strategyType,
      required double extraPayment,
      required double budget,
      required DateTime createdAt,
      required String label,
      required double baselineInterest,
      required double optimizedInterest,
      required int monthsToPayoff,
      Value<int> rowid,
    });
typedef $$ScenariosTableTableUpdateCompanionBuilder =
    ScenariosTableCompanion Function({
      Value<String> id,
      Value<String> strategyType,
      Value<double> extraPayment,
      Value<double> budget,
      Value<DateTime> createdAt,
      Value<String> label,
      Value<double> baselineInterest,
      Value<double> optimizedInterest,
      Value<int> monthsToPayoff,
      Value<int> rowid,
    });

class $$ScenariosTableTableFilterComposer
    extends Composer<_$AppDatabase, $ScenariosTableTable> {
  $$ScenariosTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get strategyType => $composableBuilder(
    column: $table.strategyType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get extraPayment => $composableBuilder(
    column: $table.extraPayment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get budget => $composableBuilder(
    column: $table.budget,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get baselineInterest => $composableBuilder(
    column: $table.baselineInterest,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get optimizedInterest => $composableBuilder(
    column: $table.optimizedInterest,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get monthsToPayoff => $composableBuilder(
    column: $table.monthsToPayoff,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ScenariosTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ScenariosTableTable> {
  $$ScenariosTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get strategyType => $composableBuilder(
    column: $table.strategyType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get extraPayment => $composableBuilder(
    column: $table.extraPayment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get budget => $composableBuilder(
    column: $table.budget,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get baselineInterest => $composableBuilder(
    column: $table.baselineInterest,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get optimizedInterest => $composableBuilder(
    column: $table.optimizedInterest,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get monthsToPayoff => $composableBuilder(
    column: $table.monthsToPayoff,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ScenariosTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScenariosTableTable> {
  $$ScenariosTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get strategyType => $composableBuilder(
    column: $table.strategyType,
    builder: (column) => column,
  );

  GeneratedColumn<double> get extraPayment => $composableBuilder(
    column: $table.extraPayment,
    builder: (column) => column,
  );

  GeneratedColumn<double> get budget =>
      $composableBuilder(column: $table.budget, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<double> get baselineInterest => $composableBuilder(
    column: $table.baselineInterest,
    builder: (column) => column,
  );

  GeneratedColumn<double> get optimizedInterest => $composableBuilder(
    column: $table.optimizedInterest,
    builder: (column) => column,
  );

  GeneratedColumn<int> get monthsToPayoff => $composableBuilder(
    column: $table.monthsToPayoff,
    builder: (column) => column,
  );
}

class $$ScenariosTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ScenariosTableTable,
          ScenariosTableData,
          $$ScenariosTableTableFilterComposer,
          $$ScenariosTableTableOrderingComposer,
          $$ScenariosTableTableAnnotationComposer,
          $$ScenariosTableTableCreateCompanionBuilder,
          $$ScenariosTableTableUpdateCompanionBuilder,
          (
            ScenariosTableData,
            BaseReferences<
              _$AppDatabase,
              $ScenariosTableTable,
              ScenariosTableData
            >,
          ),
          ScenariosTableData,
          PrefetchHooks Function()
        > {
  $$ScenariosTableTableTableManager(
    _$AppDatabase db,
    $ScenariosTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScenariosTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScenariosTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScenariosTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> strategyType = const Value.absent(),
                Value<double> extraPayment = const Value.absent(),
                Value<double> budget = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<double> baselineInterest = const Value.absent(),
                Value<double> optimizedInterest = const Value.absent(),
                Value<int> monthsToPayoff = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScenariosTableCompanion(
                id: id,
                strategyType: strategyType,
                extraPayment: extraPayment,
                budget: budget,
                createdAt: createdAt,
                label: label,
                baselineInterest: baselineInterest,
                optimizedInterest: optimizedInterest,
                monthsToPayoff: monthsToPayoff,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String strategyType,
                required double extraPayment,
                required double budget,
                required DateTime createdAt,
                required String label,
                required double baselineInterest,
                required double optimizedInterest,
                required int monthsToPayoff,
                Value<int> rowid = const Value.absent(),
              }) => ScenariosTableCompanion.insert(
                id: id,
                strategyType: strategyType,
                extraPayment: extraPayment,
                budget: budget,
                createdAt: createdAt,
                label: label,
                baselineInterest: baselineInterest,
                optimizedInterest: optimizedInterest,
                monthsToPayoff: monthsToPayoff,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ScenariosTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ScenariosTableTable,
      ScenariosTableData,
      $$ScenariosTableTableFilterComposer,
      $$ScenariosTableTableOrderingComposer,
      $$ScenariosTableTableAnnotationComposer,
      $$ScenariosTableTableCreateCompanionBuilder,
      $$ScenariosTableTableUpdateCompanionBuilder,
      (
        ScenariosTableData,
        BaseReferences<_$AppDatabase, $ScenariosTableTable, ScenariosTableData>,
      ),
      ScenariosTableData,
      PrefetchHooks Function()
    >;
typedef $$AppPreferencesTableTableCreateCompanionBuilder =
    AppPreferencesTableCompanion Function({
      Value<int> key,
      Value<String> themeMode,
      Value<String> currencyCode,
      Value<String> localeCode,
      Value<String> defaultStrategy,
      Value<bool> hideBalances,
      Value<bool> appLockEnabled,
      Value<bool> aiConsentEnabled,
      Value<bool> notificationsEnabled,
      Value<bool> onboardingCompleted,
      Value<bool> weeklySummaryEnabled,
      Value<bool> rawOcrRetentionEnabled,
      Value<int> rawOcrRetentionHours,
      Value<String> documentRetentionMode,
      Value<int> purgeFailedImportsAfterHours,
      Value<bool> dataProtectionExplainerSeen,
    });
typedef $$AppPreferencesTableTableUpdateCompanionBuilder =
    AppPreferencesTableCompanion Function({
      Value<int> key,
      Value<String> themeMode,
      Value<String> currencyCode,
      Value<String> localeCode,
      Value<String> defaultStrategy,
      Value<bool> hideBalances,
      Value<bool> appLockEnabled,
      Value<bool> aiConsentEnabled,
      Value<bool> notificationsEnabled,
      Value<bool> onboardingCompleted,
      Value<bool> weeklySummaryEnabled,
      Value<bool> rawOcrRetentionEnabled,
      Value<int> rawOcrRetentionHours,
      Value<String> documentRetentionMode,
      Value<int> purgeFailedImportsAfterHours,
      Value<bool> dataProtectionExplainerSeen,
    });

class $$AppPreferencesTableTableFilterComposer
    extends Composer<_$AppDatabase, $AppPreferencesTableTable> {
  $$AppPreferencesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get themeMode => $composableBuilder(
    column: $table.themeMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localeCode => $composableBuilder(
    column: $table.localeCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get defaultStrategy => $composableBuilder(
    column: $table.defaultStrategy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hideBalances => $composableBuilder(
    column: $table.hideBalances,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get appLockEnabled => $composableBuilder(
    column: $table.appLockEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get aiConsentEnabled => $composableBuilder(
    column: $table.aiConsentEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get notificationsEnabled => $composableBuilder(
    column: $table.notificationsEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get onboardingCompleted => $composableBuilder(
    column: $table.onboardingCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get weeklySummaryEnabled => $composableBuilder(
    column: $table.weeklySummaryEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get rawOcrRetentionEnabled => $composableBuilder(
    column: $table.rawOcrRetentionEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rawOcrRetentionHours => $composableBuilder(
    column: $table.rawOcrRetentionHours,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get documentRetentionMode => $composableBuilder(
    column: $table.documentRetentionMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get purgeFailedImportsAfterHours => $composableBuilder(
    column: $table.purgeFailedImportsAfterHours,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get dataProtectionExplainerSeen => $composableBuilder(
    column: $table.dataProtectionExplainerSeen,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppPreferencesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $AppPreferencesTableTable> {
  $$AppPreferencesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get themeMode => $composableBuilder(
    column: $table.themeMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localeCode => $composableBuilder(
    column: $table.localeCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get defaultStrategy => $composableBuilder(
    column: $table.defaultStrategy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hideBalances => $composableBuilder(
    column: $table.hideBalances,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get appLockEnabled => $composableBuilder(
    column: $table.appLockEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get aiConsentEnabled => $composableBuilder(
    column: $table.aiConsentEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get notificationsEnabled => $composableBuilder(
    column: $table.notificationsEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get onboardingCompleted => $composableBuilder(
    column: $table.onboardingCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get weeklySummaryEnabled => $composableBuilder(
    column: $table.weeklySummaryEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get rawOcrRetentionEnabled => $composableBuilder(
    column: $table.rawOcrRetentionEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rawOcrRetentionHours => $composableBuilder(
    column: $table.rawOcrRetentionHours,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get documentRetentionMode => $composableBuilder(
    column: $table.documentRetentionMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get purgeFailedImportsAfterHours => $composableBuilder(
    column: $table.purgeFailedImportsAfterHours,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get dataProtectionExplainerSeen => $composableBuilder(
    column: $table.dataProtectionExplainerSeen,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppPreferencesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppPreferencesTableTable> {
  $$AppPreferencesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get themeMode =>
      $composableBuilder(column: $table.themeMode, builder: (column) => column);

  GeneratedColumn<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get localeCode => $composableBuilder(
    column: $table.localeCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get defaultStrategy => $composableBuilder(
    column: $table.defaultStrategy,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get hideBalances => $composableBuilder(
    column: $table.hideBalances,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get appLockEnabled => $composableBuilder(
    column: $table.appLockEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get aiConsentEnabled => $composableBuilder(
    column: $table.aiConsentEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get notificationsEnabled => $composableBuilder(
    column: $table.notificationsEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get onboardingCompleted => $composableBuilder(
    column: $table.onboardingCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get weeklySummaryEnabled => $composableBuilder(
    column: $table.weeklySummaryEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get rawOcrRetentionEnabled => $composableBuilder(
    column: $table.rawOcrRetentionEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<int> get rawOcrRetentionHours => $composableBuilder(
    column: $table.rawOcrRetentionHours,
    builder: (column) => column,
  );

  GeneratedColumn<String> get documentRetentionMode => $composableBuilder(
    column: $table.documentRetentionMode,
    builder: (column) => column,
  );

  GeneratedColumn<int> get purgeFailedImportsAfterHours => $composableBuilder(
    column: $table.purgeFailedImportsAfterHours,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get dataProtectionExplainerSeen => $composableBuilder(
    column: $table.dataProtectionExplainerSeen,
    builder: (column) => column,
  );
}

class $$AppPreferencesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppPreferencesTableTable,
          AppPreferencesTableData,
          $$AppPreferencesTableTableFilterComposer,
          $$AppPreferencesTableTableOrderingComposer,
          $$AppPreferencesTableTableAnnotationComposer,
          $$AppPreferencesTableTableCreateCompanionBuilder,
          $$AppPreferencesTableTableUpdateCompanionBuilder,
          (
            AppPreferencesTableData,
            BaseReferences<
              _$AppDatabase,
              $AppPreferencesTableTable,
              AppPreferencesTableData
            >,
          ),
          AppPreferencesTableData,
          PrefetchHooks Function()
        > {
  $$AppPreferencesTableTableTableManager(
    _$AppDatabase db,
    $AppPreferencesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppPreferencesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppPreferencesTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$AppPreferencesTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> key = const Value.absent(),
                Value<String> themeMode = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<String> localeCode = const Value.absent(),
                Value<String> defaultStrategy = const Value.absent(),
                Value<bool> hideBalances = const Value.absent(),
                Value<bool> appLockEnabled = const Value.absent(),
                Value<bool> aiConsentEnabled = const Value.absent(),
                Value<bool> notificationsEnabled = const Value.absent(),
                Value<bool> onboardingCompleted = const Value.absent(),
                Value<bool> weeklySummaryEnabled = const Value.absent(),
                Value<bool> rawOcrRetentionEnabled = const Value.absent(),
                Value<int> rawOcrRetentionHours = const Value.absent(),
                Value<String> documentRetentionMode = const Value.absent(),
                Value<int> purgeFailedImportsAfterHours = const Value.absent(),
                Value<bool> dataProtectionExplainerSeen = const Value.absent(),
              }) => AppPreferencesTableCompanion(
                key: key,
                themeMode: themeMode,
                currencyCode: currencyCode,
                localeCode: localeCode,
                defaultStrategy: defaultStrategy,
                hideBalances: hideBalances,
                appLockEnabled: appLockEnabled,
                aiConsentEnabled: aiConsentEnabled,
                notificationsEnabled: notificationsEnabled,
                onboardingCompleted: onboardingCompleted,
                weeklySummaryEnabled: weeklySummaryEnabled,
                rawOcrRetentionEnabled: rawOcrRetentionEnabled,
                rawOcrRetentionHours: rawOcrRetentionHours,
                documentRetentionMode: documentRetentionMode,
                purgeFailedImportsAfterHours: purgeFailedImportsAfterHours,
                dataProtectionExplainerSeen: dataProtectionExplainerSeen,
              ),
          createCompanionCallback:
              ({
                Value<int> key = const Value.absent(),
                Value<String> themeMode = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<String> localeCode = const Value.absent(),
                Value<String> defaultStrategy = const Value.absent(),
                Value<bool> hideBalances = const Value.absent(),
                Value<bool> appLockEnabled = const Value.absent(),
                Value<bool> aiConsentEnabled = const Value.absent(),
                Value<bool> notificationsEnabled = const Value.absent(),
                Value<bool> onboardingCompleted = const Value.absent(),
                Value<bool> weeklySummaryEnabled = const Value.absent(),
                Value<bool> rawOcrRetentionEnabled = const Value.absent(),
                Value<int> rawOcrRetentionHours = const Value.absent(),
                Value<String> documentRetentionMode = const Value.absent(),
                Value<int> purgeFailedImportsAfterHours = const Value.absent(),
                Value<bool> dataProtectionExplainerSeen = const Value.absent(),
              }) => AppPreferencesTableCompanion.insert(
                key: key,
                themeMode: themeMode,
                currencyCode: currencyCode,
                localeCode: localeCode,
                defaultStrategy: defaultStrategy,
                hideBalances: hideBalances,
                appLockEnabled: appLockEnabled,
                aiConsentEnabled: aiConsentEnabled,
                notificationsEnabled: notificationsEnabled,
                onboardingCompleted: onboardingCompleted,
                weeklySummaryEnabled: weeklySummaryEnabled,
                rawOcrRetentionEnabled: rawOcrRetentionEnabled,
                rawOcrRetentionHours: rawOcrRetentionHours,
                documentRetentionMode: documentRetentionMode,
                purgeFailedImportsAfterHours: purgeFailedImportsAfterHours,
                dataProtectionExplainerSeen: dataProtectionExplainerSeen,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppPreferencesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppPreferencesTableTable,
      AppPreferencesTableData,
      $$AppPreferencesTableTableFilterComposer,
      $$AppPreferencesTableTableOrderingComposer,
      $$AppPreferencesTableTableAnnotationComposer,
      $$AppPreferencesTableTableCreateCompanionBuilder,
      $$AppPreferencesTableTableUpdateCompanionBuilder,
      (
        AppPreferencesTableData,
        BaseReferences<
          _$AppDatabase,
          $AppPreferencesTableTable,
          AppPreferencesTableData
        >,
      ),
      AppPreferencesTableData,
      PrefetchHooks Function()
    >;
typedef $$SubscriptionStateTableTableCreateCompanionBuilder =
    SubscriptionStateTableCompanion Function({
      Value<int> key,
      Value<bool> isPremium,
      Value<DateTime?> expiresAt,
      Value<String?> productId,
      Value<String?> planId,
      Value<String?> billingProvider,
      Value<String> status,
      Value<DateTime?> lastVerifiedAt,
      Value<String> unlockedFeaturesJson,
    });
typedef $$SubscriptionStateTableTableUpdateCompanionBuilder =
    SubscriptionStateTableCompanion Function({
      Value<int> key,
      Value<bool> isPremium,
      Value<DateTime?> expiresAt,
      Value<String?> productId,
      Value<String?> planId,
      Value<String?> billingProvider,
      Value<String> status,
      Value<DateTime?> lastVerifiedAt,
      Value<String> unlockedFeaturesJson,
    });

class $$SubscriptionStateTableTableFilterComposer
    extends Composer<_$AppDatabase, $SubscriptionStateTableTable> {
  $$SubscriptionStateTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPremium => $composableBuilder(
    column: $table.isPremium,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get planId => $composableBuilder(
    column: $table.planId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get billingProvider => $composableBuilder(
    column: $table.billingProvider,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastVerifiedAt => $composableBuilder(
    column: $table.lastVerifiedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unlockedFeaturesJson => $composableBuilder(
    column: $table.unlockedFeaturesJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SubscriptionStateTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SubscriptionStateTableTable> {
  $$SubscriptionStateTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPremium => $composableBuilder(
    column: $table.isPremium,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get planId => $composableBuilder(
    column: $table.planId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get billingProvider => $composableBuilder(
    column: $table.billingProvider,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastVerifiedAt => $composableBuilder(
    column: $table.lastVerifiedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unlockedFeaturesJson => $composableBuilder(
    column: $table.unlockedFeaturesJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SubscriptionStateTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SubscriptionStateTableTable> {
  $$SubscriptionStateTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<bool> get isPremium =>
      $composableBuilder(column: $table.isPremium, builder: (column) => column);

  GeneratedColumn<DateTime> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);

  GeneratedColumn<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<String> get planId =>
      $composableBuilder(column: $table.planId, builder: (column) => column);

  GeneratedColumn<String> get billingProvider => $composableBuilder(
    column: $table.billingProvider,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get lastVerifiedAt => $composableBuilder(
    column: $table.lastVerifiedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get unlockedFeaturesJson => $composableBuilder(
    column: $table.unlockedFeaturesJson,
    builder: (column) => column,
  );
}

class $$SubscriptionStateTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SubscriptionStateTableTable,
          SubscriptionStateTableData,
          $$SubscriptionStateTableTableFilterComposer,
          $$SubscriptionStateTableTableOrderingComposer,
          $$SubscriptionStateTableTableAnnotationComposer,
          $$SubscriptionStateTableTableCreateCompanionBuilder,
          $$SubscriptionStateTableTableUpdateCompanionBuilder,
          (
            SubscriptionStateTableData,
            BaseReferences<
              _$AppDatabase,
              $SubscriptionStateTableTable,
              SubscriptionStateTableData
            >,
          ),
          SubscriptionStateTableData,
          PrefetchHooks Function()
        > {
  $$SubscriptionStateTableTableTableManager(
    _$AppDatabase db,
    $SubscriptionStateTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SubscriptionStateTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$SubscriptionStateTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$SubscriptionStateTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> key = const Value.absent(),
                Value<bool> isPremium = const Value.absent(),
                Value<DateTime?> expiresAt = const Value.absent(),
                Value<String?> productId = const Value.absent(),
                Value<String?> planId = const Value.absent(),
                Value<String?> billingProvider = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime?> lastVerifiedAt = const Value.absent(),
                Value<String> unlockedFeaturesJson = const Value.absent(),
              }) => SubscriptionStateTableCompanion(
                key: key,
                isPremium: isPremium,
                expiresAt: expiresAt,
                productId: productId,
                planId: planId,
                billingProvider: billingProvider,
                status: status,
                lastVerifiedAt: lastVerifiedAt,
                unlockedFeaturesJson: unlockedFeaturesJson,
              ),
          createCompanionCallback:
              ({
                Value<int> key = const Value.absent(),
                Value<bool> isPremium = const Value.absent(),
                Value<DateTime?> expiresAt = const Value.absent(),
                Value<String?> productId = const Value.absent(),
                Value<String?> planId = const Value.absent(),
                Value<String?> billingProvider = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime?> lastVerifiedAt = const Value.absent(),
                Value<String> unlockedFeaturesJson = const Value.absent(),
              }) => SubscriptionStateTableCompanion.insert(
                key: key,
                isPremium: isPremium,
                expiresAt: expiresAt,
                productId: productId,
                planId: planId,
                billingProvider: billingProvider,
                status: status,
                lastVerifiedAt: lastVerifiedAt,
                unlockedFeaturesJson: unlockedFeaturesJson,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SubscriptionStateTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SubscriptionStateTableTable,
      SubscriptionStateTableData,
      $$SubscriptionStateTableTableFilterComposer,
      $$SubscriptionStateTableTableOrderingComposer,
      $$SubscriptionStateTableTableAnnotationComposer,
      $$SubscriptionStateTableTableCreateCompanionBuilder,
      $$SubscriptionStateTableTableUpdateCompanionBuilder,
      (
        SubscriptionStateTableData,
        BaseReferences<
          _$AppDatabase,
          $SubscriptionStateTableTable,
          SubscriptionStateTableData
        >,
      ),
      SubscriptionStateTableData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$DebtsTableTableTableManager get debtsTable =>
      $$DebtsTableTableTableManager(_db, _db.debtsTable);
  $$PaymentsTableTableTableManager get paymentsTable =>
      $$PaymentsTableTableTableManager(_db, _db.paymentsTable);
  $$ImportedDocumentsTableTableTableManager get importedDocumentsTable =>
      $$ImportedDocumentsTableTableTableManager(
        _db,
        _db.importedDocumentsTable,
      );
  $$ParsedExtractionsTableTableTableManager get parsedExtractionsTable =>
      $$ParsedExtractionsTableTableTableManager(
        _db,
        _db.parsedExtractionsTable,
      );
  $$ReminderRulesTableTableTableManager get reminderRulesTable =>
      $$ReminderRulesTableTableTableManager(_db, _db.reminderRulesTable);
  $$ScenariosTableTableTableManager get scenariosTable =>
      $$ScenariosTableTableTableManager(_db, _db.scenariosTable);
  $$AppPreferencesTableTableTableManager get appPreferencesTable =>
      $$AppPreferencesTableTableTableManager(_db, _db.appPreferencesTable);
  $$SubscriptionStateTableTableTableManager get subscriptionStateTable =>
      $$SubscriptionStateTableTableTableManager(
        _db,
        _db.subscriptionStateTable,
      );
}
