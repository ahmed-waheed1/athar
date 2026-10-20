import 'package:flutter/material.dart';

/// The ui_check glyph drawn with a custom stroke width (SVG icons are fixed at
/// 1.8). [progress] 0..1 draws the stroke from its start.
class CheckMark extends StatelessWidget {
  const CheckMark({
    super.key,
    required this.size,
    required this.color,
    required this.strokeWidth,
    this.progress = 1,
  });

  final double size;
  final Color color;
  final double strokeWidth;
  final double progress;

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: Size.square(size),
    painter: _CheckPainter(color, strokeWidth, progress),
  );
}

class _CheckPainter extends CustomPainter {
  const _CheckPainter(this.color, this.strokeWidth, this.progress);

  final Color color;
  final double strokeWidth;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    // Same path as assets/icons/ui/ui_check.svg on its 24 grid.
    final scale = size.width / 24;
    final path = Path()
      ..moveTo(5 * scale, 12.5 * scale)
      ..lineTo(9.5 * scale, 17 * scale)
      ..lineTo(19 * scale, 7.5 * scale);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * scale
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    if (progress >= 1) {
      canvas.drawPath(path, paint);
      return;
    }
    for (final metric in path.computeMetrics()) {
      canvas.drawPath(metric.extractPath(0, metric.length * progress), paint);
    }
  }

  @override
  bool shouldRepaint(_CheckPainter old) =>
      old.color != color ||
      old.strokeWidth != strokeWidth ||
      old.progress != progress;
}
