import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../tasks/data/task_providers.dart';
import '../tasks/domain/task.dart';
import '../tasks/domain/task_history_event.dart';

final calendarHistoryProvider = FutureProvider<List<TaskHistoryEvent>>((
  ref,
) async {
  final repo = ref.watch(taskRepositoryProvider);
  return repo.getAllHistory();
});

String _titleFor(String id, List<Task> tasks) {
  for (final Task t in tasks) {
    if (t.id == id) return t.title;
  }
  return 'Deleted task';
}

class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime _selected = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(calendarHistoryProvider);
    final tasksAsync = ref.watch(taskListProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Calendar')),
      body: historyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, StackTrace _) => Center(child: Text('Error: $e')),
        data: (List<TaskHistoryEvent> events) {
          return tasksAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (Object e, StackTrace _) => Center(child: Text('Error: $e')),
            data: (List<Task> tasks) {
              return Column(
                children: <Widget>[
                  _MonthHeader(
                    month: _month,
                    onPrev: () => setState(
                      () => _month = DateTime(_month.year, _month.month - 1),
                    ),
                    onNext: () => setState(
                      () => _month = DateTime(_month.year, _month.month + 1),
                    ),
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
                  Expanded(
                    child: _MonthGrid(
                      month: _month,
                      selected: _selected,
                      events: events,
                      onSelect: (DateTime d) => setState(() => _selected = d),
                    ),
                  ),
                  Expanded(
                    child: _DayDetails(
                      selected: _selected,
                      events: events,
                      tasks: tasks,
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _MonthHeader extends StatelessWidget {
  const _MonthHeader({
    required this.month,
    required this.onPrev,
    required this.onNext,
  });
  final DateTime month;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    const names = <String>[
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
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          IconButton(onPressed: onPrev, icon: const Icon(Icons.chevron_left)),
          Text(
            names[month.month - 1] + ' ' + month.year.toString(),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          IconButton(onPressed: onNext, icon: const Icon(Icons.chevron_right)),
        ],
      ),
    );
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.month,
    required this.selected,
    required this.events,
    required this.onSelect,
  });
  final DateTime month;
  final DateTime selected;
  final List<TaskHistoryEvent> events;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final first = DateTime(month.year, month.month, 1);
    final startWeekday = first.weekday - 1;
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final total = startWeekday + daysInMonth;
    final rows = (total / 7).ceil();
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
      ),
      itemCount: rows * 7,
      itemBuilder: (BuildContext context, int index) {
        final dayNumber = index - startWeekday + 1;
        if (dayNumber < 1 || dayNumber > daysInMonth) {
          return const SizedBox.shrink();
        }
        final date = DateTime(month.year, month.month, dayNumber);
        final hasActivity =
            events.any((TaskHistoryEvent e) {
              final DateTime d = e.occurredAt;
              return d.year == date.year &&
                  d.month == date.month &&
                  d.day == date.day;
            }) ||
            events.any((TaskHistoryEvent e) {
              final DateTime? d = e.newPlannedDate ?? e.previousPlannedDate;
              return d != null &&
                  d.year == date.year &&
                  d.month == date.month &&
                  d.day == date.day;
            }) ||
            events.any((TaskHistoryEvent e) {
              final DateTime? d = e.newDueDate ?? e.previousDueDate;
              return d != null &&
                  d.year == date.year &&
                  d.month == date.month &&
                  d.day == date.day;
            });
        final isSelected =
            selected.year == date.year &&
            selected.month == date.month &&
            selected.day == date.day;
        return GestureDetector(
          onTap: () => onSelect(date),
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primaryContainer
                  : null,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('$dayNumber'),
                if (hasActivity)
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DayDetails extends StatelessWidget {
  const _DayDetails({
    required this.selected,
    required this.events,
    required this.tasks,
  });
  final DateTime selected;
  final List<TaskHistoryEvent> events;
  final List<Task> tasks;

  bool _same(DateTime? d) =>
      d != null &&
      d.year == selected.year &&
      d.month == selected.month &&
      d.day == selected.day;

  @override
  Widget build(BuildContext context) {
    final plannedIds = <String>{};
    final movedAwayIds = <String>{};
    final completedIds = <String>{};
    final deadlineIds = <String>{};

    for (final TaskHistoryEvent e in events) {
      if (_same(e.newPlannedDate) &&
          (e.eventType.name == 'planned' ||
              e.eventType.name == 'rescheduled' ||
              e.eventType.name == 'created')) {
        plannedIds.add(e.taskId);
      }
      if (_same(e.previousPlannedDate) && e.eventType.name == 'rescheduled') {
        movedAwayIds.add(e.taskId);
      }
      if (e.eventType.name == 'completed' && _same(e.occurredAt)) {
        completedIds.add(e.taskId);
      }
      if (_same(e.newDueDate) || _same(e.previousDueDate)) {
        deadlineIds.add(e.taskId);
      }
    }

    final planned = plannedIds.toList();
    final movedAway = movedAwayIds.toList();
    final completed = completedIds.toList();
    final deadlines = deadlineIds.toList();

    Widget section(String title, List<String> ids) {
      return Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            if (ids.isEmpty) const Text('None'),
            ...ids.map((String id) => Text(_titleFor(id, tasks))),
          ],
        ),
      );
    }

    return ListView(
      children: <Widget>[
        section('Planned for this date', planned),
        section('Rescheduled away', movedAway),
        section('Completed on this date', completed),
        section('Deadlines on this date', deadlines),
      ],
    );
  }
}
