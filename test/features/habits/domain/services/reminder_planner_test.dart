import 'package:athar/features/habits/domain/entities/habit.dart';
import 'package:athar/features/habits/domain/entities/reminder_time.dart';
import 'package:athar/features/habits/domain/services/reminder_planner.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const planner = ReminderPlanner();
  // Tuesday 20 October 2026, 09:00.
  final now = DateTime(2026, 10, 20, 9);

  Habit habit(
    String id, {
    ReminderTime? at = const ReminderTime(hour: 20, minute: 30),
    List<DateTime> done = const [],
  }) => Habit(
    id: id,
    name: 'Habit $id',
    iconKey: 'book',
    colorKey: 'teal',
    createdAt: DateTime(2026, 10, 1),
    reminderTime: at,
    completedDates: done,
  );

  List<DateTime> times(List<PlannedReminder> plan) => [
    for (final r in plan) r.at,
  ];

  test('plans a week of daily reminders, starting today', () {
    expect(times(planner.plan([habit('a')], now)), [
      for (var d = 20; d < 27; d++) DateTime(2026, 10, d, 20, 30),
    ]);
  });

  test('habits without a reminder time get none', () {
    expect(planner.plan([habit('a', at: null)], now), isEmpty);
    expect(planner.plan([], now), isEmpty);
  });

  test('skips today once the habit is done, but keeps the next days', () {
    final plan = planner.plan([
      habit('a', done: [DateTime(2026, 10, 20, 7)]),
    ], now);
    expect(plan.first.at, DateTime(2026, 10, 21, 20, 30));
    expect(plan, hasLength(7));
  });

  test("skips today when today's time has passed", () {
    final plan = planner.plan([habit('a')], DateTime(2026, 10, 20, 20, 30));
    expect(plan.first.at, DateTime(2026, 10, 21, 20, 30));
  });

  test('a habit done yesterday is still reminded today', () {
    final plan = planner.plan([
      habit('a', done: [DateTime(2026, 10, 19)]),
    ], now);
    expect(plan.first.at, DateTime(2026, 10, 20, 20, 30));
  });

  test('runs across month and year boundaries', () {
    expect(
      times(planner.plan([habit('a')], DateTime(2026, 12, 29, 9))),
      containsAllInOrder([
        DateTime(2026, 12, 31, 20, 30),
        DateTime(2027, 1, 1, 20, 30),
        DateTime(2027, 1, 4, 20, 30),
      ]),
    );
  });

  test('sorts every habit together by time', () {
    final plan = planner.plan([
      habit('late', at: const ReminderTime(hour: 21, minute: 0)),
      habit('early', at: const ReminderTime(hour: 7, minute: 0)),
    ], DateTime(2026, 10, 20, 6));
    expect(plan.take(2).map((r) => r.habit.id), ['early', 'late']);
    expect(plan, hasLength(14));
  });

  test('many habits share the cap (iOS keeps 64), but each keeps one', () {
    final many = [for (var i = 0; i < 20; i++) habit('h$i')];
    final plan = planner.plan(many, now);
    expect(plan, hasLength(60));
    for (final h in many) {
      expect(plan.where((r) => r.habit.id == h.id), hasLength(3));
    }
    final tooMany = [for (var i = 0; i < 80; i++) habit('h$i')];
    expect(planner.plan(tooMany, now), hasLength(80));
  });
}
