import 'package:athar/core/localization/app_locales.dart';
import 'package:athar/core/utils/localized_numbers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Arabic uses Arabic-Indic digits', () {
    expect(LocalizedNumbers.decimal(21, AppLocales.ar), '٢١');
    expect(LocalizedNumbers.decimal(1234567, AppLocales.ar), contains('١'));
    expect(LocalizedNumbers.percent(0.82, AppLocales.ar), contains('٨٢'));
  });

  test('English uses Western digits', () {
    expect(LocalizedNumbers.decimal(1234567, AppLocales.en), '1,234,567');
    expect(LocalizedNumbers.percent(0.82, AppLocales.en), '82%');
  });
}
