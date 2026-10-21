import 'dart:io';

import 'package:athar/features/habits/data/datasources/habit_local_data_source.dart';
import 'package:athar/features/habits/data/models/habit_model.dart';
import 'package:athar/features/habits/data/models/hive_adapters.dart';
import 'package:athar/features/habits/data/repositories/habit_repository_impl.dart';
import 'package:athar/features/habits/domain/entities/reminder_time.dart';
import 'package:athar/features/habits/domain/services/streak_calculator.dart';
import 'package:athar/features/habits/domain/usecases/toggle_habit_today.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';

/// The HabitModel adapter as released before celebratedMilestones (field 8)
/// existed: it writes 8 fields.
class LegacyHabitModelAdapter extends TypeAdapter<HabitModel> {
  @override
  final typeId = 0;

  @override
  HabitModel read(BinaryReader reader) => throw UnimplementedError();

  @override
  void write(BinaryWriter writer, HabitModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.iconKey)
      ..writeByte(3)
      ..write(obj.colorKey)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.reminderHour)
      ..writeByte(6)
      ..write(obj.reminderMinute)
      ..writeByte(7)
      ..write(obj.completedDates);
  }
}

void main() {
  late Directory hiveDir;

  setUp(() async {
    hiveDir = await Directory.systemTemp.createTemp('athar_hive_migration');
    Hive.init(hiveDir.path);
  });

  tearDown(() async {
    await Hive.close();
    await hiveDir.delete(recursive: true);
  });

  /// Writes [model] the way the previous release did, then closes Hive.
  Future<void> writeWithLegacyAdapter(HabitModel model) async {
    Hive.registerAdapter(LegacyHabitModelAdapter(), override: true);
    final box = await Hive.openBox<HabitModel>(HabitLocalDataSource.boxName);
    await box.put(model.id, model);
    await Hive.close();
  }

  Future<HabitRepositoryImpl> openWithCurrentAdapter() async {
    Hive.registerAdapter(HabitModelAdapter(), override: true);
    final box = await Hive.openBox<HabitModel>(HabitLocalDataSource.boxName);
    return HabitRepositoryImpl(HabitLocalDataSource(box));
  }

  // Six done days up to Oct 19, so checking Oct 20 reaches 7.
  final legacy = HabitModel(
    id: 'h1',
    name: 'Drink water',
    iconKey: 'drop',
    colorKey: 'sky',
    createdAt: DateTime(2026, 9, 1, 8, 30),
    reminderHour: 21,
    reminderMinute: 5,
    completedDates: [
      for (var day = 14; day <= 19; day++) '2026-10-${day.toString()}',
    ],
  );

  test(
    'habits saved before celebratedMilestones keep all their data',
    () async {
      await writeWithLegacyAdapter(legacy);

      final repository = await openWithCurrentAdapter();
      final habit = (await repository.getHabit('h1'))!;

      expect(habit.name, 'Drink water');
      expect(habit.iconKey, 'drop');
      expect(habit.colorKey, 'sky');
      expect(habit.createdAt, DateTime(2026, 9, 1, 8, 30));
      expect(habit.reminderTime, const ReminderTime(hour: 21, minute: 5));
      expect(habit.completedDates, {
        for (var day = 14; day <= 19; day++) DateTime(2026, 10, day),
      });
      expect(habit.celebratedMilestones, isEmpty);
    },
  );

  test('a migrated habit celebrates its first milestone and keeps the record '
      'after reopening', () async {
    await writeWithLegacyAdapter(legacy);
    final now = DateTime(2026, 10, 20, 9);
    var repository = await openWithCurrentAdapter();

    final checkIn = await ToggleHabitToday(
      repository,
      StreakCalculator(now: () => now),
      now: () => now,
    )('h1');
    expect(checkIn.milestone, 7);

    await Hive.close();
    repository = await openWithCurrentAdapter();
    final reopened = (await repository.getHabit('h1'))!;
    expect(reopened.celebratedMilestones, {7});
    expect(reopened.completedDates, hasLength(7));
    expect(reopened.reminderTime, const ReminderTime(hour: 21, minute: 5));
  });
}
