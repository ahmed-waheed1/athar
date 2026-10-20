// GENERATED from the Athar design tokens (design-tokens.json).
import 'package:flutter/material.dart';

/// 4px spacing scale.
abstract final class AtharSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  /// Horizontal screen gutter per layout.
  static double gutter(AtharLayout layout) =>
      layout == AtharLayout.phone ? 20 : 32;
}

/// Corner radii.
abstract final class AtharRadii {
  /// Heatmap cell (14px) on phone
  static const double heatmapCellPhone = 4;

  /// Heatmap cell (18px) on tablet/wide
  static const double heatmapCellLarge = 5;

  /// Month calendar day cell, phone/tablet
  static const double calendarCell = 12;

  /// Month calendar day cell, wide
  static const double calendarCellWide = 11;

  /// Selected segment inside a segmented control
  static const double segment = 12;

  /// Habit icon tile (44px), icon buttons, settings row icons
  static const double chip = 14;

  /// Text fields, segmented track, icon-picker cells, secondary buttons
  static const double field = 16;

  /// Primary 56px buttons
  static const double button = 18;

  /// Habit cards, list rows, toast
  static const double card = 20;

  /// Progress card, Details sections, Settings groups on phone
  static const double sectionPhone = 24;

  /// Progress card and sections on tablet/wide
  static const double sectionTablet = 28;

  /// Dialogs and the top corners of bottom sheets
  static const double dialog = 28;

  /// Milestone celebration card
  static const double milestone = 32;

  /// Active indicator behind the selected nav item
  static const double navPill = 16;

  /// Check button (52px circle), color swatches, progress dots, pills
  static const double full = 999;

  /// Section/progress-card radius for the current layout (24 phone, 28 tablet and wide).
  static double section(AtharLayout layout) =>
      layout == AtharLayout.phone ? sectionPhone : sectionTablet;

  static const BorderRadius cardRadius = BorderRadius.all(
    Radius.circular(card),
  );
  static const BorderRadius buttonRadius = BorderRadius.all(
    Radius.circular(button),
  );
  static const BorderRadius fieldRadius = BorderRadius.all(
    Radius.circular(field),
  );
  static const BorderRadius chipRadius = BorderRadius.all(
    Radius.circular(chip),
  );
  static const BorderRadius dialogRadius = BorderRadius.all(
    Radius.circular(dialog),
  );
  static const BorderRadius sheetRadius = BorderRadius.vertical(
    top: Radius.circular(dialog),
  );
}

/// Fixed component sizes.
abstract final class AtharSizes {
  static const double minTapTarget = 48;
  static const double checkButton = 52;
  static const double checkButtonWide = 48;
  static const double iconTile = 44;
  static const double iconTileTablet = 48;
  static const double iconTileDetails = 56;
  static const double habitCardMinHeight = 72;
  static const double buttonHeight = 56;
  static const double fieldHeight = 56;
  static const double colorSwatch = 40;
  static const double iconPickerCell = 56;
  static const double navBarHeight = 84;
  static const double railWidth = 88;
  static const double wideListWidth = 380;
  static const double ringPhone = 96;
  static const double ringTablet = 120;
  static const double ringWideList = 64;
  static const double ringStrokeRatio = 0.104;
  static const double heatmapCellPhone = 14;
  static const double heatmapCellLarge = 18;
  static const double heatmapGapPhone = 3;
  static const double heatmapGapLarge = 4;
  static const double gutterPhone = 20;
  static const double gutterTablet = 32;
  static const double gutterWide = 32;
  static const double dialogMaxWidth = 400;
  static const double sheetMaxWidth = 520;
}

