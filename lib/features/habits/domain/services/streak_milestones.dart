/// Streak lengths that get a celebration, one ring illustration each
/// (assets/illustrations/milestone-ring-{7,30,100}.svg).
abstract final class StreakMilestones {
  static const values = [7, 30, 100];

  static bool isMilestone(int streak) => values.contains(streak);

  /// The first milestone above [streak], or null past the last one.
  static int? nextAfter(int streak) {
    for (final value in values) {
      if (value > streak) return value;
    }
    return null;
  }
}
