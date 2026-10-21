import '../repositories/settings_repository.dart';

class SetOnboardingDone {
  const SetOnboardingDone(this._repository);

  final SettingsRepository _repository;

  Future<void> call(bool done) => _repository.saveOnboardingDone(done);
}
