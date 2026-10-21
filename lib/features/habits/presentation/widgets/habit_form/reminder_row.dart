import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../core/theme/athar_colors.dart';
import '../../../../../core/theme/athar_typography.dart';
import '../../../../../core/utils/localized_dates.dart';
import '../../../../../core/widgets/athar_icon.dart';
import '../../../domain/entities/reminder_time.dart';
import 'habit_form_metrics.dart';

/// "Daily reminder" with its time and an on/off switch. Tapping the row
/// opens the time sheet.
class ReminderRow extends StatelessWidget {
  const ReminderRow({
    super.key,
    required this.enabled,
    required this.time,
    required this.onToggled,
    required this.onTap,
  });

  final bool enabled;
  final ReminderTime time;
  final ValueChanged<bool> onToggled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AtharColors.of(context);
    final text = AtharTextStyles.forLocale(context.locale);
    final subtitleStyle = text.bodySmall.copyWith(color: colors.textTertiary);
    final formatted = LocalizedDates.time(
      time.hour,
      time.minute,
      context.locale,
    );
    final radius = BorderRadius.circular(HabitFormMetrics.reminderRadius);

    return Material(
      color: colors.surface,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            vertical: HabitFormMetrics.reminderPaddingV,
            horizontal: HabitFormMetrics.reminderPaddingH,
          ),
          child: Row(
            children: [
              Container(
                width: HabitFormMetrics.bellTile,
                height: HabitFormMetrics.bellTile,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(
                    HabitFormMetrics.bellTileRadius,
                  ),
                ),
                alignment: AlignmentDirectional.center,
                child: AtharIcon.ui(
                  'bell',
                  size: HabitFormMetrics.bellIcon,
                  color: colors.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: HabitFormMetrics.reminderGap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'habitForm.reminder.title'.tr(),
                      style: text.cardTitle.copyWith(color: colors.textPrimary),
                    ),
                    if (enabled)
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'habitForm.reminder.optionalPrefix'.tr(),
                            ),
                            TextSpan(
                              text: formatted,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: colors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        style: subtitleStyle,
                      )
                    else
                      Text(
                        'habitForm.reminder.subtitleOff'.tr(),
                        style: subtitleStyle,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: HabitFormMetrics.reminderGap),
              Semantics(
                label: 'habitForm.reminder.title'.tr(),
                child: Switch(value: enabled, onChanged: onToggled),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
