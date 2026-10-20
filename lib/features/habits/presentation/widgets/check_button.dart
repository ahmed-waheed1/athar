import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/athar_colors.dart';
import '../../../../core/theme/athar_spacing.dart';
import '../../../../core/utils/motion.dart';
import '../../../../core/widgets/check_mark.dart';
import 'home_metrics.dart';

/// The round check-in toggle on a habit card. Pops (checkPop) when it turns
/// done; unchecking just fades the fill out.
class CheckButton extends StatefulWidget {
  const CheckButton({
    super.key,
    required this.isDone,
    required this.accent,
    required this.semanticLabel,
    required this.onPressed,
    this.size = AtharSizes.checkButton,
  });

  final bool isDone;
  final HabitAccent accent;
  final String semanticLabel;
  final VoidCallback onPressed;
  final double size;

  @override
  State<CheckButton> createState() => _CheckButtonState();
}

class _CheckButtonState extends State<CheckButton>
    with SingleTickerProviderStateMixin {
  static const _popFrom = 0.82;

  late final _pop = AnimationController(
    vsync: this,
    duration: AtharMotion.checkPop,
    value: 1,
  );
  late final _scale = Tween(
    begin: _popFrom,
    end: 1.0,
  ).animate(CurvedAnimation(parent: _pop, curve: AtharMotion.checkPopCurve));

  @override
  void didUpdateWidget(CheckButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isDone && !oldWidget.isDone) {
      _pop.duration = motionDuration(context, AtharMotion.checkPop);
      _pop.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _pop.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (!widget.isDone) HapticFeedback.lightImpact();
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.accent;
    final fade = motionDuration(context, AtharMotion.toastOut);
    final markSize =
        HomeMetrics.checkMarkSize * widget.size / AtharSizes.checkButton;

    return Semantics(
      // Its own node, so it isn't merged into the tappable card around it.
      container: true,
      button: true,
      toggled: widget.isDone,
      label: widget.semanticLabel,
      excludeSemantics: true,
      child: SizedBox.square(
        // Never below the minimum tap target.
        dimension: widget.size < AtharSizes.minTapTarget
            ? AtharSizes.minTapTarget
            : widget.size,
        child: Center(
          child: ScaleTransition(
            scale: _scale,
            child: Material(
              type: MaterialType.transparency,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: _handleTap,
                customBorder: const CircleBorder(),
                child: AnimatedContainer(
                  duration: fade,
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.isDone
                        ? accent.color
                        : accent.color.withValues(alpha: 0),
                    border: Border.all(
                      color: accent.color,
                      width: HomeMetrics.checkBorder,
                    ),
                  ),
                  alignment: AlignmentDirectional.center,
                  child: AnimatedOpacity(
                    duration: fade,
                    opacity: widget.isDone ? 1 : 0,
                    child: CheckMark(
                      size: markSize,
                      color: accent.onColor,
                      strokeWidth: HomeMetrics.checkMarkStroke,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
