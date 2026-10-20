import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/habit.dart';
import '../../domain/repositories/habit_repository.dart';
import '../../domain/services/habits_overview_calculator.dart';
import '../../domain/services/streak_calculator.dart';
import '../../domain/usecases/delete_habit.dart';
import '../../domain/usecases/get_habits.dart';
import '../../domain/usecases/toggle_habit_today.dart';
import '../../domain/utils/habit_dates.dart';
import 'habits_state.dart';

/// Today's habits for Home: load, check in / undo, delete.
class HabitsCubit extends Cubit<HabitsState> {
  HabitsCubit({
    required this._getHabits,
    required this._toggleHabitToday,
    required this._deleteHabit,
    required StreakCalculator streakCalculator,
    required HabitsOverviewCalculator overviewCalculator,
    DateTime Function()? now,
  }) : _streaks = streakCalculator,
       _overview = overviewCalculator,
       _now = now ?? DateTime.now,
       super(const HabitsLoading());

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
  /// list is reloaded then).
  Future<CheckInResult?> toggleToday(String habitId) async {
    if (!_toggling.add(habitId)) return null;
    try {
      final updated = await _toggleHabitToday(habitId);
      await _refresh();
      return CheckInResult(
        habit: updated,
        isDone: updated.isCompletedOn(_now()),
        currentStreak: _streaks.currentStreak(updated),
      );
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

  Future<void> _refresh() async => _emitLoaded(await _getHabits());

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
