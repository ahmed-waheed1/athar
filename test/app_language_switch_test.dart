import 'package:athar/app.dart';
import 'package:athar/core/di/injection.dart';
import 'package:athar/core/localization/app_locales.dart';
import 'package:athar/core/router/app_router.dart';
import 'package:athar/core/theme/athar_typography.dart';
import 'package:athar/features/habits/domain/entities/habit.dart';
import 'package:athar/features/habits/domain/services/habits_overview_calculator.dart';
import 'package:athar/features/habits/domain/services/streak_calculator.dart';
import 'package:athar/features/habits/domain/usecases/delete_all_habits.dart';
import 'package:athar/features/habits/domain/usecases/delete_habit.dart';
import 'package:athar/features/habits/domain/usecases/get_habit.dart';
import 'package:athar/features/habits/domain/usecases/get_habits.dart';
import 'package:athar/features/habits/domain/usecases/toggle_habit_today.dart';
import 'package:athar/features/habits/domain/usecases/watch_habit_changes.dart';
import 'package:athar/features/habits/presentation/cubit/habit_details_cubit.dart';
import 'package:athar/features/habits/presentation/cubit/habits_cubit.dart';
import 'package:athar/features/habits/presentation/screens/habit_details_screen.dart';
import 'package:athar/features/habits/presentation/screens/home_screen.dart';
import 'package:athar/features/settings/domain/entities/app_settings.dart';
import 'package:athar/features/settings/domain/entities/app_version.dart';
import 'package:athar/features/settings/presentation/cubit/reset_data_cubit.dart';
import 'package:athar/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:athar/features/settings/presentation/screens/settings_screen.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'helpers/athar_test_app.dart';
import 'helpers/athar_token_styles.dart';
import 'helpers/fake_notification_service.dart';
import 'helpers/in_memory_habit_repository.dart';
import 'helpers/in_memory_settings_repository.dart';

