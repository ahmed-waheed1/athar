import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/athar_colors.dart';
import '../../../../core/theme/athar_spacing.dart';
import '../../../../core/theme/athar_typography.dart';
import '../../../../core/utils/localized_numbers.dart';
import '../../../../core/widgets/athar_icon.dart';
import '../../domain/services/habits_overview_calculator.dart';
import '../cubit/habits_state.dart';
import 'all_habits_heatmap_card.dart';
import 'home_metrics.dart';

/// Wide layout end panel when no habit is selected: stat tiles, the
/// all-habits heatmap and the next milestone.
class OverviewPanel extends StatelessWidget {
  const OverviewPanel({super.key, required this.state});

  final HabitsLoaded state;

  @override
  Widget build(BuildContext context) {
    final colors = AtharColors.of(context);
    final text = AtharTextStyles.forLocale(context.locale);
    final locale = context.locale;
    final numbers = LocalizedNumbers.formatter(locale);
    final overview = state.overview;
    final progress = state.progress;
    final longest = overview.longestActiveHabit;
    final consistency = overview.monthConsistencyPercent;

    return ListView(
      padding: const EdgeInsetsDirectional.all(AtharSpacing.xxl),
      children: [
        Semantics(
          header: true,
          child: Text(
            'home.overview.title'.tr(),
            style: text.screenTitle.copyWith(color: colors.textPrimary),
          ),
        ),
        Text(
          'home.overview.subtitle'.tr(),
          style: text.body.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(height: AtharSpacing.xl),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _StatTile(
                  value:
                      '${numbers.format(progress.done)}/${numbers.format(progress.total)}',
                  label: 'home.overview.doneToday'.tr(),
                ),
              ),
              const SizedBox(width: AtharSpacing.md),
              Expanded(
                child: _StatTile(
                  value: numbers.format(overview.longestActiveStreak),
                  label: longest == null
                      ? 'home.overview.longestStreak'.tr()
                      : 'home.overview.longestStreakOf'.tr(
                          namedArgs: {'name': longest.name},
                        ),
                ),
              ),
              const SizedBox(width: AtharSpacing.md),
              Expanded(
                child: _StatTile(
                  value: consistency == null
                      ? 'home.overview.noValue'.tr()
                      : LocalizedNumbers.percent(consistency / 100, locale),
                  label: 'home.overview.consistency'.tr(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AtharSpacing.xl),
        AllHabitsHeatmapCard(
          dailyRatios: overview.dailyRatios,
          today: state.today,
          layout: AtharLayout.wide,
        ),
        if (overview.nextMilestone case final next?) ...[
          const SizedBox(height: AtharSpacing.xl),
          _NextMilestoneRow(milestone: next),
        ],
      ],
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
        padding: const EdgeInsetsDirectional.all(AtharSpacing.xl),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AtharRadii.sectionTablet),
          boxShadow: AtharShadows.card(Theme.of(context).brightness),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: text.statNumber.copyWith(
                fontSize: HomeMetrics.statNumberSize,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: AtharSpacing.xxs),
            Text(
              label,
              style: text.bodySmall.copyWith(color: colors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _NextMilestoneRow extends StatelessWidget {
  const _NextMilestoneRow({required this.milestone});

  final NextMilestone milestone;

  @override
  Widget build(BuildContext context) {
    final colors = AtharColors.of(context);
    final text = AtharTextStyles.forLocale(context.locale);
    final numbers = LocalizedNumbers.formatter(context.locale);
    final title = 'home.overview.nextMilestone'.tr(
      namedArgs: {
        'days': 'plural.days'.plural(milestone.target, format: numbers),
        'name': milestone.habit.name,
      },
    );
    final subtitle =
        (milestone.isDoneToday
                ? 'home.overview.remainingTomorrow'
                : 'home.overview.remainingToday')
            .plural(milestone.remaining, format: numbers);

    return Container(
      padding: const EdgeInsetsDirectional.all(AtharSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AtharRadii.sectionTablet),
        boxShadow: AtharShadows.card(Theme.of(context).brightness),
      ),
      child: Row(
        children: [
          Container(
            width: HomeMetrics.milestoneTile,
            height: HomeMetrics.milestoneTile,
            decoration: BoxDecoration(
              color: colors.flameSoft,
              borderRadius: AtharRadii.chipRadius,
            ),
            alignment: AlignmentDirectional.center,
            child: AtharIcon.ui(
              'flame',
              size: HomeMetrics.toastFlame,
              color: colors.flame,
            ),
          ),
          const SizedBox(width: AtharSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: text.cardTitle.copyWith(color: colors.textPrimary),
                ),
                Text(
                  subtitle,
                  style: text.bodySmall.copyWith(color: colors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
