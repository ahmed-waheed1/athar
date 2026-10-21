import 'package:equatable/equatable.dart';

import '../../domain/entities/habit.dart';
import '../../domain/services/habit_history.dart';

/// Which hero the Details screen shows (design/screens.md · 06 · States).
enum StreakStatus {
  /// A streak is running.
  active,

  /// No current streak, but there is history.
  broken,

  /// Never checked yet.
  fresh,
}

/// Stats derived from the habit's completed dates; never stored.
class HabitStats extends Equatable {
  const HabitStats({
    required this.currentStreak,
    required this.bestStreak,
    required this.completions,
    required this.consistencyPercent,
    required this.thisMonth,
  });

  final int currentStreak;
  final int bestStreak;
  final int completions;

  /// Null when there is no day to measure yet ("—").
  final int? consistencyPercent;
  final MonthProgress thisMonth;

  StreakStatus get status {
    if (completions == 0) return StreakStatus.fresh;
    return currentStreak == 0 ? StreakStatus.broken : StreakStatus.active;
  }

  @override
  List<Object?> get props => [
    currentStreak,
    bestStreak,
    completions,
    consistencyPercent,
    thisMonth,
  ];
}

sealed class HabitDetailsState extends Equatable {
  const HabitDetailsState();

  @override
  List<Object?> get props => [];
}

final class HabitDetailsLoading extends HabitDetailsState {
  const HabitDetailsLoading();
}

/// The habit no longer exists (deleted elsewhere, or a stale link).
final class HabitDetailsNotFound extends HabitDetailsState {
  const HabitDetailsNotFound();
}

final class HabitDetailsError extends HabitDetailsState {
  const HabitDetailsError(this.error);

  final Object error;

  @override
  List<Object?> get props => [error];
}

final class HabitDetailsLoaded extends HabitDetailsState {
  const HabitDetailsLoaded({
    required this.habit,
    required this.today,
    required this.stats,
    required this.month,
  });

  final Habit habit;
  final DateTime today;
  final HabitStats stats;

  /// First day of the month the calendar shows.
  final DateTime month;

  DateTime get firstMonth {
    final first = HabitHistory.firstDay(habit);
    return DateTime(first.year, first.month);
  }

  DateTime get currentMonth => DateTime(today.year, today.month);

  bool get canShowPreviousMonth => month.isAfter(firstMonth);
  bool get canShowNextMonth => month.isBefore(currentMonth);

  HabitDetailsLoaded copyWith({DateTime? month}) => HabitDetailsLoaded(
    habit: habit,
    today: today,
    stats: stats,
    month: month ?? this.month,
  );

  @override
  List<Object?> get props => [habit, today, stats, month];
}