/// Switching language (or theme) at runtime, in the real AtharApp and app
/// router, must restyle every screen in the stack at once, not after a
/// restart.
void main() {
  setUpAll(setUpAtharTestApp);

  late InMemorySettingsRepository settingsRepository;
  late SettingsCubit settings;
  late GoRouter router;

  setUp(() async {
    registerFakeNotifications();
    final habits = InMemoryHabitRepository();
    final today = DateTime.now();
    // A 3-day streak running to yesterday: Home and Details show "3".
    await habits.addHabit(
      Habit(
        id: 'read',
        name: 'Read',
        iconKey: 'book',
        colorKey: 'indigo',
        createdAt: today.subtract(const Duration(days: 30)),
        completedDates: [
          for (var i = 1; i <= 3; i++) today.subtract(Duration(days: i)),
        ],
      ),
    );
    final streaks = StreakCalculator();
    sl
      ..registerSingleton(const AppVersion(version: '1.0.0', buildNumber: '1'))
      ..registerFactory(
        () => HabitsCubit(
          getHabits: GetHabits(habits),
          toggleHabitToday: ToggleHabitToday(habits, streaks),
          deleteHabit: DeleteHabit(habits),
          watchHabitChanges: WatchHabitChanges(habits),
          streakCalculator: streaks,
          overviewCalculator: HabitsOverviewCalculator(streaks),
        ),
      )
      ..registerFactory(
        () => HabitDetailsCubit(
          getHabit: GetHabit(habits),
          streakCalculator: streaks,
        ),
      )
      ..registerFactory(
        () => ResetDataCubit(
          getHabits: GetHabits(habits),
          deleteAllHabits: DeleteAllHabits(habits),
        ),
      );
  });

  tearDown(() async {
    router.dispose();
    await settings.close();
    await sl.reset();
  });

  /// Opens Settings, then Home and Details on top, so all three are built.
  /// With [onboarding], opens onboarding instead.
  Future<void> launch(
    WidgetTester tester, {
    required AppLanguage language,
    AppThemeMode themeMode = AppThemeMode.light,
    bool onboarding = false,
  }) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    settingsRepository = InMemorySettingsRepository(
      AppSettings(
        language: language,
        themeMode: themeMode,
        onboardingDone: !onboarding,
      ),
    );
    settings = buildSettingsCubit(settingsRepository);
    router = createAppRouter(
      settings: settings,
      initialLocation: onboarding ? AppRoutes.onboarding : AppRoutes.settings,
    );
    sl
      ..registerSingleton(settings)
      ..registerSingleton(router);

    await tester.runAsync(() async {
      await tester.pumpWidget(
        EasyLocalization(
          supportedLocales: AppLocales.supported,
          path: AppLocales.translationsPath,
          fallbackLocale: AppLocales.fallback,
          startLocale: language.locale,
          saveLocale: false,
          useOnlyLangCode: true,
          ignorePluralRules: false,
          child: const AtharApp(),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pumpAndSettle();
    if (onboarding) return;
    router.go(AppRoutes.home);
    await tester.pumpAndSettle();
    router.push(AppRoutes.habitDetails('read'));
    await tester.pumpAndSettle();
    expect(find.byType(HabitDetailsScreen), findsOneWidget);
  }

  /// Switches through the cubit, as Settings and onboarding do, and lets
  /// easy_localization load the new translations.
  Future<void> switchLanguage(WidgetTester tester, AppLanguage language) async {
    // As on a device: frames keep coming while the translations load.
    final change = settings.changeLanguage(language);
    for (var i = 0; i < 30; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 10)),
      );
      await tester.pump(const Duration(milliseconds: 16));
    }
    await tester.runAsync(() => change);
    await tester.pumpAndSettle();
  }

  /// Throws the app away, so [launch] can start it again.
  Future<void> close(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    router.dispose();
    await settings.close();
    sl
      ..unregister<SettingsCubit>()
      ..unregister<GoRouter>();
  }

  /// Every piece of text painted anywhere in the app (on stage or not):
  /// what it says, its size, line height, letter-spacing and direction.
  List<String> paintedText(WidgetTester tester) {
    final painted = <String>[];
    void visit(Element element) {
      final paragraph = element.renderObject;
      if (element.widget is RichText && paragraph is RenderParagraph) {
        final style = paragraph.text.style;
        painted.add(
          '"${paragraph.text.toPlainText()}" ${style?.fontSize} '
          '${style?.height} ${style?.letterSpacing} '
          '${paragraph.textDirection.name}',
        );
      }
      element.visitChildren(visit);
    }

    tester.binding.rootElement!.visitChildren(visit);
    return painted..sort();
  }

  /// After switching [from] → [to], the app paints exactly what a fresh
  /// launch in [to] paints.
  Future<void> expectSwitchMatchesFreshLaunch(
    WidgetTester tester, {
    required AppLanguage from,
    required AppLanguage to,
    bool onboarding = false,
  }) async {
    await launch(tester, language: from, onboarding: onboarding);
    await switchLanguage(tester, to);
    final switched = paintedText(tester);
    await close(tester);

    await launch(tester, language: to, onboarding: onboarding);
    final fresh = paintedText(tester);
    expect(
      switched.toSet().difference(fresh.toSet()),
      isEmpty,
      reason:
          'painted after switching ${from.name} → ${to.name}, but not on '
          'a fresh ${to.name} launch',
    );
    expect(switched, fresh);
  }

  const screens = [SettingsScreen, HomeScreen, HabitDetailsScreen];

  Map<String, TextStyle?> textThemeSlots(TextTheme t) => {
    'displayLarge': t.displayLarge,
    'displayMedium': t.displayMedium,
    'displaySmall': t.displaySmall,
    'headlineLarge': t.headlineLarge,
    'headlineMedium': t.headlineMedium,
    'headlineSmall': t.headlineSmall,
    'titleLarge': t.titleLarge,
    'titleMedium': t.titleMedium,
    'titleSmall': t.titleSmall,
    'bodyLarge': t.bodyLarge,
    'bodyMedium': t.bodyMedium,
    'bodySmall': t.bodySmall,
    'labelLarge': t.labelLarge,
    'labelMedium': t.labelMedium,
    'labelSmall': t.labelSmall,
  };

  /// Every open screen (on stage or not) is styled for [language].
  void expectStyledFor(
    WidgetTester tester,
    AppLanguage language, {
    required Brightness brightness,
  }) {
    final isAr = language == AppLanguage.ar;
    final styles = isAr ? AtharTextStyles.arabic : AtharTextStyles.latin;
    for (final screen in screens) {
      final finder = find.byType(screen, skipOffstage: false);
      expect(finder, findsOneWidget, reason: '$screen is open');
      final context = tester.element(finder);
      final theme = Theme.of(context);
      final reason = '$screen in ${language.name}';

      expect(Localizations.localeOf(context), language.locale, reason: reason);
      expect(
        Directionality.of(context),
        isAr ? TextDirection.rtl : TextDirection.ltr,
        reason: reason,
      );
      expect(theme.brightness, brightness, reason: reason);
      // All 15 slots of both text themes carry the language's styles:
      // Arabic line heights are taller (body 1.65 vs 1.45) and its
      // letter-spacing is always 0. Nothing comes from Material's defaults.
      final expected = textThemeSlots(styles.toTextTheme());
      for (final (themeName, textTheme) in [
        ('textTheme', theme.textTheme),
        ('primaryTextTheme', theme.primaryTextTheme),
      ]) {
        final actual = textThemeSlots(textTheme);
        for (final MapEntry(key: slot, value: style) in expected.entries) {
          final where = '$reason: $themeName.$slot';
          expect(style, isNotNull, reason: where);
          expect(actual[slot]?.height, style!.height, reason: where);
          expect(actual[slot]?.fontSize, style.fontSize, reason: where);
          expect(
            actual[slot]?.letterSpacing,
            style.letterSpacing,
            reason: where,
          );
          if (isAr) expect(actual[slot]?.letterSpacing, 0, reason: where);
        }
      }
    }

    // Everything painted uses a token letter-spacing: 0 in Arabic.
    final allowed = {
      for (final style in tokenStyles(styles).values) style.letterSpacing,
    };
    for (final line in paintedText(tester)) {
      final spacing = double.parse(line.split(' ').reversed.elementAt(1));
      expect(allowed, contains(spacing), reason: 'painted $line');
      if (isAr) expect(spacing, 0, reason: 'painted $line');
    }

    // The streak "3" on Home and Details, in the language's digits.
    for (final screen in [HomeScreen, HabitDetailsScreen]) {
      Finder digit(String d) => find.descendant(
        of: find.byType(screen, skipOffstage: false),
        matching: find.textContaining(d, skipOffstage: false),
      );
      expect(digit(isAr ? '٣' : '3'), findsWidgets, reason: '$screen digits');
      expect(digit(isAr ? '3' : '٣'), findsNothing, reason: '$screen digits');
    }
  }

  testWidgets('English → Arabic restyles every open screen', (tester) async {
    await launch(tester, language: AppLanguage.en);
    expectStyledFor(tester, AppLanguage.en, brightness: Brightness.light);

    await switchLanguage(tester, AppLanguage.ar);
    expectStyledFor(tester, AppLanguage.ar, brightness: Brightness.light);
  });

  testWidgets('Arabic → English restyles every open screen (dark)', (
    tester,
  ) async {
    await launch(
      tester,
      language: AppLanguage.ar,
      themeMode: AppThemeMode.dark,
    );
    expectStyledFor(tester, AppLanguage.ar, brightness: Brightness.dark);

    await switchLanguage(tester, AppLanguage.en);
    expectStyledFor(tester, AppLanguage.en, brightness: Brightness.dark);
  });

  for (final (from, to) in [
    (AppLanguage.en, AppLanguage.ar),
    (AppLanguage.ar, AppLanguage.en),
  ]) {
    testWidgets('Settings, Home and Details after ${from.name} → ${to.name} '
        'look like a fresh launch', (tester) async {
      await expectSwitchMatchesFreshLaunch(tester, from: from, to: to);
    });

    testWidgets('onboarding after ${from.name} → ${to.name} looks like a '
        'fresh launch', (tester) async {
      await expectSwitchMatchesFreshLaunch(
        tester,
        from: from,
        to: to,
        onboarding: true,
      );
    });
  }

  testWidgets('switching back and forth ends in the last language', (
    tester,
  ) async {
    await launch(tester, language: AppLanguage.en);
    await switchLanguage(tester, AppLanguage.ar);
    await switchLanguage(tester, AppLanguage.en);
    expectStyledFor(tester, AppLanguage.en, brightness: Brightness.light);
  });

  testWidgets('switching the theme keeps the language', (tester) async {
    await launch(tester, language: AppLanguage.ar);

    await tester.runAsync(() => settings.changeThemeMode(AppThemeMode.dark));
    await tester.pumpAndSettle();
    expectStyledFor(tester, AppLanguage.ar, brightness: Brightness.dark);
    expect(settings.state.language, AppLanguage.ar);
    expect(settingsRepository.settings.language, AppLanguage.ar);

    await tester.runAsync(() => settings.changeThemeMode(AppThemeMode.light));
    await tester.pumpAndSettle();
    expectStyledFor(tester, AppLanguage.ar, brightness: Brightness.light);
  });
}
