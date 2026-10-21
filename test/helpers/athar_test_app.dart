import 'dart:io';

import 'package:athar/core/localization/app_locales.dart';
import 'package:athar/core/theme/athar_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Once per test file: translations, date symbols and the real Cairo font,
/// so text overflow shows up as a test failure.
Future<void> setUpAtharTestApp() async {
  SharedPreferences.setMockInitialValues({});
  await EasyLocalization.ensureInitialized();
  await initializeDateFormatting();
  final cairo = FontLoader('Cairo');
  for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
    final bytes = File('assets/fonts/Cairo/Cairo-$weight.ttf')
        .readAsBytesSync();
    cairo.addFont(Future.value(ByteData.sublistView(bytes)));
  }
  await cairo.load();
}

/// Pumps [router] inside the app's localization and theme at [size].
Future<void> pumpAtharRouterApp(
  WidgetTester tester, {
  required GoRouter router,
  required Locale locale,
  Brightness brightness = Brightness.light,
  Size size = const Size(375, 812),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.runAsync(() async {
    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: AppLocales.supported,
        path: AppLocales.translationsPath,
        fallbackLocale: AppLocales.fallback,
        startLocale: locale,
        saveLocale: false,
        useOnlyLangCode: true,
        ignorePluralRules: false,
        child: Builder(
          builder: (context) => MaterialApp.router(
            locale: context.locale,
            supportedLocales: context.supportedLocales,
            localizationsDelegates: context.localizationDelegates,
            theme: brightness == Brightness.light
                ? AtharTheme.light(context.locale)
                : AtharTheme.dark(context.locale),
            routerConfig: router,
          ),
        ),
      ),
    );
    // Let easy_localization read the JSON files.
    await Future<void>.delayed(const Duration(milliseconds: 200));
  });
  await tester.pumpAndSettle();
}
