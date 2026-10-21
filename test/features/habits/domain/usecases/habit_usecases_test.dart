import 'package:athar/features/habits/domain/entities/habit.dart';
import 'package:athar/features/habits/domain/entities/reminder_time.dart';
import 'package:athar/features/habits/domain/repositories/habit_repository.dart';
import 'package:athar/features/habits/domain/usecases/add_habit.dart';
import 'package:athar/features/habits/domain/usecases/delete_habit.dart';
import 'package:athar/features/habits/domain/usecases/get_habit.dart';
import 'package:athar/features/habits/domain/usecases/get_habits.dart';
import 'package:athar/features/habits/domain/usecases/toggle_habit_today.dart';
import 'package:athar/features/habits/domain/usecases/update_habit.dart';
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

  group('ToggleHabitToday', () {
    late ToggleHabitToday toggle;

    setUp(() => toggle = ToggleHabitToday(repository, now: () => now));

    test('marks today done and saves it', () async {
      await repository.addHabit(existing());
      final updated = await toggle('h1');
      expect(updated.completedDates, {DateTime(2026, 10, 20)});
      expect(repository.habits['h1'], updated);
    });

    test('undoes today when already done, keeping other days', () async {
      await repository.addHabit(
        existing(
          completedDates: [DateTime(2026, 10, 19), DateTime(2026, 10, 20, 8)],
        ),
      );
      final updated = await toggle('h1');
      expect(updated.completedDates, {DateTime(2026, 10, 19)});
      expect(repository.habits['h1'], updated);
    });

    test('throws for an unknown habit', () async {
      expect(() => toggle('missing'), throwsA(isA<HabitNotFoundException>()));
    });
  });
}
