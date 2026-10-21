import 'package:athar/core/di/injection.dart';
import 'package:athar/core/localization/app_locales.dart';
import 'package:athar/core/router/app_router.dart';
import 'package:athar/features/habits/domain/entities/habit.dart';
import 'package:athar/features/habits/domain/entities/reminder_time.dart';
import 'package:athar/features/habits/domain/services/habits_overview_calculator.dart';
import 'package:athar/features/habits/domain/services/streak_calculator.dart';
import 'package:athar/features/habits/domain/usecases/add_habit.dart';
import 'package:athar/features/habits/domain/usecases/delete_habit.dart';
import 'package:athar/features/habits/domain/usecases/get_habit.dart';
import 'package:athar/features/habits/domain/usecases/get_habits.dart';
import 'package:athar/features/habits/domain/usecases/toggle_habit_today.dart';
import 'package:athar/features/habits/domain/usecases/watch_habit_changes.dart';
import 'package:athar/features/habits/domain/usecases/update_habit.dart';
import 'package:athar/features/habits/domain/utils/habit_dates.dart';
import 'package:athar/features/habits/presentation/cubit/habit_details_cubit.dart';
import 'package:athar/features/habits/presentation/cubit/habit_form_cubit.dart';
import 'package:athar/features/habits/presentation/cubit/habits_cubit.dart';
import 'package:athar/features/habits/presentation/screens/habit_details_screen.dart';
import 'package:athar/features/habits/presentation/screens/habit_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../../helpers/athar_test_app.dart';
import '../../../../helpers/fake_notification_service.dart';
import '../../../../helpers/in_memory_habit_repository.dart';
import '../../../../helpers/in_memory_settings_repository.dart';

