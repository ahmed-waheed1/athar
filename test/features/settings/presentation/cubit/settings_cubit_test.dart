import 'package:athar/features/settings/data/datasources/settings_local_data_source.dart';
import 'package:athar/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:athar/features/settings/domain/entities/app_settings.dart';
import 'package:athar/features/settings/domain/usecases/get_settings.dart';
import 'package:athar/features/settings/domain/usecases/set_language.dart';
import 'package:athar/features/settings/domain/usecases/set_theme_mode.dart';
import 'package:athar/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<SettingsCubit> buildCubit({String deviceLanguageCode = 'en'}) async {
  final prefs = await SharedPreferences.getInstance();
  final repository = SettingsRepositoryImpl(
    SettingsLocalDataSource(prefs),
    deviceLanguageCode: deviceLanguageCode,
  );
  return SettingsCubit(
    getSettings: GetSettings(repository),
    setLanguage: SetLanguage(repository),
    setThemeMode: SetThemeMode(repository),
  );
}

void main() {
  group('first launch (nothing saved)', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('uses Arabic on an Arabic device', () async {
      final cubit = await buildCubit(deviceLanguageCode: 'ar');
      expect(
        cubit.state,
        const AppSettings(
          language: AppLanguage.ar,
          themeMode: AppThemeMode.system,
        ),
      );
    });

    test('uses English on an English device', () async {
      final cubit = await buildCubit(deviceLanguageCode: 'en');
      expect(cubit.state.language, AppLanguage.en);
      expect(cubit.state.themeMode, AppThemeMode.system);
    });

    test('uses English on any other device language', () async {
      final cubit = await buildCubit(deviceLanguageCode: 'fr');
      expect(cubit.state.language, AppLanguage.en);
    });
  });

  test('saved language wins over the device language', () async {
    SharedPreferences.setMockInitialValues({
      SettingsLocalDataSource.languageKey: 'en',
      SettingsLocalDataSource.themeModeKey: 'dark',
    });
    final cubit = await buildCubit(deviceLanguageCode: 'ar');
    expect(
      cubit.state,
      const AppSettings(language: AppLanguage.en, themeMode: AppThemeMode.dark),
    );
  });

  test('falls back to device defaults for unknown stored values', () async {
    SharedPreferences.setMockInitialValues({
      SettingsLocalDataSource.languageKey: 'fr',
      SettingsLocalDataSource.themeModeKey: 'sepia',
    });
    final cubit = await buildCubit(deviceLanguageCode: 'ar');
    expect(cubit.state, AppSettings.defaultsFor('ar'));
  });

  test('changes are emitted and survive a restart', () async {
    SharedPreferences.setMockInitialValues({});
    final cubit = await buildCubit();

    await cubit.changeLanguage(AppLanguage.ar);
    await cubit.changeThemeMode(AppThemeMode.light);
    expect(cubit.state.language, AppLanguage.ar);
    expect(cubit.state.themeMode, AppThemeMode.light);

    final restarted = await buildCubit();
    expect(restarted.state, cubit.state);
  });
}
