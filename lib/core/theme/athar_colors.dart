// GENERATED from the Athar design tokens (design-tokens.json). Values match the Athar design canvas.
// Usage: ThemeData(extensions: [AtharColors.light]) and AtharColors.of(context).primary
import 'package:flutter/material.dart';

/// One habit accent color with its soft chip background and the color to draw on top of it.
@immutable
class HabitAccent {
  const HabitAccent({
    required this.id,
    required this.color,
    required this.soft,
    required this.onColor,
  });

  /// Stable id stored in the database (indigo, sky, teal, leaf, amber, coral, rose, plum).
  final String id;
  final Color color;

  /// 12% (light) / 18% (dark) tint for icon chips and selected icon cells.
  final Color soft;

  /// Check mark / text drawn on [color].
  final Color onColor;

  static HabitAccent lerp(HabitAccent a, HabitAccent b, double t) =>
      HabitAccent(
        id: t < 0.5 ? a.id : b.id,
        color: Color.lerp(a.color, b.color, t)!,
        soft: Color.lerp(a.soft, b.soft, t)!,
        onColor: Color.lerp(a.onColor, b.onColor, t)!,
      );
}

/// Heatmap colors. A single habit's heatmap paints done days with the habit accent;
/// the all-habits heatmap uses [levels] (index 0..3 = 1-25%, 26-50%, 51-75%, 76-100% of habits done).
@immutable
class HeatmapColors {
  const HeatmapColors({
    required this.noData,
    required this.missed,
    required this.levels,
  });

  /// Days before the habit existed / no history yet.
  final Color noData;

  /// Past day with no completion.
  final Color missed;

  /// Filled levels 1-4 (lightest to strongest).
  final List<Color> levels;

  static HeatmapColors lerp(HeatmapColors a, HeatmapColors b, double t) =>
      HeatmapColors(
        noData: Color.lerp(a.noData, b.noData, t)!,
        missed: Color.lerp(a.missed, b.missed, t)!,
        levels: List<Color>.generate(
          a.levels.length,
          (i) => Color.lerp(a.levels[i], b.levels[i], t)!,
        ),
      );
}

@immutable
class AtharColors extends ThemeExtension<AtharColors> {
  const AtharColors({
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.divider,
    required this.fieldBorder,
    required this.success,
    required this.onSuccess,
    required this.error,
    required this.onError,
    required this.errorContainer,
    required this.flame,
    required this.flameSoft,
    required this.ringTrack,
    required this.inverseSurface,
    required this.onInverseSurface,
    required this.scrim,
    required this.heatmap,
    required this.accents,
  });

  /// Brand green: primary buttons, progress ring, active nav, links. Light #1E6B5A · Dark #6CCBAF
  final Color primary;

  /// Text/icons on primary. Light #FFFFFF · Dark #08241D
  final Color onPrimary;

  /// Tonal buttons, nav pill, soft brand chips. Light #DCEEE8 · Dark #1B3A31
  final Color primaryContainer;

  /// Text/icons on primaryContainer. Light #134E40 · Dark #A8E5D2
  final Color onPrimaryContainer;

  /// Scaffold background. Light #F4F6F5 · Dark #0E1412
  final Color background;

  /// Cards, sheets, dialogs, nav bar, rail. Light #FFFFFF · Dark #161F1C
  final Color surface;

  /// Segmented-control track, secondary buttons, swipe-action backdrop, no-data cells. Light #EAEFED · Dark #1F2A26
  final Color surfaceVariant;

  /// Headings and body text. Light #13201C · Dark #E8EFEC
  final Color textPrimary;

  /// Supporting text, field labels. Light #46554F · Dark #B6C4BF
  final Color textSecondary;

  /// Dates, captions, inactive nav, future calendar days. Light #5C6B65 · Dark #93A39D
  final Color textTertiary;

  /// Dividers, card/frame borders, empty progress dots. Light #DCE3E0 · Dark #2A3632
  final Color divider;

  /// Resting text-field border, switch off track border. Light #8A9893 · Dark #5E6D67
  final Color fieldBorder;

  /// Positive state (same value as the Leaf habit accent). Light #3F8F4B · Dark #6CC17A
  final Color success;

