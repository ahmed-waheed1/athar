import '../entities/habit.dart';
import '../repositories/habit_repository.dart';

/// One habit by id, or null if it no longer exists.
class GetHabit {
  const GetHabit(this._repository);

  final HabitRepository _repository;

  Future<Habit?> call(String id) => _repository.getHabit(id);
}
