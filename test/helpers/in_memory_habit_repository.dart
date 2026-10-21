import 'dart:async';

import 'package:athar/features/habits/domain/entities/habit.dart';
import 'package:athar/features/habits/domain/repositories/habit_repository.dart';

class InMemoryHabitRepository implements HabitRepository {
  final Map<String, Habit> habits = {};
  final _changes = StreamController<void>.broadcast(sync: true);

  @override
  Future<List<Habit>> getHabits() async => habits.values.toList();

  @override
  Future<Habit?> getHabit(String id) async => habits[id];

  @override
  Future<void> addHabit(Habit habit) async {
    habits[habit.id] = habit;
    _changes.add(null);
  }

  @override
  Future<void> updateHabit(Habit habit) async {
    if (!habits.containsKey(habit.id)) throw HabitNotFoundException(habit.id);
    habits[habit.id] = habit;
    _changes.add(null);
  }

  @override
  Future<void> deleteHabit(String id) async {
    if (habits.remove(id) == null) throw HabitNotFoundException(id);
    _changes.add(null);
  }

  @override
  Future<void> deleteAllHabits() async {
    habits.clear();
    _changes.add(null);
  }

  @override
  Stream<void> watchChanges() => _changes.stream;
}
