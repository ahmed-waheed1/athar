import '../entities/habit.dart';

abstract interface class HabitRepository {
  Future<List<Habit>> getHabits();

  Future<Habit?> getHabit(String id);

  Future<void> addHabit(Habit habit);

  Future<void> updateHabit(Habit habit);

  Future<void> deleteHabit(String id);
}

class HabitNotFoundException implements Exception {
  const HabitNotFoundException(this.id);

  final String id;

  @override
  String toString() => 'HabitNotFoundException: no habit with id "$id"';
}
