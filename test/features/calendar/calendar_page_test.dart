import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/app/router.dart';
import 'package:momentum/core/database/tables/task_history_events.dart'
    show TaskHistoryEventType;
import 'package:momentum/features/calendar/calendar_page.dart';
import 'package:momentum/features/calendar/domain/calendar_agenda.dart';
import 'package:momentum/features/tasks/data/task_providers.dart';
import 'package:momentum/features/tasks/domain/task.dart';
import 'package:momentum/features/tasks/domain/task_history_event.dart';

import '../../helpers/fake_task_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final DateTime fixedToday = DateTime(2026, 3, 15, 12);

  Future<void> pumpCalendar(
    WidgetTester tester, {
    FakeTaskRepository? repository,
    ThemeMode themeMode = ThemeMode.light,
    DateTime Function()? clock,
  }) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          taskRepositoryProvider.overrideWithValue(
            repository ?? FakeTaskRepository(),
          ),
        ],
        child: MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.dark,
            ),
          ),
          themeMode: themeMode,
          home: CalendarPage(clock: clock ?? () => fixedToday),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders, navigates months, and returns to today', (
    tester,
  ) async {
    final FakeTaskRepository repository = FakeTaskRepository();
    await pumpCalendar(tester, repository: repository);
    expect(find.text('March 2026'), findsOneWidget);

    await tester.tap(find.byTooltip('Previous month'));
    await tester.pumpAndSettle();
    expect(find.text('February 2026'), findsOneWidget);
    expect(
      tester
          .getSemantics(
            find.byKey(const ValueKey<String>('calendar-date-2026-2-15')),
          )
          .getSemanticsData()
          .flagsCollection
          .isSelected
          .name,
      'isTrue',
    );

    await tester.tap(find.byTooltip('Next month'));
    await tester.pumpAndSettle();
    expect(find.text('March 2026'), findsOneWidget);

    await tester.tap(find.byTooltip('Next month'));
    await tester.pumpAndSettle();
    expect(find.text('April 2026'), findsOneWidget);

    await tester.tap(find.text('Today'));
    await tester.pumpAndSettle();
    expect(find.text('March 2026'), findsOneWidget);
    repository.dispose();
  });

  testWidgets('renders all October 2026 dates in a fixed six-week grid', (
    tester,
  ) async {
    final FakeTaskRepository repository = FakeTaskRepository();
    await pumpCalendar(
      tester,
      repository: repository,
      clock: () => DateTime(2026, 10, 15),
    );

    final Finder grid = find.byKey(
      const ValueKey<String>('calendar-month-grid'),
    );
    final Rect gridRect = tester.getRect(grid);
    final List<DateTime> monthDates = calendarMonthDates(
      DateTime(2026, 10),
    ).where((DateTime date) => date.month == 10).toList();
    expect(monthDates, hasLength(31));
    expect(
      tester.widget<GridView>(grid).childrenDelegate.estimatedChildCount,
      42,
    );
    for (final DateTime date in monthDates) {
      final Rect dateRect = tester.getRect(
        find.byKey(
          ValueKey<String>(
            'calendar-date-${date.year}-${date.month}-${date.day}',
          ),
        ),
      );
      expect(dateRect.top, greaterThanOrEqualTo(gridRect.top));
      expect(dateRect.bottom, lessThanOrEqualTo(gridRect.bottom));
    }

    repository.dispose();
  });

  testWidgets('renders every February 2026 date in the grid', (tester) async {
    final FakeTaskRepository repository = FakeTaskRepository();
    await pumpCalendar(
      tester,
      repository: repository,
      clock: () => DateTime(2026, 2, 15),
    );
    expect(
      tester
          .widget<GridView>(
            find.byKey(const ValueKey<String>('calendar-month-grid')),
          )
          .childrenDelegate
          .estimatedChildCount,
      42,
    );
    expect(
      find.byKey(const ValueKey<String>('calendar-date-2026-2-28')),
      findsOneWidget,
    );
    final Rect gridRect = tester.getRect(
      find.byKey(const ValueKey<String>('calendar-month-grid')),
    );
    for (int day = 1; day <= 28; day++) {
      final Rect dateRect = tester.getRect(
        find.byKey(ValueKey<String>('calendar-date-2026-2-$day')),
      );
      expect(dateRect.top, greaterThanOrEqualTo(gridRect.top));
      expect(dateRect.bottom, lessThanOrEqualTo(gridRect.bottom));
    }
    repository.dispose();
  });

  testWidgets('renders leap day in February 2024', (tester) async {
    final FakeTaskRepository repository = FakeTaskRepository();
    await pumpCalendar(
      tester,
      repository: repository,
      clock: () => DateTime(2024, 2, 15),
    );

    expect(
      tester
          .widget<GridView>(
            find.byKey(const ValueKey<String>('calendar-month-grid')),
          )
          .childrenDelegate
          .estimatedChildCount,
      42,
    );
    expect(
      find.byKey(const ValueKey<String>('calendar-date-2024-2-29')),
      findsOneWidget,
    );
    repository.dispose();
  });

  testWidgets('adjacent dates are muted and selecting one changes month', (
    tester,
  ) async {
    final FakeTaskRepository repository = FakeTaskRepository();
    await pumpCalendar(tester, repository: repository);
    final Finder adjacentDate = find.byKey(
      const ValueKey<String>('calendar-date-2026-2-28'),
    );

    expect(adjacentDate, findsOneWidget);
    await tester.tap(adjacentDate);
    await tester.pumpAndSettle();

    expect(find.text('February 2026'), findsOneWidget);
    expect(
      tester
          .getSemantics(adjacentDate)
          .getSemanticsData()
          .flagsCollection
          .isSelected
          .name,
      'isTrue',
    );
    repository.dispose();
  });

  testWidgets('grid dimensions stay constant across month navigation', (
    tester,
  ) async {
    final FakeTaskRepository repository = FakeTaskRepository();
    await pumpCalendar(tester, repository: repository);
    final Finder grid = find.byKey(
      const ValueKey<String>('calendar-month-grid'),
    );
    final Size marchSize = tester.getSize(grid);

    await tester.tap(find.byTooltip('Previous month'));
    await tester.pumpAndSettle();
    expect(tester.getSize(grid), marchSize);
    expect(marchSize.height, 6 * 42);
    repository.dispose();
  });

  testWidgets('today and selected date are identified accessibly', (
    tester,
  ) async {
    final FakeTaskRepository repository = FakeTaskRepository();
    final SemanticsHandle semantics = tester.ensureSemantics();
    await pumpCalendar(tester, repository: repository);

    final SemanticsData today = tester
        .getSemantics(
          find.byKey(const ValueKey<String>('calendar-date-2026-3-15')),
        )
        .getSemanticsData();
    expect(today.flagsCollection.isSelected.name, 'isTrue');
    expect(today.value, 'Today');

    await tester.tap(find.text('14'));
    await tester.pumpAndSettle();
    final SemanticsData selected = tester
        .getSemantics(
          find.byKey(const ValueKey<String>('calendar-date-2026-3-14')),
        )
        .getSemanticsData();
    expect(selected.flagsCollection.isSelected.name, 'isTrue');

    final SemanticsData unselectedToday = tester
        .getSemantics(
          find.byKey(const ValueKey<String>('calendar-date-2026-3-15')),
        )
        .getSemanticsData();
    expect(unselectedToday.flagsCollection.isSelected.name, 'isFalse');
    expect(unselectedToday.value, 'Today');
    semantics.dispose();
    repository.dispose();
  });

  testWidgets(
    'shows selected-date agenda, status, and deleted history fallback',
    (tester) async {
      final Task planned = _task(
        id: 'planned',
        title: 'Planned today',
        plannedDate: DateTime(2026, 3, 15),
        dueDate: DateTime(2026, 3, 15),
      );
      final Task due = _task(
        id: 'due',
        title: 'Due today',
        dueDate: DateTime(2026, 3, 15),
      );
      final Task completed = _task(
        id: 'completed',
        title: 'Completed task',
        plannedDate: DateTime(2026, 3, 15),
        status: TaskStatus.completed,
      );
      final FakeTaskRepository repository = FakeTaskRepository(
        tasks: <Task>[planned, due, completed],
        history: <TaskHistoryEvent>[
          _completedEvent('completed', DateTime(2026, 3, 15, 14, 23)),
          _completedEvent('deleted-id', DateTime(2026, 3, 15, 15, 7)),
        ],
      );

      await pumpCalendar(tester, repository: repository);

      expect(find.text('Planned'), findsOneWidget);
      expect(find.text('Due'), findsOneWidget);
      expect(find.text('Planned today'), findsOneWidget);
      expect(find.text('Due today'), findsOneWidget);
      expect(
        find.byKey(
          const ValueKey<String>('calendar-planned-indicator-2026-3-15'),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey<String>('calendar-due-indicator-2026-3-15')),
        findsOneWidget,
      );
      expect(
        find.byKey(
          const ValueKey<String>('calendar-history-indicator-2026-3-15'),
        ),
        findsOneWidget,
      );
      final Finder plannedTile = find.ancestor(
        of: find.text('Planned today'),
        matching: find.byType(ListTile),
      );
      final Finder dateSummary = find.descendant(
        of: plannedTile,
        matching: find.textContaining('Plan '),
      );
      expect(dateSummary, findsOneWidget);
      expect(
        tester.widget<Text>(dateSummary).data,
        allOf(contains('Mar 15'), contains('Due')),
      );
      expect(find.text('Completed task'), findsNWidgets(2));
      expect(find.text('Done'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);
      expect(find.text('Deleted task'), findsOneWidget);
      expect(find.textContaining('Completed · 2:23 PM'), findsOneWidget);
      repository.dispose();
    },
  );

  testWidgets('creates a task with the selected date as its plan date', (
    tester,
  ) async {
    final FakeTaskRepository repository = FakeTaskRepository(
      clock: () => fixedToday,
    );
    await pumpCalendar(tester, repository: repository);
    await tester.tap(find.text('Plan task'));
    await tester.pumpAndSettle();

    expect(find.text('Plan 15/3/2026'), findsOneWidget);
    await tester.enterText(
      find.byType(TextFormField).first,
      'New planned task',
    );
    await tester.tap(find.text('Create task'));
    await tester.pumpAndSettle();

    final List<Task> tasks = await repository.getAll();
    expect(tasks.single.title, 'New planned task');
    expect(tasks.single.plannedDate, DateTime(2026, 3, 15));
    repository.dispose();
  });

  testWidgets('completes and reopens tasks through the repository', (
    tester,
  ) async {
    final FakeTaskRepository repository = FakeTaskRepository(
      tasks: <Task>[
        _task(
          id: 'toggle',
          title: 'Toggle me',
          plannedDate: DateTime(2026, 3, 15),
        ),
      ],
      clock: () => fixedToday,
    );
    await pumpCalendar(tester, repository: repository);
    await tester.tap(find.byType(Checkbox).first);
    await tester.pumpAndSettle();
    expect((await repository.getById('toggle'))!.status, TaskStatus.completed);

    await tester.tap(find.byType(Checkbox).first);
    await tester.pumpAndSettle();
    expect((await repository.getById('toggle'))!.status, TaskStatus.pending);
    repository.dispose();
  });

  testWidgets('editing a plan date does not change the due date', (
    tester,
  ) async {
    final Task task = _task(
      id: 'independent-dates',
      title: 'Independent dates',
      plannedDate: DateTime(2026, 3, 15),
      dueDate: DateTime(2026, 3, 20),
    );
    final FakeTaskRepository repository = FakeTaskRepository(
      tasks: <Task>[task],
      clock: () => fixedToday,
    );
    await pumpCalendar(tester, repository: repository);

    await tester.tap(find.text('Independent dates'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Clear plan date'));
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();

    final Task updated = (await repository.getById(task.id))!;
    expect(updated.plannedDate, isNull);
    expect(updated.dueDate, DateTime(2026, 3, 20));
    repository.dispose();
  });

  testWidgets('shows an empty state and renders in dark theme', (tester) async {
    final FakeTaskRepository repository = FakeTaskRepository();
    await pumpCalendar(
      tester,
      repository: repository,
      themeMode: ThemeMode.dark,
    );

    expect(find.text('Nothing scheduled for this date'), findsOneWidget);
    expect(find.text('Plan a task'), findsOneWidget);
    expect(
      Theme.of(tester.element(find.text('Calendar'))).brightness,
      Brightness.dark,
    );
    repository.dispose();
  });

  testWidgets('renders in light theme', (tester) async {
    final FakeTaskRepository repository = FakeTaskRepository();
    await pumpCalendar(tester, repository: repository);

    expect(
      Theme.of(tester.element(find.text('Calendar'))).brightness,
      Brightness.light,
    );
    expect(find.text('Nothing scheduled for this date'), findsOneWidget);
    repository.dispose();
  });

  testWidgets('Calendar history streams completion and reopening from Tasks', (
    tester,
  ) async {
    final DateTime now = DateTime.now();
    final DateTime today = calendarDateOnly(now);
    final FakeTaskRepository repository = FakeTaskRepository(
      tasks: <Task>[
        _task(
          id: 'cross-screen',
          title: 'Update from Tasks',
          plannedDate: today,
        ),
      ],
      clock: () => now,
    );
    await _pumpRoutedApp(tester, repository);

    await _tapDestination(tester, 'Tasks');
    await tester.tap(find.text('Update from Tasks'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.text('Plan ${today.day}/${today.month}/${today.year}'),
    );
    await tester.pumpAndSettle();
    final DateTime nextDate = today.add(const Duration(days: 1));
    await tester.tap(find.text('${nextDate.day}').first);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Save changes'));
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(Checkbox).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Checkbox).first);
    await tester.pumpAndSettle();
    await _tapDestination(tester, 'Today');
    await tester.tap(find.byTooltip('Calendar'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Plan changed ·'), findsOneWidget);
    expect(find.textContaining('Completed ·'), findsOneWidget);
    expect(find.textContaining('Reopened ·'), findsOneWidget);
    expect(
      find.byKey(
        ValueKey<String>(
          'calendar-history-indicator-${today.year}-${today.month}-${today.day}',
        ),
      ),
      findsOneWidget,
    );
    repository.dispose();
  });

  testWidgets('Calendar history streams deletion performed from Tasks', (
    tester,
  ) async {
    final DateTime now = DateTime.now();
    final DateTime today = calendarDateOnly(now);
    final FakeTaskRepository repository = FakeTaskRepository(
      tasks: <Task>[
        _task(
          id: 'deleted-from-tasks',
          title: 'Delete from Tasks',
          plannedDate: today,
        ),
      ],
      clock: () => now,
    );
    await _pumpRoutedApp(tester, repository);

    await _tapDestination(tester, 'Tasks');
    await tester.drag(find.text('Delete from Tasks'), const Offset(-500, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    await _tapDestination(tester, 'Today');
    await tester.tap(find.byTooltip('Calendar'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Deleted ·'), findsOneWidget);
    expect(
      find.byKey(
        ValueKey<String>(
          'calendar-history-indicator-${today.year}-${today.month}-${today.day}',
        ),
      ),
      findsOneWidget,
    );
    repository.dispose();
  });
}

Future<void> _pumpRoutedApp(
  WidgetTester tester,
  FakeTaskRepository repository,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        taskRepositoryProvider.overrideWithValue(repository),
        taskListProvider.overrideWith((Ref ref) => repository.watchAll()),
      ],
      child: MaterialApp.router(routerConfig: createRouter()),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _tapDestination(WidgetTester tester, String label) async {
  await tester.tap(
    find.descendant(of: find.byType(NavigationBar), matching: find.text(label)),
  );
  await tester.pumpAndSettle();
}

Task _task({
  required String id,
  required String title,
  DateTime? plannedDate,
  DateTime? dueDate,
  TaskStatus status = TaskStatus.pending,
}) {
  final DateTime now = DateTime(2026, 3, 1);
  return Task(
    id: id,
    title: title,
    status: status,
    priority: TaskPriority.medium,
    plannedDate: plannedDate,
    dueDate: dueDate,
    createdAt: now,
    updatedAt: now,
    completedAt: status == TaskStatus.completed ? now : null,
  );
}

TaskHistoryEvent _completedEvent(String taskId, DateTime occurredAt) =>
    TaskHistoryEvent(
      id: 'event-$taskId',
      taskId: taskId,
      eventType: TaskHistoryEventType.completed,
      occurredAt: occurredAt,
    );
