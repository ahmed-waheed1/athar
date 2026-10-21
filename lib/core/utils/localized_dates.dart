import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import 'localized_numbers.dart';

/// Date formatting per UI locale. Needs `initializeDateFormatting()` from
/// `package:intl/date_symbol_data_local.dart` once at startup.
abstract final class LocalizedDates {
  /// "Tuesday, 20 October" / "الثلاثاء، ٢٠ أكتوبر".
  static String weekdayDayMonth(DateTime date, Locale locale) {
    final pattern = locale.languageCode == 'ar'
        ? 'EEEE، d MMMM'
        : 'EEEE, d MMMM';
    return DateFormat(
      pattern,
      LocalizedNumbers.intlLocale(locale),
    ).format(date);
  }

  /// A time of day: "7:00 PM" / "٧:٠٠ م".
  static String time(int hour, int minute, Locale locale) =>
      DateFormat.jm(LocalizedNumbers.intlLocale(locale))
          .format(DateTime(2000, 1, 1, hour, minute));

  /// The AM or PM marker: "AM" / "ص", "PM" / "م".
  static String dayPeriod({required bool pm, required Locale locale}) =>
      DateFormat(
        'a',
        LocalizedNumbers.intlLocale(locale),
      ).format(DateTime(2000, 1, 1, pm ? 12 : 0));

  /// "October 2026" / "أكتوبر ٢٠٢٦".
  static String monthYear(DateTime month, Locale locale) =>
      DateFormat.yMMMM(LocalizedNumbers.intlLocale(locale)).format(month);

  /// "October 20, 2026" / "٢٠ أكتوبر ٢٠٢٦".
  static String fullDate(DateTime date, Locale locale) =>
      DateFormat.yMMMMd(LocalizedNumbers.intlLocale(locale)).format(date);

  /// Calendar weekday headers from [firstDayOfWeek]: "Sun" … "Sat" in
  /// English, single letters "س" … "ج" in Arabic.
  static List<String> weekdayHeaders(Locale locale) {
    final format = DateFormat(
      locale.languageCode == 'ar' ? 'EEEEE' : 'E',
      LocalizedNumbers.intlLocale(locale),
    );
    // 2 January 2000 was a Sunday.
    final sunday = DateTime(2000, 1, 2);
    final offset = firstDayOfWeek(locale) % DateTime.daysPerWeek;
    return [
      for (var i = 0; i < DateTime.daysPerWeek; i++)
        format.format(
          DateTime(sunday.year, sunday.month, sunday.day + offset + i),
        ),
    ];
  }

  /// [DateTime.saturday] in Arabic, [DateTime.sunday] in English.
  static int firstDayOfWeek(Locale locale) =>
      locale.languageCode == 'ar' ? DateTime.saturday : DateTime.sunday;
}
