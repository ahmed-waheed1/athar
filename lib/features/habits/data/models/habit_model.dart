import '../../domain/entities/habit.dart';
import '../../domain/entities/reminder_time.dart';
import '../../domain/utils/habit_dates.dart';

/// Hive representation of a [Habit]. Completed days are `yyyy-MM-dd` keys and
/// the reminder is split into hour and minute (both null when there is none).
class HabitModel {
  const HabitModel({
    required this.id,
    required this.name,
    required this.iconKey,
    required this.colorKey,
    required this.createdAt,
    this.reminderHour,
    this.reminderMinute,
    this.completedDates = const [],
  });

  factory HabitModel.fromEntity(Habit habit) => HabitModel(
    id: habit.id,
    name: habit.name,
    iconKey: habit.iconKey,
    colorKey: habit.colorKey,
    createdAt: habit.createdAt,
    reminderHour: habit.reminderTime?.hour,
    reminderMinute: habit.reminderTime?.minute,
    completedDates: (habit.completedDates.toList()..sort())
        .map(HabitDates.toKey)
        .toList(),
  );

  final String id;
  final String name;
  final String iconKey;
  final String colorKey;
  final DateTime createdAt;
  final int? reminderHour;
  final int? reminderMinute;
  final List<String> completedDates;

  Habit toEntity() => Habit(
    id: id,
    name: name,
    iconKey: iconKey,
    colorKey: colorKey,
    createdAt: createdAt,
    reminderTime: reminderHour != null && reminderMinute != null
        ? ReminderTime(hour: reminderHour!, minute: reminderMinute!)
        : null,
    completedDates: completedDates.map(HabitDates.fromKey),
  );
}
