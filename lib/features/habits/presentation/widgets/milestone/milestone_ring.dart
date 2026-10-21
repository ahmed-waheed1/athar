import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../core/theme/athar_spacing.dart';
import 'milestone_metrics.dart';

/// N dots in the habit accent on a circle (radius 78 in a 180 box), one per
/// streak day, with [child] in the middle. The dots pop in one by one from 12
/// o'clock, clockwise in LTR and counter-clockwise in RTL, after [delay].
class MilestoneRing extends StatefulWidget {
  const MilestoneRing({
    super.key,
    required this.milestone,
    required this.color,
    required this.child,
    this.delay = Duration.zero,
    this.animate = true,
  });

  final int milestone;
  final Color color;
  final Widget child;

  /// Lets the card finish appearing first.
  final Duration delay;

  /// False (reduced motion): every dot is drawn at once.
  final bool animate;

  @override
  State<MilestoneRing> createState() => _MilestoneRingState();
}

class _MilestoneRingState extends State<MilestoneRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  Duration get _stagger => MilestoneMetrics.dotStagger(widget.milestone);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration:
          widget.delay +
          _stagger * (widget.milestone - 1) +
          MilestoneMetrics.dotPop,
    );
    if (widget.animate) {
      _controller.forward();
    } else {
      _controller.value = 1;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return SizedBox.square(
      dimension: MilestoneMetrics.ringBox,
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          Positioned.fill(
            child: Transform.flip(
              flipX: isRtl,
              child: CustomPaint(
                painter: _DotsPainter(
                  progress: _controller,
                  count: widget.milestone,
                  color: widget.color,
                  dotSize: MilestoneMetrics.dotSize(widget.milestone),
                  total: _controller.duration!,
                  delay: widget.delay,
                  stagger: _stagger,
                ),
              ),
            ),
          ),
          widget.child,
        ],
      ),
    );
  }
}

class _DotsPainter extends CustomPainter {
  _DotsPainter({
    required this.progress,
    required this.count,
    required this.color,
    required this.dotSize,
    required this.total,
    required this.delay,
    required this.stagger,
  }) : super(repaint: progress);

  final Animation<double> progress;
  final int count;
  final Color color;
  final double dotSize;
  final Duration total;
  final Duration delay;
  final Duration stagger;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius =
        MilestoneMetrics.ringRadius * size.width / MilestoneMetrics.ringBox;
    final elapsed = total * progress.value;
    final paint = Paint()..color = color;

    for (var i = 0; i < count; i++) {
      final start = delay + stagger * i;
      final t =
          ((elapsed - start).inMicroseconds /
                  MilestoneMetrics.dotPop.inMicroseconds)
              .clamp(0.0, 1.0);
      if (t == 0) continue;
      final scale = AtharMotion.milestoneDotStaggerCurve.transform(t);
      final angle = -math.pi / 2 + 2 * math.pi * i / count;
      canvas.drawCircle(
        center + Offset(math.cos(angle), math.sin(angle)) * radius,
        dotSize / 2 * scale,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DotsPainter old) =>
      old.count != count || old.color != color || old.dotSize != dotSize;
}
