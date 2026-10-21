import 'package:athar/app.dart';
import 'package:athar/core/di/injection.dart';
import 'package:athar/core/localization/app_locales.dart';
import 'package:athar/core/notifications/notification_permission_cubit.dart';
import 'package:athar/core/router/app_router.dart';
import 'package:athar/core/services/notification_service.dart';
import 'package:athar/core/widgets/athar_segmented_control.dart';
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
import 'package:athar/features/habits/presentation/screens/home_screen.dart';
import 'package:athar/features/settings/data/datasources/settings_local_data_source.dart';
import 'package:athar/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:athar/features/settings/domain/entities/app_settings.dart';
import 'package:athar/features/settings/domain/entities/app_version.dart';
import 'package:athar/features/settings/domain/usecases/get_settings.dart';
import 'package:athar/features/settings/domain/usecases/set_language.dart';
import 'package:athar/features/settings/domain/usecases/set_onboarding_done.dart';
import 'package:athar/features/settings/domain/usecases/set_theme_mode.dart';
import 'package:athar/features/settings/presentation/cubit/reset_data_cubit.dart';
import 'package:athar/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:athar/features/settings/presentation/screens/settings_screen.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../helpers/athar_test_app.dart';
import '../../../../helpers/fake_notification_service.dart';
import '../../../../helpers/in_memory_habit_repository.dart';

