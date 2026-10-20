import '../repositories/habit_repository.dart';

class DeleteHabit {
  const DeleteHabit(this._repository);

  final HabitRepository _repository;

  Future<void> call(String id) => _repository.deleteHabit(id);
}
