import '../../tasks/domain/task.dart' show Task, TaskPriority, TaskStatus;

// re-export Task types for convenience
export '../../tasks/domain/task.dart' show Task, TaskPriority, TaskStatus;

class TodayTaskSections {
  const TodayTaskSections({
    required this.focus,
    required this.dueToday,
    required this.overdue,
    required this.completedToday,
  });

  final List<Task> focus;
  final List<Task> dueToday;
  final List<Task> overdue;
  final List<Task> completedToday;
}

// Aliases for compatibility
typedef TaskClassification = TodayTaskSections;
typedef TodayDashboardSections = TodayTaskSections;
typedef TodaySections = TodayTaskSections;

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

bool _isCompleted(Task t) => t.status == TaskStatus.completed;

TodayTaskSections classifyTasks(List<Task> tasks, DateTime now) {
  final today = _dateOnly(now);
  final focus = <Task>[];
  final dueToday = <Task>[];
  final overdue = <Task>[];
  final completedToday = <Task>[];

  for (final t in tasks) {
    if (_isCompleted(t)) {
      if (t.completedAt != null && _dateOnly(t.completedAt!) == today) {
        completedToday.add(t);
      }
      continue;
    }
    final due = t.dueDate;
    final dueDateOnly = due == null ? null : _dateOnly(due);
    final isOverdue = dueDateOnly != null && dueDateOnly.isBefore(today);
    if (isOverdue) {
      overdue.add(t);
      continue;
    }
    final isDueToday = dueDateOnly != null && dueDateOnly == today;
    if (t.priority == TaskPriority.high && !isOverdue) {
      focus.add(t);
    } else if (isDueToday) {
      dueToday.add(t);
    }
    // high priority with future/no deadline already in focus; non-high non-due-today? 
  }

  // Ensure tasks due today that are high priority already in focus (not duplicated)
  // Remove any dueToday that ended up in focus
  final focusIds = focus.map((t) => t.id).toSet();
  dueToday.removeWhere((t) => focusIds.contains(t.id));

  // Sort
  focus.sort((a, b) {
    final ad = a.dueDate == null ? null : _dateOnly(a.dueDate!);
    final bd = b.dueDate == null ? null : _dateOnly(b.dueDate!);
    if (ad == null && bd == null) return a.id.compareTo(b.id);
    if (ad == null) return 1;
    if (bd == null) return -1;
    final c = ad.compareTo(bd);
    return c != 0 ? c : a.id.compareTo(b.id);
  });
  dueToday.sort((a, b) {
    final pa = a.priority.index;
    final pb = b.priority.index;
    // higher priority first: high index? TaskPriority order low,medium,high => high index 2. We want high first, so descending
    if (pa != pb) return pb.compareTo(pa);
    return a.id.compareTo(b.id);
  });
  overdue.sort((a, b) {
    final ad = _dateOnly(a.dueDate!);
    final bd = _dateOnly(b.dueDate!);
    final c = ad.compareTo(bd);
    return c != 0 ? c : a.id.compareTo(b.id);
  });
  completedToday.sort((a, b) {
    final ac = a.completedAt!;
    final bc = b.completedAt!;
    final c = bc.compareTo(ac); // newest first
    return c != 0 ? c : a.id.compareTo(b.id);
  });

  return TodayTaskSections(
    focus: focus,
    dueToday: dueToday,
    overdue: overdue,
    completedToday: completedToday,
  );
}

// Alias function names
TodayTaskSections classifyTodayTasks(List<Task> tasks, DateTime now) => classifyTasks(tasks, now);
TodayTaskSections groupTasksForToday(List<Task> tasks, DateTime now) => classifyTasks(tasks, now);
TodayTaskSections groupTasks(List<Task> tasks, DateTime now) => classifyTasks(tasks, now);
TodayTaskSections buildTodaySections(List<Task> tasks, DateTime now) => classifyTasks(tasks, now);
