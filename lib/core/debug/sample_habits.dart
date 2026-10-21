import 'dart:math';

import '../../features/habits/domain/entities/habit.dart';
import '../../features/habits/domain/utils/habit_dates.dart';

/// DEBUG ONLY: the five habits from the Home designs, with history, so every
/// Home state can be tried. Only reachable from the debug tools sheet, which
/// exists only in debug builds.
///
/// Relative to [now]: Pray (40-day streak), Drink water (6) and Morning walk
/// (14) are done today; Read (21) and Learn English (9) are still open, with
/// streaks running to yesterday. Earlier history is random but fixed.
List<Habit> buildSampleHabits({
  required DateTime now,
  required String Function(String key) name,
}) {
  final today = HabitDates.dateOnly(now);
  final random = Random(7);

  Habit sample({
    required String id,
    required String nameKey,
    required String iconKey,
    required String colorKey,
    required int createdDaysAgo,
    required int streak,
    required bool doneToday,
  }) {
    final streakEnd = doneToday ? today : HabitDates.addDays(today, -1);
    final streakStart = HabitDates.addDays(streakEnd, -(streak - 1));
    final created = HabitDates.addDays(today, -createdDaysAgo);
    // The day before the streak is always missed so the streak is exact.
    final historyEnd = HabitDates.addDays(streakStart, -2);
    return Habit(
      id: id,
      name: name(nameKey),
      iconKey: iconKey,
      colorKey: colorKey,
      createdAt: created,
      completedDates: [
        for (
          var d = created;
          !d.isAfter(historyEnd);
          d = HabitDates.addDays(d, 1)
        )
          if (random.nextDouble() < 0.7) d,
        for (var i = 0; i < streak; i++) HabitDates.addDays(streakStart, i),
      ],
    );
  }

  return [
    sample(
      id: 'sample-pray',
      nameKey: 'debug.samplePray',
      iconKey: 'moon',
      colorKey: 'teal',
      createdDaysAgo: 200,
      streak: 40,
      doneToday: true,
    ),
    sample(
      id: 'sample-water',
      nameKey: 'debug.sampleWater',
      iconKey: 'drop',
      colorKey: 'sky',
      createdDaysAgo: 190,
      streak: 6,
      doneToday: true,
    ),
    sample(
      id: 'sample-read',
      nameKey: 'debug.sampleRead',
      iconKey: 'book',
      colorKey: 'indigo',
      createdDaysAgo: 180,
      streak: 21,
      doneToday: false,
    ),
    sample(
      id: 'sample-walk',
      nameKey: 'debug.sampleWalk',
      iconKey: 'walk',
      colorKey: 'leaf',
      createdDaysAgo: 120,
      streak: 14,
      doneToday: true,
    ),
    sample(
      id: 'sample-english',
      nameKey: 'debug.sampleEnglish',
      iconKey: 'chat',
      colorKey: 'coral',
      createdDaysAgo: 60,
      streak: 9,
      doneToday: false,
    ),
  ];
}

/// DEBUG ONLY: three habits one check-in away from each streak milestone
/// (6, 29 and 99 days, open today), as in the milestone designs, so the
/// celebration can be tried on a device. Inserting again resets them and
/// their celebrated milestones.
List<Habit> buildMilestoneSampleHabits({
  required DateTime now,
  required String Function(String key) name,
}) {
  final yesterday = HabitDates.addDays(HabitDates.dateOnly(now), -1);

  Habit sample(
    String id,
    String nameKey,
    String iconKey,
    String colorKey,
    int streak,
  ) => Habit(
    id: id,
    name: name(nameKey),
    iconKey: iconKey,
    colorKey: colorKey,
    createdAt: HabitDates.addDays(yesterday, -streak),
    completedDates: [
      for (var i = 0; i < streak; i++) HabitDates.addDays(yesterday, -i),
    ],
  );

  return [
    sample('milestone-water', 'debug.sampleWater', 'drop', 'sky', 6),
    sample('milestone-pray', 'debug.samplePray', 'moon', 'teal', 29),
    sample('milestone-walk', 'debug.sampleWalk', 'walk', 'leaf', 99),
  ];
}
