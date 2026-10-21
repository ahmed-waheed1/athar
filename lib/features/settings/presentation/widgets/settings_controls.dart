import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/athar_typography.dart';
import '../../../../core/widgets/athar_segmented_control.dart';
import '../../domain/entities/app_settings.dart';
import '../cubit/settings_cubit.dart';

/// English | العربية. Each language is labelled in its own script, whatever
/// the UI language. Switching changes locale, direction and digits at once.
class LanguageControl extends StatelessWidget {
  const LanguageControl({super.key});

  @override
  Widget build(BuildContext context) {
    final language = context.select((SettingsCubit c) => c.state.language);
    return AtharSegmentedControl<AppLanguage>(
      selected: language,
      onChanged: context.read<SettingsCubit>().changeLanguage,
      segments: [
        AtharSegment(
          value: AppLanguage.en,
          label: context.tr('settings.languageEnglish'),
          style: AtharTextStyles.latin,
        ),
        AtharSegment(
          value: AppLanguage.ar,
          label: context.tr('settings.languageArabic'),
          style: AtharTextStyles.arabic,
        ),
      ],
    );
  }
}

/// Light / Dark / System.
///
/// The labels use `context.tr`, not `context.tr('key')`: the String extension reads
/// a global and subscribes to nothing, and this widget depends on nothing
/// else that changes with the language (it is const and only selects the
/// theme mode), so it kept the old language's labels until the theme mode
/// changed. `context.tr` rebuilds it once the new translations are loaded.
class ThemeModeControl extends StatelessWidget {
  const ThemeModeControl({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.select((SettingsCubit c) => c.state.themeMode);
    return AtharSegmentedControl<AppThemeMode>(
      selected: themeMode,
      onChanged: context.read<SettingsCubit>().changeThemeMode,
      segments: [
        AtharSegment(
          value: AppThemeMode.light,
          label: context.tr('settings.themeLight'),
          iconName: 'theme_light',
        ),
        AtharSegment(
          value: AppThemeMode.dark,
          label: context.tr('settings.themeDark'),
          iconName: 'theme_dark',
        ),
        AtharSegment(
          value: AppThemeMode.system,
          label: context.tr('settings.themeSystem'),
          iconName: 'system',
        ),
      ],
    );
  }
}
