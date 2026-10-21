import 'package:athar/features/habits/domain/entities/habit.dart';
import 'package:athar/features/habits/domain/entities/habit_catalog.dart';
import 'package:athar/features/habits/domain/entities/habit_name.dart';
import 'package:athar/features/habits/domain/entities/reminder_time.dart';
import 'package:athar/features/habits/domain/services/streak_calculator.dart';
import 'package:athar/features/habits/domain/usecases/add_habit.dart';
import 'package:athar/features/habits/domain/usecases/delete_habit.dart';
import 'package:athar/features/habits/domain/usecases/get_habit.dart';
import 'package:athar/features/habits/domain/usecases/update_habit.dart';
import 'package:athar/features/habits/presentation/cubit/habit_form_cubit.dart';
import 'package:athar/features/habits/presentation/cubit/habit_form_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/in_memory_habit_repository.dart';

class FailingWritesRepository extends InMemoryHabitRepository {
  @override
  Future<void> addHabit(Habit habit) async => throw StateError('disk full');

  @override
  Future<void> updateHabit(Habit habit) async => throw StateError('disk full');

  @override
  Future<void> deleteHabit(String id) async => throw StateError('disk full');
}

class FailingReadsRepository extends InMemoryHabitRepository {
  @override
  Future<Habit?> getHabit(String id) async => throw StateError('corrupt');
}

