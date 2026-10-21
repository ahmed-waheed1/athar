import 'package:flutter/widgets.dart';

/// Asset paths. Directional UI icons (see design/screens.md) must be drawn with mirrorInRtl.
abstract final class AtharAssets {
  static const brandMarkLight = 'assets/brand/athar-mark-light.svg';
  static const brandMarkDark = 'assets/brand/athar-mark-dark.svg';
  static const brandMarkWhite = 'assets/brand/athar-mark-white.svg';

  /// Empty Home illustration. Directional: mirror it in RTL.
  static String emptyStateTrail(Brightness brightness) =>
      'assets/illustrations/empty-state-trail-${brightness.name}.svg';

  /// Onboarding illustration by its slug (1-trace, 2-path, 3-private). All
  /// three mirror in RTL, as in the Arabic designs: 2 and 3 by flipping,
  /// 1 with its own [rtl] artwork, because a flip would mirror its check mark.
  static String onboarding(
    String slug,
    Brightness brightness, {
    bool rtl = false,
  }) =>
      'assets/illustrations/onboarding-$slug-${brightness.name}'
      '${rtl ? '-rtl' : ''}.svg';

  /// Notification permission sheet illustration (design/screens.md · 09).
  static String notificationBell(Brightness brightness) =>
      'assets/illustrations/notification-bell-${brightness.name}.svg';

  static String uiIcon(String name) => 'assets/icons/ui/ui_$name.svg';

  /// [name] is the id stored on a habit (book, drop, walk, ...).
  static String habitIcon(String name) => 'assets/icons/habit/habit_$name.svg';

  /// UI icons that flip horizontally in RTL.
  static const directionalUiIcons = {'back', 'next', 'chev_start', 'chev_end'};
}
