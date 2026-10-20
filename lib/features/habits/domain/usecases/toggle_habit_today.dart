import '../entities/habit.dart';
import '../repositories/habit_repository.dart';

/// Marks today done for a habit, or undoes it. Returns the saved habit.
class ToggleHabitToday {
  ToggleHabitToday(this._repository, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final HabitRepository _repository;
  final DateTime Function() _now;

  Future<Habit> call(String habitId) async {
    final habit = await _repository.getHabit(habitId);
    if (habit == null) throw HabitNotFoundException(habitId);
    final updated = habit.toggleCompletion(_now());
    await _repository.updateHabit(updated);
    return updated;
  }
}