/// Habit Details through the app's real routes: every state at phone,
/// tablet and wide, in both languages and themes, with the real Cairo font
/// so overflow fails the test.
void main() {
  late InMemoryHabitRepository repository;
  late GoRouter router;

  /// Details' "today": Tuesday 20 October 2026, as in the designs.
  final today = DateTime(2026, 10, 20);
  DateTime now() => today.add(const Duration(hours: 9));

  setUpAll(setUpAtharTestApp);

  setUp(() {
    registerFakeNotifications();
    repository = InMemoryHabitRepository();
    final streaks = StreakCalculator();
    sl
      ..registerFactory(
        () => HabitsCubit(
          getHabits: GetHabits(repository),
          toggleHabitToday: ToggleHabitToday(repository, streaks),
          deleteHabit: DeleteHabit(repository),
          watchHabitChanges: WatchHabitChanges(repository),
          streakCalculator: streaks,
          overviewCalculator: HabitsOverviewCalculator(streaks),
        ),
      )
      ..registerFactory(
        () => HabitDetailsCubit(
          getHabit: GetHabit(repository),
          streakCalculator: StreakCalculator(now: now),
          now: now,
        ),
      )
      ..registerFactory(
        () => HabitFormCubit(
          addHabit: AddHabit(repository),
          updateHabit: UpdateHabit(repository),
          getHabit: GetHabit(repository),
          deleteHabit: DeleteHabit(repository),
          streakCalculator: streaks,
        ),
      );
  });

  tearDown(() => sl.reset());

  /// [count] consecutive days ending on [end].
  List<DateTime> run(DateTime end, int count) => [
    for (var i = 0; i < count; i++) HabitDates.addDays(end, -i),
  ];

  /// Every other day from [from] to [to], for some missed-day texture.
  List<DateTime> alternate(DateTime from, DateTime to) => [
    for (var d = from; !d.isAfter(to); d = HabitDates.addDays(d, 2)) d,
  ];

  final habits = {
    // Read 10 pages: 21 days, best 34.
    'active': Habit(
      id: 'read',
      name: 'Read 10 pages',
      iconKey: 'book',
      colorKey: 'indigo',
      createdAt: DateTime(2026, 5, 1),
      reminderTime: const ReminderTime(hour: 20, minute: 30),
      completedDates: [
        ...run(DateTime(2026, 7, 4), 34),
        ...alternate(DateTime(2026, 7, 10), DateTime(2026, 9, 25)),
        ...run(today, 21),
      ],
    ),
    // Learn English: streak broken, best 12.
    'broken': Habit(
      id: 'english',
      name: 'Learn English',
      iconKey: 'chat',
      colorKey: 'coral',
      createdAt: DateTime(2026, 6, 1),
      reminderTime: const ReminderTime(hour: 19, minute: 0),
      completedDates: [
        ...run(DateTime(2026, 9, 30), 12),
        ...alternate(DateTime(2026, 6, 1), DateTime(2026, 9, 15)),
        DateTime(2026, 10, 2),
        DateTime(2026, 10, 4),
      ],
    ),
    // Learn English, created today.
    'new': Habit(
      id: 'english',
      name: 'Learn English',
      iconKey: 'chat',
      colorKey: 'coral',
      createdAt: today.add(const Duration(hours: 8)),
    ),
  };

  const notes = {
    'active': {'en': 'Best is 34 — 13 to go', 'ar': 'الأفضل ٣٤ — باقي ١٣'},
    'broken': {
      'en': 'Streak paused. Best is 12 — start again today',
      'ar': 'توقفت السلسلة. الأفضل ١٢ — ابدأ من جديد اليوم',
    },
    'new': {
      'en': 'Your first trace is one tap away',
      'ar': 'أثرك الأول على بُعد لمسة',
    },
  };

  Future<void> pumpApp(
    WidgetTester tester, {
    Locale locale = AppLocales.en,
    Brightness brightness = Brightness.light,
    Size size = const Size(375, 812),
  }) async {
    router = createAppRouter(
      settings: buildSettingsCubit(),
      initialLocation: AppRoutes.home,
    );
    addTearDown(router.dispose);
    await pumpAtharRouterApp(
      tester,
      router: router,
      locale: locale,
      brightness: brightness,
      size: size,
    );
  }

  /// Opens Details the way each layout does: its own route on phone and
  /// tablet, the end panel on wide.
  Future<void> openDetails(
    WidgetTester tester,
    Habit habit, {
    required bool wide,
  }) async {
    if (wide) {
      await tester.tap(find.text(habit.name));
    } else {
      router.push(AppRoutes.habitDetails(habit.id));
    }
    await tester.pumpAndSettle();
  }

  Finder navButton(String tooltip) => find.ancestor(
    of: find.byTooltip(tooltip),
    matching: find.byType(IconButton),
  );

  bool isEnabled(WidgetTester tester, Finder button) =>
      tester.widget<IconButton>(button).onPressed != null;

  const sizes = {
    'phone': Size(375, 812),
    'tablet': Size(768, 1024),
    'wide': Size(1200, 800),
  };
  const locales = {'en': AppLocales.en, 'ar': AppLocales.ar};
  const themes = {'light': Brightness.light, 'dark': Brightness.dark};

  for (final MapEntry(key: stateName, value: habit) in habits.entries) {
    for (final MapEntry(key: sizeName, value: size) in sizes.entries) {
      for (final MapEntry(key: lang, value: locale) in locales.entries) {
        for (final MapEntry(key: themeName, value: brightness)
            in themes.entries) {
          testWidgets('$stateName · $sizeName · $lang · $themeName', (
            tester,
          ) async {
            await repository.addHabit(habit);
            await pumpApp(
              tester,
              locale: locale,
              brightness: brightness,
              size: size,
            );
            await openDetails(tester, habit, wide: sizeName == 'wide');
            expect(tester.takeException(), isNull);

            final isAr = lang == 'ar';
            expect(
              find.text(isAr ? 'السلسلة الحالية' : 'Current streak'),
              findsOneWidget,
            );
            expect(find.text(notes[stateName]![lang]!), findsOneWidget);
            if (stateName == 'new') {
              expect(
                find.textContaining(isAr ? 'أُنشئت اليوم' : 'Created today'),
                findsOneWidget,
              );
            }
            final weeks = sizeName == 'phone'
                ? (isAr ? 'آخر ١٨ أسبوعًا' : 'Last 18 weeks')
                : (isAr ? 'آخر ٢٦ أسبوعًا' : 'Last 26 weeks');

            // Phone scrolls; the rest fits the window.
            final monthTitle = isAr ? 'أكتوبر ٢٠٢٦' : 'October 2026';
            if (sizeName == 'phone') {
              await tester.scrollUntilVisible(find.text(monthTitle), 300);
              await tester.pumpAndSettle();
            }
            expect(find.text(weeks), findsOneWidget);
            expect(find.text(monthTitle), findsOneWidget);
            expect(tester.takeException(), isNull);

            // The calendar never goes past the current month.
            final next = navButton(isAr ? 'الشهر التالي' : 'Next month');
            final previous = navButton(
              isAr ? 'الشهر السابق' : 'Previous month',
            );
            expect(isEnabled(tester, next), isFalse);
            expect(isEnabled(tester, previous), stateName != 'new');

            switch (stateName) {
              case 'active':
                expect(find.text(isAr ? '٢١' : '21'), findsWidgets);
              case 'new':
                // Best streak and consistency have nothing to show yet.
                expect(find.text('—'), findsNWidgets(2));
            }

            switch (sizeName) {
              case 'phone':
                expect(find.byType(NavigationBar), findsNothing);
              case 'tablet':
                expect(find.byType(NavigationRail), findsOneWidget);
                expect(
                  find.text(isAr ? 'هذا الشهر' : 'This month'),
                  findsOneWidget,
                );
              case 'wide':
                // In Home's panel, next to the habit list.
                expect(find.byType(HabitDetailsPanel), findsOneWidget);
                expect(find.byType(HabitDetailsScreen), findsNothing);
            }
          });
        }
      }
    }
  }

  testWidgets('month navigation stops at the creation month', (tester) async {
    final semantics = tester.ensureSemantics();
    await repository.addHabit(
      Habit(
        id: 'read',
        name: 'Read 10 pages',
        iconKey: 'book',
        colorKey: 'indigo',
        createdAt: DateTime(2026, 9, 12),
        completedDates: [DateTime(2026, 9, 14), DateTime(2026, 10, 19)],
      ),
    );
    await pumpApp(tester);
    await openDetails(tester, repository.habits['read']!, wide: false);
    await tester.scrollUntilVisible(find.text('October 2026'), 300);
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('October 19, 2026, done'), findsOneWidget);
    expect(find.bySemanticsLabel('October 18, 2026, missed'), findsOneWidget);

    await tester.tap(navButton('Previous month'));
    await tester.pumpAndSettle();
    expect(find.text('September 2026'), findsOneWidget);
    expect(isEnabled(tester, navButton('Previous month')), isFalse);
    expect(isEnabled(tester, navButton('Next month')), isTrue);
    expect(find.bySemanticsLabel('September 14, 2026, done'), findsOneWidget);
    // Before the habit was created: no data, so not a miss.
    expect(find.bySemanticsLabel('September 11, 2026'), findsOneWidget);
    expect(find.bySemanticsLabel('September 13, 2026, missed'), findsOneWidget);

    await tester.tap(navButton('Next month'));
    await tester.pumpAndSettle();
    expect(find.text('October 2026'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('edit updates Details; delete returns Home', (tester) async {
    await repository.addHabit(habits['active']!);
    await pumpApp(tester);
    await openDetails(tester, habits['active']!, wide: false);

    // Save an edit: Details shows the new name.
    await tester.tap(find.byTooltip('Edit habit'));
    await tester.pumpAndSettle();
    expect(find.byType(HabitFormScreen), findsOneWidget);
    await tester.enterText(
      find.descendant(
        of: find.byType(HabitFormScreen),
        matching: find.byType(TextField),
      ),
      'Read 20 pages',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();
    expect(find.byType(HabitFormScreen), findsNothing);
    expect(find.byType(HabitDetailsScreen), findsOneWidget);
    expect(find.text('Read 20 pages'), findsOneWidget);

    // Delete it: back to Home, with the nav bar.
    await tester.tap(find.byTooltip('Edit habit'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Delete habit'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(HabitFormScreen), findsNothing);
    expect(find.byType(HabitDetailsScreen), findsNothing);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(repository.habits, isEmpty);
  });

  testWidgets('a link to a missing habit goes Home', (tester) async {
    await pumpApp(tester);
    router.go(AppRoutes.habitDetails('gone'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(HabitDetailsScreen), findsNothing);
    expect(router.state.uri.path, AppRoutes.home);
  });

  testWidgets('back returns Home', (tester) async {
    await repository.addHabit(habits['active']!);
    await pumpApp(tester, locale: AppLocales.ar);
    await openDetails(tester, habits['active']!, wide: false);
    final back = MaterialLocalizations.of(
      tester.element(find.byType(HabitDetailsScreen)),
    ).backButtonTooltip;
    await tester.tap(find.byTooltip(back));
    await tester.pumpAndSettle();
    expect(find.byType(HabitDetailsScreen), findsNothing);
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
