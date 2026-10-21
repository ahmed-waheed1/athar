import '../../../../../core/theme/athar_spacing.dart';

/// Milestone celebration sizes and timings from design/screens.md (07) that
/// have no shared token in lib/core/theme.
abstract final class MilestoneMetrics {
  // Card
  static const double scaleFrom = 0.92;
  static const double cardMargin = AtharSpacing.lg;
  static const double paddingTop = 28;
  static const double paddingH = AtharSpacing.xl;
  static const double paddingBottom = AtharSpacing.xl;
  static const double closeInset = AtharSpacing.xs;
  static const double closeIcon = AtharSpacing.xl;

  // Ring
  static const double ringBox = 180;
  static const double ringRadius = 78;
  static const double flame = 28;
  static const double unitSize = 14;

  /// Dot diameter per milestone (milestone-ring-*.svg).
  static double dotSize(int milestone) => switch (milestone) {
    <= 7 => 20,
    <= 30 => 11,
    _ => 5,
  };

  /// Delay between dots popping in; the 100 ring is denser, so faster.
  static Duration dotStagger(int milestone) => milestone >= 100
      ? const Duration(milliseconds: 12)
      : AtharMotion.milestoneDotStagger;

  /// How long each dot takes to pop in.
  static const dotPop = Duration(milliseconds: 500);

  // Text
  static const double ringToTitle = AtharSpacing.lg;
  static const double titleToBody = AtharSpacing.xs;
  static const double bodyToPill = AtharSpacing.md;
  static const double pillPaddingV = 6;
  static const double pillPaddingH = 14;
  static const double pillToButton = AtharSpacing.lg;

  // Confetti
  static const int confettiPieces = 36;
  static const double confettiRectWidth = 8;
  static const double confettiRectHeight = 14;
  static const double confettiRectRadius = 2;
  static const double confettiCircle = 10;

  /// Pieces start this far above the screen and end this far below it.
  static const double confettiOverscan = 40;
  static const confettiMinFall = Duration(milliseconds: 2600);
  static const confettiMaxFall = Duration(milliseconds: 4200);

  /// Total rotation over one fall: 540°.
  static const double confettiTurns = 1.5;

  /// Reduced motion: the card only fades in, over this long.
  static const reducedMotionFade = Duration(milliseconds: 200);
}
