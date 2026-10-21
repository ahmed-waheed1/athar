import '../../../../../core/theme/athar_spacing.dart';

/// Add / Edit Habit sizes from design/screens.md (05) that have no shared
/// token in lib/core/theme. Kept here so widgets never inline them.
abstract final class HabitFormMetrics {
  // Screen (phone)
  static const double topPadding = 44;
  static const double bottomPadding = AtharSpacing.xxl;
  static const double appBarHeight = 48;
  static const double appBarIcon = 24;

  /// The back button's icon lines up with the gutter.
  static const double appBarInset =
      AtharSizes.gutterPhone - (AtharSizes.minTapTarget - appBarIcon) / 2;
  static const double appBarTitleGap = AtharSpacing.xs;
  static const double appBarGap = 10;
  static const double saveTopGap = AtharSpacing.sm;

  // Dialog (tablet and wide)
  static const double dialogMargin = AtharSpacing.xl;
  static const double dialogPadding = AtharSpacing.xl;
  static const double dialogScaleFrom = 0.92;

  // Form
  static const double nameTop = AtharSpacing.lg;
  static const double sectionTop = 18;
  static const double reminderTop = 14;

  /// Under the reminder row while notifications are blocked (screens.md · 09).
  static const double blockedBannerTop = AtharSpacing.xs;

  /// Swipe back: the start-edge strip it starts in (as in Cupertino routes),
  /// and how far a swipe goes before it asks to discard unsaved changes.
  static const double backSwipeEdge = 20;
  static const double backSwipeTrigger = 32;
  static const double labelGap = AtharSpacing.xs;
  static const double errorGap = AtharSpacing.xs;
  static const double errorIcon = AtharSpacing.md;
  static const double errorIconGap = 6;

  /// Centres the icon on the first line of caption text.
  static const double errorIconTop = 2;
  static const int nameMaxLines = 3;

  /// The "Icon" header holds a 48-high "More" button; this keeps its label
  /// where an 18 gap above a plain label would put it.
  static const double iconHeaderTop =
      sectionTop - (AtharSizes.minTapTarget - 20) / 2;
  static const double moreButtonPaddingH = AtharSpacing.xxs;

  // Validation shake: 3 × 4 px over 300 ms.
  static const shakeDuration = Duration(milliseconds: 300);
  static const double shakeOffset = 4;
  static const int shakeCount = 3;

  // Icon cells (row and sheet)
  static const double iconCell = AtharSizes.iconPickerCell;
  static const double iconCellGap = AtharSpacing.xs;
  static const double iconCellBorder = 2;
  static const double iconSize = 24;
  static const int iconSheetColumns = 5;
  static const double iconSheetGap = 10;

  // Color grid
  static const int colorColumns = 4;
  static const double colorCell = 52;
  static const double colorGridTop = AtharSpacing.xxs;
  static const double colorRowGap = 2;
  static const double swatchGap = 3;
  static const double swatchRing = 2.5;
  static const double swatchFocusRing = 2;
  static const double swatchCheck = 20;

  // Reminder row
  static const double reminderRadius = AtharRadii.button;
  static const double reminderPaddingV = 10;
  static const double reminderPaddingH = 14;
  static const double bellTile = 40;
  static const double bellTileRadius = AtharSpacing.sm;
  static const double bellIcon = 22;
  static const double reminderGap = AtharSpacing.sm;

  // Bottom sheets
  static const double sheetActionsTop = AtharSpacing.xl;
  static const double sheetButtonHeight = 52;
  static const double sheetButtonGap = AtharSpacing.sm;

  // Time wheel
  static const double wheelItemExtent = 46;
  static const int wheelVisibleItems = 5;
  static const double wheelBandHeight = 44;
  static const double wheelBandRadius = 14;
  static const double wheelSelectedSize = 26;
  static const double wheelNeighbourSize = 20;
  static const double wheelOuterOpacity = 0.45;
  static const double wheelColonWidth = AtharSpacing.xl;
  static const double wheelDiameterRatio = 8;
  static const int wheelMinuteStep = 5;

  /// Rows each looping column repeats its values for, so it never reaches
  /// an end in practice.
  static const int wheelLoops = 1000;
}
