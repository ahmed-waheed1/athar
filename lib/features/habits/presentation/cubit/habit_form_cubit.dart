import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_catalog.dart';
import '../../domain/entities/habit_name.dart';
import '../../domain/entities/reminder_time.dart';
import '../../domain/repositories/habit_repository.dart';
import '../../domain/services/streak_calculator.dart';
import '../../domain/usecases/add_habit.dart';
import '../../domain/usecases/delete_habit.dart';
import '../../domain/usecases/get_habit.dart';
import '../../domain/usecases/update_habit.dart';
import 'habit_form_state.dart';

/// Add Habit / Edit Habit form. Call [startAdd] or [startEdit] once.
class HabitFormCubit extends Cubit<HabitFormState> {
  HabitFormCubit({
    required this._addHabit,
    required this._updateHabit,
    required this._getHabit,
    required this._deleteHabit,
    required StreakCalculator streakCalculator,
  }) : _streaks = streakCalculator,
       super(const HabitFormState(mode: HabitFormMode.add));

  final AddHabit _addHabit;
  final UpdateHabit _updateHabit;
  final GetHabit _getHabit;
  final DeleteHabit _deleteHabit;
  final StreakCalculator _streaks;

  /// Edit mode: the habit as loaded. Saving keeps everything else on it
  /// (history, creation date).
  Habit? _original;

  /// A new habit, optionally prefilled (empty-state suggestions). Unknown
  /// keys fall back to the new-habit defaults.
  void startAdd({String? name, String? iconKey, String? colorKey}) {
    final form = HabitFormState(
      mode: HabitFormMode.add,
      status: HabitFormStatus.editing,
      name: name?.trim() ?? '',
      iconKey: HabitCatalog.iconKeys.contains(iconKey)
          ? iconKey!
          : HabitCatalog.newHabitIconKey,
      colorKey: HabitCatalog.colorKeys.contains(colorKey)
          ? colorKey!
          : HabitCatalog.newHabitColorKey,
    );
    emit(form.copyWith(initial: form.values));
  }

  /// Loads habit [id]. Ends in [HabitFormStatus.notFound] when it is gone or
  /// can't be read.
  Future<void> startEdit(String id) async {
    emit(const HabitFormState(mode: HabitFormMode.edit));
    Habit? habit;
    try {
      habit = await _getHabit(id);
    } catch (error, stackTrace) {
      addError(error, stackTrace);
    }
    if (isClosed) return;
    if (habit == null) {
      emit(state.copyWith(status: HabitFormStatus.notFound));
      return;
    }
    _original = habit;
    final form = HabitFormState(
      mode: HabitFormMode.edit,
      status: HabitFormStatus.editing,
      name: habit.name,
      // Stale keys show as the defaults, and saving repairs them.
      iconKey: HabitCatalog.iconOrDefault(habit.iconKey),
      colorKey: HabitCatalog.colorOrDefault(habit.colorKey),
      reminderEnabled: habit.reminderTime != null,
      reminderTime: habit.reminderTime ?? HabitFormState.defaultReminderTime,
      currentStreak: _streaks.currentStreak(habit),
    );
    emit(form.copyWith(initial: form.values));
  }

  void nameChanged(String name) => _edit(state.copyWith(name: name));

  void iconSelected(String key) {
    if (HabitCatalog.iconKeys.contains(key)) {
      _edit(state.copyWith(iconKey: key));
    }
  }

  void colorSelected(String key) {
    if (HabitCatalog.colorKeys.contains(key)) {
      _edit(state.copyWith(colorKey: key));
    }
  }

  void reminderToggled(bool enabled) =>
      _edit(state.copyWith(reminderEnabled: enabled));

  /// Setting a time turns the reminder on.
  void reminderTimeSet(ReminderTime time) =>
      _edit(state.copyWith(reminderTime: time, reminderEnabled: true));

  /// Saves the form. Returns true once saved; false when the name is invalid
  /// (errors show), saving failed, or the habit was deleted meanwhile.
  Future<bool> save() async {
    if (state.status != HabitFormStatus.editing) return false;
    if (HabitName.validate(state.name) != null) {
      emit(
        state.copyWith(
          showErrors: true,
          rejectedSaves: state.rejectedSaves + 1,
        ),
      );
      return false;
    }

    final values = state.values;
    emit(state.copyWith(status: HabitFormStatus.saving));
    try {
      if (state.isEdit) {
        await _updateHabit(
          _original!.copyWith(
            name: values.name,
            iconKey: values.iconKey,
            colorKey: values.colorKey,
            reminderTime: values.reminderTime,
            clearReminderTime: values.reminderTime == null,
          ),
        );
      } else {
        await _addHabit(
          name: values.name,
          iconKey: values.iconKey,
          colorKey: values.colorKey,
          reminderTime: values.reminderTime,
        );
      }
    } on HabitNotFoundException {
      if (!isClosed) emit(state.copyWith(status: HabitFormStatus.notFound));
      return false;
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      if (!isClosed) {
        emit(
          state.copyWith(
            status: HabitFormStatus.editing,
            failedSaves: state.failedSaves + 1,
          ),
        );
      }
      return false;
    }
    if (!isClosed) emit(state.copyWith(status: HabitFormStatus.saved));
    return true;
  }

  /// Edit mode: deletes the habit. A habit that is already gone counts as
  /// deleted.
  Future<void> delete() async {
    final habit = _original;
    if (habit == null || state.status != HabitFormStatus.editing) return;
    emit(state.copyWith(status: HabitFormStatus.saving));
    try {
      await _deleteHabit(habit.id);
    } on HabitNotFoundException {
      // Already gone.
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      if (!isClosed) {
        emit(
          state.copyWith(
            status: HabitFormStatus.editing,
            failedSaves: state.failedSaves + 1,
          ),
        );
      }
      return;
    }
    if (!isClosed) emit(state.copyWith(status: HabitFormStatus.deleted));
  }

  /// Edits are ignored while loading, saving, or after the form is done.
  void _edit(HabitFormState next) {
    if (state.status == HabitFormStatus.editing) emit(next);
  }
}
