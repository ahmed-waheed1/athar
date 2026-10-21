import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../core/theme/athar_colors.dart';
import '../../../../../core/theme/athar_spacing.dart';
import '../../../../../core/theme/athar_typography.dart';
import '../../../../../core/utils/localized_numbers.dart';
import '../../../../../core/widgets/athar_icon.dart';
import '../../cubit/habit_details_state.dart';
import 'habit_details_metrics.dart';

/// The current-streak card: accent while a streak runs, muted once it
/// breaks, and `primaryContainer` before the first check-in.
class StreakHero extends StatelessWidget {
  const StreakHero({
    super.key,
    required this.stats,
    required this.accent,
    required this.layout,
  });

  final HabitStats stats;
  final HabitAccent accent;
  final AtharLayout layout;

  String _note(BuildContext context, NumberFormat numbers) {
    final best = numbers.format(stats.bestStreak);
    return switch (stats.status) {
      StreakStatus.fresh => context.tr('details.note.first'),
      StreakStatus.broken => context.tr(
        'details.note.paused',
        namedArgs: {'best': best},
      ),
      StreakStatus.active when stats.currentStreak >= stats.bestStreak =>
        context.tr('details.note.bestEver'),
      StreakStatus.active => context.tr(
        'details.note.toGo',
        namedArgs: {
          'best': best,
          'remaining': numbers.format(stats.bestStreak - stats.currentStreak),
        },
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = AtharColors.of(context);
    final text = AtharTextStyles.forLocale(context.locale);
    final numbers = LocalizedNumbers.formatter(context.locale);
    final (background, foreground, flame) = switch (stats.status) {
      StreakStatus.active => (
        accent.color,
        accent.onColor,
        accent.onColor.withValues(alpha: HabitDetailsMetrics.heroFlameOpacity),
      ),
      StreakStatus.broken => (
        colors.surfaceVariant,
        colors.textPrimary,
        colors.textTertiary.withValues(
          alpha: HabitDetailsMetrics.heroFlameMutedOpacity,
        ),
      ),
      StreakStatus.fresh => (
        colors.primaryContainer,
        colors.onPrimaryContainer,
        colors.onPrimaryContainer.withValues(
          alpha: HabitDetailsMetrics.heroFlameMutedOpacity,
        ),
      ),
    };
    final current = stats.currentStreak;
    final unit = context.plural('details.daysUnit', current);
    final note = _note(context, numbers);
    final numberStyle = text.displayStreak.copyWith(
      color: foreground,
      fontSize: layout == AtharLayout.phone
          ? null
          : HabitDetailsMetrics.heroNumberTablet,
    );
    final animate = !MediaQuery.disableAnimationsOf(context);

    return Semantics(
      container: true,
      label:
          '${context.tr('details.currentStreak')}, '
          '${numbers.format(current)} $unit, $note',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsetsDirectional.symmetric(
          vertical: HabitDetailsMetrics.heroPaddingV,
          horizontal: HabitDetailsMetrics.heroPaddingH,
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(HabitDetailsMetrics.heroRadius),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('details.currentStreak'),
                    style: text.cardTitle.copyWith(
                      color: foreground,
                      fontSize: HabitDetailsMetrics.heroLabelSize,
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      TweenAnimationBuilder<int>(
                        tween: IntTween(begin: 0, end: current),
                        duration: animate
                            ? HabitDetailsMetrics.countUp
                            : Duration.zero,
                        curve: Curves.easeOutCubic,
                        builder: (context, value, _) =>
                            Text(numbers.format(value), style: numberStyle),
                      ),
                      const SizedBox(width: HabitDetailsMetrics.heroUnitGap),
                      Flexible(
                        child: Text(
                          unit,
                          style: text.cardTitle.copyWith(
                            color: foreground,
                            fontSize: HabitDetailsMetrics.heroUnitSize,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AtharSpacing.xxs),
                  Text(
                    note,
                    style: text.body.copyWith(
                      color: foreground,
                      fontSize: HabitDetailsMetrics.heroNoteSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AtharSpacing.md),
            AtharIcon.ui(
              'flame',
              size: HabitDetailsMetrics.heroFlame,
              color: flame,
            ),
          ],
        ),
      ),
    );
  }
}
