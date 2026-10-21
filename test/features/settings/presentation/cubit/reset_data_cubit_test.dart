import 'package:athar/features/habits/domain/entities/habit.dart';
import 'package:athar/features/habits/domain/usecases/delete_all_habits.dart';
import 'package:athar/features/habits/domain/usecases/get_habits.dart';
import 'package:athar/features/settings/presentation/cubit/reset_data_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/in_memory_habit_repository.dart';

class FailingHabitRepository extends InMemoryHabitRepository {
  @override
  Future<List<Habit>> getHabits() async => throw StateError('disk on fire');

  @override
  Future<void> deleteAllHabits() async => throw StateError('disk on fire');
}

void main() {
  late InMemoryHabitRepository repository;

  ResetDataCubit buildCubit() => ResetDataCubit(
    getHabits: GetHabits(repository),
    deleteAllHabits: DeleteAllHabits(repository),
  );

  Habit habit(String id, int traces) => Habit(
    id: id,
    name: 'Habit $id',
    iconKey: 'book',
    colorKey: 'teal',
    createdAt: DateTime(2026, 1, 1),
    completedDates: [for (var i = 0; i < traces; i++) DateTime(2026, 1, 1 + i)],
    celebratedMilestones: traces >= 7 ? [7] : [],
  );

  setUp(() => repository = InMemoryHabitRepository());

  test('summary counts habits and every completed day', () async {
    await repository.addHabit(habit('a', 10));
    await repository.addHabit(habit('b', 3));
    await repository.addHabit(habit('c', 0));

    expect(
      await buildCubit().summary(),
      const StoredDataSummary(habits: 3, traces: 13),
    );
  });

  test('reset deletes every habit with its milestones', () async {
    await repository.addHabit(habit('a', 10));
    await repository.addHabit(habit('b', 3));
    final cubit = buildCubit();

    final states = <ResetDataStatus>[];
    final subscription = cubit.stream.listen(states.add);
    await cubit.reset();
    await pumpEventQueue();

    expect(states, [ResetDataStatus.resetting, ResetDataStatus.done]);
    expect(await repository.getHabits(), isEmpty);
    expect(
      await cubit.summary(),
      const StoredDataSummary(habits: 0, traces: 0),
    );
    await subscription.cancel();
  });

  test('failures are reported, not thrown', () async {
    repository = FailingHabitRepository();
    final cubit = buildCubit();

    expect(await cubit.summary(), isNull);
    await cubit.reset();
    expect(cubit.state, ResetDataStatus.failure);
  });
}
