import 'package:equatable/equatable.dart';

enum AppLanguage { en, ar }

enum AppThemeMode { light, dark, system }

class AppSettings extends Equatable {
  const AppSettings({required this.language, required this.themeMode});

  /// Used before the user picks anything: Arabic on an Arabic device, otherwise English.
  factory AppSettings.defaultsFor(String deviceLanguageCode) => AppSettings(
    language: defaultLanguageFor(deviceLanguageCode),
    themeMode: AppThemeMode.system,
  );

  static AppLanguage defaultLanguageFor(String deviceLanguageCode) =>
      deviceLanguageCode == 'ar' ? AppLanguage.ar : AppLanguage.en;

  final AppLanguage language;
  final AppThemeMode themeMode;

  AppSettings copyWith({AppLanguage? language, AppThemeMode? themeMode}) =>
      AppSettings(
        language: language ?? this.language,
        themeMode: themeMode ?? this.themeMode,
      );

  @override
  List<Object> get props => [language, themeMode];
}
