import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/athar_assets.dart';
import '../../../../core/theme/athar_colors.dart';
import '../../../../core/theme/athar_spacing.dart';
import '../../../../core/theme/athar_typography.dart';
import '../../../../core/widgets/athar_icon.dart';
import 'home_metrics.dart';

/// A starter habit offered on the empty Home screen; it prefills Add Habit.
class HabitSuggestion {
  const HabitSuggestion({
    required this.labelKey,
    required this.iconKey,
    required this.colorKey,
  });

  final String labelKey;
  final String iconKey;
  final String colorKey;

  static const all = [
    HabitSuggestion(
      labelKey: 'home.empty.suggestionWater',
      iconKey: 'drop',
      colorKey: 'sky',
    ),
    HabitSuggestion(
      labelKey: 'home.empty.suggestionRead',
      iconKey: 'book',
      colorKey: 'indigo',
    ),
    HabitSuggestion(
      labelKey: 'home.empty.suggestionWalk',
      iconKey: 'walk',
      colorKey: 'leaf',
    ),
  ];
}

class HomeEmptyState extends StatelessWidget {
  const HomeEmptyState({
    super.key,
    required this.onCreate,
    required this.onSuggestion,
  });

  final VoidCallback onCreate;
  final ValueChanged<HabitSuggestion> onSuggestion;

  @override
  Widget build(BuildContext context) {
    final colors = AtharColors.of(context);
    final text = AtharTextStyles.forLocale(context.locale);
    final brightness = Theme.of(context).brightness;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // The trail runs toward the end edge, so it mirrors in RTL.
        Transform.flip(
          flipX: Directionality.of(context) == TextDirection.rtl,
          child: SvgPicture.asset(
            AtharAssets.emptyStateTrail(brightness),
            width: HomeMetrics.emptyArtWidth,
            height: HomeMetrics.emptyArtHeight,
            excludeFromSemantics: true,
          ),
        ),
        const SizedBox(height: AtharSpacing.xl),
        Text(
          'home.empty.title'.tr(),
          textAlign: TextAlign.center,
          style: text.emptyTitle.copyWith(color: colors.textPrimary),
        ),
        const SizedBox(height: AtharSpacing.xs),
        ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: HomeMetrics.emptyBodyMaxWidth,
          ),
          child: Text(
            'home.empty.body'.tr(),
            textAlign: TextAlign.center,
            style: text.body.copyWith(color: colors.textSecondary),
          ),
        ),
        const SizedBox(height: AtharSpacing.xl),
        FilledButton.icon(
          onPressed: onCreate,
          style: FilledButton.styleFrom(
            minimumSize: const Size(0, AtharSizes.buttonHeight),
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: AtharSpacing.xxl,
            ),
          ),
          icon: AtharIcon.ui(
            'plus',
            size: HomeMetrics.buttonIcon,
            color: colors.onPrimary,
          ),
          label: Text('home.empty.create'.tr()),
        ),
        const SizedBox(height: AtharSpacing.xl),
        Text(
          'home.empty.suggestionsTitle'.tr(),
          textAlign: TextAlign.center,
          style: text.caption.copyWith(color: colors.textTertiary),
        ),
        const SizedBox(height: AtharSpacing.sm),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: AtharSpacing.xs,
          runSpacing: AtharSpacing.xs,
          children: [
            for (final suggestion in HabitSuggestion.all)
              _SuggestionChip(
                suggestion: suggestion,
                onPressed: () => onSuggestion(suggestion),
              ),
          ],
        ),
      ],
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip({required this.suggestion, required this.onPressed});

  final HabitSuggestion suggestion;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = AtharColors.of(context);
    final text = AtharTextStyles.forLocale(context.locale);
    final accent = colors.accent(suggestion.colorKey);
    const shape = StadiumBorder();

    return Material(
      color: colors.surface,
      shape: shape.copyWith(
        side: BorderSide(color: colors.divider, width: HomeMetrics.chipBorder),
      ),
      child: InkWell(
        customBorder: shape,
        onTap: onPressed,
        child: Container(
          height: HomeMetrics.chipHeight,
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: AtharSpacing.lg,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AtharIcon.habit(
                suggestion.iconKey,
                size: HomeMetrics.chipIcon,
                color: accent.color,
              ),
              const SizedBox(width: AtharSpacing.xs),
              Text(
                suggestion.labelKey.tr(),
                style: text.bodySmall.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
