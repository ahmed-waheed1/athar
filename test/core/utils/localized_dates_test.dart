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
}
