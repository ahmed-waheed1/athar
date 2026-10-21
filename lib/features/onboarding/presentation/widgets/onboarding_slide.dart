import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/athar_assets.dart';
import '../../../../core/theme/athar_colors.dart';
import '../../../../core/theme/athar_spacing.dart';
import '../../../../core/theme/athar_typography.dart';
import '../../../../core/utils/motion.dart';
import '../../../../core/widgets/athar_icon.dart';
import '../../../settings/presentation/widgets/settings_controls.dart';
import 'onboarding_metrics.dart';

/// One onboarding slide's content.
class OnboardingSlide {
  const OnboardingSlide({
    required this.illustration,
    required this.illustrationSize,
    required this.key,
    this.cardRadius,
    this.hasRtlArtwork = false,
    this.hasLanguagePicker = false,
  });

  /// Slug in assets/illustrations/onboarding-{slug}-{light,dark}.svg.
  final String illustration;

  /// Size of the illustration in the 290 phone box.
  final Size illustrationSize;

  /// Translation group under `onboarding.slides`.
  final String key;

  /// The illustration is a card: give it the card shadow with this radius.
  final double? cardRadius;

  /// Uses its own -rtl artwork in RTL instead of being flipped.
  final bool hasRtlArtwork;
  final bool hasLanguagePicker;

  String get titleKey => 'onboarding.slides.$key.title';
  String get bodyKey => 'onboarding.slides.$key.body';

  static const all = [
    OnboardingSlide(
      illustration: '1-trace',
      illustrationSize: Size(240, 240),
      key: 'trace',
      // The dots move to the other side; the check mark must not mirror.
      hasRtlArtwork: true,
      hasLanguagePicker: true,
    ),
    OnboardingSlide(
      illustration: '2-path',
      illustrationSize: Size(270, 234),
      key: 'path',
      cardRadius: 28,
    ),
    OnboardingSlide(
      illustration: '3-private',
      illustrationSize: Size(184, 274),
      key: 'private',
    ),
  ];
}

/// Illustration box, room for the page indicator (drawn by the screen on
/// top), then the text. Only the text scrolls, and only when a short screen
/// or large text needs it.
class OnboardingSlideView extends StatelessWidget {
  const OnboardingSlideView({
    super.key,
    required this.slide,
    required this.illustrationHeight,
    required this.isCurrent,
  });

  final OnboardingSlide slide;
  final double illustrationHeight;

  /// The slide on screen: its illustration fades and scales in.
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final colors = AtharColors.of(context);
    final text = AtharTextStyles.forLocale(context.locale);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: illustrationHeight,
          child: Center(
            child: _Illustration(
              slide: slide,
              scale: illustrationHeight / OnboardingMetrics.illustration,
              isCurrent: isCurrent,
            ),
          ),
        ),
        const SizedBox(
          height:
              OnboardingMetrics.indicatorTop +
              OnboardingMetrics.dot +
              OnboardingMetrics.indicatorBottom,
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    context.tr(slide.titleKey),
                    style: text.screenTitle.copyWith(color: colors.textPrimary),
                  ),
                ),
                const SizedBox(height: OnboardingMetrics.titleGap),
                Text(
                  context.tr(slide.bodyKey),
                  style: text.body.copyWith(color: colors.textSecondary),
                ),
                if (slide.hasLanguagePicker) ...[
                  const SizedBox(height: OnboardingMetrics.languageTop),
                  Row(
                    children: [
                      AtharIcon.ui(
                        'globe',
                        size: OnboardingMetrics.languageIcon,
                        color: colors.textSecondary,
                      ),
                      const SizedBox(width: OnboardingMetrics.languageIconGap),
                      Text(
                        context.tr('settings.language'),
                        style: text.fieldLabel.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: OnboardingMetrics.languageControlGap),
                  // Rebuilds the whole app in the new language and direction
                  // without leaving this slide.
                  const LanguageControl(),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Light or dark artwork to match the theme, mirrored in RTL like the
/// Arabic designs (e.g. the slide 3 lock badge moves to the start-bottom
/// corner).
class _Illustration extends StatelessWidget {
  const _Illustration({
    required this.slide,
    required this.scale,
    required this.isCurrent,
  });

  final OnboardingSlide slide;
  final double scale;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final duration = motionDuration(context, AtharMotion.onboardingPage);
    final size = slide.illustrationSize * scale;

    Widget art = SvgPicture.asset(
      AtharAssets.onboarding(
        slide.illustration,
        brightness,
        rtl: isRtl && slide.hasRtlArtwork,
      ),
      width: size.width,
      height: size.height,
      excludeFromSemantics: true,
    );
    if (slide.cardRadius case final radius?) {
      art = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(radius * scale)),
          boxShadow: AtharShadows.card(brightness),
        ),
        child: art,
      );
    }

    return AnimatedOpacity(
      opacity: isCurrent ? 1 : 0,
      duration: duration,
      curve: AtharMotion.onboardingPageCurve,
      child: AnimatedScale(
        scale: isCurrent ? 1 : OnboardingMetrics.illustrationEnterScale,
        duration: duration,
        curve: AtharMotion.onboardingPageCurve,
        child: Transform.flip(flipX: isRtl && !slide.hasRtlArtwork, child: art),
      ),
    );
  }
}
