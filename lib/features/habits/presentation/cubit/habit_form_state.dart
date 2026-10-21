import 'package:equatable/equatable.dart';

import '../../domain/entities/habit_catalog.dart';
import '../../domain/entities/habit_name.dart';
import '../../domain/entities/reminder_time.dart';

enum HabitFormMode { add, edit }

enum HabitFormStatus {
  /// Edit mode only: reading the habit.
  loading,
  editing,
  saving,
  saved,
  deleted,

  /// Edit mode only: the habit no longer exists.
  notFound,
}

/// What would be saved. Two forms with equal values have no changes between
/// them.
class HabitFormValues extends Equatable {
  const HabitFormValues({
    required this.name,
    required this.iconKey,
    required this.colorKey,
    this.reminderTime,
  });

  /// Normalized (trimmed).
  final String name;
  final String iconKey;
  final String colorKey;

  /// Null when the reminder is off.
  final ReminderTime? reminderTime;

  @override
  List<Object?> get props => [name, iconKey, colorKey, reminderTime];
}

class HabitFormState extends Equatable {
  const HabitFormState({
    required this.mode,
    this.status = HabitFormStatus.loading,
    this.name = '',
    this.iconKey = HabitCatalog.newHabitIconKey,
    this.colorKey = HabitCatalog.newHabitColorKey,
    this.reminderEnabled = false,
    this.reminderTime = defaultReminderTime,
    this.initial,
    this.currentStreak = 0,
    this.showErrors = false,
    this.rejectedSaves = 0,
    this.failedSaves = 0,
  });

  /// Offered when the reminder is first turned on (design: 7:00 PM).
  static const defaultReminderTime = ReminderTime(hour: 19, minute: 0);

  final HabitFormMode mode;
  final HabitFormStatus status;

  /// As typed; see [values] for what is saved.
  final String name;
  final String iconKey;
  final String colorKey;
  final bool reminderEnabled;

  /// Kept while the reminder is off so turning it back on restores it.
  final ReminderTime reminderTime;

  /// The values the form opened with; null while loading.
  final HabitFormValues? initial;

  /// Edit mode: the habit's current streak, for the preview card.
  final int currentStreak;

  /// Set by the first Save attempt; from then on an empty name is an error
  /// too, not only a name that is too long.
  final bool showErrors;

  /// Bumped each time Save is refused for an invalid name (the field shakes).
  final int rejectedSaves;

  /// Bumped each time saving throws.
  final int failedSaves;

  bool get isEdit => mode == HabitFormMode.edit;

  HabitFormValues get values => HabitFormValues(
    name: HabitName.normalize(name),
    iconKey: iconKey,
    colorKey: colorKey,
    reminderTime: reminderEnabled ? reminderTime : null,
  );

  int get nameLength => HabitName.length(name);

  /// The error to show under the name field, if any.
  HabitNameError? get nameError {
    final error = HabitName.validate(name);
    if (error == HabitNameError.empty && !showErrors) return null;
    return error;
  }

  bool get isDirty => initial != null && values != initial;

  /// Leaving now would lose something the user did.
  bool get hasUnsavedChanges =>
      isDirty &&
      (status == HabitFormStatus.editing || status == HabitFormStatus.saving);

  /// Save is enabled once there is something to save. An untouched new habit
  /// keeps it disabled; an invalid name still enables it so tapping it can
  /// explain what is wrong.
  bool get canSubmit =>
      status == HabitFormStatus.editing && (isDirty || nameLength > 0);

  HabitFormState copyWith({
    HabitFormStatus? status,
    String? name,
    String? iconKey,
    String? colorKey,
    bool? reminderEnabled,
    ReminderTime? reminderTime,
    HabitFormValues? initial,
    int? currentStreak,
    bool? showErrors,
    int? rejectedSaves,
    int? failedSaves,
  }) => HabitFormState(
    mode: mode,
    status: status ?? this.status,
    name: name ?? this.name,
    iconKey: iconKey ?? this.iconKey,
    colorKey: colorKey ?? this.colorKey,
    reminderEnabled: reminderEnabled ?? this.reminderEnabled,
    reminderTime: reminderTime ?? this.reminderTime,
    initial: initial ?? this.initial,
    currentStreak: currentStreak ?? this.currentStreak,
    showErrors: showErrors ?? this.showErrors,
    rejectedSaves: rejectedSaves ?? this.rejectedSaves,
    failedSaves: failedSaves ?? this.failedSaves,
  );

  @override
  List<Object?> get props => [
    mode,
    status,
    name,
    iconKey,
    colorKey,
    reminderEnabled,
    reminderTime,
    initial,
    currentStreak,
    showErrors,
    rejectedSaves,
    failedSaves,
  ];
}
