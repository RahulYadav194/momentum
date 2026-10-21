import 'package:flutter/material.dart';

import '../../shared/widgets/empty_state.dart';

/// The landing tab of the application.
class TodayPage extends StatelessWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      icon: Icons.today_outlined,
      title: 'Nothing planned for today',
      message:
          'Your agenda is clear. Once you plan tasks for the day they will '
          'be listed here, grouped by the time you want to tackle them.',
    );
  }
}
