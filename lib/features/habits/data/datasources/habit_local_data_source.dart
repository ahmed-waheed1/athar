import 'package:hive_ce/hive_ce.dart';

import '../models/habit_model.dart';

/// Raw Hive access for habits. Each habit is stored under its id.
class HabitLocalDataSource {
  const HabitLocalDataSource(this._box);

  static const boxName = 'habits';

  final Box<HabitModel> _box;

  List<HabitModel> readAll() => _box.values.toList();

  HabitModel? read(String id) => _box.get(id);

  bool contains(String id) => _box.containsKey(id);

  Future<void> write(HabitModel habit) => _box.put(habit.id, habit);

  Future<void> remove(String id) => _box.delete(id);
}
