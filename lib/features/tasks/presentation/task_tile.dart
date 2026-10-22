import 'package:flutter/material.dart';

import '../domain/task.dart';

/// A single task rendered as a Material 3 list tile.
class TaskTile extends StatelessWidget {
  const TaskTile({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onTap,
    required this.onDelete,
  });

  final Task task;
  final ValueChanged<bool> onToggle;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    final Color priorityColor = switch (task.priority) {
      TaskPriority.low => colors.tertiary,
      TaskPriority.medium => colors.primary,
      TaskPriority.high => colors.error,
    };

    return Dismissible(
      key: ValueKey<String>(task.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        onDelete();
        return false;
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        color: colors.errorContainer,
        child: Icon(Icons.delete_outline, color: colors.onErrorContainer),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (bool? value) => onToggle(value ?? false),
        ),
        title: Text(
          task.title,
          style: task.isCompleted
              ? theme.textTheme.bodyLarge?.copyWith(
                  decoration: TextDecoration.lineThrough,
                  color: colors.onSurfaceVariant,
                )
              : theme.textTheme.bodyLarge,
        ),
        subtitle: _buildSubtitle(context),
        trailing: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: priorityColor,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  Widget? _buildSubtitle(BuildContext context) {
    final List<Widget> parts = <Widget>[];

    if (task.description != null && task.description!.isNotEmpty) {
      parts.add(Text(task.description!));
    }

    if (task.dueDate != null) {
      parts.add(
        Text(
          'Due ${_formatDate(task.dueDate!)}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      );
    }

    if (parts.isEmpty) return null;
    if (parts.length == 1) return parts.first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: parts,
    );
  }

  String _formatDate(DateTime date) {
    final String day = date.day.toString().padLeft(2, '0');
    final String month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }
}
