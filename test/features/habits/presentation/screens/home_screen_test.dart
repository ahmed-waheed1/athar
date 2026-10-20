import 'dart:io';

import 'package:athar/core/debug/sample_habits.dart';
import 'package:athar/core/localization/app_locales.dart';
import 'package:athar/core/theme/athar_theme.dart';
import 'package:athar/features/habits/domain/services/habits_overview_calculator.dart';
import 'package:athar/features/habits/domain/services/streak_calculator.dart';
import 'package:athar/features/habits/domain/usecases/delete_habit.dart';
import 'package:athar/features/habits/domain/usecases/get_habits.dart';
import 'package:athar/features/habits/domain/usecases/toggle_habit_today.dart';
import 'package:athar/features/habits/presentation/cubit/habits_cubit.dart';
import 'package:athar/features/habits/presentation/screens/home_screen.dart';
import 'package:athar/features/habits/presentation/widgets/check_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../helpers/in_memory_habit_repository.dart';

/// Renders Home with the real Cairo font so text overflow shows up as a test
/// failure, in every layout, language and theme.
void main() {
  setUpAll(() async {
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
  });

  Future<HabitsCubit> buildCubit({required bool withHabits}) async {
    final repository = InMemoryHabitRepository();
    final streaks = StreakCalculator();
    if (withHabits) {
      final names = {
        'debug.samplePray': 'Pray on time',
        'debug.sampleWater': 'Drink water',
        'debug.sampleRead': 'Read 10 pages',
        'debug.sampleWalk': 'Morning walk',
        'debug.sampleEnglish': 'Learn English',
      };
      for (final habit in buildSampleHabits(
        now: DateTime.now(),
        name: (key) => names[key]!,
      )) {
        await repository.addHabit(habit);
      }
    }
    final cubit = HabitsCubit(
      getHabits: GetHabits(repository),
      toggleHabitToday: ToggleHabitToday(repository),
      deleteHabit: DeleteHabit(repository),
      streakCalculator: streaks,
      overviewCalculator: HabitsOverviewCalculator(streaks),
    );
    await cubit.load();
    return cubit;
  }

  Future<void> pumpHome(
    WidgetTester tester, {
    required Size size,
    required Locale locale,
    required Brightness brightness,
    required HabitsCubit cubit,
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
            builder: (context) => MaterialApp(
              locale: context.locale,
              supportedLocales: context.supportedLocales,
              localizationsDelegates: context.localizationDelegates,
              theme: brightness == Brightness.light
                  ? AtharTheme.light(context.locale)
                  : AtharTheme.dark(context.locale),
              home: Scaffold(
                body: BlocProvider.value(
                  value: cubit,
                  child: const HomeScreen(),
                ),
              ),
            ),
          ),
        ),
      );
      // Let easy_localization read the JSON files.
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pumpAndSettle();
  }

  const sizes = {
    'phone': Size(375, 812),
    'tablet': Size(768, 1024),
    'wide': Size(1200, 800),
  };
  const locales = {'en': AppLocales.en, 'ar': AppLocales.ar};

  for (final MapEntry(key: sizeName, value: size) in sizes.entries) {
    for (final MapEntry(key: lang, value: locale) in locales.entries) {
      for (final brightness in Brightness.values) {
        testWidgets('renders habits on $sizeName, $lang, ${brightness.name}', (
          tester,
        ) async {
          final cubit = await buildCubit(withHabits: true);
          await pumpHome(
            tester,
            size: size,
            locale: locale,
            brightness: brightness,
            cubit: cubit,
          );
          expect(tester.takeException(), isNull);
          expect(find.text('Read 10 pages'), findsOneWidget);
          await cubit.close();
        });
      }

      testWidgets('renders the empty state on $sizeName, $lang', (
        tester,
      ) async {
        final cubit = await buildCubit(withHabits: false);
        await pumpHome(
          tester,
          size: size,
          locale: locale,
          brightness: Brightness.light,
          cubit: cubit,
        );
        expect(tester.takeException(), isNull);
        expect(
          find.text(lang == 'ar' ? 'لا أثر بعد' : 'No traces yet'),
          findsOneWidget,
        );
        await cubit.close();
      });
    }
  }

  for (final (lang, locale, toast) in [
    ('en', AppLocales.en, 'Trace added · 22-day streak'),
    ('ar', AppLocales.ar, 'أُضيف أثر · سلسلة ٢٢ يومًا'),
  ]) {
    testWidgets('checking a habit shows the toast in $lang', (tester) async {
      final cubit = await buildCubit(withHabits: true);
      await pumpHome(
        tester,
        size: sizes['phone']!,
        locale: locale,
        brightness: Brightness.light,
        cubit: cubit,
      );
      // Read 10 pages: the third card, not yet done today.
      final check = find.byType(CheckButton).at(2);
      expect(
        tester.getSemantics(check),
        matchesSemantics(
          label: lang == 'ar'
              ? 'تسجيل الإنجاز: Read 10 pages'
              : 'Mark done: Read 10 pages',
          isButton: true,
          hasToggledState: true,
        ),
      );

      await tester.runAsync(() async {
        await tester.tap(check);
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text(toast), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 4));
      await cubit.close();
    });
  }
}
