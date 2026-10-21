import 'package:flutter/material.dart';

import '../../shared/widgets/empty_state.dart';

/// The tab holding the longer term objectives of the user.
class GoalsPage extends StatelessWidget {
  const GoalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      icon: Icons.flag_outlined,
      title: 'No goals yet',
      message:
          'Goals give your work direction. Set one up and you can break it '
          'down into tasks and follow your progress towards it.',
    );
  }
}
