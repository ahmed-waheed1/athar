import '../../../../../core/theme/athar_spacing.dart';

/// Habit Details sizes from design/screens.md (06) that have no shared token
/// in lib/core/theme. Kept here so widgets never inline them.
abstract final class HabitDetailsMetrics {
  // Screen
  static const double topPadding = 44;
  static const double sectionGap = 14;
  static const double topBarIcon = 24;

  /// The back and edit icons line up with the gutter.
  static const double topBarInset = (AtharSizes.minTapTarget - topBarIcon) / 2;
  static const double columnGap = AtharSpacing.md;

  // Header
  static const double headerTileRadius = AtharRadii.button;
  static const double headerIcon = 28;
  static const double headerGap = 14;
  static const double editButtonHeight = AtharSizes.minTapTarget;
  static const double editButtonRadius = AtharRadii.chip;
  static const double editButtonBorder = 1.5;
  static const double editButtonIcon = 20;

  // Streak hero
  static const double heroRadius = AtharRadii.sectionTablet;
  static const double heroPaddingV = AtharSpacing.lg;
  static const double heroPaddingH = 22;
  static const double heroLabelSize = 14;
  static const double heroNumberTablet = 64;
  static const double heroUnitSize = 18;
  static const double heroUnitGap = AtharSpacing.sm;
  static const double heroNoteSize = 14;
  static const double heroFlame = 64;
  static const double heroFlameOpacity = 0.92;
  static const double heroFlameMutedOpacity = 0.5;
  static const countUp = Duration(milliseconds: 600);

  // Stat tiles
  static const double statRadius = AtharRadii.card;
  static const double statPaddingV = AtharSpacing.sm;
  static const double statPaddingH = 14;
  static const double statGap = 10;

  // Section cards
  static const double sectionPadding = AtharSpacing.md;
  static const double sectionTitleGap = AtharSpacing.md;

  // Heatmap
  static const int heatmapWeeksPhone = 18;
  static const int heatmapWeeksLarge = 26;
  static const double heatmapLegendCell = 10;
  static const double heatmapTodayGap = 2;
  static const double heatmapTodayRing = 1.5;

  // Calendar
  static const double calendarNavButton = AtharSizes.minTapTarget;
  static const double calendarNavIcon = 24;
  static const double calendarNavDisabledOpacity = 0.35;
  static const double calendarWeekdayHeight = 24;
  static const double calendarGap = 4;
  static const double calendarCellPhone = 40;
  static const double calendarCellTablet = 38;
  static const double calendarCellWide = 34;
  static const double calendarTodayRing = 2;
  static const double calendarMaxWidthTablet = 420;
  static const monthSlide = Duration(milliseconds: 250);

  // This month (tablet)
  static const double thisMonthNumber = 56;
  static const double thisMonthDot = 14;
  static const double thisMonthDotGap = AtharSpacing.xs;
  static const double thisMonthDotRing = 2;

  static double calendarCell(AtharLayout layout) => switch (layout) {
    AtharLayout.phone => calendarCellPhone,
    AtharLayout.tablet => calendarCellTablet,
    AtharLayout.wide => calendarCellWide,
  };
}
