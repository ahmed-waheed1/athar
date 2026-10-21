import 'package:athar/core/debug/sample_habits.dart';
import 'package:athar/features/habits/domain/entities/habit_catalog.dart';
import 'package:athar/features/habits/domain/services/streak_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 10, 20, 8);
  final habits = buildSampleHabits(now: now, name: (key) => key);
  final streaks = StreakCalculator(now: () => now);

  test('match the Home designs: streaks and the partial state', () {
    expect(
      habits.map(
        (h) => (h.name, streaks.currentStreak(h), h.isCompletedOn(now)),
      ),
      [
        ('debug.samplePray', 40, true),
        ('debug.sampleWater', 6, true),
        ('debug.sampleRead', 21, false),
        ('debug.sampleWalk', 14, true),
        ('debug.sampleEnglish', 9, false),
      ],
    );
  });

  test('use catalog keys only', () {
    for (final habit in habits) {
      expect(HabitCatalog.iconKeys, contains(habit.iconKey));
      expect(HabitCatalog.colorKeys, contains(habit.colorKey));
    }
  });

  test('are in creation order, with no completion before creation', () {
    for (var i = 1; i < habits.length; i++) {
      expect(habits[i].createdAt.isAfter(habits[i - 1].createdAt), isTrue);
    }
    for (final habit in habits) {
      expect(
        habit.completedDates.every((d) => !d.isBefore(habit.createdAt)),
        isTrue,
      );
    }
  });

  test('are the same every time', () {
    expect(buildSampleHabits(now: now, name: (key) => key), habits);
  });

  test('milestone samples are one check-in from 7, 30 and 100', () {
    final samples = buildMilestoneSampleHabits(now: now, name: (key) => key);
    expect(
      samples.map((h) => (streaks.currentStreak(h), h.isCompletedOn(now))),
      [(6, false), (29, false), (99, false)],
    );
    for (final habit in samples) {
      expect(habit.celebratedMilestones, isEmpty);
      expect(HabitCatalog.colorKeys, contains(habit.colorKey));
    }
  });
}
