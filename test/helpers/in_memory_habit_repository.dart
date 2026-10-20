import 'package:athar/features/habits/domain/entities/habit.dart';
import 'package:athar/features/habits/domain/repositories/habit_repository.dart';

class InMemoryHabitRepository implements HabitRepository {
  final Map<String, Habit> habits = {};

  @override
  Future<List<Habit>> getHabits() async => habits.values.toList();

  @override
  Future<Habit?> getHabit(String id) async => habits[id];

  @override
  Future<void> addHabit(Habit habit) async => habits[habit.id] = habit;

  @override
  Future<void> updateHabit(Habit habit) async {
    if (!habits.containsKey(habit.id)) throw HabitNotFoundException(habit.id);
    habits[habit.id] = habit;
  }

  @override
  Future<void> deleteHabit(String id) async {
    if (habits.remove(id) == null) throw HabitNotFoundException(id);
  }
}
