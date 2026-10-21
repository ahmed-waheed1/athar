import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/theme/athar_colors.dart';
import '../../../../../core/theme/athar_spacing.dart';
import '../../../../../core/theme/athar_typography.dart';
import '../../../../../core/utils/localized_dates.dart';
import '../../../../../core/utils/localized_numbers.dart';
import '../../../../../core/widgets/athar_bottom_sheet.dart';
import '../../../domain/entities/reminder_time.dart';
import 'habit_form_metrics.dart';

/// The "Reminder time" sheet. Resolves to the chosen time, or null when
/// cancelled.
Future<ReminderTime?> showReminderTimeSheet(
  BuildContext context, {
  required ReminderTime initial,
}) => showAtharBottomSheet<ReminderTime>(
  context,
  title: 'habitForm.reminder.sheetTitle'.tr(),
  builder: (context) => _ReminderTimeSheet(initial: initial),
);

class _ReminderTimeSheet extends StatefulWidget {
  const _ReminderTimeSheet({required this.initial});

  final ReminderTime initial;

  @override
  State<_ReminderTimeSheet> createState() => _ReminderTimeSheetState();
}

class _ReminderTimeSheetState extends State<_ReminderTimeSheet> {
  static const _minutes = 60 ~/ HabitFormMetrics.wheelMinuteStep;

  /// 0..11 for 12, 1, ..., 11.
  late int _hour = widget.initial.hour % 12;

  /// Index into the minute steps (0, 5, ..., 55); rounds to the nearest step.
  late int _minute =
      ((widget.initial.minute / HabitFormMetrics.wheelMinuteStep).round()) %
      _minutes;
  late bool _pm = widget.initial.hour >= 12;

  ReminderTime get _value => ReminderTime(
    hour: _hour + (_pm ? 12 : 0),
    minute: _minute * HabitFormMetrics.wheelMinuteStep,
  );

