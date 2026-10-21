import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/athar_colors.dart';
import '../../../../core/theme/athar_spacing.dart';
import '../../../../core/theme/athar_typography.dart';
import '../../../../core/utils/localized_numbers.dart';
import 'heatmap_grid.dart';
import 'home_metrics.dart';

/// "Your path · last 26 weeks": one cell per day, shaded by the share of
/// habits done. Columns are weeks from the start edge; the current week sits
/// on the end side. Rows follow the locale's week start.
class AllHabitsHeatmapCard extends StatelessWidget {
  const AllHabitsHeatmapCard({
    super.key,
    required this.dailyRatios,
    required this.today,
    required this.layout,
  });

  final Map<DateTime, double> dailyRatios;
  final DateTime today;
  final AtharLayout layout;

  @override
  Widget build(BuildContext context) {
    final colors = AtharColors.of(context);
    final text = AtharTextStyles.forLocale(context.locale);
    final locale = context.locale;
    final maxCell = layout == AtharLayout.wide
        ? HomeMetrics.heatmapCellWide
        : AtharSizes.heatmapCellLarge;
    final title = 'home.heatmap.title'.tr(
      namedArgs: {
        'weeks': LocalizedNumbers.decimal(HomeMetrics.heatmapWeeks, locale),
      },
    );

    return Container(
      padding: const EdgeInsetsDirectional.all(AtharSpacing.xl),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AtharRadii.section(layout)),
        boxShadow: AtharShadows.card(Theme.of(context).brightness),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AtharSpacing.md,
            runSpacing: AtharSpacing.xs,
            children: [
              Text(
                title,
                style: text.progressTitle.copyWith(color: colors.textPrimary),
              ),
              _Legend(colors: colors, text: text),
            ],
          ),
          const SizedBox(height: AtharSpacing.lg),
          HeatmapGrid(
            values: dailyRatios,
            today: today,
            weeks: HomeMetrics.heatmapWeeks,
            maxCell: maxCell,
            gap: HomeMetrics.heatmapGap,
            radius: AtharRadii.heatmapCellLarge,
            todayRing: const HeatmapTodayRing(
              gap: HomeMetrics.heatmapTodayBorder / 2,
              width: HomeMetrics.heatmapTodayBorder,
            ),
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.colors, required this.text});

  final AtharColors colors;
  final AtharTextStyles text;

  @override
  Widget build(BuildContext context) {
    final style = text.caption.copyWith(color: colors.textTertiary);
    final swatches = [colors.heatmap.missed, ...colors.heatmap.levels];
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('home.heatmap.less'.tr(), style: style),
        for (final color in swatches) ...[
          const SizedBox(width: AtharSpacing.xxs),
          HeatmapLegendSwatch(
            color: color,
            size: HomeMetrics.heatmapLegendCell,
          ),
        ],
        const SizedBox(width: AtharSpacing.xxs),
        Text('home.heatmap.more'.tr(), style: style),
      ],
    );
  }
}
