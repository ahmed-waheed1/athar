import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../core/theme/athar_colors.dart';
import '../../../../../core/theme/athar_spacing.dart';
import '../../../../../core/theme/athar_typography.dart';
import '../../../../../core/utils/localized_numbers.dart';
import '../../../domain/services/habit_history.dart';
import 'details_section_card.dart';
import 'habit_details_metrics.dart';

/// Tablet: "This month · 20 of 20 days" with one dot per tracked day.
class ThisMonthCard extends StatelessWidget {
  const ThisMonthCard({
    super.key,
    required this.progress,
    required this.accent,
  });

  final MonthProgress progress;
  final HabitAccent accent;

  @override
  Widget build(BuildContext context) {
    final colors = AtharColors.of(context);
    final text = AtharTextStyles.forLocale(context.locale);
    final numbers = LocalizedNumbers.formatter(context.locale);
    final done = numbers.format(progress.done);
    final ofDays = 'details.thisMonth.ofDays'.plural(
      progress.total,
      format: numbers,
    );

    return DetailsSectionCard(
      layout: AtharLayout.tablet,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(
              'details.thisMonth.title'.tr(),
              style: text.cardTitle.copyWith(color: colors.textPrimary),
            ),
          ),
          const SizedBox(height: AtharSpacing.xs),
          Semantics(
            container: true,
            label: '$done $ofDays',
            excludeSemantics: true,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  done,
                  style: text.displayStreak.copyWith(
                    color: accent.color,
                    fontSize: HabitDetailsMetrics.thisMonthNumber,
                  ),
                ),
                const SizedBox(width: HabitDetailsMetrics.heroUnitGap),
                Flexible(
                  child: Text(
                    ofDays,
                    style: text.cardTitle.copyWith(
                      color: colors.textSecondary,
                      fontSize: HabitDetailsMetrics.heroUnitSize,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AtharSpacing.md),
          ExcludeSemantics(
            child: Wrap(
              spacing: HabitDetailsMetrics.thisMonthDotGap,
              runSpacing: HabitDetailsMetrics.thisMonthDotGap,
              children: [
                for (final isDone in progress.days)
                  Container(
                    width: HabitDetailsMetrics.thisMonthDot,
                    height: HabitDetailsMetrics.thisMonthDot,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDone ? accent.color : null,
                      border: isDone
                          ? null
                          : Border.all(
                              color: colors.divider,
                              width: HabitDetailsMetrics.thisMonthDotRing,
                            ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
