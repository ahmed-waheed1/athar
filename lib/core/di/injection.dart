import 'dart:ui';

import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/habits/data/datasources/habit_local_data_source.dart';
import '../../features/habits/data/models/habit_model.dart';
import '../../features/habits/data/models/hive_registrar.g.dart';
import '../../features/habits/data/repositories/habit_repository_impl.dart';
import '../../features/habits/domain/repositories/habit_repository.dart';
import '../../features/habits/domain/services/habits_overview_calculator.dart';
import '../../features/habits/domain/services/streak_calculator.dart';
import '../../features/habits/domain/usecases/add_habit.dart';
import '../../features/habits/domain/usecases/delete_habit.dart';
import '../../features/habits/domain/usecases/get_habit.dart';
import '../../features/habits/domain/usecases/get_habits.dart';
import '../../features/habits/domain/usecases/toggle_habit_today.dart';
import '../../features/habits/domain/usecases/update_habit.dart';
import '../../features/habits/presentation/cubit/habit_form_cubit.dart';
import '../../features/habits/presentation/cubit/habits_cubit.dart';
import '../../features/settings/data/datasources/settings_local_data_source.dart';
import '../../features/settings/data/repositories/settings_repository_impl.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../../features/settings/domain/usecases/get_settings.dart';
import '../../features/settings/domain/usecases/set_language.dart';
import '../../features/settings/domain/usecases/set_theme_mode.dart';
import '../../features/settings/presentation/cubit/settings_cubit.dart';
import '../router/app_router.dart';

final sl = GetIt.instance;

/// Expects Hive to be initialized (Hive.initFlutter) before it runs.
Future<void> configureDependencies() async {
  final prefs = await SharedPreferences.getInstance();
  Hive.registerAdapters();
  final habitBox = await Hive.openBox<HabitModel>(HabitLocalDataSource.boxName);
  sl
    ..registerSingleton<SharedPreferences>(prefs)
    ..registerSingleton<Box<HabitModel>>(habitBox)
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
    // Habits
    ..registerLazySingleton(() => HabitLocalDataSource(sl()))
    ..registerLazySingleton<HabitRepository>(() => HabitRepositoryImpl(sl()))
    ..registerLazySingleton(() => GetHabits(sl()))
    ..registerLazySingleton(() => GetHabit(sl()))
    ..registerLazySingleton(() => AddHabit(sl()))
    ..registerLazySingleton(() => UpdateHabit(sl()))
    ..registerLazySingleton(() => DeleteHabit(sl()))
    ..registerLazySingleton(() => ToggleHabitToday(sl()))
    ..registerLazySingleton(StreakCalculator.new)
    ..registerLazySingleton(() => HabitsOverviewCalculator(sl()))
    ..registerFactory(
      () => HabitsCubit(
        getHabits: sl(),
        toggleHabitToday: sl(),
        deleteHabit: sl(),
        streakCalculator: sl(),
        overviewCalculator: sl(),
      ),
    )
    ..registerFactory(
      () => HabitFormCubit(
        addHabit: sl(),
        updateHabit: sl(),
        getHabit: sl(),
        deleteHabit: sl(),
        streakCalculator: sl(),
      ),
    )
    // Navigation
    ..registerLazySingleton<GoRouter>(createAppRouter);
}
