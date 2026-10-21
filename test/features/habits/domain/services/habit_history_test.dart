import 'package:athar/features/habits/domain/entities/habit.dart';
import 'package:athar/features/habits/domain/services/habit_history.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final today = DateTime(2026, 10, 20);

  Habit habit({
    required DateTime createdAt,
    Iterable<DateTime> completedDates = const [],
  }) => Habit(
    id: 'h',
    name: 'Read',
    iconKey: 'book',
    colorKey: 'indigo',
    createdAt: createdAt,
    completedDates: completedDates,
  );

  group('statusOn', () {
    final h = habit(
      createdAt: DateTime(2026, 10, 10, 18, 45),
      completedDates: [DateTime(2026, 10, 12), DateTime(2026, 10, 19)],
    );
    HabitDayStatus status(DateTime day) =>
        HabitHistory.statusOn(h, day, today: today);

    test('days before the habit existed have no data, not misses', () {
      expect(status(DateTime(2026, 10, 9)), HabitDayStatus.beforeStart);
      expect(status(DateTime(2026, 9, 30)), HabitDayStatus.beforeStart);
    });

    test('the creation day counts from midnight', () {
      expect(status(DateTime(2026, 10, 10)), HabitDayStatus.missed);
    });

    test('done and missed days since the start', () {
      expect(status(DateTime(2026, 10, 12)), HabitDayStatus.done);
      expect(status(DateTime(2026, 10, 13)), HabitDayStatus.missed);
      expect(status(DateTime(2026, 10, 19, 23, 59)), HabitDayStatus.done);
    });

    test('an unchecked today is open, not missed', () {
      expect(status(today), HabitDayStatus.open);
      final done = habit(
        createdAt: DateTime(2026, 10, 10),
        completedDates: [today],
      );
      expect(
        HabitHistory.statusOn(done, today, today: today),
        HabitDayStatus.done,
      );
    });

    test('days after today are future', () {
      expect(status(DateTime(2026, 10, 21)), HabitDayStatus.future);
    });
  });

  group('monthProgress', () {
    test('counts from the first of the month to today', () {
      final h = habit(
        createdAt: DateTime(2026, 8, 1),
        completedDates: [
          DateTime(2026, 9, 30),
          DateTime(2026, 10, 1),
          DateTime(2026, 10, 20),
        ],
      );
      final progress = HabitHistory.monthProgress(h, today: today);
      expect(progress.total, 20);
      expect(progress.done, 2);
      expect(progress.days.first, isTrue);
      expect(progress.days.last, isTrue);
    });

    test('a habit created mid-month counts from its first day', () {
      final h = habit(
        createdAt: DateTime(2026, 10, 15),
        completedDates: [DateTime(2026, 10, 16)],
      );
      final progress = HabitHistory.monthProgress(h, today: today);
      expect(progress.total, 6);
      expect(progress.done, 1);
    });

    test('on the first of a new year it is just today', () {
      final h = habit(
        createdAt: DateTime(2026, 6, 1),
        completedDates: [DateTime(2026, 12, 31)],
      );
      final progress = HabitHistory.monthProgress(
        h,
        today: DateTime(2027, 1, 1),
      );
      expect(progress.total, 1);
      expect(progress.done, 0);
    });
  });
}
