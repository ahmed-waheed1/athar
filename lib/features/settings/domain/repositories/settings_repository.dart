import '../entities/app_settings.dart';

abstract interface class SettingsRepository {
  AppSettings load();

  Future<void> saveLanguage(AppLanguage language);

  Future<void> saveThemeMode(AppThemeMode themeMode);

  Future<void> saveOnboardingDone(bool done);
}
