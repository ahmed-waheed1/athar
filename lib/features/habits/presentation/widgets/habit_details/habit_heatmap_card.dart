import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../core/theme/athar_colors.dart';
import '../../../../../core/theme/athar_spacing.dart';
import '../../../../../core/theme/athar_typography.dart';
import '../../../../../core/utils/localized_numbers.dart';
import '../../../domain/entities/habit.dart';
import '../../../domain/services/habit_history.dart';
import '../../../domain/utils/habit_dates.dart';
import '../heatmap_grid.dart';
import 'details_section_card.dart';
import 'habit_details_metrics.dart';

/// "Last 18 weeks" (26 on tablet and wide) for one habit: done days in the
/// habit's accent, misses in `heatmap.missed`, and days before the habit
/// started in `heatmap.noData`.
class HabitHeatmapCard extends StatelessWidget {
  const HabitHeatmapCard({
    super.key,
    required this.habit,
    required this.today,
    required this.accent,
    required this.layout,
  });

  final Habit habit;
  final DateTime today;
  final HabitAccent accent;
  final AtharLayout layout;

  int get _weeks => layout == AtharLayout.phone
      ? HabitDetailsMetrics.heatmapWeeksPhone
      : HabitDetailsMetrics.heatmapWeeksLarge;

  /// 1 for done, 0 for missed (an open today included); days with no data
  /// are left out.
  Map<DateTime, double> _values() {
    final values = <DateTime, double>{};
    for (
      var day = HabitDates.addDays(today, -_weeks * 7);
      !day.isAfter(today);
      day = HabitDates.addDays(day, 1)
    ) {
      switch (HabitHistory.statusOn(habit, day, today: today)) {
        case HabitDayStatus.done:
          values[day] = 1;
        case HabitDayStatus.missed || HabitDayStatus.open:
          values[day] = 0;
        case HabitDayStatus.beforeStart || HabitDayStatus.future:
          break;
      }
    }
    return values;
  }

  @override
  Widget build(BuildContext context) {
    final colors = AtharColors.of(context);
    final text = AtharTextStyles.forLocale(context.locale);
    final isPhone = layout == AtharLayout.phone;
    final title = 'details.heatmap.title'.plural(
      _weeks,
      format: LocalizedNumbers.formatter(context.locale),
    );

    return DetailsSectionCard(
      layout: layout,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AtharSpacing.md,
            runSpacing: AtharSpacing.xs,
            children: [
              Semantics(
                header: true,
                child: Text(
                  title,
                  style: text.cardTitle.copyWith(color: colors.textPrimary),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _LegendItem(
                    color: colors.heatmap.missed,
                    label: 'details.heatmap.missed'.tr(),
                  ),
                  const SizedBox(width: AtharSpacing.md),
                  _LegendItem(
                    color: accent.color,
                    label: 'details.heatmap.done'.tr(),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: HabitDetailsMetrics.sectionTitleGap),
          HeatmapGrid(
            values: _values(),
            today: today,
            weeks: _weeks,
            maxCell: isPhone
                ? AtharSizes.heatmapCellPhone
                : AtharSizes.heatmapCellLarge,
            gap: isPhone
                ? AtharSizes.heatmapGapPhone
                : AtharSizes.heatmapGapLarge,
            radius: isPhone
                ? AtharRadii.heatmapCellPhone
                : AtharRadii.heatmapCellLarge,
            levels: [accent.color],
            todayRing: HeatmapTodayRing(
              gap: HabitDetailsMetrics.heatmapTodayGap,
              width: HabitDetailsMetrics.heatmapTodayRing,
              gapColor: colors.surface,
            ),
            animateIn: true,
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = AtharColors.of(context);
    final text = AtharTextStyles.forLocale(context.locale);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        HeatmapLegendSwatch(
          color: color,
          size: HabitDetailsMetrics.heatmapLegendCell,
        ),
        const SizedBox(width: AtharSpacing.xs),
        Text(label, style: text.label.copyWith(color: colors.textSecondary)),
      ],
    );
  }
}
