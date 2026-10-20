import 'dart:io';

import 'package:athar/features/habits/data/datasources/habit_local_data_source.dart';
import 'package:athar/features/habits/data/models/habit_model.dart';
import 'package:athar/features/habits/data/models/hive_registrar.g.dart';
import 'package:athar/features/habits/data/repositories/habit_repository_impl.dart';
import 'package:athar/features/habits/domain/entities/habit.dart';
import 'package:athar/features/habits/domain/entities/reminder_time.dart';
import 'package:athar/features/habits/domain/repositories/habit_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';

void main() {
  late Directory hiveDir;
  late HabitRepositoryImpl repository;

  Future<HabitRepositoryImpl> openRepository() async {
    final box = await Hive.openBox<HabitModel>(HabitLocalDataSource.boxName);
    return HabitRepositoryImpl(HabitLocalDataSource(box));
  }

  Habit habit(String id, {DateTime? createdAt}) => Habit(
    id: id,
    name: 'Habit $id',
    iconKey: 'book',
    colorKey: 'teal',
    createdAt: createdAt ?? DateTime(2026, 10, 1),
  );

  setUpAll(() => Hive.registerAdapters());

  setUp(() async {
    hiveDir = await Directory.systemTemp.createTemp('athar_hive_test');
    Hive.init(hiveDir.path);
    repository = await openRepository();
  });

  tearDown(() async {
    await Hive.close();
    await hiveDir.delete(recursive: true);
  });

  test('starts empty', () async {
    expect(await repository.getHabits(), isEmpty);
    expect(await repository.getHabit('missing'), isNull);
  });

  test('adds a habit and reads it back', () async {
    final original = Habit(
      id: 'h1',
      name: 'قراءة',
      iconKey: 'book',
      colorKey: 'teal',
      createdAt: DateTime(2026, 10, 1, 9, 30, 15, 123, 456),
      reminderTime: const ReminderTime(hour: 7, minute: 30),
      completedDates: [DateTime(2025, 12, 31), DateTime(2026, 1, 1)],
    );
    await repository.addHabit(original);

    expect(await repository.getHabit('h1'), original);
    expect(await repository.getHabits(), [original]);
  });

  test('persists habits across reopening the box', () async {
    final original = habit('h1').toggleCompletion(DateTime(2026, 10, 20));
    await repository.addHabit(original);
    await Hive.close();

    final reopened = await openRepository();
    expect(await reopened.getHabits(), [original]);
  });

  test('returns habits in creation order', () async {
    await repository.addHabit(habit('c', createdAt: DateTime(2026, 10, 3)));
    await repository.addHabit(habit('a', createdAt: DateTime(2026, 10, 1)));
    await repository.addHabit(habit('b', createdAt: DateTime(2026, 10, 2)));

    final habits = await repository.getHabits();
    expect(habits.map((h) => h.id), ['a', 'b', 'c']);
  });

  test('updates an existing habit', () async {
    await repository.addHabit(
      habit('h1')
          .copyWith(reminderTime: const ReminderTime(hour: 8, minute: 0)),
    );
    final updated = habit(
      'h1',
    ).copyWith(name: 'Read 10 pages', completedDates: [DateTime(2026, 10, 20)]);
    await repository.updateHabit(updated);

    final stored = await repository.getHabit('h1');
    expect(stored, updated);
    expect(stored!.reminderTime, isNull);
  });

  test('updating a missing habit throws and stores nothing', () async {
    await expectLater(
      repository.updateHabit(habit('missing')),
      throwsA(
        isA<HabitNotFoundException>().having((e) => e.id, 'id', 'missing'),
      ),
    );
    expect(await repository.getHabits(), isEmpty);
  });

  test('deletes a habit', () async {
    await repository.addHabit(habit('h1'));
    await repository.addHabit(habit('h2'));
    await repository.deleteHabit('h1');

    expect(await repository.getHabit('h1'), isNull);
    expect((await repository.getHabits()).map((h) => h.id), ['h2']);
  });

  test('deleting a missing habit throws', () async {
    await expectLater(
      repository.deleteHabit('missing'),
      throwsA(
        isA<HabitNotFoundException>().having((e) => e.id, 'id', 'missing'),
      ),
    );
  });
}
