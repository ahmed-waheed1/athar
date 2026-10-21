import 'package:shared_preferences/shared_preferences.dart';

/// Raw shared_preferences access for app settings. Enums are stored by name.
class SettingsLocalDataSource {
  const SettingsLocalDataSource(this._prefs);

  static const languageKey = 'settings.language';
  static const themeModeKey = 'settings.themeMode';
  static const onboardingDoneKey = 'settings.onboardingDone';

  final SharedPreferences _prefs;

  String? readLanguage() => _prefs.getString(languageKey);

  String? readThemeMode() => _prefs.getString(themeModeKey);

  bool? readOnboardingDone() => _prefs.getBool(onboardingDoneKey);

  Future<void> writeLanguage(String value) =>
      _prefs.setString(languageKey, value);

  Future<void> writeThemeMode(String value) =>
      _prefs.setString(themeModeKey, value);

  Future<void> writeOnboardingDone(bool value) =>
      _prefs.setBool(onboardingDoneKey, value);
}
