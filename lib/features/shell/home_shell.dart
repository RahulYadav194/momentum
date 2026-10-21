import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';

/// The scaffold that hosts the tabbed navigation, the app bar and the
/// bottom navigation.
class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.navigationShell});

  /// The navigation state of the surrounding [StatefulShellRoute].
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final AppDestination destination =
        appDestinations[navigationShell.currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(destination.label),
        actions: <Widget>[
          IconButton(
            onPressed: () => context.push(AppRoutes.settings),
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (int index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: <Widget>[
          for (final AppDestination destination in appDestinations)
            NavigationDestination(
              icon: Icon(destination.icon),
              selectedIcon: Icon(destination.selectedIcon),
              label: destination.label,
            ),
        ],
      ),
    );
  }
}
