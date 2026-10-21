import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'core/di/injection.dart';
import 'core/localization/app_locales.dart';
import 'core/notifications/notification_permission_cubit.dart';
import 'core/router/app_router.dart';
import 'core/services/notification_service.dart';
import 'features/habits/data/services/habit_reminder_scheduler.dart';
import 'features/settings/presentation/cubit/settings_cubit.dart';

Future<void> main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  // Keep the native splash until SplashScreen has laid out (it removes it),
  // so translations loading never shows as a blank frame in between.
  FlutterNativeSplash.preserve(widgetsBinding: binding);
  await EasyLocalization.ensureInitialized();
  // Date names for ar_EG / en_US (see LocalizedDates).
  await initializeDateFormatting();
  await Hive.initFlutter();
  await configureDependencies();
  await _startReminders();

  runApp(
    EasyLocalization(
      supportedLocales: AppLocales.supported,
      path: AppLocales.translationsPath,
      fallbackLocale: AppLocales.fallback,
      startLocale: sl<SettingsCubit>().state.language.locale,
      // The language lives in SettingsCubit; don't keep a second copy in easy_localization.
      saveLocale: false,
      useOnlyLangCode: true,
      // The default (true) only knows zero/one/two/other; Arabic needs the
      // CLDR few and many forms (٣ أيام, ١١ يومًا).
      ignorePluralRules: false,
      child: const AtharApp(),
    ),
  );
}

/// Notifications and the daily reminders. A failure here is reported but
/// never stops the app from starting.
Future<void> _startReminders() async {
  try {
    await sl<NotificationService>().initialize(
      // Tapping a reminder opens Home (a cold start gets there via splash).
      onOpened: () => sl<GoRouter>().go(AppRoutes.home),
    );
  } catch (error, stackTrace) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'notifications',
        context: ErrorDescription('initializing notifications'),
      ),
    );
    return;
  }
  // Not awaited: the first sync and permission read don't hold up launch.
  unawaited(sl<NotificationPermissionCubit>().refresh());
  unawaited(sl<HabitReminderScheduler>().start());
}
