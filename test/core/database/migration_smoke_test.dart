import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/core/database/app_database.dart' hide Task;
import 'package:momentum/core/database/tables/task_history_events.dart'
    show TaskHistoryEventType;
import 'package:momentum/core/database/tables/tasks.dart' show TaskStatus;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('migrates the original v1 task schema and preserves its data', () async {
    final AppDatabase database = AppDatabase(_versionOneDatabase());
    addTearDown(database.close);

    final tasks = await database.select(database.tasks).get();
    expect(tasks, hasLength(1));
    final task = tasks.single;
    expect(task.id, 'legacy-v1');
    expect(task.title, 'Completed legacy task');
    expect(task.status, TaskStatus.completed);
    expect(task.priority.name, 'high');
    expect(task.dueDate, DateTime(2026, 12, 31));
    expect(task.plannedDate, isNull);
    expect(task.deletedAt, isNull);
    expect(task.completedAt, DateTime(2026, 10, 25, 16));

    expect(await database.select(database.taskHistoryEvents).get(), isEmpty);
    await _expectHistoryIndexes(database);
  });

  test('migrates the supported v2 schema and preserves task history', () async {
    final AppDatabase database = AppDatabase(_versionTwoDatabase());
    addTearDown(database.close);

    final tasks = await database.select(database.tasks).get();
    expect(tasks, hasLength(1));
    final task = tasks.single;
    expect(task.id, 'legacy-v2');
    expect(task.title, 'Planned legacy task');
    expect(task.status, TaskStatus.pending);
    expect(task.dueDate, DateTime(2026, 11, 2));
    expect(task.plannedDate, DateTime(2026, 10, 26));
    expect(task.deletedAt, isNull);
    expect(task.completedAt, isNull);

    final List<TaskHistoryEvent> events = await database
        .select(database.taskHistoryEvents)
        .get();
    expect(events, hasLength(1));
    expect(events.single.id, 'legacy-v2-event');
    expect(events.single.taskId, task.id);
    expect(events.single.eventType, TaskHistoryEventType.planned);
    expect(events.single.occurredAt, DateTime(2026, 10, 20, 9));
    expect(events.single.previousPlannedDate, isNull);
    expect(events.single.newPlannedDate, DateTime(2026, 10, 26));
    expect(events.single.previousDueDate, isNull);
    expect(events.single.newDueDate, DateTime(2026, 11, 2));

    await _expectHistoryIndexes(database);
  });

  test('fresh databases have the current schema and history indexes', () async {
    final AppDatabase database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    expect(database.schemaVersion, 3);
    expect(await database.select(database.tasks).get(), isEmpty);
    expect(await database.select(database.taskHistoryEvents).get(), isEmpty);
    await _expectHistoryIndexes(database);
  });
}

drift.QueryExecutor _versionOneDatabase() {
  return NativeDatabase.memory(
    setup: (database) {
      database.execute('''
        CREATE TABLE tasks (
          id TEXT NOT NULL PRIMARY KEY,
          title TEXT NOT NULL,
          description TEXT,
          status TEXT NOT NULL DEFAULT 'pending',
          priority TEXT NOT NULL DEFAULT 'medium',
          due_date INTEGER,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL,
          completed_at INTEGER
        )
      ''');
      database.execute(
        '''
        INSERT INTO tasks (
          id, title, status, priority, due_date, created_at, updated_at,
          completed_at
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        ''',
        <Object?>[
          'legacy-v1',
          'Completed legacy task',
          'completed',
          'high',
          _dateSeconds(DateTime(2026, 12, 31)),
          _dateSeconds(DateTime(2026, 10, 20, 9)),
          _dateSeconds(DateTime(2026, 10, 25, 16)),
          _dateSeconds(DateTime(2026, 10, 25, 16)),
        ],
      );
      database.execute('PRAGMA user_version = 1');
    },
  );
}

drift.QueryExecutor _versionTwoDatabase() {
  return NativeDatabase.memory(
    setup: (database) {
      database.execute('''
        CREATE TABLE tasks (
          id TEXT NOT NULL PRIMARY KEY,
          title TEXT NOT NULL,
          description TEXT,
          status TEXT NOT NULL DEFAULT 'pending',
          priority TEXT NOT NULL DEFAULT 'medium',
          due_date INTEGER,
          planned_date INTEGER,
          deleted_at INTEGER,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL,
          completed_at INTEGER
        )
      ''');
      database.execute('''
        CREATE TABLE task_history_events (
          id TEXT NOT NULL PRIMARY KEY,
          task_id TEXT NOT NULL,
          event_type TEXT NOT NULL,
          occurred_at INTEGER NOT NULL,
          previous_planned_date INTEGER,
          new_planned_date INTEGER,
          previous_due_date INTEGER,
          new_due_date INTEGER,
          previous_status TEXT,
          new_status TEXT
        )
      ''');
      database.execute(
        '''
        INSERT INTO tasks (
          id, title, status, priority, due_date, planned_date, created_at,
          updated_at
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        ''',
        <Object?>[
          'legacy-v2',
          'Planned legacy task',
          'pending',
          'medium',
          _dateSeconds(DateTime(2026, 11, 2)),
          _dateSeconds(DateTime(2026, 10, 26)),
          _dateSeconds(DateTime(2026, 10, 20, 9)),
          _dateSeconds(DateTime(2026, 10, 20, 9)),
        ],
      );
      database.execute(
        '''
        INSERT INTO task_history_events (
          id, task_id, event_type, occurred_at, new_planned_date, new_due_date
        ) VALUES (?, ?, ?, ?, ?, ?)
        ''',
        <Object?>[
          'legacy-v2-event',
          'legacy-v2',
          'planned',
          _dateSeconds(DateTime(2026, 10, 20, 9)),
          _dateSeconds(DateTime(2026, 10, 26)),
          _dateSeconds(DateTime(2026, 11, 2)),
        ],
      );
      database.execute('PRAGMA user_version = 2');
    },
  );
}

Future<void> _expectHistoryIndexes(AppDatabase database) async {
  final List<String> indexes = await database
      .customSelect("SELECT name FROM sqlite_master WHERE type = 'index'")
      .map((row) => row.read<String>('name'))
      .get();

  expect(indexes, contains('idx_task_history_events_task_id'));
  expect(indexes, contains('idx_task_history_events_occurred_at'));
}

int _dateSeconds(DateTime date) => date.millisecondsSinceEpoch ~/ 1000;
