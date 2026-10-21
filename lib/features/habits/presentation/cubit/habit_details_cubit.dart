import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/habit.dart';
import '../../domain/services/habit_history.dart';
import '../../domain/services/streak_calculator.dart';
import '../../domain/usecases/get_habit.dart';
import '../../domain/utils/habit_dates.dart';
import 'habit_details_state.dart';

/// One habit with its stats for Habit Details, and the month its calendar
/// shows. Read-only: checking in happens on Home.
class HabitDetailsCubit extends Cubit<HabitDetailsState> {
  HabitDetailsCubit({
    required this._getHabit,
    required StreakCalculator streakCalculator,
    DateTime Function()? now,
  }) : _streaks = streakCalculator,
       _now = now ?? DateTime.now,
       super(const HabitDetailsLoading());

  final GetHabit _getHabit;
  final StreakCalculator _streaks;
  final DateTime Function() _now;

  String? _habitId;

  /// Loads [habitId]. Reloading the same habit keeps the calendar on the
  /// month it shows, if that month is still in range.
  Future<void> load(String habitId) async {
    final previous = state;
    final keepMonth =
        previous is HabitDetailsLoaded && previous.habit.id == habitId
        ? previous.month
        : null;
    _habitId = habitId;
    // Reloading the same habit keeps it on screen until the new data lands.
    if (keepMonth == null) emit(const HabitDetailsLoading());
    try {
      final habit = await _getHabit(habitId);
      // A newer load for another habit has started, or the screen closed.
      if (isClosed || _habitId != habitId) return;
      if (habit == null) {
        emit(const HabitDetailsNotFound());
        return;
      }
      emit(_loaded(habit, keepMonth));
    } catch (error, stackTrace) {
      if (isClosed || _habitId != habitId) return;
      addError(error, stackTrace);
      emit(HabitDetailsError(error));
    }
  }

  /// Loads the current habit again, e.g. after it was edited.
  Future<void> reload() async {
    final id = _habitId;
    if (id != null) await load(id);
  }

  void showPreviousMonth() {
    final current = state;
    if (current is! HabitDetailsLoaded || !current.canShowPreviousMonth) {
      return;
    }
    final month = current.month;
    emit(current.copyWith(month: DateTime(month.year, month.month - 1)));
  }

  void showNextMonth() {
    final current = state;
    if (current is! HabitDetailsLoaded || !current.canShowNextMonth) return;
    final month = current.month;
    emit(current.copyWith(month: DateTime(month.year, month.month + 1)));
  }

  HabitDetailsLoaded _loaded(Habit habit, DateTime? month) {
    final today = HabitDates.dateOnly(_now());
    final loaded = HabitDetailsLoaded(
      habit: habit,
      today: today,
      stats: HabitStats(
        currentStreak: _streaks.currentStreak(habit),
        bestStreak: _streaks.bestStreak(habit),
        completions: _streaks.totalCompletions(habit),
        consistencyPercent: _streaks.consistencyPercent(habit),
        thisMonth: HabitHistory.monthProgress(habit, today: today),
      ),
      month: DateTime(today.year, today.month),
    );
    if (month == null ||
        month.isBefore(loaded.firstMonth) ||
        month.isAfter(loaded.currentMonth)) {
      return loaded;
    }
    return loaded.copyWith(month: month);
  }
}
