import 'dart:ui';

import 'package:flutter/material.dart';

@immutable
class AppColorTokens extends ThemeExtension<AppColorTokens> {
  const AppColorTokens({
    required this.safeAction,
    required this.onSafeAction,
    required this.dangerAction,
    required this.onDangerAction,
    required this.surfacePrimary,
    required this.surfaceSecondary,
    required this.surfaceCritical,
    required this.textPrimary,
    required this.textSecondary,
    required this.borderSubtle,
    required this.focusRing,
    required this.brandColor,
  });

  final Color safeAction;
  final Color onSafeAction;
  final Color dangerAction;
  final Color onDangerAction;
  final Color surfacePrimary;
  final Color surfaceSecondary;
  final Color surfaceCritical;
  final Color textPrimary;
  final Color textSecondary;
  final Color borderSubtle;
  final Color focusRing;
  final Color brandColor;

  static const AppColorTokens light = AppColorTokens(
    safeAction: Color(0xFF1F6B45),
    onSafeAction: Color(0xFFFFFFFF),
    dangerAction: Color(0xFFB3261E),
    onDangerAction: Color(0xFFFFFFFF),
    surfacePrimary: Color(0xFFF5F7F9),
    surfaceSecondary: Color(0xFFFFFFFF),
    surfaceCritical: Color(0xFFE9EEF2),
    textPrimary: Color(0xFF13212B),
    textSecondary: Color(0xFF41515D),
    borderSubtle: Color(0xFFB8C4CD),
    focusRing: Color(0xFF0D6EFD),
    brandColor: Color(0xFF2D8659),
  );

  static const AppColorTokens dark = AppColorTokens(
    safeAction: Color(0xFF7DDAA7),
    onSafeAction: Color(0xFF002111),
    dangerAction: Color(0xFFFFB4AB),
    onDangerAction: Color(0xFF690005),
    surfacePrimary: Color(0xFF101417),
    surfaceSecondary: Color(0xFF182027),
    surfaceCritical: Color(0xFF1F2A33),
    textPrimary: Color(0xFFF1F4F6),
    textSecondary: Color(0xFFC5CCD2),
    borderSubtle: Color(0xFF54606A),
    focusRing: Color(0xFF9ACBFF),
    brandColor: Color(0xFF2D8659),
  );

  @override
  AppColorTokens copyWith({
    Color? safeAction,
    Color? onSafeAction,
    Color? dangerAction,
    Color? onDangerAction,
    Color? surfacePrimary,
    Color? surfaceSecondary,
    Color? surfaceCritical,
    Color? textPrimary,
    Color? textSecondary,
    Color? borderSubtle,
    Color? focusRing,
    Color? brandColor,
  }) {
    return AppColorTokens(
      safeAction: safeAction ?? this.safeAction,
      onSafeAction: onSafeAction ?? this.onSafeAction,
      dangerAction: dangerAction ?? this.dangerAction,
      onDangerAction: onDangerAction ?? this.onDangerAction,
      surfacePrimary: surfacePrimary ?? this.surfacePrimary,
      surfaceSecondary: surfaceSecondary ?? this.surfaceSecondary,
      surfaceCritical: surfaceCritical ?? this.surfaceCritical,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      focusRing: focusRing ?? this.focusRing,
      brandColor: brandColor ?? this.brandColor,
    );
  }

  @override
  AppColorTokens lerp(ThemeExtension<AppColorTokens>? other, double t) {
    if (other is! AppColorTokens) {
      return this;
    }

    return AppColorTokens(
      safeAction: Color.lerp(safeAction, other.safeAction, t) ?? safeAction,
      onSafeAction:
          Color.lerp(onSafeAction, other.onSafeAction, t) ?? onSafeAction,
      dangerAction:
          Color.lerp(dangerAction, other.dangerAction, t) ?? dangerAction,
      onDangerAction:
          Color.lerp(onDangerAction, other.onDangerAction, t) ?? onDangerAction,
      surfacePrimary:
          Color.lerp(surfacePrimary, other.surfacePrimary, t) ?? surfacePrimary,
      surfaceSecondary:
          Color.lerp(surfaceSecondary, other.surfaceSecondary, t) ??
          surfaceSecondary,
      surfaceCritical:
          Color.lerp(surfaceCritical, other.surfaceCritical, t) ??
          surfaceCritical,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t) ?? textPrimary,
      textSecondary:
          Color.lerp(textSecondary, other.textSecondary, t) ?? textSecondary,
      borderSubtle:
          Color.lerp(borderSubtle, other.borderSubtle, t) ?? borderSubtle,
      focusRing: Color.lerp(focusRing, other.focusRing, t) ?? focusRing,
      brandColor: Color.lerp(brandColor, other.brandColor, t) ?? brandColor,
    );
  }
}

