import 'package:flutter/material.dart';

import '../../../../core/theme/athar_colors.dart';
import '../../../../core/theme/athar_spacing.dart';
import '../../../../core/widgets/athar_icon.dart';

/// A habit icon on its accent's soft tile.
class HabitIconTile extends StatelessWidget {
  const HabitIconTile({
    super.key,
    required this.iconKey,
    required this.accent,
    this.size = AtharSizes.iconTile,
    this.iconSize = 24,
    this.radius = AtharRadii.chip,
  });

  final String iconKey;
  final HabitAccent accent;
  final double size;
  final double iconSize;
  final double radius;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: accent.soft,
      borderRadius: BorderRadius.circular(radius),
    ),
    alignment: AlignmentDirectional.center,
    child: AtharIcon.habit(iconKey, size: iconSize, color: accent.color),
  );
}
