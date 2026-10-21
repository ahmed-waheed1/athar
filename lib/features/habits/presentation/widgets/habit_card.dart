import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../../core/theme/athar_colors.dart';
import '../../../../core/theme/athar_spacing.dart';
import '../../../../core/theme/athar_typography.dart';
import '../../../../core/utils/localized_numbers.dart';
import '../../../../core/utils/motion.dart';
import '../../../../core/widgets/athar_icon.dart';
import '../cubit/habits_state.dart';
import 'check_button.dart';
import 'habit_appearance.dart';
import 'habit_icon_tile.dart';
import 'home_metrics.dart';

/// Group tag so only one card's actions are open at a time.
const habitCardSlidableGroup = 'home-habits';

/// A habit on Home: icon, name, current streak and the check-in toggle.
/// Swiping toward the start edge reveals Edit and Delete on the end side.
class HabitCard extends StatefulWidget {
  const HabitCard({
    super.key,
    required this.item,
    required this.layout,
    required this.onToggle,
    required this.onEdit,
    required this.confirmDelete,
    required this.onDeleted,
    this.onTap,
    this.onSwipeOpenChanged,
    this.isSelected = false,
  });

  final HabitItem item;
  final AtharLayout layout;
  final VoidCallback onToggle;
  final VoidCallback onEdit;

  /// Asks for confirmation; resolves to true when the habit should go.
  final Future<bool> Function() confirmDelete;

  /// Called once a confirmed card has collapsed.
  final VoidCallback onDeleted;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onSwipeOpenChanged;

  /// Wide list only: highlights the habit shown in the details panel.
  final bool isSelected;

  @override
  State<HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends State<HabitCard> with TickerProviderStateMixin {
  late final _slidable = SlidableController(this);
  late final _collapse = AnimationController(
    vsync: this,
    duration: HabitCardCollapse.duration,
    value: 1,
  );
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _slidable.animation.addListener(_handleSlide);
  }

  @override
  void dispose() {
    _slidable.animation.removeListener(_handleSlide);
    _slidable.dispose();
    _collapse.dispose();
    super.dispose();
  }

  void _handleSlide() {
    final isOpen = _slidable.animation.value > 0;
    if (isOpen == _isOpen) return;
    setState(() => _isOpen = isOpen);
    widget.onSwipeOpenChanged?.call(isOpen);
  }

