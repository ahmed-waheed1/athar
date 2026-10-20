import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

/// Number formatting per UI locale. Arabic uses `ar_EG` so digits come out Arabic-Indic (٠١٢٣٤٥٦٧٨٩);
/// the plain `ar` locale gives Western digits.
abstract final class LocalizedNumbers {
  static String intlLocale(Locale locale) =>
      locale.languageCode == 'ar' ? 'ar_EG' : 'en_US';

  static String decimal(num value, Locale locale) =>
      NumberFormat.decimalPattern(intlLocale(locale)).format(value);

  /// [fraction] is 0..1, e.g. 0.82 -> "82%" / "٪٨٢".
  static String percent(double fraction, Locale locale) =>
      NumberFormat.percentPattern(intlLocale(locale)).format(fraction);
}
