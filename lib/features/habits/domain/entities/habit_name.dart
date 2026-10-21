import 'package:characters/characters.dart';

enum HabitNameError { empty, tooLong }

/// Rules for a habit's name (design/screens.md · 05).
abstract final class HabitName {
  /// Most characters a name may have, counted as graphemes so an emoji or a
  /// letter with diacritics (تعلّم) counts once.
  static const maxLength = 40;

  /// The name as stored: surrounding whitespace removed.
  static String normalize(String input) => input.trim();

  /// Graphemes in the normalized name.
  static int length(String input) => normalize(input).characters.length;

  static HabitNameError? validate(String input) {
    final length = HabitName.length(input);
    if (length == 0) return HabitNameError.empty;
    if (length > maxLength) return HabitNameError.tooLong;
    return null;
  }
}
