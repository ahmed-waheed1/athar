import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';

import '../../../../../core/theme/athar_colors.dart';
import '../../../../../core/theme/athar_spacing.dart';
import '../../../../../core/theme/athar_typography.dart';
import '../../../../../core/utils/localized_dates.dart';
import '../../../../../core/utils/localized_numbers.dart';
import '../../../../../core/widgets/athar_icon.dart';
import '../../../domain/entities/habit.dart';
import '../../../domain/services/habit_history.dart';
import 'details_section_card.dart';
import 'habit_details_metrics.dart';

/// Read-only month calendar with previous / next month buttons. Done days
/// are filled with the habit's accent; today gets an inset ring.
class MonthCalendarCard extends StatefulWidget {
  const MonthCalendarCard({
    super.key,
    required this.habit,
    required this.today,
    required this.month,
    required this.accent,
    required this.layout,
    required this.onPrevious,
    required this.onNext,
  });

  final Habit habit;
  final DateTime today;

  /// First day of the month shown.
  final DateTime month;
  final HabitAccent accent;
  final AtharLayout layout;

  /// Null when there is no earlier / later month to show.
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  State<MonthCalendarCard> createState() => _MonthCalendarCardState();
}

class _MonthCalendarCardState extends State<MonthCalendarCard> {
  /// Whether the last month change went forward in time.
  bool _forward = true;

