import 'package:equatable/equatable.dart';

import '../utils/habit_dates.dart';
import 'reminder_time.dart';

class Habit extends Equatable {
  /// [completedDates] are normalized to local dates and deduplicated.
  Habit({
    required this.id,
    required this.name,
    required this.iconKey,
    required this.colorKey,
    required this.createdAt,
    this.reminderTime,
    Iterable<DateTime> completedDates = const [],
  }) : completedDates = Set.unmodifiable(
         completedDates.map(HabitDates.dateOnly),
       );

  final String id;
  final String name;
  final String iconKey;
  final String colorKey;
  final DateTime createdAt;
  final ReminderTime? reminderTime;
  final Set<DateTime> completedDates;

  bool isCompletedOn(DateTime day) =>
      completedDates.contains(HabitDates.dateOnly(day));

  /// Marks [day] done, or undoes it if it was already done.
  Habit toggleCompletion(DateTime day) {
    final date = HabitDates.dateOnly(day);
    return copyWith(
      completedDates: isCompletedOn(date)
          ? completedDates.where((d) => d != date)
          : [...completedDates, date],
    );
  }

  Habit copyWith({
    String? name,
    String? iconKey,
    String? colorKey,
    ReminderTime? reminderTime,
    bool clearReminderTime = false,
    Iterable<DateTime>? completedDates,
  }) => Habit(
    id: id,
    name: name ?? this.name,
    iconKey: iconKey ?? this.iconKey,
    colorKey: colorKey ?? this.colorKey,
    createdAt: createdAt,
    reminderTime: clearReminderTime ? null : reminderTime ?? this.reminderTime,
    completedDates: completedDates ?? this.completedDates,
  );

  @override
  List<Object?> get props => [
    id,
    name,
    iconKey,
    colorKey,
    createdAt,
    reminderTime,
    completedDates,
  ];
}
