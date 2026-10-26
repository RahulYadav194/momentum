// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $TasksTable extends Tasks with TableInfo<$TasksTable, Task> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasksTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<TaskStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(TaskStatus.pending.name),
      ).withConverter<TaskStatus>($TasksTable.$converterstatus);
  @override
  late final GeneratedColumnWithTypeConverter<TaskPriority, String> priority =
      GeneratedColumn<String>(
        'priority',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(TaskPriority.medium.name),
      ).withConverter<TaskPriority>($TasksTable.$converterpriority);
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
  static const VerificationMeta _plannedDateMeta = const VerificationMeta(
    'plannedDate',
  );
  @override
  late final GeneratedColumn<DateTime> plannedDate = GeneratedColumn<DateTime>(
    'planned_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
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
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    description,
    status,
    priority,
    dueDate,
    plannedDate,
    deletedAt,
    createdAt,
    updatedAt,
    completedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Task> instance, {
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
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    }
    if (data.containsKey('planned_date')) {
      context.handle(
        _plannedDateMeta,
        plannedDate.isAcceptableOrUnknown(
          data['planned_date']!,
          _plannedDateMeta,
        ),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
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
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Task map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Task(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      status: $TasksTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      priority: $TasksTable.$converterpriority.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}priority'],
        )!,
      ),
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_date'],
      ),
      plannedDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}planned_date'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
    );
  }

  @override
  $TasksTable createAlias(String alias) {
    return $TasksTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TaskStatus, String, String> $converterstatus =
      const EnumNameConverter<TaskStatus>(TaskStatus.values);
  static JsonTypeConverter2<TaskPriority, String, String> $converterpriority =
      const EnumNameConverter<TaskPriority>(TaskPriority.values);
}

class Task extends DataClass implements Insertable<Task> {
  /// Locally generated stable identifier (UUID v4).
  final String id;

  /// Required, non-empty task title.
  final String title;

  /// Optional free-form description.
  final String? description;

  /// Lifecycle state of the task.
  final TaskStatus status;

  /// Relative importance of the task.
  final TaskPriority priority;

  /// Optional local deadline for the task.
  final DateTime? dueDate;

  /// Optional date on which the user intends to work on the task.
  final DateTime? plannedDate;

  /// When the task was soft-deleted, if ever.
  final DateTime? deletedAt;

  /// When the task was first created.
  final DateTime createdAt;

  /// When the task was last modified.
  final DateTime updatedAt;

