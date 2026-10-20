import 'package:shared_preferences/shared_preferences.dart';

/// Raw shared_preferences access for app settings. Values are stored as enum names.
class SettingsLocalDataSource {
  const SettingsLocalDataSource(this._prefs);

  static const languageKey = 'settings.language';
  static const themeModeKey = 'settings.themeMode';

  final SharedPreferences _prefs;

  String? readLanguage() => _prefs.getString(languageKey);

  String? readThemeMode() => _prefs.getString(themeModeKey);

  Future<void> writeLanguage(String value) =>
      _prefs.setString(languageKey, value);

  Future<void> writeThemeMode(String value) =>
      _prefs.setString(themeModeKey, value);
}
