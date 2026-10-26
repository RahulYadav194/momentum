import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/core/database/app_database.dart' hide Task;
import 'package:momentum/core/database/tables/task_history_events.dart'
    show TaskHistoryEventType;
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

  test('create with planned date records created and planned events', () async {
    final planned = DateTime(2026, 10, 27);
    final task = await repository.create(
      TaskDraft(title: 'Plan', plannedDate: planned),
    );
    final history = await repository.getHistoryForTask(task.id);
    expect(history.length, 2);
  });

  test('create without planned date records only created event', () async {
    final task = await repository.create(const TaskDraft(title: 'No plan'));
    final history = await repository.getHistoryForTask(task.id);
    expect(history.length, 1);
    expect(history.single.eventType, TaskHistoryEventType.created);
  });

  test('multiple reschedules retain events and id', () async {
    final task = await repository.create(
      TaskDraft(title: 'R', plannedDate: DateTime(2026, 10, 26)),
    );
    final id = task.id;
    await repository.update(
      id,
      TaskUpdate(plannedDate: DateTime(2026, 10, 27)),
    );
    await repository.update(
      id,
      TaskUpdate(plannedDate: DateTime(2026, 10, 28)),
    );
    final updated = await repository.getById(id);
    expect(updated!.plannedDate, DateTime(2026, 10, 28));
    final history = await repository.getHistoryForTask(id);
    final reschedules = history
        .where((e) => e.eventType == TaskHistoryEventType.rescheduled)
        .toList();
    expect(reschedules.length, 2);
  });

  test('unchanged planned date does not create event', () async {
    final task = await repository.create(
      TaskDraft(title: 'U', plannedDate: DateTime(2026, 10, 26)),
    );
    await repository.update(
      task.id,
      TaskUpdate(plannedDate: DateTime(2026, 10, 26)),
    );
    final history = await repository.getHistoryForTask(task.id);
    expect(
      history
          .where((e) => e.eventType == TaskHistoryEventType.rescheduled)
          .length,
      0,
    );
  });

  test('deadline change records previous and new', () async {
    final task = await repository.create(
      TaskDraft(title: 'D', dueDate: DateTime(2026, 10, 26)),
    );
    await repository.update(
      task.id,
      TaskUpdate(dueDate: DateTime(2026, 10, 30)),
    );
    final history = await repository.getHistoryForTask(task.id);
    final dc = history
        .where((e) => e.eventType == TaskHistoryEventType.deadlineChanged)
        .single;
    expect(dc.previousDueDate, DateTime(2026, 10, 26));
    expect(dc.newDueDate, DateTime(2026, 10, 30));
  });

  test('complete and reopen preserve history', () async {
    final task = await repository.create(TaskDraft(title: 'C'));
    await repository.complete(task.id);
    await repository.reopen(task.id);
    final history = await repository.getHistoryForTask(task.id);
    expect(
      history.map((e) => e.eventType),
      contains(TaskHistoryEventType.completed),
    );
    expect(
      history.map((e) => e.eventType),
      contains(TaskHistoryEventType.reopened),
    );
  });

  test('soft delete retains history', () async {
    final task = await repository.create(TaskDraft(title: 'Del'));
    await repository.delete(task.id);
    expect(await repository.getById(task.id), isNull);
    final history = await repository.getHistoryForTask(task.id);
    expect(
      history.map((e) => e.eventType),
      contains(TaskHistoryEventType.deleted),
    );
  });
}
