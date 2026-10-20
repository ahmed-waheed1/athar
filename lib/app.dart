import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'core/di/injection.dart';
import 'core/localization/app_locales.dart';
import 'core/theme/athar_theme.dart';
import 'features/settings/domain/entities/app_settings.dart';
import 'features/settings/presentation/cubit/settings_cubit.dart';

class AtharApp extends StatelessWidget {
  const AtharApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SettingsCubit>.value(
      value: sl<SettingsCubit>(),
      // EasyLocalization owns the active locale; keep it in step with the saved language.
      child: BlocListener<SettingsCubit, AppSettings>(
        listenWhen: (prev, next) => prev.language != next.language,
        listener: (context, settings) =>
            context.setLocale(settings.language.locale),
        child: BlocBuilder<SettingsCubit, AppSettings>(
          buildWhen: (prev, next) => prev.themeMode != next.themeMode,
          builder: (context, settings) => MaterialApp.router(
            onGenerateTitle: (context) => 'app.name'.tr(),
            debugShowCheckedModeBanner: false,
            theme: AtharTheme.light(context.locale),
            darkTheme: AtharTheme.dark(context.locale),
            themeMode: settings.themeMode.themeMode,
            locale: context.locale,
            supportedLocales: context.supportedLocales,
            localizationsDelegates: context.localizationDelegates,
            routerConfig: sl<GoRouter>(),
          ),
        ),
      ),
    );
  }
}
