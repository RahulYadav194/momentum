import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/core/theme/theme_preferences.dart';

import '../helpers/test_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// The brightness the application is actually rendered with.
  Brightness renderedBrightness(WidgetTester tester) {
    final BuildContext context = tester.element(find.byType(Scaffold).first);
    return Theme.of(context).brightness;
  }

  ThemeMode? appThemeMode(WidgetTester tester) =>
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode;

  group('theme behaviour', () {
    testWidgets('starts in the system theme when nothing is stored', (
      WidgetTester tester,
    ) async {
      final preferences = await createTestPreferences(<String, Object>{});
      await tester.pumpWidget(buildTestApp(preferences: preferences));
      await tester.pumpAndSettle();

      expect(appThemeMode(tester), ThemeMode.system);
    });

    testWidgets('starts in the persisted dark theme', (
      WidgetTester tester,
    ) async {
      final preferences = await createTestPreferences(<String, Object>{
        kThemeModeKey: 'dark',
      });
      await tester.pumpWidget(buildTestApp(preferences: preferences));
      await tester.pumpAndSettle();

      expect(appThemeMode(tester), ThemeMode.dark);
      expect(renderedBrightness(tester), Brightness.dark);
    });

    testWidgets('starts in the persisted light theme', (
      WidgetTester tester,
    ) async {
      final preferences = await createTestPreferences(<String, Object>{
        kThemeModeKey: 'light',
      });
      await tester.pumpWidget(buildTestApp(preferences: preferences));
      await tester.pumpAndSettle();

      expect(appThemeMode(tester), ThemeMode.light);
      expect(renderedBrightness(tester), Brightness.light);
    });

    testWidgets('the system theme follows the device brightness', (
      WidgetTester tester,
    ) async {
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

      final preferences = await createTestPreferences(<String, Object>{});
      await tester.pumpWidget(buildTestApp(preferences: preferences));
      await tester.pumpAndSettle();

      expect(appThemeMode(tester), ThemeMode.system);
      expect(renderedBrightness(tester), Brightness.dark);
    });

    testWidgets('choosing the dark theme in settings applies and persists it', (
      WidgetTester tester,
    ) async {
      final preferences = await createTestPreferences(<String, Object>{});
      await tester.pumpWidget(buildTestApp(preferences: preferences));
      await tester.pumpAndSettle();

      expect(appThemeMode(tester), ThemeMode.system);

      await tester.tap(find.byTooltip('Settings'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      expect(appThemeMode(tester), ThemeMode.dark);
      expect(renderedBrightness(tester), Brightness.dark);
      expect(preferences.getString(kThemeModeKey), 'dark');
    });

    testWidgets(
      'choosing the light theme in settings applies and persists it',
      (WidgetTester tester) async {
        tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
        addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

        final preferences = await createTestPreferences(<String, Object>{});
        await tester.pumpWidget(buildTestApp(preferences: preferences));
        await tester.pumpAndSettle();

        await tester.tap(find.byTooltip('Settings'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Light'));
        await tester.pumpAndSettle();

        expect(appThemeMode(tester), ThemeMode.light);
        expect(renderedBrightness(tester), Brightness.light);
        expect(preferences.getString(kThemeModeKey), 'light');
      },
    );

    testWidgets('choosing the system theme hands control back to the device', (
      WidgetTester tester,
    ) async {
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

      final preferences = await createTestPreferences(<String, Object>{
        kThemeModeKey: 'dark',
      });
      await tester.pumpWidget(buildTestApp(preferences: preferences));
      await tester.pumpAndSettle();

      expect(renderedBrightness(tester), Brightness.dark);

      await tester.tap(find.byTooltip('Settings'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('System'));
      await tester.pumpAndSettle();

      expect(appThemeMode(tester), ThemeMode.system);
      expect(renderedBrightness(tester), Brightness.light);
      expect(preferences.getString(kThemeModeKey), 'system');
    });
  });
}