  Future<void> _handleDelete() async {
    await _slidable.close();
    if (!mounted) return;
    final confirmed = await widget.confirmDelete();
    if (!confirmed || !mounted) return;
    _collapse.duration = motionDuration(context, HabitCardCollapse.duration);
    await _collapse.animateTo(0, curve: HabitCardCollapse.curve);
    widget.onDeleted();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AtharColors.of(context);

    return SizeTransition(
      sizeFactor: _collapse,
      alignment: AlignmentDirectional.topCenter,
      child: FadeTransition(
        opacity: _collapse,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return DecoratedBox(
              // The backdrop only shows while the card is slid aside.
              decoration: BoxDecoration(
                color: _isOpen ? colors.surfaceVariant : null,
                borderRadius: AtharRadii.cardRadius,
              ),
              child: Slidable(
                key: ValueKey(widget.item.habit.id),
                controller: _slidable,
                groupTag: habitCardSlidableGroup,
                endActionPane: ActionPane(
                  // The pane is sized as a share of the card; slide 144.
                  extentRatio: (HomeMetrics.swipeExtent / constraints.maxWidth)
                      .clamp(0.0, 1.0),
                  motion: const BehindMotion(),
                  children: [
                    Expanded(
                      child: _SwipeActions(
                        onEdit: () {
                          _slidable.close();
                          widget.onEdit();
                        },
                        onDelete: _handleDelete,
                      ),
                    ),
                  ],
                ),
                child: _CardBody(
                  item: widget.item,
                  layout: widget.layout,
                  isSelected: widget.isSelected,
                  onToggle: widget.onToggle,
                  onTap: widget.onTap,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Delete collapse after confirmation (design/screens.md · 03 Motion).
abstract final class HabitCardCollapse {
  static const duration = Duration(milliseconds: 300);
  static const curve = Curves.easeInCubic;
}

class _CardBody extends StatelessWidget {
  const _CardBody({
    required this.item,
    required this.layout,
    required this.isSelected,
    required this.onToggle,
    required this.onTap,
  });

  final HabitItem item;
  final AtharLayout layout;
  final bool isSelected;
  final VoidCallback onToggle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AtharColors.of(context);
    final text = AtharTextStyles.forLocale(context.locale);
    final habit = item.habit;
    final accent = habit.accentIn(context);
    final isWide = layout == AtharLayout.wide;
    final streak = 'plural.days'.plural(
      item.currentStreak,
      format: LocalizedNumbers.formatter(context.locale),
    );

    final background = isSelected
        ? Color.alphaBlend(
            accent.color.withValues(alpha: HomeMetrics.selectedTintAlpha),
            colors.surface,
          )
        : colors.surface;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: AtharRadii.cardRadius,
        boxShadow: AtharShadows.card(Theme.of(context).brightness),
      ),
      child: Material(
        color: background,
        shape: RoundedRectangleBorder(
          borderRadius: AtharRadii.cardRadius,
          side: isSelected
              ? BorderSide(
                  color: accent.color,
                  width: HomeMetrics.selectedBorder,
                )
              : BorderSide.none,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: AtharSizes.habitCardMinHeight,
            ),
            child: Padding(
              padding: const EdgeInsetsDirectional.all(HomeMetrics.cardPadding),
              child: Row(
                children: [
                  HabitIconTile(
                    iconKey: habit.safeIconKey,
                    accent: accent,
                    size: isWide
                        ? HomeMetrics.iconTileWide
                        : AtharSizes.iconTile,
                  ),
                  const SizedBox(width: HomeMetrics.cardGap),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          habit.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: text.cardTitle.copyWith(
                            color: colors.textPrimary,
                          ),
                        ),
                        Row(
                          children: [
                            if (!isWide) ...[
                              AtharIcon.ui(
                                'flame',
                                size: HomeMetrics.flameSize,
                                color: colors.flame,
                              ),
                              const SizedBox(width: AtharSpacing.xxs),
                            ],
                            Flexible(
                              child: Text(
                                streak,
                                style: text.caption.copyWith(
                                  color: colors.flame,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AtharSpacing.xs),
                  CheckButton(
                    isDone: item.isDoneToday,
                    accent: accent,
                    size: isWide
                        ? AtharSizes.checkButtonWide
                        : AtharSizes.checkButton,
                    semanticLabel:
                        (item.isDoneToday ? 'home.undoDone' : 'home.markDone')
                            .tr(namedArgs: {'name': habit.name}),
                    onPressed: onToggle,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SwipeActions extends StatelessWidget {
  const _SwipeActions({required this.onEdit, required this.onDelete});

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = AtharColors.of(context);
    // 64 + 8 + 64 plus 8 at the end edge fill the 144 slide exactly; the
    // start side meets the card.
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        0,
        AtharSpacing.xs,
        AtharSpacing.xs,
        AtharSpacing.xs,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _SwipeAction(
            icon: 'edit',
            label: 'home.edit'.tr(),
            background: colors.primaryContainer,
            foreground: colors.onPrimaryContainer,
            onPressed: onEdit,
          ),
          const SizedBox(width: AtharSpacing.xs),
          _SwipeAction(
            icon: 'trash',
            label: 'home.delete'.tr(),
            background: colors.error,
            foreground: colors.onError,
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

class _SwipeAction extends StatelessWidget {
  const _SwipeAction({
    required this.icon,
    required this.label,
    required this.background,
    required this.foreground,
    required this.onPressed,
  });

  final String icon;
  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final text = AtharTextStyles.forLocale(context.locale);
    final radius = BorderRadius.circular(HomeMetrics.swipeActionRadius);
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: background,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: onPressed,
          child: SizedBox(
            width: HomeMetrics.swipeActionWidth,
            height: HomeMetrics.swipeActionHeight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AtharIcon.ui(
                  icon,
                  size: HomeMetrics.swipeActionIcon,
                  color: foreground,
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: text.label.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w700,
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