@immutable
class AppSpacingTokens extends ThemeExtension<AppSpacingTokens> {
  const AppSpacingTokens({
    required this.xSmall,
    required this.small,
    required this.medium,
    required this.large,
    required this.xLarge,
  });

  final double xSmall;
  final double small;
  final double medium;
  final double large;
  final double xLarge;

  static const AppSpacingTokens base = AppSpacingTokens(
    xSmall: 4,
    small: 8,
    medium: 16,
    large: 24,
    xLarge: 32,
  );

  @override
  AppSpacingTokens copyWith({
    double? xSmall,
    double? small,
    double? medium,
    double? large,
    double? xLarge,
  }) {
    return AppSpacingTokens(
      xSmall: xSmall ?? this.xSmall,
      small: small ?? this.small,
      medium: medium ?? this.medium,
      large: large ?? this.large,
      xLarge: xLarge ?? this.xLarge,
    );
  }

  @override
  AppSpacingTokens lerp(ThemeExtension<AppSpacingTokens>? other, double t) {
    if (other is! AppSpacingTokens) {
      return this;
    }

    return AppSpacingTokens(
      xSmall: lerpDouble(xSmall, other.xSmall, t) ?? xSmall,
      small: lerpDouble(small, other.small, t) ?? small,
      medium: lerpDouble(medium, other.medium, t) ?? medium,
      large: lerpDouble(large, other.large, t) ?? large,
      xLarge: lerpDouble(xLarge, other.xLarge, t) ?? xLarge,
    );
  }
}

@immutable
class AppComponentSizeTokens extends ThemeExtension<AppComponentSizeTokens> {
  const AppComponentSizeTokens({
    required this.homeTriggerSize,
    required this.callActionSize,
    required this.settingsTileMinHeight,
    required this.cornerRadius,
    required this.cardRadius,
  });

  final double homeTriggerSize;
  final double callActionSize;
  final double settingsTileMinHeight;
  final double cornerRadius;
  final double cardRadius;

  static const AppComponentSizeTokens base = AppComponentSizeTokens(
    homeTriggerSize: 64,
    callActionSize: 72,
    settingsTileMinHeight: 56,
    cornerRadius: 16,
    cardRadius: 20,
  );

  @override
  AppComponentSizeTokens copyWith({
    double? homeTriggerSize,
    double? callActionSize,
    double? settingsTileMinHeight,
    double? cornerRadius,
    double? cardRadius,
  }) {
    return AppComponentSizeTokens(
      homeTriggerSize: homeTriggerSize ?? this.homeTriggerSize,
      callActionSize: callActionSize ?? this.callActionSize,
      settingsTileMinHeight:
          settingsTileMinHeight ?? this.settingsTileMinHeight,
      cornerRadius: cornerRadius ?? this.cornerRadius,
      cardRadius: cardRadius ?? this.cardRadius,
    );
  }

  @override
  AppComponentSizeTokens lerp(
    ThemeExtension<AppComponentSizeTokens>? other,
    double t,
  ) {
    if (other is! AppComponentSizeTokens) {
      return this;
    }

    return AppComponentSizeTokens(
      homeTriggerSize:
          lerpDouble(homeTriggerSize, other.homeTriggerSize, t) ??
          homeTriggerSize,
      callActionSize:
          lerpDouble(callActionSize, other.callActionSize, t) ?? callActionSize,
      settingsTileMinHeight:
          lerpDouble(settingsTileMinHeight, other.settingsTileMinHeight, t) ??
          settingsTileMinHeight,
      cornerRadius:
          lerpDouble(cornerRadius, other.cornerRadius, t) ?? cornerRadius,
      cardRadius: lerpDouble(cardRadius, other.cardRadius, t) ?? cardRadius,
    );
  }
}

