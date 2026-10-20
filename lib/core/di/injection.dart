import 'dart:ui';

import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/settings/data/datasources/settings_local_data_source.dart';
import '../../features/settings/data/repositories/settings_repository_impl.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../../features/settings/domain/usecases/get_settings.dart';
import '../../features/settings/domain/usecases/set_language.dart';
import '../../features/settings/domain/usecases/set_theme_mode.dart';
import '../../features/settings/presentation/cubit/settings_cubit.dart';
import '../router/app_router.dart';

final sl = GetIt.instance;

Future<void> configureDependencies() async {
  final prefs = await SharedPreferences.getInstance();
  sl
    ..registerSingleton<SharedPreferences>(prefs)
    // Settings
    ..registerLazySingleton(() => SettingsLocalDataSource(sl()))
    ..registerLazySingleton<SettingsRepository>(
      () => SettingsRepositoryImpl(
        sl(),
        deviceLanguageCode: PlatformDispatcher.instance.locale.languageCode,
      ),
    )
    ..registerLazySingleton(() => GetSettings(sl()))
    ..registerLazySingleton(() => SetLanguage(sl()))
    ..registerLazySingleton(() => SetThemeMode(sl()))
    ..registerLazySingleton(
      () => SettingsCubit(
        getSettings: sl(),
        setLanguage: sl(),
        setThemeMode: sl(),
      ),
    )
    // Navigation
    ..registerLazySingleton<GoRouter>(createAppRouter);
}
