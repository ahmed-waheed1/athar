import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';

import '../../../../core/theme/athar_colors.dart';
import '../../../../core/theme/athar_spacing.dart';
import '../../../../core/theme/athar_typography.dart';
import '../../../../core/utils/localized_numbers.dart';
import '../../../../core/utils/motion.dart';
import '../../../../core/widgets/check_mark.dart';
import '../cubit/habits_state.dart';
import 'home_metrics.dart';

/// Today's progress: ring, title, subtitle and (phone) progress dots.
class ProgressCard extends StatelessWidget {
  const ProgressCard({super.key, required this.progress, required this.layout});

  final TodayProgress progress;
  final AtharLayout layout;

  @override
  Widget build(BuildContext context) {
    final colors = AtharColors.of(context);
    final text = AtharTextStyles.forLocale(context.locale);
    final locale = context.locale;
    final numbers = LocalizedNumbers.formatter(locale);

    final (ringSize, stroke, padding) = switch (layout) {
      AtharLayout.phone => (
        AtharSizes.ringPhone,
        HomeMetrics.ringStrokePhone,
        const EdgeInsetsDirectional.all(HomeMetrics.progressCardPadding),
      ),
      AtharLayout.tablet => (
        AtharSizes.ringTablet,
        AtharSizes.ringTablet * AtharSizes.ringStrokeRatio,
        const EdgeInsetsDirectional.symmetric(
          vertical: HomeMetrics.tabletProgressPaddingV,
          horizontal: HomeMetrics.tabletProgressPaddingH,
        ),
      ),
      AtharLayout.wide => (
        AtharSizes.ringWideList,
        HomeMetrics.ringStrokeWide,
        const EdgeInsetsDirectional.all(AtharSpacing.md),
      ),
    };

    final title = progress.isAllDone
        ? 'home.progress.allDone'.plural(progress.total, format: numbers)
        : 'home.progress.title'.tr(
            namedArgs: {
              'done': numbers.format(progress.done),
              'total': numbers.format(progress.total),
            },
          );
    final subtitle = progress.isAllDone
        ? 'home.progress.allDoneBody'.tr()
        : progress.done == 0
        ? 'home.progress.waiting'.plural(progress.total, format: numbers)
        : 'home.progress.remaining'.plural(progress.remaining, format: numbers);

    var titleStyle = text.progressTitle.copyWith(color: colors.textPrimary);
    if (layout == AtharLayout.tablet) {
      titleStyle = titleStyle.copyWith(
        fontSize: HomeMetrics.tabletProgressTitleSize,
      );
    }

    final ratio =
        '${numbers.format(progress.done)}/${numbers.format(progress.total)}';

    return Semantics(
      container: true,
      label: '$title. $subtitle',
      excludeSemantics: true,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AtharRadii.section(layout)),
          boxShadow: AtharShadows.card(Theme.of(context).brightness),
        ),
        // Ring and dots animate together from the old value to the new one.
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: progress.fraction),
          duration: motionDuration(context, AtharMotion.ringProgress),
          curve: AtharMotion.ringProgressCurve,
          builder: (context, value, _) => Row(
            children: [
              ProgressRing(
                value: value,
                size: ringSize,
                strokeWidth: stroke,
                child: progress.isAllDone
                    ? CheckMark(
                        size:
                            HomeMetrics.ringCheckSize *
                            ringSize /
                            AtharSizes.ringPhone,
                        color: colors.primary,
                        strokeWidth: HomeMetrics.checkMarkStroke,
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            ratio,
                            style: text.ringValue.copyWith(
                              color: colors.textPrimary,
                              fontSize: switch (layout) {
                                AtharLayout.phone => null,
                                AtharLayout.tablet =>
                                  HomeMetrics.ringValueTabletSize,
                                AtharLayout.wide => text.cardTitle.fontSize,
                              },
                            ),
                          ),
                          if (layout != AtharLayout.wide)
                            Text(
                              LocalizedNumbers.percent(
                                progress.fraction,
                                locale,
                              ),
                              style: text.label.copyWith(
                                color: colors.textTertiary,
                              ),
                            ),
                        ],
                      ),
              ),
              SizedBox(
                width: switch (layout) {
                  AtharLayout.phone => HomeMetrics.progressCardGap,
                  AtharLayout.tablet => AtharSpacing.xxl,
                  AtharLayout.wide => AtharSpacing.md,
                },
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: layout == AtharLayout.wide
                          ? text.cardTitle.copyWith(color: colors.textPrimary)
                          : titleStyle,
                    ),
                    const SizedBox(height: AtharSpacing.xxs),
                    Text(
                      subtitle,
                      style: text.bodySmall.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                    if (layout == AtharLayout.phone) ...[
                      const SizedBox(height: AtharSpacing.sm),
                      ProgressDots(
                        filled: value * progress.total,
                        total: progress.total,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Circular progress starting at 12 o'clock: clockwise in LTR,
/// counter-clockwise in RTL. Only the painter flips; [child] does not.
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.value,
    required this.size,
    required this.strokeWidth,
    this.child,
  });

  /// 0..1.
  final double value;
  final double size;
  final double strokeWidth;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final colors = AtharColors.of(context);
    return SizedBox.square(
      dimension: size,
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          Positioned.fill(
            child: Transform.flip(
              flipX: Directionality.of(context) == TextDirection.rtl,
              child: CustomPaint(
                painter: _RingPainter(
                  value: value,
                  strokeWidth: strokeWidth,
                  track: colors.ringTrack,
                  arc: colors.primary,
                ),
              ),
            ),
          ),
          ?child,
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.value,
    required this.strokeWidth,
    required this.track,
    required this.arc,
  });

  final double value;
  final double strokeWidth;
  final Color track;
  final Color arc;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final ring = rect.deflate(strokeWidth / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawArc(ring, 0, 2 * math.pi, false, paint..color = track);
    final sweep = value.clamp(0.0, 1.0) * 2 * math.pi;
    if (sweep <= 0) return;
    canvas.drawArc(
      ring,
      -math.pi / 2,
      sweep,
      false,
      paint
        ..color = arc
        // A round cap on a full circle would overlap itself at the start.
        ..strokeCap = sweep >= 2 * math.pi ? StrokeCap.butt : StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.value != value ||
      old.strokeWidth != strokeWidth ||
      old.track != track ||
      old.arc != arc;
}

/// One dot per habit, filled from the start edge. [filled] may be fractional
/// while the ring animates; a dot fills once the sweep reaches it.
class ProgressDots extends StatelessWidget {
  const ProgressDots({super.key, required this.filled, required this.total});

  final double filled;
  final int total;

  @override
  Widget build(BuildContext context) {
    final colors = AtharColors.of(context);
    final duration = motionDuration(context, AtharMotion.toastIn);
    return Wrap(
      spacing: HomeMetrics.progressDotGap,
      runSpacing: HomeMetrics.progressDotGap,
      children: [
        for (var i = 0; i < total; i++)
          AnimatedContainer(
            duration: duration,
            width: HomeMetrics.progressDot,
            height: HomeMetrics.progressDot,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: filled >= i + 1 - 0.001 ? colors.primary : null,
              border: filled >= i + 1 - 0.001
                  ? null
                  : Border.all(
                      color: colors.divider,
                      width: HomeMetrics.progressDotRing,
                    ),
            ),
          ),
      ],
    );
  }
}
