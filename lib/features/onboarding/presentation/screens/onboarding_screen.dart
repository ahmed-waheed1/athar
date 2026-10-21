import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/athar_colors.dart';
import '../../../../core/theme/athar_spacing.dart';
import '../../../../core/theme/athar_typography.dart';
import '../../../../core/utils/localized_numbers.dart';
import '../../../../core/utils/motion.dart';
import '../../../../core/widgets/athar_icon.dart';
import '../../../settings/presentation/cubit/settings_cubit.dart';
import '../widgets/onboarding_metrics.dart';
import '../widgets/onboarding_slide.dart';

/// Onboarding (design/screens.md · 02): three slides, the language picker on
/// the first. Skip and Get started mark onboarding done; the router then
/// moves on to Home.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  bool get _isLast => _page == OnboardingSlide.all.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    final duration = motionDuration(context, AtharMotion.onboardingPage);
    if (duration == Duration.zero) {
      _controller.jumpToPage(_page + 1);
    } else {
      _controller.nextPage(
        duration: duration,
        curve: AtharMotion.onboardingPageCurve,
      );
    }
  }

  void _finish() => context.read<SettingsCubit>().completeOnboarding();

  @override
  Widget build(BuildContext context) {
    final colors = AtharColors.of(context);
    final layout = AtharBreakpoints.of(MediaQuery.sizeOf(context).width);
    final maxIllustration = layout == AtharLayout.phone
        ? OnboardingMetrics.illustration
        : OnboardingMetrics.illustrationLarge;
    const gutter = EdgeInsetsDirectional.symmetric(
      horizontal: OnboardingMetrics.sidePadding,
    );

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: layout == AtharLayout.phone
                  ? double.infinity
                  : OnboardingMetrics.maxContentWidth +
                        2 * OnboardingMetrics.sidePadding,
            ),
            child: Padding(
              padding: const EdgeInsetsDirectional.only(
                top: OnboardingMetrics.topPadding,
                bottom: OnboardingMetrics.bottomPadding,
              ),
              child: Column(
                children: [
                  Padding(
                    padding: gutter,
                    child: SizedBox(
                      height: OnboardingMetrics.topBarHeight,
                      child: Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: _SkipButton(hidden: _isLast, onPressed: _finish),
                      ),
                    ),
                  ),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, area) {
                        final illustrationHeight =
                            (area.maxHeight - OnboardingMetrics.textReserve)
                                .clamp(
                                  OnboardingMetrics.illustrationMin,
                                  maxIllustration,
                                );
                        return Stack(
                          children: [
                            PageView.builder(
                              controller: _controller,
                              itemCount: OnboardingSlide.all.length,
                              onPageChanged: (page) =>
                                  setState(() => _page = page),
                              itemBuilder: (context, index) => Padding(
                                padding: gutter,
                                child: OnboardingSlideView(
                                  slide: OnboardingSlide.all[index],
                                  illustrationHeight: illustrationHeight,
                                  isCurrent: index == _page,
                                ),
                              ),
                            ),
                            // Outside the PageView so it stays put while
                            // the slides move under it.
                            PositionedDirectional(
                              top:
                                  illustrationHeight +
                                  OnboardingMetrics.indicatorTop,
                              start: OnboardingMetrics.sidePadding,
                              child: IgnorePointer(
                                child: _PageIndicator(
                                  controller: _controller,
                                  page: _page,
                                  count: OnboardingSlide.all.length,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: OnboardingMetrics.ctaTop),
                  Padding(
                    padding: gutter,
                    child: FilledButton.icon(
                      onPressed: _isLast ? _finish : _next,
                      iconAlignment: IconAlignment.end,
                      icon: AtharIcon.ui(
                        'next',
                        size: OnboardingMetrics.ctaIcon,
                        color: colors.onPrimary,
                      ),
                      label: Text(
                        (_isLast ? 'onboarding.getStarted' : 'onboarding.next')
                            .tr(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Hidden on the last slide, where Get started does the same thing. It keeps
/// its space so nothing below moves.
class _SkipButton extends StatelessWidget {
  const _SkipButton({required this.hidden, required this.onPressed});

  final bool hidden;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = AtharColors.of(context);
    final text = AtharTextStyles.forLocale(context.locale);
    return ExcludeSemantics(
      excluding: hidden,
      child: IgnorePointer(
        ignoring: hidden,
        child: AnimatedOpacity(
          opacity: hidden ? 0 : 1,
          duration: motionDuration(context, AtharMotion.onboardingPage),
          curve: AtharMotion.onboardingPageCurve,
          child: TextButton(
            onPressed: onPressed,
            style: TextButton.styleFrom(
              foregroundColor: colors.textSecondary,
              textStyle: text.buttonSmall,
              minimumSize: const Size.square(AtharSizes.minTapTarget),
            ),
            child: Text('onboarding.skip'.tr()),
          ),
        ),
      ),
    );
  }
}

/// Pills from the start edge; the active one widens 8 -> 24 and follows the
/// swipe as it happens.
class _PageIndicator extends StatelessWidget {
  const _PageIndicator({
    required this.controller,
    required this.page,
    required this.count,
  });

  final PageController controller;
  final int page;
  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = AtharColors.of(context);
    String number(int value) => LocalizedNumbers.decimal(value, context.locale);

    return Semantics(
      label: 'onboarding.pageIndicator'.tr(
        namedArgs: {'current': number(page + 1), 'total': number(count)},
      ),
      child: ExcludeSemantics(
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            final position =
                controller.hasClients &&
                    controller.position.hasContentDimensions
                ? controller.page!
                : page.toDouble();
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < count; i++) ...[
                  if (i > 0) const SizedBox(width: OnboardingMetrics.dotGap),
                  _Pill(
                    activeness: (1 - (position - i).abs()).clamp(0.0, 1.0),
                    color: colors.primary,
                    restColor: colors.divider,
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.activeness,
    required this.color,
    required this.restColor,
  });

  /// 0 for a resting dot, 1 for the current page.
  final double activeness;
  final Color color;
  final Color restColor;

  @override
  Widget build(BuildContext context) => Container(
    width:
        OnboardingMetrics.dot +
        (OnboardingMetrics.dotActive - OnboardingMetrics.dot) * activeness,
    height: OnboardingMetrics.dot,
    decoration: BoxDecoration(
      color: Color.lerp(restColor, color, activeness),
      borderRadius: const BorderRadius.all(
        Radius.circular(OnboardingMetrics.dotRadius),
      ),
    ),
  );
}
