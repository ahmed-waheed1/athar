import 'package:athar/features/settings/domain/entities/app_settings.dart';
import 'package:athar/features/settings/domain/repositories/settings_repository.dart';
import 'package:athar/features/settings/domain/usecases/get_settings.dart';
import 'package:athar/features/settings/domain/usecases/set_language.dart';
import 'package:athar/features/settings/domain/usecases/set_onboarding_done.dart';
import 'package:athar/features/settings/domain/usecases/set_theme_mode.dart';
import 'package:athar/features/settings/presentation/cubit/settings_cubit.dart';

/// Settings kept in memory. [settings] is what was last saved.
class InMemorySettingsRepository implements SettingsRepository {
  InMemorySettingsRepository([
    this.settings = const AppSettings(
      language: AppLanguage.en,
      themeMode: AppThemeMode.light,
      onboardingDone: true,
    ),
  ]);

  AppSettings settings;

  @override
  AppSettings load() => settings;

  @override
  Future<void> saveLanguage(AppLanguage language) async =>
      settings = settings.copyWith(language: language);

  @override
  Future<void> saveThemeMode(AppThemeMode themeMode) async =>
      settings = settings.copyWith(themeMode: themeMode);

  @override
  Future<void> saveOnboardingDone(bool done) async =>
      settings = settings.copyWith(onboardingDone: done);
}

/// A SettingsCubit over [repository] (by default: English, light, onboarding done).
SettingsCubit buildSettingsCubit([SettingsRepository? repository]) {
  final repo = repository ?? InMemorySettingsRepository();
  return SettingsCubit(
    getSettings: GetSettings(repo),
    setLanguage: SetLanguage(repo),
    setThemeMode: SetThemeMode(repo),
    setOnboardingDone: SetOnboardingDone(repo),
  );
}
