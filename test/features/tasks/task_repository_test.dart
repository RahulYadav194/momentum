import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/core/database/app_database.dart' hide Task;
import 'package:momentum/features/tasks/data/drift_task_repository.dart';
import 'package:momentum/features/tasks/domain/task.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase database;
  late DriftTaskRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = DriftTaskRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  group('create', () {
    test('creates a task with normalized title and defaults', () async {
      final Task task = await repository.create(
        const TaskDraft(title: '  Buy groceries  '),
      );

      expect(task.title, 'Buy groceries');
      expect(task.status, TaskStatus.pending);
      expect(task.priority, TaskPriority.medium);
      expect(task.description, isNull);
      expect(task.dueDate, isNull);
      expect(task.completedAt, isNull);
      expect(task.createdAt, isNotNull);
      expect(task.updatedAt, task.createdAt);
    });

    test('creates a task with all optional fields', () async {
      final DateTime dueDate = DateTime(2026, 12, 25);
      final Task task = await repository.create(
        TaskDraft(
          title: 'Plan holiday',
          description: '  Book flights  ',
          priority: TaskPriority.high,
          dueDate: dueDate,
        ),
      );

      expect(task.title, 'Plan holiday');
      expect(task.description, 'Book flights');
      expect(task.priority, TaskPriority.high);
      expect(task.dueDate, dueDate);
    });

    test('rejects an empty title', () async {
      expect(
        () => repository.create(const TaskDraft(title: '')),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('rejects a whitespace-only title', () async {
      expect(
        () => repository.create(const TaskDraft(title: '   ')),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('trims surrounding whitespace from the description', () async {
      final Task task = await repository.create(
        const TaskDraft(title: 'Task', description: '  spaced  '),
      );

      expect(task.description, 'spaced');
    });

    test('converts a blank description to null', () async {
      final Task task = await repository.create(
        const TaskDraft(title: 'Task', description: '   '),
      );

      expect(task.description, isNull);
    });
  });

  group('getById', () {
    test('returns the task when it exists', () async {
      final Task created = await repository.create(
        const TaskDraft(title: 'Find me'),
      );

      final Task? found = await repository.getById(created.id);

      expect(found, isNotNull);
      expect(found!.id, created.id);
      expect(found.title, 'Find me');
    });

    test('returns null for a nonexistent id', () async {
      final Task? found = await repository.getById('does-not-exist');

      expect(found, isNull);
    });
  });

  group('getAll and watchAll', () {
    test('returns tasks newest first', () async {
      final Task first = await repository.create(
        const TaskDraft(title: 'First'),
      );
      // Ensure a distinct creation time at second-level precision (Drift
      // stores DateTime as Unix seconds).
      await Future<void>.delayed(const Duration(seconds: 1, milliseconds: 100));
      final Task second = await repository.create(
        const TaskDraft(title: 'Second'),
      );

      final List<Task> tasks = await repository.getAll();

      expect(tasks, hasLength(2));
      expect(tasks.first.id, second.id);
      expect(tasks.last.id, first.id);
    });

    test('watchAll emits updates when a task is added', () async {
      final List<List<Task>> emissions = <List<Task>>[];
      final StreamSubscription<List<Task>> subscription =
          repository.watchAll().listen(emissions.add);

      await repository.create(const TaskDraft(title: 'Streamed'));
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(emissions, isNotEmpty);
      expect(emissions.last, hasLength(1));
      expect(emissions.last.single.title, 'Streamed');

      await subscription.cancel();
    });
  });

  group('update', () {
    test('updates the title and trims it', () async {
      final Task created = await repository.create(
        const TaskDraft(title: 'Original'),
      );

      final Task updated = await repository.update(
        created.id,
        const TaskUpdate(title: '  Renamed  '),
      );

      expect(updated.title, 'Renamed');
      expect(updated.updatedAt.isAfter(created.updatedAt) ||
          updated.updatedAt == created.updatedAt, isTrue);
    });

    test('rejects an empty updated title', () async {
      final Task created = await repository.create(
        const TaskDraft(title: 'Original'),
      );

      expect(
        () => repository.update(created.id, const TaskUpdate(title: '')),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('updates priority and due date', () async {
      final Task created = await repository.create(
        const TaskDraft(title: 'Task'),
      );
      final DateTime dueDate = DateTime(2026, 12, 31);

      final Task updated = await repository.update(
        created.id,
        TaskUpdate(priority: TaskPriority.high, dueDate: dueDate),
      );

      expect(updated.priority, TaskPriority.high);
      expect(updated.dueDate, dueDate);
    });

    test('clears the description with the flag', () async {
      final Task created = await repository.create(
        const TaskDraft(title: 'Task', description: 'Has a description'),
      );

      final Task updated = await repository.update(
        created.id,
        const TaskUpdate(clearDescription: true),
      );

      expect(updated.description, isNull);
    });

    test('clears the due date with the flag', () async {
      final Task created = await repository.create(
        TaskDraft(title: 'Task', dueDate: DateTime(2026, 12, 31)),
      );

      final Task updated = await repository.update(
        created.id,
        const TaskUpdate(clearDueDate: true),
      );

      expect(updated.dueDate, isNull);
    });

    test('throws StateError for a nonexistent id', () async {
      expect(
        () => repository.update('missing', const TaskUpdate(title: 'X')),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('delete', () {
    test('deletes an existing task', () async {
      final Task created = await repository.create(
        const TaskDraft(title: 'Delete me'),
      );

      final bool deleted = await repository.delete(created.id);

      expect(deleted, isTrue);
      expect(await repository.getById(created.id), isNull);
    });

    test('returns false for a nonexistent id', () async {
      final bool deleted = await repository.delete('missing');

      expect(deleted, isFalse);
    });
  });

  group('complete and reopen', () {
    test('complete sets status and completedAt', () async {
      final Task created = await repository.create(
        const TaskDraft(title: 'Finish me'),
      );

      final Task completed = await repository.complete(created.id);

      expect(completed.isCompleted, isTrue);
      expect(completed.completedAt, isNotNull);
      expect(completed.updatedAt.isAfter(created.updatedAt) ||
          completed.updatedAt == created.updatedAt, isTrue);
    });

    test('reopen clears completedAt and resets status', () async {
      final Task created = await repository.create(
        const TaskDraft(title: 'Reopen me'),
      );
      await repository.complete(created.id);

      final Task reopened = await repository.reopen(created.id);

      expect(reopened.isCompleted, isFalse);
      expect(reopened.completedAt, isNull);
      expect(reopened.status, TaskStatus.pending);
    });

    test('complete throws StateError for a nonexistent id', () async {
      expect(
        () => repository.complete('missing'),
        throwsA(isA<StateError>()),
      );
    });

    test('reopen throws StateError for a nonexistent id', () async {
      expect(
        () => repository.reopen('missing'),
        throwsA(isA<StateError>()),
      );
    });

    test('watchById emits the updated task after completion', () async {
      final Task created = await repository.create(
        const TaskDraft(title: 'Watch me'),
      );

      final List<Task?> emissions = <Task?>[];
      final StreamSubscription<Task?> subscription =
          repository.watchById(created.id).listen(emissions.add);

      await repository.complete(created.id);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(emissions, isNotEmpty);
      expect(emissions.last, isNotNull);
      expect(emissions.last!.isCompleted, isTrue);

      await subscription.cancel();
    });
  });
}
