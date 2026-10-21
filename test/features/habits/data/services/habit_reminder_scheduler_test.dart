import 'package:athar/features/habits/data/services/habit_reminder_scheduler.dart';
import 'package:athar/features/habits/data/services/reminder_copy.dart';
import 'package:athar/features/habits/domain/entities/habit.dart';
import 'package:athar/features/habits/domain/entities/reminder_time.dart';
import 'package:athar/features/habits/domain/services/streak_calculator.dart';
import 'package:athar/features/habits/domain/usecases/delete_all_habits.dart';
import 'package:athar/features/habits/domain/usecases/delete_habit.dart';
import 'package:athar/features/habits/domain/usecases/get_habits.dart';
import 'package:athar/features/habits/domain/usecases/toggle_habit_today.dart';
import 'package:athar/features/habits/domain/usecases/update_habit.dart';
import 'package:athar/features/habits/domain/usecases/watch_habit_changes.dart';
import 'package:athar/features/settings/domain/entities/app_settings.dart';
import 'package:athar/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fake_notification_service.dart';
import '../../../../helpers/in_memory_habit_repository.dart';
import '../../../../helpers/in_memory_settings_repository.dart';

/// The scheduler on its own triggers: every test changes something and
/// lets the events run, without calling sync() itself.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Tuesday 20 October 2026, 09:00.
  final now = DateTime(2026, 10, 20, 9);
  final copy = ReminderCopySource();

  late InMemoryHabitRepository repository;
  late FakeNotificationService notifications;
  late SettingsCubit settings;
  late HabitReminderScheduler scheduler;

  Habit habit(
    String id, {
    String? name,
    ReminderTime? at = const ReminderTime(hour: 20, minute: 30),
  }) => Habit(
    id: id,
    name: name ?? 'Habit $id',
    iconKey: 'book',
    colorKey: 'teal',
    createdAt: DateTime(2026, 10, 1),
    reminderTime: at,
  );

  Set<String> scheduledTitles() => {
    for (final n in notifications.scheduled) n.title,
  };

  setUpAll(() async {
    // Read both translation files up front, so only in-memory work is left.
    await copy.load(AppLanguage.en);
    await copy.load(AppLanguage.ar);
  });

  setUp(() async {
    repository = InMemoryHabitRepository();
    notifications = FakeNotificationService();
    settings = buildSettingsCubit();
    scheduler = HabitReminderScheduler(
      getHabits: GetHabits(repository),
      watchHabitChanges: WatchHabitChanges(repository),
      notifications: notifications,
      copy: copy,
      language: () => settings.state.language,
      languageChanges: settings.stream.map((s) => s.language),
      now: () => now,
    );
    await scheduler.start();
  });

  tearDown(() async {
    await scheduler.dispose();
    await settings.close();
  });

  test('app start schedules nothing when there are no reminders', () {
    expect(notifications.replaceCalls, 1);
    expect(notifications.scheduled, isEmpty);
  });

  test('adding a habit schedules its daily reminder, in English', () async {
    await repository.addHabit(habit('read', name: 'Read 10 pages'));
    await pumpEventQueue();

    expect(notifications.scheduled, hasLength(7));
    final first = notifications.scheduled.first;
    expect(first.at, DateTime(2026, 10, 20, 20, 30));
    expect(first.title, 'Time for “Read 10 pages”');
    expect(first.body, 'Leave today’s trace and keep your path going.');
    expect(notifications.channel?.name, 'Habit reminders');
  });

  test('a habit without a reminder time gets no reminder', () async {
    await repository.addHabit(habit('quiet', at: null));
    await repository.addHabit(habit('loud'));
    await pumpEventQueue();

    expect(scheduledTitles(), {'Time for “Habit loud”'});
  });

  test('editing reschedules: new time, new name, reminder removed', () async {
    final read = habit('read');
    await repository.addHabit(read);
    await pumpEventQueue();

    await UpdateHabit(repository)(
      read.copyWith(
        name: 'Read 20 pages',
        reminderTime: const ReminderTime(hour: 7, minute: 15),
      ),
    );
    await pumpEventQueue();
    expect(scheduledTitles(), {'Time for “Read 20 pages”'});
    // 07:15 today has passed, so tomorrow first.
    expect(notifications.scheduled.first.at, DateTime(2026, 10, 21, 7, 15));

    await UpdateHabit(repository)(read.copyWith(clearReminderTime: true));
    await pumpEventQueue();
    expect(notifications.scheduled, isEmpty);
  });

  test("deleting a habit removes only that habit's reminders", () async {
    await repository.addHabit(habit('a'));
    await repository.addHabit(habit('b'));
    await pumpEventQueue();
    expect(notifications.scheduled, hasLength(14));

    await DeleteHabit(repository)('a');
    await pumpEventQueue();
    expect(scheduledTitles(), {'Time for “Habit b”'});
  });

  test('reset all data removes every reminder', () async {
    await repository.addHabit(habit('a'));
    await repository.addHabit(habit('b'));
    await pumpEventQueue();

    await DeleteAllHabits(repository)();
    await pumpEventQueue();
    expect(notifications.scheduled, isEmpty);
  });

  test(
    "checking in today drops today's reminder; undo brings it back",
    () async {
      await repository.addHabit(habit('a'));
      await pumpEventQueue();
      final toggle = ToggleHabitToday(
        repository,
        StreakCalculator(),
        now: () => now,
      );

      await toggle('a');
      await pumpEventQueue();
      expect(notifications.scheduled.first.at, DateTime(2026, 10, 21, 20, 30));
      expect(notifications.scheduled, hasLength(7));

      await toggle('a');
      await pumpEventQueue();
      expect(notifications.scheduled.first.at, DateTime(2026, 10, 20, 20, 30));
    },
  );

  test('switching language rewrites the text and channel name', () async {
    await repository.addHabit(habit('water', name: 'شرب الماء'));
    await pumpEventQueue();
    final callsBefore = notifications.replaceCalls;

    await settings.changeLanguage(AppLanguage.ar);
    await pumpEventQueue();

    expect(notifications.replaceCalls, greaterThan(callsBefore));
    expect(notifications.scheduled, hasLength(7));
    expect(notifications.scheduled.first.title, 'حان وقت «شرب الماء»');
    expect(notifications.scheduled.first.body, 'اترك أثر اليوم وواصل طريقك.');
    expect(notifications.channel?.name, 'تذكيرات العادات');

    await settings.changeLanguage(AppLanguage.en);
    await pumpEventQueue();
    expect(notifications.scheduled.first.title, 'Time for “شرب الماء”');
    expect(notifications.channel?.name, 'Habit reminders');
  });

  test('a burst of changes ends with the reminders current', () async {
    for (var i = 0; i < 5; i++) {
      await repository.addHabit(habit('h$i'));
    }
    await pumpEventQueue();
    expect(notifications.scheduled, hasLength(35));
  });

  test('debug test reminders go through the same text', () async {
    await scheduler.showTestReminder(name: 'Test habit');
    expect(notifications.shown.single.title, 'Time for “Test habit”');

    await scheduler.scheduleTestReminder(
      const Duration(minutes: 1),
      name: 'Test habit',
    );
    expect(notifications.scheduled.single.at, DateTime(2026, 10, 20, 9, 1));
  });
}
