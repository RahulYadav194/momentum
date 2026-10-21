import 'package:flutter/material.dart';

/// The paths of the routes in the application.
abstract final class AppRoutes {
  /// The Today tab.
  static const String today = '/today';

  /// The Tasks tab.
  static const String tasks = '/tasks';

  /// The Goals tab.
  static const String goals = '/goals';

  /// The Progress tab.
  static const String progress = '/progress';

  /// The Settings screen, pushed on top of the tabbed shell.
  static const String settings = '/settings';
}

/// A single destination of the bottom navigation.
class AppDestination {
  const AppDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  /// The label shown under the icon.
  final String label;

  /// The icon shown while the destination is not selected.
  final IconData icon;

  /// The icon shown while the destination is selected.
  final IconData selectedIcon;
}

/// The bottom navigation destinations, in display order.
///
/// The order has to match the order of the branches in the router
/// configuration, because the shell indexes into this list with the index of
/// the active navigation branch.
const List<AppDestination> appDestinations = <AppDestination>[
  AppDestination(
    label: 'Today',
    icon: Icons.today_outlined,
    selectedIcon: Icons.today,
  ),
  AppDestination(
    label: 'Tasks',
    icon: Icons.checklist_outlined,
    selectedIcon: Icons.checklist,
  ),
  AppDestination(
    label: 'Goals',
    icon: Icons.flag_outlined,
    selectedIcon: Icons.flag,
  ),
  AppDestination(
    label: 'Progress',
    icon: Icons.insights_outlined,
    selectedIcon: Icons.insights,
  ),
];
