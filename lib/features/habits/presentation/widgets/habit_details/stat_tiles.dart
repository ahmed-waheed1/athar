import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../core/theme/athar_colors.dart';
import '../../../../../core/theme/athar_spacing.dart';
import '../../../../../core/theme/athar_typography.dart';
import '../../../../../core/utils/localized_numbers.dart';
import '../../cubit/habit_details_state.dart';
import 'habit_details_metrics.dart';

/// Best streak, completions and consistency. Best streak and consistency
/// show "—" until there is something to measure.
class StatTiles extends StatelessWidget {
  const StatTiles({super.key, required this.stats});

  final HabitStats stats;

  @override
  Widget build(BuildContext context) {
    final locale = context.locale;
    final numbers = LocalizedNumbers.formatter(locale);
    final noValue = 'details.stats.noValue'.tr();
    final consistency = stats.consistencyPercent;
    final tiles = [
      (
        value: stats.completions == 0
            ? noValue
            : numbers.format(stats.bestStreak),
        label: 'details.stats.best'.tr(),
      ),
      (
        value: numbers.format(stats.completions),
        label: 'details.stats.completions'.tr(),
      ),
      (
        value: consistency == null
            ? noValue
            : LocalizedNumbers.percent(consistency / 100, locale),
        label: 'details.stats.consistency'.tr(),
      ),
    ];

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (index, tile) in tiles.indexed) ...[
            if (index > 0) const SizedBox(width: HabitDetailsMetrics.statGap),
            Expanded(
              child: _StatTile(value: tile.value, label: tile.label),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = AtharColors.of(context);
    final text = AtharTextStyles.forLocale(context.locale);
    return Semantics(
      container: true,
      label: '$value, $label',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsetsDirectional.symmetric(
          vertical: HabitDetailsMetrics.statPaddingV,
          horizontal: HabitDetailsMetrics.statPaddingH,
        ),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(HabitDetailsMetrics.statRadius),
          boxShadow: AtharShadows.card(Theme.of(context).brightness),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                value,
                style: text.statNumber.copyWith(color: colors.textPrimary),
              ),
            ),
            Text(
              label,
              style: text.statLabel.copyWith(color: colors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
