import 'package:equatable/equatable.dart';

/// A local time of day for a daily reminder.
class ReminderTime extends Equatable {
  const ReminderTime({required this.hour, required this.minute})
    : assert(hour >= 0 && hour < 24),
      assert(minute >= 0 && minute < 60);

  final int hour;
  final int minute;

  @override
  List<Object> get props => [hour, minute];
}
