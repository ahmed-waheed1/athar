import 'package:equatable/equatable.dart';

import '../entities/habit.dart';
import '../utils/habit_dates.dart';
import 'streak_calculator.dart';

/// Streak lengths that get a celebration.
abstract final class StreakMilestones {
  static const values = [7, 14, 30, 60, 100, 365];

  static bool isMilestone(int streak) => values.contains(streak);

  /// The first milestone above [streak], or null past the last one.
  static int? nextAfter(int streak) {
    for (final value in values) {
      if (value > streak) return value;
    }
    return null;
  }
}

class NextMilestone extends Equatable {
  const NextMilestone({
    required this.habit,
    required this.target,
    required this.remaining,
    required this.isDoneToday,
  });

  final Habit habit;

  /// Streak length of the milestone, e.g. 7.
  final int target;

  /// Check-ins still needed to reach [target].
  final int remaining;

  /// Whether the next check-in can only happen tomorrow.
  final bool isDoneToday;

  @override
  List<Object?> get props => [habit, target, remaining, isDoneToday];
}

/// Stats across all habits, shown on the tablet and wide Home screens.
class HabitsOverview extends Equatable {
  const HabitsOverview({
    required this.dailyRatios,
    this.longestActiveStreak = 0,
    this.longestActiveHabit,
    this.monthConsistencyPercent,
    this.nextMilestone,
  });

  static const empty = HabitsOverview(dailyRatios: {});

  /// Share (0..1) of the habits that existed on each day that were done.
  /// Days with no habit yet are absent.
  final Map<DateTime, double> dailyRatios;

  /// The highest current streak, and the habit holding it (null when every
  /// streak is 0).
  final int longestActiveStreak;
  final Habit? longestActiveHabit;

  /// Done habit-days this month out of the possible ones (0–100). Today counts
  /// only for habits already checked. Null when there is nothing to measure.
  final int? monthConsistencyPercent;

  /// The milestone closest to being reached, if any.
  final NextMilestone? nextMilestone;

  @override
  List<Object?> get props => [
    dailyRatios,
    longestActiveStreak,
    longestActiveHabit,
    monthConsistencyPercent,
    nextMilestone,
  ];
}

class HabitsOverviewCalculator {
  HabitsOverviewCalculator(this._streaks, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final StreakCalculator _streaks;
  final DateTime Function() _now;

  /// [days] is how many days of history to include in
  /// [HabitsOverview.dailyRatios], ending today.
  HabitsOverview calculate(List<Habit> habits, {required int days}) {
    if (habits.isEmpty) return HabitsOverview.empty;
    final today = HabitDates.dateOnly(_now());

    var longest = 0;
    Habit? longestHabit;
    NextMilestone? next;
    for (final habit in habits) {
      final streak = _streaks.currentStreak(habit);
      if (streak > longest) {
        longest = streak;
        longestHabit = habit;
      }
      final target = StreakMilestones.nextAfter(streak);
      if (target == null) continue;
      final remaining = target - streak;
      if (next == null || remaining < next.remaining) {
        next = NextMilestone(
          habit: habit,
          target: target,
          remaining: remaining,
          isDoneToday: habit.isCompletedOn(today),
        );
      }
    }

    return HabitsOverview(
      dailyRatios: _dailyRatios(habits, today, days),
      longestActiveStreak: longest,
      longestActiveHabit: longestHabit,
      monthConsistencyPercent: _monthConsistency(habits, today),
      nextMilestone: next,
    );
  }

  Map<DateTime, double> _dailyRatios(
    List<Habit> habits,
    DateTime today,
    int days,
  ) {
    final ratios = <DateTime, double>{};
    for (var offset = days - 1; offset >= 0; offset--) {
      final day = HabitDates.addDays(today, -offset);
      final existing = habits.where((h) => _existsOn(h, day));
      if (existing.isEmpty) continue;
      final done = existing.where((h) => h.isCompletedOn(day)).length;
      ratios[day] = done / existing.length;
    }
    return ratios;
  }

  int? _monthConsistency(List<Habit> habits, DateTime today) {
    var possible = 0;
    var done = 0;
    for (
      var day = DateTime(today.year, today.month);
      !day.isAfter(today);
      day = HabitDates.addDays(day, 1)
    ) {
      for (final habit in habits.where((h) => _existsOn(h, day))) {
        final isDone = habit.isCompletedOn(day);
        // Like StreakCalculator.consistencyPercent: today only counts once done.
        if (day == today && !isDone) continue;
        possible++;
        if (isDone) done++;
      }
    }
    if (possible == 0) return null;
    return (done * 100 / possible).round();
  }

  bool _existsOn(Habit habit, DateTime day) =>
      !HabitDates.dateOnly(habit.createdAt).isAfter(day);
}
