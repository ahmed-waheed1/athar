import 'package:flutter/widgets.dart';

import '../../../../core/theme/athar_colors.dart';
import '../../../../core/theme/athar_spacing.dart';

/// Splash sizes and timings from design/screens.md (01 · Splash) that have
/// no shared token in lib/core/theme.
abstract final class SplashMetrics {
  /// The app-icon tile. The native splash images in assets/splash/ draw the
  /// same tile at the same size, centred, so the hand-over doesn't move.
  static const double tile = 120;
  static const double tileRadius = tile * 0.2237;

  /// The mark inside the tile, as in the app icon (485 of 1024).
  static const double mark = tile * 0.474;

  static const double wordmarkGap = 18;
  static const double wordmarkSize = 48;
  static const double wordmarkHeight = 1.2;
  static const double taglineGap = AtharSpacing.lg;
  static const double taglineSize = 17;
  static const double sidePadding = AtharSpacing.xl;

  static const double loaderDot = 8;
  static const double loaderGap = 10;
  static const double loaderBottom = 64;
  static const double loaderMinOpacity = 0.25;

  /// Resting opacities when animations are off.
  static const loaderStillOpacities = [0.25, 0.6, 1.0];

  static const loaderLoop = Duration(milliseconds: 1600);
  static const loaderStagger = Duration(milliseconds: 200);

  /// The tile rises from the centre while the wordmark and tagline fade in.
  static const entrance = Duration(milliseconds: 600);
  static const Curve entranceCurve = Curves.easeOutCubic;

  /// How long the splash stays before routing on.
  static const hold = Duration(milliseconds: 1200);
}

/// Splash colours. They follow the device's dark mode rather than the app's
/// theme setting, because the native splash before it can only do that.
@immutable
class SplashPalette {
  const SplashPalette._({
    required this.background,
    required this.tile,
    required this.mark,
    required this.wordmark,
    required this.tagline,
  });

  static final light = SplashPalette._(
    background: AtharColors.light.primary,
    tile: AtharColors.light.surface,
    mark: AtharColors.light.primary,
    wordmark: AtharColors.light.onPrimary,
    tagline: const Color(0xFFD3EAE2),
  );

  static final dark = SplashPalette._(
    background: AtharColors.dark.background,
    tile: AtharColors.dark.surface,
    mark: AtharColors.dark.primary,
    wordmark: AtharColors.dark.textPrimary,
    tagline: AtharColors.dark.textSecondary,
  );

  static SplashPalette of(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;

  final Color background;
  final Color tile;
  final Color mark;

  /// Wordmark and loader dots.
  final Color wordmark;
  final Color tagline;
}
