import 'package:equatable/equatable.dart';

import 'habit.dart';

/// What checking today in or undoing it did.
class CheckIn extends Equatable {
  const CheckIn({
    required this.habit,
    required this.isDone,
    required this.currentStreak,
    this.milestone,
  });

  /// The habit as saved.
  final Habit habit;

  /// True when today was marked done, false when it was undone.
  final bool isDone;
  final int currentStreak;

  /// The streak milestone this check-in reached for the first time, which
  /// gets the celebration instead of the toast. Null otherwise.
  final int? milestone;

  @override
  List<Object?> get props => [habit, isDone, currentStreak, milestone];
}
