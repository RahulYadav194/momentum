import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../tasks/data/task_providers.dart';
import '../tasks/domain/task.dart';
import '../tasks/domain/task_history_event.dart';
import '../tasks/domain/task_repository.dart';
import '../tasks/presentation/task_form_sheet.dart';
import 'domain/calendar_agenda.dart';

final calendarHistoryProvider = FutureProvider<List<TaskHistoryEvent>>((
  ref,
) async {
  final TaskRepository repository = ref.watch(taskRepositoryProvider);
  return repository.getAllHistory();
});

String _titleFor(String id, List<Task> tasks) {
  for (final Task task in tasks) {
    if (task.id == id) return task.title;
  }
  return 'Deleted task';
}

class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key, this.clock});

  final DateTime Function()? clock;

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  late DateTime _month;
  late DateTime _selected;

  DateTime get _now => widget.clock?.call() ?? DateTime.now();

  void _changeMonth(int offset) {
    final DateTime month = DateTime(_month.year, _month.month + offset);
    final int lastDay = DateTime(month.year, month.month + 1, 0).day;
    final int day = _selected.day < lastDay ? _selected.day : lastDay;
    setState(() {
      _month = month;
      _selected = DateTime(month.year, month.month, day);
    });
  }

  @override
  void initState() {
    super.initState();
    final DateTime today = calendarDateOnly(_now);
    _month = DateTime(today.year, today.month);
    _selected = today;
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<TaskHistoryEvent>> historyAsync = ref.watch(
      calendarHistoryProvider,
    );
    final AsyncValue<List<Task>> tasksAsync = ref.watch(taskListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Calendar')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createTask,
        icon: const Icon(Icons.add),
        label: const Text('Plan task'),
      ),
      body: historyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace _) => _LoadError(
          message: 'Unable to load calendar history: $error',
          onRetry: () => ref.invalidate(calendarHistoryProvider),
        ),
        data: (List<TaskHistoryEvent> events) => tasksAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (Object error, StackTrace _) => _LoadError(
            message: 'Unable to load tasks: $error',
            onRetry: () => ref.invalidate(taskListProvider),
          ),
          data: (List<Task> tasks) => _buildCalendar(context, tasks, events),
        ),
      ),
    );
  }

  Widget _buildCalendar(
    BuildContext context,
    List<Task> tasks,
    List<TaskHistoryEvent> events,
  ) {
    final List<DateTime> dates = calendarMonthDates(_month);
    final CalendarAgenda agenda = buildCalendarAgenda(
      selectedDate: _selected,
      tasks: tasks,
      events: events,
    );

    return Column(
      children: <Widget>[
        _MonthHeader(
          month: _month,
          onPrev: () => _changeMonth(-1),
          onNext: () => _changeMonth(1),
          onToday: () {
            final DateTime today = calendarDateOnly(_now);
            setState(() {
              _month = DateTime(today.year, today.month);
              _selected = today;
            });
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: const <Widget>[
              Expanded(child: Center(child: Text('Mon'))),
              Expanded(child: Center(child: Text('Tue'))),
              Expanded(child: Center(child: Text('Wed'))),
              Expanded(child: Center(child: Text('Thu'))),
              Expanded(child: Center(child: Text('Fri'))),
              Expanded(child: Center(child: Text('Sat'))),
              Expanded(child: Center(child: Text('Sun'))),
            ],
          ),
        ),
        SizedBox(
          height: 6 * _CalendarDateCell.extent,
          child: GridView.builder(
            key: const ValueKey<String>('calendar-month-grid'),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: DateTime.daysPerWeek,
              mainAxisExtent: _CalendarDateCell.extent,
            ),
            itemCount: dates.length,
            itemBuilder: (BuildContext context, int index) {
              final DateTime date = dates[index];
              return _CalendarDateCell(
                date: date,
                today: _now,
                selected: _selected,
                isInDisplayedMonth:
                    date.year == _month.year && date.month == _month.month,
                indicators: calendarIndicatorsForDate(
                  date: date,
                  tasks: tasks,
                  events: events,
                ),
                onSelect: () => setState(() {
                  _selected = date;
                  _month = DateTime(date.year, date.month);
                }),
              );
            },
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: _DayAgenda(
            selectedDate: _selected,
            agenda: agenda,
            tasks: tasks,
            onCreate: _createTask,
            onEdit: _editTask,
            onToggle: _toggleTask,
          ),
        ),
      ],
    );
  }

  Future<void> _createTask() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (BuildContext context) => TaskFormSheet(
        initialPlannedDate: _selected,
        onSave:
            ({
              required String title,
              String? description,
              required TaskPriority priority,
              DateTime? dueDate,
              DateTime? plannedDate,
            }) async {
              await ref
                  .read(taskRepositoryProvider)
                  .create(
                    TaskDraft(
                      title: title,
                      description: description,
                      priority: priority,
                      dueDate: dueDate,
                      plannedDate: plannedDate,
                    ),
                  );
              ref.invalidate(calendarHistoryProvider);
            },
      ),
    );
  }

  Future<void> _editTask(Task task) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (BuildContext context) => TaskFormSheet(
        initialTask: task,
        onSave:
            ({
              required String title,
              String? description,
              required TaskPriority priority,
              DateTime? dueDate,
              DateTime? plannedDate,
            }) async {
              await ref
                  .read(taskRepositoryProvider)
                  .update(
                    task.id,
                    TaskUpdate(
                      title: title,
                      description: description,
                      clearDescription: description == null,
                      priority: priority,
                      dueDate: dueDate,
                      clearDueDate: dueDate == null && task.dueDate != null,
                      plannedDate: plannedDate,
                      clearPlannedDate:
                          plannedDate == null && task.plannedDate != null,
                    ),
                  );
              ref.invalidate(calendarHistoryProvider);
            },
      ),
    );
  }

  Future<void> _toggleTask(Task task, bool completed) async {
    try {
      final TaskRepository repository = ref.read(taskRepositoryProvider);
      if (completed) {
        await repository.complete(task.id);
      } else {
        await repository.reopen(task.id);
      }
      ref.invalidate(calendarHistoryProvider);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not update task: $error')),
        );
      }
    }
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.error_outline, size: 40),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          FilledButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    ),
  );
}

