import 'dart:async';

import 'package:momentum/features/tasks/domain/task.dart';
import 'package:momentum/features/tasks/domain/task_history_event.dart';
import 'package:momentum/features/tasks/domain/task_repository.dart';

/// An in-memory [TaskRepository] for widget tests.
class FakeTaskRepository implements TaskRepository {
  FakeTaskRepository({
    DateTime Function()? clock,
    List<Task> tasks = const <Task>[],
    List<TaskHistoryEvent> history = const <TaskHistoryEvent>[],
  }) : _clock = clock ?? DateTime.now,
       _tasks = List<Task>.of(tasks),
       _history = List<TaskHistoryEvent>.of(history);

  final DateTime Function() _clock;
  final List<Task> _tasks;
  final List<TaskHistoryEvent> _history;
  final StreamController<List<Task>> _controller =
      StreamController<List<Task>>.broadcast();

  void _emit() => _controller.add(
    List<Task>.unmodifiable(_tasks.where((t) => t.deletedAt == null).toList()),
  );

  @override
  Future<Task> create(TaskDraft draft) async {
    final Task task = Task(
      id: 'fake-${_tasks.length}',
      title: draft.title.trim(),
      description: draft.description?.trim(),
      status: TaskStatus.pending,
      priority: draft.priority,
      dueDate: draft.dueDate,
      plannedDate: draft.plannedDate,
      createdAt: _clock(),
      updatedAt: _clock(),
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
  Future<List<Task>> getAll() async => List<Task>.unmodifiable(
    _tasks.where((t) => t.deletedAt == null).toList(),
  );

  @override
  Stream<List<Task>> watchAll() {
    final StreamController<List<Task>> controller =
        StreamController<List<Task>>();
    // Emit the current state immediately, like Drift's watch().
    controller.add(
      List<Task>.unmodifiable(
        _tasks.where((Task task) => task.deletedAt == null).toList(),
      ),
    );
    final StreamSubscription<List<Task>> subscription = _controller.stream
        .listen(controller.add);
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
    final StreamSubscription<List<Task>> subscription = _controller.stream
        .listen((List<Task> tasks) {
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
    final String newTitle = update.title == null
        ? existing.title
        : update.title!.trim();
    if (newTitle.isEmpty) throw ArgumentError('Task title must not be empty.');

    final Task updated = Task(
      id: existing.id,
      title: newTitle,
      description: update.clearDescription
          ? null
          : (update.description ?? existing.description),
      status: update.status ?? existing.status,
      priority: update.priority ?? existing.priority,
      dueDate: update.clearDueDate
          ? null
          : (update.dueDate ?? existing.dueDate),
      plannedDate: update.clearPlannedDate
          ? null
          : (update.plannedDate ?? existing.plannedDate),
      createdAt: existing.createdAt,
      updatedAt: _clock(),
      completedAt: update.status == TaskStatus.completed
          ? _clock()
          : (update.status == TaskStatus.pending ? null : existing.completedAt),
    );
    _tasks[index] = updated;
    _emit();
    return updated;
  }

  @override
  Future<bool> delete(String id) async {
    final int index = _tasks.indexWhere(
      (Task t) => t.id == id && t.deletedAt == null,
    );
    if (index == -1) return false;
    _tasks[index] = Task(
      id: _tasks[index].id,
      title: _tasks[index].title,
      description: _tasks[index].description,
      status: _tasks[index].status,
      priority: _tasks[index].priority,
      dueDate: _tasks[index].dueDate,
      plannedDate: _tasks[index].plannedDate,
      deletedAt: _clock(),
      createdAt: _tasks[index].createdAt,
      updatedAt: _clock(),
      completedAt: _tasks[index].completedAt,
    );
    _emit();
    return true;
  }

  @override
  Future<Task> complete(String id) async {
    final int index = _tasks.indexWhere((Task t) => t.id == id);
    if (index == -1) throw StateError('Task not found: $id');

    final Task existing = _tasks[index];
    final DateTime now = _clock();
    final Task completed = Task(
      id: existing.id,
      title: existing.title,
      description: existing.description,
      status: TaskStatus.completed,
      priority: existing.priority,
      dueDate: existing.dueDate,
      plannedDate: existing.plannedDate,
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
    final DateTime now = _clock();
    final Task reopened = Task(
      id: existing.id,
      title: existing.title,
      description: existing.description,
      status: TaskStatus.pending,
      priority: existing.priority,
      dueDate: existing.dueDate,
      plannedDate: existing.plannedDate,
      createdAt: existing.createdAt,
      updatedAt: now,
      completedAt: null,
    );
    _tasks[index] = reopened;
    _emit();
    return reopened;
  }

  @override
  Future<List<TaskHistoryEvent>> getHistoryForTask(String id) async =>
      _history.where((TaskHistoryEvent event) => event.taskId == id).toList();

  @override
  Future<List<TaskHistoryEvent>> getAllHistory() async =>
      List<TaskHistoryEvent>.unmodifiable(_history);

  void dispose() => _controller.close();
}
