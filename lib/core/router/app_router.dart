import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/habits/presentation/cubit/habit_details_cubit.dart';
import '../../features/habits/presentation/cubit/habit_form_cubit.dart';
import '../../features/habits/presentation/cubit/habits_cubit.dart';
import '../../features/habits/presentation/screens/habit_details_screen.dart';
import '../../features/habits/presentation/screens/habit_form_screen.dart';
import '../../features/habits/presentation/screens/home_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/onboarding/presentation/screens/splash_screen.dart';
import '../../features/settings/domain/entities/app_settings.dart';
import '../../features/settings/presentation/cubit/reset_data_cubit.dart';
import '../../features/settings/presentation/cubit/settings_cubit.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../debug/design_test_screen.dart';
import '../di/injection.dart';
import '../notifications/notification_permission_cubit.dart';
import '../theme/athar_spacing.dart';
import '../widgets/app_shell.dart';
import '../widgets/placeholder_screen.dart';

abstract final class AppRoutes {
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const home = '/';
  static const history = '/history';
  static const settings = '/settings';
  static const addHabit = '/habits/new';
  static const designTest = '/debug/design';

  static String habitDetails(String id) => '/habits/$id';
  static String editHabit(String id) => '/habits/$id/edit';

  /// Add Habit, optionally prefilled (empty-state suggestions).
  static String addHabitWith({
    String? name,
    String? iconKey,
    String? colorKey,
  }) => Uri(
    path: addHabit,
    queryParameters: {'name': ?name, 'icon': ?iconKey, 'color': ?colorKey},
  ).toString();
}

const _branchRoots = {AppRoutes.home, AppRoutes.history, AppRoutes.settings};

/// Keeps the app on onboarding until it's done, and out of it afterwards.
/// The splash is left alone: it goes to Home when it's finished, and this
/// sends a first launch on to onboarding from there.
String? onboardingRedirect(String location, {required bool onboardingDone}) {
  if (location == AppRoutes.splash) return null;
  final atOnboarding = location == AppRoutes.onboarding;
  if (onboardingDone) return atOnboarding ? AppRoutes.home : null;
  return atOnboarding ? null : AppRoutes.onboarding;
}

/// Re-runs the redirect when onboarding is completed or reset, so Skip, Get
/// started and the debug reset need no navigation of their own.
class _OnboardingRefresh extends ChangeNotifier {
  _OnboardingRefresh(SettingsCubit settings)
    : _done = settings.state.onboardingDone {
    _subscription = settings.stream.listen(_onSettings);
  }

  bool _done;
  late final StreamSubscription<AppSettings> _subscription;

  void _onSettings(AppSettings settings) {
    if (settings.onboardingDone == _done) return;
    _done = settings.onboardingDone;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

/// Splash, onboarding and the shell cross-fade instead of sliding: they
/// replace each other rather than stacking. With reduced motion they cut.
Page<void> _fadePage({required LocalKey key, required Widget child}) =>
    CustomTransitionPage<void>(
      key: key,
      child: child,
      transitionDuration: AtharMotion.pageTransition,
      reverseTransitionDuration: AtharMotion.pageTransition,
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          MediaQuery.disableAnimationsOf(context)
          ? child
          : FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: AtharMotion.pageTransitionCurve,
              ),
              child: child,
            ),
    );

GoRouter createAppRouter({
  required SettingsCubit settings,
  String initialLocation = AppRoutes.splash,
}) => GoRouter(
  initialLocation: initialLocation,
  refreshListenable: _OnboardingRefresh(settings),
  redirect: (context, state) => onboardingRedirect(
    state.uri.path,
    onboardingDone: settings.state.onboardingDone,
  ),
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      pageBuilder: (context, state) => _fadePage(
        key: state.pageKey,
        child: SplashScreen(firstLaunch: !settings.state.onboardingDone),
      ),
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      pageBuilder: (context, state) =>
          _fadePage(key: state.pageKey, child: const OnboardingScreen()),
    ),
    GoRoute(
      path: AppRoutes.addHabit,
      pageBuilder: (context, state) {
        final query = state.uri.queryParameters;
        return habitFormPage(
          key: state.pageKey,
          child: MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (_) => sl<HabitFormCubit>()
                  ..startAdd(
                    name: query['name'],
                    iconKey: query['icon'],
                    colorKey: query['color'],
                  ),
              ),
              BlocProvider.value(value: sl<NotificationPermissionCubit>()),
            ],
            child: const HabitFormScreen(),
          ),
        );
      },
    ),
    // Top level rather than under '/habits/:id', so pushing it from Home
    // doesn't stack Details underneath: Save goes straight back. Listed
    // before the shell so '/habits/new' never matches Details.
    GoRoute(
      path: '/habits/:id/edit',
      pageBuilder: (context, state) => habitFormPage(
        key: state.pageKey,
        child: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) =>
                  sl<HabitFormCubit>()..startEdit(state.pathParameters['id']!),
            ),
            BlocProvider.value(value: sl<NotificationPermissionCubit>()),
          ],
          child: const HabitFormScreen(),
        ),
      ),
    ),
    StatefulShellRoute.indexedStack(
      pageBuilder: (context, state, shell) => _fadePage(
        key: state.pageKey,
        child: AppShell(
          shell: shell,
          // Details is pushed inside the Today branch so tablet keeps the
          // rail; the phone hides its bar there.
          showNavigationBar: _branchRoots.contains(state.uri.path),
        ),
      ),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.home,
              builder: (context, state) => BlocProvider(
                create: (_) => sl<HabitsCubit>()..load(),
                child: HomeScreen(
                  createDetailsCubit: () => sl<HabitDetailsCubit>(),
                ),
              ),
              routes: [
                GoRoute(
                  path: 'habits/:id',
                  builder: (context, state) => BlocProvider(
                    create: (_) =>
                        sl<HabitDetailsCubit>()
                          ..load(state.pathParameters['id']!),
                    child: const HabitDetailsScreen(),
                  ),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.history,
              builder: (context, state) =>
                  const PlaceholderScreen(titleKey: 'placeholder.history'),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.settings,
              builder: (context, state) => MultiBlocProvider(
                providers: [
                  BlocProvider(create: (_) => sl<ResetDataCubit>()),
                  BlocProvider.value(value: sl<NotificationPermissionCubit>()),
                ],
                child: SettingsScreen(version: sl()),
              ),
            ),
          ],
        ),
      ],
    ),
    if (kDebugMode)
      GoRoute(
        path: AppRoutes.designTest,
        builder: (context, state) => const DesignTestScreen(),
      ),
  ],
);
