import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Keys of a translation file, with plural forms collapsed to their parent.
Set<String> keys(Map<String, dynamic> json, [String prefix = '']) {
  const pluralForms = {'zero', 'one', 'two', 'few', 'many', 'other'};
  final result = <String>{};
  for (final MapEntry(:key, :value) in json.entries) {
    final path = prefix.isEmpty ? key : '$prefix.$key';
    if (value is Map<String, dynamic>) {
      if (value.keys.every(pluralForms.contains)) {
        result.add(path);
      } else {
        result.addAll(keys(value, path));
      }
    } else {
      result.add(path);
    }
  }
  return result;
}

Map<String, dynamic> load(String code) =>
    jsonDecode(File('assets/translations/$code.json').readAsStringSync())
        as Map<String, dynamic>;

void main() {
  test('en.json and ar.json have the same keys', () {
    expect(keys(load('ar')), keys(load('en')));
  });

  test('Arabic "day" has every plural form from screens.md', () {
    final days = (load('ar')['plural'] as Map)['days'] as Map;
    expect(days, {
      'zero': '{} يوم',
      'one': 'يوم واحد',
      'two': 'يومان',
      'few': '{} أيام',
      'many': '{} يومًا',
      'other': '{} يوم',
    });
  });

  test('every plural has an other form', () {
    void check(Map<String, dynamic> json, String code) {
      for (final value in json.values) {
        if (value is! Map<String, dynamic>) continue;
        if (value.containsKey('one')) {
          expect(value, contains('other'), reason: '$code: $value');
        } else {
          check(value, code);
        }
      }
    }

    check(load('en'), 'en');
    check(load('ar'), 'ar');
  });
}
