import 'dart:async';

import 'package:momentum/features/tasks/domain/task.dart';
import 'package:momentum/features/tasks/domain/task_repository.dart';

/// An in-memory [TaskRepository] for widget tests.
class FakeTaskRepository implements TaskRepository {
  final List<Task> _tasks = <Task>[];
  final StreamController<List<Task>> _controller =
      StreamController<List<Task>>.broadcast();

  void _emit() => _controller.add(List<Task>.unmodifiable(_tasks));

  @override
  Future<Task> create(TaskDraft draft) async {
    final Task task = Task(
      id: 'fake-${_tasks.length}',
      title: draft.title.trim(),
      description: draft.description?.trim(),
      status: TaskStatus.pending,
      priority: draft.priority,
      dueDate: draft.dueDate,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _tasks.insert(0, task);
    _emit();
    return task;
  }

  @override
  Future<Task?> getById(String id) async {
    for (final Task t in _tasks) {
      if (t.id == id) return t;
    }
    return null;
  }

  @override
  Future<List<Task>> getAll() async => List<Task>.unmodifiable(_tasks);

  @override
  Stream<List<Task>> watchAll() {
    final StreamController<List<Task>> controller =
        StreamController<List<Task>>();
    // Emit the current state immediately, like Drift's watch().
    controller.add(List<Task>.unmodifiable(_tasks));
    final StreamSubscription<List<Task>> subscription =
        _controller.stream.listen(controller.add);
    controller.onCancel = () => subscription.cancel();
    return controller.stream;
  }

  @override
  Stream<Task?> watchById(String id) {
    final StreamController<Task?> controller = StreamController<Task?>();
    Task? findTask(List<Task> tasks) {
      for (final Task t in tasks) {
        if (t.id == id) return t;
      }
      return null;
    }

    controller.add(findTask(_tasks));
    final StreamSubscription<List<Task>> subscription =
        _controller.stream.listen((List<Task> tasks) {
      controller.add(findTask(tasks));
    });
    controller.onCancel = () => subscription.cancel();
    return controller.stream;
  }

  @override
  Future<Task> update(String id, TaskUpdate update) async {
    final int index = _tasks.indexWhere((Task t) => t.id == id);
    if (index == -1) throw StateError('Task not found: $id');

    final Task existing = _tasks[index];
    final String newTitle =
        update.title == null ? existing.title : update.title!.trim();
    if (newTitle.isEmpty) throw ArgumentError('Task title must not be empty.');

    final Task updated = Task(
      id: existing.id,
      title: newTitle,
      description: update.clearDescription
          ? null
          : (update.description ?? existing.description),
      status: update.status ?? existing.status,
      priority: update.priority ?? existing.priority,
      dueDate: update.clearDueDate ? null : (update.dueDate ?? existing.dueDate),
      createdAt: existing.createdAt,
      updatedAt: DateTime.now(),
      completedAt: update.status == TaskStatus.completed
          ? DateTime.now()
          : (update.status == TaskStatus.pending ? null : existing.completedAt),
    );
    _tasks[index] = updated;
    _emit();
    return updated;
  }

  @override
  Future<bool> delete(String id) async {
    final int before = _tasks.length;
    _tasks.removeWhere((Task t) => t.id == id);
    final bool deleted = _tasks.length < before;
    if (deleted) _emit();
    return deleted;
  }

  @override
  Future<Task> complete(String id) async {
    final int index = _tasks.indexWhere((Task t) => t.id == id);
    if (index == -1) throw StateError('Task not found: $id');

    final Task existing = _tasks[index];
    final DateTime now = DateTime.now();
    final Task completed = Task(
      id: existing.id,
      title: existing.title,
      description: existing.description,
      status: TaskStatus.completed,
      priority: existing.priority,
      dueDate: existing.dueDate,
      createdAt: existing.createdAt,
      updatedAt: now,
      completedAt: now,
    );
    _tasks[index] = completed;
    _emit();
    return completed;
  }

  @override
  Future<Task> reopen(String id) async {
    final int index = _tasks.indexWhere((Task t) => t.id == id);
    if (index == -1) throw StateError('Task not found: $id');

    final Task existing = _tasks[index];
    final DateTime now = DateTime.now();
    final Task reopened = Task(
      id: existing.id,
      title: existing.title,
      description: existing.description,
      status: TaskStatus.pending,
      priority: existing.priority,
      dueDate: existing.dueDate,
      createdAt: existing.createdAt,
      updatedAt: now,
      completedAt: null,
    );
    _tasks[index] = reopened;
    _emit();
    return reopened;
  }

  void dispose() => _controller.close();
}
