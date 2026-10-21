import '../../domain/entities/habit.dart';
import '../../domain/entities/reminder_time.dart';
import '../../domain/utils/habit_dates.dart';

/// Hive representation of a [Habit]. Completed days are `yyyy-MM-dd` keys and
/// the reminder is split into hour and minute (both null when there is none).
///
/// [celebratedMilestones] was added after the first release as field 8.
/// Habits saved before it read it as empty, so their other data is kept.
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
    this.celebratedMilestones = const [],
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
    celebratedMilestones: habit.celebratedMilestones.toList()..sort(),
  );

  final String id;
  final String name;
  final String iconKey;
  final String colorKey;
  final DateTime createdAt;
  final int? reminderHour;
  final int? reminderMinute;
  final List<String> completedDates;
  final List<int> celebratedMilestones;

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
    celebratedMilestones: celebratedMilestones,
  );
}
