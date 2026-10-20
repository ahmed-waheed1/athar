/// Helpers for the calendar days habits are tracked on.
///
/// A habit day is a local date with no time: `DateTime(y, m, d)`. It is
/// persisted as a `yyyy-MM-dd` key.
abstract final class HabitDates {
  static DateTime dateOnly(DateTime dateTime) =>
      DateTime(dateTime.year, dateTime.month, dateTime.day);

  /// Adds whole calendar days. Safe across DST changes, unlike adding a
  /// [Duration] of 24 hours.
  static DateTime addDays(DateTime day, int days) =>
      DateTime(day.year, day.month, day.day + days);

  /// Number of calendar days from [from] to [to], ignoring time of day.
  static int daysBetween(DateTime from, DateTime to) => DateTime.utc(
    to.year,
    to.month,
    to.day,
  ).difference(DateTime.utc(from.year, from.month, from.day)).inDays;

  static String toKey(DateTime day) {
    final y = day.year.toString().padLeft(4, '0');
    final m = day.month.toString().padLeft(2, '0');
    final d = day.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  static DateTime fromKey(String key) {
    final parts = key.split('-');
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }
}