  /// Icons on success. Light #FFFFFF · Dark #0E1412
  final Color onSuccess;

  /// Delete, reset, validation errors. Light #B3261E · Dark #F2B8B5
  final Color error;

  /// Text on error buttons. Light #FFFFFF · Dark #601410
  final Color onError;

  /// Soft error chips (delete/reset icon tiles). Light #FBE4E2 · Dark #3B1F1D
  final Color errorContainer;

  /// Streak flame icon + streak label. Light #C4521F · Dark #F2925A
  final Color flame;

  /// Soft background behind the flame (toast, badges). Dark = flame at 18% alpha (AARRGGBB). Light #FBE6DB · Dark #2EF2925A
  final Color flameSoft;

  /// Progress-ring track. Light #E3E9E7 · Dark #25302C
  final Color ringTrack;

  /// Toast / snackbar background. Light #13201C · Dark #E8EFEC
  final Color inverseSurface;

  /// Toast / snackbar text. Light #E8EFEC · Dark #13201C
  final Color onInverseSurface;

  /// Modal scrim (AARRGGBB): light 50% #0A1411, dark 66% black. Light #800A1411 · Dark #A8000000
  final Color scrim;

  final HeatmapColors heatmap;

  /// The 8 habit accents, in picker order.
  final List<HabitAccent> accents;

  /// Accent by stored id; falls back to the first accent.
  HabitAccent accent(String id) =>
      accents.firstWhere((a) => a.id == id, orElse: () => accents.first);

  static AtharColors of(BuildContext context) =>
      Theme.of(context).extension<AtharColors>()!;

