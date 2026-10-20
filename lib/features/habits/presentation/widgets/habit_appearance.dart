import 'package:flutter/widgets.dart';

import '../../../../core/theme/athar_colors.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_catalog.dart';

/// Resolves a habit's stored keys to what is drawn, falling back to the
/// catalog defaults for unknown keys.
extension HabitAppearance on Habit {
  String get safeIconKey => HabitCatalog.iconOrDefault(iconKey);

  HabitAccent accentIn(BuildContext context) =>
      AtharColors.of(context).accent(HabitCatalog.colorOrDefault(colorKey));
}
