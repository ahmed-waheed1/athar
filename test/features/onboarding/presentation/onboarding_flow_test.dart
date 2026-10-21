import 'package:athar/app.dart';
import 'package:athar/core/di/injection.dart';
import 'package:athar/core/localization/app_locales.dart';
import 'package:athar/core/router/app_router.dart';
import 'package:athar/core/theme/athar_spacing.dart';
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
import 'package:athar/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:athar/features/onboarding/presentation/screens/splash_screen.dart';
import 'package:athar/features/onboarding/presentation/widgets/splash_metrics.dart';
import 'package:athar/features/settings/domain/entities/app_settings.dart';
import 'package:athar/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../helpers/athar_test_app.dart';
import '../../../helpers/in_memory_habit_repository.dart';
import '../../../helpers/in_memory_settings_repository.dart';

/// Splash, onboarding and the first-launch redirect inside the real AtharApp
/// and app router, so language switching and the redirect run as wired.
void main() {
  setUpAll(setUpAtharTestApp);

  late InMemorySettingsRepository settingsRepository;
  late SettingsCubit settings;
  late GoRouter router;

  setUp(() {
    final habits = InMemoryHabitRepository();
    final streaks = StreakCalculator();
    sl
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
      );
  });

  tearDown(() async {
    router.dispose();
    await settings.close();
    await sl.reset();
  });

  /// Launches the app from the splash with [saved] settings, and lets the
  /// splash finish unless [settle] is false.
  Future<void> launch(
    WidgetTester tester, {
    AppLanguage language = AppLanguage.en,
    AppThemeMode themeMode = AppThemeMode.light,
    bool onboardingDone = false,
    Size size = const Size(375, 812),
    bool reduceMotion = false,
    bool settle = true,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    if (reduceMotion) {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
    }

    settingsRepository = InMemorySettingsRepository(
      AppSettings(
        language: language,
        themeMode: themeMode,
        onboardingDone: onboardingDone,
      ),
    );
    settings = buildSettingsCubit(settingsRepository);
    router = createAppRouter(settings: settings);
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
      // Let easy_localization read the JSON files.
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pump();
    if (settle) await tester.pumpAndSettle();
  }

  /// Taps and waits, with real time for loading the other language's JSON.
  Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
    await tester.runAsync(() async {
      await tester.tap(finder);
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await tester.pumpAndSettle();
  }

  Finder text(String key) => find.text(key.tr());
  Finder button(String key) => find.widgetWithText(FilledButton, key.tr());

  group('splash', () {
    const tagline = 'Small steps, lasting traces';

    /// How visible [finder] is through the fades above it (page fades, the
    /// splash's wordmark fade-in).
    double visibility(WidgetTester tester, Finder finder) {
      var value = 1.0;
      for (final fade in tester.widgetList<FadeTransition>(
        find.ancestor(of: finder, matching: find.byType(FadeTransition)),
      )) {
        value *= fade.opacity.value;
      }
      for (final opacity in tester.widgetList<Opacity>(
        find.ancestor(of: finder, matching: find.byType(Opacity)),
      )) {
        value *= opacity.opacity;
      }
      return value;
    }

    group('first launch', () {
      testWidgets('shows the wordmark and tagline, holds, then onboarding', (
        tester,
      ) async {
        await launch(tester, settle: false);
        expect(find.byType(SplashScreen), findsOneWidget);
        expect(find.text('Athar'), findsOneWidget);
        expect(find.text(tagline), findsOneWidget);

        // The first frame starts the entrance; the next ends it, short of
        // the hold.
        await tester.pump();
        await tester.pump(
          SplashMetrics.hold - const Duration(milliseconds: 100),
        );
        expect(find.byType(SplashScreen), findsOneWidget);
        expect(visibility(tester, find.text(tagline)), 1);
        expect(find.byType(OnboardingScreen), findsNothing);

        await tester.pumpAndSettle();
        expect(find.byType(SplashScreen), findsNothing);
        expect(find.byType(OnboardingScreen), findsOneWidget);
      });

      testWidgets('is in Arabic when the app is', (tester) async {
        await launch(tester, language: AppLanguage.ar, settle: false);
        expect(find.text('أثر'), findsOneWidget);
        expect(find.text('خطوات صغيرة، أثر يدوم'), findsOneWidget);
        await tester.pumpAndSettle();
      });

      testWidgets('with reduced motion, the words are there at once', (
        tester,
      ) async {
        await launch(tester, reduceMotion: true, settle: false);
        await tester.pump();
        expect(visibility(tester, find.text(tagline)), 1);
        // Nothing animates, so nothing keeps frames coming.
        expect(tester.binding.hasScheduledFrame, isFalse);

        await tester.pump(SplashMetrics.hold);
        await tester.pumpAndSettle();
        expect(find.byType(OnboardingScreen), findsOneWidget);
        // Onboarding replaced the splash without a fade.
        expect(visibility(tester, find.byType(OnboardingScreen)), 1);
      });
    });

    group('later launches', () {
      testWidgets('show only the tile, then fade straight into Home', (
        tester,
      ) async {
        await launch(tester, onboardingDone: true, settle: false);
        // Just the tile, as the native splash left it.
        expect(find.byType(SplashScreen), findsOneWidget);
        expect(find.text('Athar'), findsNothing);
        expect(find.text(tagline), findsNothing);

        // Home is up within two frames (go_router applies go() over two)
        // and fades in over the page fade.
        await tester.pump();
        await tester.pump();
        expect(find.byType(HomeScreen), findsOneWidget);
        expect(visibility(tester, find.byType(HomeScreen)), lessThan(1));

        await tester.pump(AtharMotion.pageTransition);
        await tester.pump();
        expect(visibility(tester, find.byType(HomeScreen)), 1);

        // The replaced splash route is disposed once the fade is over.
        await tester.pumpAndSettle();
        expect(find.byType(SplashScreen), findsNothing);
        expect(find.byType(OnboardingScreen), findsNothing);
      });

      testWidgets('with reduced motion, cut to Home without a fade', (
        tester,
      ) async {
        await launch(
          tester,
          onboardingDone: true,
          reduceMotion: true,
          settle: false,
        );
        await tester.pump();
        await tester.pump();
        expect(find.byType(HomeScreen), findsOneWidget);
        expect(visibility(tester, find.byType(HomeScreen)), 1);
        await tester.pumpAndSettle();
        expect(find.byType(SplashScreen), findsNothing);
      });
    });
  });

  group('redirect', () {
    testWidgets('first launch opens onboarding, not Home', (tester) async {
      await launch(tester);
      expect(find.byType(OnboardingScreen), findsOneWidget);
      expect(find.byType(HomeScreen), findsNothing);
      expect(text('onboarding.slides.trace.title'), findsOneWidget);

      // Nothing else is reachable until onboarding is done.
      router.go(AppRoutes.settings);
      await tester.pumpAndSettle();
      expect(find.byType(OnboardingScreen), findsOneWidget);
    });

    testWidgets('Get started on the last slide finishes and goes Home', (
      tester,
    ) async {
      await launch(tester);
      await tester.tap(button('onboarding.next'));
      await tester.pumpAndSettle();
      expect(text('onboarding.slides.path.title'), findsOneWidget);
      await tester.tap(button('onboarding.next'));
      await tester.pumpAndSettle();
      expect(text('onboarding.slides.private.title'), findsOneWidget);

      await tester.tap(button('onboarding.getStarted'));
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(OnboardingScreen), findsNothing);
      expect(settingsRepository.settings.onboardingDone, isTrue);
    });

    testWidgets('Skip finishes and goes Home', (tester) async {
      await launch(tester);
      await tester.tap(text('onboarding.skip'));
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(settingsRepository.settings.onboardingDone, isTrue);
    });

    testWidgets('Skip works from the middle slide too', (tester) async {
      await launch(tester);
      await tester.tap(button('onboarding.next'));
      await tester.pumpAndSettle();
      await tester.tap(text('onboarding.skip'));
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(settingsRepository.settings.onboardingDone, isTrue);
    });

    testWidgets('after onboarding, launches go to Home and stay out of it', (
      tester,
    ) async {
      await launch(tester, onboardingDone: true);
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(OnboardingScreen), findsNothing);

      router.go(AppRoutes.onboarding);
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(OnboardingScreen), findsNothing);
    });

    testWidgets('resetting onboarding (debug tools) shows it again', (
      tester,
    ) async {
      await launch(tester, onboardingDone: true);
      await settings.resetOnboarding();
      await tester.pumpAndSettle();
      expect(find.byType(OnboardingScreen), findsOneWidget);
      expect(settingsRepository.settings.onboardingDone, isFalse);
    });
  });

  group('language picker', () {
    testWidgets('switches the app in place and the next slides follow', (
      tester,
    ) async {
      await launch(tester);
      expect(find.text('Every day leaves a trace'), findsOneWidget);

      await tapAndSettle(tester, find.text('العربية'));
      // Still on slide 1, now in Arabic and right-to-left.
      expect(find.byType(OnboardingScreen), findsOneWidget);
      expect(find.text('كل يوم يترك أثرًا'), findsOneWidget);
      expect(find.text('تخطَّ'), findsOneWidget);
      expect(
        Directionality.of(tester.element(find.byType(OnboardingScreen))),
        TextDirection.rtl,
      );
      expect(settingsRepository.settings.language, AppLanguage.ar);
      expect(settingsRepository.settings.onboardingDone, isFalse);

      await tester.tap(find.widgetWithText(FilledButton, 'التالي'));
      await tester.pumpAndSettle();
      expect(find.text('الآثار تصنع طريقًا'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'التالي'));
      await tester.pumpAndSettle();
      expect(find.text('لك وحدك'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'ابدأ الآن'), findsOneWidget);
    });

    testWidgets('switches back to English', (tester) async {
      await launch(tester, language: AppLanguage.ar);
      await tapAndSettle(tester, find.text('English'));
      expect(find.text('Every day leaves a trace'), findsOneWidget);
      expect(settingsRepository.settings.language, AppLanguage.en);
    });
  });

  group('screens', () {
    const sizes = {
      'phone': Size(375, 812),
      'small phone': Size(320, 640),
      'tablet': Size(768, 1024),
      'wide': Size(1200, 800),
    };

    const expected = {
      AppLanguage.en: [
        (
          'Every day leaves a trace',
          'Check off a habit and you leave a mark. Small, but it stays.',
        ),
        (
          'Traces become a path',
          'Day after day, your marks connect into a pattern you can actually see.',
        ),
        (
          'Yours, and only yours',
          'No accounts, no cloud. Your habits and history stay on this device.',
        ),
      ],
      AppLanguage.ar: [
        ('كل يوم يترك أثرًا', 'أنجز عادتك فتترك علامة. صغيرة، لكنها تبقى.'),
        (
          'الآثار تصنع طريقًا',
          'يومًا بعد يوم، تتصل علاماتك لتصنع نمطًا تراه بعينك.',
        ),
        (
          'لك وحدك',
          'بلا حسابات ولا سحابة. عاداتك وسجلّك يبقيان على هذا الجهاز.',
        ),
      ],
    };

    /// The illustration on the slide in view (not the globe icon).
    final illustration = find.byWidgetPredicate(
      (widget) =>
          widget is SvgPicture &&
          (widget.bytesLoader as SvgAssetLoader).assetName.contains(
            'illustrations/',
          ),
    );

    String currentIllustration(WidgetTester tester) =>
        (tester.widget<SvgPicture>(illustration).bytesLoader as SvgAssetLoader)
            .assetName;

    bool isMirrored(WidgetTester tester) => tester
        .widgetList<Transform>(
          find.ancestor(of: illustration, matching: find.byType(Transform)),
        )
        .any((transform) => transform.transform.storage[0] < 0);

    for (final MapEntry(key: sizeName, value: size) in sizes.entries) {
      for (final language in AppLanguage.values) {
        for (final themeMode in [AppThemeMode.light, AppThemeMode.dark]) {
          testWidgets(
            'all slides render on $sizeName, ${language.name}, ${themeMode.name}',
            (tester) async {
              await launch(
                tester,
                language: language,
                themeMode: themeMode,
                size: size,
              );
              final isAr = language == AppLanguage.ar;
              final brightness = themeMode.name;
              final slugs = ['1-trace', '2-path', '3-private'];

              for (var i = 0; i < 3; i++) {
                final (title, body) = expected[language]![i];
                expect(find.text(title), findsOneWidget);
                expect(find.text(body), findsOneWidget);
                // Slide 1 has its own RTL artwork (its check mark must not
                // mirror); slides 2 and 3 are flipped.
                final rtlArtwork = isAr && i == 0;
                expect(
                  currentIllustration(tester),
                  'assets/illustrations/onboarding-${slugs[i]}-$brightness'
                  '${rtlArtwork ? '-rtl' : ''}.svg',
                );
                expect(isMirrored(tester), isAr && !rtlArtwork);
                expect(tester.takeException(), isNull);

                final isLast = i == 2;
                // Language picker on slide 1 only.
                expect(
                  find.text('العربية'),
                  i == 0 ? findsOneWidget : findsNothing,
                );
                // Skip on slides 1 and 2; hidden (not tappable) on 3.
                expect(
                  find.text(isAr ? 'تخطَّ' : 'Skip').hitTestable(),
                  isLast ? findsNothing : findsOneWidget,
                );
                final cta = isLast
                    ? (isAr ? 'ابدأ الآن' : 'Get started')
                    : (isAr ? 'التالي' : 'Next');
                expect(find.widgetWithText(FilledButton, cta), findsOneWidget);

                if (!isLast) {
                  // Swipe toward the start edge for the next slide: left in
                  // English, right in Arabic.
                  await tester.fling(
                    find.byType(PageView),
                    Offset(isAr ? 300 : -300, 0),
                    1000,
                  );
                  await tester.pumpAndSettle();
                }
              }
            },
          );
        }
      }
    }

    testWidgets('page indicator reads the page in the UI language', (
      tester,
    ) async {
      await launch(tester, language: AppLanguage.ar);
      expect(find.bySemanticsLabel('الصفحة ١ من ٣'), findsOneWidget);
    });
  });
}
