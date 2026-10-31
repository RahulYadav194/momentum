import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../shared/widgets/empty_state.dart';
import '../tasks/data/task_providers.dart';
import '../tasks/domain/task_repository.dart';
import '../tasks/presentation/quick_add_bar.dart';
import '../tasks/presentation/task_tile.dart';
import 'domain/today_task_classification.dart';

class TodayPage extends ConsumerWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(taskListProvider);

    return tasksAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stackTrace) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Unable to load your tasks',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please try again.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.invalidate(taskListProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      data: (tasks) {
        if (tasks.isEmpty) {
          return Scaffold(
            body: const EmptyState(
              icon: Icons.today_outlined,
              title: 'Nothing planned for today',
              message: 'Your agenda is clear. Add a task to get started.',
            ),
            bottomNavigationBar: const QuickAddBar(),
          );
        }

        final sections = classifyTasks(tasks, DateTime.now());
        final completed = sections.completedToday.length;
        final total = tasks.length;
        final progress = total == 0 ? 0.0 : completed / total;

        final now = DateTime.now();
        final greeting = now.hour < 12
            ? 'Good morning'
            : now.hour < 18
            ? 'Good afternoon'
            : 'Good evening';
        final dateLabel = '//';

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
                            'Daily progress',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(value: progress),
                          const SizedBox(height: 4),
                          Text(' of  tasks completed'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              ..._buildSections(context, sections, ref),
            ],
          ),
          bottomNavigationBar: const QuickAddBar(),
        );
      },
    );
  }

  List<Widget> _buildSections(
    BuildContext context,
    TodayTaskSections sections,
    WidgetRef ref,
  ) {
    final groups = <MapEntry<String, List<Task>>>[
      MapEntry("Today's Focus", sections.focus),
      MapEntry('Due Today', sections.dueToday),
      MapEntry('Overdue', sections.overdue),
      MapEntry('Completed Today', sections.completedToday),
    ];
    return groups.expand((entry) {
      return <Widget>[
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              entry.key,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ),
        if (entry.value.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                'No tasks',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final task = entry.value[index];
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Card(
                  child: TaskTile(
                    task: task,
                    onToggle: (bool completed) =>
                        _toggleTask(context, ref, task, completed),
                    onTap: () {},
                    onDelete: () {},
                  ),
                ),
              );
            }, childCount: entry.value.length),
          ),
      ];
    }).toList();
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
