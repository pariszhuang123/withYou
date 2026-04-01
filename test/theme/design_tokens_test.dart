import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:with_you/theme/app_theme.dart';
import 'package:with_you/theme/design_tokens.dart';

void main() {
  group('Design tokens', () {
    test('spacing tokens stay on the 8dp grid for major spacing', () {
      const spacing = AppSpacingTokens.base;

      expect(spacing.small, 8);
      expect(spacing.medium, 16);
      expect(spacing.large, 24);
      expect(spacing.xLarge, 32);
    });

    test('component size tokens encode the critical hit target sizes', () {
      const sizes = AppComponentSizeTokens.base;
      const accessibility = AccessibilityTokens.base;

      expect(sizes.homeTriggerSize, 64);
      expect(sizes.callActionSize, accessibility.largeTouchTarget);
      expect(sizes.settingsTileMinHeight, greaterThanOrEqualTo(48));
    });

    test('color tokens preserve semantic action pairings', () {
      const light = AppColorTokens.light;
      const dark = AppColorTokens.dark;

      expect(light.safeAction, isNot(light.dangerAction));
      expect(light.onSafeAction, const Color(0xFFFFFFFF));
      expect(dark.onDangerAction, const Color(0xFF690005));
    });

    test('spacing token lerp returns typed values', () {
      final lerped = AppSpacingTokens.base.lerp(
        const AppSpacingTokens(
          xSmall: 8,
          small: 12,
          medium: 20,
          large: 28,
          xLarge: 36,
        ),
        0.5,
      );

      expect(lerped.medium, 18);
      expect(lerped.large, 26);
    });

    test('copyWith preserves and overrides color tokens', () {
      final updated = AppColorTokens.light.copyWith(
        safeAction: const Color(0xFF000000),
        textSecondary: const Color(0xFF111111),
      );

      expect(updated.safeAction, const Color(0xFF000000));
      expect(updated.textSecondary, const Color(0xFF111111));
      expect(updated.onSafeAction, AppColorTokens.light.onSafeAction);
      expect(updated.focusRing, AppColorTokens.light.focusRing);
    });

    test('lerp interpolates color and call theme tokens', () {
      final colorMidpoint = AppColorTokens.light.lerp(AppColorTokens.dark, 0.5);
      final callMidpoint = CallThemeTokens.dark.lerp(
        const CallThemeTokens(
          background: Color(0xFF000000),
          surface: Color(0xFF111111),
          textPrimary: Color(0xFF222222),
          textSecondary: Color(0xFF333333),
          acceptAction: Color(0xFF444444),
          onAcceptAction: Color(0xFF555555),
          declineAction: Color(0xFF666666),
          onDeclineAction: Color(0xFF777777),
          avatarRing: Color(0xFF888888),
        ),
        0.5,
      );

      expect(colorMidpoint.safeAction, isNot(AppColorTokens.light.safeAction));
      expect(
        colorMidpoint.onDangerAction,
        isNot(AppColorTokens.dark.onDangerAction),
      );
      expect(callMidpoint.surface, isNot(CallThemeTokens.dark.surface));
      expect(callMidpoint.avatarRing, isNot(CallThemeTokens.dark.avatarRing));
    });

    test(
      'copyWith and lerp cover component, motion, and accessibility tokens',
      () {
        final sizeCopy = AppComponentSizeTokens.base.copyWith(
          homeTriggerSize: 80,
          cardRadius: 24,
        );
        final sizeMidpoint = AppComponentSizeTokens.base.lerp(
          const AppComponentSizeTokens(
            homeTriggerSize: 72,
            callActionSize: 80,
            settingsTileMinHeight: 64,
            cornerRadius: 20,
            cardRadius: 28,
          ),
          0.5,
        );

        final motionCopy = AppMotionTokens.base.copyWith(
          screenEntry: const Duration(milliseconds: 400),
        );
        final motionMidpoint = AppMotionTokens.base.lerp(
          const AppMotionTokens(
            avatarPulse: Duration(milliseconds: 2000),
            screenEntry: Duration(milliseconds: 500),
            actionFeedback: Duration(milliseconds: 250),
            stageTransition: Duration(milliseconds: 300),
          ),
          0.5,
        );

        final accessibilityCopy = AccessibilityTokens.base.copyWith(
          minContrastRatio: 7,
          reduceMotionDuration: const Duration(milliseconds: 50),
        );
        final accessibilityMidpoint = AccessibilityTokens.base.lerp(
          const AccessibilityTokens(
            minContrastRatio: 5.5,
            minTouchTarget: 56,
            largeTouchTarget: 80,
            maxSupportedTextScale: 2.5,
            reduceMotionDuration: Duration(milliseconds: 100),
          ),
          0.5,
        );

        expect(sizeCopy.homeTriggerSize, 80);
        expect(sizeCopy.cardRadius, 24);
        expect(sizeMidpoint.callActionSize, 76);
        expect(sizeMidpoint.cornerRadius, 18);

        expect(motionCopy.screenEntry, const Duration(milliseconds: 400));
        expect(motionMidpoint.avatarPulse, const Duration(milliseconds: 1750));
        expect(
          motionMidpoint.stageTransition,
          const Duration(milliseconds: 250),
        );

        expect(accessibilityCopy.minContrastRatio, 7);
        expect(
          accessibilityCopy.reduceMotionDuration,
          const Duration(milliseconds: 50),
        );
        expect(accessibilityMidpoint.minTouchTarget, 52);
        expect(accessibilityMidpoint.maxSupportedTextScale, 2.25);
      },
    );

    test('theme extension lookup returns registered tokens', () {
      final lightTheme = AppTheme.light();
      final darkTheme = AppTheme.dark();

      expect(lightTheme.appColors, AppColorTokens.light);
      expect(lightTheme.appSpacing, AppSpacingTokens.base);
      expect(lightTheme.appSizes, AppComponentSizeTokens.base);
      expect(lightTheme.appMotion, AppMotionTokens.base);
      expect(lightTheme.accessibility, AccessibilityTokens.base);
      expect(darkTheme.callTheme, CallThemeTokens.dark);
    });

    test('lerpDuration interpolates and rounds microseconds', () {
      final midpoint = lerpDuration(
        const Duration(milliseconds: 100),
        const Duration(milliseconds: 201),
        0.5,
      );

      expect(midpoint, const Duration(microseconds: 150500));
    });
  });
}
