import 'package:flutter/material.dart';

import '../../shared/widgets/empty_state.dart';

/// The tab summarising how far the user has come.
class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      icon: Icons.insights_outlined,
      title: 'No progress to show yet',
      message:
          'Complete a few tasks and your momentum, streaks and trends will '
          'be charted here so you can see what is working.',
    );
  }
}
