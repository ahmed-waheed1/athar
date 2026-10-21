import '../entities/habit.dart';

abstract interface class HabitRepository {
  Future<List<Habit>> getHabits();

  Future<Habit?> getHabit(String id);

  Future<void> addHabit(Habit habit);

  /// Throws [HabitNotFoundException] if no habit has [Habit.id].
  Future<void> updateHabit(Habit habit);

  /// Throws [HabitNotFoundException] if no habit has [id].
  Future<void> deleteHabit(String id);

  /// Removes every habit with its history and celebrated milestones.
  Future<void> deleteAllHabits();

  /// Fires whenever the stored habits change, from any screen.
  Stream<void> watchChanges();
}

class HabitNotFoundException implements Exception {
  const HabitNotFoundException(this.id);

  final String id;

  @override
  String toString() => 'HabitNotFoundException: no habit with id "$id"';
}
