import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/core/database/tables/task_history_events.dart'
    show TaskHistoryEventType;
import 'package:momentum/features/calendar/domain/calendar_agenda.dart';
import 'package:momentum/features/tasks/domain/task.dart';
import 'package:momentum/features/tasks/domain/task_history_event.dart';

void main() {
  group('calendarMonthDates', () {
    test(
      'always generates six Monday-first weeks including adjacent dates',
      () {
        final List<DateTime> october = calendarMonthDates(DateTime(2026, 10));
        final List<DateTime> february = calendarMonthDates(DateTime(2026, 2));
        final List<DateTime> leapFebruary = calendarMonthDates(
          DateTime(2024, 2),
        );

        expect(october, hasLength(42));
        expect(october.first, DateTime(2026, 9, 28));
        expect(october[3], DateTime(2026, 10, 1));
        expect(october[33], DateTime(2026, 10, 31));
        expect(october.last, DateTime(2026, 11, 8));

        expect(february, hasLength(42));
        expect(february.first, DateTime(2026, 1, 26));
        expect(february[6], DateTime(2026, 2, 1));
        expect(february[33], DateTime(2026, 2, 28));
        expect(february.last, DateTime(2026, 3, 8));

        expect(leapFebruary, hasLength(42));
        expect(leapFebruary[3], DateTime(2024, 2, 1));
        expect(leapFebruary[31], DateTime(2024, 2, 29));
      },
    );

    test('four-, five-, and six-week calendar months all use 42 cells', () {
      for (final DateTime month in <DateTime>[
        DateTime(2021, 2),
        DateTime(2026, 2),
        DateTime(2026, 10),
      ]) {
        expect(calendarMonthDates(month), hasLength(42));
      }
    });
  });

  test('distinguishes planned, due, and historical activity indicators', () {
    final DateTime date = DateTime(2026, 3, 15);
    final Task task = _task(
      id: 'both',
      title: 'Both dates',
      plannedDate: DateTime(2026, 3, 15, 18),
      dueDate: DateTime(2026, 3, 15, 23),
    );
    final CalendarDateIndicators indicators = calendarIndicatorsForDate(
      date: date,
      tasks: <Task>[task],
      events: <TaskHistoryEvent>[_historyEvent(date)],
    );
    final CalendarDateIndicators noIndicators = calendarIndicatorsForDate(
      date: DateTime(2026, 3, 16),
      tasks: <Task>[task],
      events: <TaskHistoryEvent>[],
    );

    expect(indicators.hasPlannedTasks, isTrue);
    expect(indicators.hasDueTasks, isTrue);
    expect(indicators.hasHistory, isTrue);
    expect(noIndicators.hasActivity, isFalse);
  });

  test(
    'keeps plan and due dates independent and avoids duplicate agenda tasks',
    () {
      final DateTime selected = DateTime(2026, 3, 15);
      final Task differentDates = _task(
        id: 'different',
        title: 'Plan earlier, due today',
        plannedDate: DateTime(2026, 3, 12),
        dueDate: selected,
      );
      final Task sameDate = _task(
        id: 'same',
        title: 'Plan and due today',
        plannedDate: selected,
        dueDate: DateTime(2026, 3, 15, 20),
      );
      final Task missed = _task(
        id: 'missed',
        title: 'Missed plan',
        plannedDate: DateTime(2026, 3, 10),
      );

      final CalendarAgenda agenda = buildCalendarAgenda(
        selectedDate: selected,
        tasks: <Task>[differentDates, sameDate, missed],
        events: <TaskHistoryEvent>[],
      );

      expect(agenda.plannedTasks, <Task>[sameDate]);
      expect(agenda.dueTasks, <Task>[differentDates]);
      expect(agenda.missedTasks, <Task>[missed]);
      expect(
        <Task>[
          ...agenda.plannedTasks,
          ...agenda.dueTasks,
          ...agenda.missedTasks,
        ].map((Task task) => task.id).toSet(),
        hasLength(3),
      );
    },
  );

  test('shows future planned tasks on their selected date', () {
    final Task futureTask = _task(
      id: 'future',
      title: 'Future plan',
      plannedDate: DateTime(2026, 3, 25),
    );

    final CalendarAgenda agenda = buildCalendarAgenda(
      selectedDate: DateTime(2026, 3, 25),
      tasks: <Task>[futureTask],
      events: <TaskHistoryEvent>[],
    );

    expect(agenda.plannedTasks, <Task>[futureTask]);
    expect(agenda.dueTasks, isEmpty);
    expect(agenda.missedTasks, isEmpty);
  });

  test('shows historical activity by actual occurrence date', () {
    final TaskHistoryEvent completed = _historyEvent(
      DateTime(2026, 3, 15, 16, 42),
      taskId: 'deleted-id',
      eventType: TaskHistoryEventType.completed,
    );
    final CalendarAgenda agenda = buildCalendarAgenda(
      selectedDate: DateTime(2026, 3, 15),
      tasks: <Task>[],
      events: <TaskHistoryEvent>[
        completed,
        _historyEvent(DateTime(2026, 3, 16), taskId: 'other'),
      ],
    );

    expect(agenda.historyEvents, <TaskHistoryEvent>[completed]);
    expect(
      agenda.historyEvents.single.occurredAt,
      DateTime(2026, 3, 15, 16, 42),
    );
  });
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

TaskHistoryEvent _historyEvent(
  DateTime occurredAt, {
  String taskId = 'task-id',
  TaskHistoryEventType eventType = TaskHistoryEventType.created,
}) => TaskHistoryEvent(
  id: 'event-${occurredAt.millisecondsSinceEpoch}-$taskId',
  taskId: taskId,
  eventType: eventType,
  occurredAt: occurredAt,
);
