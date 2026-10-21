import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/goals/goals_page.dart';
import '../features/progress/progress_page.dart';
import '../features/settings/settings_page.dart';
import '../features/shell/home_shell.dart';
import '../features/tasks/tasks_page.dart';
import '../features/today/today_page.dart';
import 'routes.dart';

/// The application router.
final Provider<GoRouter> routerProvider = Provider<GoRouter>(
  (Ref ref) => createRouter(),
);

/// Builds a router for the Momentum application.
///
/// The branches of the shell are declared in the same order as
/// [appDestinations], so the bottom navigation and the router stay in sync.
GoRouter createRouter({String initialLocation = AppRoutes.today}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: <RouteBase>[
      StatefulShellRoute.indexedStack(
        builder:
            (
              BuildContext context,
              GoRouterState state,
              StatefulNavigationShell navigationShell,
            ) => HomeShell(navigationShell: navigationShell),
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.today,
                builder: (BuildContext context, GoRouterState state) =>
                    const TodayPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.tasks,
                builder: (BuildContext context, GoRouterState state) =>
                    const TasksPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.goals,
                builder: (BuildContext context, GoRouterState state) =>
                    const GoalsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.progress,
                builder: (BuildContext context, GoRouterState state) =>
                    const ProgressPage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (BuildContext context, GoRouterState state) =>
            const SettingsPage(),
      ),
    ],
    errorBuilder: (BuildContext context, GoRouterState state) => Scaffold(
      appBar: AppBar(title: const Text('Page not found')),
      body: Center(child: Text('No route matches ${state.uri}')),
    ),
  );
}
