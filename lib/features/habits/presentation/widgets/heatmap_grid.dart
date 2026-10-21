import 'package:flutter/material.dart';

import '../../../../core/theme/athar_colors.dart';
import '../../../../core/theme/athar_spacing.dart';
import '../../../../core/utils/localized_dates.dart';
import '../../domain/utils/habit_dates.dart';

/// A heatmap of the last [weeks] weeks: one cell per day, columns are weeks
/// running from the start edge, with the current week on the end side. Rows
/// follow the locale's week start. Days after [today] are left empty.
///
/// A day's value in [values] is 0 for a miss and up to 1 for fully done; it
/// is painted with [levels] (`heatmap.levels` when null). Days missing from
/// [values] have no data and use `heatmap.noData`.
class HeatmapGrid extends StatefulWidget {
  const HeatmapGrid({
    super.key,
    required this.values,
    required this.today,
    required this.weeks,
    required this.maxCell,
    required this.gap,
    required this.radius,
    required this.todayRing,
    this.levels,
    this.animateIn = false,
  });

  final Map<DateTime, double> values;
  final DateTime today;
  final int weeks;

  /// Cells shrink below this to fit the width.
  final double maxCell;
  final double gap;
  final double radius;
  final HeatmapTodayRing todayRing;
  final List<Color>? levels;

  /// Fades the columns in one by one from the start edge.
  final bool animateIn;

  @override
  State<HeatmapGrid> createState() => _HeatmapGridState();
}

/// The ring around today's cell: a [gap] (painted in [gapColor], or left
/// clear when null) and then a [width] ring.
class HeatmapTodayRing {
  const HeatmapTodayRing({
    required this.gap,
    required this.width,
    this.gapColor,
  });

  final double gap;
  final double width;
  final Color? gapColor;

  @override
  bool operator ==(Object other) =>
      other is HeatmapTodayRing &&
      other.gap == gap &&
      other.width == width &&
      other.gapColor == gapColor;

  @override
  int get hashCode => Object.hash(gap, width, gapColor);
}

/// Delay between columns and each column's fade (design/screens.md · 06).
const _columnStagger = Duration(milliseconds: 20);
const _columnFade = Duration(milliseconds: 200);

class _HeatmapGridState extends State<HeatmapGrid>
    with SingleTickerProviderStateMixin {
  late final AnimationController _reveal = AnimationController(
    vsync: this,
    duration: _columnStagger * (widget.weeks - 1) + _columnFade,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final animate =
        widget.animateIn && !MediaQuery.disableAnimationsOf(context);
    if (!animate) {
      _reveal.value = 1;
    } else if (!_reveal.isAnimating && _reveal.value == 0) {
      _reveal.forward();
    }
  }

  @override
  void dispose() {
    _reveal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AtharColors.of(context);
    final locale = Localizations.localeOf(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final weeks = widget.weeks;
        final gap = widget.gap;
        final fit = (constraints.maxWidth - gap * (weeks - 1)) / weeks;
        final cell = fit < widget.maxCell ? fit : widget.maxCell;
        return ExcludeSemantics(
          child: AnimatedBuilder(
            animation: _reveal,
            builder: (context, _) => CustomPaint(
              size: Size(cell * weeks + gap * (weeks - 1), cell * 7 + gap * 6),
              painter: _HeatmapPainter(
                values: widget.values,
                today: widget.today,
                weeks: weeks,
                firstDayOfWeek: LocalizedDates.firstDayOfWeek(locale),
                cell: cell,
                gap: gap,
                radius: widget.radius,
                isRtl: Directionality.of(context) == TextDirection.rtl,
                heatmap: colors.heatmap,
                levels: widget.levels ?? colors.heatmap.levels,
                todayRing: widget.todayRing,
                todayRingColor: colors.textPrimary,
                revealMs:
                    _reveal.value *
                    _reveal.duration!.inMicroseconds /
                    Duration.microsecondsPerMillisecond,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HeatmapPainter extends CustomPainter {
  const _HeatmapPainter({
    required this.values,
    required this.today,
    required this.weeks,
    required this.firstDayOfWeek,
    required this.cell,
    required this.gap,
    required this.radius,
    required this.isRtl,
    required this.heatmap,
    required this.levels,
    required this.todayRing,
    required this.todayRingColor,
    required this.revealMs,
  });

  final Map<DateTime, double> values;
  final DateTime today;
  final int weeks;
  final int firstDayOfWeek;
  final double cell;
  final double gap;
  final double radius;
  final bool isRtl;
  final HeatmapColors heatmap;
  final List<Color> levels;
  final HeatmapTodayRing todayRing;
  final Color todayRingColor;

  /// Milliseconds into the column fade-in.
  final double revealMs;

  Color _colorFor(DateTime day) {
    final value = values[day];
    if (value == null) return heatmap.noData;
    if (value <= 0) return heatmap.missed;
    final level = (value * levels.length).ceil() - 1;
    return levels[level.clamp(0, levels.length - 1)];
  }

  double _opacityFor(int column) {
    final start = column * _columnStagger.inMilliseconds;
    final t = (revealMs - start) / _columnFade.inMilliseconds;
    return t.clamp(0.0, 1.0);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final todayRow = (today.weekday - firstDayOfWeek + 7) % 7;
    final firstDay = HabitDates.addDays(today, -todayRow - (weeks - 1) * 7);
    final fill = Paint();

    for (var column = 0; column < weeks; column++) {
      final opacity = _opacityFor(column);
      if (opacity == 0) continue;
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
        final color = _colorFor(day);
        canvas.drawRRect(
          rect,
          fill..color = color.withValues(alpha: color.a * opacity),
        );
        if (day == today) _paintTodayRing(canvas, rect, opacity);
      }
    }
  }

  void _paintTodayRing(Canvas canvas, RRect rect, double opacity) {
    final ring = todayRing;
    final gapColor = ring.gapColor;
    if (gapColor != null && ring.gap > 0) {
      canvas.drawRRect(
        rect.inflate(ring.gap / 2),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = ring.gap
          ..color = gapColor.withValues(alpha: gapColor.a * opacity),
      );
    }
    canvas.drawRRect(
      rect.inflate(ring.gap + ring.width / 2),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = ring.width
        ..color = todayRingColor.withValues(alpha: todayRingColor.a * opacity),
    );
  }

  @override
  bool shouldRepaint(_HeatmapPainter old) =>
      old.values != values ||
      old.today != today ||
      old.weeks != weeks ||
      old.firstDayOfWeek != firstDayOfWeek ||
      old.cell != cell ||
      old.gap != gap ||
      old.radius != radius ||
      old.isRtl != isRtl ||
      old.heatmap != heatmap ||
      old.levels != levels ||
      old.todayRing != todayRing ||
      old.todayRingColor != todayRingColor ||
      old.revealMs != revealMs;
}

/// The heatmap's legend swatch.
class HeatmapLegendSwatch extends StatelessWidget {
  const HeatmapLegendSwatch({
    super.key,
    required this.color,
    required this.size,
  });

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(AtharRadii.heatmapCellPhone),
    ),
  );
}
