import 'package:athar/features/habits/domain/entities/habit.dart';
import 'package:athar/features/habits/domain/entities/reminder_time.dart';
import 'package:athar/features/habits/domain/utils/habit_dates.dart';
import 'package:flutter_test/flutter_test.dart';

Habit buildHabit({List<DateTime> completedDates = const []}) => Habit(
  id: 'h1',
  name: 'Drink water',
  iconKey: 'water',
  colorKey: 'blue',
  createdAt: DateTime(2026, 10, 1, 9, 15),
  completedDates: completedDates,
);

void main() {
  group('completedDates', () {
    test('are normalized to local dates and deduplicated', () {
      final habit = buildHabit(
        completedDates: [
          DateTime(2026, 10, 5, 7, 30),
          DateTime(2026, 10, 5, 22),
          DateTime(2026, 10, 6),
        ],
      );
      expect(habit.completedDates, {
        DateTime(2026, 10, 5),
        DateTime(2026, 10, 6),
      });
    });

    test('cannot be modified from outside', () {
      final habit = buildHabit();
      expect(
        () => habit.completedDates.add(DateTime(2026, 10, 5)),
        throwsUnsupportedError,
      );
    });

    test('isCompletedOn ignores time of day', () {
      final habit = buildHabit(completedDates: [DateTime(2026, 10, 5)]);
      expect(habit.isCompletedOn(DateTime(2026, 10, 5, 23, 59)), isTrue);
      expect(habit.isCompletedOn(DateTime(2026, 10, 6)), isFalse);
    });
  });

  group('toggleCompletion', () {
    test('adds a missing day', () {
      final toggled = buildHabit().toggleCompletion(DateTime(2026, 10, 5, 8));
      expect(toggled.completedDates, {DateTime(2026, 10, 5)});
    });

    test('removes an existing day', () {
      final habit = buildHabit(completedDates: [DateTime(2026, 10, 5)]);
      final toggled = habit.toggleCompletion(DateTime(2026, 10, 5, 20));
      expect(toggled.completedDates, isEmpty);
    });

    test('keeps every other field', () {
      final habit = buildHabit().copyWith(
        reminderTime: const ReminderTime(hour: 20, minute: 30),
      );
      final toggled = habit.toggleCompletion(DateTime(2026, 10, 5));
      expect(toggled.copyWith(completedDates: const []), habit);
    });
  });

  group('copyWith', () {
    test('can clear the reminder', () {
      final habit = buildHabit().copyWith(
        reminderTime: const ReminderTime(hour: 8, minute: 0),
      );
      expect(habit.copyWith(clearReminderTime: true).reminderTime, isNull);
    });

    test('keeps the reminder when not given', () {
      final habit = buildHabit().copyWith(
        reminderTime: const ReminderTime(hour: 8, minute: 0),
      );
      expect(
        habit.copyWith(name: 'Water').reminderTime,
        const ReminderTime(hour: 8, minute: 0),
      );
    });
  });

  test('equal habits compare equal regardless of date order', () {
    final a = buildHabit(
      completedDates: [DateTime(2026, 10, 5), DateTime(2026, 10, 6)],
    );
    final b = buildHabit(
      completedDates: [DateTime(2026, 10, 6, 12), DateTime(2026, 10, 5)],
    );
    expect(a, b);
  });

  group('date keys (yyyy-MM-dd)', () {
    test('format with zero padding', () {
      expect(HabitDates.toKey(DateTime(2026, 3, 7, 23, 10)), '2026-03-07');
    });

    test('parse to a local midnight', () {
      final parsed = HabitDates.fromKey('2026-12-31');
      expect(parsed, DateTime(2026, 12, 31));
      expect(parsed.isUtc, isFalse);
    });

    test('round-trip', () {
      final day = DateTime(2028, 2, 29);
      expect(HabitDates.fromKey(HabitDates.toKey(day)), day);
    });
  });

  group('ReminderTime', () {
    test('rejects out-of-range values', () {
      expect(
        () => ReminderTime(hour: 24, minute: 0),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => ReminderTime(hour: 8, minute: 60),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}