/// Elevation as soft shadows (the design does not use Material tonal elevation).
abstract final class AtharShadows {
  static const List<BoxShadow> cardLight = [
    BoxShadow(
      offset: Offset(0, 1),
      blurRadius: 2,
      spreadRadius: 0,
      color: Color(0x0D13201C),
    ),
    BoxShadow(
      offset: Offset(0, 6),
      blurRadius: 18,
      spreadRadius: 0,
      color: Color(0x0F13201C),
    ),
  ];
  static const List<BoxShadow> cardDark = [
    BoxShadow(
      offset: Offset(0, 1),
      blurRadius: 2,
      spreadRadius: 0,
      color: Color(0x4D000000),
    ),
    BoxShadow(
      offset: Offset(0, 6),
      blurRadius: 18,
      spreadRadius: 0,
      color: Color(0x33000000),
    ),
  ];
  static const List<BoxShadow> raisedLight = [
    BoxShadow(
      offset: Offset(0, 24),
      blurRadius: 60,
      spreadRadius: 0,
      color: Color(0x2E000000),
    ),
  ];
  static const List<BoxShadow> raisedDark = [
    BoxShadow(
      offset: Offset(0, 24),
      blurRadius: 60,
      spreadRadius: 0,
      color: Color(0x4D000000),
    ),
  ];
  static const List<BoxShadow> toastLight = [
    BoxShadow(
      offset: Offset(0, 12),
      blurRadius: 28,
      spreadRadius: -6,
      color: Color(0x40000000),
    ),
  ];
  static const List<BoxShadow> toastDark = [
    BoxShadow(
      offset: Offset(0, 12),
      blurRadius: 28,
      spreadRadius: -6,
      color: Color(0x66000000),
    ),
  ];

  static List<BoxShadow> card(Brightness b) =>
      b == Brightness.dark ? cardDark : cardLight;
  static List<BoxShadow> raised(Brightness b) =>
      b == Brightness.dark ? raisedDark : raisedLight;
  static List<BoxShadow> toast(Brightness b) =>
      b == Brightness.dark ? toastDark : toastLight;
}

enum AtharLayout { phone, tablet, wide }

/// Responsive breakpoints: phone < 600, tablet 600-1024, wide > 1024 (logical px of the window width).
abstract final class AtharBreakpoints {
  static const double tablet = 600;
  static const double wide = 1024;

  static AtharLayout of(double width) {
    if (width > wide) return AtharLayout.wide;
    if (width >= tablet) return AtharLayout.tablet;
    return AtharLayout.phone;
  }
}

/// Motion tokens. Respect MediaQuery.disableAnimationsOf(context): use Duration.zero when true.
abstract final class AtharMotion {
  /// Check button scales 0.82 -> 1.0 when a habit is checked; HapticFeedback.lightImpact()
  static const Duration checkPop = Duration(milliseconds: 500);
  static const Curve checkPopCurve = Curves.easeOutBack;

  /// Progress ring sweeps from its old to its new value
  static const Duration ringProgress = Duration(milliseconds: 1400);
  static const Curve ringProgressCurve = Curves.easeOutCubic;

  /// Habit card slides 144px toward the start edge to reveal Edit/Delete
  static const Duration swipeReveal = Duration(milliseconds: 350);
  static const Curve swipeRevealCurve = Curves.fastOutSlowIn;

  /// Toast slides up 16px + fades in; stays 3000ms
  static const Duration toastIn = Duration(milliseconds: 250);
  static const Curve toastInCurve = Curves.easeOutCubic;

  /// Toast fades out
  static const Duration toastOut = Duration(milliseconds: 200);
  static const Curve toastOutCurve = Curves.easeInCubic;

  /// Dialogs/milestone card fade in and scale 0.92 -> 1.0
  static const Duration dialogIn = Duration(milliseconds: 350);
  static const Curve dialogInCurve = Curves.easeOutBack;

  /// Bottom sheets slide up
  static const Duration sheetIn = Duration(milliseconds: 300);
  static const Curve sheetInCurve = Curves.easeOutCubic;

  /// Push/pop: horizontal slide that follows text direction (Cupertino-style); fade-through between nav tabs
  static const Duration pageTransition = Duration(milliseconds: 300);
  static const Curve pageTransitionCurve = Curves.easeInOutCubic;

  /// Delay between each dot filling in the milestone ring (each dot pops in 500ms)
  static const Duration milestoneDotStagger = Duration(milliseconds: 90);
  static const Curve milestoneDotStaggerCurve = Curves.easeOutBack;

  /// Confetti fall duration per piece (2.6-4.2s randomised), 36 pieces, loops while the modal is open
  static const Duration confetti = Duration(milliseconds: 3200);
  static const Curve confettiCurve = Curves.linear;

  /// PageView slide between onboarding slides; indicator pill widens 8 -> 24px
  static const Duration onboardingPage = Duration(milliseconds: 350);
  static const Curve onboardingPageCurve = Curves.easeOutCubic;
}
