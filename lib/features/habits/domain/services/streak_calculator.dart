import '../entities/habit.dart';
import '../utils/habit_dates.dart';

/// Derives streak stats from a habit's completed dates. Streaks are never
/// stored. Dates after today are ignored.
class StreakCalculator {
  StreakCalculator({DateTime Function()? now}) : _now = now ?? DateTime.now;

  final DateTime Function() _now;

  DateTime get _today => HabitDates.dateOnly(_now());

  /// Consecutive done days ending today, or ending yesterday while today is
  /// still unchecked: an unchecked today breaks nothing until the day ends.
  int currentStreak(Habit habit) {
    final dates = habit.completedDates;
    var day = _today;
    if (!dates.contains(day)) day = HabitDates.addDays(day, -1);
    var streak = 0;
    while (dates.contains(day)) {
      streak++;
      day = HabitDates.addDays(day, -1);
    }
    return streak;
  }

  int bestStreak(Habit habit) {
    final days = _pastDates(habit).toList()..sort();
    var best = 0;
    var run = 0;
    DateTime? previous;
    for (final day in days) {
      run = previous != null && HabitDates.daysBetween(previous, day) == 1
          ? run + 1
          : 1;
      if (run > best) best = run;
      previous = day;
    }
    return best;
  }

  int totalCompletions(Habit habit) => _pastDates(habit).length;

  /// Percentage (0–100) of days since the habit was created that are done.
  /// Today counts only once it is checked. Null when there is no day to
  /// measure yet (created today, not yet checked).
  int? consistencyPercent(Habit habit) {
    final today = _today;
    final start = HabitDates.dateOnly(habit.createdAt);
    final doneToday = habit.isCompletedOn(today);
    final days = HabitDates.daysBetween(start, today) + (doneToday ? 1 : 0);
    if (days <= 0) return null;
    final done = _pastDates(habit).where((d) => !d.isBefore(start)).length;
    return (done * 100 / days).round().clamp(0, 100);
  }

  Iterable<DateTime> _pastDates(Habit habit) {
    final today = _today;
    return habit.completedDates.where((d) => !d.isAfter(today));
  }
}
