import '../../../../core/theme/athar_spacing.dart';

/// Onboarding sizes from design/screens.md (02 · Onboarding) that have no
/// shared token in lib/core/theme.
abstract final class OnboardingMetrics {
  static const double topPadding = 52;
  static const double sidePadding = AtharSpacing.xl;
  static const double bottomPadding = 40;
  static const double topBarHeight = 48;

  /// Column width on tablet and wide.
  static const double maxContentWidth = 480;

  /// The illustration box: 290 on phone, up to 340 on tablet and wide. It
  /// shrinks on short screens so the text keeps about [textReserve].
  static const double illustration = 290;
  static const double illustrationLarge = 340;
  static const double illustrationMin = 160;
  static const double textReserve = 250;

  /// Illustrations fade and scale in from this when their slide arrives.
  static const double illustrationEnterScale = 0.94;

  static const double indicatorTop = AtharSpacing.lg;
  static const double indicatorBottom = 18;
  static const double dot = 8;
  static const double dotActive = 24;
  static const double dotGap = 6;
  static const double dotRadius = 4;

  static const double titleGap = AtharSpacing.xs;
  static const double languageTop = AtharSpacing.lg;
  static const double languageIcon = 18;
  static const double languageIconGap = AtharSpacing.xs;
  static const double languageControlGap = AtharSpacing.xs;

  static const double ctaTop = AtharSpacing.xl;
  static const double ctaIcon = 20;
}
