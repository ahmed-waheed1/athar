import 'package:athar/core/router/app_router.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('first launch (onboarding not done)', () {
    String? redirect(String location) =>
        onboardingRedirect(location, onboardingDone: false);

    test('the splash is left alone', () {
      expect(redirect(AppRoutes.splash), isNull);
    });

    test('Home and every other screen go to onboarding', () {
      for (final location in [
        AppRoutes.home,
        AppRoutes.history,
        AppRoutes.settings,
        AppRoutes.addHabit,
        AppRoutes.habitDetails('read'),
        AppRoutes.editHabit('read'),
        AppRoutes.designTest,
      ]) {
        expect(redirect(location), AppRoutes.onboarding, reason: location);
      }
    });

    test('onboarding stays', () {
      expect(redirect(AppRoutes.onboarding), isNull);
    });
  });

  group('after finishing or skipping (onboarding done)', () {
    String? redirect(String location) =>
        onboardingRedirect(location, onboardingDone: true);

    test('onboarding goes to Home', () {
      expect(redirect(AppRoutes.onboarding), AppRoutes.home);
    });

    test('every other screen stays', () {
      for (final location in [
        AppRoutes.splash,
        AppRoutes.home,
        AppRoutes.history,
        AppRoutes.settings,
        AppRoutes.addHabit,
        AppRoutes.habitDetails('read'),
        AppRoutes.designTest,
      ]) {
        expect(redirect(location), isNull, reason: location);
      }
    });
  });
}
