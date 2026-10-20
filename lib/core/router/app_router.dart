import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/habits/presentation/cubit/habits_cubit.dart';
import '../../features/habits/presentation/screens/home_screen.dart';
import '../debug/design_test_screen.dart';
import '../di/injection.dart';
import '../widgets/app_shell.dart';
import '../widgets/placeholder_screen.dart';

abstract final class AppRoutes {
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

GoRouter createAppRouter() => GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => AppShell(shell: shell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.home,
              builder: (context, state) => BlocProvider(
                create: (_) => sl<HabitsCubit>()..load(),
                child: const HomeScreen(),
              ),
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
              builder: (context, state) =>
                  const PlaceholderScreen(titleKey: 'placeholder.settings'),
            ),
          ],
        ),
      ],
    ),
    // TODO(step 05): replace with the Add / Edit Habit screen.
    GoRoute(
      path: AppRoutes.addHabit,
      builder: (context, state) =>
          const PlaceholderScreen(titleKey: 'placeholder.addHabit'),
    ),
    // TODO(step 06): replace with Habit Details.
    GoRoute(
      path: '/habits/:id',
      builder: (context, state) =>
          const PlaceholderScreen(titleKey: 'placeholder.habitDetails'),
      routes: [
        GoRoute(
          path: 'edit',
          builder: (context, state) =>
              const PlaceholderScreen(titleKey: 'placeholder.editHabit'),
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
