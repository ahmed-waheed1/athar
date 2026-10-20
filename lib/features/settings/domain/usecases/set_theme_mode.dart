import '../entities/app_settings.dart';
import '../repositories/settings_repository.dart';

class SetThemeMode {
  const SetThemeMode(this._repository);

  final SettingsRepository _repository;

  Future<void> call(AppThemeMode themeMode) =>
      _repository.saveThemeMode(themeMode);
}
