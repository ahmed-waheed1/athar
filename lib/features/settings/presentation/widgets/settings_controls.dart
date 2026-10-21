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
          label: 'settings.languageEnglish'.tr(),
          style: AtharTextStyles.latin,
        ),
        AtharSegment(
          value: AppLanguage.ar,
          label: 'settings.languageArabic'.tr(),
          style: AtharTextStyles.arabic,
        ),
      ],
    );
  }
}

/// Light / Dark / System.
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
          label: 'settings.themeLight'.tr(),
          iconName: 'theme_light',
        ),
        AtharSegment(
          value: AppThemeMode.dark,
          label: 'settings.themeDark'.tr(),
          iconName: 'theme_dark',
        ),
        AtharSegment(
          value: AppThemeMode.system,
          label: 'settings.themeSystem'.tr(),
          iconName: 'system',
        ),
      ],
    );
  }
}
