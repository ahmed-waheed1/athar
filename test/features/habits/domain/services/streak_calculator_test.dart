import 'package:athar/features/habits/domain/entities/habit.dart';
import 'package:athar/features/habits/domain/services/streak_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

Habit habitWith(List<DateTime> completedDates, {DateTime? createdAt}) => Habit(
  id: 'h1',
  name: 'Read 10 pages',
  iconKey: 'book',
  colorKey: 'teal',
  createdAt: createdAt ?? DateTime(2026, 1, 1),
  completedDates: completedDates,
);

StreakCalculator calculatorAt(DateTime now) => StreakCalculator(now: () => now);

/// Consecutive days ending at [last], oldest first.
List<DateTime> daysEndingAt(DateTime last, int count) => [
  for (var i = count - 1; i >= 0; i--)
    DateTime(last.year, last.month, last.day - i),
];

void main() {
  // Mid-afternoon, so a time-of-day on "now" must not leak into day math.
  final now = DateTime(2026, 10, 20, 15, 30);
  final today = DateTime(2026, 10, 20);
  final yesterday = DateTime(2026, 10, 19);
  final calculator = calculatorAt(now);

  group('no completions', () {
    final habit = habitWith([]);

    test('current and best streak are 0', () {
      expect(calculator.currentStreak(habit), 0);
      expect(calculator.bestStreak(habit), 0);
    });

    test('total completions is 0', () {
      expect(calculator.totalCompletions(habit), 0);
    });

    test('consistency is 0 when the habit has past days', () {
      expect(calculator.consistencyPercent(habit), 0);
    });

    test('consistency is null for a habit created today', () {
      expect(
        calculator.consistencyPercent(habitWith([], createdAt: now)),
        isNull,
      );
    });
  });

  group('single day', () {
    test('today only gives a streak of 1', () {
      final habit = habitWith([today]);
      expect(calculator.currentStreak(habit), 1);
      expect(calculator.bestStreak(habit), 1);
      expect(calculator.totalCompletions(habit), 1);
    });

    test('a single day long ago gives current 0 and best 1', () {
      final habit = habitWith([DateTime(2026, 9, 1)]);
      expect(calculator.currentStreak(habit), 0);
      expect(calculator.bestStreak(habit), 1);
      expect(calculator.totalCompletions(habit), 1);
    });
  });

  group('consecutive days', () {
    test('five days ending today', () {
      final habit = habitWith(daysEndingAt(today, 5));
      expect(calculator.currentStreak(habit), 5);
      expect(calculator.bestStreak(habit), 5);
      expect(calculator.totalCompletions(habit), 5);
    });

    test('order of completedDates does not matter', () {
      final habit = habitWith(daysEndingAt(today, 5).reversed.toList());
      expect(calculator.currentStreak(habit), 5);
      expect(calculator.bestStreak(habit), 5);
    });
  });

  group('a gap', () {
    // Oct 1–10 (10 days), gap on Oct 11, then Oct 12–20 (9 days).
    final habit = habitWith([
      ...daysEndingAt(DateTime(2026, 10, 10), 10),
      ...daysEndingAt(today, 9),
    ]);

    test('current streak restarts after the gap', () {
      expect(calculator.currentStreak(habit), 9);
    });

    test('best streak is the longest run before the gap', () {
      expect(calculator.bestStreak(habit), 10);
    });

    test('total counts both runs', () {
      expect(calculator.totalCompletions(habit), 19);
    });
  });

  group('today unchecked', () {
    final habit = habitWith(daysEndingAt(yesterday, 6));

    test('streak is still alive through yesterday', () {
      expect(calculator.currentStreak(habit), 6);
      expect(calculator.bestStreak(habit), 6);
    });

    test('still alive one minute before midnight', () {
      final late = calculatorAt(DateTime(2026, 10, 20, 23, 59));
      expect(late.currentStreak(habit), 6);
    });

    test('broken once the day has ended', () {
      final nextDay = calculatorAt(DateTime(2026, 10, 21, 0, 1));
      expect(nextDay.currentStreak(habit), 0);
      expect(nextDay.bestStreak(habit), 6);
    });
  });

  group('yesterday and today both unchecked', () {
    final habit = habitWith(daysEndingAt(DateTime(2026, 10, 18), 6));

    test('current streak is broken', () {
      expect(calculator.currentStreak(habit), 0);
    });

    test('best streak keeps the history', () {
      expect(calculator.bestStreak(habit), 6);
    });
  });

  group('month boundary', () {
    final march2 = DateTime(2026, 3, 2, 9);

    test('streak runs across Feb 28 → Mar 1 (non-leap year)', () {
      final habit = habitWith([
        DateTime(2026, 2, 27),
        DateTime(2026, 2, 28),
        DateTime(2026, 3, 1),
        DateTime(2026, 3, 2),
      ]);
      expect(calculatorAt(march2).currentStreak(habit), 4);
      expect(calculatorAt(march2).bestStreak(habit), 4);
    });

    test('streak runs across Feb 29 in a leap year', () {
      final habit = habitWith([
        DateTime(2028, 2, 28),
        DateTime(2028, 2, 29),
        DateTime(2028, 3, 1),
      ], createdAt: DateTime(2028, 1, 1));
      final c = calculatorAt(DateTime(2028, 3, 1, 20));
      expect(c.currentStreak(habit), 3);
    });

    test('streak runs across a 30-day month with today unchecked', () {
      final habit = habitWith([DateTime(2026, 4, 29), DateTime(2026, 4, 30)]);
      expect(calculatorAt(DateTime(2026, 5, 1, 8)).currentStreak(habit), 2);
    });

    test('a missing last day of the month breaks the streak', () {
      final habit = habitWith([
        DateTime(2026, 4, 28),
        DateTime(2026, 4, 29),
        DateTime(2026, 5, 1),
      ]);
      final c = calculatorAt(DateTime(2026, 5, 1, 8));
      expect(c.currentStreak(habit), 1);
      expect(c.bestStreak(habit), 2);
    });
  });

  group('year boundary', () {
    final habit = habitWith([
      DateTime(2026, 12, 30),
      DateTime(2026, 12, 31),
      DateTime(2027, 1, 1),
    ]);

    test('streak runs across Dec 31 → Jan 1', () {
      final c = calculatorAt(DateTime(2027, 1, 1, 10));
      expect(c.currentStreak(habit), 3);
      expect(c.bestStreak(habit), 3);
    });

    test('streak through Dec 31 is alive on an unchecked Jan 1', () {
      final c = calculatorAt(DateTime(2027, 1, 1, 10));
      final throughNewYearsEve = habitWith([
        DateTime(2026, 12, 30),
        DateTime(2026, 12, 31),
      ]);
      expect(c.currentStreak(throughNewYearsEve), 2);
    });
  });

  group('duplicate dates', () {
    final habit = habitWith([
      DateTime(2026, 10, 19, 7),
      DateTime(2026, 10, 19, 21, 45),
      DateTime(2026, 10, 19),
      DateTime(2026, 10, 20, 8),
      DateTime(2026, 10, 20, 8),
    ]);

    test('count once in total completions', () {
      expect(calculator.totalCompletions(habit), 2);
    });

    test('count once in streaks', () {
      expect(calculator.currentStreak(habit), 2);
      expect(calculator.bestStreak(habit), 2);
    });
  });

  group('future dates', () {
    test('are ignored', () {
      final habit = habitWith([
        today,
        DateTime(2026, 10, 21),
        DateTime(2026, 10, 22),
      ]);
      expect(calculator.currentStreak(habit), 1);
      expect(calculator.bestStreak(habit), 1);
      expect(calculator.totalCompletions(habit), 1);
    });
  });

  group('consistency percentage (% of days since start)', () {
    // Created Oct 11, so Oct 11–19 are 9 past days, plus today.
    final createdAt = DateTime(2026, 10, 11, 18);

    test('every day done is 100', () {
      final habit = habitWith(daysEndingAt(today, 10), createdAt: createdAt);
      expect(calculator.consistencyPercent(habit), 100);
    });

    test('an unchecked today does not count against it', () {
      final habit = habitWith(daysEndingAt(yesterday, 9), createdAt: createdAt);
      expect(calculator.consistencyPercent(habit), 100);
    });

    test('a checked today counts toward it', () {
      // 5 of 9 past days + today = 6 / 10.
      final habit = habitWith([
        ...daysEndingAt(DateTime(2026, 10, 15), 5),
        today,
      ], createdAt: createdAt);
      expect(calculator.consistencyPercent(habit), 60);
    });

    test('rounds to the nearest whole percent', () {
      // 2 of 3 past days, today unchecked.
      final habit = habitWith([
        DateTime(2026, 10, 17),
        DateTime(2026, 10, 18),
      ], createdAt: DateTime(2026, 10, 17));
      expect(calculator.consistencyPercent(habit), 67);
    });

    test('created today and checked today is 100', () {
      final habit = habitWith([today], createdAt: now);
      expect(calculator.consistencyPercent(habit), 100);
    });

    test('spans month and year boundaries', () {
      // Dec 30 – Jan 2 is 4 days; 3 done.
      final habit = habitWith([
        DateTime(2026, 12, 30),
        DateTime(2026, 12, 31),
        DateTime(2027, 1, 2),
      ], createdAt: DateTime(2026, 12, 30));
      expect(
        calculatorAt(DateTime(2027, 1, 2, 12)).consistencyPercent(habit),
        75,
      );
    });
  });
}
