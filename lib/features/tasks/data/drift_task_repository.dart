import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:momentum/core/database/app_database.dart' as db;
import 'package:momentum/core/database/tables/task_history_events.dart' as hist;
import 'package:momentum/core/database/tables/tasks.dart' as tables;
import 'package:momentum/features/tasks/domain/task.dart';
import 'package:momentum/features/tasks/domain/task_history_event.dart';
import 'package:momentum/features/tasks/domain/task_repository.dart';
import 'package:uuid/uuid.dart';

class DriftTaskRepository implements TaskRepository {
  DriftTaskRepository(this._database);

  final db.AppDatabase _database;
  static const Uuid _uuid = Uuid();

  @override
  Future<Task> create(TaskDraft draft) async {
    final String title = draft.title.trim();
    if (title.isEmpty) throw ArgumentError('Task title must not be empty.');

    final DateTime now = DateTime.now();
    final String id = _uuid.v4();

    await _database.transaction(() async {
      await _database
          .into(_database.tasks)
          .insert(
            db.TasksCompanion.insert(
              id: id,
              title: title,
              description: _valueOrNull(draft.description?.trim()),
              status: const Value(tables.TaskStatus.pending),
              priority: Value(draft.priority),
              dueDate: Value(draft.dueDate),
              plannedDate: Value(draft.plannedDate),
              createdAt: now,
              updatedAt: now,
            ),
          );
      await _database
          .into(_database.taskHistoryEvents)
          .insert(
            db.TaskHistoryEventsCompanion.insert(
              id: _uuid.v4(),
              taskId: id,
              eventType: hist.TaskHistoryEventType.created,
              occurredAt: now,
              newPlannedDate: Value(draft.plannedDate),
              newDueDate: Value(draft.dueDate),
              newStatus: const Value('pending'),
            ),
          );
      if (draft.plannedDate != null) {
        await _database
            .into(_database.taskHistoryEvents)
            .insert(
              db.TaskHistoryEventsCompanion.insert(
                id: _uuid.v4(),
                taskId: id,
                eventType: hist.TaskHistoryEventType.planned,
                occurredAt: now,
                newPlannedDate: Value(draft.plannedDate),
              ),
            );
      }
    });

    return Task(
      id: id,
      title: title,
      description: _normalizeDescription(draft.description),
      status: tables.TaskStatus.pending,
      priority: draft.priority,
      dueDate: draft.dueDate,
      plannedDate: draft.plannedDate,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Future<Task?> getById(String id) async {
    final db.Task? row =
        await (_database.select(_database.tasks)..where(
              (tables.Tasks t) => t.id.equals(id) & t.deletedAt.isNull(),
            ))
            .getSingleOrNull();
    return row == null ? null : _toDomain(row);
  }

  @override
  Future<List<Task>> getAll() async {
    final rows =
        await (_database.select(_database.tasks)
              ..where((tables.Tasks t) => t.deletedAt.isNull())
              ..orderBy([(tables.Tasks t) => OrderingTerm.desc(t.createdAt)]))
            .get();
    return rows.map(_toDomain).toList();
  }

  @override
  Stream<List<Task>> watchAll() {
    return (_database.select(_database.tasks)
          ..where((tables.Tasks t) => t.deletedAt.isNull())
          ..orderBy([(tables.Tasks t) => OrderingTerm.desc(t.createdAt)]))
        .watch()
        .map((rows) => rows.map(_toDomain).toList());
  }

  @override
  Stream<Task?> watchById(String id) {
    return (_database.select(_database.tasks)
          ..where((tables.Tasks t) => t.id.equals(id) & t.deletedAt.isNull()))
        .watchSingleOrNull()
        .map((row) => row == null ? null : _toDomain(row));
  }

  @override
  Future<Task> update(String id, TaskUpdate update) async {
    final db.Task? existing =
        await (_database.select(_database.tasks)..where(
              (tables.Tasks t) => t.id.equals(id) & t.deletedAt.isNull(),
            ))
            .getSingleOrNull();
    if (existing == null) throw StateError('Task not found: $id');

    final String? newTitle = update.title?.trim();
    if (newTitle != null && newTitle.isEmpty) {
      throw ArgumentError('Task title must not be empty.');
    }

    final DateTime now = DateTime.now();
    final tables.TaskStatus newStatus = update.status ?? existing.status;
    final DateTime? newCompletedAt = _resolveCompletedAt(
      existing: existing.completedAt,
      newStatus: newStatus,
      now: now,
    );

    final DateTime? newDueDate = update.clearDueDate
        ? null
        : (update.dueDate ?? existing.dueDate);
    final DateTime? newPlannedDate = update.clearPlannedDate
        ? null
        : (update.plannedDate ?? existing.plannedDate);

    final bool plannedChanged = newPlannedDate != existing.plannedDate;
    final bool dueChanged = newDueDate != existing.dueDate;
    final bool statusChanged = newStatus != existing.status;

    await _database.transaction(() async {
      await (_database.update(
        _database.tasks,
      )..where((tables.Tasks t) => t.id.equals(id))).write(
        db.TasksCompanion(
          title: newTitle == null ? const Value.absent() : Value(newTitle),
          description: update.clearDescription
              ? const Value(null)
              : (update.description == null
                    ? const Value.absent()
                    : Value(_normalizeDescription(update.description))),
          status: update.status == null
              ? const Value.absent()
              : Value(update.status!),
          priority: update.priority == null
              ? const Value.absent()
              : Value(update.priority!),
          dueDate: update.clearDueDate
              ? const Value(null)
              : (update.dueDate == null
                    ? const Value.absent()
                    : Value(update.dueDate)),
          plannedDate: update.clearPlannedDate
              ? const Value(null)
              : (update.plannedDate == null
                    ? const Value.absent()
                    : Value(update.plannedDate)),
          completedAt: Value(newCompletedAt),
          updatedAt: Value(now),
        ),
      );

      if (plannedChanged) {
        await _database
            .into(_database.taskHistoryEvents)
            .insert(
              db.TaskHistoryEventsCompanion.insert(
                id: _uuid.v4(),
                taskId: id,
                eventType:
                    existing.plannedDate == null && newPlannedDate != null
                    ? hist.TaskHistoryEventType.planned
                    : hist.TaskHistoryEventType.rescheduled,
                occurredAt: now,
                previousPlannedDate: Value(existing.plannedDate),
                newPlannedDate: Value(newPlannedDate),
              ),
            );
      }
      if (dueChanged) {
        await _database
            .into(_database.taskHistoryEvents)
            .insert(
              db.TaskHistoryEventsCompanion.insert(
                id: _uuid.v4(),
                taskId: id,
                eventType: hist.TaskHistoryEventType.deadlineChanged,
                occurredAt: now,
                previousDueDate: Value(existing.dueDate),
                newDueDate: Value(newDueDate),
              ),
            );
      }
      if (statusChanged) {
        await _database
            .into(_database.taskHistoryEvents)
            .insert(
              db.TaskHistoryEventsCompanion.insert(
                id: _uuid.v4(),
                taskId: id,
                eventType: newStatus == tables.TaskStatus.completed
                    ? hist.TaskHistoryEventType.completed
                    : hist.TaskHistoryEventType.reopened,
                occurredAt: now,
                newPlannedDate: Value(newPlannedDate),
                newDueDate: Value(newDueDate),
                previousStatus: Value(existing.status.name),
                newStatus: Value(newStatus.name),
              ),
            );
      }
    });

    return Task(
      id: existing.id,
      title: newTitle ?? existing.title,
      description: update.clearDescription
          ? null
          : (update.description ?? existing.description),
      status: newStatus,
      priority: update.priority ?? existing.priority,
      dueDate: newDueDate,
      plannedDate: newPlannedDate,
      createdAt: existing.createdAt,
      updatedAt: now,
      completedAt: newCompletedAt,
    );
  }

  @override
  Future<bool> delete(String id) async {
    final db.Task? existing =
        await (_database.select(_database.tasks)..where(
              (tables.Tasks t) => t.id.equals(id) & t.deletedAt.isNull(),
            ))
            .getSingleOrNull();
    if (existing == null) return false;

    final DateTime now = DateTime.now();
    await _database.transaction(() async {
      await (_database.update(
        _database.tasks,
      )..where((tables.Tasks t) => t.id.equals(id))).write(
        db.TasksCompanion(deletedAt: Value(now), updatedAt: Value(now)),
      );
      await _database
          .into(_database.taskHistoryEvents)
          .insert(
            db.TaskHistoryEventsCompanion.insert(
              id: _uuid.v4(),
              taskId: id,
              eventType: hist.TaskHistoryEventType.deleted,
              occurredAt: now,
              previousPlannedDate: Value(existing.plannedDate),
              previousDueDate: Value(existing.dueDate),
              previousStatus: Value(existing.status.name),
            ),
          );
    });
    return true;
  }

  @override
  Future<Task> complete(String id) async {
    final db.Task? existing =
        await (_database.select(_database.tasks)..where(
              (tables.Tasks t) => t.id.equals(id) & t.deletedAt.isNull(),
            ))
            .getSingleOrNull();
    if (existing == null) throw StateError('Task not found: $id');

    final DateTime now = DateTime.now();
    await _database.transaction(() async {
      await (_database.update(
        _database.tasks,
      )..where((tables.Tasks t) => t.id.equals(id))).write(
        db.TasksCompanion(
          status: const Value(tables.TaskStatus.completed),
          completedAt: Value(now),
          updatedAt: Value(now),
        ),
      );
      await _database
          .into(_database.taskHistoryEvents)
          .insert(
            db.TaskHistoryEventsCompanion.insert(
              id: _uuid.v4(),
              taskId: id,
              eventType: hist.TaskHistoryEventType.completed,
              occurredAt: now,
              newPlannedDate: Value(existing.plannedDate),
              newDueDate: Value(existing.dueDate),
              previousStatus: Value(existing.status.name),
              newStatus: const Value('completed'),
            ),
          );
    });

    return Task(
      id: existing.id,
      title: existing.title,
      description: existing.description,
      status: tables.TaskStatus.completed,
      priority: existing.priority,
      dueDate: existing.dueDate,
      plannedDate: existing.plannedDate,
      createdAt: existing.createdAt,
      updatedAt: now,
      completedAt: now,
    );
  }

  @override
  Future<Task> reopen(String id) async {
    final db.Task? existing =
        await (_database.select(_database.tasks)..where(
              (tables.Tasks t) => t.id.equals(id) & t.deletedAt.isNull(),
            ))
            .getSingleOrNull();
    if (existing == null) throw StateError('Task not found: $id');

    final DateTime now = DateTime.now();
    await _database.transaction(() async {
      await (_database.update(
        _database.tasks,
      )..where((tables.Tasks t) => t.id.equals(id))).write(
        db.TasksCompanion(
          status: const Value(tables.TaskStatus.pending),
          completedAt: const Value(null),
          updatedAt: Value(now),
        ),
      );
      await _database
          .into(_database.taskHistoryEvents)
          .insert(
            db.TaskHistoryEventsCompanion.insert(
              id: _uuid.v4(),
              taskId: id,
              eventType: hist.TaskHistoryEventType.reopened,
              occurredAt: now,
              newPlannedDate: Value(existing.plannedDate),
              newDueDate: Value(existing.dueDate),
              previousStatus: Value(existing.status.name),
              newStatus: const Value('pending'),
            ),
          );
    });

    return Task(
      id: existing.id,
      title: existing.title,
      description: existing.description,
      status: tables.TaskStatus.pending,
      priority: existing.priority,
      dueDate: existing.dueDate,
      plannedDate: existing.plannedDate,
      createdAt: existing.createdAt,
      updatedAt: now,
      completedAt: null,
    );
  }

  @override
  Future<List<TaskHistoryEvent>> getHistoryForTask(String id) async {
    final rows =
        await (_database.select(_database.taskHistoryEvents)
              ..where((hist.TaskHistoryEvents t) => t.taskId.equals(id))
              ..orderBy([
                (hist.TaskHistoryEvents t) => OrderingTerm.asc(t.occurredAt),
              ]))
            .get();
    return rows.map(_toHistory).toList();
  }

  @override
  Future<List<TaskHistoryEvent>> getAllHistory() async {
    final rows =
        await (_database.select(_database.taskHistoryEvents)..orderBy([
              (hist.TaskHistoryEvents t) => OrderingTerm.asc(t.occurredAt),
            ]))
            .get();
    return rows.map(_toHistory).toList();
  }

  Task _toDomain(db.Task row) {
    return Task(
      id: row.id,
      title: row.title,
      description: row.description,
      status: row.status,
      priority: row.priority,
      dueDate: row.dueDate,
      plannedDate: row.plannedDate,
      deletedAt: row.deletedAt,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      completedAt: row.completedAt,
    );
  }

  TaskHistoryEvent _toHistory(db.TaskHistoryEvent row) {
    return TaskHistoryEvent(
      id: row.id,
      taskId: row.taskId,
      eventType: row.eventType,
      occurredAt: row.occurredAt,
      previousPlannedDate: row.previousPlannedDate,
      newPlannedDate: row.newPlannedDate,
      previousDueDate: row.previousDueDate,
      newDueDate: row.newDueDate,
      previousStatus: row.previousStatus,
      newStatus: row.newStatus,
    );
  }

  String? _normalizeDescription(String? value) {
    if (value == null) return null;
    final String trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  Value<String?> _valueOrNull(String? value) {
    return Value(_normalizeDescription(value));
  }

  DateTime? _resolveCompletedAt({
    required DateTime? existing,
    required tables.TaskStatus newStatus,
    required DateTime now,
  }) {
    if (newStatus == tables.TaskStatus.completed) {
      return existing ?? now;
    }
    return null;
  }
}
