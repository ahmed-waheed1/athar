import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../../../../core/theme/athar_colors.dart';
import 'milestone_metrics.dart';

/// Confetti over the whole screen (design/screens.md · 07): 36 pieces in the
/// 8 accent colours, 2/3 rounded rectangles and 1/3 circles. Each falls from
/// above the screen to below it in 2.6–4.2 s, turning 540°, after a random
/// start delay, and loops until this widget goes away.
///
/// Drawn in code from confetti-pieces.svg's two shapes; don't build it when
/// reduced motion is on.
class ConfettiLayer extends StatefulWidget {
  const ConfettiLayer({super.key, this.seed});

  /// Fixes the random layout (tests).
  final int? seed;

  @override
  State<ConfettiLayer> createState() => _ConfettiLayerState();
}

class _ConfettiLayerState extends State<ConfettiLayer>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final _elapsed = ValueNotifier(Duration.zero);
  late final List<_Piece> _pieces;

  @override
  void initState() {
    super.initState();
    final random = math.Random(widget.seed);
    const minFall = MilestoneMetrics.confettiMinFall;
    final fallRange = MilestoneMetrics.confettiMaxFall - minFall;
    _pieces = List.generate(MilestoneMetrics.confettiPieces, (i) {
      final fall = minFall + fallRange * random.nextDouble();
      return _Piece(
        x: random.nextDouble(),
        fall: fall,
        delay: fall * random.nextDouble(),
        isCircle: i % 3 == 2,
        colorIndex: i,
        startAngle: random.nextDouble() * 2 * math.pi,
        spin: random.nextBool() ? 1 : -1,
      );
    });
    _ticker = createTicker((elapsed) => _elapsed.value = elapsed)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _elapsed.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accents = AtharColors.of(context).accents;
    return IgnorePointer(
      child: ExcludeSemantics(
        child: CustomPaint(
          size: Size.infinite,
          painter: _ConfettiPainter(
            elapsed: _elapsed,
            pieces: _pieces,
            colors: [for (final accent in accents) accent.color],
          ),
        ),
      ),
    );
  }
}

class _Piece {
  const _Piece({
    required this.x,
    required this.fall,
    required this.delay,
    required this.isCircle,
    required this.colorIndex,
    required this.startAngle,
    required this.spin,
  });

  /// Horizontal position, 0..1 of the width.
  final double x;
  final Duration fall;
  final Duration delay;
  final bool isCircle;
  final int colorIndex;
  final double startAngle;
  final int spin;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({
    required this.elapsed,
    required this.pieces,
    required this.colors,
  }) : super(repaint: elapsed);

  final ValueNotifier<Duration> elapsed;
  final List<_Piece> pieces;
  final List<Color> colors;

  static final _rect = RRect.fromRectAndRadius(
    Rect.fromCenter(
      center: Offset.zero,
      width: MilestoneMetrics.confettiRectWidth,
      height: MilestoneMetrics.confettiRectHeight,
    ),
    const Radius.circular(MilestoneMetrics.confettiRectRadius),
  );

  @override
  void paint(Canvas canvas, Size size) {
    const overscan = MilestoneMetrics.confettiOverscan;
    final paint = Paint();
    for (final piece in pieces) {
      final sinceStart = elapsed.value - piece.delay;
      if (sinceStart.isNegative) continue;
      final t =
          (sinceStart.inMicroseconds % piece.fall.inMicroseconds) /
          piece.fall.inMicroseconds;
      final y = -overscan + (size.height + 2 * overscan) * t;
      final angle =
          piece.startAngle +
          piece.spin * MilestoneMetrics.confettiTurns * 2 * math.pi * t;
      paint.color = colors[piece.colorIndex % colors.length];

      canvas
        ..save()
        ..translate(piece.x * size.width, y)
        ..rotate(angle);
      if (piece.isCircle) {
        canvas.drawCircle(
          Offset.zero,
          MilestoneMetrics.confettiCircle / 2,
          paint,
        );
      } else {
        canvas.drawRRect(_rect, paint);
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) =>
      old.pieces != pieces || old.colors != colors;
}
