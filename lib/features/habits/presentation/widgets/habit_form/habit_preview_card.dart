import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../core/theme/athar_colors.dart';
import '../../../../../core/theme/athar_spacing.dart';
import '../../../../../core/theme/athar_typography.dart';
import '../../../../../core/utils/localized_numbers.dart';
import '../habit_icon_tile.dart';
import '../home_metrics.dart';

/// The live preview at the top of Add / Edit Habit: a habit card with the
/// current name, icon and color. Decorative; its check circle does nothing.
class HabitPreviewCard extends StatelessWidget {
  const HabitPreviewCard({
    super.key,
    required this.name,
    required this.iconKey,
    required this.accent,
    this.currentStreak,
  });

  /// Normalized; empty shows the placeholder.
  final String name;
  final String iconKey;
  final HabitAccent accent;

  /// Edit mode: shown as "21 days". Null (add mode) shows "Starts today".
  final int? currentStreak;

  @override
  Widget build(BuildContext context) {
    final colors = AtharColors.of(context);
    final text = AtharTextStyles.forLocale(context.locale);
    final streak = currentStreak;
    final meta = streak == null
        ? 'habitForm.preview.startsToday'.tr()
        : 'plural.days'.plural(
            streak,
            format: LocalizedNumbers.formatter(context.locale),
          );

    return ExcludeSemantics(
      child: Container(
        constraints: const BoxConstraints(
          minHeight: AtharSizes.habitCardMinHeight,
        ),
        padding: const EdgeInsetsDirectional.all(HomeMetrics.cardPadding),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: AtharRadii.cardRadius,
          boxShadow: AtharShadows.card(Theme.of(context).brightness),
        ),
        child: Row(
          children: [
            HabitIconTile(iconKey: iconKey, accent: accent),
            const SizedBox(width: HomeMetrics.cardGap),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name.isEmpty ? 'habitForm.preview.placeholder'.tr() : name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.cardTitle.copyWith(
                      color: name.isEmpty
                          ? colors.textTertiary
                          : colors.textPrimary,
                    ),
                  ),
                  Text(
                    meta,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.caption.copyWith(color: colors.flame),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AtharSpacing.xs),
            Container(
              width: AtharSizes.checkButton,
              height: AtharSizes.checkButton,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: accent.color,
                  width: HomeMetrics.checkBorder,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
