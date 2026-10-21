import 'package:athar/features/habits/domain/entities/habit.dart';
import 'package:athar/features/habits/domain/services/streak_calculator.dart';
import 'package:athar/features/habits/domain/usecases/get_habit.dart';
import 'package:athar/features/habits/domain/utils/habit_dates.dart';
import 'package:athar/features/habits/presentation/cubit/habit_details_cubit.dart';
import 'package:athar/features/habits/presentation/cubit/habit_details_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/in_memory_habit_repository.dart';

class FailingReadsRepository extends InMemoryHabitRepository {
  @override
  Future<Habit?> getHabit(String id) async => throw StateError('corrupt');
}

/// [count] consecutive days ending on [end].
List<DateTime> run(DateTime end, int count) => [
  for (var i = 0; i < count; i++) HabitDates.addDays(end, -i),
];

void main() {
  late InMemoryHabitRepository repository;
  // Tuesday 20 October 2026, as in the designs.
  var now = DateTime(2026, 10, 20, 9, 30);

  HabitDetailsCubit buildCubit([InMemoryHabitRepository? repo]) =>
      HabitDetailsCubit(
        getHabit: GetHabit(repo ?? repository),
        streakCalculator: StreakCalculator(now: () => now),
        now: () => now,
      );

  Habit habit({
    String id = 'read',
    required DateTime createdAt,
    Iterable<DateTime> completedDates = const [],
  }) => Habit(
    id: id,
    name: 'Read 10 pages',
    iconKey: 'book',
    colorKey: 'indigo',
    createdAt: createdAt,
    completedDates: completedDates,
  );

  setUp(() {
    repository = InMemoryHabitRepository();
    now = DateTime(2026, 10, 20, 9, 30);
  });

  HabitDetailsLoaded loaded(HabitDetailsCubit cubit) =>
      cubit.state as HabitDetailsLoaded;

  group('load', () {
    test('active streak: stats from the completed dates', () async {
      // Best run of 34 in the summer; current run of 21 ending yesterday,
      // with today still open.
      await repository.addHabit(
        habit(
          createdAt: DateTime(2026, 6, 1),
          completedDates: [
            ...run(DateTime(2026, 7, 4), 34),
            ...run(DateTime(2026, 10, 19), 21),
          ],
        ),
      );
      final cubit = buildCubit();
      await cubit.load('read');

      final state = loaded(cubit);
      expect(state.today, DateTime(2026, 10, 20));
      expect(state.month, DateTime(2026, 10));
      expect(state.stats.currentStreak, 21);
      expect(state.stats.bestStreak, 34);
      expect(state.stats.completions, 55);
      // 55 done over 141 days from 1 June to yesterday.
      expect(state.stats.consistencyPercent, 39);
      expect(state.stats.status, StreakStatus.active);
      // October so far: 1–19 done, today open.
      expect(state.stats.thisMonth.total, 20);
      expect(state.stats.thisMonth.done, 19);
      await cubit.close();
    });

    test('broken streak: zero current, best and history kept', () async {
      await repository.addHabit(
        habit(
          createdAt: DateTime(2026, 9, 1),
          completedDates: run(DateTime(2026, 10, 17), 12),
        ),
      );
      final cubit = buildCubit();
      await cubit.load('read');

      final stats = loaded(cubit).stats;
      expect(stats.currentStreak, 0);
      expect(stats.bestStreak, 12);
      expect(stats.completions, 12);
      expect(stats.status, StreakStatus.broken);
      await cubit.close();
    });

    test('brand-new habit: no history and no consistency yet', () async {
      await repository.addHabit(habit(createdAt: DateTime(2026, 10, 20, 8)));
      final cubit = buildCubit();
      await cubit.load('read');

      final state = loaded(cubit);
      expect(state.stats.status, StreakStatus.fresh);
      expect(state.stats.currentStreak, 0);
      expect(state.stats.bestStreak, 0);
      expect(state.stats.completions, 0);
      expect(state.stats.consistencyPercent, isNull);
      expect(state.stats.thisMonth.total, 1);
      expect(state.canShowPreviousMonth, isFalse);
      expect(state.canShowNextMonth, isFalse);
      await cubit.close();
    });

    test('checked in on its first day: active, best ever', () async {
      await repository.addHabit(
        habit(
          createdAt: DateTime(2026, 10, 20, 8),
          completedDates: [DateTime(2026, 10, 20)],
        ),
      );
      final cubit = buildCubit();
      await cubit.load('read');

      final stats = loaded(cubit).stats;
      expect(stats.status, StreakStatus.active);
      expect(stats.currentStreak, 1);
      expect(stats.bestStreak, 1);
      expect(stats.consistencyPercent, 100);
      await cubit.close();
    });

    test('a missing habit is not found, without throwing', () async {
      final cubit = buildCubit();
      await cubit.load('gone');
      expect(cubit.state, const HabitDetailsNotFound());
      await cubit.close();
    });

    test('a read failure is an error state', () async {
      final cubit = buildCubit(FailingReadsRepository());
      await cubit.load('read');
      expect(cubit.state, isA<HabitDetailsError>());
      await cubit.close();
    });
  });

  group('month navigation', () {
    test('stays between the creation month and the current month', () async {
      await repository.addHabit(habit(createdAt: DateTime(2026, 8, 15)));
      final cubit = buildCubit();
      await cubit.load('read');

      // Already on the current month: next does nothing.
      expect(loaded(cubit).canShowNextMonth, isFalse);
      cubit.showNextMonth();
      expect(loaded(cubit).month, DateTime(2026, 10));

      cubit.showPreviousMonth();
      expect(loaded(cubit).month, DateTime(2026, 9));
      cubit.showPreviousMonth();
      expect(loaded(cubit).month, DateTime(2026, 8));
      expect(loaded(cubit).canShowPreviousMonth, isFalse);
      cubit.showPreviousMonth();
      expect(loaded(cubit).month, DateTime(2026, 8));

      cubit.showNextMonth();
      expect(loaded(cubit).month, DateTime(2026, 9));
      expect(loaded(cubit).canShowNextMonth, isTrue);
      await cubit.close();
    });

    test('crosses the year boundary', () async {
      now = DateTime(2027, 1, 3, 12);
      await repository.addHabit(habit(createdAt: DateTime(2026, 12, 28)));
      final cubit = buildCubit();
      await cubit.load('read');

      expect(loaded(cubit).month, DateTime(2027, 1));
      cubit.showPreviousMonth();
      expect(loaded(cubit).month, DateTime(2026, 12));
      expect(loaded(cubit).canShowPreviousMonth, isFalse);
      cubit.showNextMonth();
      expect(loaded(cubit).month, DateTime(2027, 1));
      await cubit.close();
    });

    test('a completion before the creation date extends the range', () async {
      await repository.addHabit(
        habit(
          createdAt: DateTime(2026, 10, 1),
          completedDates: [DateTime(2026, 9, 28)],
        ),
      );
      final cubit = buildCubit();
      await cubit.load('read');
      cubit.showPreviousMonth();
      expect(loaded(cubit).month, DateTime(2026, 9));
      await cubit.close();
    });
  });

  group('reload', () {
    test('shows an edit and keeps the month on screen', () async {
      await repository.addHabit(habit(createdAt: DateTime(2026, 8, 15)));
      final cubit = buildCubit();
      await cubit.load('read');
      cubit.showPreviousMonth();

      final edited = repository.habits['read']!.copyWith(name: 'Read 20');
      await repository.updateHabit(edited);
      final states = <HabitDetailsState>[];
      final sub = cubit.stream.listen(states.add);
      await cubit.reload();
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();

      // No loading flash in between.
      expect(states, hasLength(1));
      expect(loaded(cubit).habit.name, 'Read 20');
      expect(loaded(cubit).month, DateTime(2026, 9));
      await cubit.close();
    });

    test('after a delete the habit is not found', () async {
      await repository.addHabit(habit(createdAt: DateTime(2026, 8, 15)));
      final cubit = buildCubit();
      await cubit.load('read');
      await repository.deleteHabit('read');
      await cubit.reload();
      expect(cubit.state, const HabitDetailsNotFound());
      await cubit.close();
    });

    test('loading another habit starts on the current month', () async {
      await repository.addHabit(habit(createdAt: DateTime(2026, 8, 15)));
      await repository.addHabit(
        habit(id: 'walk', createdAt: DateTime(2026, 8, 15)),
      );
      final cubit = buildCubit();
      await cubit.load('read');
      cubit.showPreviousMonth();
      await cubit.load('walk');
      expect(loaded(cubit).habit.id, 'walk');
      expect(loaded(cubit).month, DateTime(2026, 10));
      await cubit.close();
    });
  });
}
