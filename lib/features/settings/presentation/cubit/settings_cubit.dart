import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/app_settings.dart';
import '../../domain/usecases/get_settings.dart';
import '../../domain/usecases/set_language.dart';
import '../../domain/usecases/set_theme_mode.dart';

/// App-wide language and theme mode. Emits first, then persists, so the UI never waits on disk.
class SettingsCubit extends Cubit<AppSettings> {
  SettingsCubit({
    required GetSettings getSettings,
    required this._setLanguage,
    required this._setThemeMode,
  }) : super(getSettings());

  final SetLanguage _setLanguage;
  final SetThemeMode _setThemeMode;

  Future<void> changeLanguage(AppLanguage language) async {
    if (language == state.language) return;
    emit(state.copyWith(language: language));
    await _setLanguage(language);
  }

  Future<void> changeThemeMode(AppThemeMode themeMode) async {
    if (themeMode == state.themeMode) return;
    emit(state.copyWith(themeMode: themeMode));
    await _setThemeMode(themeMode);
  }
}
