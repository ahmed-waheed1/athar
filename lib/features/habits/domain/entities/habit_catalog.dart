/// The icon and color keys a habit can store. This is the single list used by
/// the pickers, sample data and rendering.
///
/// Icon keys match `assets/icons/habit/habit_<key>.svg`; color keys match the
/// habit accent ids in `AtharColors`. Tests keep both in sync.
abstract final class HabitCatalog {
  /// In icon-picker order.
  static const iconKeys = [
    'book',
    'drop',
    'walk',
    'journal',
    'moon',
    'chat',
    'leaf',
    'heart',
    'dumbbell',
    'sun',
    'sparkle',
    'cup',
    'apple',
    'bed',
    'music',
    'brush',
    'bike',
    'coin',
    'phoneoff',
    'clock',
  ];

  /// In color-picker order.
  static const colorKeys = [
    'indigo',
    'sky',
    'teal',
    'leaf',
    'amber',
    'coral',
    'rose',
    'plum',
  ];

  static const defaultIconKey = 'sparkle';
  static const defaultColorKey = 'indigo';

  /// Preselected on a new habit: the first icon and color in picker order
  /// (design/screens.md · 05, empty state).
  static const newHabitIconKey = 'book';
  static const newHabitColorKey = 'indigo';

  /// [key] if it is known, otherwise [defaultIconKey]. Stored keys may be
  /// stale or corrupt; never trust them to name an asset.
  static String iconOrDefault(String key) =>
      iconKeys.contains(key) ? key : defaultIconKey;

  static String colorOrDefault(String key) =>
      colorKeys.contains(key) ? key : defaultColorKey;
}
