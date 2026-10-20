import 'package:athar/features/habits/domain/entities/habit.dart';
import 'package:athar/features/habits/domain/services/habits_overview_calculator.dart';
import 'package:athar/features/habits/domain/services/streak_calculator.dart';
import 'package:athar/features/habits/domain/utils/habit_dates.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 10, 20, 10);
  final today = DateTime(2026, 10, 20);
  final calculator = HabitsOverviewCalculator(
    StreakCalculator(now: () => now),
    now: () => now,
  );

  DateTime daysAgo(int n) => HabitDates.addDays(today, -n);

  Habit habit(
    String id, {
    required DateTime createdAt,
    List<DateTime> done = const [],
  }) => Habit(
    id: id,
    name: id,
    iconKey: 'book',
    colorKey: 'teal',
    createdAt: createdAt,
    completedDates: done,
  );

  test('no habits gives the empty overview', () {
    expect(calculator.calculate([], days: 7), HabitsOverview.empty);
  });

  group('StreakMilestones', () {
    test('next milestone after a streak', () {
      expect(StreakMilestones.nextAfter(0), 7);
      expect(StreakMilestones.nextAfter(7), 14);
      expect(StreakMilestones.nextAfter(99), 100);
      expect(StreakMilestones.nextAfter(365), isNull);
    });
  });

  test('daily ratios only count habits that existed that day', () {
    final a = habit('a', createdAt: daysAgo(2), done: [daysAgo(2), today]);
    final b = habit('b', createdAt: daysAgo(1), done: [today]);

    final overview = calculator.calculate([a, b], days: 4);

    expect(overview.dailyRatios, {
      daysAgo(2): 1.0, // only a existed, done
      daysAgo(1): 0.0, // both existed, none done
      today: 1.0,
    });
  });

  test('longest active streak and its habit', () {
    final a = habit('a', createdAt: daysAgo(10), done: [daysAgo(1), today]);
    final b = habit(
      'b',
      createdAt: daysAgo(10),
      done: [daysAgo(3), daysAgo(2), daysAgo(1)],
    );

    final overview = calculator.calculate([a, b], days: 7);

    expect(overview.longestActiveStreak, 3);
    expect(overview.longestActiveHabit, b);
  });

  test('next milestone is the closest one, noting if today is done', () {
    final six = habit(
      'six',
      createdAt: daysAgo(30),
      done: [for (var i = 0; i < 6; i++) daysAgo(i)],
    );
    final twelve = habit(
      'twelve',
      createdAt: daysAgo(30),
      done: [for (var i = 1; i <= 12; i++) daysAgo(i)],
    );

    final next = calculator.calculate([twelve, six], days: 7).nextMilestone;

    expect(next?.habit, six);
    expect(next?.target, 7);
    expect(next?.remaining, 1);
    expect(next?.isDoneToday, isTrue);
  });

  test('month consistency counts today only once checked', () {
    // Created on Oct 18: possible days 18, 19 (+ 20 once done).
    final a = habit(
      'a',
      createdAt: DateTime(2026, 10, 18),
      done: [DateTime(2026, 10, 18)],
    );
    expect(calculator.calculate([a], days: 7).monthConsistencyPercent, 50);

    final checked = a.toggleCompletion(today);
    expect(
      calculator.calculate([checked], days: 7).monthConsistencyPercent,
      67,
    );
  });

  test('month consistency ignores last month', () {
    final a = habit(
      'a',
      createdAt: DateTime(2026, 9, 1),
      done: [
        DateTime(2026, 9, 30),
        for (var d = 1; d < 20; d++) DateTime(2026, 10, d),
      ],
    );
    expect(calculator.calculate([a], days: 7).monthConsistencyPercent, 100);
  });

  test('month consistency is null for a habit created today', () {
    final a = habit('a', createdAt: now);
    expect(calculator.calculate([a], days: 7).monthConsistencyPercent, isNull);
  });
}