/// Settings inside the real AtharApp (language and theme wiring), next to a
/// Home that is already loaded, as in the app's tab shell.
void main() {
  setUpAll(setUpAtharTestApp);

  late InMemoryHabitRepository repository;
  late SharedPreferences prefs;
  late HabitsCubit habitsCubit;

  const version = AppVersion(version: '1.2.3', buildNumber: '45');

  Habit habit(String id, int traces) => Habit(
    id: id,
    name: 'Habit $id',
    iconKey: 'book',
    colorKey: 'teal',
    createdAt: DateTime(2026, 1, 1),
    completedDates: [for (var i = 0; i < traces; i++) DateTime(2026, 1, 1 + i)],
    celebratedMilestones: traces >= 7 ? [7] : [],
  );

  Future<void> pumpSettings(
    WidgetTester tester, {
    AppLanguage language = AppLanguage.en,
    AppThemeMode themeMode = AppThemeMode.light,
    Size size = const Size(375, 812),
    List<Habit> habits = const [],
    FakeNotificationService? notifications,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    SharedPreferences.setMockInitialValues({
      SettingsLocalDataSource.languageKey: language.name,
      SettingsLocalDataSource.themeModeKey: themeMode.name,
    });
    prefs = await SharedPreferences.getInstance();
    final settingsRepository = SettingsRepositoryImpl(
      SettingsLocalDataSource(prefs),
      deviceLanguageCode: 'en',
    );

    repository = InMemoryHabitRepository();
    for (final h in habits) {
      await repository.addHabit(h);
    }
    final streaks = StreakCalculator();
    habitsCubit = HabitsCubit(
      getHabits: GetHabits(repository),
      toggleHabitToday: ToggleHabitToday(repository, streaks),
      deleteHabit: DeleteHabit(repository),
      watchHabitChanges: WatchHabitChanges(repository),
      streakCalculator: streaks,
      overviewCalculator: HabitsOverviewCalculator(streaks),
    );
    await habitsCubit.load();
    addTearDown(habitsCubit.close);

    registerFakeNotifications(notifications);
    sl
      ..registerSingleton(
        SettingsCubit(
          getSettings: GetSettings(settingsRepository),
          setLanguage: SetLanguage(settingsRepository),
          setThemeMode: SetThemeMode(settingsRepository),
          setOnboardingDone: SetOnboardingDone(settingsRepository),
        ),
      )
      ..registerSingleton(
        GoRouter(
          initialLocation: AppRoutes.settings,
          routes: [
            GoRoute(
              path: AppRoutes.home,
              builder: (context, state) => Scaffold(
                body: BlocProvider.value(
                  value: habitsCubit,
                  child: HomeScreen(
                    createDetailsCubit: () => HabitDetailsCubit(
                      getHabit: GetHabit(repository),
                      streakCalculator: streaks,
                    ),
                  ),
                ),
              ),
            ),
            GoRoute(
              path: AppRoutes.settings,
              builder: (context, state) => Scaffold(
                body: MultiBlocProvider(
                  providers: [
                    BlocProvider(
                      create: (_) => ResetDataCubit(
                        getHabits: GetHabits(repository),
                        deleteAllHabits: DeleteAllHabits(repository),
                      ),
                    ),
                    BlocProvider.value(
                      value: sl<NotificationPermissionCubit>()..refresh(),
                    ),
                  ],
                  child: const SettingsScreen(version: version),
                ),
              ),
            ),
          ],
        ),
      );

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
  }

  tearDown(() => sl.reset());

  Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
    await tester.runAsync(() async {
      await tester.tap(finder);
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await tester.pumpAndSettle();
  }

  const sizes = {
    'phone': Size(375, 812),
    'small phone': Size(320, 640),
    'tablet': Size(768, 1024),
    'wide': Size(1200, 800),
  };

  for (final MapEntry(key: sizeName, value: size) in sizes.entries) {
    for (final language in AppLanguage.values) {
      for (final themeMode in [AppThemeMode.light, AppThemeMode.dark]) {
        testWidgets(
          'renders on $sizeName, ${language.name}, ${themeMode.name}',
          (tester) async {
            await pumpSettings(
              tester,
              language: language,
              themeMode: themeMode,
              size: size,
            );
            expect(tester.takeException(), isNull);
            final isAr = language == AppLanguage.ar;
            expect(find.text(isAr ? 'الإعدادات' : 'Settings'), findsOneWidget);
            // Both languages in their own script, whatever the UI language.
            expect(find.text('English'), findsOneWidget);
            expect(find.text('العربية'), findsOneWidget);
            expect(
              find.text(isAr ? 'مسح كل البيانات' : 'Reset all data'),
              findsOneWidget,
            );
            final versionText = find.text(
              isAr ? 'أثر · الإصدار ١.٢.٣ (٤٥)' : 'Athar · Version 1.2.3 (45)',
            );
            // Below the fold on small phones.
            await tester.scrollUntilVisible(
              versionText,
              200,
              scrollable: find.byType(Scrollable).first,
            );
            expect(versionText, findsOneWidget);
            // Preferences holds Reminders only (no "Week starts on").
            expect(
              find.text(isAr ? 'التفضيلات' : 'Preferences'),
              findsOneWidget,
            );
            expect(find.text(isAr ? 'التذكيرات' : 'Reminders'), findsOneWidget);
            expect(find.byType(Switch), findsOneWidget);
            expect(
              find.text(isAr ? 'بداية الأسبوع' : 'Week starts on'),
              findsNothing,
            );
          },
        );
      }
    }
  }

  group('reminders row', () {
    const strings = {
      AppLanguage.en: (
        on: 'On · per-habit times',
        off: 'Off',
        blocked: 'Blocked by the system',
        banner:
            'Notifications are blocked, so reminders can’t reach you. '
            'Turn them on in your phone’s settings.',
        openSettings: 'Open settings',
        promptTitle: 'Want a gentle nudge?',
        allow: 'Allow reminders',
      ),
      AppLanguage.ar: (
        on: 'مفعّلة · وقت لكل عادة',
        off: 'متوقفة',
        blocked: 'محظورة من النظام',
        banner: 'الإشعارات متوقفة، لذلك لن تصلك التذكيرات. فعّلها من إعدادات هاتفك.',
        openSettings: 'فتح الإعدادات',
        promptTitle: 'هل تريد تذكيرًا لطيفًا؟',
        allow: 'السماح بالتذكيرات',
      ),
    };

    Switch remindersSwitch(WidgetTester tester) =>
        tester.widget<Switch>(find.byType(Switch));

    for (final MapEntry(key: language, value: text) in strings.entries) {
      testWidgets('blocked: disabled switch, banner, Open settings '
          '(${language.name})', (tester) async {
        final notifications = FakeNotificationService(
          permissionState: NotificationPermission.denied,
        );
        await pumpSettings(
          tester,
          language: language,
          notifications: notifications,
        );

        expect(find.text(text.blocked), findsOneWidget);
        expect(find.text(text.banner), findsOneWidget);
        expect(remindersSwitch(tester).value, isFalse);
        expect(remindersSwitch(tester).onChanged, isNull);

        await tester.tap(find.text(text.openSettings));
        await tester.pumpAndSettle();
        expect(notifications.openSettingsCalls, 1);
        expect(tester.takeException(), isNull);
      });

      testWidgets('not asked yet: the switch explains, then asks '
          '(${language.name})', (tester) async {
        final notifications = FakeNotificationService(
          permissionState: NotificationPermission.notDetermined,
        );
        await pumpSettings(
          tester,
          language: language,
          notifications: notifications,
        );
        expect(find.text(text.off), findsOneWidget);
        expect(find.text(text.banner), findsNothing);

        await tester.tap(find.byType(Switch));
        await tester.pumpAndSettle();
        expect(find.text(text.promptTitle), findsOneWidget);
        await tester.tap(find.text(text.allow));
        await tester.pumpAndSettle();

        expect(notifications.requestCalls, 1);
        expect(find.text(text.on), findsOneWidget);
        expect(remindersSwitch(tester).value, isTrue);
      });

      testWidgets('allowed: on, and turning it off opens the system '
          'settings (${language.name})', (tester) async {
        final notifications = FakeNotificationService();
        await pumpSettings(
          tester,
          language: language,
          notifications: notifications,
        );
        expect(find.text(text.on), findsOneWidget);
        expect(remindersSwitch(tester).value, isTrue);

        await tester.tap(find.byType(Switch));
        await tester.pumpAndSettle();
        expect(notifications.openSettingsCalls, 1);
        expect(find.text(text.promptTitle), findsNothing);
      });
    }

    testWidgets('re-reads the permission when the app comes back', (
      tester,
    ) async {
      final notifications = FakeNotificationService(
        permissionState: NotificationPermission.denied,
      );
      await pumpSettings(tester, notifications: notifications);
      expect(find.text('Blocked by the system'), findsOneWidget);

      // Turned on in the system settings, then back to the app.
      notifications.permissionState = NotificationPermission.granted;
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(find.text('On · per-habit times'), findsOneWidget);
      expect(find.textContaining('Notifications are blocked'), findsNothing);
    });
  });

  testWidgets('uses the designed segmented controls, not Material ones', (
    tester,
  ) async {
    await pumpSettings(tester);
    expect(find.byType(SegmentedButton<AppLanguage>), findsNothing);
    expect(find.byType(SegmentedButton<AppThemeMode>), findsNothing);
    expect(find.byType(AtharSegmentedControl<AppLanguage>), findsOneWidget);
    expect(find.byType(AtharSegmentedControl<AppThemeMode>), findsOneWidget);
    expect(
      tester.getSemantics(find.text('English')),
      matchesSemantics(
        label: 'English',
        isButton: true,
        hasSelectedState: true,
        isSelected: true,
        isInMutuallyExclusiveGroup: true,
        hasTapAction: true,
        hasFocusAction: true,
        isFocusable: true,
      ),
    );
  });

  testWidgets('switching language changes locale and direction at once, and '
      'persists', (tester) async {
    await pumpSettings(tester);
    expect(
      Directionality.of(tester.element(find.byType(SettingsScreen))),
      TextDirection.ltr,
    );

    await tapAndSettle(tester, find.text('العربية'));

    expect(find.text('الإعدادات'), findsOneWidget);
    expect(find.text('أثر · الإصدار ١.٢.٣ (٤٥)'), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.byType(SettingsScreen))),
      TextDirection.rtl,
    );
    expect(prefs.getString(SettingsLocalDataSource.languageKey), 'ar');
  });

  testWidgets('switching theme applies and persists it', (tester) async {
    await pumpSettings(tester);
    Brightness brightness() =>
        Theme.of(tester.element(find.byType(SettingsScreen))).brightness;
    expect(brightness(), Brightness.light);

    await tapAndSettle(tester, find.text('Dark'));

    expect(brightness(), Brightness.dark);
    expect(prefs.getString(SettingsLocalDataSource.themeModeKey), 'dark');
  });

  for (final (language, habits, body) in [
    (
      AppLanguage.en,
      [habit('a', 400), habit('b', 12)],
      'This removes 2 habits and 412 traces from this device. '
          'It can’t be undone.',
    ),
    (
      AppLanguage.en,
      [habit('a', 1)],
      'This removes 1 habit and 1 trace from this device. It can’t be undone.',
    ),
    (
      AppLanguage.ar,
      [for (var i = 0; i < 5; i++) habit('$i', i == 0 ? 400 : 3)],
      'سيُحذف ٥ عادات و٤١٢ أثرًا من هذا الجهاز، ولا يمكن التراجع عن ذلك.',
    ),
    (
      AppLanguage.ar,
      [habit('a', 2)],
      'سيُحذف عادة واحدة وأثران من هذا الجهاز، ولا يمكن التراجع عن ذلك.',
    ),
    (
      AppLanguage.ar,
      [habit('a', 5), habit('b', 5)],
      'سيُحذف عادتان و١٠ آثار من هذا الجهاز، ولا يمكن التراجع عن ذلك.',
    ),
    (
      AppLanguage.en,
      <Habit>[],
      'There are no habits on this device yet. Nothing will be removed.',
    ),
  ]) {
    testWidgets('reset dialog shows the real counts: ${language.name}, '
        '${habits.length} habits', (tester) async {
      await pumpSettings(tester, language: language, habits: habits);

      await tapAndSettle(
        tester,
        find.text(
          language == AppLanguage.ar ? 'مسح كل البيانات' : 'Reset all data',
        ),
      );

      expect(
        find.text(
          language == AppLanguage.ar ? 'مسح كل البيانات؟' : 'Reset all data?',
        ),
        findsOneWidget,
      );
      expect(find.text(body), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('cancel keeps everything', (tester) async {
    await pumpSettings(tester, habits: [habit('a', 9)]);

    await tapAndSettle(tester, find.text('Reset all data'));
    await tapAndSettle(tester, find.text('Cancel'));

    expect(find.text('Reset all data?'), findsNothing);
    expect(await repository.getHabits(), hasLength(1));
    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('reset deletes habits and milestones, keeps language and theme, '
      'and Home shows its empty state', (tester) async {
    await pumpSettings(
      tester,
      language: AppLanguage.ar,
      themeMode: AppThemeMode.dark,
      habits: [habit('a', 30), habit('b', 3)],
    );

    await tapAndSettle(tester, find.text('مسح كل البيانات'));
    await tapAndSettle(tester, find.text('مسح'));

    expect(await repository.getHabits(), isEmpty);
    expect(repository.habits, isEmpty);
    // Settings stay.
    expect(prefs.getString(SettingsLocalDataSource.languageKey), 'ar');
    expect(prefs.getString(SettingsLocalDataSource.themeModeKey), 'dark');
    expect(sl<SettingsCubit>().state.language, AppLanguage.ar);
    expect(sl<SettingsCubit>().state.themeMode, AppThemeMode.dark);
    // Routed to Home, which reloaded by itself to the empty state.
    expect(find.byType(SettingsScreen), findsNothing);
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('لا أثر بعد'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