class _MonthHeader extends StatelessWidget {
  const _MonthHeader({
    required this.month,
    required this.onPrev,
    required this.onNext,
    required this.onToday,
  });

  final DateTime month;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onToday;

  @override
  Widget build(BuildContext context) {
    const List<String> names = <String>[
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: <Widget>[
          IconButton(
            onPressed: onPrev,
            tooltip: 'Previous month',
            icon: const Icon(Icons.chevron_left),
          ),
          Expanded(
            child: Center(
              child: Text(
                '${names[month.month - 1]} ${month.year}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
          IconButton(
            onPressed: onNext,
            tooltip: 'Next month',
            icon: const Icon(Icons.chevron_right),
          ),
          TextButton(onPressed: onToday, child: const Text('Today')),
        ],
      ),
    );
  }
}

class _CalendarDateCell extends StatelessWidget {
  const _CalendarDateCell({
    required this.date,
    required this.today,
    required this.selected,
    required this.isInDisplayedMonth,
    required this.indicators,
    required this.onSelect,
  });

  static const double extent = 42;

  final DateTime date;
  final DateTime today;
  final DateTime selected;
  final bool isInDisplayedMonth;
  final CalendarDateIndicators indicators;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final bool isToday = isSameCalendarDate(today, date);
    final bool isSelected = isSameCalendarDate(selected, date);
    final String fullDate = MaterialLocalizations.of(
      context,
    ).formatFullDate(date);

    return Semantics(
      key: ValueKey<String>(
        'calendar-date-${date.year}-${date.month}-${date.day}',
      ),
      label: fullDate,
      value: isToday ? 'Today' : null,
      button: true,
      selected: isSelected,
      onTap: onSelect,
      child: ExcludeSemantics(
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onSelect,
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isSelected ? colors.primaryContainer : null,
              shape: BoxShape.circle,
              border: isToday ? Border.all(color: colors.primary) : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  '${date.day}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: isSelected || isToday
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: !isInDisplayedMonth
                        ? colors.onSurfaceVariant.withAlpha(120)
                        : isSelected
                        ? colors.onPrimaryContainer
                        : null,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    if (indicators.hasPlannedTasks)
                      _ActivityDot(
                        key: ValueKey<String>(
                          'calendar-planned-indicator-${date.year}-${date.month}-${date.day}',
                        ),
                        color: colors.primary,
                      ),
                    if (indicators.hasDueTasks)
                      _ActivityDot(
                        key: ValueKey<String>(
                          'calendar-due-indicator-${date.year}-${date.month}-${date.day}',
                        ),
                        color: colors.error,
                      ),
                    if (indicators.hasHistory)
                      _ActivityDot(
                        key: ValueKey<String>(
                          'calendar-history-indicator-${date.year}-${date.month}-${date.day}',
                        ),
                        color: colors.onSurfaceVariant,
                        outlined: true,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActivityDot extends StatelessWidget {
  const _ActivityDot({super.key, required this.color, this.outlined = false});

  final Color color;
  final bool outlined;

  @override
  Widget build(BuildContext context) => Container(
    width: 5,
    height: 5,
    margin: const EdgeInsets.symmetric(horizontal: 1),
    decoration: BoxDecoration(
      color: outlined ? null : color,
      border: outlined ? Border.all(color: color) : null,
      shape: BoxShape.circle,
    ),
  );
}

class _DayAgenda extends StatelessWidget {
  const _DayAgenda({
    required this.selectedDate,
    required this.agenda,
    required this.tasks,
    required this.onCreate,
    required this.onEdit,
    required this.onToggle,
  });

  final DateTime selectedDate;
  final CalendarAgenda agenda;
  final List<Task> tasks;
  final VoidCallback onCreate;
  final ValueChanged<Task> onEdit;
  final void Function(Task task, bool completed) onToggle;

  @override
  Widget build(BuildContext context) {
    final MaterialLocalizations localizations = MaterialLocalizations.of(
      context,
    );

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  localizations.formatFullDate(selectedDate),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              if (!agenda.isEmpty)
                Text(
                  '${agenda.plannedTasks.length + agenda.dueTasks.length + agenda.missedTasks.length} tasks',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
        ),
        Expanded(
          child: agenda.isEmpty
              ? _AgendaEmptyState(onCreate: onCreate)
              : ListView(
                  padding: const EdgeInsets.only(bottom: 88),
                  children: <Widget>[
                    _taskSection(
                      context,
                      title: 'Planned',
                      icon: Icons.event_note_outlined,
                      tasks: agenda.plannedTasks,
                    ),
                    _taskSection(
                      context,
                      title: 'Due',
                      icon: Icons.flag_outlined,
                      tasks: agenda.dueTasks,
                    ),
                    _taskSection(
                      context,
                      title: 'Missed plans',
                      icon: Icons.history_toggle_off,
                      tasks: agenda.missedTasks,
                    ),
                    if (agenda.historyEvents.isNotEmpty)
                      _historySection(context),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _taskSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Task> tasks,
  }) {
    if (tasks.isEmpty) return const SizedBox.shrink();
    final ColorScheme colors = Theme.of(context).colorScheme;
    final Color color = title == 'Due' ? colors.error : colors.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Row(
            children: <Widget>[
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(title, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(width: 6),
              Text(
                '${tasks.length}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        ...tasks.map(
          (Task task) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            child: Card(
              color: color.withAlpha(14),
              child: ListTile(
                dense: true,
                onTap: () => onEdit(task),
                leading: Checkbox(
                  value: task.isCompleted,
                  onChanged: (bool? value) => onToggle(task, value ?? false),
                ),
                title: Text(
                  task.title,
                  style: task.isCompleted
                      ? const TextStyle(decoration: TextDecoration.lineThrough)
                      : null,
                ),
                subtitle: Text(_taskDateSummary(task, context)),
                trailing: Text(
                  task.isCompleted ? 'Done' : 'Open',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: task.isCompleted ? colors.onSurfaceVariant : color,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _taskDateSummary(Task task, BuildContext context) {
    final MaterialLocalizations localizations = MaterialLocalizations.of(
      context,
    );
    final List<String> dates = <String>[];
    if (task.plannedDate != null) {
      dates.add('Plan ${localizations.formatMediumDate(task.plannedDate!)}');
    }
    if (task.dueDate != null) {
      dates.add('Due ${localizations.formatMediumDate(task.dueDate!)}');
    }
    return dates.join('  ·  ');
  }

  Widget _historySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: <Widget>[
              Icon(
                Icons.history,
                size: 18,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text('History', style: Theme.of(context).textTheme.titleSmall),
            ],
          ),
        ),
        ...agenda.historyEvents.map((TaskHistoryEvent event) {
          final String title = _titleFor(event.taskId, tasks);
          final String label = switch (event.eventType.name) {
            'created' => 'Created',
            'planned' => 'Planned',
            'rescheduled' => 'Plan changed',
            'deadlineChanged' => 'Deadline changed',
            'completed' => 'Completed',
            'reopened' => 'Reopened',
            'deleted' => 'Deleted',
            _ => 'Activity',
          };
          final TimeOfDay time = TimeOfDay(
            hour: event.occurredAt.hour,
            minute: event.occurredAt.minute,
          );
          return ListTile(
            dense: true,
            leading: const Icon(Icons.history, size: 18),
            title: Text(
              '$label · ${MaterialLocalizations.of(context).formatTimeOfDay(time)}',
            ),
            subtitle: Text(title),
          );
        }),
      ],
    );
  }
}

class _AgendaEmptyState extends StatelessWidget {
  const _AgendaEmptyState({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.event_available_outlined, size: 32),
          const SizedBox(height: 8),
          const Text('Nothing scheduled for this date'),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: onCreate,
            icon: const Icon(Icons.add),
            label: const Text('Plan a task'),
          ),
        ],
      ),
    ),
  );
}
