import 'package:flutter/material.dart';

import 'design_tokens.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    const colors = AppColorTokens.light;
    const spacing = AppSpacingTokens.base;
    const sizes = AppComponentSizeTokens.base;
    const motion = AppMotionTokens.base;
    const accessibility = AccessibilityTokens.base;
    const callTheme = CallThemeTokens.dark;

    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF2D5F7C),
      onPrimary: Color(0xFFFFFFFF),
      primaryContainer: Color(0xFFD2E4EF),
      onPrimaryContainer: Color(0xFF0F1D26),
      secondary: Color(0xFF5C8A9E),
      onSecondary: Color(0xFFFFFFFF),
      secondaryContainer: Color(0xFFD7E8EF),
      onSecondaryContainer: Color(0xFF112028),
      tertiary: Color(0xFF5F667F),
      onTertiary: Color(0xFFFFFFFF),
      tertiaryContainer: Color(0xFFE2E5F4),
      onTertiaryContainer: Color(0xFF1B2035),
      error: Color(0xFFB3261E),
      onError: Color(0xFFFFFFFF),
      errorContainer: Color(0xFFF9DEDC),
      onErrorContainer: Color(0xFF410E0B),
      surface: Color(0xFFF5F7F9),
      onSurface: Color(0xFF13212B),
      surfaceContainerHighest: Color(0xFFDCE5EB),
      onSurfaceVariant: Color(0xFF41515D),
      outline: Color(0xFF70808B),
      outlineVariant: Color(0xFFB8C4CD),
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      inverseSurface: Color(0xFF28343D),
      onInverseSurface: Color(0xFFECF1F4),
      inversePrimary: Color(0xFFA7CCE1),
      surfaceTint: Color(0xFF2D5F7C),
    );

    return _buildTheme(
      colorScheme: colorScheme,
      colors: colors,
      spacing: spacing,
      sizes: sizes,
      motion: motion,
      accessibility: accessibility,
      callTheme: callTheme,
    );
  }

  static ThemeData dark() {
    const colors = AppColorTokens.dark;
    const spacing = AppSpacingTokens.base;
    const sizes = AppComponentSizeTokens.base;
    const motion = AppMotionTokens.base;
    const accessibility = AccessibilityTokens.base;
    const callTheme = CallThemeTokens.dark;

    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFFA7CCE1),
      onPrimary: Color(0xFF00344C),
      primaryContainer: Color(0xFF104764),
      onPrimaryContainer: Color(0xFFD2E4EF),
      secondary: Color(0xFFB7CCD6),
      onSecondary: Color(0xFF22323B),
      secondaryContainer: Color(0xFF394A54),
      onSecondaryContainer: Color(0xFFD3E8F2),
      tertiary: Color(0xFFC2C8E9),
      onTertiary: Color(0xFF2B3048),
      tertiaryContainer: Color(0xFF42485F),
      onTertiaryContainer: Color(0xFFE2E5F4),
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),
      errorContainer: Color(0xFF93000A),
      onErrorContainer: Color(0xFFFFDAD6),
      surface: Color(0xFF101417),
      onSurface: Color(0xFFF1F4F6),
      surfaceContainerHighest: Color(0xFF33404A),
      onSurfaceVariant: Color(0xFFC5CCD2),
      outline: Color(0xFF8E9AA4),
      outlineVariant: Color(0xFF54606A),
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      inverseSurface: Color(0xFFEAF0F3),
      onInverseSurface: Color(0xFF28343D),
      inversePrimary: Color(0xFF2D5F7C),
      surfaceTint: Color(0xFFA7CCE1),
    );

    return _buildTheme(
      colorScheme: colorScheme,
      colors: colors,
      spacing: spacing,
      sizes: sizes,
      motion: motion,
      accessibility: accessibility,
      callTheme: callTheme,
    );
  }

  static ThemeData _buildTheme({
    required ColorScheme colorScheme,
    required AppColorTokens colors,
    required AppSpacingTokens spacing,
    required AppComponentSizeTokens sizes,
    required AppMotionTokens motion,
    required AccessibilityTokens accessibility,
    required CallThemeTokens callTheme,
  }) {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colors.surfacePrimary,
      canvasColor: colors.surfacePrimary,
      dividerColor: colors.borderSubtle,
      focusColor: colors.focusRing.withValues(alpha: 0.24),
      hoverColor: colors.focusRing.withValues(alpha: 0.08),
      splashColor: colors.focusRing.withValues(alpha: 0.16),
      highlightColor: colors.focusRing.withValues(alpha: 0.12),
      materialTapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.standard,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );

    final textTheme = _textTheme(base.textTheme, colors);
    final actionShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(sizes.cornerRadius),
    );

    return base.copyWith(
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      iconTheme: IconThemeData(color: colors.textPrimary, size: 24),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        backgroundColor: colors.surfacePrimary,
        foregroundColor: colors.textPrimary,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: colors.surfaceSecondary,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(sizes.cardRadius),
          side: BorderSide(color: colors.borderSubtle),
        ),
      ),
      listTileTheme: ListTileThemeData(
        minTileHeight: sizes.settingsTileMinHeight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(sizes.cornerRadius),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: spacing.large,
          vertical: spacing.small,
        ),
        iconColor: colors.textPrimary,
        textColor: colors.textPrimary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          minimumSize: WidgetStatePropertyAll(
            Size(accessibility.minTouchTarget, accessibility.minTouchTarget),
          ),
          padding: WidgetStatePropertyAll(
            EdgeInsets.symmetric(
              horizontal: spacing.large,
              vertical: spacing.medium,
            ),
          ),
          shape: WidgetStatePropertyAll(actionShape),
          textStyle: WidgetStatePropertyAll(textTheme.labelLarge),
          elevation: const WidgetStatePropertyAll(0),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return colorScheme.onSurface.withValues(alpha: 0.12);
            }
            return colorScheme.primary;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return colorScheme.onSurface.withValues(alpha: 0.38);
            }
            return colorScheme.onPrimary;
          }),
          overlayColor: WidgetStatePropertyAll(
            colors.focusRing.withValues(alpha: 0.08),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          minimumSize: WidgetStatePropertyAll(
            Size(accessibility.minTouchTarget, accessibility.minTouchTarget),
          ),
          shape: WidgetStatePropertyAll(actionShape),
          textStyle: WidgetStatePropertyAll(textTheme.labelLarge),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          minimumSize: WidgetStatePropertyAll(
            Size(accessibility.minTouchTarget, accessibility.minTouchTarget),
          ),
          shape: WidgetStatePropertyAll(actionShape),
          side: WidgetStatePropertyAll(BorderSide(color: colors.borderSubtle)),
          textStyle: WidgetStatePropertyAll(textTheme.labelLarge),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceSecondary,
        contentPadding: EdgeInsets.symmetric(
          horizontal: spacing.medium,
          vertical: spacing.medium,
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
        hintStyle: textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(sizes.cornerRadius),
          borderSide: BorderSide(color: colors.borderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(sizes.cornerRadius),
          borderSide: BorderSide(color: colors.borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(sizes.cornerRadius),
          borderSide: BorderSide(color: colors.focusRing, width: 2),
        ),
      ),
      extensions: <ThemeExtension<dynamic>>[
        colors,
        spacing,
        sizes,
        motion,
        accessibility,
        callTheme,
      ],
    );
  }

  static TextTheme _textTheme(TextTheme base, AppColorTokens colors) {
    return base.copyWith(
      headlineMedium: base.headlineMedium?.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: colors.textPrimary,
        height: 1.2,
      ),
      headlineLarge: base.headlineLarge?.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: colors.textPrimary,
        height: 1.15,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: colors.textPrimary,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: colors.textPrimary,
        height: 1.4,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: colors.textSecondary,
        height: 1.4,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: colors.textPrimary,
        letterSpacing: 0.1,
      ),
    );
  }
}
