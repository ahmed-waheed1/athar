import 'package:flutter/widgets.dart';

/// The Athar mark (4 × 4 trace grid) painted in [color]. Same geometry and
/// cell opacities as assets/brand/athar-mark-*.svg, but painted
/// synchronously, so it is there on the very first frame (the splash hands
/// over from the native splash without the mark popping in).
class AtharMark extends StatelessWidget {
  const AtharMark({super.key, required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size.square(size), painter: _AtharMarkPainter(color));
}

class _AtharMarkPainter extends CustomPainter {
  const _AtharMarkPainter(this.color);

  final Color color;

  // In the SVG's 640-unit viewBox.
  static const double _grid = 640;
  static const double _cell = 133;
  static const double _pitch = 169;
  static const double _radius = 30;

  /// Row by row from the top-start cell.
  static const _opacities = [
    [0.16, 0.16, 0.16, 1.0],
    [0.16, 0.16, 0.88, 1.0],
    [0.16, 0.62, 0.76, 0.16],
    [0.38, 0.5, 0.16, 0.16],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / _grid;
    final paint = Paint();
    for (var row = 0; row < _opacities.length; row++) {
      for (var col = 0; col < _opacities[row].length; col++) {
        paint.color = color.withValues(alpha: _opacities[row][col]);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              col * _pitch * scale,
              row * _pitch * scale,
              _cell * scale,
              _cell * scale,
            ),
            Radius.circular(_radius * scale),
          ),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_AtharMarkPainter oldDelegate) =>
      oldDelegate.color != color;
}
