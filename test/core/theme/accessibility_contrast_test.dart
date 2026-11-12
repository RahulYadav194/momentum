import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/core/theme/app_theme.dart';

void main() {
  for (final ThemeData theme in <ThemeData>[AppTheme.light, AppTheme.dark]) {
    final ColorScheme colors = theme.colorScheme;
    final String mode = theme.brightness.name;
    final Color todayCard = Color.alphaBlend(
      colors.primary.withAlpha(18),
      colors.surface,
    );

    test('$mode theme provides readable text and indicators', () {
      _expectContrast(
        colors.onSurface,
        colors.surface,
        4.5,
        '$mode calendar date label',
      );
      _expectContrast(
        colors.onSurfaceVariant,
        colors.surface,
        4.5,
        '$mode muted adjacent-month date',
      );
      _expectContrast(
        colors.onPrimaryContainer,
        colors.primaryContainer,
        4.5,
        '$mode selected calendar date',
      );
      _expectContrast(
        colors.onSurfaceVariant,
        colors.surface,
        4.5,
        '$mode secondary task metadata',
      );
      _expectContrast(
        colors.onSurfaceVariant,
        todayCard,
        4.5,
        '$mode secondary task metadata on Today card',
      );

      for (final (Color foreground, String label) in <(Color, String)>[
        (colors.primary, 'planned calendar indicator'),
        (colors.error, 'due calendar indicator'),
        (colors.onSurfaceVariant, 'history calendar indicator'),
        (colors.tertiary, 'low priority indicator'),
        (colors.primary, 'medium priority indicator'),
        (colors.error, 'high priority indicator'),
      ]) {
        _expectContrast(foreground, colors.surface, 3, '$mode $label');
      }

      _expectContrast(
        colors.tertiary,
        todayCard,
        3,
        '$mode low priority indicator on Today card',
      );
      _expectContrast(
        colors.primary,
        todayCard,
        3,
        '$mode medium priority indicator on Today card',
      );
      _expectContrast(
        colors.error,
        todayCard,
        3,
        '$mode high priority indicator on Today card',
      );
    });
  }
}

void _expectContrast(
  Color foreground,
  Color background,
  double minimum,
  String label,
) {
  final double ratio = _contrastRatio(foreground, background);
  expect(
    ratio,
    greaterThanOrEqualTo(minimum),
    reason: '$label contrast ratio was ${ratio.toStringAsFixed(2)}:1',
  );
}

double _contrastRatio(Color first, Color second) {
  final double firstLuminance = first.computeLuminance();
  final double secondLuminance = second.computeLuminance();
  final double lighter = firstLuminance > secondLuminance
      ? firstLuminance
      : secondLuminance;
  final double darker = firstLuminance > secondLuminance
      ? secondLuminance
      : firstLuminance;
  return (lighter + 0.05) / (darker + 0.05);
}
