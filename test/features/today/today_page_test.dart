import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/features/tasks/data/task_providers.dart';
import 'package:momentum/features/tasks/domain/task.dart';
import 'package:momentum/features/today/today_page.dart';

import '../../helpers/fake_task_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final DateTime today = DateTime(2026, 10, 26, 14, 30);
  late FakeTaskRepository repository;

  setUp(() {
    repository = FakeTaskRepository(clock: () => today);
  });

  tearDown(() {
    repository.dispose();
  });

  Future<void> pumpToday(
    WidgetTester tester, {
    DateTime Function()? clock,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          taskRepositoryProvider.overrideWithValue(repository),
          taskListProvider.overrideWith((Ref ref) => repository.watchAll()),
          todayClockProvider.overrideWithValue(clock ?? () => today),
        ],
        child: const MaterialApp(home: TodayPage()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows current date and meaningful progress for today tasks', (
    tester,
  ) async {
    await repository.create(
      TaskDraft(
        title: 'Planned and due',
        plannedDate: DateTime(2026, 10, 26),
        dueDate: DateTime(2026, 10, 26),
      ),
    );
    await repository.create(
      TaskDraft(title: 'Completed today', plannedDate: DateTime(2026, 10, 25)),
    );
    await repository.complete('fake-1');

    await pumpToday(tester);

    expect(find.text('Monday, October 26, 2026'), findsOneWidget);
    expect(find.text('Planned Today'), findsOneWidget);
    expect(find.text('Completed Today'), findsOneWidget);
    expect(find.text('1 of 2 relevant tasks completed today'), findsOneWidget);
    expect(find.text('Planned and due'), findsOneWidget);
  });

  testWidgets('shows missed plan actions and Keep leaves its date unchanged', (
    tester,
  ) async {
    final Task task = await repository.create(
      TaskDraft(
        title: 'Missed task',
        plannedDate: DateTime(2026, 10, 25),
        dueDate: DateTime(2026, 10, 24),
      ),
    );

    await pumpToday(tester);

    expect(find.text('Missed Plans'), findsOneWidget);
    expect(find.text('Reschedule'), findsOneWidget);
    expect(find.text('Keep in Missed Plans'), findsOneWidget);
    expect(find.text('Remove Plan Date'), findsOneWidget);
    expect(find.text('Due 24/10/2026'), findsOneWidget);

    await tester.tap(find.text('Keep in Missed Plans'));
    await tester.pumpAndSettle();

    expect(find.text('Missed Plans'), findsOneWidget);
    expect(
      (await repository.getById(task.id))!.plannedDate,
      DateTime(2026, 10, 25),
    );
    expect(
      (await repository.getById(task.id))!.dueDate,
      DateTime(2026, 10, 24),
    );
  });

  testWidgets('rescheduling a missed task persists the new plan date', (
    tester,
  ) async {
    final Task task = await repository.create(
      TaskDraft(title: 'Move me', plannedDate: DateTime(2026, 10, 25)),
    );

    await pumpToday(tester);
    await tester.tap(find.text('Reschedule'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('28').last);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(
      (await repository.getById(task.id))!.plannedDate,
      DateTime(2026, 10, 28),
    );
    expect(find.text('Missed Plans'), findsNothing);
    expect(find.text('Upcoming'), findsOneWidget);
    expect(find.text('Move me'), findsOneWidget);
  });

  testWidgets('removing a missed plan date keeps task and due date', (
    tester,
  ) async {
    final DateTime dueDate = DateTime(2026, 11, 2);
    final Task task = await repository.create(
      TaskDraft(
        title: 'Keep my deadline',
        plannedDate: DateTime(2026, 10, 25),
        dueDate: dueDate,
      ),
    );

    await pumpToday(tester);
    await tester.tap(find.text('Remove Plan Date'));
    await tester.pumpAndSettle();

    final Task updated = (await repository.getById(task.id))!;
    expect(updated.plannedDate, isNull);
    expect(updated.dueDate, dueDate);
    expect(updated.deletedAt, isNull);
    expect(find.text('Missed Plans'), findsNothing);
    expect(find.text('Upcoming'), findsOneWidget);
  });

  testWidgets('completing and reopening a missed task reclassifies it', (
    tester,
  ) async {
    final Task task = await repository.create(
      TaskDraft(
        title: 'Complete or reopen',
        plannedDate: DateTime(2026, 10, 25),
      ),
    );

    await pumpToday(tester);
    await tester.tap(find.byType(Checkbox).first);
    await tester.pumpAndSettle();

    expect((await repository.getById(task.id))!.isCompleted, isTrue);
    expect(find.text('Missed Plans'), findsNothing);
    expect(find.text('Completed Today'), findsOneWidget);

    await tester.tap(find.byType(Checkbox).first);
    await tester.pumpAndSettle();

    expect((await repository.getById(task.id))!.isCompleted, isFalse);
    expect(find.text('Missed Plans'), findsOneWidget);
    expect(find.text('Completed Today'), findsNothing);
  });

  testWidgets('tapping a Today task opens the existing edit form', (
    tester,
  ) async {
    await repository.create(
      TaskDraft(title: 'Edit from Today', plannedDate: DateTime(2026, 10, 26)),
    );

    await pumpToday(tester);
    await tester.tap(find.text('Edit from Today'));
    await tester.pumpAndSettle();

    expect(find.text('Edit task'), findsOneWidget);
    expect(find.text('Plan 26/10/2026'), findsOneWidget);
    expect(find.text('Save changes'), findsOneWidget);
  });

  testWidgets('empty Today still displays the current date and quick add', (
    tester,
  ) async {
    await pumpToday(tester);

    expect(find.text('Monday, October 26, 2026'), findsOneWidget);
    expect(find.text('Nothing planned for today'), findsOneWidget);
    expect(find.byTooltip('Add task'), findsOneWidget);
  });

  testWidgets('swiping a task asks for confirmation before deleting', (
    tester,
  ) async {
    final Task task = await repository.create(
      TaskDraft(title: 'Swipe to delete', plannedDate: DateTime(2026, 10, 26)),
    );
    await pumpToday(tester);

    await tester.drag(find.text(task.title), const Offset(-500, 0));
    await tester.pumpAndSettle();

    expect(find.text('Delete task?'), findsOneWidget);
    expect((await repository.getById(task.id))!.deletedAt, isNull);

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect((await repository.getById(task.id))!.deletedAt, isNotNull);
    expect(find.text(task.title), findsNothing);
    expect(find.text('Task deleted'), findsOneWidget);
    expect(
      (await repository.getHistoryForTask(task.id)).last.eventType.name,
      'deleted',
    );
  });

  testWidgets('cancelling Today swipe deletion keeps the task', (tester) async {
    final Task task = await repository.create(
      TaskDraft(title: 'Keep this task', plannedDate: DateTime(2026, 10, 26)),
    );
    await pumpToday(tester);

    await tester.drag(find.text(task.title), const Offset(-500, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text(task.title), findsOneWidget);
    expect((await repository.getById(task.id))!.deletedAt, isNull);
  });

  testWidgets('Today reports deletion failures', (tester) async {
    repository.dispose();
    final _FailingDeleteRepository failingRepository = _FailingDeleteRepository(
      clock: () => today,
    );
    repository = failingRepository;
    final Task task = await repository.create(
      TaskDraft(title: 'Delete fails', plannedDate: DateTime(2026, 10, 26)),
    );
    await pumpToday(tester);

    await tester.drag(find.text(task.title), const Offset(-500, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Could not delete task: Bad state: delete failed'),
      findsOneWidget,
    );
    expect((await repository.getById(task.id))!.deletedAt, isNull);
  });

  testWidgets('Today refreshes its date and sections at local midnight', (
    tester,
  ) async {
    DateTime currentTime = DateTime(2026, 10, 26, 23, 59);
    await repository.create(
      TaskDraft(
        title: 'Planned yesterday',
        plannedDate: DateTime(2026, 10, 26),
      ),
    );
    await pumpToday(tester, clock: () => currentTime);

    expect(find.text('Monday, October 26, 2026'), findsOneWidget);
    expect(find.text('Planned Today'), findsOneWidget);

    currentTime = DateTime(2026, 10, 27);
    await tester.pump(const Duration(minutes: 1));

    expect(find.text('Tuesday, October 27, 2026'), findsOneWidget);
    expect(find.text('Missed Plans'), findsOneWidget);
    expect(find.text('Planned Today'), findsNothing);
  });

  testWidgets('Today refreshes date and sections when the app resumes', (
    tester,
  ) async {
    DateTime currentTime = DateTime(2026, 10, 26, 14, 30);
    await repository.create(
      TaskDraft(
        title: 'Planned before background',
        plannedDate: DateTime(2026, 10, 26),
      ),
    );
    await pumpToday(tester, clock: () => currentTime);

    expect(find.text('Planned Today'), findsOneWidget);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    currentTime = DateTime(2026, 10, 27, 8);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();

    expect(find.text('Tuesday, October 27, 2026'), findsOneWidget);
    expect(find.text('Missed Plans'), findsOneWidget);
    expect(find.text('Planned Today'), findsNothing);
  });
}

class _FailingDeleteRepository extends FakeTaskRepository {
  _FailingDeleteRepository({required super.clock});

  @override
  Future<bool> delete(String id) => throw StateError('delete failed');
}
