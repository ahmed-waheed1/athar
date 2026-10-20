import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/athar_colors.dart';
import '../../../../core/theme/athar_spacing.dart';
import '../../../../core/theme/athar_typography.dart';
import '../../../../core/utils/localized_dates.dart';
import '../../../../core/widgets/athar_icon.dart';
import 'home_metrics.dart';

/// Today's date over a time-of-day greeting, with the add button at the end.
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.now,
    required this.layout,
    this.onAdd,
    this.onLongPress,
  });

  final DateTime now;
  final AtharLayout layout;

  /// Null hides the add button (empty state).
  final VoidCallback? onAdd;

  /// Debug builds only: opens the debug tools.
  final VoidCallback? onLongPress;

  static String greetingKey(DateTime now) => switch (now.hour) {
    >= 5 && < 12 => 'home.greeting.morning',
    >= 12 && < 17 => 'home.greeting.afternoon',
    _ => 'home.greeting.evening',
  };

  @override
  Widget build(BuildContext context) {
    final colors = AtharColors.of(context);
    final text = AtharTextStyles.forLocale(context.locale);
    var greetingStyle = text.greeting.copyWith(color: colors.textPrimary);
    if (layout == AtharLayout.wide) {
      greetingStyle = greetingStyle.copyWith(
        fontSize: HomeMetrics.wideGreetingSize,
      );
    }

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onLongPress: onLongPress,
            behavior: HitTestBehavior.opaque,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LocalizedDates.weekdayDayMonth(now, context.locale),
                  style: text.dateLabel.copyWith(color: colors.textTertiary),
                ),
                Semantics(
                  header: true,
                  child: Text(greetingKey(now).tr(), style: greetingStyle),
                ),
              ],
            ),
          ),
        ),
        if (onAdd != null) ...[
          const SizedBox(width: AtharSpacing.md),
          layout == AtharLayout.tablet
              ? _LabelledAddButton(onPressed: onAdd!)
              : _AddIconButton(onPressed: onAdd!),
        ],
      ],
    );
  }
}

class _AddIconButton extends StatelessWidget {
  const _AddIconButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = AtharColors.of(context);
    return Semantics(
      button: true,
      label: 'home.addHabit'.tr(),
      excludeSemantics: true,
      child: Material(
        color: colors.primary,
        borderRadius: AtharRadii.fieldRadius,
        child: InkWell(
          borderRadius: AtharRadii.fieldRadius,
          onTap: onPressed,
          child: SizedBox.square(
            dimension: HomeMetrics.addButtonSize,
            child: Center(
              child: AtharIcon.ui(
                'plus',
                size: HomeMetrics.addIconSize,
                color: colors.onPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LabelledAddButton extends StatelessWidget {
  const _LabelledAddButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = AtharColors.of(context);
    return FilledButton.icon(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, AtharSizes.minTapTarget),
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: AtharSpacing.lg,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: AtharRadii.fieldRadius,
        ),
      ),
      icon: AtharIcon.ui(
        'plus',
        size: HomeMetrics.buttonIcon,
        color: colors.onPrimary,
      ),
      label: Text('home.addHabit'.tr()),
    );
  }
}
