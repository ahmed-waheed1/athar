import 'package:athar/core/utils/localized_dates.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(initializeDateFormatting);

  final date = DateTime(2026, 10, 20);

  test('English header date', () {
    expect(
      LocalizedDates.weekdayDayMonth(date, const Locale('en', 'US')),
      'Tuesday, 20 October',
    );
  });

  test('Arabic header date uses Arabic-Indic digits', () {
    expect(
      LocalizedDates.weekdayDayMonth(date, const Locale('ar')),
      'الثلاثاء، ٢٠ أكتوبر',
    );
  });

  test('week starts Saturday in Arabic, Sunday in English', () {
    expect(
      LocalizedDates.firstDayOfWeek(const Locale('ar')),
      DateTime.saturday,
    );
    expect(
      LocalizedDates.firstDayOfWeek(const Locale('en', 'US')),
      DateTime.sunday,
    );
  });

  test('times use the locale digits and day period', () {
    const en = Locale('en', 'US');
    const ar = Locale('ar');
    // intl may separate the period with a narrow no-break space.
    String plain(String s) => s.replaceAll('\u202F', ' ');
    expect(plain(LocalizedDates.time(19, 0, en)), '7:00 PM');
    expect(plain(LocalizedDates.time(8, 30, en)), '8:30 AM');
    expect(plain(LocalizedDates.time(19, 0, ar)), '٧:٠٠ م');
    expect(plain(LocalizedDates.time(0, 5, ar)), '١٢:٠٥ ص');
    expect(LocalizedDates.dayPeriod(pm: false, locale: ar), 'ص');
    expect(LocalizedDates.dayPeriod(pm: true, locale: ar), 'م');
    expect(LocalizedDates.dayPeriod(pm: true, locale: en), 'PM');
  });
}
