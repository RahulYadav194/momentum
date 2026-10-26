import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/widgets/empty_state.dart';
import '../tasks/data/task_providers.dart';
import 'domain/today_task_classification.dart';

/// The landing tab of the application.
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
          return const EmptyState(
            icon: Icons.today_outlined,
            title: 'Nothing planned for today',
            message:
                'Your agenda is clear. Once you plan tasks for the day they '
                'will be listed here, grouped by the time you want to tackle '
                'them.',
          );
        }

        final sections = classifyTasks(tasks, DateTime.now());
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _Section(title: "Today's Focus", tasks: sections.focus),
            _Section(title: 'Due Today', tasks: sections.dueToday),
            _Section(title: 'Overdue', tasks: sections.overdue),
            _Section(title: 'Completed Today', tasks: sections.completedToday),
          ],
        );
      },
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.tasks});

  final String title;
  final List<Task> tasks;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          if (tasks.isEmpty)
            Text(
              'No tasks',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          else
            ...tasks.map((t) => ListTile(title: Text(t.title))),
        ],
      ),
    );
  }
}
