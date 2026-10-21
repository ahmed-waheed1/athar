import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/habits/presentation/cubit/habit_details_cubit.dart';
import '../../features/habits/presentation/cubit/habit_form_cubit.dart';
import '../../features/habits/presentation/cubit/habits_cubit.dart';
import '../../features/habits/presentation/screens/habit_details_screen.dart';
import '../../features/habits/presentation/screens/habit_form_screen.dart';
import '../../features/habits/presentation/screens/home_screen.dart';
import '../../features/settings/presentation/cubit/reset_data_cubit.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
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

const _branchRoots = {AppRoutes.home, AppRoutes.history, AppRoutes.settings};

GoRouter createAppRouter() => GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    GoRoute(
      path: AppRoutes.addHabit,
      pageBuilder: (context, state) {
        final query = state.uri.queryParameters;
        return habitFormPage(
          key: state.pageKey,
          child: BlocProvider(
            create: (_) => sl<HabitFormCubit>()
              ..startAdd(
                name: query['name'],
                iconKey: query['icon'],
                colorKey: query['color'],
              ),
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
        child: BlocProvider(
          create: (_) =>
              sl<HabitFormCubit>()..startEdit(state.pathParameters['id']!),
          child: const HabitFormScreen(),
        ),
      ),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => AppShell(
        shell: shell,
        // Details is pushed inside the Today branch so tablet keeps the
        // rail; the phone hides its bar there.
        showNavigationBar: _branchRoots.contains(state.uri.path),
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
              builder: (context, state) => BlocProvider(
                create: (_) => sl<ResetDataCubit>(),
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
