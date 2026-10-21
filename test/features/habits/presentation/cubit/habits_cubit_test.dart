import 'package:athar/features/habits/domain/entities/habit.dart';
import 'package:athar/features/habits/domain/services/habits_overview_calculator.dart';
import 'package:athar/features/habits/domain/services/streak_calculator.dart';
import 'package:athar/features/habits/domain/usecases/delete_habit.dart';
import 'package:athar/features/habits/domain/usecases/get_habits.dart';
import 'package:athar/features/habits/domain/usecases/toggle_habit_today.dart';
import 'package:athar/features/habits/domain/usecases/watch_habit_changes.dart';
import 'package:athar/features/habits/presentation/cubit/habits_cubit.dart';
import 'package:athar/features/habits/presentation/cubit/habits_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/in_memory_habit_repository.dart';

class FailingHabitRepository extends InMemoryHabitRepository {
  bool failReads = true;

  @override
  Future<List<Habit>> getHabits() async {
    if (failReads) throw StateError('disk on fire');
    return super.getHabits();
  }
}

void main() {
  late InMemoryHabitRepository repository;
  late DateTime now;

  HabitsCubit buildCubit() {
    DateTime clock() => now;
    final streaks = StreakCalculator(now: clock);
    return HabitsCubit(
      getHabits: GetHabits(repository),
      toggleHabitToday: ToggleHabitToday(repository, streaks, now: clock),
      deleteHabit: DeleteHabit(repository),
      watchHabitChanges: WatchHabitChanges(repository),
      streakCalculator: streaks,
      overviewCalculator: HabitsOverviewCalculator(streaks, now: clock),
      now: clock,
    );
  }

  Habit habit(String id, {List<DateTime> done = const []}) => Habit(
    id: id,
    name: 'Habit $id',
    iconKey: 'book',
    colorKey: 'teal',
    createdAt: DateTime(2026, 9, 1),
    completedDates: done,
  );

  HabitsLoaded loaded(HabitsCubit cubit) => cubit.state as HabitsLoaded;

  setUp(() {
    repository = InMemoryHabitRepository();
    now = DateTime(2026, 10, 20, 9, 30);
  });

  test('starts loading', () {
    expect(buildCubit().state, const HabitsLoading());
  });

  group('load', () {
    test('emits the habits with streaks and today\'s progress', () async {
      await repository.addHabit(
        habit('a', done: [DateTime(2026, 10, 18), DateTime(2026, 10, 19), now]),
      );
      await repository.addHabit(
        habit('b', done: [DateTime(2026, 10, 18), DateTime(2026, 10, 19)]),
      );
      await repository.addHabit(habit('c'));
      final cubit = buildCubit();

      await cubit.load();

      final state = loaded(cubit);
      expect(state.today, DateTime(2026, 10, 20));
      expect(
        state.habits.map((h) => (h.habit.id, h.currentStreak, h.isDoneToday)),
        [('a', 3, true), ('b', 2, false), ('c', 0, false)],
      );
      expect(state.progress, const TodayProgress(done: 1, total: 3));
      expect(state.progress.isAllDone, isFalse);
      expect(state.overview.longestActiveStreak, 3);
    });

    test('with no habits is loaded and empty', () async {
      final cubit = buildCubit();
      await cubit.load();
      expect(loaded(cubit).habits, isEmpty);
      expect(loaded(cubit).progress.fraction, 0);
      expect(loaded(cubit).progress.isAllDone, isFalse);
    });

    test('reports all done when every habit is checked', () async {
      await repository.addHabit(habit('a', done: [now]));
      await repository.addHabit(habit('b', done: [now]));
      final cubit = buildCubit();
      await cubit.load();
      expect(loaded(cubit).progress.isAllDone, isTrue);
      expect(loaded(cubit).progress.fraction, 1);
    });

    test('emits an error when the habits cannot be read', () async {
      repository = FailingHabitRepository();
      final cubit = buildCubit();

      await cubit.load();

      expect(cubit.state, isA<HabitsError>());
      expect((cubit.state as HabitsError).error, isA<StateError>());
    });

    test('recovers from an error on retry', () async {
      final failing = FailingHabitRepository();
      repository = failing;
      final cubit = buildCubit();
      await cubit.load();
      expect(cubit.state, isA<HabitsError>());

      failing.failReads = false;
      await cubit.load();
      expect(cubit.state, isA<HabitsLoaded>());
    });
  });

  group('toggleToday', () {
    test('checks today and returns the new streak', () async {
      await repository.addHabit(
        habit('a', done: [DateTime(2026, 10, 18), DateTime(2026, 10, 19)]),
      );
      final cubit = buildCubit();
      await cubit.load();

      final result = await cubit.toggleToday('a');

      expect(result?.isDone, isTrue);
      expect(result?.currentStreak, 3);
      expect(loaded(cubit).habits.single.isDoneToday, isTrue);
      expect(loaded(cubit).habits.single.currentStreak, 3);
      expect(loaded(cubit).progress, const TodayProgress(done: 1, total: 1));
      expect((await repository.getHabit('a'))!.isCompletedOn(now), isTrue);
    });

    test('undoes a checked today without breaking the streak', () async {
      await repository.addHabit(
        habit('a', done: [DateTime(2026, 10, 19), now]),
      );
      final cubit = buildCubit();
      await cubit.load();

      final result = await cubit.toggleToday('a');

      expect(result?.isDone, isFalse);
      // Today unchecked: yesterday's streak still counts until the day ends.
      expect(result?.currentStreak, 1);
      expect(loaded(cubit).habits.single.isDoneToday, isFalse);
    });

    test('reloads instead of throwing when the habit is gone', () async {
      await repository.addHabit(habit('a'));
      await repository.addHabit(habit('b'));
      final cubit = buildCubit();
      await cubit.load();
      // Deleted elsewhere (e.g. another screen) after Home loaded.
      await repository.deleteHabit('a');

      final result = await cubit.toggleToday('a');

      expect(result, isNull);
      expect(loaded(cubit).habits.map((h) => h.habit.id), ['b']);
    });

    test('ignores a second tap while the first is still saving', () async {
      await repository.addHabit(habit('a'));
      final cubit = buildCubit();
      await cubit.load();

      final first = cubit.toggleToday('a');
      final second = cubit.toggleToday('a');

      expect(await second, isNull);
      expect((await first)?.isDone, isTrue);
      expect(loaded(cubit).habits.single.isDoneToday, isTrue);
    });
  });

  group('milestones', () {
    List<DateTime> lastDays(int count) => [
      for (var i = 1; i <= count; i++) DateTime(2026, 10, 20 - i),
    ];

    test('a check-in reaching 7 reports the milestone', () async {
      await repository.addHabit(habit('a', done: lastDays(6)));
      final cubit = buildCubit();
      await cubit.load();

      final result = await cubit.toggleToday('a');

      expect(result?.currentStreak, 7);
      expect(result?.milestone, 7);
      expect(loaded(cubit).habits.single.habit.celebratedMilestones, {7});
    });

    test('uncheck and recheck the same day reports it only once', () async {
      await repository.addHabit(habit('a', done: lastDays(6)));
      final cubit = buildCubit();
      await cubit.load();

      expect((await cubit.toggleToday('a'))?.milestone, 7);
      expect((await cubit.toggleToday('a'))?.milestone, isNull);
      final again = await cubit.toggleToday('a');

      expect(again?.isDone, isTrue);
      expect(again?.milestone, isNull);
    });

    test('a check-in off a milestone reports none', () async {
      await repository.addHabit(habit('a', done: lastDays(7)));
      final cubit = buildCubit();
      await cubit.load();

      final result = await cubit.toggleToday('a');

      expect(result?.currentStreak, 8);
      expect(result?.milestone, isNull);
    });
  });

  group('changes made elsewhere', () {
    test('reloads to empty after every habit is deleted', () async {
      await repository.addHabit(habit('a'));
      await repository.addHabit(habit('b'));
      final cubit = buildCubit();
      await cubit.load();
      expect(loaded(cubit).habits, hasLength(2));

      // Reset all data in Settings.
      await repository.deleteAllHabits();
      await pumpEventQueue();

      expect(loaded(cubit).habits, isEmpty);
      expect(loaded(cubit).overview, HabitsOverview.empty);
      await cubit.close();
    });

    test('reloads after a habit is added elsewhere', () async {
      final cubit = buildCubit();
      await cubit.load();

      await repository.addHabit(habit('a'));
      await pumpEventQueue();

      expect(loaded(cubit).habits.map((h) => h.habit.id), ['a']);
      await cubit.close();
    });

    test('stops listening once closed', () async {
      final cubit = buildCubit();
      await cubit.load();
      await cubit.close();

      await repository.addHabit(habit('a'));
      await pumpEventQueue();

      expect(loaded(cubit).habits, isEmpty);
    });
  });

  group('delete', () {
    test('removes the habit from the list and storage', () async {
      await repository.addHabit(habit('a'));
      await repository.addHabit(habit('b'));
      final cubit = buildCubit();
      await cubit.load();

      await cubit.delete('a');

      expect(loaded(cubit).habits.map((h) => h.habit.id), ['b']);
      expect(await repository.getHabit('a'), isNull);
    });

    test('reloads instead of throwing when the habit is gone', () async {
      await repository.addHabit(habit('a'));
      await repository.addHabit(habit('b'));
      final cubit = buildCubit();
      await cubit.load();
      await repository.deleteHabit('a');

      await cubit.delete('a');

      expect(loaded(cubit).habits.map((h) => h.habit.id), ['b']);
    });
  });

  group('refreshIfDayChanged', () {
    test('does nothing on the same day', () async {
      await repository.addHabit(habit('a'));
      final cubit = buildCubit();
      await cubit.load();
      final before = cubit.state;
      // A change it would pick up if it reloaded (stored without notifying).
      repository.habits['b'] = habit('b');

      await cubit.refreshIfDayChanged();

      expect(cubit.state, before);
    });

    test('reloads for the new day after midnight', () async {
      await repository.addHabit(habit('a', done: [now]));
      final cubit = buildCubit();
      await cubit.load();
      expect(loaded(cubit).progress.done, 1);

      now = DateTime(2026, 10, 21, 0, 5);
      await cubit.refreshIfDayChanged();

      final state = loaded(cubit);
      expect(state.today, DateTime(2026, 10, 21));
      expect(state.progress.done, 0);
      // Yesterday's check keeps the streak alive.
      expect(state.habits.single.currentStreak, 1);
    });
  });

  test('does not emit after close while a save is running', () async {
    await repository.addHabit(habit('a'));
    final cubit = buildCubit();
    await cubit.load();

    final pending = cubit.toggleToday('a');
    await cubit.close();

    await expectLater(pending, completes);
  });
}
