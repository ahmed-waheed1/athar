import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_data_source.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  const SettingsRepositoryImpl(
    this._dataSource, {
    required this._deviceLanguageCode,
  });

  final SettingsLocalDataSource _dataSource;

  /// The device's preferred language, used until the user picks one.
  final String _deviceLanguageCode;

  @override
  AppSettings load() {
    final defaults = AppSettings.defaultsFor(_deviceLanguageCode);
    return AppSettings(
      language:
          AppLanguage.values.asNameMap()[_dataSource.readLanguage()] ??
          defaults.language,
      themeMode:
          AppThemeMode.values.asNameMap()[_dataSource.readThemeMode()] ??
          defaults.themeMode,
      onboardingDone: _dataSource.readOnboardingDone() ?? false,
    );
  }

  @override
  Future<void> saveLanguage(AppLanguage language) =>
      _dataSource.writeLanguage(language.name);

  @override
  Future<void> saveThemeMode(AppThemeMode themeMode) =>
      _dataSource.writeThemeMode(themeMode.name);

  @override
  Future<void> saveOnboardingDone(bool done) =>
      _dataSource.writeOnboardingDone(done);
}
