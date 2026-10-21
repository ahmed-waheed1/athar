import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../core/theme/athar_colors.dart';
import '../../../../../core/theme/athar_spacing.dart';
import '../../../../../core/theme/athar_typography.dart';
import '../../../../../core/utils/localized_dates.dart';
import '../../../../../core/widgets/athar_icon.dart';
import '../../../domain/entities/habit.dart';
import '../../../domain/utils/habit_dates.dart';
import '../habit_appearance.dart';
import '../habit_icon_tile.dart';
import 'habit_details_metrics.dart';

/// Phone: back at the start edge, edit at the end edge.
class DetailsTopBar extends StatelessWidget {
  const DetailsTopBar({super.key, required this.onBack, required this.onEdit});

  final VoidCallback onBack;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final colors = AtharColors.of(context);
    return Row(
      children: [
        IconButton(
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: onBack,
          icon: AtharIcon.ui(
            'back',
            size: HabitDetailsMetrics.topBarIcon,
            color: colors.textPrimary,
          ),
        ),
        const Spacer(),
        IconButton(
          tooltip: context.tr('details.editHabit'),
          onPressed: onEdit,
          icon: AtharIcon.ui(
            'edit',
            size: HabitDetailsMetrics.topBarIcon,
            color: colors.textPrimary,
          ),
        ),
      ],
    );
  }
}

/// Icon tile, name and the "Every day · Reminder 8:30 PM" line.
class DetailsHeader extends StatelessWidget {
  const DetailsHeader({super.key, required this.habit, required this.today});

  final Habit habit;
  final DateTime today;

  String _meta(BuildContext context) {
    final reminder = habit.reminderTime;
    return [
      context.tr('details.everyDay'),
      if (reminder != null)
        context.tr(
          'details.reminder',
          namedArgs: {
            'time': LocalizedDates.time(
              reminder.hour,
              reminder.minute,
              context.locale,
            ),
          },
        ),
      if (HabitDates.dateOnly(habit.createdAt) == today)
        context.tr('details.createdToday'),
    ].join(context.tr('details.metaSeparator'));
  }

  @override
  Widget build(BuildContext context) {
    final colors = AtharColors.of(context);
    final text = AtharTextStyles.forLocale(context.locale);
    return Row(
      children: [
        HabitIconTile(
          iconKey: habit.safeIconKey,
          accent: habit.accentIn(context),
          size: AtharSizes.iconTileDetails,
          iconSize: HabitDetailsMetrics.headerIcon,
          radius: HabitDetailsMetrics.headerTileRadius,
        ),
        const SizedBox(width: HabitDetailsMetrics.headerGap),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text(
                  habit.name,
                  style: text.emptyTitle.copyWith(color: colors.textPrimary),
                ),
              ),
              Text(
                _meta(context),
                style: text.dateLabel.copyWith(color: colors.textTertiary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Tablet and wide: the outlined "Edit" button at the end of the header.
class DetailsEditButton extends StatelessWidget {
  const DetailsEditButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = AtharColors.of(context);
    final text = AtharTextStyles.forLocale(context.locale);
    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, HabitDetailsMetrics.editButtonHeight),
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: AtharSpacing.lg,
        ),
        foregroundColor: colors.textPrimary,
        side: BorderSide(
          color: colors.divider,
          width: HabitDetailsMetrics.editButtonBorder,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            HabitDetailsMetrics.editButtonRadius,
          ),
        ),
        textStyle: text.button,
      ),
      icon: AtharIcon.ui(
        'edit',
        size: HabitDetailsMetrics.editButtonIcon,
        color: colors.textPrimary,
      ),
      label: Text(
        context.tr('details.edit'),
        semanticsLabel: context.tr('details.editHabit'),
      ),
    );
  }
}