@immutable
class AppMotionTokens extends ThemeExtension<AppMotionTokens> {
  const AppMotionTokens({
    required this.avatarPulse,
    required this.screenEntry,
    required this.actionFeedback,
    required this.stageTransition,
  });

  final Duration avatarPulse;
  final Duration screenEntry;
  final Duration actionFeedback;
  final Duration stageTransition;

  static const AppMotionTokens base = AppMotionTokens(
    avatarPulse: Duration(milliseconds: 1500),
    screenEntry: Duration(milliseconds: 300),
    actionFeedback: Duration(milliseconds: 150),
    stageTransition: Duration(milliseconds: 200),
  );

  @override
  AppMotionTokens copyWith({
    Duration? avatarPulse,
    Duration? screenEntry,
    Duration? actionFeedback,
    Duration? stageTransition,
  }) {
    return AppMotionTokens(
      avatarPulse: avatarPulse ?? this.avatarPulse,
      screenEntry: screenEntry ?? this.screenEntry,
      actionFeedback: actionFeedback ?? this.actionFeedback,
      stageTransition: stageTransition ?? this.stageTransition,
    );
  }

  @override
  AppMotionTokens lerp(ThemeExtension<AppMotionTokens>? other, double t) {
    if (other is! AppMotionTokens) {
      return this;
    }

    return AppMotionTokens(
      avatarPulse:
          lerpDuration(avatarPulse, other.avatarPulse, t) ?? avatarPulse,
      screenEntry:
          lerpDuration(screenEntry, other.screenEntry, t) ?? screenEntry,
      actionFeedback:
          lerpDuration(actionFeedback, other.actionFeedback, t) ??
          actionFeedback,
      stageTransition:
          lerpDuration(stageTransition, other.stageTransition, t) ??
          stageTransition,
    );
  }
}

@immutable
class AccessibilityTokens extends ThemeExtension<AccessibilityTokens> {
  const AccessibilityTokens({
    required this.minContrastRatio,
    required this.minTouchTarget,
    required this.largeTouchTarget,
    required this.maxSupportedTextScale,
    required this.reduceMotionDuration,
  });

  final double minContrastRatio;
  final double minTouchTarget;
  final double largeTouchTarget;
  final double maxSupportedTextScale;
  final Duration reduceMotionDuration;

  static const AccessibilityTokens base = AccessibilityTokens(
    minContrastRatio: 4.5,
    minTouchTarget: 48,
    largeTouchTarget: 72,
    maxSupportedTextScale: 2.0,
    reduceMotionDuration: Duration.zero,
  );

  @override
  AccessibilityTokens copyWith({
    double? minContrastRatio,
    double? minTouchTarget,
    double? largeTouchTarget,
    double? maxSupportedTextScale,
    Duration? reduceMotionDuration,
  }) {
    return AccessibilityTokens(
      minContrastRatio: minContrastRatio ?? this.minContrastRatio,
      minTouchTarget: minTouchTarget ?? this.minTouchTarget,
      largeTouchTarget: largeTouchTarget ?? this.largeTouchTarget,
      maxSupportedTextScale:
          maxSupportedTextScale ?? this.maxSupportedTextScale,
      reduceMotionDuration: reduceMotionDuration ?? this.reduceMotionDuration,
    );
  }

  @override
  AccessibilityTokens lerp(
    ThemeExtension<AccessibilityTokens>? other,
    double t,
  ) {
    if (other is! AccessibilityTokens) {
      return this;
    }

    return AccessibilityTokens(
      minContrastRatio:
          lerpDouble(minContrastRatio, other.minContrastRatio, t) ??
          minContrastRatio,
      minTouchTarget:
          lerpDouble(minTouchTarget, other.minTouchTarget, t) ?? minTouchTarget,
      largeTouchTarget:
          lerpDouble(largeTouchTarget, other.largeTouchTarget, t) ??
          largeTouchTarget,
      maxSupportedTextScale:
          lerpDouble(maxSupportedTextScale, other.maxSupportedTextScale, t) ??
          maxSupportedTextScale,
      reduceMotionDuration:
          lerpDuration(reduceMotionDuration, other.reduceMotionDuration, t) ??
          reduceMotionDuration,
    );
  }
}

