import '../../tasks/domain/task.dart' show Task, TaskPriority, TaskStatus;

export '../../tasks/domain/task.dart' show Task, TaskPriority, TaskStatus;

class TodayTaskSections {
  const TodayTaskSections({
    required this.plannedToday,
    required this.missedPlans,
    required this.overdue,
    required this.dueToday,
    required this.suggestedForToday,
    required this.upcoming,
    required this.unscheduled,
    required this.completedToday,
  });

  final List<Task> plannedToday;
  final List<Task> missedPlans;
  final List<Task> overdue;
  final List<Task> dueToday;
  final List<Task> suggestedForToday;
  final List<Task> upcoming;
  final List<Task> unscheduled;
  final List<Task> completedToday;

  /// Pending tasks that need attention in today's dashboard.
  List<Task> get relevantTasks => <Task>[
    ...missedPlans,
    ...plannedToday,
    ...overdue,
    ...dueToday,
    ...suggestedForToday,
  ];
}

typedef TaskClassification = TodayTaskSections;
typedef TodayDashboardSections = TodayTaskSections;
typedef TodaySections = TodayTaskSections;

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

int _compareByDateThenId(Task a, Task b, DateTime? dateA, DateTime? dateB) {
  if (dateA == null && dateB == null) return a.id.compareTo(b.id);
  if (dateA == null) return 1;
  if (dateB == null) return -1;
  final int dateComparison = _dateOnly(dateA).compareTo(_dateOnly(dateB));
  return dateComparison != 0 ? dateComparison : a.id.compareTo(b.id);
}

int _compareByPriorityThenId(Task a, Task b) {
  final int priorityComparison = b.priority.index.compareTo(a.priority.index);
  return priorityComparison != 0 ? priorityComparison : a.id.compareTo(b.id);
}

/// Classifies each task into at most one Today category.
///
/// Calendar-day comparisons use the local date components of each [DateTime].
TodayTaskSections classifyTasks(List<Task> tasks, DateTime now) {
  final DateTime today = _dateOnly(now);
  final List<Task> plannedToday = <Task>[];
  final List<Task> missedPlans = <Task>[];
  final List<Task> overdue = <Task>[];
  final List<Task> dueToday = <Task>[];
  final List<Task> suggestedForToday = <Task>[];
  final List<Task> upcoming = <Task>[];
  final List<Task> unscheduled = <Task>[];
  final List<Task> completedToday = <Task>[];

  for (final Task task in tasks) {
    if (task.status == TaskStatus.completed) {
      final DateTime? completedAt = task.completedAt;
      if (completedAt != null && _dateOnly(completedAt) == today) {
        completedToday.add(task);
      }
      continue;
    }

    final DateTime? plannedDate = task.plannedDate == null
        ? null
        : _dateOnly(task.plannedDate!);
    final DateTime? dueDate = task.dueDate == null
        ? null
        : _dateOnly(task.dueDate!);

    if (plannedDate != null && plannedDate.isBefore(today)) {
      missedPlans.add(task);
    } else if (plannedDate == today) {
      plannedToday.add(task);
    } else if (dueDate != null && dueDate.isBefore(today)) {
      overdue.add(task);
    } else if (dueDate == today) {
      dueToday.add(task);
    } else if (plannedDate == null &&
        dueDate == null &&
        task.priority == TaskPriority.high) {
      suggestedForToday.add(task);
    } else if ((plannedDate != null && plannedDate.isAfter(today)) ||
        (dueDate != null && dueDate.isAfter(today))) {
      upcoming.add(task);
    } else {
      unscheduled.add(task);
    }
  }

  plannedToday.sort(
    (Task a, Task b) => _compareByDateThenId(a, b, a.dueDate, b.dueDate),
  );
  missedPlans.sort(
    (Task a, Task b) =>
        _compareByDateThenId(a, b, a.plannedDate, b.plannedDate),
  );
  overdue.sort(
    (Task a, Task b) => _compareByDateThenId(a, b, a.dueDate, b.dueDate),
  );
  dueToday.sort(_compareByPriorityThenId);
  suggestedForToday.sort(_compareByPriorityThenId);
  upcoming.sort((Task a, Task b) {
    final DateTime? dateA = a.plannedDate ?? a.dueDate;
    final DateTime? dateB = b.plannedDate ?? b.dueDate;
    return _compareByDateThenId(a, b, dateA, dateB);
  });
  unscheduled.sort((Task a, Task b) => a.id.compareTo(b.id));
  completedToday.sort((Task a, Task b) {
    final DateTime completedA = a.completedAt!;
    final DateTime completedB = b.completedAt!;
    final int completedComparison = completedB.compareTo(completedA);
    return completedComparison != 0
        ? completedComparison
        : a.id.compareTo(b.id);
  });

  return TodayTaskSections(
    plannedToday: plannedToday,
    missedPlans: missedPlans,
    overdue: overdue,
    dueToday: dueToday,
    suggestedForToday: suggestedForToday,
    upcoming: upcoming,
    unscheduled: unscheduled,
    completedToday: completedToday,
  );
}

TodayTaskSections classifyTodayTasks(List<Task> tasks, DateTime now) =>
    classifyTasks(tasks, now);
TodayTaskSections groupTasksForToday(List<Task> tasks, DateTime now) =>
    classifyTasks(tasks, now);
TodayTaskSections groupTasks(List<Task> tasks, DateTime now) =>
    classifyTasks(tasks, now);
TodayTaskSections buildTodaySections(List<Task> tasks, DateTime now) =>
    classifyTasks(tasks, now);