  static const light = AtharColors(
    primary: Color(0xFF1E6B5A),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFDCEEE8),
    onPrimaryContainer: Color(0xFF134E40),
    background: Color(0xFFF4F6F5),
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFEAEFED),
    textPrimary: Color(0xFF13201C),
    textSecondary: Color(0xFF46554F),
    textTertiary: Color(0xFF5C6B65),
    divider: Color(0xFFDCE3E0),
    fieldBorder: Color(0xFF8A9893),
    success: Color(0xFF3F8F4B),
    onSuccess: Color(0xFFFFFFFF),
    error: Color(0xFFB3261E),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFBE4E2),
    flame: Color(0xFFC4521F),
    flameSoft: Color(0xFFFBE6DB),
    ringTrack: Color(0xFFE3E9E7),
    inverseSurface: Color(0xFF13201C),
    onInverseSurface: Color(0xFFE8EFEC),
    scrim: Color(0x800A1411),
    heatmap: HeatmapColors(
      noData: Color(0xFFEAEFED),
      missed: Color(0xFFE3E9E7),
      levels: [
        Color(0xFFB9DDD0),
        Color(0xFF79C2A8),
        Color(0xFF2F8C72),
        Color(0xFF1E6B5A),
      ],
    ),
    accents: [
      HabitAccent(
        id: 'indigo',
        color: Color(0xFF5257C4),
        soft: Color(0x1F5257C4),
        onColor: Color(0xFFFFFFFF),
      ), // Indigo · نيلي
      HabitAccent(
        id: 'sky',
        color: Color(0xFF2F7CC0),
        soft: Color(0x1F2F7CC0),
        onColor: Color(0xFFFFFFFF),
      ), // Sky · سماوي
      HabitAccent(
        id: 'teal',
        color: Color(0xFF1B857A),
        soft: Color(0x1F1B857A),
        onColor: Color(0xFFFFFFFF),
      ), // Teal · فيروزي
      HabitAccent(
        id: 'leaf',
        color: Color(0xFF3F8F4B),
        soft: Color(0x1F3F8F4B),
        onColor: Color(0xFFFFFFFF),
      ), // Leaf · أخضر
      HabitAccent(
        id: 'amber',
        color: Color(0xFFB8740A),
        soft: Color(0x1FB8740A),
        onColor: Color(0xFFFFFFFF),
      ), // Amber · كهرماني
      HabitAccent(
        id: 'coral',
        color: Color(0xFFD0502F),
        soft: Color(0x1FD0502F),
        onColor: Color(0xFFFFFFFF),
      ), // Coral · مرجاني
      HabitAccent(
        id: 'rose',
        color: Color(0xFFC2405F),
        soft: Color(0x1FC2405F),
        onColor: Color(0xFFFFFFFF),
      ), // Rose · وردي
      HabitAccent(
        id: 'plum',
        color: Color(0xFF9348AE),
        soft: Color(0x1F9348AE),
        onColor: Color(0xFFFFFFFF),
      ), // Plum · بنفسجي
    ],
  );

  static const dark = AtharColors(
    primary: Color(0xFF6CCBAF),
    onPrimary: Color(0xFF08241D),
    primaryContainer: Color(0xFF1B3A31),
    onPrimaryContainer: Color(0xFFA8E5D2),
    background: Color(0xFF0E1412),
    surface: Color(0xFF161F1C),
    surfaceVariant: Color(0xFF1F2A26),
    textPrimary: Color(0xFFE8EFEC),
    textSecondary: Color(0xFFB6C4BF),
    textTertiary: Color(0xFF93A39D),
    divider: Color(0xFF2A3632),
    fieldBorder: Color(0xFF5E6D67),
    success: Color(0xFF6CC17A),
    onSuccess: Color(0xFF0E1412),
    error: Color(0xFFF2B8B5),
    onError: Color(0xFF601410),
    errorContainer: Color(0xFF3B1F1D),
    flame: Color(0xFFF2925A),
    flameSoft: Color(0x2EF2925A),
    ringTrack: Color(0xFF25302C),
    inverseSurface: Color(0xFFE8EFEC),
    onInverseSurface: Color(0xFF13201C),
    scrim: Color(0xA8000000),
    heatmap: HeatmapColors(
      noData: Color(0xFF1F2A26),
      missed: Color(0xFF25302C),
      levels: [
        Color(0xFF1F4D40),
        Color(0xFF2D7A63),
        Color(0xFF4FAE90),
        Color(0xFF7FDCBD),
      ],
    ),
    accents: [
      HabitAccent(
        id: 'indigo',
        color: Color(0xFF8A8EF0),
        soft: Color(0x2E8A8EF0),
        onColor: Color(0xFF0E1412),
      ), // Indigo · نيلي
      HabitAccent(
        id: 'sky',
        color: Color(0xFF5FA8E8),
        soft: Color(0x2E5FA8E8),
        onColor: Color(0xFF0E1412),
      ), // Sky · سماوي
      HabitAccent(
        id: 'teal',
        color: Color(0xFF4CC3B5),
        soft: Color(0x2E4CC3B5),
        onColor: Color(0xFF0E1412),
      ), // Teal · فيروزي
      HabitAccent(
        id: 'leaf',
        color: Color(0xFF6CC17A),
        soft: Color(0x2E6CC17A),
        onColor: Color(0xFF0E1412),
      ), // Leaf · أخضر
      HabitAccent(
        id: 'amber',
        color: Color(0xFFE9A93E),
        soft: Color(0x2EE9A93E),
        onColor: Color(0xFF0E1412),
      ), // Amber · كهرماني
      HabitAccent(
        id: 'coral',
        color: Color(0xFFF08A6C),
        soft: Color(0x2EF08A6C),
        onColor: Color(0xFF0E1412),
      ), // Coral · مرجاني
      HabitAccent(
        id: 'rose',
        color: Color(0xFFEE7C99),
        soft: Color(0x2EEE7C99),
        onColor: Color(0xFF0E1412),
      ), // Rose · وردي
      HabitAccent(
        id: 'plum',
        color: Color(0xFFC485DB),
        soft: Color(0x2EC485DB),
        onColor: Color(0xFF0E1412),
      ), // Plum · بنفسجي
    ],
  );

  /// Material 3 ColorScheme built from the tokens, for ThemeData(colorScheme: ...).
  ColorScheme toColorScheme(Brightness brightness) => ColorScheme(
    brightness: brightness,
    primary: primary,
    onPrimary: onPrimary,
    primaryContainer: primaryContainer,
    onPrimaryContainer: onPrimaryContainer,
    secondary: primary,
    onSecondary: onPrimary,
    secondaryContainer: primaryContainer,
    onSecondaryContainer: onPrimaryContainer,
    tertiary: flame,
    onTertiary: onPrimary,
    error: error,
    onError: onError,
    errorContainer: errorContainer,
    onErrorContainer: error,
    surface: surface,
    onSurface: textPrimary,
    onSurfaceVariant: textSecondary,
    surfaceContainerLowest: surface,
    surfaceContainerLow: background,
    surfaceContainer: background,
    surfaceContainerHigh: surfaceVariant,
    surfaceContainerHighest: surfaceVariant,
    outline: fieldBorder,
    outlineVariant: divider,
    inverseSurface: inverseSurface,
    onInverseSurface: onInverseSurface,
    inversePrimary: primaryContainer,
    scrim: scrim,
    shadow: const Color(0xFF000000),
  );

  @override
  AtharColors copyWith({
    Color? primary,
    Color? onPrimary,
    Color? primaryContainer,
    Color? onPrimaryContainer,
    Color? background,
    Color? surface,
    Color? surfaceVariant,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? divider,
    Color? fieldBorder,
    Color? success,
    Color? onSuccess,
    Color? error,
    Color? onError,
    Color? errorContainer,
    Color? flame,
    Color? flameSoft,
    Color? ringTrack,
    Color? inverseSurface,
    Color? onInverseSurface,
    Color? scrim,
    HeatmapColors? heatmap,
    List<HabitAccent>? accents,
  }) => AtharColors(
    primary: primary ?? this.primary,
    onPrimary: onPrimary ?? this.onPrimary,
    primaryContainer: primaryContainer ?? this.primaryContainer,
    onPrimaryContainer: onPrimaryContainer ?? this.onPrimaryContainer,
    background: background ?? this.background,
    surface: surface ?? this.surface,
    surfaceVariant: surfaceVariant ?? this.surfaceVariant,
    textPrimary: textPrimary ?? this.textPrimary,
    textSecondary: textSecondary ?? this.textSecondary,
    textTertiary: textTertiary ?? this.textTertiary,
    divider: divider ?? this.divider,
    fieldBorder: fieldBorder ?? this.fieldBorder,
    success: success ?? this.success,
    onSuccess: onSuccess ?? this.onSuccess,
    error: error ?? this.error,
    onError: onError ?? this.onError,
    errorContainer: errorContainer ?? this.errorContainer,
    flame: flame ?? this.flame,
    flameSoft: flameSoft ?? this.flameSoft,
    ringTrack: ringTrack ?? this.ringTrack,
    inverseSurface: inverseSurface ?? this.inverseSurface,
    onInverseSurface: onInverseSurface ?? this.onInverseSurface,
    scrim: scrim ?? this.scrim,
    heatmap: heatmap ?? this.heatmap,
    accents: accents ?? this.accents,
  );

  @override
  AtharColors lerp(ThemeExtension<AtharColors>? other, double t) {
    if (other is! AtharColors) return this;
    return AtharColors(
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      primaryContainer: Color.lerp(
        primaryContainer,
        other.primaryContainer,
        t,
      )!,
      onPrimaryContainer: Color.lerp(
        onPrimaryContainer,
        other.onPrimaryContainer,
        t,
      )!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      fieldBorder: Color.lerp(fieldBorder, other.fieldBorder, t)!,
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      error: Color.lerp(error, other.error, t)!,
      onError: Color.lerp(onError, other.onError, t)!,
      errorContainer: Color.lerp(errorContainer, other.errorContainer, t)!,
      flame: Color.lerp(flame, other.flame, t)!,
      flameSoft: Color.lerp(flameSoft, other.flameSoft, t)!,
      ringTrack: Color.lerp(ringTrack, other.ringTrack, t)!,
      inverseSurface: Color.lerp(inverseSurface, other.inverseSurface, t)!,
      onInverseSurface: Color.lerp(
        onInverseSurface,
        other.onInverseSurface,
        t,
      )!,
      scrim: Color.lerp(scrim, other.scrim, t)!,
      heatmap: HeatmapColors.lerp(heatmap, other.heatmap, t),
      accents: List<HabitAccent>.generate(
        accents.length,
        (i) => HabitAccent.lerp(accents[i], other.accents[i], t),
      ),
    );
  }
}
