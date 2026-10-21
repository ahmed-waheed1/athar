import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../habits/domain/usecases/delete_all_habits.dart';
import '../../../habits/domain/usecases/get_habits.dart';

enum ResetDataStatus { idle, resetting, done, failure }

/// What Reset all data would remove, for the confirmation dialog.
class StoredDataSummary extends Equatable {
  const StoredDataSummary({required this.habits, required this.traces});

  final int habits;

  /// Every completed day across all habits.
  final int traces;

  @override
  List<Object> get props => [habits, traces];
}

/// Settings · Your data: Reset all data. Deletes every habit with its history
/// and celebrated milestones; language and theme are kept.
class ResetDataCubit extends Cubit<ResetDataStatus> {
  ResetDataCubit({required this._getHabits, required this._deleteAllHabits})
    : super(ResetDataStatus.idle);

  final GetHabits _getHabits;
  final DeleteAllHabits _deleteAllHabits;

  /// Null when the habits couldn't be read.
  Future<StoredDataSummary?> summary() async {
    try {
      final habits = await _getHabits();
      return StoredDataSummary(
        habits: habits.length,
        traces: habits.fold(0, (sum, h) => sum + h.completedDates.length),
      );
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      return null;
    }
  }

  Future<void> reset() async {
    if (state == ResetDataStatus.resetting) return;
    emit(ResetDataStatus.resetting);
    try {
      await _deleteAllHabits();
      if (!isClosed) emit(ResetDataStatus.done);
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      if (!isClosed) emit(ResetDataStatus.failure);
    }
  }
}
