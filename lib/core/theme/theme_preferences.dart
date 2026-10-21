import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The key the selected theme mode is persisted under.
const String kThemeModeKey = 'theme_mode';

/// Reads and writes the theme selection from [SharedPreferences].
class ThemePreferences {
  const ThemePreferences(this._preferences);

  final SharedPreferences _preferences;

  /// The theme mode the user selected.
  ///
  /// Falls back to [ThemeMode.system] when nothing has been persisted yet, or
  /// when the persisted value does not name a known [ThemeMode].
  ThemeMode readThemeMode() {
    final String? stored = _preferences.getString(kThemeModeKey);
    if (stored == null) {
      return ThemeMode.system;
    }
    for (final ThemeMode mode in ThemeMode.values) {
      if (mode.name == stored) {
        return mode;
      }
    }
    return ThemeMode.system;
  }

  /// Persists [mode] so it survives the next launch.
  Future<bool> writeThemeMode(ThemeMode mode) =>
      _preferences.setString(kThemeModeKey, mode.name);
}