  @override
  void didUpdateWidget(MonthCalendarCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.month != oldWidget.month) {
      _forward = widget.month.isAfter(oldWidget.month);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AtharColors.of(context);
    final text = AtharTextStyles.forLocale(context.locale);
    final locale = context.locale;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final animate = !MediaQuery.disableAnimationsOf(context);

    return DetailsSectionCard(
      layout: widget.layout,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _NavButton(
                icon: 'chev_start',
                tooltip: 'details.calendar.previous'.tr(),
                onPressed: widget.onPrevious,
              ),
              Expanded(
                child: Semantics(
                  header: true,
                  liveRegion: true,
                  child: Text(
                    LocalizedDates.monthYear(widget.month, locale),
                    textAlign: TextAlign.center,
                    style: text.cardTitle.copyWith(color: colors.textPrimary),
                  ),
                ),
              ),
              _NavButton(
                icon: 'chev_end',
                tooltip: 'details.calendar.next'.tr(),
                onPressed: widget.onNext,
              ),
            ],
          ),
          const SizedBox(height: AtharSpacing.xs),
          ExcludeSemantics(
            child: Row(
              children: [
                for (final (index, day) in LocalizedDates.weekdayHeaders(
                  locale,
                ).indexed) ...[
                  if (index > 0)
                    const SizedBox(width: HabitDetailsMetrics.calendarGap),
                  Expanded(
                    child: SizedBox(
                      height: HabitDetailsMetrics.calendarWeekdayHeight,
                      child: Center(
                        child: Text(
                          day,
                          style: text.calendarWeekday.copyWith(
                            color: colors.textTertiary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AtharSpacing.xs),
          ClipRect(
            child: AnimatedSwitcher(
              duration: animate
                  ? HabitDetailsMetrics.monthSlide
                  : Duration.zero,
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeOutCubic,
              layoutBuilder: (current, previous) => Stack(
                alignment: AlignmentDirectional.topCenter,
                children: [...previous, ?current],
              ),
              transitionBuilder: (child, animation) {
                final isIncoming = child.key == ValueKey(widget.month);
                // Later months come in from the end edge, earlier ones from
                // the start edge; the old grid leaves the other way.
                final fromEnd = _forward == isIncoming;
                final dx = (fromEnd ? 1.0 : -1.0) * (isRtl ? -1 : 1);
                return SlideTransition(
                  position: Tween(
                    begin: Offset(dx, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                );
              },
              child: _MonthGrid(
                key: ValueKey(widget.month),
                habit: widget.habit,
                today: widget.today,
                month: widget.month,
                accent: widget.accent,
                cellHeight: HabitDetailsMetrics.calendarCell(widget.layout),
                radius: widget.layout == AtharLayout.wide
                    ? AtharRadii.calendarCellWide
                    : AtharRadii.calendarCell,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final String icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = AtharColors.of(context);
    return SizedBox.square(
      dimension: HabitDetailsMetrics.calendarNavButton,
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Opacity(
          opacity: onPressed == null
              ? HabitDetailsMetrics.calendarNavDisabledOpacity
              : 1,
          child: AtharIcon.ui(
            icon,
            size: HabitDetailsMetrics.calendarNavIcon,
            color: colors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    super.key,
    required this.habit,
    required this.today,
    required this.month,
    required this.accent,
    required this.cellHeight,
    required this.radius,
  });

  final Habit habit;
  final DateTime today;
  final DateTime month;
  final HabitAccent accent;
  final double cellHeight;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final locale = context.locale;
    final leading =
        (month.weekday - LocalizedDates.firstDayOfWeek(locale) + 7) % 7;
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final cells = <DateTime?>[
      for (var i = 0; i < leading; i++) null,
      for (var d = 1; d <= daysInMonth; d++)
        DateTime(month.year, month.month, d),
    ];
    while (cells.length % 7 != 0) {
      cells.add(null);
    }

    return Column(
      children: [
        for (var row = 0; row < cells.length ~/ 7; row++) ...[
          if (row > 0) const SizedBox(height: HabitDetailsMetrics.calendarGap),
          Row(
            children: [
              for (var col = 0; col < 7; col++) ...[
                if (col > 0)
                  const SizedBox(width: HabitDetailsMetrics.calendarGap),
                Expanded(
                  child: SizedBox(
                    height: cellHeight,
                    child: switch (cells[row * 7 + col]) {
                      final day? => _DayCell(
                        day: day,
                        status: HabitHistory.statusOn(habit, day, today: today),
                        isToday: day == today,
                        accent: accent,
                        radius: radius,
                      ),
                      null => const SizedBox.shrink(),
                    },
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.status,
    required this.isToday,
    required this.accent,
    required this.radius,
  });

  final DateTime day;
  final HabitDayStatus status;
  final bool isToday;
  final HabitAccent accent;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final colors = AtharColors.of(context);
    final text = AtharTextStyles.forLocale(context.locale);
    final locale = context.locale;
    final (fill, color, weight) = switch (status) {
      HabitDayStatus.done => (accent.color, accent.onColor, null),
      HabitDayStatus.missed => (
        colors.surfaceVariant,
        colors.textPrimary,
        null,
      ),
      HabitDayStatus.open => (null, colors.textPrimary, null),
      HabitDayStatus.future || HabitDayStatus.beforeStart => (
        null,
        colors.textTertiary,
        FontWeight.w500,
      ),
    };
    final date = LocalizedDates.fullDate(day, locale);
    final label = switch (status) {
      HabitDayStatus.done => 'details.calendar.dayDone'.tr(
        namedArgs: {'date': date},
      ),
      HabitDayStatus.missed => 'details.calendar.dayMissed'.tr(
        namedArgs: {'date': date},
      ),
      _ => date,
    };
    final shape = BorderRadius.circular(radius);

    return Semantics(
      container: true,
      label: label,
      excludeSemantics: true,
      child: Container(
        decoration: BoxDecoration(color: fill, borderRadius: shape),
        foregroundDecoration: isToday
            ? BoxDecoration(
                borderRadius: shape,
                border: Border.all(
                  color: colors.textPrimary,
                  width: HabitDetailsMetrics.calendarTodayRing,
                ),
              )
            : null,
        alignment: AlignmentDirectional.center,
        child: Text(
          LocalizedNumbers.decimal(day.day, locale),
          style: text.calendarDay.copyWith(color: color, fontWeight: weight),
        ),
      ),
    );
  }
}
