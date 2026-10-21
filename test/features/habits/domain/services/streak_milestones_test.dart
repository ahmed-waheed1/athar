import 'package:athar/features/habits/domain/services/streak_milestones.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('milestones are 7, 30 and 100 only', () {
    expect(StreakMilestones.values, [7, 30, 100]);
    for (final streak in [7, 30, 100]) {
      expect(StreakMilestones.isMilestone(streak), isTrue, reason: '$streak');
    }
    for (final streak in [0, 1, 6, 8, 14, 29, 60, 99, 101, 365]) {
      expect(StreakMilestones.isMilestone(streak), isFalse, reason: '$streak');
    }
  });

  test('next milestone after a streak', () {
    expect(StreakMilestones.nextAfter(0), 7);
    expect(StreakMilestones.nextAfter(6), 7);
    expect(StreakMilestones.nextAfter(7), 30);
    expect(StreakMilestones.nextAfter(29), 30);
    expect(StreakMilestones.nextAfter(30), 100);
    expect(StreakMilestones.nextAfter(99), 100);
    expect(StreakMilestones.nextAfter(100), isNull);
    expect(StreakMilestones.nextAfter(365), isNull);
  });
}
