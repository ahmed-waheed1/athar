import '../theme/athar_spacing.dart';

/// Sizes from design/screens.md (09 · Notifications) that have no shared
/// token in lib/core/theme.
abstract final class NotificationMetrics {
  // Permission sheet
  static const double bellSize = 120;
  static const double titleTop = AtharSpacing.lg;
  static const double bodyTop = AtharSpacing.xs;
  static const double bodySize = 15;
  static const double actionsTop = AtharSpacing.xl;
  static const double notNowTop = AtharSpacing.xs;

  // Blocked banner
  static const double bannerRadius = AtharRadii.field;
  static const double bannerPadding = AtharSpacing.sm;
  static const double bannerIcon = 20;
  static const double bannerIconGap = AtharSpacing.sm;
  static const double bannerButtonTop = AtharSpacing.sm;
  static const double bannerButtonHeight = 40;
  static const double bannerButtonRadius = AtharRadii.segment;
  static const double bannerButtonPaddingH = AtharSpacing.lg;

  /// A switch that can't be used (notifications blocked).
  static const double disabledSwitchOpacity = 0.45;
}
