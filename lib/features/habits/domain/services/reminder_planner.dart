import 'package:equatable/equatable.dart';

import '../entities/habit.dart';
import '../utils/habit_dates.dart';

/// One reminder for [habit] at [at] (local time).
class PlannedReminder extends Equatable {
  const PlannedReminder({required this.habit, required this.at});

  final Habit habit;
  final DateTime at;

  @override
  List<Object> get props => [habit.id, at];
}

/// Works out which daily reminders to schedule.
///
/// Each reminder is a one-off notification, not a repeating one, so today's
/// can be left out once the habit is done. A few days are planned ahead so
/// reminders keep coming if the app isn't opened for a while; every change
/// to the habits (and every app start) plans again from scratch.
class ReminderPlanner {
  const ReminderPlanner({this.daysAhead = 7, this.maxReminders = 60});

  /// How many days of reminders each habit gets, today included.
  final int daysAhead;

  /// Total cap. iOS keeps only 64 pending notifications per app, so with
  /// many habits each one gets fewer days (but always at least the next).
  final int maxReminders;

  List<PlannedReminder> plan(List<Habit> habits, DateTime now) {
    final withReminder = habits.where((h) => h.reminderTime != null).toList();
    if (withReminder.isEmpty) return const [];
    final perHabit = (maxReminders ~/ withReminder.length).clamp(1, daysAhead);
    final today = HabitDates.dateOnly(now);

    final reminders = <PlannedReminder>[];
    for (final habit in withReminder) {
      final time = habit.reminderTime!;
      var planned = 0;
      // Today may be skipped, so look one day further than the window.
      for (
        var offset = 0;
        offset <= daysAhead && planned < perHabit;
        offset++
      ) {
        final day = HabitDates.addDays(today, offset);
        final at = DateTime(
          day.year,
          day.month,
          day.day,
          time.hour,
          time.minute,
        );
        if (offset == 0 && (!at.isAfter(now) || habit.isCompletedOn(day))) {
          continue;
        }
        reminders.add(PlannedReminder(habit: habit, at: at));
        planned++;
      }
    }
    return reminders..sort((a, b) => a.at.compareTo(b.at));
  }
}
