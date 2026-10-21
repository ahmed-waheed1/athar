import '../entities/check_in.dart';
import '../repositories/habit_repository.dart';
import '../services/streak_calculator.dart';
import '../services/streak_milestones.dart';

/// Marks today done for a habit, or undoes it, and saves it.
///
/// A check-in that lands on a streak milestone the habit has never celebrated
/// records it in the same save and reports it in [CheckIn.milestone], so
/// unchecking and checking again never celebrates twice.
class ToggleHabitToday {
  ToggleHabitToday(this._repository, this._streaks, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final HabitRepository _repository;
  final StreakCalculator _streaks;
  final DateTime Function() _now;

  Future<CheckIn> call(String habitId) async {
    final habit = await _repository.getHabit(habitId);
    if (habit == null) throw HabitNotFoundException(habitId);
    final today = _now();
    var updated = habit.toggleCompletion(today);
    final isDone = updated.isCompletedOn(today);
    final streak = _streaks.currentStreak(updated);

    int? milestone;
    if (isDone &&
        StreakMilestones.isMilestone(streak) &&
        !updated.celebratedMilestones.contains(streak)) {
      milestone = streak;
      updated = updated.markMilestoneCelebrated(streak);
    }

    await _repository.updateHabit(updated);
    return CheckIn(
      habit: updated,
      isDone: isDone,
      currentStreak: streak,
      milestone: milestone,
    );
  }
}
