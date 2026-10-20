import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';

import '../../../../core/theme/athar_colors.dart';
import '../../../../core/theme/athar_spacing.dart';
import '../../../../core/theme/athar_typography.dart';
import '../../../../core/utils/localized_dates.dart';
import '../../../../core/utils/localized_numbers.dart';
import '../../domain/utils/habit_dates.dart';
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
          LayoutBuilder(
            builder: (context, constraints) {
              const weeks = HomeMetrics.heatmapWeeks;
              const gap = HomeMetrics.heatmapGap;
              final fit = (constraints.maxWidth - gap * (weeks - 1)) / weeks;
              final cell = fit < maxCell ? fit : maxCell;
              return ExcludeSemantics(
                child: CustomPaint(
                  size: Size(
                    cell * weeks + gap * (weeks - 1),
                    cell * 7 + gap * 6,
                  ),
                  painter: _HeatmapPainter(
                    ratios: dailyRatios,
                    today: today,
                    firstDayOfWeek: LocalizedDates.firstDayOfWeek(locale),
                    cell: cell,
                    gap: gap,
                    radius: AtharRadii.heatmapCellLarge,
                    isRtl: Directionality.of(context) == TextDirection.rtl,
                    heatmap: colors.heatmap,
                    todayBorder: colors.textPrimary,
                  ),
                ),
              );
            },
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
          Container(
            width: HomeMetrics.heatmapLegendCell,
            height: HomeMetrics.heatmapLegendCell,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(AtharRadii.heatmapCellPhone),
            ),
          ),
        ],
        const SizedBox(width: AtharSpacing.xxs),
        Text('home.heatmap.more'.tr(), style: style),
      ],
    );
  }
}

class _HeatmapPainter extends CustomPainter {
  const _HeatmapPainter({
    required this.ratios,
    required this.today,
    required this.firstDayOfWeek,
    required this.cell,
    required this.gap,
    required this.radius,
    required this.isRtl,
    required this.heatmap,
    required this.todayBorder,
  });

  final Map<DateTime, double> ratios;
  final DateTime today;
  final int firstDayOfWeek;
  final double cell;
  final double gap;
  final double radius;
  final bool isRtl;
  final HeatmapColors heatmap;
  final Color todayBorder;

  Color _colorFor(DateTime day) {
    final ratio = ratios[day];
    if (ratio == null) return heatmap.noData;
    if (ratio <= 0) return heatmap.missed;
    final level = (ratio * heatmap.levels.length).ceil() - 1;
    return heatmap.levels[level.clamp(0, heatmap.levels.length - 1)];
  }

  @override
  void paint(Canvas canvas, Size size) {
    const weeks = HomeMetrics.heatmapWeeks;
    final todayRow = (today.weekday - firstDayOfWeek + 7) % 7;
    final firstDay = HabitDates.addDays(today, -todayRow - (weeks - 1) * 7);
    final fill = Paint();
    final border = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = HomeMetrics.heatmapTodayBorder
      ..color = todayBorder;

    for (var column = 0; column < weeks; column++) {
      final x = isRtl
          ? size.width - (column + 1) * cell - column * gap
          : column * (cell + gap);
      for (var row = 0; row < 7; row++) {
        final day = HabitDates.addDays(firstDay, column * 7 + row);
        if (day.isAfter(today)) break;
        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(x, row * (cell + gap), cell, cell),
          Radius.circular(radius),
        );
        canvas.drawRRect(rect, fill..color = _colorFor(day));
        if (day == today) {
          canvas.drawRRect(
            rect.inflate(HomeMetrics.heatmapTodayBorder),
            border,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(_HeatmapPainter old) =>
      old.ratios != ratios ||
      old.today != today ||
      old.firstDayOfWeek != firstDayOfWeek ||
      old.cell != cell ||
      old.isRtl != isRtl ||
      old.heatmap != heatmap ||
      old.todayBorder != todayBorder;
}