void main() {
  late InMemoryHabitRepository repository;
  final now = DateTime(2026, 10, 20, 9, 30);

  HabitFormCubit buildCubit([InMemoryHabitRepository? repo]) {
    final r = repo ?? repository;
    return HabitFormCubit(
      addHabit: AddHabit(r, now: () => now, generateId: () => 'new-id'),
      updateHabit: UpdateHabit(r),
      getHabit: GetHabit(r),
      deleteHabit: DeleteHabit(r),
      streakCalculator: StreakCalculator(now: () => now),
    );
  }

  final existing = Habit(
    id: 'read',
    name: 'Read 10 pages',
    iconKey: 'book',
    colorKey: 'indigo',
    createdAt: DateTime(2026, 9, 1),
    reminderTime: const ReminderTime(hour: 20, minute: 30),
    // A 3-day streak running to yesterday; today is still open.
    completedDates: [
      DateTime(2026, 10, 17),
      DateTime(2026, 10, 18),
      DateTime(2026, 10, 19),
    ],
  );

  setUp(() => repository = InMemoryHabitRepository());

  group('add mode', () {
    test('starts empty with the catalog defaults and Save disabled', () {
      final cubit = buildCubit()..startAdd();
      final state = cubit.state;
      expect(state.status, HabitFormStatus.editing);
      expect(state.isEdit, isFalse);
      expect(state.name, '');
      expect(state.iconKey, HabitCatalog.newHabitIconKey);
      expect(state.colorKey, HabitCatalog.newHabitColorKey);
      expect(state.reminderEnabled, isFalse);
      expect(state.isDirty, isFalse);
      expect(state.canSubmit, isFalse);
      expect(state.nameError, isNull);
    });

    test('prefills from a suggestion without counting as a change', () {
      final cubit = buildCubit()
        ..startAdd(name: 'Drink water', iconKey: 'drop', colorKey: 'sky');
      final state = cubit.state;
      expect(state.name, 'Drink water');
      expect(state.iconKey, 'drop');
      expect(state.colorKey, 'sky');
      expect(state.isDirty, isFalse);
      expect(state.hasUnsavedChanges, isFalse);
      // A valid prefilled name can be saved straight away.
      expect(state.canSubmit, isTrue);
    });

    test('unknown query keys fall back to the defaults', () {
      final cubit = buildCubit()
        ..startAdd(name: '  Walk ', iconKey: 'unicorn', colorKey: 'beige');
      expect(cubit.state.name, 'Walk');
      expect(cubit.state.iconKey, HabitCatalog.newHabitIconKey);
      expect(cubit.state.colorKey, HabitCatalog.newHabitColorKey);
    });

    test('any change enables Save and marks the form dirty', () {
      final cubit = buildCubit()..startAdd();
      cubit.colorSelected('coral');
      expect(cubit.state.isDirty, isTrue);
      expect(cubit.state.hasUnsavedChanges, isTrue);
      expect(cubit.state.canSubmit, isTrue);
      cubit.colorSelected('indigo');
      expect(cubit.state.isDirty, isFalse);
    });

    test('whitespace alone is not a change', () {
      final cubit = buildCubit()..startAdd(name: 'Walk');
      cubit.nameChanged('  Walk  ');
      expect(cubit.state.isDirty, isFalse);
    });

    test('ignores keys that are not in the catalog', () {
      final cubit = buildCubit()..startAdd();
      cubit
        ..iconSelected('unicorn')
        ..colorSelected('beige');
      expect(cubit.state.iconKey, HabitCatalog.newHabitIconKey);
      expect(cubit.state.colorKey, HabitCatalog.newHabitColorKey);
    });

    test('saves a trimmed habit with its reminder', () async {
      final cubit = buildCubit()..startAdd();
      cubit
        ..nameChanged('  Learn English  ')
        ..iconSelected('chat')
        ..colorSelected('coral')
        ..reminderTimeSet(const ReminderTime(hour: 7, minute: 15));

      expect(await cubit.save(), isTrue);
      expect(cubit.state.status, HabitFormStatus.saved);
      expect(cubit.state.hasUnsavedChanges, isFalse);
      expect(
        repository.habits['new-id'],
        Habit(
          id: 'new-id',
          name: 'Learn English',
          iconKey: 'chat',
          colorKey: 'coral',
          createdAt: now,
          reminderTime: const ReminderTime(hour: 7, minute: 15),
        ),
      );
    });

    test('a reminder switched off is saved as none', () async {
      final cubit = buildCubit()..startAdd(name: 'Walk');
      cubit
        ..reminderToggled(true)
        ..reminderToggled(false);
      await cubit.save();
      expect(repository.habits['new-id']!.reminderTime, isNull);
    });
  });

  group('reminder', () {
    test('turning it on uses 7:00 PM until a time is set', () {
      final cubit = buildCubit()..startAdd();
      cubit.reminderToggled(true);
      expect(
        cubit.state.values.reminderTime,
        HabitFormState.defaultReminderTime,
      );
      expect(
        HabitFormState.defaultReminderTime,
        const ReminderTime(hour: 19, minute: 0),
      );
    });

    test('setting a time turns it on; switching off keeps the time', () {
      final cubit = buildCubit()..startAdd();
      const time = ReminderTime(hour: 6, minute: 45);
      cubit.reminderTimeSet(time);
      expect(cubit.state.reminderEnabled, isTrue);
      expect(cubit.state.values.reminderTime, time);

      cubit.reminderToggled(false);
      expect(cubit.state.values.reminderTime, isNull);
      cubit.reminderToggled(true);
      expect(cubit.state.values.reminderTime, time);
    });
  });

  group('validation', () {
    test('an empty name is only an error after tapping Save', () async {
      final cubit = buildCubit()..startAdd();
      cubit.colorSelected('coral');
      expect(cubit.state.nameError, isNull);

      expect(await cubit.save(), isFalse);
      expect(cubit.state.status, HabitFormStatus.editing);
      expect(cubit.state.nameError, HabitNameError.empty);
      expect(cubit.state.rejectedSaves, 1);
      expect(repository.habits, isEmpty);

      cubit.nameChanged('Walk');
      expect(cubit.state.nameError, isNull);
      // Clearing it again shows the error right away now.
      cubit.nameChanged('   ');
      expect(cubit.state.nameError, HabitNameError.empty);
    });

    test(
      'a name over the limit is an error while typing and blocks Save',
      () async {
        final cubit = buildCubit()..startAdd();
        final tooLong = 'a' * (HabitName.maxLength + 1);
        cubit.nameChanged(tooLong);
        expect(cubit.state.nameLength, HabitName.maxLength + 1);
        expect(cubit.state.nameError, HabitNameError.tooLong);
        // Save stays tappable so it can shake the field.
        expect(cubit.state.canSubmit, isTrue);

        expect(await cubit.save(), isFalse);
        expect(cubit.state.rejectedSaves, 1);
        expect(repository.habits, isEmpty);

        cubit.nameChanged('a' * HabitName.maxLength);
        expect(cubit.state.nameError, isNull);
        expect(await cubit.save(), isTrue);
      },
    );

    test('the counter counts the trimmed name in graphemes', () {
      final cubit = buildCubit()..startAdd();
      cubit.nameChanged('  تعلّم  ');
      expect(cubit.state.nameLength, 4);
    });
  });

  group('edit mode', () {
    setUp(() => repository.habits[existing.id] = existing);

    test('loads and prefills everything', () async {
      final cubit = buildCubit();
      final future = cubit.startEdit('read');
      expect(cubit.state.status, HabitFormStatus.loading);
      expect(cubit.state.isEdit, isTrue);
      await future;

      final state = cubit.state;
      expect(state.status, HabitFormStatus.editing);
      expect(state.name, 'Read 10 pages');
      expect(state.iconKey, 'book');
      expect(state.colorKey, 'indigo');
      expect(state.reminderEnabled, isTrue);
      expect(state.reminderTime, const ReminderTime(hour: 20, minute: 30));
      expect(state.currentStreak, 3);
      expect(state.isDirty, isFalse);
      expect(state.canSubmit, isTrue);
    });

    test('a missing habit ends in notFound', () async {
      final cubit = buildCubit();
      await cubit.startEdit('gone');
      expect(cubit.state.status, HabitFormStatus.notFound);
      expect(cubit.state.hasUnsavedChanges, isFalse);
    });

    test('a habit that cannot be read ends in notFound', () async {
      final cubit = buildCubit(FailingReadsRepository());
      await cubit.startEdit('read');
      expect(cubit.state.status, HabitFormStatus.notFound);
    });

    test(
      'stale stored keys show as defaults without counting as a change',
      () async {
        repository.habits['old'] = Habit(
          id: 'old',
          name: 'Old',
          iconKey: 'unicorn',
          colorKey: 'beige',
          createdAt: DateTime(2026, 1, 1),
        );
        final cubit = buildCubit();
        await cubit.startEdit('old');
        expect(cubit.state.iconKey, HabitCatalog.defaultIconKey);
        expect(cubit.state.colorKey, HabitCatalog.defaultColorKey);
        expect(cubit.state.isDirty, isFalse);
      },
    );

    test('saves changes and keeps history and creation date', () async {
      final cubit = buildCubit();
      await cubit.startEdit('read');
      cubit
        ..nameChanged(' Read 20 pages ')
        ..colorSelected('plum')
        ..reminderToggled(false);
      expect(cubit.state.hasUnsavedChanges, isTrue);

      expect(await cubit.save(), isTrue);
      final saved = repository.habits['read']!;
      expect(saved.name, 'Read 20 pages');
      expect(saved.colorKey, 'plum');
      expect(saved.iconKey, 'book');
      expect(saved.reminderTime, isNull);
      expect(saved.createdAt, existing.createdAt);
      expect(saved.completedDates, existing.completedDates);
    });

    test('a habit deleted while editing ends in notFound on Save', () async {
      final cubit = buildCubit();
      await cubit.startEdit('read');
      repository.habits.clear();
      cubit.nameChanged('Renamed');
      expect(await cubit.save(), isFalse);
      expect(cubit.state.status, HabitFormStatus.notFound);
    });

    test('delete removes the habit', () async {
      final cubit = buildCubit();
      await cubit.startEdit('read');
      await cubit.delete();
      expect(cubit.state.status, HabitFormStatus.deleted);
      expect(repository.habits, isEmpty);
    });

    test('delete of a habit that is already gone still finishes', () async {
      final cubit = buildCubit();
      await cubit.startEdit('read');
      repository.habits.clear();
      await cubit.delete();
      expect(cubit.state.status, HabitFormStatus.deleted);
    });
  });

  group('failures', () {
    test('a failed save keeps the form and counts the failure', () async {
      final cubit = buildCubit(FailingWritesRepository())
        ..startAdd(name: 'Walk');
      expect(await cubit.save(), isFalse);
      expect(cubit.state.status, HabitFormStatus.editing);
      expect(cubit.state.failedSaves, 1);
      expect(cubit.state.name, 'Walk');
    });

    test('a failed delete keeps the form and counts the failure', () async {
      final failing = FailingWritesRepository();
      failing.habits[existing.id] = existing;
      final cubit = buildCubit(failing);
      await cubit.startEdit('read');
      await cubit.delete();
      expect(cubit.state.status, HabitFormStatus.editing);
      expect(cubit.state.failedSaves, 1);
    });

    test('edits and repeat saves are ignored while saving', () async {
      final cubit = buildCubit()..startAdd(name: 'Walk');
      final first = cubit.save();
      expect(cubit.state.status, HabitFormStatus.saving);
      cubit.nameChanged('Run');
      expect(await cubit.save(), isFalse);
      expect(await first, isTrue);
      expect(repository.habits.values.single.name, 'Walk');
    });
  });
}
