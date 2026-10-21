import '../repositories/habit_repository.dart';

/// Reset all data: removes every habit with its history and celebrated
/// milestones. Settings (language, theme) are stored apart and stay.
class DeleteAllHabits {
  const DeleteAllHabits(this._repository);

  final HabitRepository _repository;

  Future<void> call() => _repository.deleteAllHabits();
}
