import 'dart:async';

import 'task.dart';

/// Contract for task persistence.
///
/// Implementations are responsible for validating input, normalising titles,
/// managing timestamps and translating between the domain model and the
/// underlying storage.
abstract class TaskRepository {
  /// Creates a new task from [draft] and returns it.
  ///
  /// Throws [ArgumentError] when the (trimmed) title is empty.
  Future<Task> create(TaskDraft draft);

  /// Returns the task with [id], or `null` when no such task exists.
  Future<Task?> getById(String id);

  /// Returns all tasks, ordered by creation time (newest first).
  Future<List<Task>> getAll();

  /// Returns a stream that emits the current list of tasks (newest first)
  /// whenever the underlying data changes.
  Stream<List<Task>> watchAll();

  /// Returns a stream that emits the task with [id] (or `null`) whenever it
  /// changes.
  Stream<Task?> watchById(String id);

  /// Applies [update] to the task with [id] and returns the updated task.
  ///
  /// Throws [StateError] when no task with [id] exists.
  /// Throws [ArgumentError] when a provided title trims to empty.
  Future<Task> update(String id, TaskUpdate update);

  /// Deletes the task with [id].
  ///
  /// Returns `true` when a task was deleted, `false` when no such task
  /// existed.
  Future<bool> delete(String id);

  /// Marks the task with [id] as completed.
  ///
  /// Sets [Task.completedAt] to the current time and updates [Task.updatedAt].
  ///
  /// Throws [StateError] when no task with [id] exists.
  Future<Task> complete(String id);

  /// Reopens a completed task.
  ///
  /// Clears [Task.completedAt] and sets the status back to pending.
  ///
  /// Throws [StateError] when no task with [id] exists.
  Future<Task> reopen(String id);
}
