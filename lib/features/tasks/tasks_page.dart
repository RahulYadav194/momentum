import 'package:flutter/material.dart';

import '../../shared/widgets/empty_state.dart';

/// The tab holding every task the user captured.
class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      icon: Icons.checklist_outlined,
      title: 'No tasks yet',
      message:
          'Tasks you capture will live here. You will be able to prioritise, '
          'schedule and tick them off as you make progress.',
    );
  }
}
