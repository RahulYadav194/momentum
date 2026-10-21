import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/core/theme/theme_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences preferences;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    preferences = await SharedPreferences.getInstance();
  });

  group('ThemePreferences', () {
    test('falls back to the system theme when nothing is stored', () {
      expect(ThemePreferences(preferences).readThemeMode(), ThemeMode.system);
    });

    test('round-trips every theme mode', () async {
      for (final ThemeMode mode in ThemeMode.values) {
        await ThemePreferences(preferences).writeThemeMode(mode);

        expect(
          ThemePreferences(preferences).readThemeMode(),
          mode,
          reason: 'the persisted $mode should be read back unchanged',
        );
      }
    });

    test(
      'falls back to the system theme for an unknown stored value',
      () async {
        await preferences.setString(kThemeModeKey, 'sepia');

        expect(ThemePreferences(preferences).readThemeMode(), ThemeMode.system);
      },
    );

    test('stores the theme mode under a stable key', () async {
      await ThemePreferences(preferences).writeThemeMode(ThemeMode.dark);

      expect(preferences.getString(kThemeModeKey), 'dark');
    });
  });
}
