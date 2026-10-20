import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import 'app.dart';
import 'core/di/injection.dart';
import 'core/localization/app_locales.dart';
import 'features/settings/presentation/cubit/settings_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Hive.initFlutter();
  await configureDependencies();

  runApp(
    EasyLocalization(
      supportedLocales: AppLocales.supported,
      path: AppLocales.translationsPath,
      fallbackLocale: AppLocales.fallback,
      startLocale: sl<SettingsCubit>().state.language.locale,
      // The language lives in SettingsCubit; don't keep a second copy in easy_localization.
      saveLocale: false,
      useOnlyLangCode: true,
      child: const AtharApp(),
    ),
  );
}
