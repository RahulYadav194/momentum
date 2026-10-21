import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/core/theme/app_theme.dart';

void main() {
  group('AppTheme', () {
    test('the light theme is a Material 3 light theme', () {
      final ThemeData theme = AppTheme.light;

      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, Brightness.light);
      expect(theme.colorScheme.brightness, Brightness.light);
    });

    test('the dark theme is a Material 3 dark theme', () {
      final ThemeData theme = AppTheme.dark;

      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, Brightness.dark);
      expect(theme.colorScheme.brightness, Brightness.dark);
    });

    test('the light and dark themes are visually distinct', () {
      expect(
        AppTheme.light.colorScheme.primary,
        isNot(AppTheme.dark.colorScheme.primary),
      );
      expect(
        AppTheme.light.colorScheme.surface,
        isNot(AppTheme.dark.colorScheme.surface),
      );
    });

    test('the app bar and navigation bar follow the colour scheme', () {
      final ColorScheme lightScheme = AppTheme.light.colorScheme;
      final ColorScheme darkScheme = AppTheme.dark.colorScheme;

      expect(AppTheme.light.appBarTheme.backgroundColor, lightScheme.surface);
      expect(AppTheme.dark.appBarTheme.backgroundColor, darkScheme.surface);
      expect(
        AppTheme.light.navigationBarTheme.indicatorColor,
        lightScheme.secondaryContainer,
      );
      expect(
        AppTheme.dark.navigationBarTheme.indicatorColor,
        darkScheme.secondaryContainer,
      );
    });
  });
}
