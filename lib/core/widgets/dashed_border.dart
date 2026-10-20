import 'package:flutter/material.dart';

/// Paints a dashed rounded-rectangle outline around [child].
class DashedBorder extends StatelessWidget {
  const DashedBorder({
    super.key,
    required this.color,
    required this.strokeWidth,
    required this.radius,
    required this.dashLength,
    required this.gapLength,
    required this.child,
  });

  final Color color;
  final double strokeWidth;
  final double radius;
  final double dashLength;
  final double gapLength;
  final Widget child;

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _DashedPainter(color, strokeWidth, radius, dashLength, gapLength),
    child: child,
  );
}

class _DashedPainter extends CustomPainter {
  const _DashedPainter(
    this.color,
    this.strokeWidth,
    this.radius,
    this.dashLength,
    this.gapLength,
  );

  final Color color;
  final double strokeWidth;
  final double radius;
  final double dashLength;
  final double gapLength;

  @override
  void paint(Canvas canvas, Size size) {
    final inset = strokeWidth / 2;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        inset,
        inset,
        size.width - strokeWidth,
        size.height - strokeWidth,
      ),
      Radius.circular(radius),
    );
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    for (final metric in (Path()..addRRect(rrect)).computeMetrics()) {
      for (var d = 0.0; d < metric.length; d += dashLength + gapLength) {
        canvas.drawPath(metric.extractPath(d, d + dashLength), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedPainter old) =>
      old.color != color ||
      old.strokeWidth != strokeWidth ||
      old.radius != radius ||
      old.dashLength != dashLength ||
      old.gapLength != gapLength;
}
