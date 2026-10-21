import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/core/theme/theme_controller.dart';
import 'package:momentum/core/theme/theme_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences preferences;

  ProviderContainer createContainer() {
    final ProviderContainer container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
    );
    addTearDown(container.dispose);
    return container;
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    preferences = await SharedPreferences.getInstance();
  });

  group('ThemeModeController', () {
    test('starts in the system theme when nothing is stored', () {
      final ProviderContainer container = createContainer();

      expect(container.read(themeModeProvider), ThemeMode.system);
    });

    test('starts in the persisted theme', () async {
      await preferences.setString(kThemeModeKey, 'dark');
      final ProviderContainer container = createContainer();

      expect(container.read(themeModeProvider), ThemeMode.dark);
    });

    test('changing the theme updates the state and persists it', () async {
      final ProviderContainer container = createContainer();

      await container
          .read(themeModeProvider.notifier)
          .setThemeMode(ThemeMode.dark);

      expect(container.read(themeModeProvider), ThemeMode.dark);
      expect(preferences.getString(kThemeModeKey), 'dark');
    });

    test('the persisted theme survives a new container', () async {
      final ProviderContainer container = createContainer();
      await container
          .read(themeModeProvider.notifier)
          .setThemeMode(ThemeMode.light);

      final ProviderContainer restarted = createContainer();

      expect(restarted.read(themeModeProvider), ThemeMode.light);
    });

    test('selecting the current theme again keeps the state stable', () async {
      final ProviderContainer container = createContainer();

      await container
          .read(themeModeProvider.notifier)
          .setThemeMode(ThemeMode.dark);
      await container
          .read(themeModeProvider.notifier)
          .setThemeMode(ThemeMode.dark);

      expect(container.read(themeModeProvider), ThemeMode.dark);
      expect(preferences.getString(kThemeModeKey), 'dark');
    });
  });
}
