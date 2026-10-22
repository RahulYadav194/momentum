import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart' as db;
import '../../../core/database/tables/tasks.dart' as tables;
import '../domain/task.dart';
import '../domain/task_repository.dart';

/// Drift-backed implementation of [TaskRepository].
class DriftTaskRepository implements TaskRepository {
  DriftTaskRepository(this._database);

  final db.AppDatabase _database;

  static const Uuid _uuid = Uuid();

  @override
  Future<Task> create(TaskDraft draft) async {
    final String title = draft.title.trim();
    if (title.isEmpty) {
      throw ArgumentError('Task title must not be empty.');
    }

    final DateTime now = DateTime.now();
    final String id = _uuid.v4();

    await _database.into(_database.tasks).insert(
          db.TasksCompanion.insert(
            id: id,
            title: title,
            description: _valueOrNull(draft.description?.trim()),
            status: const Value(tables.TaskStatus.pending),
            priority: Value(draft.priority),
            dueDate: Value(draft.dueDate),
            createdAt: now,
            updatedAt: now,
          ),
        );

    return Task(
      id: id,
      title: title,
      description: _normalizeDescription(draft.description),
      status: tables.TaskStatus.pending,
      priority: draft.priority,
      dueDate: draft.dueDate,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Future<Task?> getById(String id) async {
    final db.Task? row = await (_database.select(_database.tasks)
          ..where((tables.Tasks t) => t.id.equals(id)))
        .getSingleOrNull();

    return row == null ? null : _toDomain(row);
  }

  @override
  Future<List<Task>> getAll() async {
    final List<db.Task> rows = await (_database.select(_database.tasks)
          ..orderBy([
            (tables.Tasks t) => OrderingTerm.desc(t.createdAt),
            (tables.Tasks t) => OrderingTerm.desc(t.id),
          ]))
        .get();

    return rows.map(_toDomain).toList();
  }

  @override
  Stream<List<Task>> watchAll() {
    return (_database.select(_database.tasks)
          ..orderBy([
            (tables.Tasks t) => OrderingTerm.desc(t.createdAt),
            (tables.Tasks t) => OrderingTerm.desc(t.id),
          ]))
        .watch()
        .map((List<db.Task> rows) => rows.map(_toDomain).toList());
  }

  @override
  Stream<Task?> watchById(String id) {
    return (_database.select(_database.tasks)
          ..where((tables.Tasks t) => t.id.equals(id)))
        .watchSingleOrNull()
        .map((db.Task? row) => row == null ? null : _toDomain(row));
  }

  @override
  Future<Task> update(String id, TaskUpdate update) async {
    final db.Task? existing = await (_database.select(_database.tasks)
          ..where((tables.Tasks t) => t.id.equals(id)))
        .getSingleOrNull();

    if (existing == null) {
      throw StateError('Task not found: $id');
    }

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

    await (_database.update(_database.tasks)
          ..where((tables.Tasks t) => t.id.equals(id)))
        .write(
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
        completedAt: Value(newCompletedAt),
        updatedAt: Value(now),
      ),
    );

    return Task(
      id: existing.id,
      title: newTitle ?? existing.title,
      description: update.clearDescription
          ? null
          : (update.description ?? existing.description),
      status: newStatus,
      priority: update.priority ?? existing.priority,
      dueDate: update.clearDueDate ? null : (update.dueDate ?? existing.dueDate),
      createdAt: existing.createdAt,
      updatedAt: now,
      completedAt: newCompletedAt,
    );
  }

  @override
  Future<bool> delete(String id) async {
    final int deleted = await (_database.delete(_database.tasks)
          ..where((tables.Tasks t) => t.id.equals(id)))
        .go();

    return deleted > 0;
  }

  @override
  Future<Task> complete(String id) async {
    final db.Task? existing = await (_database.select(_database.tasks)
          ..where((tables.Tasks t) => t.id.equals(id)))
        .getSingleOrNull();

    if (existing == null) {
      throw StateError('Task not found: $id');
    }

    final DateTime now = DateTime.now();

    await (_database.update(_database.tasks)
          ..where((tables.Tasks t) => t.id.equals(id)))
        .write(
      db.TasksCompanion(
        status: const Value(tables.TaskStatus.completed),
        completedAt: Value(now),
        updatedAt: Value(now),
      ),
    );

    return Task(
      id: existing.id,
      title: existing.title,
      description: existing.description,
      status: tables.TaskStatus.completed,
      priority: existing.priority,
      dueDate: existing.dueDate,
      createdAt: existing.createdAt,
      updatedAt: now,
      completedAt: now,
    );
  }

  @override
  Future<Task> reopen(String id) async {
    final db.Task? existing = await (_database.select(_database.tasks)
          ..where((tables.Tasks t) => t.id.equals(id)))
        .getSingleOrNull();

    if (existing == null) {
      throw StateError('Task not found: $id');
    }

    final DateTime now = DateTime.now();

    await (_database.update(_database.tasks)
          ..where((tables.Tasks t) => t.id.equals(id)))
        .write(
      db.TasksCompanion(
        status: const Value(tables.TaskStatus.pending),
        completedAt: const Value(null),
        updatedAt: Value(now),
      ),
    );

    return Task(
      id: existing.id,
      title: existing.title,
      description: existing.description,
      status: tables.TaskStatus.pending,
      priority: existing.priority,
      dueDate: existing.dueDate,
      createdAt: existing.createdAt,
      updatedAt: now,
      completedAt: null,
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Task _toDomain(db.Task row) {
    return Task(
      id: row.id,
      title: row.title,
      description: row.description,
      status: row.status,
      priority: row.priority,
      dueDate: row.dueDate,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      completedAt: row.completedAt,
    );
  }

  /// Returns the description value to store, or `null` when absent/blank.
  String? _normalizeDescription(String? value) {
    if (value == null) return null;
    final String trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  /// Converts an optional description to a Drift [Value], treating blank
  /// strings as `null`.
  Value<String?> _valueOrNull(String? value) {
    return Value(_normalizeDescription(value));
  }

  /// Determines the new [completedAt] value when updating a task.
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
