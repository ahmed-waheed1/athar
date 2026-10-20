import 'package:equatable/equatable.dart';

import '../../domain/entities/habit.dart';
import '../../domain/services/habits_overview_calculator.dart';

sealed class HabitsState extends Equatable {
  const HabitsState();

  @override
  List<Object?> get props => [];
}

final class HabitsLoading extends HabitsState {
  const HabitsLoading();
}

final class HabitsLoaded extends HabitsState {
  const HabitsLoaded({
    required this.today,
    required this.habits,
    required this.overview,
  });

  /// The day [habits] were evaluated for (local date, no time).
  final DateTime today;
  final List<HabitItem> habits;
  final HabitsOverview overview;

  TodayProgress get progress => TodayProgress(
    done: habits.where((h) => h.isDoneToday).length,
    total: habits.length,
  );

  @override
  List<Object?> get props => [today, habits, overview];
}

final class HabitsError extends HabitsState {
  const HabitsError(this.error);

  final Object error;

  @override
  List<Object?> get props => [error];
}

/// A habit with the values Home shows for it today.
class HabitItem extends Equatable {
  const HabitItem({
    required this.habit,
    required this.currentStreak,
    required this.isDoneToday,
  });

  final Habit habit;
  final int currentStreak;
  final bool isDoneToday;

  @override
  List<Object?> get props => [habit, currentStreak, isDoneToday];
}

class TodayProgress extends Equatable {
  const TodayProgress({required this.done, required this.total});

  final int done;
  final int total;

  int get remaining => total - done;

  /// 0..1; 0 when there are no habits.
  double get fraction => total == 0 ? 0 : done / total;

  bool get isAllDone => total > 0 && done == total;

  @override
  List<Object?> get props => [done, total];
}

/// What a check-in toggle did, for the toast.
class CheckInResult extends Equatable {
  const CheckInResult({
    required this.habit,
    required this.isDone,
    required this.currentStreak,
  });

  final Habit habit;

  /// True when today was marked done, false when it was undone.
  final bool isDone;
  final int currentStreak;

  @override
  List<Object?> get props => [habit, isDone, currentStreak];
}
