import '../../../../core/theme/athar_spacing.dart';

/// Settings sizes from design/screens.md (08 · Settings) that have no shared
/// token in lib/core/theme. Kept here so widgets never inline them.
abstract final class SettingsMetrics {
  static const double topPadding = 52;
  static const double maxContentWidth = 560;
  static const double labelGap = 10;
  static const double sectionGap = 18;
  static const double labelInset = AtharSpacing.xxs;
  static const double labelSize = 13;

  // Groups
  static const double groupRadius = 22;
  static const double groupPadding = 6;
  static const double rowMinHeight = 60;
  static const double rowPaddingV = AtharSpacing.xs;
  static const double rowPaddingH = AtharSpacing.sm;
  static const double rowIconTile = 40;
  static const double rowIconTileRadius = AtharSpacing.sm;
  static const double rowIcon = 22;
  static const double rowGap = AtharSpacing.sm;
  static const double dividerInset = AtharSpacing.sm;

  static const double versionTop = AtharSpacing.xl;

  /// Theme switches cross-fade (AnimatedTheme) over this long.
  static const themeChange = Duration(milliseconds: 300);
}
