import 'dart:async';

import 'task.dart';
import 'task_history_event.dart';

/// Contract for task persistence.
abstract class TaskRepository {
  Future<Task> create(TaskDraft draft);
  Future<Task?> getById(String id);
  Future<List<Task>> getAll();
  Stream<List<Task>> watchAll();
  Stream<Task?> watchById(String id);
  Future<Task> update(String id, TaskUpdate update);
  Future<bool> delete(String id);
  Future<Task> complete(String id);
  Future<Task> reopen(String id);
  Future<List<TaskHistoryEvent>> getHistoryForTask(String id);
  Future<List<TaskHistoryEvent>> getAllHistory();
  Stream<List<TaskHistoryEvent>> watchAllHistory();
}