@immutable
class CallThemeTokens extends ThemeExtension<CallThemeTokens> {
  const CallThemeTokens({
    required this.background,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.acceptAction,
    required this.onAcceptAction,
    required this.declineAction,
    required this.onDeclineAction,
    required this.avatarRing,
  });

  final Color background;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
  final Color acceptAction;
  final Color onAcceptAction;
  final Color declineAction;
  final Color onDeclineAction;
  final Color avatarRing;

  static const CallThemeTokens dark = CallThemeTokens(
    background: Color(0xFF101417),
    surface: Color(0xFF182027),
    textPrimary: Color(0xFFF1F4F6),
    textSecondary: Color(0xFFC5CCD2),
    acceptAction: Color(0xFF7DDAA7),
    onAcceptAction: Color(0xFF002111),
    declineAction: Color(0xFFFFB4AB),
    onDeclineAction: Color(0xFF690005),
    avatarRing: Color(0xFF9ACBFF),
  );

  @override
  CallThemeTokens copyWith({
    Color? background,
    Color? surface,
    Color? textPrimary,
    Color? textSecondary,
    Color? acceptAction,
    Color? onAcceptAction,
    Color? declineAction,
    Color? onDeclineAction,
    Color? avatarRing,
  }) {
    return CallThemeTokens(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      acceptAction: acceptAction ?? this.acceptAction,
      onAcceptAction: onAcceptAction ?? this.onAcceptAction,
      declineAction: declineAction ?? this.declineAction,
      onDeclineAction: onDeclineAction ?? this.onDeclineAction,
      avatarRing: avatarRing ?? this.avatarRing,
    );
  }

  @override
  CallThemeTokens lerp(ThemeExtension<CallThemeTokens>? other, double t) {
    if (other is! CallThemeTokens) {
      return this;
    }

    return CallThemeTokens(
      background: Color.lerp(background, other.background, t) ?? background,
      surface: Color.lerp(surface, other.surface, t) ?? surface,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t) ?? textPrimary,
      textSecondary:
          Color.lerp(textSecondary, other.textSecondary, t) ?? textSecondary,
      acceptAction:
          Color.lerp(acceptAction, other.acceptAction, t) ?? acceptAction,
      onAcceptAction:
          Color.lerp(onAcceptAction, other.onAcceptAction, t) ?? onAcceptAction,
      declineAction:
          Color.lerp(declineAction, other.declineAction, t) ?? declineAction,
      onDeclineAction:
          Color.lerp(onDeclineAction, other.onDeclineAction, t) ??
          onDeclineAction,
      avatarRing: Color.lerp(avatarRing, other.avatarRing, t) ?? avatarRing,
    );
  }
}

extension ThemeTokenLookup on ThemeData {
  AppColorTokens get appColors => extension<AppColorTokens>()!;
  AppSpacingTokens get appSpacing => extension<AppSpacingTokens>()!;
  AppComponentSizeTokens get appSizes => extension<AppComponentSizeTokens>()!;
  AppMotionTokens get appMotion => extension<AppMotionTokens>()!;
  AccessibilityTokens get accessibility => extension<AccessibilityTokens>()!;
  CallThemeTokens get callTheme => extension<CallThemeTokens>()!;
}

extension AccessibleMotionContext on BuildContext {
  Duration accessibleMotionDuration(Duration preferredDuration) {
    final mediaQuery = MediaQuery.maybeOf(this);
    if (mediaQuery?.disableAnimations ?? false) {
      return Theme.of(this).accessibility.reduceMotionDuration;
    }
    return preferredDuration;
  }
}

Duration? lerpDuration(Duration a, Duration b, double t) {
  return Duration(
    microseconds:
        lerpDouble(
          a.inMicroseconds.toDouble(),
          b.inMicroseconds.toDouble(),
          t,
        )?.round() ??
        a.inMicroseconds,
  );
}
