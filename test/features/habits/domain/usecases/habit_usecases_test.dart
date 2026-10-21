import 'package:athar/features/habits/domain/entities/habit.dart';
import 'package:athar/features/habits/domain/entities/reminder_time.dart';
import 'package:athar/features/habits/domain/repositories/habit_repository.dart';
import 'package:athar/features/habits/domain/services/streak_calculator.dart';
import 'package:athar/features/habits/domain/usecases/add_habit.dart';
import 'package:athar/features/habits/domain/usecases/delete_all_habits.dart';
import 'package:athar/features/habits/domain/usecases/delete_habit.dart';
import 'package:athar/features/habits/domain/usecases/get_habit.dart';
import 'package:athar/features/habits/domain/usecases/get_habits.dart';
import 'package:athar/features/habits/domain/usecases/toggle_habit_today.dart';
import 'package:athar/features/habits/domain/usecases/update_habit.dart';
import 'package:athar/features/habits/domain/utils/habit_dates.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/in_memory_habit_repository.dart';

void main() {
  late InMemoryHabitRepository repository;
  final now = DateTime(2026, 10, 20, 21, 5);

  Habit existing({List<DateTime> completedDates = const []}) => Habit(
    id: 'h1',
    name: 'Read',
    iconKey: 'book',
    colorKey: 'teal',
    createdAt: DateTime(2026, 10, 1),
    completedDates: completedDates,
  );

  setUp(() => repository = InMemoryHabitRepository());

  test('GetHabits returns the stored habits', () async {
    await repository.addHabit(existing());
    expect(await GetHabits(repository)(), [existing()]);
  });

  test('GetHabit returns one habit, or null when it is gone', () async {
    await repository.addHabit(existing());
    expect(await GetHabit(repository)('h1'), existing());
    expect(await GetHabit(repository)('missing'), isNull);
  });

  test(
    'AddHabit creates a habit with a new id, createdAt now and no history',
    () async {
      final add = AddHabit(
        repository,
        now: () => now,
        generateId: () => 'new-id',
      );
      final habit = await add(
        name: 'Morning walk',
        iconKey: 'walk',
        colorKey: 'amber',
        reminderTime: const ReminderTime(hour: 7, minute: 0),
      );

      expect(habit.id, 'new-id');
      expect(habit.createdAt, now);
      expect(habit.completedDates, isEmpty);
      expect(habit.reminderTime, const ReminderTime(hour: 7, minute: 0));
      expect(repository.habits['new-id'], habit);
    },
  );

  test('AddHabit generates distinct ids by default', () async {
    final add = AddHabit(repository, now: () => now);
    final a = await add(name: 'A', iconKey: 'book', colorKey: 'teal');
    final b = await add(name: 'B', iconKey: 'book', colorKey: 'teal');
    expect(a.id, isNot(b.id));
    expect(a.id, isNotEmpty);
  });

  test('UpdateHabit stores the new values', () async {
    await repository.addHabit(existing());
    final renamed = existing().copyWith(name: 'Read 10 pages');
    await UpdateHabit(repository)(renamed);
    expect(repository.habits['h1']!.name, 'Read 10 pages');
  });

  test('DeleteHabit removes the habit', () async {
    await repository.addHabit(existing());
    await DeleteHabit(repository)('h1');
    expect(repository.habits, isEmpty);
  });

  test('DeleteAllHabits removes every habit', () async {
    await repository.addHabit(existing());
    await repository.addHabit(
      Habit(
        id: 'h2',
        name: 'Walk',
        iconKey: 'walk',
        colorKey: 'leaf',
        createdAt: DateTime(2026, 10, 2),
      ),
    );
    await DeleteAllHabits(repository)();
    expect(await repository.getHabits(), isEmpty);
  });

  group('ToggleHabitToday', () {
    late ToggleHabitToday toggle;

    ToggleHabitToday toggleAt(DateTime time) => ToggleHabitToday(
      repository,
      StreakCalculator(now: () => time),
      now: () => time,
    );

    /// [streak] done days ending the day before [today].
    List<DateTime> daysBefore(DateTime today, int streak) => [
      for (var i = 1; i <= streak; i++) HabitDates.addDays(today, -i),
    ];

    setUp(() => toggle = toggleAt(now));

    test('marks today done and saves it', () async {
      await repository.addHabit(existing());
      final checkIn = await toggle('h1');
      expect(checkIn.isDone, isTrue);
      expect(checkIn.currentStreak, 1);
      expect(checkIn.milestone, isNull);
      expect(checkIn.habit.completedDates, {DateTime(2026, 10, 20)});
      expect(repository.habits['h1'], checkIn.habit);
    });

    test('undoes today when already done, keeping other days', () async {
      await repository.addHabit(
        existing(
          completedDates: [DateTime(2026, 10, 19), DateTime(2026, 10, 20, 8)],
        ),
      );
      final checkIn = await toggle('h1');
      expect(checkIn.isDone, isFalse);
      expect(checkIn.habit.completedDates, {DateTime(2026, 10, 19)});
      expect(repository.habits['h1'], checkIn.habit);
    });

    test('throws for an unknown habit', () async {
      expect(() => toggle('missing'), throwsA(isA<HabitNotFoundException>()));
    });

    group('milestones', () {
      final today = DateTime(2026, 10, 20);

      for (final milestone in [7, 30, 100]) {
        test('reaching $milestone reports it once and records it', () async {
          await repository.addHabit(
            existing(completedDates: daysBefore(today, milestone - 1)),
          );

          final checkIn = await toggle('h1');

          expect(checkIn.currentStreak, milestone);
          expect(checkIn.milestone, milestone);
          expect(checkIn.habit.celebratedMilestones, {milestone});
          expect(repository.habits['h1']!.celebratedMilestones, {milestone});
        });
      }

      test('other streak lengths are not milestones', () async {
        for (final streak in [1, 6, 8, 14, 29, 31, 60, 99, 101, 365]) {
          repository.habits.clear();
          await repository.addHabit(
            existing(completedDates: daysBefore(today, streak - 1)),
          );
          final checkIn = await toggle('h1');
          expect(checkIn.currentStreak, streak);
          expect(checkIn.milestone, isNull, reason: 'streak $streak');
          expect(checkIn.habit.celebratedMilestones, isEmpty);
        }
      });

      test(
        'unchecking and rechecking the same day does not repeat it',
        () async {
          await repository.addHabit(
            existing(completedDates: daysBefore(today, 6)),
          );

          final first = await toggle('h1');
          final undo = await toggle('h1');
          final again = await toggle('h1');

          expect(first.milestone, 7);
          expect(undo.isDone, isFalse);
          expect(undo.milestone, isNull);
          // Unchecking keeps the record.
          expect(undo.habit.celebratedMilestones, {7});
          expect(again.isDone, isTrue);
          expect(again.currentStreak, 7);
          expect(again.milestone, isNull);
          expect(repository.habits['h1']!.celebratedMilestones, {7});
        },
      );

      test(
        'a rebuilt streak does not celebrate the same milestone again',
        () async {
          await repository.addHabit(
            existing(completedDates: daysBefore(today, 6))
                .markMilestoneCelebrated(7),
          );

          final checkIn = await toggle('h1');

          expect(checkIn.currentStreak, 7);
          expect(checkIn.milestone, isNull);
        },
      );

      test('each milestone is recorded alongside earlier ones', () async {
        await repository.addHabit(
          existing(completedDates: daysBefore(today, 29))
              .markMilestoneCelebrated(7),
        );

        final checkIn = await toggle('h1');

        expect(checkIn.milestone, 30);
        expect(checkIn.habit.celebratedMilestones, {7, 30});
      });

      test('counts a streak across a month and year boundary', () async {
        final newYear = DateTime(2027, 1, 3, 7);
        // Dec 28 – Jan 2, then today Jan 3 makes 7.
        await repository.addHabit(
          existing(completedDates: daysBefore(DateTime(2027, 1, 3), 6)),
        );

        final checkIn = await toggleAt(newYear)('h1');

        expect(checkIn.currentStreak, 7);
        expect(checkIn.milestone, 7);
      });

      test('a gap means no milestone', () async {
        await repository.addHabit(
          existing(
            completedDates: [
              ...daysBefore(today, 6).where((d) => d != DateTime(2026, 10, 17)),
            ],
          ),
        );

        final checkIn = await toggle('h1');

        expect(checkIn.currentStreak, 3);
        expect(checkIn.milestone, isNull);
      });
    });
  });
}
