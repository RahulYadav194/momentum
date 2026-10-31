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

  Future<void> pumpToday(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          taskRepositoryProvider.overrideWithValue(repository),
          taskListProvider.overrideWith((Ref ref) => repository.watchAll()),
          todayClockProvider.overrideWithValue(() => today),
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
}
