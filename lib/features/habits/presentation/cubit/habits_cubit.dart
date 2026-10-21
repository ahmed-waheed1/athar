import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/check_in.dart';
import '../../domain/entities/habit.dart';
import '../../domain/repositories/habit_repository.dart';
import '../../domain/services/habits_overview_calculator.dart';
import '../../domain/services/streak_calculator.dart';
import '../../domain/usecases/delete_habit.dart';
import '../../domain/usecases/get_habits.dart';
import '../../domain/usecases/toggle_habit_today.dart';
import '../../domain/usecases/watch_habit_changes.dart';
import '../../domain/utils/habit_dates.dart';
import 'habits_state.dart';

/// Today's habits for Home: load, check in / undo, delete. Reloads by itself
/// when the stored habits change elsewhere (e.g. Reset all data in Settings).
class HabitsCubit extends Cubit<HabitsState> {
  HabitsCubit({
    required this._getHabits,
    required this._toggleHabitToday,
    required this._deleteHabit,
    required WatchHabitChanges watchHabitChanges,
    required StreakCalculator streakCalculator,
    required HabitsOverviewCalculator overviewCalculator,
    DateTime Function()? now,
  }) : _streaks = streakCalculator,
       _overview = overviewCalculator,
       _now = now ?? DateTime.now,
       super(const HabitsLoading()) {
    _changes = watchHabitChanges().listen((_) => _scheduleReload());
  }

  /// Days of history in [HabitsOverview.dailyRatios]: the 26-week heatmap
  /// plus the partial current week.
  static const overviewDays = 26 * 7 + 7;

  final GetHabits _getHabits;
  final ToggleHabitToday _toggleHabitToday;
  final DeleteHabit _deleteHabit;
  final StreakCalculator _streaks;
  final HabitsOverviewCalculator _overview;
  final DateTime Function() _now;

  /// Habits with a toggle in progress; repeat taps are ignored until it lands.
  final _toggling = <String>{};

  late final StreamSubscription<void> _changes;
  bool _reloadScheduled = false;

  Future<void> load() async {
    if (state is! HabitsLoaded) emit(const HabitsLoading());
    try {
      _emitLoaded(await _getHabits());
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(HabitsError(error));
    }
  }

  /// Reloads when the date has moved on since the last load (e.g. the app
  /// was left open past midnight).
  Future<void> refreshIfDayChanged() async {
    final current = state;
    if (current is HabitsLoaded &&
        current.today == HabitDates.dateOnly(_now())) {
      return;
    }
    await load();
  }

  /// Marks today done for [habitId], or undoes it. Returns null when nothing
  /// changed: a toggle for it was already running, or the habit is gone (the
  /// list is reloaded then). [CheckIn.milestone] is set the first time a
  /// streak milestone is reached.
  Future<CheckIn?> toggleToday(String habitId) async {
    if (!_toggling.add(habitId)) return null;
    try {
      final checkIn = await _toggleHabitToday(habitId);
      await _refresh();
      return checkIn;
    } on HabitNotFoundException {
      await load();
      return null;
    } finally {
      _toggling.remove(habitId);
    }
  }

  Future<void> delete(String habitId) async {
    try {
      await _deleteHabit(habitId);
      await _refresh();
    } on HabitNotFoundException {
      await load();
    }
  }

  @override
  Future<void> close() {
    // Not awaited: nothing depends on it, and a broadcast subscription's
    // cancel future can belong to another zone (it never completes in
    // fake-async widget tests).
    unawaited(_changes.cancel());
    return super.close();
  }

  Future<void> _refresh() async => _emitLoaded(await _getHabits());

  /// One reload for a burst of changes (a reset fires one per habit).
  void _scheduleReload() {
    if (_reloadScheduled) return;
    _reloadScheduled = true;
    scheduleMicrotask(() {
      _reloadScheduled = false;
      if (!isClosed) load();
    });
  }

  void _emitLoaded(List<Habit> habits) {
    // Home can be disposed while a save is still running.
    if (isClosed) return;
    final today = HabitDates.dateOnly(_now());
    emit(
      HabitsLoaded(
        today: today,
        habits: [
          for (final habit in habits)
            HabitItem(
              habit: habit,
              currentStreak: _streaks.currentStreak(habit),
              isDoneToday: habit.isCompletedOn(today),
            ),
        ],
        overview: _overview.calculate(habits, days: overviewDays),
      ),
    );
  }
}
