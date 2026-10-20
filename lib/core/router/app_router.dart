import 'package:go_router/go_router.dart';

import '../debug/design_test_screen.dart';

abstract final class AppRoutes {
  static const designTest = '/';
}

GoRouter createAppRouter() => GoRouter(
  initialLocation: AppRoutes.designTest,
  routes: [
    GoRoute(
      path: AppRoutes.designTest,
      builder: (context, state) => const DesignTestScreen(),
    ),
  ],
);
