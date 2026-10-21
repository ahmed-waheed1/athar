import 'package:equatable/equatable.dart';

import '../entities/habit.dart';
import '../utils/habit_dates.dart';

/// How one day looks in a habit's history.
enum HabitDayStatus {
  done,

  /// A past day since the habit started that wasn't done.
  missed,

  /// Today, not done yet. Not a miss until the day ends.
  open,

  future,

  /// Before the habit was tracked: no data, distinct from a miss.
  beforeStart,
}

/// Day-by-day view of a habit's completed dates, for its heatmap and
/// calendar.
abstract final class HabitHistory {
  /// The first tracked day: the creation date, or an earlier completion if
  /// there is one.
  static DateTime firstDay(Habit habit) {
    var first = HabitDates.dateOnly(habit.createdAt);
    for (final day in habit.completedDates) {
      if (day.isBefore(first)) first = day;
    }
    return first;
  }

  static HabitDayStatus statusOn(
    Habit habit,
    DateTime day, {
    required DateTime today,
  }) {
    final date = HabitDates.dateOnly(day);
    final todayDate = HabitDates.dateOnly(today);
    if (date.isAfter(todayDate)) return HabitDayStatus.future;
    if (habit.isCompletedOn(date)) return HabitDayStatus.done;
    if (date == todayDate) return HabitDayStatus.open;
    if (date.isBefore(firstDay(habit))) return HabitDayStatus.beforeStart;
    return HabitDayStatus.missed;
  }

  /// Days done this month out of the tracked days so far, today included.
  static MonthProgress monthProgress(Habit habit, {required DateTime today}) {
    final todayDate = HabitDates.dateOnly(today);
    final monthStart = DateTime(todayDate.year, todayDate.month);
    final first = firstDay(habit);
    final start = first.isAfter(monthStart) ? first : monthStart;
    final days = <bool>[
      for (
        var day = start;
        !day.isAfter(todayDate);
        day = HabitDates.addDays(day, 1)
      )
        habit.isCompletedOn(day),
    ];
    return MonthProgress(days);
  }
}

/// One entry per tracked day this month, in order: true when done.
class MonthProgress extends Equatable {
  MonthProgress(List<bool> days) : days = List.unmodifiable(days);

  final List<bool> days;

  int get done => days.where((d) => d).length;
  int get total => days.length;

  @override
  List<Object?> get props => [days];
}
