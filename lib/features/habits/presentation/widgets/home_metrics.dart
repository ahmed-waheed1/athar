import '../../../../core/theme/athar_spacing.dart';

/// Home sizes from design/screens.md (03 · Home) that have no shared token in
/// lib/core/theme. Kept here so widgets never inline them.
abstract final class HomeMetrics {
  // Phone
  static const double topPadding = 52;
  static const double sectionGap = AtharSpacing.md;
  static const double listGap = 10;
  static const double addButtonSize = AtharSizes.minTapTarget;
  static const double addIconSize = 24;
  static const double progressCardPadding = 18;
  static const double progressCardGap = 18;
  static const double ringStrokePhone = 10;
  static const double ringStrokeWide = 12;
  static const double ringCheckSize = 34;
  static const double progressDot = 10;
  static const double progressDotGap = 6;
  static const double progressDotRing = 2;
  static const double sectionTitleInset = AtharSpacing.xxs;

  // Habit card
  static const double cardPadding = AtharSpacing.sm;
  static const double cardGap = 14;
  static const double iconTileWide = 42;
  static const double flameSize = AtharSpacing.md;
  static const double checkBorder = 2.5;
  static const double checkMarkSize = 26;
  static const double checkMarkStroke = 2.8;
  static const double selectedBorder = 2;

  /// Alpha of the accent over `surface` behind the selected wide-list row.
  static const double selectedTintAlpha = 0.06;

  // Swipe actions
  static const double swipeExtent = 144;
  static const double swipeActionWidth = 64;
  static const double swipeActionHeight = 56;
  static const double swipeActionRadius = AtharRadii.field;
  static const double swipeActionIcon = 20;

  // Empty state
  static const double emptyArtWidth = 300;
  static const double emptyArtHeight = 200;
  static const double emptyBodyMaxWidth = 290;
  static const double chipHeight = AtharSizes.minTapTarget;
  static const double chipBorder = 1.5;
  static const double chipIcon = 18;
  static const double buttonIcon = 20;

  // Tablet
  static const double tabletTopPadding = 40;
  static const double tabletGridGap = 14;
  static const double tabletProgressPaddingV = 22;
  static const double tabletProgressPaddingH = 26;
  static const double tabletProgressTitleSize = 21;
  static const double ringValueTabletSize = 30;
  static const double dashedBorder = 2;
  static const double dashLength = 6;
  static const double dashGap = 5;

  // Wide
  static const double wideListPaddingTop = 28;
  static const double wideListPaddingH = 22;
  static const double wideGreetingSize = 24;
  static const double statNumberSize = 32;
  static const double heatmapCellWide = 20;
  static const double heatmapGap = 3;
  static const double heatmapLegendCell = 12;
  static const double heatmapTodayBorder = 2;
  static const int heatmapWeeks = 26;
  static const double milestoneTile = 44;
  static const double emptyMaxWidth = 480;

  // Toast
  static const double toastMargin = AtharSpacing.md;
  static const double toastPaddingV = 10;
  static const double toastPaddingH = AtharSpacing.sm;
  static const double toastTile = 40;
  static const double toastTileRadius = AtharSpacing.sm;
  static const double toastFlame = 22;

  /// How long the toast stays between toastIn and toastOut.
  static const toastVisible = Duration(milliseconds: 3000);
}
