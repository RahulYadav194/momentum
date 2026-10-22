import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/core/database/app_database.dart';
import 'package:momentum/core/database/tables/tasks.dart';
import 'package:uuid/uuid.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // The "closing the database" test creates a second AppDatabase instance on
  // purpose; silence the resulting informational warning.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase database;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  group('database initialization', () {
    test('opens and exposes the tasks table', () async {
      // Touching the table forces the schema to be created.
      final List<Task> tasks = await database.select(database.tasks).get();

      expect(tasks, isEmpty);
    });

    test('has schema version 1', () {
      expect(database.schemaVersion, 1);
    });
  });

  group('inserting and reading a task', () {
    test('inserts a task and reads it back', () async {
      final String id = const Uuid().v4();
      final DateTime now = DateTime.now();

      await database.into(database.tasks).insert(
            TasksCompanion.insert(
              id: id,
              title: 'Buy groceries',
              createdAt: now,
              updatedAt: now,
            ),
          );

      final List<Task> tasks = await database.select(database.tasks).get();

      expect(tasks, hasLength(1));
      final Task task = tasks.single;
      expect(task.id, id);
      expect(task.title, 'Buy groceries');
      expect(task.status, TaskStatus.pending);
      expect(task.priority, TaskPriority.medium);
      expect(task.description, isNull);
      expect(task.dueDate, isNull);
      expect(task.completedAt, isNull);
    });

    test('reads a single task by id', () async {
      final String id = const Uuid().v4();
      final DateTime now = DateTime.now();

      await database.into(database.tasks).insert(
            TasksCompanion.insert(
              id: id,
              title: 'Read a book',
              createdAt: now,
              updatedAt: now,
            ),
          );

      final Task? task = await (database.select(database.tasks)
            ..where((Tasks t) => t.id.equals(id)))
          .getSingleOrNull();

      expect(task, isNotNull);
      expect(task!.title, 'Read a book');
    });
  });

  group('updating a task', () {
    test('updates the title and status', () async {
      final String id = const Uuid().v4();
      final DateTime now = DateTime.now();

      await database.into(database.tasks).insert(
            TasksCompanion.insert(
              id: id,
              title: 'Original title',
              createdAt: now,
              updatedAt: now,
            ),
          );

      final DateTime completedAt = DateTime.now();
      await (database.update(database.tasks)
            ..where((Tasks t) => t.id.equals(id)))
          .write(
            TasksCompanion(
              title: const Value('Updated title'),
              status: const Value(TaskStatus.completed),
              completedAt: Value(completedAt),
              updatedAt: Value(completedAt),
            ),
          );

      final Task task = await (database.select(database.tasks)
            ..where((Tasks t) => t.id.equals(id)))
          .getSingle();

      expect(task.title, 'Updated title');
      expect(task.status, TaskStatus.completed);
      expect(task.completedAt, isNotNull);
      expect(task.completedAt!.difference(completedAt).inSeconds.abs(), lessThanOrEqualTo(1));
    });
  });

  group('deleting a task', () {
    test('deletes a task by id', () async {
      final String id = const Uuid().v4();
      final DateTime now = DateTime.now();

      await database.into(database.tasks).insert(
            TasksCompanion.insert(
              id: id,
              title: 'To be deleted',
              createdAt: now,
              updatedAt: now,
            ),
          );

      expect(await database.select(database.tasks).get(), hasLength(1));

      await (database.delete(database.tasks)
            ..where((Tasks t) => t.id.equals(id)))
          .go();

      expect(await database.select(database.tasks).get(), isEmpty);
    });

    test('deleting a missing id does not throw', () async {
      await (database.delete(database.tasks)
            ..where((Tasks t) => t.id.equals('does-not-exist')))
          .go();

      expect(await database.select(database.tasks).get(), isEmpty);
    });
  });

  group('optional fields and defaults', () {
    test('stores description, due date and priority', () async {
      final String id = const Uuid().v4();
      final DateTime now = DateTime.now();
      final DateTime dueDate = now.add(const Duration(days: 3));

      await database.into(database.tasks).insert(
            TasksCompanion.insert(
              id: id,
              title: 'Plan milestone',
              description: const Value('Write the database layer'),
              priority: const Value(TaskPriority.high),
              dueDate: Value(dueDate),
              createdAt: now,
              updatedAt: now,
            ),
          );

      final Task task = await (database.select(database.tasks)
            ..where((Tasks t) => t.id.equals(id)))
          .getSingle();

      expect(task.description, 'Write the database layer');
      expect(task.priority, TaskPriority.high);
      expect(task.dueDate, isNotNull);
      expect(task.dueDate!.difference(dueDate).inSeconds.abs(), lessThanOrEqualTo(1));
    });

    test('defaults status to pending and priority to medium', () async {
      final String id = const Uuid().v4();
      final DateTime now = DateTime.now();

      await database.into(database.tasks).insert(
            TasksCompanion.insert(
              id: id,
              title: 'Defaults check',
              createdAt: now,
              updatedAt: now,
            ),
          );

      final Task task = await (database.select(database.tasks)
            ..where((Tasks t) => t.id.equals(id)))
          .getSingle();

      expect(task.status, TaskStatus.pending);
      expect(task.priority, TaskPriority.medium);
    });
  });

  group('closing the database', () {
    test('closes cleanly without throwing', () async {
      final AppDatabase local = AppDatabase(NativeDatabase.memory());

      // Force the schema to be created before closing.
      await local.select(local.tasks).get();

      await local.close();
    });
  });
}
