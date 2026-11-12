import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
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

  Future<void> pumpApp(
    WidgetTester tester, {
    Stream<List<Task>> Function()? taskStream,
  }) async {
    final preferences = await createTestPreferences(<String, Object>{});
    await tester.pumpWidget(
      buildTestApp(
        preferences: preferences,
        overrides: <dynamic>[
          taskRepositoryProvider.overrideWithValue(repository),
          taskListProvider.overrideWith(
            (Ref ref) => taskStream?.call() ?? repository.watchAll(),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
    // Navigate to the Tasks tab.
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Tasks'),
      ),
    );
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

  testWidgets('task priority is available through semantic labels', (
    tester,
  ) async {
    await repository.create(
      const TaskDraft(title: 'Low task', priority: TaskPriority.low),
    );
    await repository.create(
      const TaskDraft(title: 'Medium task', priority: TaskPriority.medium),
    );
    await repository.create(
      const TaskDraft(title: 'High task', priority: TaskPriority.high),
    );
    final SemanticsHandle semantics = tester.ensureSemantics();

    await pumpApp(tester);

    for (final (String id, String label) in <(String, String)>[
      ('fake-0', 'Low priority'),
      ('fake-1', 'Medium priority'),
      ('fake-2', 'High priority'),
    ]) {
      expect(
        tester
            .getSemantics(find.byKey(ValueKey<String>('task-priority-$id')))
            .getSemanticsData()
            .label,
        contains(label),
      );
    }

    semantics.dispose();
  });

  testWidgets('task completion and delete actions are named accessibly', (
    tester,
  ) async {
    final Task task = await repository.create(
      const TaskDraft(title: 'Accessible task'),
    );
    final SemanticsHandle semantics = tester.ensureSemantics();

    await pumpApp(tester);

    final SemanticsData checkbox = tester
        .getSemantics(find.byType(Checkbox).first)
        .getSemanticsData();
    expect(checkbox.label, 'Mark Accessible task as complete');
    expect(checkbox.hasAction(SemanticsAction.tap), isTrue);

    final SemanticsNode deleteNode = tester.getSemantics(
      find.byKey(ValueKey<String>('task-actions-${task.id}')),
    );
    final int deleteActionId = CustomSemanticsAction.getIdentifier(
      CustomSemanticsAction(label: 'Delete Accessible task'),
    );
    expect(
      deleteNode.getSemanticsData().customSemanticsActionIds,
      contains(deleteActionId),
    );

    final Dismissible dismissible = tester.widget(
      find.byType(Dismissible).first,
    );
    await dismissible.confirmDismiss!(DismissDirection.endToStart);
    await tester.pumpAndSettle();

    expect(find.text('Delete task?'), findsOneWidget);
    expect((await repository.getById(task.id))!.deletedAt, isNull);

    semantics.dispose();
  });

  testWidgets('task metadata lays out on a narrow screen with large text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await repository.create(
      TaskDraft(
        title: 'A task title that wraps on a narrow display',
        description:
            'Long task details should wrap cleanly without obscuring task '
            'controls or its due date.',
        dueDate: DateTime(2026, 11, 12),
      ),
    );

    await pumpApp(tester);
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(
      find.text('A task title that wraps on a narrow display'),
      findsOneWidget,
    );
    expect(find.text('Due 12/11/2026'), findsOneWidget);
  });

  testWidgets('retry reloads tasks after a stream failure', (tester) async {
    int loadCount = 0;
    await pumpApp(
      tester,
      taskStream: () {
        loadCount++;
        return loadCount == 1
            ? Stream<List<Task>>.error(StateError('temporary failure'))
            : Stream<List<Task>>.value(<Task>[]);
      },
    );

    expect(find.text('Could not load tasks'), findsOneWidget);
    expect(find.textContaining('temporary failure'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(loadCount, 2);
    expect(find.text('No tasks yet'), findsOneWidget);
    expect(find.text('Could not load tasks'), findsNothing);
  });

  testWidgets('quick-add creates a task', (tester) async {
    await pumpApp(tester);

    await tester.enterText(find.byType(TextField), 'Quick task');
    await tester.tap(find.byTooltip('Add task'));
    await tester.pumpAndSettle();

    expect(find.text('Quick task'), findsOneWidget);
    expect(find.text('No tasks yet'), findsNothing);
  });

  testWidgets('successful quick-add dismisses keyboard without refocusing', (
    tester,
  ) async {
    await pumpApp(tester);
    final Finder input = find.byType(TextField);

    await tester.showKeyboard(input);
    await tester.enterText(input, 'Quick task without keyboard');
    expect(tester.testTextInput.isVisible, isTrue);

    await tester.tap(find.byTooltip('Add task'));
    await tester.pumpAndSettle();

    expect(find.text('Quick task without keyboard'), findsOneWidget);
    expect(tester.testTextInput.isVisible, isFalse);
    expect(tester.widget<TextField>(input).focusNode!.hasFocus, isFalse);
    expect(tester.widget<TextField>(input).controller!.text, isEmpty);

    await tester.pump();
    expect(tester.widget<TextField>(input).focusNode!.hasFocus, isFalse);
    expect(tester.testTextInput.isVisible, isFalse);

    await tester.showKeyboard(input);
    expect(tester.widget<TextField>(input).focusNode!.hasFocus, isTrue);
    expect(tester.testTextInput.isVisible, isTrue);
  });

  testWidgets('failed quick-add keeps the task input and error feedback', (
    tester,
  ) async {
    repository = _FailingTaskRepository();
    await pumpApp(tester);
    final Finder input = find.byType(TextField);

    await tester.showKeyboard(input);
    await tester.enterText(input, 'Retry this task');
    await tester.tap(find.byTooltip('Add task'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Create failed'), findsOneWidget);
    expect(tester.widget<TextField>(input).controller!.text, 'Retry this task');
    expect(tester.widget<TextField>(input).focusNode!.hasFocus, isTrue);
    expect(tester.testTextInput.isVisible, isTrue);
  });

  testWidgets(
    'successful detailed task creation closes and dismisses keyboard',
    (tester) async {
      await pumpApp(tester);

      await tester.tap(find.byTooltip('New task with details'));
      await tester.pumpAndSettle();
      final Finder titleInput = find.byType(TextFormField).first;
      expect(tester.testTextInput.isVisible, isTrue);
      await tester.enterText(titleInput, 'Detailed keyboard test');
      await tester.ensureVisible(find.text('Create task'));
      await tester.tap(find.text('Create task'));
      await tester.pumpAndSettle();

      expect(
        (await repository.getAll()).single.title,
        'Detailed keyboard test',
      );
      expect(find.text('New task'), findsNothing);
      expect(find.byType(TextFormField), findsNothing);
      expect(tester.testTextInput.isVisible, isFalse);
      expect(
        tester.widget<TextField>(find.byType(TextField)).focusNode!.hasFocus,
        isFalse,
      );
    },
  );

  testWidgets('failed detailed creation stays open with error feedback', (
    tester,
  ) async {
    repository = _FailingTaskRepository();
    await pumpApp(tester);

    await tester.tap(find.byTooltip('New task with details'));
    await tester.pumpAndSettle();
    final Finder titleInput = find.byType(TextFormField).first;
    await tester.enterText(titleInput, 'Failed detailed task');
    await tester.ensureVisible(find.text('Create task'));
    await tester.tap(find.text('Create task'));
    await tester.pumpAndSettle();

    expect(find.byType(TextFormField), findsWidgets);
    final Finder error = find.textContaining('Create failed');
    expect(error, findsOneWidget);
    await tester.ensureVisible(error);
    expect(
      tester.widget<TextFormField>(titleInput).controller!.text,
      'Failed detailed task',
    );
    expect(tester.testTextInput.isVisible, isTrue);
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

  testWidgets('plan date can be set and cleared without changing due date', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.byTooltip('New task with details'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextFormField).first,
      'Plan independently',
    );

    await tester.tap(find.text('Add plan date'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('10').last);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add due date'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('20').last);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Create task'));
    await tester.tap(find.text('Create task'));
    await tester.pumpAndSettle();

    Task task = (await repository.getAll()).single;
    expect(
      task.plannedDate,
      DateTime(DateTime.now().year, DateTime.now().month, 10),
    );
    expect(
      task.dueDate,
      DateTime(DateTime.now().year, DateTime.now().month, 20),
    );

    await tester.tap(find.text('Plan independently'));
    await tester.pumpAndSettle();
    expect(
      find.text('Plan 10/${DateTime.now().month}/${DateTime.now().year}'),
      findsOneWidget,
    );
    expect(
      find.text('Due 20/${DateTime.now().month}/${DateTime.now().year}'),
      findsWidgets,
    );

    await tester.ensureVisible(find.byTooltip('Clear plan date'));
    await tester.tap(find.byTooltip('Clear plan date'));
    await tester.ensureVisible(find.text('Save changes'));
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();

    task = (await repository.getAll()).single;
    expect(task.plannedDate, isNull);
    expect(
      task.dueDate,
      DateTime(DateTime.now().year, DateTime.now().month, 20),
    );
  });

  testWidgets('completing a task toggles its state', (tester) async {
    final Task task = await repository.create(
      const TaskDraft(title: 'Toggle me'),
    );

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

class _FailingTaskRepository extends FakeTaskRepository {
  @override
  Future<Task> create(TaskDraft draft) async {
    throw StateError('Create failed');
  }
}
