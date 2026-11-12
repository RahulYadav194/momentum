import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../shared/widgets/empty_state.dart';
import '../tasks/data/task_providers.dart';
import '../tasks/domain/task.dart';
import '../tasks/domain/task_repository.dart';
import '../tasks/presentation/quick_add_bar.dart';
import '../tasks/presentation/task_deletion.dart';
import '../tasks/presentation/task_form_sheet.dart';
import '../tasks/presentation/task_tile.dart';
import 'domain/today_task_classification.dart';

final Provider<DateTime Function()> todayClockProvider =
    Provider<DateTime Function()>((Ref ref) => DateTime.now);

class TodayPage extends ConsumerStatefulWidget {
  const TodayPage({super.key});

  @override
  ConsumerState<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends ConsumerState<TodayPage>
    with WidgetsBindingObserver {
  Timer? _dateRefreshTimer;

  DateTime get _now => ref.read(todayClockProvider)();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scheduleDateRefresh();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshDate();
    } else if (state == AppLifecycleState.paused) {
      _dateRefreshTimer?.cancel();
      _dateRefreshTimer = null;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _dateRefreshTimer?.cancel();
    super.dispose();
  }

  void _scheduleDateRefresh() {
    _dateRefreshTimer?.cancel();
    final DateTime now = _now;
    final DateTime nextDay = DateTime(now.year, now.month, now.day + 1);
    final Duration untilNextDay = nextDay.difference(now);
    _dateRefreshTimer = Timer(
      untilNextDay.isNegative || untilNextDay == Duration.zero
          ? const Duration(seconds: 1)
          : untilNextDay,
      _refreshDate,
    );
  }

