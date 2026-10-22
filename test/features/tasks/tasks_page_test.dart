import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/features/tasks/data/task_providers.dart';
import 'package:momentum/features/tasks/domain/task.dart';

import '../../helpers/fake_task_repository.dart';
import '../../helpers/test_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeTaskRepository repository;

  setUp(() {
    repository = FakeTaskRepository();
  });

  tearDown(() {
    repository.dispose();
  });

  Future<void> pumpApp(WidgetTester tester) async {
    final preferences = await createTestPreferences(<String, Object>{});
    await tester.pumpWidget(
      buildTestApp(
        preferences: preferences,
        overrides: <dynamic>[
          taskRepositoryProvider.overrideWithValue(repository),
          taskListProvider.overrideWith((Ref ref) => repository.watchAll()),
        ],
      ),
    );
    await tester.pumpAndSettle();
    // Navigate to the Tasks tab.
    await tester.tap(find.descendant(
      of: find.byType(NavigationBar),
      matching: find.text('Tasks'),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('shows empty state when there are no tasks', (tester) async {
    await pumpApp(tester);

    expect(find.text('No tasks yet'), findsOneWidget);
  });

  testWidgets('shows tasks from the repository', (tester) async {
    await repository.create(const TaskDraft(title: 'First task'));
    await repository.create(const TaskDraft(title: 'Second task'));

    await pumpApp(tester);

    expect(find.text('First task'), findsOneWidget);
    expect(find.text('Second task'), findsOneWidget);
  });

  testWidgets('quick-add creates a task', (tester) async {
    await pumpApp(tester);

    await tester.enterText(find.byType(TextField), 'Quick task');
    await tester.tap(find.byTooltip('Add task'));
    await tester.pumpAndSettle();

    expect(find.text('Quick task'), findsOneWidget);
    expect(find.text('No tasks yet'), findsNothing);
  });

  testWidgets('quick-add rejects blank titles', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.byTooltip('Add task'));
    await tester.pumpAndSettle();

    expect(find.text('Title is required'), findsOneWidget);
    final tasks = await repository.getAll();
    expect(tasks, isEmpty);
  });

  testWidgets('tapping a task opens the edit form', (tester) async {
    await repository.create(const TaskDraft(title: 'Editable'));

    await pumpApp(tester);

    await tester.tap(find.text('Editable'));
    await tester.pumpAndSettle();

    expect(find.text('Edit task'), findsOneWidget);
    expect(find.text('Save changes'), findsOneWidget);
  });

  testWidgets('completing a task toggles its state', (tester) async {
    final Task task = await repository.create(const TaskDraft(title: 'Toggle me'));

    await pumpApp(tester);

    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();

    final Task? updated = await repository.getById(task.id);
    expect(updated!.isCompleted, isTrue);
  });

  testWidgets('deleting a task requires confirmation', (tester) async {
    await repository.create(const TaskDraft(title: 'Delete me'));

    await pumpApp(tester);

    // Swipe to delete.
    await tester.drag(find.text('Delete me'), const Offset(-500, 0));
    await tester.pumpAndSettle();

    // Confirmation dialog should appear.
    expect(find.text('Delete task?'), findsOneWidget);

    // Cancel.
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Delete me'), findsOneWidget);
  });

  testWidgets('confirming deletion removes the task', (tester) async {
    await repository.create(const TaskDraft(title: 'Gone'));

    await pumpApp(tester);

    await tester.drag(find.text('Gone'), const Offset(-500, 0));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Gone'), findsNothing);
    expect(find.text('No tasks yet'), findsOneWidget);
  });
}
