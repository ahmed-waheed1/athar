import 'dart:async';
import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/athar_typography.dart';
import '../../../../core/widgets/athar_mark.dart';
import '../widgets/splash_metrics.dart';

/// Splash (design/screens.md · 01). Takes over from the native splash, which
/// shows the same tile in the same place.
///
/// On a [firstLaunch] it adds what the native one can't (the wordmark, the
/// tagline and the loader) and goes on after [SplashMetrics.hold]; the
/// router sends it to onboarding. Later launches show only the tile and go
/// to Home on the first frame, so the only delay is the page fade.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.firstLaunch});

  /// Onboarding isn't done yet.
  final bool firstLaunch;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final _entrance = AnimationController(
    vsync: this,
    duration: SplashMetrics.entrance,
  );
  late final _loader = AnimationController(
    vsync: this,
    duration: SplashMetrics.loaderLoop,
  );
  Timer? _hold;

  @override
  void initState() {
    super.initState();
    // main() keeps the native splash up until this screen has laid out, so
    // the first visible Flutter frame is this one, never a blank one.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlutterNativeSplash.remove();
      if (!mounted) return;
      if (!widget.firstLaunch) {
        context.go(AppRoutes.home);
        return;
      }
      if (MediaQuery.disableAnimationsOf(context)) {
        _entrance.value = 1;
      } else {
        _entrance.forward();
        _loader.repeat();
      }
      _hold = Timer(SplashMetrics.hold, () {
        if (mounted) context.go(AppRoutes.home);
      });
    });
  }

  @override
  void dispose() {
    _hold?.cancel();
    _entrance.dispose();
    _loader.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = SplashPalette.of(MediaQuery.platformBrightnessOf(context));
    final text = AtharTextStyles.forLocale(context.locale);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: palette.background,
        body: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _Tile(palette: palette),
                  if (widget.firstLaunch)
                    // Grows from zero height, so the tile starts exactly where
                    // the native splash left it (the centre) and rises as the
                    // words fade in.
                    AnimatedBuilder(
                      animation: _entrance,
                      builder: (context, child) {
                        final t = SplashMetrics.entranceCurve.transform(
                          _entrance.value,
                        );
                        return Align(
                          alignment: AlignmentDirectional.topCenter,
                          heightFactor: t,
                          child: Opacity(opacity: t, child: child),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsetsDirectional.symmetric(
                          horizontal: SplashMetrics.sidePadding,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: SplashMetrics.wordmarkGap),
                            Text(
                              'app.name'.tr(),
                              textAlign: TextAlign.center,
                              style: text.screenTitle.copyWith(
                                fontSize: SplashMetrics.wordmarkSize,
                                height: SplashMetrics.wordmarkHeight,
                                color: palette.wordmark,
                              ),
                            ),
                            const SizedBox(height: SplashMetrics.taglineGap),
                            Text(
                              'splash.tagline'.tr(),
                              textAlign: TextAlign.center,
                              style: text.body.copyWith(
                                fontSize: SplashMetrics.taglineSize,
                                fontWeight: FontWeight.w500,
                                color: palette.tagline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (widget.firstLaunch)
              PositionedDirectional(
                start: 0,
                end: 0,
                bottom: SplashMetrics.loaderBottom,
                child: _Loader(
                  animation: _loader,
                  color: palette.wordmark,
                  still: MediaQuery.disableAnimationsOf(context),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.palette});

  final SplashPalette palette;

  @override
  Widget build(BuildContext context) => Container(
    width: SplashMetrics.tile,
    height: SplashMetrics.tile,
    decoration: BoxDecoration(
      color: palette.tile,
      borderRadius: const BorderRadius.all(
        Radius.circular(SplashMetrics.tileRadius),
      ),
    ),
    alignment: Alignment.center,
    child: AtharMark(size: SplashMetrics.mark, color: palette.mark),
  );
}

/// Three dots pulsing in sequence. Nothing on the splash mirrors, so the
/// pulse always runs left to right.
class _Loader extends StatelessWidget {
  const _Loader({
    required this.animation,
    required this.color,
    required this.still,
  });

  final Animation<double> animation;
  final Color color;
  final bool still;

  static const _count = 3;

  double _opacity(int index) {
    if (still) return SplashMetrics.loaderStillOpacities[index];
    final stagger =
        SplashMetrics.loaderStagger.inMilliseconds /
        SplashMetrics.loaderLoop.inMilliseconds;
    final phase = (animation.value - index * stagger) % 1;
    // 0.25 -> 1 -> 0.25 over one loop.
    final wave = 0.5 - 0.5 * math.cos(2 * math.pi * phase);
    return SplashMetrics.loaderMinOpacity +
        (1 - SplashMetrics.loaderMinOpacity) * wave;
  }

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, _) => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < _count; i++) ...[
              if (i > 0) const SizedBox(width: SplashMetrics.loaderGap),
              Container(
                width: SplashMetrics.loaderDot,
                height: SplashMetrics.loaderDot,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: _opacity(i)),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}
