import '../../tasks/domain/task.dart';
import '../../tasks/domain/task_history_event.dart';

class CalendarAgenda {
  const CalendarAgenda({
    required this.plannedTasks,
    required this.dueTasks,
    required this.missedTasks,
    required this.historyEvents,
  });

  final List<Task> plannedTasks;
  final List<Task> dueTasks;
  final List<Task> missedTasks;
  final List<TaskHistoryEvent> historyEvents;

  bool get isEmpty =>
      plannedTasks.isEmpty &&
      dueTasks.isEmpty &&
      missedTasks.isEmpty &&
      historyEvents.isEmpty;
}

class CalendarDateIndicators {
  const CalendarDateIndicators({
    required this.hasPlannedTasks,
    required this.hasDueTasks,
    required this.hasHistory,
  });

  final bool hasPlannedTasks;
  final bool hasDueTasks;
  final bool hasHistory;

  bool get hasActivity => hasPlannedTasks || hasDueTasks || hasHistory;
}

DateTime calendarDateOnly(DateTime date) =>
    DateTime(date.year, date.month, date.day);

bool isSameCalendarDate(DateTime? first, DateTime second) =>
    first != null && calendarDateOnly(first) == calendarDateOnly(second);

List<DateTime> calendarMonthDates(DateTime month) {
  final DateTime first = DateTime(month.year, month.month);
  final int offset = first.weekday - DateTime.monday;
  final DateTime firstVisibleDate = DateTime(
    month.year,
    month.month,
    1 - offset,
  );

  return List<DateTime>.generate(
    6 * DateTime.daysPerWeek,
    (int index) => DateTime(
      firstVisibleDate.year,
      firstVisibleDate.month,
      firstVisibleDate.day + index,
    ),
    growable: false,
  );
}

CalendarDateIndicators calendarIndicatorsForDate({
  required DateTime date,
  required List<Task> tasks,
  required List<TaskHistoryEvent> events,
}) {
  return CalendarDateIndicators(
    hasPlannedTasks: tasks.any(
      (Task task) => isSameCalendarDate(task.plannedDate, date),
    ),
    hasDueTasks: tasks.any(
      (Task task) => isSameCalendarDate(task.dueDate, date),
    ),
    hasHistory: events.any(
      (TaskHistoryEvent event) => isSameCalendarDate(event.occurredAt, date),
    ),
  );
}

CalendarAgenda buildCalendarAgenda({
  required DateTime selectedDate,
  required List<Task> tasks,
  required List<TaskHistoryEvent> events,
}) {
  final DateTime date = calendarDateOnly(selectedDate);
  final List<Task> planned = <Task>[];
  final List<Task> due = <Task>[];
  final List<Task> missed = <Task>[];

  final List<Task> orderedTasks = List<Task>.of(tasks)
    ..sort((Task a, Task b) {
      final int titleComparison = a.title.toLowerCase().compareTo(
        b.title.toLowerCase(),
      );
      return titleComparison != 0 ? titleComparison : a.id.compareTo(b.id);
    });

  for (final Task task in orderedTasks) {
    if (isSameCalendarDate(task.plannedDate, date)) {
      planned.add(task);
    } else if (isSameCalendarDate(task.dueDate, date)) {
      due.add(task);
    } else if (!task.isCompleted &&
        task.plannedDate != null &&
        calendarDateOnly(task.plannedDate!).isBefore(date)) {
      missed.add(task);
    }
  }

  final List<TaskHistoryEvent> history =
      events
          .where(
            (TaskHistoryEvent event) =>
                isSameCalendarDate(event.occurredAt, date),
          )
          .toList()
        ..sort(
          (TaskHistoryEvent a, TaskHistoryEvent b) =>
              b.occurredAt.compareTo(a.occurredAt),
        );

  return CalendarAgenda(
    plannedTasks: List<Task>.unmodifiable(planned),
    dueTasks: List<Task>.unmodifiable(due),
    missedTasks: List<Task>.unmodifiable(missed),
    historyEvents: List<TaskHistoryEvent>.unmodifiable(history),
  );
}
