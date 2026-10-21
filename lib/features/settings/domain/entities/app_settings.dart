import 'package:equatable/equatable.dart';

enum AppLanguage { en, ar }

enum AppThemeMode { light, dark, system }

class AppSettings extends Equatable {
  const AppSettings({
    required this.language,
    required this.themeMode,
    this.onboardingDone = false,
  });

  /// Used before the user picks anything: Arabic on an Arabic device, otherwise English.
  factory AppSettings.defaultsFor(String deviceLanguageCode) => AppSettings(
    language: defaultLanguageFor(deviceLanguageCode),
    themeMode: AppThemeMode.system,
  );

  static AppLanguage defaultLanguageFor(String deviceLanguageCode) =>
      deviceLanguageCode == 'ar' ? AppLanguage.ar : AppLanguage.en;

  final AppLanguage language;
  final AppThemeMode themeMode;

  /// False until onboarding is finished or skipped; the router shows onboarding until then.
  final bool onboardingDone;

  AppSettings copyWith({
    AppLanguage? language,
    AppThemeMode? themeMode,
    bool? onboardingDone,
  }) => AppSettings(
    language: language ?? this.language,
    themeMode: themeMode ?? this.themeMode,
    onboardingDone: onboardingDone ?? this.onboardingDone,
  );

  @override
  List<Object> get props => [language, themeMode, onboardingDone];
}
