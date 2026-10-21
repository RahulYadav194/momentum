import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'theme_preferences.dart';

/// Exposes the [SharedPreferences] instance to the widget tree.
///
/// The instance is created in `main()` before the first frame and injected
/// through [ProviderScope], so nothing else in the app has to deal with
/// asynchronous plugin initialisation.
final Provider<SharedPreferences> sharedPreferencesProvider =
    Provider<SharedPreferences>(
      (Ref ref) => throw UnimplementedError(
        'sharedPreferencesProvider must be overridden in a ProviderScope.',
      ),
    );

/// The theme mode the application is currently rendered with.
final NotifierProvider<ThemeModeController, ThemeMode> themeModeProvider =
    NotifierProvider<ThemeModeController, ThemeMode>(ThemeModeController.new);

/// Owns the selected [ThemeMode] and keeps it in sync with storage.
class ThemeModeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() =>
      ThemePreferences(ref.watch(sharedPreferencesProvider)).readThemeMode();

  /// Applies [mode] immediately and persists it for the next launch.
  Future<void> setThemeMode(ThemeMode mode) async {
    if (mode == state) {
      return;
    }
    state = mode;
    await ThemePreferences(
      ref.read(sharedPreferencesProvider),
    ).writeThemeMode(mode);
  }
}
