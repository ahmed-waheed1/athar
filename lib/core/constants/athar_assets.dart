/// Asset paths. Directional UI icons (see design/screens.md) must be drawn with mirrorInRtl.
abstract final class AtharAssets {
  static const brandMarkLight = 'assets/brand/athar-mark-light.svg';
  static const brandMarkDark = 'assets/brand/athar-mark-dark.svg';
  static const brandMarkWhite = 'assets/brand/athar-mark-white.svg';

  static String uiIcon(String name) => 'assets/icons/ui/ui_$name.svg';

  /// [name] is the id stored on a habit (book, drop, walk, ...).
  static String habitIcon(String name) => 'assets/icons/habit/habit_$name.svg';

  /// UI icons that flip horizontally in RTL.
  static const directionalUiIcons = {'back', 'next', 'chev_start', 'chev_end'};
}
