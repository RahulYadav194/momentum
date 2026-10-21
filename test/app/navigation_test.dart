import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:momentum/app/router.dart';
import 'package:momentum/app/routes.dart';

import '../helpers/test_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpApp(WidgetTester tester, {GoRouter? router}) async {
    final preferences = await createTestPreferences(<String, Object>{});
    await tester.pumpWidget(
      buildTestApp(preferences: preferences, router: router),
    );
    await tester.pumpAndSettle();
  }

  /// Finds a bottom navigation destination by its label.
  Finder destination(String label) => find.descendant(
    of: find.byType(NavigationBar),
    matching: find.text(label),
  );

  group('bottom navigation', () {
    testWidgets('shows the four destinations', (WidgetTester tester) async {
      await pumpApp(tester);

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationDestination), findsNWidgets(4));
      for (final String label in <String>[
        'Today',
        'Tasks',
        'Goals',
        'Progress',
      ]) {
        expect(destination(label), findsOneWidget);
      }
    });

    testWidgets('starts on the Today tab', (WidgetTester tester) async {
      await pumpApp(tester);

      final NavigationBar navigationBar = tester.widget<NavigationBar>(
        find.byType(NavigationBar),
      );
      expect(navigationBar.selectedIndex, 0);
      expect(find.widgetWithText(AppBar, 'Today'), findsOneWidget);
      expect(find.text('Nothing planned for today'), findsOneWidget);
    });

    testWidgets('switches to the Tasks tab', (WidgetTester tester) async {
      await pumpApp(tester);

      await tester.tap(destination('Tasks'));
      await tester.pumpAndSettle();

      final NavigationBar navigationBar = tester.widget<NavigationBar>(
        find.byType(NavigationBar),
      );
      expect(navigationBar.selectedIndex, 1);
      expect(find.widgetWithText(AppBar, 'Tasks'), findsOneWidget);
      expect(find.text('No tasks yet'), findsOneWidget);
    });

    testWidgets('switches to the Goals tab', (WidgetTester tester) async {
      await pumpApp(tester);

      await tester.tap(destination('Goals'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(AppBar, 'Goals'), findsOneWidget);
      expect(find.text('No goals yet'), findsOneWidget);
    });

    testWidgets('switches to the Progress tab', (WidgetTester tester) async {
      await pumpApp(tester);

      await tester.tap(destination('Progress'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(AppBar, 'Progress'), findsOneWidget);
      expect(find.text('No progress to show yet'), findsOneWidget);
    });

    testWidgets('keeps the state of every visited tab', (
      WidgetTester tester,
    ) async {
      await pumpApp(tester);

      await tester.tap(destination('Tasks'));
      await tester.pumpAndSettle();
      await tester.tap(destination('Goals'));
      await tester.pumpAndSettle();
      await tester.tap(destination('Tasks'));
      await tester.pumpAndSettle();

      expect(find.text('No tasks yet'), findsOneWidget);
    });
  });

  group('settings', () {
    testWidgets('is reachable from the app bar', (WidgetTester tester) async {
      await pumpApp(tester);

      expect(find.text('Appearance'), findsNothing);

      await tester.tap(find.byTooltip('Settings'));
      await tester.pumpAndSettle();

      expect(find.text('Appearance'), findsOneWidget);
      expect(find.widgetWithText(AppBar, 'Settings'), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
    });

    testWidgets('can be opened from every tab', (WidgetTester tester) async {
      await pumpApp(tester);

      await tester.tap(destination('Progress'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Settings'));
      await tester.pumpAndSettle();

      expect(find.text('Appearance'), findsOneWidget);
    });

    testWidgets('is left with the back button', (WidgetTester tester) async {
      await pumpApp(tester);

      await tester.tap(find.byTooltip('Settings'));
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.text('Appearance'), findsNothing);
      expect(find.widgetWithText(AppBar, 'Today'), findsOneWidget);
      expect(find.byType(NavigationBar), findsOneWidget);
    });

    testWidgets('can be opened directly through a deep link', (
      WidgetTester tester,
    ) async {
      await pumpApp(
        tester,
        router: createRouter(initialLocation: AppRoutes.settings),
      );

      expect(find.text('Appearance'), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
    });
  });
}
