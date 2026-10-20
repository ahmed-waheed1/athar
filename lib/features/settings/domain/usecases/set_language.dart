import '../entities/app_settings.dart';
import '../repositories/settings_repository.dart';

class SetLanguage {
  const SetLanguage(this._repository);

  final SettingsRepository _repository;

  Future<void> call(AppLanguage language) => _repository.saveLanguage(language);
}