  void _refreshDate() {
    if (!mounted) return;
    _dateRefreshTimer?.cancel();
    setState(() {});
    _scheduleDateRefresh();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Task>> tasksAsync = ref.watch(taskListProvider);

    return tasksAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (Object error, StackTrace stackTrace) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Unable to load your tasks',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              const Text('Please try again.', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.invalidate(taskListProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      data: (List<Task> tasks) {
        final DateTime now = _now;
        final TodayTaskSections sections = classifyTasks(tasks, now);
        final int completedCount = sections.completedToday.length;
        final int relevantCount =
            sections.relevantTasks.length + completedCount;
        final double progress = relevantCount == 0
            ? 0
            : completedCount / relevantCount;
        final String dateLabel = MaterialLocalizations.of(
          context,
        ).formatFullDate(now);
        final String greeting = now.hour < 12
            ? 'Good morning'
            : now.hour < 18
            ? 'Good afternoon'
            : 'Good evening';

        return Scaffold(
          body: CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                pinned: true,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      greeting,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      dateLabel,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                actions: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.calendar_month_outlined),
                    tooltip: 'Calendar',
                    onPressed: () => context.push(AppRoutes.calendar),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Today’s progress',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(value: progress),
                          const SizedBox(height: 4),
                          Text(
                            '$completedCount of $relevantCount relevant tasks completed today',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (tasks.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(
                    icon: Icons.today_outlined,
                    title: 'Nothing planned for today',
                    message: 'Your agenda is clear. Add a task to get started.',
                  ),
                )
              else
                ..._buildSections(context, ref, sections, now),
            ],
          ),
          bottomNavigationBar: const QuickAddBar(),
        );
      },
    );
  }

  List<Widget> _buildSections(
    BuildContext context,
    WidgetRef ref,
    TodayTaskSections sections,
    DateTime now,
  ) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final List<Widget> result = <Widget>[];

    void addSection({
      required String title,
      required IconData icon,
      required Color color,
      required List<Task> tasks,
      bool missed = false,
    }) {
      if (tasks.isEmpty) return;

      result
        ..add(
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: <Widget>[
                  Icon(icon, size: 20, color: color),
                  const SizedBox(width: 8),
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
            ),
          ),
        )
        ..add(
          SliverList(
            delegate: SliverChildBuilderDelegate((
              BuildContext context,
              int index,
            ) {
              final Task task = tasks[index];
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 3,
                ),
                child: Card(
                  color: color.withAlpha(18),
                  child: Column(
                    children: <Widget>[
                      TaskTile(
                        task: task,
                        onToggle: (bool completed) =>
                            _toggleTask(context, ref, task, completed),
                        onTap: () => _editTask(context, ref, task),
                        onDelete: () => confirmAndDeleteTask(
                          context,
                          repository: ref.read(taskRepositoryProvider),
                          task: task,
                        ),
                      ),
                      if (missed)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            alignment: WrapAlignment.end,
                            children: <Widget>[
                              OutlinedButton(
                                onPressed: () =>
                                    _rescheduleTask(context, ref, task, now),
                                child: const Text('Reschedule'),
                              ),
                              TextButton(
                                onPressed: () => _keepMissedPlan(context, task),
                                child: const Text('Keep in Missed Plans'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    _removePlanDate(context, ref, task),
                                child: const Text('Remove Plan Date'),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }, childCount: tasks.length),
          ),
        );
    }

    addSection(
      title: 'Planned Today',
      icon: Icons.today_outlined,
      color: colors.primary,
      tasks: sections.plannedToday,
    );
    addSection(
      title: 'Missed Plans',
      icon: Icons.event_busy_outlined,
      color: colors.error,
      tasks: sections.missedPlans,
      missed: true,
    );
    addSection(
      title: 'Overdue',
      icon: Icons.warning_amber_outlined,
      color: colors.error,
      tasks: sections.overdue,
    );
    addSection(
      title: 'Due Today',
      icon: Icons.event_available_outlined,
      color: colors.secondary,
      tasks: sections.dueToday,
    );
    addSection(
      title: 'Suggested for Today',
      icon: Icons.priority_high,
      color: colors.tertiary,
      tasks: sections.suggestedForToday,
    );
    addSection(
      title: 'Upcoming',
      icon: Icons.upcoming_outlined,
      color: colors.primary,
      tasks: sections.upcoming,
    );
    addSection(
      title: 'Unscheduled',
      icon: Icons.inbox_outlined,
      color: colors.onSurfaceVariant,
      tasks: sections.unscheduled,
    );
    addSection(
      title: 'Completed Today',
      icon: Icons.task_alt,
      color: colors.tertiary,
      tasks: sections.completedToday,
    );

    if (sections.relevantTasks.isEmpty) {
      result.add(
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(
              'Nothing needs your attention today.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
            ),
          ),
        ),
      );
    }

    return result;
  }

  Future<void> _editTask(BuildContext context, WidgetRef ref, Task task) async {
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
              final TaskRepository repository = ref.read(
                taskRepositoryProvider,
              );
              await repository.update(
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
            },
      ),
    );
  }

  Future<void> _rescheduleTask(
    BuildContext context,
    WidgetRef ref,
    Task task,
    DateTime now,
  ) async {
    final DateTime? plannedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (plannedDate == null) return;

    try {
      await ref
          .read(taskRepositoryProvider)
          .update(task.id, TaskUpdate(plannedDate: plannedDate));
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not reschedule task: $error')),
        );
      }
    }
  }

  void _keepMissedPlan(BuildContext context, Task task) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('"${task.title}" will remain in Missed Plans.')),
    );
  }

  Future<void> _removePlanDate(
    BuildContext context,
    WidgetRef ref,
    Task task,
  ) async {
    try {
      await ref
          .read(taskRepositoryProvider)
          .update(task.id, const TaskUpdate(clearPlannedDate: true));
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not remove plan date: $error')),
        );
      }
    }
  }

  Future<void> _toggleTask(
    BuildContext context,
    WidgetRef ref,
    Task task,
    bool completed,
  ) async {
    try {
      final TaskRepository repository = ref.read(taskRepositoryProvider);
      if (completed) {
        await repository.complete(task.id);
      } else {
        await repository.reopen(task.id);
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not update task: $error')),
        );
      }
    }
  }
}
