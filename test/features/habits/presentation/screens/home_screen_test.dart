import 'dart:io';

import 'package:athar/core/debug/sample_habits.dart';
import 'package:athar/core/localization/app_locales.dart';
import 'package:athar/core/theme/athar_theme.dart';
import 'package:athar/features/habits/domain/services/habits_overview_calculator.dart';
import 'package:athar/features/habits/domain/services/streak_calculator.dart';
import 'package:athar/features/habits/domain/usecases/delete_habit.dart';
import 'package:athar/features/habits/domain/usecases/get_habit.dart';
import 'package:athar/features/habits/domain/usecases/get_habits.dart';
import 'package:athar/features/habits/domain/usecases/toggle_habit_today.dart';
import 'package:athar/features/habits/domain/usecases/watch_habit_changes.dart';
import 'package:athar/features/habits/presentation/cubit/habit_details_cubit.dart';
import 'package:athar/features/habits/presentation/cubit/habits_cubit.dart';
import 'package:athar/features/habits/presentation/screens/home_screen.dart';
import 'package:athar/features/habits/presentation/widgets/check_button.dart';
import 'package:athar/features/habits/presentation/widgets/milestone/confetti_layer.dart';
import 'package:athar/features/habits/presentation/widgets/milestone/milestone_dialog.dart';
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

  late InMemoryHabitRepository repository;

  HabitDetailsCubit buildDetailsCubit() => HabitDetailsCubit(
    getHabit: GetHabit(repository),
    streakCalculator: StreakCalculator(),
  );

  const sampleNames = {
    'debug.samplePray': 'Pray on time',
    'debug.sampleWater': 'Drink water',
    'debug.sampleRead': 'Read 10 pages',
    'debug.sampleWalk': 'Morning walk',
    'debug.sampleEnglish': 'Learn English',
  };

  /// [milestoneSamples]: Drink water, Pray on time and Morning walk, one
  /// check-in away from 7, 30 and 100.
  Future<HabitsCubit> buildCubit({
    required bool withHabits,
    bool milestoneSamples = false,
  }) async {
    repository = InMemoryHabitRepository();
    final streaks = StreakCalculator();
    if (withHabits) {
      final build = milestoneSamples
          ? buildMilestoneSampleHabits
          : buildSampleHabits;
      for (final habit in build(
        now: DateTime.now(),
        name: (key) => sampleNames[key]!,
      )) {
        await repository.addHabit(habit);
      }
    }
    final cubit = HabitsCubit(
      getHabits: GetHabits(repository),
      toggleHabitToday: ToggleHabitToday(repository, streaks),
      deleteHabit: DeleteHabit(repository),
      watchHabitChanges: WatchHabitChanges(repository),
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
                  child: HomeScreen(createDetailsCubit: buildDetailsCubit),
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

  for (final (lang, locale, title) in [
    ('en', AppLocales.en, 'Current streak'),
    ('ar', AppLocales.ar, 'السلسلة الحالية'),
  ]) {
    testWidgets('wide: selecting a habit shows its details in $lang', (
      tester,
    ) async {
      final cubit = await buildCubit(withHabits: true);
      await pumpHome(
        tester,
        size: sizes['wide']!,
        locale: locale,
        brightness: Brightness.light,
        cubit: cubit,
      );
      expect(find.text(title), findsNothing);

      await tester.runAsync(() async {
        await tester.tap(find.text('Read 10 pages'));
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text(title), findsOneWidget);
      // Header name plus the selected list row.
      expect(find.text('Read 10 pages'), findsNWidgets(2));

      // Tapping it again goes back to the overview.
      await tester.tap(find.text('Read 10 pages').first);
      await tester.pumpAndSettle();
      expect(find.text(title), findsNothing);
      await cubit.close();
    });
  }

  /// Lets a closing dialog finish and leave the tree.
  Future<void> pumpDialogClosed(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
  }

  Future<void> tapCheck(WidgetTester tester, String label) async {
    await tester.runAsync(() async {
      await tester.tap(find.bySemanticsLabel(label));
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await tester.pump();
  }

  for (final (lang, locale, milestone, name, title, body, next) in [
    (
      'en',
      AppLocales.en,
      7,
      'Drink water',
      '7-day streak!',
      'A full week of traces for “Drink water”. Your path is taking shape.',
      'Next milestone · 30 days',
    ),
    (
      'ar',
      AppLocales.ar,
      7,
      'Drink water',
      'سلسلة ٧ أيام!',
      'أسبوع كامل من الأثر في «Drink water». طريقك يتشكّل.',
      'المحطة التالية · ٣٠ يومًا',
    ),
    (
      'en',
      AppLocales.en,
      30,
      'Pray on time',
      '30-day streak!',
      'A month of showing up for “Pray on time”. That’s a real habit now.',
      'Next milestone · 100 days',
    ),
    (
      'ar',
      AppLocales.ar,
      30,
      'Pray on time',
      'سلسلة ٣٠ يومًا!',
      'شهر كامل من الالتزام بـ«Pray on time». صارت عادة حقيقية.',
      'المحطة التالية · ١٠٠ يوم',
    ),
    (
      'en',
      AppLocales.en,
      100,
      'Morning walk',
      '100-day streak!',
      '100 mornings of “Morning walk”. This trace is here to stay.',
      null,
    ),
    (
      'ar',
      AppLocales.ar,
      100,
      'Morning walk',
      'سلسلة ١٠٠ يوم!',
      '١٠٠ صباح من «Morning walk». هذا الأثر باقٍ.',
      null,
    ),
  ]) {
    testWidgets('reaching $milestone shows the celebration, not the toast, '
        'in $lang', (tester) async {
      final cubit = await buildCubit(withHabits: true, milestoneSamples: true);
      await pumpHome(
        tester,
        size: sizes['phone']!,
        locale: locale,
        brightness: Brightness.light,
        cubit: cubit,
      );

      await tapCheck(
        tester,
        lang == 'ar' ? 'تسجيل الإنجاز: $name' : 'Mark done: $name',
      );
      await tester.pump(const Duration(seconds: 2));

      expect(tester.takeException(), isNull);
      expect(find.byType(MilestoneCard), findsOneWidget);
      expect(find.byType(ConfettiLayer), findsOneWidget);
      expect(find.text(title), findsOneWidget);
      expect(find.text(body), findsOneWidget);
      if (next == null) {
        expect(
          find.textContaining(lang == 'ar' ? 'المحطة' : 'Next'),
          findsNothing,
        );
      } else {
        expect(find.text(next), findsOneWidget);
      }
      expect(find.byType(SnackBar), findsNothing);

      await tester.tap(find.text(lang == 'ar' ? 'واصل الطريق' : 'Keep going'));
      await pumpDialogClosed(tester);
      expect(find.byType(MilestoneCard), findsNothing);
      expect(find.byType(ConfettiLayer), findsNothing);
      await cubit.close();
    });
  }

  testWidgets('unchecking and rechecking shows the toast, not the celebration '
      'again', (tester) async {
    final cubit = await buildCubit(withHabits: true, milestoneSamples: true);
    await pumpHome(
      tester,
      size: sizes['phone']!,
      locale: AppLocales.en,
      brightness: Brightness.light,
      cubit: cubit,
    );

    await tapCheck(tester, 'Mark done: Drink water');
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(MilestoneCard), findsOneWidget);
    await tester.tap(find.byTooltip('Close'));
    await pumpDialogClosed(tester);
    expect(find.byType(MilestoneCard), findsNothing);

    await tapCheck(tester, 'Undo: Drink water');
    await tester.pump(const Duration(seconds: 1));
    await tapCheck(tester, 'Mark done: Drink water');
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(MilestoneCard), findsNothing);
    expect(find.text('Trace added · 7-day streak'), findsOneWidget);
    await tester.pumpAndSettle(const Duration(seconds: 4));
    await cubit.close();
  });

  testWidgets('reduced motion: no confetti, the card fades in', (tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    final cubit = await buildCubit(withHabits: true, milestoneSamples: true);
    await pumpHome(
      tester,
      size: sizes['phone']!,
      locale: AppLocales.en,
      brightness: Brightness.light,
      cubit: cubit,
    );

    await tapCheck(tester, 'Mark done: Drink water');
    await tester.pump(const Duration(milliseconds: 1));
    // Only a fade: the card is at full size from the first frame.
    final scale = tester.widget<ScaleTransition>(
      find
          .ancestor(
            of: find.byType(MilestoneCard),
            matching: find.byType(ScaleTransition),
          )
          .first,
    );
    expect(scale.scale.value, 1);

    // Nothing loops, so everything settles.
    await tester.pumpAndSettle();
    expect(find.byType(MilestoneCard), findsOneWidget);
    expect(find.byType(ConfettiLayer), findsNothing);
    await cubit.close();
  });
}
