import 'dart:convert';
import 'dart:io';

import 'package:athar/core/theme/athar_typography.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/athar_token_styles.dart';

void main() {
  test('every style sets the token letter-spacing in both languages', () {
    final tokens = jsonDecode(
      File('design/design-tokens.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    final typography = tokens['typography'] as Map<String, dynamic>;
    for (final (script, styles) in [
      ('latin', AtharTextStyles.latin),
      ('ar', AtharTextStyles.arabic),
    ]) {
      final byToken = tokenStyles(styles);
      expect(byToken.keys.toSet(), typography.keys.toSet());
      for (final MapEntry(key: name, value: style) in byToken.entries) {
        final spacing =
            (typography[name] as Map<String, dynamic>)['letterSpacing']
                as Map<String, dynamic>;
        expect(
          style.letterSpacing,
          (spacing[script] as num?)?.toDouble() ?? 0,
          reason: '$script $name',
        );
        if (script == 'ar') expect(style.letterSpacing, 0, reason: name);
      }
    }
  });
}
