import '../repositories/habit_repository.dart';

/// Fires whenever the stored habits change, e.g. after a reset in Settings.
class WatchHabitChanges {
  const WatchHabitChanges(this._repository);

  final HabitRepository _repository;

  Stream<void> call() => _repository.watchChanges();
}
