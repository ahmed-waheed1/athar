import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/theme/athar_colors.dart';
import '../../../../../core/theme/athar_spacing.dart';
import '../../../../../core/theme/athar_typography.dart';
import '../../../../../core/utils/localized_numbers.dart';
import '../../../../../core/widgets/athar_icon.dart';
import '../../../domain/entities/habit.dart';
import '../../../domain/services/streak_milestones.dart';
import 'confetti_layer.dart';
import 'milestone_metrics.dart';
import 'milestone_ring.dart';

/// The streak milestone celebration (design/screens.md · 07), shown over Home
/// instead of the check-in toast. With reduced motion the card only fades
/// in: no scale, no dot animation and no confetti.
Future<void> showMilestoneCelebration(
  BuildContext context, {
  required Habit habit,
  required int milestone,
}) {
  final colors = AtharColors.of(context);
  final reduceMotion = MediaQuery.disableAnimationsOf(context);
  HapticFeedback.mediumImpact();

  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: colors.scrim,
    transitionDuration: reduceMotion
        ? MilestoneMetrics.reducedMotionFade
        : AtharMotion.dialogIn,
    // Only the card scales; the confetti and scrim just fade in.
    pageBuilder: (context, animation, _) => Stack(
      children: [
        if (!reduceMotion) const Positioned.fill(child: ConfettiLayer()),
        ScaleTransition(
          scale: reduceMotion
              ? const AlwaysStoppedAnimation(1.0)
              : Tween(begin: MilestoneMetrics.scaleFrom, end: 1.0).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: AtharMotion.dialogInCurve,
                  ),
                ),
          child: MilestoneCard(
            habit: habit,
            milestone: milestone,
            ringDelay: reduceMotion ? Duration.zero : AtharMotion.dialogIn,
            animate: !reduceMotion,
          ),
        ),
      ],
    ),
    transitionBuilder: (context, animation, _, child) => FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
      child: child,
    ),
  );
}

class MilestoneCard extends StatelessWidget {
  const MilestoneCard({
    super.key,
    required this.habit,
    required this.milestone,
    this.ringDelay = Duration.zero,
    this.animate = true,
  });

  final Habit habit;
  final int milestone;
  final Duration ringDelay;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final colors = AtharColors.of(context);
    final text = AtharTextStyles.forLocale(context.locale);
    final numbers = LocalizedNumbers.formatter(context.locale);
    final brightness = Theme.of(context).brightness;
    final next = StreakMilestones.nextAfter(milestone);
    final title = 'milestone.title'.plural(milestone, format: numbers);

    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsetsDirectional.all(MilestoneMetrics.cardMargin),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AtharSizes.dialogMaxWidth,
            ),
            child: Semantics(
              scopesRoute: true,
              namesRoute: true,
              explicitChildNodes: true,
              label: title,
              child: Material(
                type: MaterialType.transparency,
                child: Container(
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(AtharRadii.milestone),
                    boxShadow: AtharShadows.raised(brightness),
                  ),
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          MilestoneMetrics.paddingH,
                          MilestoneMetrics.paddingTop,
                          MilestoneMetrics.paddingH,
                          MilestoneMetrics.paddingBottom,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            MilestoneRing(
                              milestone: milestone,
                              color: colors.accent(habit.colorKey).color,
                              delay: ringDelay,
                              animate: animate,
                              child: _RingCentre(milestone: milestone),
                            ),
                            const SizedBox(
                              height: MilestoneMetrics.ringToTitle,
                            ),
                            Text(
                              title,
                              textAlign: TextAlign.center,
                              style: text.greeting.copyWith(
                                color: colors.textPrimary,
                              ),
                            ),
                            const SizedBox(
                              height: MilestoneMetrics.titleToBody,
                            ),
                            Text(
                              'milestone.body.$milestone'.tr(
                                namedArgs: {
                                  'name': habit.name,
                                  'count': numbers.format(milestone),
                                },
                              ),
                              textAlign: TextAlign.center,
                              style: text.body.copyWith(
                                color: colors.textSecondary,
                              ),
                            ),
                            if (next != null) ...[
                              const SizedBox(
                                height: MilestoneMetrics.bodyToPill,
                              ),
                              _NextMilestonePill(next: next),
                            ],
                            const SizedBox(
                              height: MilestoneMetrics.pillToButton,
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: () => Navigator.of(context).pop(),
                                style: FilledButton.styleFrom(
                                  minimumSize: const Size.fromHeight(
                                    AtharSizes.buttonHeight,
                                  ),
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: AtharRadii.buttonRadius,
                                  ),
                                  textStyle: text.button,
                                ),
                                child: Text('milestone.keepGoing'.tr()),
                              ),
                            ),
                          ],
                        ),
                      ),
                      PositionedDirectional(
                        top: MilestoneMetrics.closeInset,
                        end: MilestoneMetrics.closeInset,
                        child: IconButton(
                          tooltip: MaterialLocalizations.of(context)
                              .closeButtonTooltip,
                          onPressed: () => Navigator.of(context).pop(),
                          constraints: const BoxConstraints.tightFor(
                            width: AtharSizes.minTapTarget,
                            height: AtharSizes.minTapTarget,
                          ),
                          icon: AtharIcon.ui(
                            'close',
                            size: MilestoneMetrics.closeIcon,
                            color: colors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Flame, the number and "days" in the plural form for it.
class _RingCentre extends StatelessWidget {
  const _RingCentre({required this.milestone});

  final int milestone;

  @override
  Widget build(BuildContext context) {
    final colors = AtharColors.of(context);
    final text = AtharTextStyles.forLocale(context.locale);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AtharIcon.ui(
          'flame',
          size: MilestoneMetrics.flame,
          color: colors.flame,
        ),
        Text(
          LocalizedNumbers.decimal(milestone, context.locale),
          style: text.milestoneNumber.copyWith(color: colors.textPrimary),
        ),
        Text(
          'details.daysUnit'.plural(milestone),
          style: text.label.copyWith(
            fontSize: MilestoneMetrics.unitSize,
            fontWeight: FontWeight.w700,
            color: colors.textTertiary,
          ),
        ),
      ],
    );
  }
}

class _NextMilestonePill extends StatelessWidget {
  const _NextMilestonePill({required this.next});

  final int next;

  @override
  Widget build(BuildContext context) {
    final colors = AtharColors.of(context);
    final text = AtharTextStyles.forLocale(context.locale);
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(
        vertical: MilestoneMetrics.pillPaddingV,
        horizontal: MilestoneMetrics.pillPaddingH,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(AtharRadii.full),
      ),
      child: Text(
        'milestone.next'.tr(
          namedArgs: {
            'days': 'plural.days'.plural(
              next,
              format: LocalizedNumbers.formatter(context.locale),
            ),
          },
        ),
        style: text.caption.copyWith(
          fontWeight: FontWeight.w700,
          color: colors.textSecondary,
        ),
      ),
    );
  }
}
