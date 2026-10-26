import 'package:drift/drift.dart';

/// Event types recorded in [TaskHistoryEvents].
enum TaskHistoryEventType {
  created,
  planned,
  rescheduled,
  deadlineChanged,
  completed,
  reopened,
  deleted,
}

/// The 	ask_history_events table.
@TableIndex(name: 'idx_task_history_events_task_id', columns: {#taskId})
@TableIndex(name: 'idx_task_history_events_occurred_at', columns: {#occurredAt})
class TaskHistoryEvents extends Table {
  TextColumn get id => text()();
  TextColumn get taskId => text()();
  TextColumn get eventType => text().map(
    const EnumNameConverter<TaskHistoryEventType>(TaskHistoryEventType.values),
  )();
  DateTimeColumn get occurredAt => dateTime()();
  DateTimeColumn get previousPlannedDate => dateTime().nullable()();
  DateTimeColumn get newPlannedDate => dateTime().nullable()();
  DateTimeColumn get previousDueDate => dateTime().nullable()();
  DateTimeColumn get newDueDate => dateTime().nullable()();
  TextColumn get previousStatus => text().nullable()();
  TextColumn get newStatus => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
