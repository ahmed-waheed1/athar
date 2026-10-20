import 'package:flutter/cupertino.dart';
// Builds ThemeData from the Athar tokens. Optional convenience; the three token files work on their own.
import 'package:flutter/material.dart';

import 'athar_colors.dart';
import 'athar_spacing.dart';
import 'athar_typography.dart';

abstract final class AtharTheme {
  static ThemeData light(Locale locale) =>
      _build(AtharColors.light, Brightness.light, locale);
  static ThemeData dark(Locale locale) =>
      _build(AtharColors.dark, Brightness.dark, locale);

  static ThemeData _build(AtharColors c, Brightness brightness, Locale locale) {
    final t = AtharTextStyles.forLocale(locale);
    OutlineInputBorder field(Color color, double width) => OutlineInputBorder(
      borderRadius: AtharRadii.fieldRadius,
      borderSide: BorderSide(color: color, width: width),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: c.toColorScheme(brightness),
      scaffoldBackgroundColor: c.background,
      fontFamily: AtharTextStyles.fontFamily,
      textTheme: t.toTextTheme().apply(
        bodyColor: c.textPrimary,
        displayColor: c.textPrimary,
      ),
      extensions: <ThemeExtension<dynamic>>[c],
      dividerTheme: DividerThemeData(color: c.divider, thickness: 1, space: 1),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(AtharSizes.buttonHeight),
          shape: const RoundedRectangleBorder(
            borderRadius: AtharRadii.buttonRadius,
          ),
          backgroundColor: c.primary,
          foregroundColor: c.onPrimary,
          disabledBackgroundColor: c.surfaceVariant,
          disabledForegroundColor: c.textTertiary,
          textStyle: t.button,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: t.body.copyWith(color: c.textTertiary),
        errorStyle: t.caption.copyWith(color: c.error),
        border: field(c.fieldBorder, 1.5),
        enabledBorder: field(c.fieldBorder, 1.5),
        focusedBorder: field(c.primary, 2),
        errorBorder: field(c.error, 2),
        focusedErrorBorder: field(c.error, 2),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: c.surface,
        indicatorColor: c.primaryContainer,
        labelTextStyle: WidgetStatePropertyAll(t.label),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: c.surface,
        indicatorColor: c.primaryContainer,
        minWidth: AtharSizes.railWidth,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: c.inverseSurface,
        contentTextStyle: t.toast.copyWith(color: c.onInverseSurface),
        // The toast is an inverse surface, so its action uses the opposite theme's primary.
        actionTextColor: brightness == Brightness.light
            ? AtharColors.dark.primary
            : AtharColors.light.primary,
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(
          borderRadius: AtharRadii.cardRadius,
        ),
      ),
      // Push/pop slides with the text direction on both platforms.
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
