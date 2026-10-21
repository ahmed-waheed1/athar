import '../../domain/entities/habit.dart';
import '../../domain/repositories/habit_repository.dart';
import '../datasources/habit_local_data_source.dart';
import '../models/habit_model.dart';

class HabitRepositoryImpl implements HabitRepository {
  const HabitRepositoryImpl(this._dataSource);

  final HabitLocalDataSource _dataSource;

  /// Habits in the order they were created (Hive orders by key, which is a
  /// random id).
  @override
  Future<List<Habit>> getHabits() async =>
      _dataSource.readAll().map((model) => model.toEntity()).toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

  @override
  Future<Habit?> getHabit(String id) async => _dataSource.read(id)?.toEntity();

  @override
  Future<void> addHabit(Habit habit) =>
      _dataSource.write(HabitModel.fromEntity(habit));

  @override
  Future<void> updateHabit(Habit habit) async {
    if (!_dataSource.contains(habit.id)) throw HabitNotFoundException(habit.id);
    await _dataSource.write(HabitModel.fromEntity(habit));
  }

  @override
  Future<void> deleteHabit(String id) async {
    if (!_dataSource.contains(id)) throw HabitNotFoundException(id);
    await _dataSource.remove(id);
  }

  @override
  Future<void> deleteAllHabits() => _dataSource.clear();

  @override
  Stream<void> watchChanges() => _dataSource.watch();
}
