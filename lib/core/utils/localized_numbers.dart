import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

/// Number formatting per UI locale. Arabic uses `ar_EG` so digits come out Arabic-Indic (٠١٢٣٤٥٦٧٨٩);
/// the plain `ar` locale gives Western digits.
abstract final class LocalizedNumbers {
  static String intlLocale(Locale locale) =>
      locale.languageCode == 'ar' ? 'ar_EG' : 'en_US';

  static NumberFormat formatter(Locale locale) =>
      NumberFormat.decimalPattern(intlLocale(locale));

  static String decimal(num value, Locale locale) =>
      formatter(locale).format(value);

  /// [fraction] is 0..1, e.g. 0.82 -> "82%" / "٪٨٢".
  static String percent(double fraction, Locale locale) =>
      NumberFormat.percentPattern(intlLocale(locale)).format(fraction);

  /// Rewrites the Western digits in [text] for [locale], e.g. a version
  /// "1.0.2" -> "١.٠.٢" in Arabic. Other characters are kept.
  static String digits(String text, Locale locale) {
    if (locale.languageCode != 'ar') return text;
    const arabicIndic = '٠١٢٣٤٥٦٧٨٩';
    return text.replaceAllMapped(
      RegExp('[0-9]'),
      (m) => arabicIndic[int.parse(m[0]!)],
    );
  }
}
