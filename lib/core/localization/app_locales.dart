import 'package:flutter/material.dart';

import '../../features/settings/domain/entities/app_settings.dart';

abstract final class AppLocales {
  static const en = Locale('en', 'US');
  static const ar = Locale('ar');

  static const supported = [en, ar];
  static const fallback = en;

  /// Translation JSON files are named by language code only (en.json, ar.json).
  static const translationsPath = 'assets/translations';
}

extension AppLanguageLocale on AppLanguage {
  Locale get locale => switch (this) {
    AppLanguage.en => AppLocales.en,
    AppLanguage.ar => AppLocales.ar,
  };
}

extension AppThemeModeMaterial on AppThemeMode {
  ThemeMode get themeMode => switch (this) {
    AppThemeMode.light => ThemeMode.light,
    AppThemeMode.dark => ThemeMode.dark,
    AppThemeMode.system => ThemeMode.system,
  };
}
