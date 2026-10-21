import 'package:flutter/material.dart';

import '../../../../../core/theme/athar_colors.dart';
import '../../../../../core/theme/athar_spacing.dart';
import 'habit_details_metrics.dart';

/// A Details section: `surface`, section radius for the layout, padding 16.
class DetailsSectionCard extends StatelessWidget {
  const DetailsSectionCard({
    super.key,
    required this.layout,
    required this.child,
  });

  final AtharLayout layout;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = AtharColors.of(context);
    return Container(
      padding: const EdgeInsetsDirectional.all(
        HabitDetailsMetrics.sectionPadding,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AtharRadii.section(layout)),
        boxShadow: AtharShadows.card(Theme.of(context).brightness),
      ),
      child: child,
    );
  }
}