  /// When the task was marked as completed, if ever.
  final DateTime? completedAt;
  const Task({
    required this.id,
    required this.title,
    this.description,
    required this.status,
    required this.priority,
    this.dueDate,
    this.plannedDate,
    this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    {
      map['status'] = Variable<String>(
        $TasksTable.$converterstatus.toSql(status),
      );
    }
    {
      map['priority'] = Variable<String>(
        $TasksTable.$converterpriority.toSql(priority),
      );
    }
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    if (!nullToAbsent || plannedDate != null) {
      map['planned_date'] = Variable<DateTime>(plannedDate);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    return map;
  }

  TasksCompanion toCompanion(bool nullToAbsent) {
    return TasksCompanion(
      id: Value(id),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      status: Value(status),
      priority: Value(priority),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      plannedDate: plannedDate == null && nullToAbsent
          ? const Value.absent()
          : Value(plannedDate),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
    );
  }

  factory Task.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Task(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      status: $TasksTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      priority: $TasksTable.$converterpriority.fromJson(
        serializer.fromJson<String>(json['priority']),
      ),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      plannedDate: serializer.fromJson<DateTime?>(json['plannedDate']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'status': serializer.toJson<String>(
        $TasksTable.$converterstatus.toJson(status),
      ),
      'priority': serializer.toJson<String>(
        $TasksTable.$converterpriority.toJson(priority),
      ),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'plannedDate': serializer.toJson<DateTime?>(plannedDate),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
    };
  }

  Task copyWith({
    String? id,
    String? title,
    Value<String?> description = const Value.absent(),
    TaskStatus? status,
    TaskPriority? priority,
    Value<DateTime?> dueDate = const Value.absent(),
    Value<DateTime?> plannedDate = const Value.absent(),
    Value<DateTime?> deletedAt = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> completedAt = const Value.absent(),
  }) => Task(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    status: status ?? this.status,
    priority: priority ?? this.priority,
    dueDate: dueDate.present ? dueDate.value : this.dueDate,
    plannedDate: plannedDate.present ? plannedDate.value : this.plannedDate,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
  );
  Task copyWithCompanion(TasksCompanion data) {
    return Task(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      status: data.status.present ? data.status.value : this.status,
      priority: data.priority.present ? data.priority.value : this.priority,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      plannedDate: data.plannedDate.present
          ? data.plannedDate.value
          : this.plannedDate,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Task(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('status: $status, ')
          ..write('priority: $priority, ')
          ..write('dueDate: $dueDate, ')
          ..write('plannedDate: $plannedDate, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    description,
    status,
    priority,
    dueDate,
    plannedDate,
    deletedAt,
    createdAt,
    updatedAt,
    completedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Task &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.status == this.status &&
          other.priority == this.priority &&
          other.dueDate == this.dueDate &&
          other.plannedDate == this.plannedDate &&
          other.deletedAt == this.deletedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.completedAt == this.completedAt);
}

class TasksCompanion extends UpdateCompanion<Task> {
  final Value<String> id;
  final Value<String> title;
  final Value<String?> description;
  final Value<TaskStatus> status;
  final Value<TaskPriority> priority;
  final Value<DateTime?> dueDate;
  final Value<DateTime?> plannedDate;
  final Value<DateTime?> deletedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> completedAt;
  final Value<int> rowid;
  const TasksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.status = const Value.absent(),
    this.priority = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.plannedDate = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TasksCompanion.insert({
    required String id,
    required String title,
    this.description = const Value.absent(),
    this.status = const Value.absent(),
    this.priority = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.plannedDate = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Task> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? status,
    Expression<String>? priority,
    Expression<DateTime>? dueDate,
    Expression<DateTime>? plannedDate,
    Expression<DateTime>? deletedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? completedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (status != null) 'status': status,
      if (priority != null) 'priority': priority,
      if (dueDate != null) 'due_date': dueDate,
      if (plannedDate != null) 'planned_date': plannedDate,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TasksCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String?>? description,
    Value<TaskStatus>? status,
    Value<TaskPriority>? priority,
    Value<DateTime?>? dueDate,
    Value<DateTime?>? plannedDate,
    Value<DateTime?>? deletedAt,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? completedAt,
    Value<int>? rowid,
  }) {
    return TasksCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      plannedDate: plannedDate ?? this.plannedDate,
      deletedAt: deletedAt ?? this.deletedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
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
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $TasksTable.$converterstatus.toSql(status.value),
      );
    }
    if (priority.present) {
      map['priority'] = Variable<String>(
        $TasksTable.$converterpriority.toSql(priority.value),
      );
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (plannedDate.present) {
      map['planned_date'] = Variable<DateTime>(plannedDate.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasksCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('status: $status, ')
          ..write('priority: $priority, ')
          ..write('dueDate: $dueDate, ')
          ..write('plannedDate: $plannedDate, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TaskHistoryEventsTable extends TaskHistoryEvents
    with TableInfo<$TaskHistoryEventsTable, TaskHistoryEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TaskHistoryEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
    'task_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<TaskHistoryEventType, String>
  eventType =
      GeneratedColumn<String>(
        'event_type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<TaskHistoryEventType>(
        $TaskHistoryEventsTable.$convertereventType,
      );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<DateTime> occurredAt = GeneratedColumn<DateTime>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _previousPlannedDateMeta =
      const VerificationMeta('previousPlannedDate');
  @override
  late final GeneratedColumn<DateTime> previousPlannedDate =
      GeneratedColumn<DateTime>(
        'previous_planned_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _newPlannedDateMeta = const VerificationMeta(
    'newPlannedDate',
  );
  @override
  late final GeneratedColumn<DateTime> newPlannedDate =
      GeneratedColumn<DateTime>(
        'new_planned_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _previousDueDateMeta = const VerificationMeta(
    'previousDueDate',
  );
  @override
  late final GeneratedColumn<DateTime> previousDueDate =
      GeneratedColumn<DateTime>(
        'previous_due_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _newDueDateMeta = const VerificationMeta(
    'newDueDate',
  );
  @override
  late final GeneratedColumn<DateTime> newDueDate = GeneratedColumn<DateTime>(
    'new_due_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _previousStatusMeta = const VerificationMeta(
    'previousStatus',
  );
  @override
  late final GeneratedColumn<String> previousStatus = GeneratedColumn<String>(
    'previous_status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _newStatusMeta = const VerificationMeta(
    'newStatus',
  );
  @override
  late final GeneratedColumn<String> newStatus = GeneratedColumn<String>(
    'new_status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    taskId,
    eventType,
    occurredAt,
    previousPlannedDate,
    newPlannedDate,
    previousDueDate,
    newDueDate,
    previousStatus,
    newStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'task_history_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<TaskHistoryEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    if (data.containsKey('previous_planned_date')) {
      context.handle(
        _previousPlannedDateMeta,
        previousPlannedDate.isAcceptableOrUnknown(
          data['previous_planned_date']!,
          _previousPlannedDateMeta,
        ),
      );
    }
    if (data.containsKey('new_planned_date')) {
      context.handle(
        _newPlannedDateMeta,
        newPlannedDate.isAcceptableOrUnknown(
          data['new_planned_date']!,
          _newPlannedDateMeta,
        ),
      );
    }
    if (data.containsKey('previous_due_date')) {
      context.handle(
        _previousDueDateMeta,
        previousDueDate.isAcceptableOrUnknown(
          data['previous_due_date']!,
          _previousDueDateMeta,
        ),
      );
    }
    if (data.containsKey('new_due_date')) {
      context.handle(
        _newDueDateMeta,
        newDueDate.isAcceptableOrUnknown(
          data['new_due_date']!,
          _newDueDateMeta,
        ),
      );
    }
    if (data.containsKey('previous_status')) {
      context.handle(
        _previousStatusMeta,
        previousStatus.isAcceptableOrUnknown(
          data['previous_status']!,
          _previousStatusMeta,
        ),
      );
    }
    if (data.containsKey('new_status')) {
      context.handle(
        _newStatusMeta,
        newStatus.isAcceptableOrUnknown(data['new_status']!, _newStatusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TaskHistoryEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskHistoryEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_id'],
      )!,
      eventType: $TaskHistoryEventsTable.$convertereventType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}event_type'],
        )!,
      ),
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at'],
      )!,
      previousPlannedDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}previous_planned_date'],
      ),
      newPlannedDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}new_planned_date'],
      ),
      previousDueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}previous_due_date'],
      ),
      newDueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}new_due_date'],
      ),
      previousStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}previous_status'],
      ),
      newStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}new_status'],
      ),
    );
  }

  @override
  $TaskHistoryEventsTable createAlias(String alias) {
    return $TaskHistoryEventsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TaskHistoryEventType, String, String>
  $convertereventType = const EnumNameConverter<TaskHistoryEventType>(
    TaskHistoryEventType.values,
  );
}

