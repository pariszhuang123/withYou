import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:with_you/theme/app_theme.dart';
import 'package:with_you/theme/design_tokens.dart';

void main() {
  group('AppTheme', () {
    test('light theme exposes typed token extensions', () {
      final theme = AppTheme.light();

      expect(theme.useMaterial3, isTrue);
      expect(theme.appColors, AppColorTokens.light);
      expect(theme.appSpacing, AppSpacingTokens.base);
      expect(theme.appSizes, AppComponentSizeTokens.base);
      expect(theme.appMotion, AppMotionTokens.base);
      expect(theme.accessibility, AccessibilityTokens.base);
      expect(theme.callTheme, CallThemeTokens.dark);
    });

    test('dark theme uses explicit accessible colors', () {
      final theme = AppTheme.dark();

      expect(theme.useMaterial3, isTrue);
      expect(theme.colorScheme.surface, const Color(0xFF101417));
      expect(theme.colorScheme.onSurface, const Color(0xFFF1F4F6));
      expect(theme.iconTheme.color, const Color(0xFFF1F4F6));
    });

    test('required color pairs meet minimum contrast ratio', () {
      final lightTheme = AppTheme.light();
      final darkTheme = AppTheme.dark();

      final minRatio = lightTheme.accessibility.minContrastRatio;

      expect(
        _contrastRatio(
          lightTheme.colorScheme.primary,
          lightTheme.colorScheme.onPrimary,
        ),
        greaterThanOrEqualTo(minRatio),
      );
      expect(
        _contrastRatio(
          lightTheme.colorScheme.surface,
          lightTheme.colorScheme.onSurface,
        ),
        greaterThanOrEqualTo(minRatio),
      );
      expect(
        _contrastRatio(
          darkTheme.colorScheme.primary,
          darkTheme.colorScheme.onPrimary,
        ),
        greaterThanOrEqualTo(minRatio),
      );
      expect(
        _contrastRatio(
          darkTheme.colorScheme.surface,
          darkTheme.colorScheme.onSurface,
        ),
        greaterThanOrEqualTo(minRatio),
      );
    });
  });
}

double _contrastRatio(Color a, Color b) {
  final lightest = mathMax(_relativeLuminance(a), _relativeLuminance(b));
  final darkest = mathMin(_relativeLuminance(a), _relativeLuminance(b));
  return (lightest + 0.05) / (darkest + 0.05);
}

double _relativeLuminance(Color color) {
  final red = _linearize(color.r);
  final green = _linearize(color.g);
  final blue = _linearize(color.b);
  return (0.2126 * red) + (0.7152 * green) + (0.0722 * blue);
}

double _linearize(double channel) {
  final normalized = channel;
  if (normalized <= 0.03928) {
    return normalized / 12.92;
  }
  return math.pow((normalized + 0.055) / 1.055, 2.4).toDouble();
}

double mathMax(double a, double b) => a > b ? a : b;

double mathMin(double a, double b) => a < b ? a : b;
