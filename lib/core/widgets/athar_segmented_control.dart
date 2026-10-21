import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../theme/athar_colors.dart';
import '../theme/athar_spacing.dart';
import '../theme/athar_typography.dart';
import '../utils/motion.dart';
import 'athar_icon.dart';

/// Sizes of the segmented control (design/screens.md · 08 Settings).
abstract final class _SegmentMetrics {
  static const double height = AtharSizes.fieldHeight;
  static const double inset = AtharSpacing.xxs;
  static const double icon = 18;
  static const double iconGap = AtharSpacing.xs;
}

class AtharSegment<T> {
  const AtharSegment({
    required this.value,
    required this.label,
    this.iconName,
    this.style,
  });

  final T value;
  final String label;

  /// UI icon (ui_*.svg) drawn before the label.
  final String? iconName;

  /// Overrides the label style, e.g. Arabic styles for "العربية" in the
  /// English UI.
  final AtharTextStyles? style;
}

/// The designed segmented control: equal segments on a `surfaceVariant`
/// track, with the selected one raised on a `surface` pill that slides
/// between them. Runs from the start edge, so it mirrors in RTL.
class AtharSegmentedControl<T> extends StatelessWidget {
  const AtharSegmentedControl({
    super.key,
    required this.segments,
    required this.selected,
    required this.onChanged,
  });

  final List<AtharSegment<T>> segments;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = AtharColors.of(context);
    final brightness = Theme.of(context).brightness;
    final index = segments.indexWhere((s) => s.value == selected);
    final count = segments.length;

    return Container(
      height: _SegmentMetrics.height,
      padding: const EdgeInsetsDirectional.all(_SegmentMetrics.inset),
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: AtharRadii.fieldRadius,
      ),
      child: Stack(
        children: [
          if (index >= 0)
            AnimatedAlign(
              duration: motionDuration(context, AtharMotion.sheetIn),
              curve: AtharMotion.sheetInCurve,
              alignment: AlignmentDirectional(
                count == 1 ? 0 : -1 + 2 * index / (count - 1),
                0,
              ),
              child: FractionallySizedBox(
                widthFactor: 1 / count,
                heightFactor: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(AtharRadii.segment),
                    ),
                    boxShadow: AtharShadows.card(brightness),
                  ),
                ),
              ),
            ),
          Row(
            children: [
              for (final segment in segments)
                Expanded(
                  child: _SegmentButton(
                    segment: segment,
                    isSelected: segment.value == selected,
                    onTap: () => onChanged(segment.value),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.segment,
    required this.isSelected,
    required this.onTap,
  });

  final AtharSegment<Object?> segment;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AtharColors.of(context);
    final text = segment.style ?? AtharTextStyles.forLocale(context.locale);
    final color = isSelected ? colors.textPrimary : colors.textSecondary;

    return Semantics(
      button: true,
      selected: isSelected,
      inMutuallyExclusiveGroup: true,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: const BorderRadius.all(
            Radius.circular(AtharRadii.segment),
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (segment.iconName case final icon?) ...[
                  AtharIcon.ui(icon, size: _SegmentMetrics.icon, color: color),
                  const SizedBox(width: _SegmentMetrics.iconGap),
                ],
                Flexible(
                  child: Text(
                    segment.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.buttonSmall.copyWith(color: color),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
