import 'package:athar/core/di/injection.dart';
import 'package:athar/core/localization/app_locales.dart';
import 'package:athar/core/router/app_router.dart';
import 'package:athar/features/habits/domain/entities/habit.dart';
import 'package:athar/features/habits/domain/entities/habit_name.dart';
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
import 'package:athar/features/habits/presentation/cubit/habit_form_cubit.dart';
import 'package:athar/features/habits/presentation/cubit/habits_cubit.dart';
import 'package:athar/features/habits/presentation/screens/habit_form_screen.dart';
import 'package:athar/features/habits/presentation/screens/home_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../../helpers/athar_test_app.dart';
import '../../../../helpers/in_memory_habit_repository.dart';

/// Add / Edit Habit through the app's real routes, in every language, theme
/// and layout, with the real Cairo font so overflow fails the test.
void main() {
  late InMemoryHabitRepository repository;
  late GoRouter router;

  setUpAll(setUpAtharTestApp);

  setUp(() {
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

  Habit readHabit() {
    final today = DateTime.now();
    return Habit(
      id: 'read',
      name: 'Read 10 pages',
      iconKey: 'book',
      colorKey: 'indigo',
      createdAt: today.subtract(const Duration(days: 30)),
      reminderTime: const ReminderTime(hour: 20, minute: 30),
      // A 3-day streak running to yesterday.
      completedDates: [
        for (var i = 1; i <= 3; i++) today.subtract(Duration(days: i)),
      ],
    );
  }

  Future<void> pumpApp(
    WidgetTester tester, {
    String location = AppRoutes.home,
    Locale locale = AppLocales.en,
    Brightness brightness = Brightness.light,
    Size size = const Size(375, 812),
  }) async {
    router = createAppRouter();
    addTearDown(router.dispose);
    await pumpAtharRouterApp(
      tester,
      router: router,
      locale: locale,
      brightness: brightness,
      size: size,
    );
    if (location != AppRoutes.home) {
      router.push(location);
      await tester.pumpAndSettle();
    }
  }

  /// Home stays built under the form (the route is not opaque, so it can
  /// be a dialog on tablet); look only inside the form.
  Finder inForm(Finder finder) =>
      find.descendant(of: find.byType(HabitFormScreen), matching: finder);

  Finder saveButton(String key) => find.widgetWithText(FilledButton, key.tr());

  bool isEnabled(WidgetTester tester, Finder button) =>
      tester.widget<FilledButton>(button).onPressed != null;

  /// Opens Edit the way a user does: swipe the card on Home, tap Edit.
  Future<void> openEditFromHome(WidgetTester tester, String name) async {
    await tester.drag(find.text(name), const Offset(-200, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('home.edit'.tr()));
    await tester.pumpAndSettle();
    expect(find.byType(HabitFormScreen), findsOneWidget);
  }

  /// Taps something that may sit below the fold of the form.
  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  const sizes = {'phone': Size(375, 812), 'tablet': Size(768, 1024)};
  const locales = {'en': AppLocales.en, 'ar': AppLocales.ar};
  const themes = {'light': Brightness.light, 'dark': Brightness.dark};

  for (final MapEntry(key: sizeName, value: size) in sizes.entries) {
    for (final MapEntry(key: langName, value: locale) in locales.entries) {
      for (final MapEntry(key: themeName, value: brightness)
          in themes.entries) {
        final variant = '$sizeName · $langName · $themeName';

        testWidgets('add: empty, then both name errors ($variant)', (
          tester,
        ) async {
          await pumpApp(
            tester,
            location: AppRoutes.addHabit,
            locale: locale,
            brightness: brightness,
            size: size,
          );
          final numbers = locale == AppLocales.ar
              ? (zero: '٠', max: '٤٠', tooLong: '٦٦')
              : (zero: '0', max: '40', tooLong: '66');

          // Empty: placeholder preview, 0/40, Save disabled.
          expect(find.text('habitForm.addTitle'.tr()), findsOneWidget);
          expect(
            find.text('habitForm.preview.startsToday'.tr()),
            findsOneWidget,
          );
          expect(find.text('${numbers.zero}/${numbers.max}'), findsOneWidget);
          expect(isEnabled(tester, saveButton('habitForm.save')), isFalse);

          // error-empty-name: change something, then Save with no name.
          await tapVisible(
            tester,
            find.bySemanticsLabel('habitForm.color.names.coral'.tr()),
          );
          expect(find.text('habitForm.color.names.coral'.tr()), findsWidgets);
          await tester.tap(saveButton('habitForm.save'));
          await tester.pumpAndSettle();
          expect(find.text('habitForm.name.errorEmpty'.tr()), findsOneWidget);
          expect(router.state.uri.path, AppRoutes.addHabit);

          // error-name-too-long: shown while typing; Save is refused.
          const long =
              'Read at least ten pages of a good book every night before sleeping';
          await tester.enterText(find.byType(TextField), long);
          await tester.pumpAndSettle();
          expect(find.text('habitForm.name.errorEmpty'.tr()), findsNothing);
          final tooLong = 'habitForm.name.errorTooLong'.plural(
            HabitName.maxLength,
            format: NumberFormat.decimalPattern(
              locale == AppLocales.ar ? 'ar_EG' : 'en_US',
            ),
          );
          expect(find.text(tooLong), findsOneWidget);
          expect(tooLong, contains(numbers.max));
          expect(
            find.text('${numbers.tooLong}/${numbers.max}'),
            findsOneWidget,
          );
          await tester.tap(saveButton('habitForm.save'));
          await tester.pumpAndSettle();
          expect(repository.habits, isEmpty);
          expect(router.state.uri.path, AppRoutes.addHabit);
        });

        testWidgets('edit: prefilled ($variant)', (tester) async {
          await repository.addHabit(readHabit());
          await pumpApp(
            tester,
            location: AppRoutes.editHabit('read'),
            locale: locale,
            brightness: brightness,
            size: size,
          );
          final ar = locale == AppLocales.ar;

          expect(inForm(find.text('habitForm.editTitle'.tr())), findsOneWidget);
          expect(inForm(find.text('Read 10 pages')), findsWidgets);
          expect(inForm(find.text(ar ? '١٣/٤٠' : '13/40')), findsOneWidget);
          expect(inForm(find.text(ar ? '٣ أيام' : '3 days')), findsOneWidget);
          expect(
            inForm(find.textContaining(ar ? '٨:٣٠ م' : '8:30')),
            findsOneWidget,
          );
          expect(find.byTooltip('habitForm.delete'.tr()), findsOneWidget);
          expect(
            isEnabled(tester, saveButton('habitForm.saveChanges')),
            isTrue,
          );
        });
      }
    }
  }

  group('Arabic', () {
    testWidgets('counts graphemes with Arabic-Indic digits', (tester) async {
      await pumpApp(
        tester,
        location: AppRoutes.addHabit,
        locale: AppLocales.ar,
      );
      await tester.enterText(find.byType(TextField), 'تعلّم الإنجليزية');
      await tester.pumpAndSettle();
      expect(find.text('١٥/٤٠'), findsOneWidget);
    });

    testWidgets('time sheet uses Arabic digits and ص / م', (tester) async {
      await pumpApp(
        tester,
        location: AppRoutes.addHabit,
        locale: AppLocales.ar,
      );
      await tapVisible(tester, find.text('habitForm.reminder.title'.tr()));
      expect(find.text('habitForm.reminder.sheetTitle'.tr()), findsOneWidget);
      expect(find.text('٧'), findsWidgets);
      expect(find.text('٠٠'), findsWidgets);
      expect(find.text('م'), findsOneWidget);
      expect(find.text('ص'), findsOneWidget);

      await tester.tap(find.text('habitForm.reminder.set'.tr()));
      await tester.pumpAndSettle();
      expect(find.textContaining('٧:٠٠ م'), findsOneWidget);
    });
  });

  group('pickers', () {
    testWidgets('the icon sheet picks an icon and updates the row', (
      tester,
    ) async {
      await pumpApp(tester, location: AppRoutes.addHabit);
      await tapVisible(tester, find.text('habitForm.icon.more'.tr()));
      expect(find.text('habitForm.icon.sheetTitle'.tr()), findsOneWidget);

      // The sheet shows all 20; the chat cell in the sheet is the last match.
      await tester.tap(
        find.bySemanticsLabel('habitForm.icon.names.chat'.tr()).last,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('habitForm.icon.done'.tr()));
      await tester.pumpAndSettle();
      expect(find.text('habitForm.icon.sheetTitle'.tr()), findsNothing);

      expect(
        tester.getSemantics(
          find.bySemanticsLabel('habitForm.icon.names.chat'.tr()),
        ),
        isSemantics(isSelected: true),
      );
    });

    testWidgets('the reminder switch shows the default time', (tester) async {
      await pumpApp(tester, location: AppRoutes.addHabit);
      expect(find.text('habitForm.reminder.subtitleOff'.tr()), findsOneWidget);
      await tapVisible(tester, find.byType(Switch));
      expect(find.textContaining('7:00'), findsOneWidget);
    });
  });

  group('navigation', () {
    testWidgets('a new habit shows on Home right after Save', (tester) async {
      await pumpApp(tester);
      await tester.tap(find.text('home.empty.create'.tr()));
      await tester.pumpAndSettle();
      expect(find.byType(HabitFormScreen), findsOneWidget);

      await tester.enterText(find.byType(TextField), '  Learn English  ');
      await tester.pumpAndSettle();
      await tester.tap(saveButton('habitForm.save'));
      await tester.pumpAndSettle();

      expect(find.byType(HabitFormScreen), findsNothing);
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.text('Learn English'), findsOneWidget);
      expect(repository.habits.values.single.name, 'Learn English');
    });

    testWidgets('an empty-state suggestion prefills the form', (tester) async {
      await pumpApp(tester);
      await tester.tap(find.text('home.empty.suggestionWater'.tr()));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(TextField, 'Drink water'), findsOneWidget);
      expect(find.text('habitForm.color.names.sky'.tr()), findsOneWidget);
      expect(
        tester.getSemantics(
          find.bySemanticsLabel('habitForm.icon.names.drop'.tr()),
        ),
        isSemantics(isSelected: true),
      );

      // Nothing changed yet, so leaving doesn't ask.
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(find.byType(HabitFormScreen), findsNothing);
    });

    testWidgets('an edit shows on Home right after Save', (tester) async {
      await repository.addHabit(readHabit());
      await pumpApp(tester);
      await openEditFromHome(tester, 'Read 10 pages');

      await tester.enterText(find.byType(TextField), 'Read 20 pages');
      await tester.pumpAndSettle();
      await tester.tap(saveButton('habitForm.saveChanges'));
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.text('Read 20 pages'), findsOneWidget);
      expect(find.text('Read 10 pages'), findsNothing);
      // History survives the edit.
      expect(repository.habits['read']!.completedDates, hasLength(3));
    });

    testWidgets('editing a habit that no longer exists returns Home', (
      tester,
    ) async {
      await pumpApp(tester, location: AppRoutes.editHabit('gone'));
      expect(find.byType(HabitFormScreen), findsNothing);
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(router.state.uri.path, AppRoutes.home);
    });

    testWidgets('leaving with changes asks before discarding', (tester) async {
      await pumpApp(tester, location: AppRoutes.addHabit);
      await tester.enterText(find.byType(TextField), 'Walk');
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(find.text('habitForm.discard.title'.tr()), findsOneWidget);
      await tester.tap(find.text('habitForm.discard.cancel'.tr()));
      await tester.pumpAndSettle();
      expect(find.byType(HabitFormScreen), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Walk'), findsOneWidget);

      // The system back gesture asks too.
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('habitForm.discard.title'.tr()), findsOneWidget);
      await tester.tap(find.text('habitForm.discard.confirm'.tr()));
      await tester.pumpAndSettle();
      expect(find.byType(HabitFormScreen), findsNothing);
      expect(repository.habits, isEmpty);
    });

    testWidgets('tablet: tapping the scrim asks before discarding', (
      tester,
    ) async {
      await pumpApp(
        tester,
        location: AppRoutes.addHabit,
        size: const Size(768, 1024),
      );
      expect(find.byTooltip('Close'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'Walk');
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      expect(find.text('habitForm.discard.title'.tr()), findsOneWidget);
    });

    testWidgets('delete from Edit returns Home without the habit', (
      tester,
    ) async {
      await repository.addHabit(readHabit());
      await pumpApp(tester);
      await openEditFromHome(tester, 'Read 10 pages');
      await tester.tap(find.byTooltip('habitForm.delete'.tr()));
      await tester.pumpAndSettle();
      await tester.tap(find.text('deleteDialog.confirm'.tr()));
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(repository.habits, isEmpty);
      expect(find.text('home.empty.title'.tr()), findsOneWidget);
    });

    testWidgets('opened by a deep link, Save goes to Home', (tester) async {
      router = createAppRouter();
      addTearDown(router.dispose);
      router.go(AppRoutes.addHabitWith(name: 'Walk'));
      await pumpAtharRouterApp(tester, router: router, locale: AppLocales.en);

      await tester.tap(saveButton('habitForm.save'));
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.text('Walk'), findsOneWidget);
    });
  });

  testWidgets('the keyboard covers neither the field nor Save', (tester) async {
    await pumpApp(tester, location: AppRoutes.addHabit);
    const keyboard = 336.0;
    tester.view.viewInsets = const FakeViewPadding(bottom: keyboard);
    await tester.showKeyboard(find.byType(TextField));
    await tester.pumpAndSettle();

    const visibleBottom = 812 - keyboard;
    final save = tester.getRect(saveButton('habitForm.save'));
    final field = tester.getRect(find.byType(TextField));
    expect(save.bottom, lessThanOrEqualTo(visibleBottom));
    expect(field.bottom, lessThanOrEqualTo(save.top));
    expect(field.top, greaterThanOrEqualTo(0));
  });
}
