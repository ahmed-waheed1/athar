import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../core/theme/athar_colors.dart';
import '../../../../../core/theme/athar_spacing.dart';
import '../../../../../core/theme/athar_typography.dart';
import '../../../../../core/widgets/athar_icon.dart';
import '../../../domain/entities/habit_catalog.dart';
import 'habit_form_metrics.dart';

/// "Color" label with the selected color's name, and a 4 × 2 swatch grid.
class ColorPickerGrid extends StatelessWidget {
  const ColorPickerGrid({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = AtharColors.of(context);
    final text = AtharTextStyles.forLocale(context.locale);
    const keys = HabitCatalog.colorKeys;
    const columns = HabitFormMetrics.colorColumns;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'habitForm.color.label'.tr(),
                style: text.fieldLabel.copyWith(color: colors.textSecondary),
              ),
            ),
            Text(
              'habitForm.color.names.$selected'.tr(),
              style: text.dateLabel.copyWith(color: colors.textTertiary),
            ),
          ],
        ),
        const SizedBox(height: HabitFormMetrics.colorGridTop),
        for (var row = 0; row * columns < keys.length; row++) ...[
          if (row > 0) const SizedBox(height: HabitFormMetrics.colorRowGap),
          Row(
            children: [
              for (final key in keys.skip(row * columns).take(columns))
                Expanded(
                  child: Center(
                    child: _Swatch(
                      accent: colors.accent(key),
                      label: 'habitForm.color.names.$key'.tr(),
                      isSelected: key == selected,
                      onTap: () => onSelected(key),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

/// A 40 swatch in a 52 tap cell. Selected: a check plus a double ring
/// (background gap, then accent). Keyboard focus adds a `textPrimary` ring.
class _Swatch extends StatefulWidget {
  const _Swatch({
    required this.accent,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final HabitAccent accent;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_Swatch> createState() => _SwatchState();
}

class _SwatchState extends State<_Swatch> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final colors = AtharColors.of(context);
    final accent = widget.accent;
    const ring = HabitFormMetrics.swatchGap + HabitFormMetrics.swatchRing;
    const selectedSize = AtharSizes.colorSwatch + 2 * ring;
    const focusSize = selectedSize + 2 * HabitFormMetrics.swatchFocusRing;

    Widget swatch = Container(
      width: AtharSizes.colorSwatch,
      height: AtharSizes.colorSwatch,
      decoration: BoxDecoration(color: accent.color, shape: BoxShape.circle),
      alignment: AlignmentDirectional.center,
      child: widget.isSelected
          ? AtharIcon.ui(
              'check',
              size: HabitFormMetrics.swatchCheck,
              color: accent.onColor,
            )
          : null,
    );
    if (widget.isSelected) {
      swatch = Container(
        width: selectedSize,
        height: selectedSize,
        padding: const EdgeInsetsDirectional.all(HabitFormMetrics.swatchGap),
        decoration: BoxDecoration(
          color: colors.background,
          shape: BoxShape.circle,
          border: Border.all(
            color: accent.color,
            width: HabitFormMetrics.swatchRing,
          ),
        ),
        child: swatch,
      );
    }
    if (_focused) {
      swatch = Container(
        width: focusSize,
        height: focusSize,
        alignment: AlignmentDirectional.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: colors.textPrimary,
            width: HabitFormMetrics.swatchFocusRing,
          ),
        ),
        child: swatch,
      );
    }

    return Semantics(
      button: true,
      selected: widget.isSelected,
      label: widget.label,
      excludeSemantics: true,
      child: SizedBox.square(
        dimension: HabitFormMetrics.colorCell,
        child: Material(
          type: MaterialType.transparency,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: widget.onTap,
            onFocusChange: (focused) => setState(() => _focused = focused),
            // The rings may draw slightly past the tap cell.
            child: OverflowBox(
              maxWidth: focusSize,
              maxHeight: focusSize,
              child: Center(child: swatch),
            ),
          ),
        ),
      ),
    );
  }
}
