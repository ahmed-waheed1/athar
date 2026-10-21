import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../core/theme/athar_colors.dart';
import '../../../../../core/theme/athar_spacing.dart';
import '../../../../../core/theme/athar_typography.dart';
import '../../../../../core/utils/motion.dart';
import '../../../../../core/widgets/athar_bottom_sheet.dart';
import '../../../../../core/widgets/athar_icon.dart';
import '../../../domain/entities/habit_catalog.dart';
import 'habit_form_metrics.dart';

/// "Icon" label, a "More" button for the full sheet, and a horizontal row of
/// every catalog icon that bleeds off the end edge.
class IconPickerRow extends StatefulWidget {
  const IconPickerRow({
    super.key,
    required this.selected,
    required this.accent,
    required this.gutter,
    required this.onSelected,
    required this.onMore,
  });

  final String selected;
  final HabitAccent accent;

  /// Start padding of the label and the first cell; the row itself spans the
  /// full width so it can scroll under the edges.
  final double gutter;
  final ValueChanged<String> onSelected;
  final VoidCallback onMore;

  @override
  State<IconPickerRow> createState() => _IconPickerRowState();
}

class _IconPickerRowState extends State<IconPickerRow> {
  static const _extent =
      HabitFormMetrics.iconCell + HabitFormMetrics.iconCellGap;

  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _reveal(animate: false),
    );
  }

  @override
  void didUpdateWidget(IconPickerRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected != oldWidget.selected) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _reveal());
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  /// Scrolls just enough to show the selected cell in full.
  void _reveal({bool animate = true}) {
    if (!mounted || !_scroll.hasClients) return;
    final index = HabitCatalog.iconKeys.indexOf(widget.selected);
    if (index < 0) return;
    final position = _scroll.position;
    final start = index * _extent;
    final end = start + HabitFormMetrics.iconCell + 2 * widget.gutter;
    final double target;
    if (start < position.pixels) {
      target = start;
    } else if (end > position.pixels + position.viewportDimension) {
      target = end - position.viewportDimension;
    } else {
      return;
    }
    final clamped = target.clamp(0.0, position.maxScrollExtent);
    final duration = motionDuration(context, AtharMotion.swipeReveal);
    if (!animate || duration == Duration.zero) {
      _scroll.jumpTo(clamped);
    } else {
      _scroll.animateTo(
        clamped,
        duration: duration,
        curve: AtharMotion.swipeRevealCurve,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AtharColors.of(context);
    final text = AtharTextStyles.forLocale(context.locale);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.only(
            start: widget.gutter,
            end: widget.gutter - HabitFormMetrics.moreButtonPaddingH,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'habitForm.icon.label'.tr(),
                  style: text.fieldLabel.copyWith(color: colors.textSecondary),
                ),
              ),
              TextButton(
                onPressed: widget.onMore,
                style: TextButton.styleFrom(
                  foregroundColor: colors.primary,
                  textStyle: text.buttonSmall,
                  minimumSize: const Size.square(AtharSizes.minTapTarget),
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: HabitFormMetrics.moreButtonPaddingH,
                  ),
                ),
                child: Text('habitForm.icon.more'.tr()),
              ),
            ],
          ),
        ),
        SizedBox(
          height: HabitFormMetrics.iconCell,
          child: ListView.separated(
            controller: _scroll,
            scrollDirection: Axis.horizontal,
            padding: EdgeInsetsDirectional.symmetric(horizontal: widget.gutter),
            itemCount: HabitCatalog.iconKeys.length,
            separatorBuilder: (_, _) =>
                const SizedBox(width: HabitFormMetrics.iconCellGap),
            itemBuilder: (context, index) {
              final key = HabitCatalog.iconKeys[index];
              return SizedBox.square(
                dimension: HabitFormMetrics.iconCell,
                child: HabitIconCell(
                  iconKey: key,
                  accent: widget.accent,
                  isSelected: key == widget.selected,
                  restingFill: colors.surface,
                  onTap: () => widget.onSelected(key),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// One icon choice. Selected: 2 px accent border, accent soft fill, accent
/// icon.
class HabitIconCell extends StatelessWidget {
  const HabitIconCell({
    super.key,
    required this.iconKey,
    required this.accent,
    required this.isSelected,
    required this.restingFill,
    required this.onTap,
  });

  final String iconKey;
  final HabitAccent accent;
  final bool isSelected;

  /// Fill when not selected: `surface` in the row, `surfaceVariant` in the
  /// sheet.
  final Color restingFill;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AtharColors.of(context);
    return Semantics(
      button: true,
      selected: isSelected,
      label: 'habitForm.icon.names.$iconKey'.tr(),
      excludeSemantics: true,
      child: Material(
        color: isSelected
            ? Color.alphaBlend(accent.soft, colors.surface)
            : restingFill,
        shape: RoundedRectangleBorder(
          borderRadius: AtharRadii.fieldRadius,
          side: isSelected
              ? BorderSide(
                  color: accent.color,
                  width: HabitFormMetrics.iconCellBorder,
                )
              : BorderSide.none,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Center(
            child: AtharIcon.habit(
              iconKey,
              size: HabitFormMetrics.iconSize,
              color: isSelected ? accent.color : colors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

/// The full icon grid. Picks apply right away (the preview behind updates);
/// "Done" closes the sheet.
Future<void> showIconPickerSheet(
  BuildContext context, {
  required String selected,
  required HabitAccent accent,
  required ValueChanged<String> onSelected,
}) => showAtharBottomSheet<void>(
  context,
  title: 'habitForm.icon.sheetTitle'.tr(),
  builder: (context) =>
      _IconSheet(initial: selected, accent: accent, onSelected: onSelected),
);

class _IconSheet extends StatefulWidget {
  const _IconSheet({
    required this.initial,
    required this.accent,
    required this.onSelected,
  });

  final String initial;
  final HabitAccent accent;
  final ValueChanged<String> onSelected;

  @override
  State<_IconSheet> createState() => _IconSheetState();
}

class _IconSheetState extends State<_IconSheet> {
  late String _selected = widget.initial;

  @override
  Widget build(BuildContext context) {
    final colors = AtharColors.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Flexible(
          child: GridView.builder(
            shrinkWrap: true,
            itemCount: HabitCatalog.iconKeys.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: HabitFormMetrics.iconSheetColumns,
              mainAxisExtent: HabitFormMetrics.iconCell,
              mainAxisSpacing: HabitFormMetrics.iconSheetGap,
              crossAxisSpacing: HabitFormMetrics.iconSheetGap,
            ),
            itemBuilder: (context, index) {
              final key = HabitCatalog.iconKeys[index];
              return HabitIconCell(
                iconKey: key,
                accent: widget.accent,
                isSelected: key == _selected,
                restingFill: colors.surfaceVariant,
                onTap: () {
                  setState(() => _selected = key);
                  widget.onSelected(key);
                },
              );
            },
          ),
        ),
        const SizedBox(height: HabitFormMetrics.sheetActionsTop),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('habitForm.icon.done'.tr()),
        ),
      ],
    );
  }
}