  @override
  Widget build(BuildContext context) {
    final colors = AtharColors.of(context);
    final text = AtharTextStyles.forLocale(context.locale);
    final locale = context.locale;
    final numbers = LocalizedNumbers.formatter(locale);
    final twoDigits = NumberFormat('00', LocalizedNumbers.intlLocale(locale));
    const height =
        HabitFormMetrics.wheelItemExtent * HabitFormMetrics.wheelVisibleItems;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: height,
          child: Stack(
            alignment: AlignmentDirectional.center,
            children: [
              Container(
                height: HabitFormMetrics.wheelBandHeight,
                decoration: BoxDecoration(
                  color: colors.surfaceVariant,
                  borderRadius: BorderRadius.circular(
                    HabitFormMetrics.wheelBandRadius,
                  ),
                ),
              ),
              // In reading order: hour first, so it sits on the right in
              // Arabic.
              Row(
                children: [
                  Expanded(
                    child: _Wheel(
                      semanticLabel: 'habitForm.reminder.hour'.tr(),
                      count: 12,
                      initial: _hour,
                      looping: true,
                      label: (i) => numbers.format(i == 0 ? 12 : i),
                      onChanged: (i) => setState(() => _hour = i),
                    ),
                  ),
                  SizedBox(
                    width: HabitFormMetrics.wheelColonWidth,
                    child: Text(
                      ':',
                      textAlign: TextAlign.center,
                      style: _Wheel.selectedStyle(context),
                    ),
                  ),
                  Expanded(
                    child: _Wheel(
                      semanticLabel: 'habitForm.reminder.minute'.tr(),
                      count: _minutes,
                      initial: _minute,
                      looping: true,
                      label: (i) => twoDigits.format(
                        i * HabitFormMetrics.wheelMinuteStep,
                      ),
                      onChanged: (i) => setState(() => _minute = i),
                    ),
                  ),
                  Expanded(
                    child: _Wheel(
                      semanticLabel: 'habitForm.reminder.period'.tr(),
                      count: 2,
                      initial: _pm ? 1 : 0,
                      looping: false,
                      label: (i) =>
                          LocalizedDates.dayPeriod(pm: i == 1, locale: locale),
                      onChanged: (i) => setState(() => _pm = i == 1),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AtharSpacing.md),
        Text(
          'habitForm.reminder.helper'.tr(),
          textAlign: TextAlign.center,
          style: text.bodySmall.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(height: HabitFormMetrics.sheetActionsTop),
        Row(
          children: [
            Expanded(
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(
                    HabitFormMetrics.sheetButtonHeight,
                  ),
                  backgroundColor: colors.surfaceVariant,
                  foregroundColor: colors.textPrimary,
                ),
                child: Text('habitForm.reminder.cancel'.tr()),
              ),
            ),
            const SizedBox(width: HabitFormMetrics.sheetButtonGap),
            Expanded(
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(_value),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(
                    HabitFormMetrics.sheetButtonHeight,
                  ),
                ),
                child: Text('habitForm.reminder.set'.tr()),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// One wheel column. The selected value is 26 w700; its neighbours 20 w500
/// in `textTertiary`, the outer ones at 45% opacity.
class _Wheel extends StatefulWidget {
  const _Wheel({
    required this.semanticLabel,
    required this.count,
    required this.initial,
    required this.looping,
    required this.label,
    required this.onChanged,
  });

  final String semanticLabel;
  final int count;
  final int initial;

  /// Hours and minutes wrap around; AM/PM doesn't.
  final bool looping;
  final String Function(int index) label;
  final ValueChanged<int> onChanged;

  static TextStyle selectedStyle(BuildContext context) =>
      AtharTextStyles.forLocale(context.locale).ringValue.copyWith(
        fontSize: HabitFormMetrics.wheelSelectedSize,
        fontWeight: FontWeight.w700,
        color: AtharColors.of(context).textPrimary,
      );

  @override
  State<_Wheel> createState() => _WheelState();
}

class _WheelState extends State<_Wheel> {
  /// Looping wheels start in the middle of a long run of repeats, so rows
  /// can be styled by their distance from the selected row.
  late final int _offset = widget.looping
      ? widget.count * (HabitFormMetrics.wheelLoops ~/ 2)
      : 0;
  late int _selectedRow = _offset + widget.initial;
  late final _controller = FixedExtentScrollController(
    initialItem: _selectedRow,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _select(int row) {
    setState(() => _selectedRow = row);
    HapticFeedback.selectionClick();
    widget.onChanged(row % widget.count);
  }

  /// Moves one row with the keyboard or a screen reader.
  void _step(int delta) {
    final rows = widget.looping
        ? widget.count * HabitFormMetrics.wheelLoops
        : widget.count;
    final row = (_selectedRow + delta).clamp(0, rows - 1);
    _controller.animateToItem(
      row,
      duration: AtharMotion.sheetIn,
      curve: AtharMotion.sheetInCurve,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AtharColors.of(context);
    final text = AtharTextStyles.forLocale(context.locale);
    final selected = _Wheel.selectedStyle(context);
    final neighbour = text.ringValue.copyWith(
      fontSize: HabitFormMetrics.wheelNeighbourSize,
      fontWeight: FontWeight.w500,
      color: colors.textTertiary,
    );
    final rows = widget.looping
        ? widget.count * HabitFormMetrics.wheelLoops
        : widget.count;

    final canIncrease = _selectedRow + 1 < rows;
    final canDecrease = _selectedRow > 0;
    return Semantics(
      container: true,
      label: widget.semanticLabel,
      value: widget.label(_selectedRow % widget.count),
      increasedValue: canIncrease
          ? widget.label((_selectedRow + 1) % widget.count)
          : null,
      decreasedValue: canDecrease
          ? widget.label((_selectedRow - 1) % widget.count)
          : null,
      onIncrease: canIncrease ? () => _step(1) : null,
      onDecrease: canDecrease ? () => _step(-1) : null,
      child: ExcludeSemantics(
        child: ListWheelScrollView.useDelegate(
          controller: _controller,
          itemExtent: HabitFormMetrics.wheelItemExtent,
          diameterRatio: HabitFormMetrics.wheelDiameterRatio,
          physics: const FixedExtentScrollPhysics(),
          onSelectedItemChanged: _select,
          childDelegate: ListWheelChildBuilderDelegate(
            childCount: rows,
            builder: (context, row) {
              final distance = (row - _selectedRow).abs();
              return Center(
                child: Opacity(
                  opacity: distance > 1
                      ? HabitFormMetrics.wheelOuterOpacity
                      : 1,
                  child: Text(
                    widget.label(row % widget.count),
                    style: distance == 0 ? selected : neighbour,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
