import 'package:uuid/uuid.dart';

import '../entities/habit.dart';
import '../entities/reminder_time.dart';
import '../repositories/habit_repository.dart';

class AddHabit {
  AddHabit(
    this._repository, {
    DateTime Function()? now,
    String Function()? generateId,
  }) : _now = now ?? DateTime.now,
       _generateId = generateId ?? const Uuid().v4;

  final HabitRepository _repository;
  final DateTime Function() _now;
  final String Function() _generateId;

  Future<Habit> call({
    required String name,
    required String iconKey,
    required String colorKey,
    ReminderTime? reminderTime,
  }) async {
    final habit = Habit(
      id: _generateId(),
      name: name,
      iconKey: iconKey,
      colorKey: colorKey,
      createdAt: _now(),
      reminderTime: reminderTime,
    );
    await _repository.addHabit(habit);
    return habit;
  }
}
