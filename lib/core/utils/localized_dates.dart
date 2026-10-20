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

  /// [DateTime.saturday] in Arabic, [DateTime.sunday] in English.
  static int firstDayOfWeek(Locale locale) =>
      locale.languageCode == 'ar' ? DateTime.saturday : DateTime.sunday;
}
