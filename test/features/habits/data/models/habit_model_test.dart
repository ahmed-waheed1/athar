import 'package:athar/features/habits/data/models/habit_model.dart';
import 'package:athar/features/habits/domain/entities/habit.dart';
import 'package:athar/features/habits/domain/entities/reminder_time.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Habit habit({
    ReminderTime? reminderTime,
    List<DateTime> completedDates = const [],
  }) => Habit(
    id: 'h1',
    name: 'Read',
    iconKey: 'book',
    colorKey: 'teal',
    createdAt: DateTime(2026, 10, 1, 9, 30, 15, 123, 456),
    reminderTime: reminderTime,
    completedDates: completedDates,
  );

  test('round-trips a habit with a reminder and completed days', () {
    final original = habit(
      reminderTime: const ReminderTime(hour: 21, minute: 5),
      completedDates: [
        DateTime(2025, 12, 31),
        DateTime(2026, 1, 1),
        DateTime(2026, 2, 28),
        DateTime(2026, 3, 1),
      ],
    );
    expect(HabitModel.fromEntity(original).toEntity(), original);
  });

  test('round-trips a habit with no reminder and no completed days', () {
    final original = habit();
    final model = HabitModel.fromEntity(original);

    expect(model.reminderHour, isNull);
    expect(model.reminderMinute, isNull);
    expect(model.completedDates, isEmpty);
    expect(model.toEntity(), original);
    expect(model.toEntity().reminderTime, isNull);
  });

  test('stores the reminder as hour and minute', () {
    final model = HabitModel.fromEntity(
      habit(reminderTime: const ReminderTime(hour: 0, minute: 0)),
    );
    expect(model.reminderHour, 0);
    expect(model.reminderMinute, 0);
    expect(
      model.toEntity().reminderTime,
      const ReminderTime(hour: 0, minute: 0),
    );
  });

  test('stores completed days as sorted yyyy-MM-dd keys', () {
    final model = HabitModel.fromEntity(
      habit(
        completedDates: [
          DateTime(2026, 10, 20, 23, 59),
          DateTime(2026, 1, 5),
          DateTime(2025, 12, 31, 8),
        ],
      ),
    );
    expect(model.completedDates, ['2025-12-31', '2026-01-05', '2026-10-20']);
  });
}
