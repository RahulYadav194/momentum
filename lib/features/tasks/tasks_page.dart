import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/widgets/empty_state.dart';
import 'data/task_providers.dart';
import 'domain/task.dart';
import 'domain/task_repository.dart';
import 'presentation/quick_add_bar.dart';
import 'presentation/task_form_sheet.dart';
import 'presentation/task_tile.dart';

/// The tab holding every task the user captured.
class TasksPage extends ConsumerWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Task>> tasksAsync = ref.watch(taskListProvider);

    return Scaffold(
      body: tasksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(Icons.error_outline, size: 48),
                const SizedBox(height: 12),
                Text(
                  'Could not load tasks',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
        data: (List<Task> tasks) {
          if (tasks.isEmpty) {
            return const EmptyState(
              icon: Icons.checklist_outlined,
              title: 'No tasks yet',
              message:
                  'Capture your first task below. You can prioritise, '
                  'schedule and tick them off as you make progress.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: tasks.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (BuildContext context, int index) {
              final Task task = tasks[index];
              return TaskTile(
                task: task,
                onToggle: (bool completed) => _toggleTask(
                  context,
                  ref,
                  task,
                  completed,
                ),
                onTap: () => _editTask(context, ref, task),
                onDelete: () => _confirmDelete(context, ref, task),
              );
            },
          );
        },
      ),
      bottomNavigationBar: const QuickAddBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createTask(context, ref),
        tooltip: 'New task with details',
        child: const Icon(Icons.edit_note),
      ),
    );
  }

  Future<void> _createTask(BuildContext context, WidgetRef ref) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (BuildContext context) => TaskFormSheet(
        onSave: ({
          required String title,
          String? description,
          required TaskPriority priority,
          DateTime? dueDate,
        }) async {
          final TaskRepository repository = ref.read(taskRepositoryProvider);
          await repository.create(
            TaskDraft(
              title: title,
              description: description,
              priority: priority,
              dueDate: dueDate,
            ),
          );
        },
      ),
    );
  }

  Future<void> _editTask(
    BuildContext context,
    WidgetRef ref,
    Task task,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (BuildContext context) => TaskFormSheet(
        initialTask: task,
        onSave: ({
          required String title,
          String? description,
          required TaskPriority priority,
          DateTime? dueDate,
        }) async {
          final TaskRepository repository = ref.read(taskRepositoryProvider);
          await repository.update(
            task.id,
            TaskUpdate(
              title: title,
              description: description,
              clearDescription: description == null,
              priority: priority,
              dueDate: dueDate,
              clearDueDate: dueDate == null && task.dueDate != null,
            ),
          );
        },
      ),
    );
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

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Task task,
  ) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Delete task?'),
        content: Text('\u201C${task.title}\u201D will be permanently deleted.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final TaskRepository repository = ref.read(taskRepositoryProvider);
      await repository.delete(task.id);
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not delete task: $error')),
        );
      }
    }
  }
}
