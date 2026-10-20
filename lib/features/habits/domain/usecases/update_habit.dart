import '../entities/habit.dart';
import '../repositories/habit_repository.dart';

class UpdateHabit {
  const UpdateHabit(this._repository);

  final HabitRepository _repository;

  Future<void> call(Habit habit) => _repository.updateHabit(habit);
}