class TaskHistoryEvent extends DataClass
    implements Insertable<TaskHistoryEvent> {
  final String id;
  final String taskId;
  final TaskHistoryEventType eventType;
  final DateTime occurredAt;
  final DateTime? previousPlannedDate;
  final DateTime? newPlannedDate;
  final DateTime? previousDueDate;
  final DateTime? newDueDate;
  final String? previousStatus;
  final String? newStatus;
  const TaskHistoryEvent({
    required this.id,
    required this.taskId,
    required this.eventType,
    required this.occurredAt,
    this.previousPlannedDate,
    this.newPlannedDate,
    this.previousDueDate,
    this.newDueDate,
    this.previousStatus,
    this.newStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['task_id'] = Variable<String>(taskId);
    {
      map['event_type'] = Variable<String>(
        $TaskHistoryEventsTable.$convertereventType.toSql(eventType),
      );
    }
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    if (!nullToAbsent || previousPlannedDate != null) {
      map['previous_planned_date'] = Variable<DateTime>(previousPlannedDate);
    }
    if (!nullToAbsent || newPlannedDate != null) {
      map['new_planned_date'] = Variable<DateTime>(newPlannedDate);
    }
    if (!nullToAbsent || previousDueDate != null) {
      map['previous_due_date'] = Variable<DateTime>(previousDueDate);
    }
    if (!nullToAbsent || newDueDate != null) {
      map['new_due_date'] = Variable<DateTime>(newDueDate);
    }
    if (!nullToAbsent || previousStatus != null) {
      map['previous_status'] = Variable<String>(previousStatus);
    }
    if (!nullToAbsent || newStatus != null) {
      map['new_status'] = Variable<String>(newStatus);
    }
    return map;
  }

  TaskHistoryEventsCompanion toCompanion(bool nullToAbsent) {
    return TaskHistoryEventsCompanion(
      id: Value(id),
      taskId: Value(taskId),
      eventType: Value(eventType),
      occurredAt: Value(occurredAt),
      previousPlannedDate: previousPlannedDate == null && nullToAbsent
          ? const Value.absent()
          : Value(previousPlannedDate),
      newPlannedDate: newPlannedDate == null && nullToAbsent
          ? const Value.absent()
          : Value(newPlannedDate),
      previousDueDate: previousDueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(previousDueDate),
      newDueDate: newDueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(newDueDate),
      previousStatus: previousStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(previousStatus),
      newStatus: newStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(newStatus),
    );
  }

  factory TaskHistoryEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskHistoryEvent(
      id: serializer.fromJson<String>(json['id']),
      taskId: serializer.fromJson<String>(json['taskId']),
      eventType: $TaskHistoryEventsTable.$convertereventType.fromJson(
        serializer.fromJson<String>(json['eventType']),
      ),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
      previousPlannedDate: serializer.fromJson<DateTime?>(
        json['previousPlannedDate'],
      ),
      newPlannedDate: serializer.fromJson<DateTime?>(json['newPlannedDate']),
      previousDueDate: serializer.fromJson<DateTime?>(json['previousDueDate']),
      newDueDate: serializer.fromJson<DateTime?>(json['newDueDate']),
      previousStatus: serializer.fromJson<String?>(json['previousStatus']),
      newStatus: serializer.fromJson<String?>(json['newStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'taskId': serializer.toJson<String>(taskId),
      'eventType': serializer.toJson<String>(
        $TaskHistoryEventsTable.$convertereventType.toJson(eventType),
      ),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
      'previousPlannedDate': serializer.toJson<DateTime?>(previousPlannedDate),
      'newPlannedDate': serializer.toJson<DateTime?>(newPlannedDate),
      'previousDueDate': serializer.toJson<DateTime?>(previousDueDate),
      'newDueDate': serializer.toJson<DateTime?>(newDueDate),
      'previousStatus': serializer.toJson<String?>(previousStatus),
      'newStatus': serializer.toJson<String?>(newStatus),
    };
  }

  TaskHistoryEvent copyWith({
    String? id,
    String? taskId,
    TaskHistoryEventType? eventType,
    DateTime? occurredAt,
    Value<DateTime?> previousPlannedDate = const Value.absent(),
    Value<DateTime?> newPlannedDate = const Value.absent(),
    Value<DateTime?> previousDueDate = const Value.absent(),
    Value<DateTime?> newDueDate = const Value.absent(),
    Value<String?> previousStatus = const Value.absent(),
    Value<String?> newStatus = const Value.absent(),
  }) => TaskHistoryEvent(
    id: id ?? this.id,
    taskId: taskId ?? this.taskId,
    eventType: eventType ?? this.eventType,
    occurredAt: occurredAt ?? this.occurredAt,
    previousPlannedDate: previousPlannedDate.present
        ? previousPlannedDate.value
        : this.previousPlannedDate,
    newPlannedDate: newPlannedDate.present
        ? newPlannedDate.value
        : this.newPlannedDate,
    previousDueDate: previousDueDate.present
        ? previousDueDate.value
        : this.previousDueDate,
    newDueDate: newDueDate.present ? newDueDate.value : this.newDueDate,
    previousStatus: previousStatus.present
        ? previousStatus.value
        : this.previousStatus,
    newStatus: newStatus.present ? newStatus.value : this.newStatus,
  );
  TaskHistoryEvent copyWithCompanion(TaskHistoryEventsCompanion data) {
    return TaskHistoryEvent(
      id: data.id.present ? data.id.value : this.id,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
      previousPlannedDate: data.previousPlannedDate.present
          ? data.previousPlannedDate.value
          : this.previousPlannedDate,
      newPlannedDate: data.newPlannedDate.present
          ? data.newPlannedDate.value
          : this.newPlannedDate,
      previousDueDate: data.previousDueDate.present
          ? data.previousDueDate.value
          : this.previousDueDate,
      newDueDate: data.newDueDate.present
          ? data.newDueDate.value
          : this.newDueDate,
      previousStatus: data.previousStatus.present
          ? data.previousStatus.value
          : this.previousStatus,
      newStatus: data.newStatus.present ? data.newStatus.value : this.newStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskHistoryEvent(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('eventType: $eventType, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('previousPlannedDate: $previousPlannedDate, ')
          ..write('newPlannedDate: $newPlannedDate, ')
          ..write('previousDueDate: $previousDueDate, ')
          ..write('newDueDate: $newDueDate, ')
          ..write('previousStatus: $previousStatus, ')
          ..write('newStatus: $newStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    taskId,
    eventType,
    occurredAt,
    previousPlannedDate,
    newPlannedDate,
    previousDueDate,
    newDueDate,
    previousStatus,
    newStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskHistoryEvent &&
          other.id == this.id &&
          other.taskId == this.taskId &&
          other.eventType == this.eventType &&
          other.occurredAt == this.occurredAt &&
          other.previousPlannedDate == this.previousPlannedDate &&
          other.newPlannedDate == this.newPlannedDate &&
          other.previousDueDate == this.previousDueDate &&
          other.newDueDate == this.newDueDate &&
          other.previousStatus == this.previousStatus &&
          other.newStatus == this.newStatus);
}

class TaskHistoryEventsCompanion extends UpdateCompanion<TaskHistoryEvent> {
  final Value<String> id;
  final Value<String> taskId;
  final Value<TaskHistoryEventType> eventType;
  final Value<DateTime> occurredAt;
  final Value<DateTime?> previousPlannedDate;
  final Value<DateTime?> newPlannedDate;
  final Value<DateTime?> previousDueDate;
  final Value<DateTime?> newDueDate;
  final Value<String?> previousStatus;
  final Value<String?> newStatus;
  final Value<int> rowid;
  const TaskHistoryEventsCompanion({
    this.id = const Value.absent(),
    this.taskId = const Value.absent(),
    this.eventType = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.previousPlannedDate = const Value.absent(),
    this.newPlannedDate = const Value.absent(),
    this.previousDueDate = const Value.absent(),
    this.newDueDate = const Value.absent(),
    this.previousStatus = const Value.absent(),
    this.newStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TaskHistoryEventsCompanion.insert({
    required String id,
    required String taskId,
    required TaskHistoryEventType eventType,
    required DateTime occurredAt,
    this.previousPlannedDate = const Value.absent(),
    this.newPlannedDate = const Value.absent(),
    this.previousDueDate = const Value.absent(),
    this.newDueDate = const Value.absent(),
    this.previousStatus = const Value.absent(),
    this.newStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       taskId = Value(taskId),
       eventType = Value(eventType),
       occurredAt = Value(occurredAt);
  static Insertable<TaskHistoryEvent> custom({
    Expression<String>? id,
    Expression<String>? taskId,
    Expression<String>? eventType,
    Expression<DateTime>? occurredAt,
    Expression<DateTime>? previousPlannedDate,
    Expression<DateTime>? newPlannedDate,
    Expression<DateTime>? previousDueDate,
    Expression<DateTime>? newDueDate,
    Expression<String>? previousStatus,
    Expression<String>? newStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (taskId != null) 'task_id': taskId,
      if (eventType != null) 'event_type': eventType,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (previousPlannedDate != null)
        'previous_planned_date': previousPlannedDate,
      if (newPlannedDate != null) 'new_planned_date': newPlannedDate,
      if (previousDueDate != null) 'previous_due_date': previousDueDate,
      if (newDueDate != null) 'new_due_date': newDueDate,
      if (previousStatus != null) 'previous_status': previousStatus,
      if (newStatus != null) 'new_status': newStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TaskHistoryEventsCompanion copyWith({
    Value<String>? id,
    Value<String>? taskId,
    Value<TaskHistoryEventType>? eventType,
    Value<DateTime>? occurredAt,
    Value<DateTime?>? previousPlannedDate,
    Value<DateTime?>? newPlannedDate,
    Value<DateTime?>? previousDueDate,
    Value<DateTime?>? newDueDate,
    Value<String?>? previousStatus,
    Value<String?>? newStatus,
    Value<int>? rowid,
  }) {
    return TaskHistoryEventsCompanion(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      eventType: eventType ?? this.eventType,
      occurredAt: occurredAt ?? this.occurredAt,
      previousPlannedDate: previousPlannedDate ?? this.previousPlannedDate,
      newPlannedDate: newPlannedDate ?? this.newPlannedDate,
      previousDueDate: previousDueDate ?? this.previousDueDate,
      newDueDate: newDueDate ?? this.newDueDate,
      previousStatus: previousStatus ?? this.previousStatus,
      newStatus: newStatus ?? this.newStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (eventType.present) {
      map['event_type'] = Variable<String>(
        $TaskHistoryEventsTable.$convertereventType.toSql(eventType.value),
      );
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    if (previousPlannedDate.present) {
      map['previous_planned_date'] = Variable<DateTime>(
        previousPlannedDate.value,
      );
    }
    if (newPlannedDate.present) {
      map['new_planned_date'] = Variable<DateTime>(newPlannedDate.value);
    }
    if (previousDueDate.present) {
      map['previous_due_date'] = Variable<DateTime>(previousDueDate.value);
    }
    if (newDueDate.present) {
      map['new_due_date'] = Variable<DateTime>(newDueDate.value);
    }
    if (previousStatus.present) {
      map['previous_status'] = Variable<String>(previousStatus.value);
    }
    if (newStatus.present) {
      map['new_status'] = Variable<String>(newStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TaskHistoryEventsCompanion(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('eventType: $eventType, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('previousPlannedDate: $previousPlannedDate, ')
          ..write('newPlannedDate: $newPlannedDate, ')
          ..write('previousDueDate: $previousDueDate, ')
          ..write('newDueDate: $newDueDate, ')
          ..write('previousStatus: $previousStatus, ')
          ..write('newStatus: $newStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TasksTable tasks = $TasksTable(this);
  late final $TaskHistoryEventsTable taskHistoryEvents =
      $TaskHistoryEventsTable(this);
  late final Index idxTaskHistoryEventsTaskId = Index(
    'idx_task_history_events_task_id',
    'CREATE INDEX idx_task_history_events_task_id ON task_history_events (task_id)',
  );
  late final Index idxTaskHistoryEventsOccurredAt = Index(
    'idx_task_history_events_occurred_at',
    'CREATE INDEX idx_task_history_events_occurred_at ON task_history_events (occurred_at)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    tasks,
    taskHistoryEvents,
    idxTaskHistoryEventsTaskId,
    idxTaskHistoryEventsOccurredAt,
  ];
}

typedef $$TasksTableCreateCompanionBuilder =
    TasksCompanion Function({
      required String id,
      required String title,
      Value<String?> description,
      Value<TaskStatus> status,
      Value<TaskPriority> priority,
      Value<DateTime?> dueDate,
      Value<DateTime?> plannedDate,
      Value<DateTime?> deletedAt,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> completedAt,
      Value<int> rowid,
    });
typedef $$TasksTableUpdateCompanionBuilder =
    TasksCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String?> description,
      Value<TaskStatus> status,
      Value<TaskPriority> priority,
      Value<DateTime?> dueDate,
      Value<DateTime?> plannedDate,
      Value<DateTime?> deletedAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> completedAt,
      Value<int> rowid,
    });

class $$TasksTableFilterComposer extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableFilterComposer({
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

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TaskStatus, TaskStatus, String> get status =>
      $composableBuilder(
        column: $table.status,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<TaskPriority, TaskPriority, String>
  get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get plannedDate => $composableBuilder(
    column: $table.plannedDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
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

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TasksTableOrderingComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableOrderingComposer({
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

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get plannedDate => $composableBuilder(
    column: $table.plannedDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
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

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableAnnotationComposer({
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

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<TaskStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TaskPriority, String> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<DateTime> get plannedDate => $composableBuilder(
    column: $table.plannedDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );
}

class $$TasksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TasksTable,
          Task,
          $$TasksTableFilterComposer,
          $$TasksTableOrderingComposer,
          $$TasksTableAnnotationComposer,
          $$TasksTableCreateCompanionBuilder,
          $$TasksTableUpdateCompanionBuilder,
          (Task, BaseReferences<_$AppDatabase, $TasksTable, Task>),
          Task,
          PrefetchHooks Function()
        > {
  $$TasksTableTableManager(_$AppDatabase db, $TasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<TaskStatus> status = const Value.absent(),
                Value<TaskPriority> priority = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                Value<DateTime?> plannedDate = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TasksCompanion(
                id: id,
                title: title,
                description: description,
                status: status,
                priority: priority,
                dueDate: dueDate,
                plannedDate: plannedDate,
                deletedAt: deletedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                completedAt: completedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                Value<String?> description = const Value.absent(),
                Value<TaskStatus> status = const Value.absent(),
                Value<TaskPriority> priority = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                Value<DateTime?> plannedDate = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TasksCompanion.insert(
                id: id,
                title: title,
                description: description,
                status: status,
                priority: priority,
                dueDate: dueDate,
                plannedDate: plannedDate,
                deletedAt: deletedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                completedAt: completedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TasksTable,
      Task,
      $$TasksTableFilterComposer,
      $$TasksTableOrderingComposer,
      $$TasksTableAnnotationComposer,
      $$TasksTableCreateCompanionBuilder,
      $$TasksTableUpdateCompanionBuilder,
      (Task, BaseReferences<_$AppDatabase, $TasksTable, Task>),
      Task,
      PrefetchHooks Function()
    >;
typedef $$TaskHistoryEventsTableCreateCompanionBuilder =
    TaskHistoryEventsCompanion Function({
      required String id,
      required String taskId,
      required TaskHistoryEventType eventType,
      required DateTime occurredAt,
      Value<DateTime?> previousPlannedDate,
      Value<DateTime?> newPlannedDate,
      Value<DateTime?> previousDueDate,
      Value<DateTime?> newDueDate,
      Value<String?> previousStatus,
      Value<String?> newStatus,
      Value<int> rowid,
    });
typedef $$TaskHistoryEventsTableUpdateCompanionBuilder =
    TaskHistoryEventsCompanion Function({
      Value<String> id,
      Value<String> taskId,
      Value<TaskHistoryEventType> eventType,
      Value<DateTime> occurredAt,
      Value<DateTime?> previousPlannedDate,
      Value<DateTime?> newPlannedDate,
      Value<DateTime?> previousDueDate,
      Value<DateTime?> newDueDate,
      Value<String?> previousStatus,
      Value<String?> newStatus,
      Value<int> rowid,
    });

class $$TaskHistoryEventsTableFilterComposer
    extends Composer<_$AppDatabase, $TaskHistoryEventsTable> {
  $$TaskHistoryEventsTableFilterComposer({
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

  ColumnFilters<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    TaskHistoryEventType,
    TaskHistoryEventType,
    String
  >
  get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get previousPlannedDate => $composableBuilder(
    column: $table.previousPlannedDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get newPlannedDate => $composableBuilder(
    column: $table.newPlannedDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get previousDueDate => $composableBuilder(
    column: $table.previousDueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get newDueDate => $composableBuilder(
    column: $table.newDueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get previousStatus => $composableBuilder(
    column: $table.previousStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get newStatus => $composableBuilder(
    column: $table.newStatus,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TaskHistoryEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $TaskHistoryEventsTable> {
  $$TaskHistoryEventsTableOrderingComposer({
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

  ColumnOrderings<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get previousPlannedDate => $composableBuilder(
    column: $table.previousPlannedDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get newPlannedDate => $composableBuilder(
    column: $table.newPlannedDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get previousDueDate => $composableBuilder(
    column: $table.previousDueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get newDueDate => $composableBuilder(
    column: $table.newDueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get previousStatus => $composableBuilder(
    column: $table.previousStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get newStatus => $composableBuilder(
    column: $table.newStatus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TaskHistoryEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TaskHistoryEventsTable> {
  $$TaskHistoryEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get taskId =>
      $composableBuilder(column: $table.taskId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TaskHistoryEventType, String>
  get eventType =>
      $composableBuilder(column: $table.eventType, builder: (column) => column);

  GeneratedColumn<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get previousPlannedDate => $composableBuilder(
    column: $table.previousPlannedDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get newPlannedDate => $composableBuilder(
    column: $table.newPlannedDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get previousDueDate => $composableBuilder(
    column: $table.previousDueDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get newDueDate => $composableBuilder(
    column: $table.newDueDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get previousStatus => $composableBuilder(
    column: $table.previousStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get newStatus =>
      $composableBuilder(column: $table.newStatus, builder: (column) => column);
}

class $$TaskHistoryEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TaskHistoryEventsTable,
          TaskHistoryEvent,
          $$TaskHistoryEventsTableFilterComposer,
          $$TaskHistoryEventsTableOrderingComposer,
          $$TaskHistoryEventsTableAnnotationComposer,
          $$TaskHistoryEventsTableCreateCompanionBuilder,
          $$TaskHistoryEventsTableUpdateCompanionBuilder,
          (
            TaskHistoryEvent,
            BaseReferences<
              _$AppDatabase,
              $TaskHistoryEventsTable,
              TaskHistoryEvent
            >,
          ),
          TaskHistoryEvent,
          PrefetchHooks Function()
        > {
  $$TaskHistoryEventsTableTableManager(
    _$AppDatabase db,
    $TaskHistoryEventsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TaskHistoryEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TaskHistoryEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TaskHistoryEventsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> taskId = const Value.absent(),
                Value<TaskHistoryEventType> eventType = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
                Value<DateTime?> previousPlannedDate = const Value.absent(),
                Value<DateTime?> newPlannedDate = const Value.absent(),
                Value<DateTime?> previousDueDate = const Value.absent(),
                Value<DateTime?> newDueDate = const Value.absent(),
                Value<String?> previousStatus = const Value.absent(),
                Value<String?> newStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TaskHistoryEventsCompanion(
                id: id,
                taskId: taskId,
                eventType: eventType,
                occurredAt: occurredAt,
                previousPlannedDate: previousPlannedDate,
                newPlannedDate: newPlannedDate,
                previousDueDate: previousDueDate,
                newDueDate: newDueDate,
                previousStatus: previousStatus,
                newStatus: newStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String taskId,
                required TaskHistoryEventType eventType,
                required DateTime occurredAt,
                Value<DateTime?> previousPlannedDate = const Value.absent(),
                Value<DateTime?> newPlannedDate = const Value.absent(),
                Value<DateTime?> previousDueDate = const Value.absent(),
                Value<DateTime?> newDueDate = const Value.absent(),
                Value<String?> previousStatus = const Value.absent(),
                Value<String?> newStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TaskHistoryEventsCompanion.insert(
                id: id,
                taskId: taskId,
                eventType: eventType,
                occurredAt: occurredAt,
                previousPlannedDate: previousPlannedDate,
                newPlannedDate: newPlannedDate,
                previousDueDate: previousDueDate,
                newDueDate: newDueDate,
                previousStatus: previousStatus,
                newStatus: newStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TaskHistoryEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TaskHistoryEventsTable,
      TaskHistoryEvent,
      $$TaskHistoryEventsTableFilterComposer,
      $$TaskHistoryEventsTableOrderingComposer,
      $$TaskHistoryEventsTableAnnotationComposer,
      $$TaskHistoryEventsTableCreateCompanionBuilder,
      $$TaskHistoryEventsTableUpdateCompanionBuilder,
      (
        TaskHistoryEvent,
        BaseReferences<
          _$AppDatabase,
          $TaskHistoryEventsTable,
          TaskHistoryEvent
        >,
      ),
      TaskHistoryEvent,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db, _db.tasks);
  $$TaskHistoryEventsTableTableManager get taskHistoryEvents =>
      $$TaskHistoryEventsTableTableManager(_db, _db.taskHistoryEvents);
}
