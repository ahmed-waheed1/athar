// GENERATED from the Athar design tokens (design-tokens.json).
// Font: bundle Cairo 400/500/600/700 and declare it in pubspec.yaml as family "Cairo".
// Colors are not baked in: styles inherit from DefaultTextStyle / the theme. Apply color with .copyWith(color: ...).
import 'package:flutter/material.dart';

/// Cairo has tall built-in line metrics; spread the extra leading evenly so text centres in buttons and chips.
const TextHeightBehavior atharTextHeightBehavior = TextHeightBehavior(
  leadingDistribution: TextLeadingDistribution.even,
);

@immutable
class AtharTextStyles {
  const AtharTextStyles._({
    required this.displayStreak,
    required this.milestoneNumber,
    required this.screenTitle,
    required this.greeting,
    required this.emptyTitle,
    required this.ringValue,
    required this.statNumber,
    required this.appBarTitle,
    required this.progressTitle,
    required this.sectionTitle,
    required this.button,
    required this.cardTitle,
    required this.body,
    required this.buttonSmall,
    required this.toast,
    required this.bodySmall,
    required this.dateLabel,
    required this.fieldLabel,
    required this.calendarDay,
    required this.caption,
    required this.statLabel,
    required this.label,
    required this.calendarWeekday,
  });

  /// Current-streak number on Habit Details. 72px / w700. Arabic line height 1.2 vs Latin 1.05.
  final TextStyle displayStreak;

  /// Number inside the milestone celebration ring. 56px / w700. Arabic line height 1.15 vs Latin 1.0.
  final TextStyle milestoneNumber;

  /// Tab-screen titles (Settings), onboarding titles. 28px / w700. Arabic line height 1.5 vs Latin 1.3.
  final TextStyle screenTitle;

  /// Home greeting; dialog/milestone titles. 26px / w700. Arabic line height 1.5 vs Latin 1.3.
  final TextStyle greeting;

  /// Empty-state and permission-prompt titles; habit name on Details. 24px / w700. Arabic line height 1.5 vs Latin 1.3.
  final TextStyle emptyTitle;

  /// Value inside the Today progress ring (3/5). 24px / w700. Arabic line height 1.25 vs Latin 1.1.
  final TextStyle ringValue;

  /// Best streak / completions / consistency numbers. 24px / w700. Arabic line height 1.35 vs Latin 1.2.
  final TextStyle statNumber;

  /// App bar titles (New habit, Edit habit). 20px / w700. Arabic line height 1.55 vs Latin 1.35.
  final TextStyle appBarTitle;

  /// '3 of 5 done today' on the progress card. 18px / w700. Arabic line height 1.55 vs Latin 1.35.
  final TextStyle progressTitle;

  /// Section headers (Today's habits). 17px / w700. Arabic line height 1.6 vs Latin 1.4.
  final TextStyle sectionTitle;

  /// Primary 56px buttons. 17px / w700. Arabic line height 1.45 vs Latin 1.3.
  final TextStyle button;

  /// Habit name on cards, card headings (Last 18 weeks). 16px / w700. Arabic line height 1.6 vs Latin 1.4.
  final TextStyle cardTitle;

  /// Body copy, onboarding text, field input. 16px / w400. Arabic line height 1.65 vs Latin 1.45.
  final TextStyle body;

  /// Segmented control, outline/text buttons, list-row titles. 15px / w700. Arabic line height 1.45 vs Latin 1.3.
  final TextStyle buttonSmall;

  /// Snackbar text. 15px / w600. Arabic line height 1.55 vs Latin 1.35.
  final TextStyle toast;

  /// Supporting text, dialog body on compact layouts. 14px / w400. Arabic line height 1.65 vs Latin 1.45.
  final TextStyle bodySmall;

  /// Date line above the greeting, habit meta line. 14px / w500. Arabic line height 1.6 vs Latin 1.4.
  final TextStyle dateLabel;

  /// Form labels, settings section headers. 14px / w700. Arabic line height 1.6 vs Latin 1.4.
  final TextStyle fieldLabel;

  /// Day numbers in month calendar (future days use w500). 14px / w700.
  final TextStyle calendarDay;

  /// Streak label next to the flame, helper/error text. 13px / w600. Arabic line height 1.6 vs Latin 1.4.
  final TextStyle caption;

  /// Labels under stat numbers. 12.5px / w600. Arabic line height 1.55 vs Latin 1.35.
  final TextStyle statLabel;

  /// Nav labels, legends, chips. 12px / w600. Arabic line height 1.55 vs Latin 1.35.
  final TextStyle label;

  /// Weekday header row in the calendar. 12px / w700.
  final TextStyle calendarWeekday;

  static const String fontFamily = 'Cairo';

  /// Pick by locale: Arabic needs taller line heights and no negative tracking.
  static AtharTextStyles forLocale(Locale locale) =>
      locale.languageCode == 'ar' ? arabic : latin;

  static const latin = AtharTextStyles._(
    displayStreak: TextStyle(
      fontFamily: fontFamily,
      fontSize: 72,
      fontWeight: FontWeight.w700,
      height: 1.05,
      leadingDistribution: TextLeadingDistribution.even,
      letterSpacing: -1.4,
    ),
    milestoneNumber: TextStyle(
      fontFamily: fontFamily,
      fontSize: 56,
      fontWeight: FontWeight.w700,
      height: 1,
      leadingDistribution: TextLeadingDistribution.even,
      letterSpacing: -1,
    ),
    screenTitle: TextStyle(
      fontFamily: fontFamily,
      fontSize: 28,
      fontWeight: FontWeight.w700,
      height: 1.3,
      leadingDistribution: TextLeadingDistribution.even,
      letterSpacing: -0.3,
    ),
    greeting: TextStyle(
      fontFamily: fontFamily,
      fontSize: 26,
      fontWeight: FontWeight.w700,
      height: 1.3,
      leadingDistribution: TextLeadingDistribution.even,
      letterSpacing: -0.2,
    ),
    emptyTitle: TextStyle(
      fontFamily: fontFamily,
      fontSize: 24,
      fontWeight: FontWeight.w700,
      height: 1.3,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    ringValue: TextStyle(
      fontFamily: fontFamily,
      fontSize: 24,
      fontWeight: FontWeight.w700,
      height: 1.1,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    statNumber: TextStyle(
      fontFamily: fontFamily,
      fontSize: 24,
      fontWeight: FontWeight.w700,
      height: 1.2,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    appBarTitle: TextStyle(
      fontFamily: fontFamily,
      fontSize: 20,
      fontWeight: FontWeight.w700,
      height: 1.35,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    progressTitle: TextStyle(
      fontFamily: fontFamily,
      fontSize: 18,
      fontWeight: FontWeight.w700,
      height: 1.35,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    sectionTitle: TextStyle(
      fontFamily: fontFamily,
      fontSize: 17,
      fontWeight: FontWeight.w700,
      height: 1.4,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    button: TextStyle(
      fontFamily: fontFamily,
      fontSize: 17,
      fontWeight: FontWeight.w700,
      height: 1.3,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    cardTitle: TextStyle(
      fontFamily: fontFamily,
      fontSize: 16,
      fontWeight: FontWeight.w700,
      height: 1.4,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    body: TextStyle(
      fontFamily: fontFamily,
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.45,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    buttonSmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 15,
      fontWeight: FontWeight.w700,
      height: 1.3,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    toast: TextStyle(
      fontFamily: fontFamily,
      fontSize: 15,
      fontWeight: FontWeight.w600,
      height: 1.35,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    bodySmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.45,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    dateLabel: TextStyle(
      fontFamily: fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 1.4,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    fieldLabel: TextStyle(
      fontFamily: fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w700,
      height: 1.4,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    calendarDay: TextStyle(
      fontFamily: fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w700,
      height: 1,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    caption: TextStyle(
      fontFamily: fontFamily,
      fontSize: 13,
      fontWeight: FontWeight.w600,
      height: 1.4,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    statLabel: TextStyle(
      fontFamily: fontFamily,
      fontSize: 12.5,
      fontWeight: FontWeight.w600,
      height: 1.35,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    label: TextStyle(
      fontFamily: fontFamily,
      fontSize: 12,
      fontWeight: FontWeight.w600,
      height: 1.35,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    calendarWeekday: TextStyle(
      fontFamily: fontFamily,
      fontSize: 12,
      fontWeight: FontWeight.w700,
      height: 1,
      leadingDistribution: TextLeadingDistribution.even,
    ),
  );

  static const arabic = AtharTextStyles._(
    displayStreak: TextStyle(
      fontFamily: fontFamily,
      fontSize: 72,
      fontWeight: FontWeight.w700,
      height: 1.2,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    milestoneNumber: TextStyle(
      fontFamily: fontFamily,
      fontSize: 56,
      fontWeight: FontWeight.w700,
      height: 1.15,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    screenTitle: TextStyle(
      fontFamily: fontFamily,
      fontSize: 28,
      fontWeight: FontWeight.w700,
      height: 1.5,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    greeting: TextStyle(
      fontFamily: fontFamily,
      fontSize: 26,
      fontWeight: FontWeight.w700,
      height: 1.5,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    emptyTitle: TextStyle(
      fontFamily: fontFamily,
      fontSize: 24,
      fontWeight: FontWeight.w700,
      height: 1.5,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    ringValue: TextStyle(
      fontFamily: fontFamily,
      fontSize: 24,
      fontWeight: FontWeight.w700,
      height: 1.25,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    statNumber: TextStyle(
      fontFamily: fontFamily,
      fontSize: 24,
      fontWeight: FontWeight.w700,
      height: 1.35,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    appBarTitle: TextStyle(
      fontFamily: fontFamily,
      fontSize: 20,
      fontWeight: FontWeight.w700,
      height: 1.55,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    progressTitle: TextStyle(
      fontFamily: fontFamily,
      fontSize: 18,
      fontWeight: FontWeight.w700,
      height: 1.55,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    sectionTitle: TextStyle(
      fontFamily: fontFamily,
      fontSize: 17,
      fontWeight: FontWeight.w700,
      height: 1.6,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    button: TextStyle(
      fontFamily: fontFamily,
      fontSize: 17,
      fontWeight: FontWeight.w700,
      height: 1.45,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    cardTitle: TextStyle(
      fontFamily: fontFamily,
      fontSize: 16,
      fontWeight: FontWeight.w700,
      height: 1.6,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    body: TextStyle(
      fontFamily: fontFamily,
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.65,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    buttonSmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 15,
      fontWeight: FontWeight.w700,
      height: 1.45,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    toast: TextStyle(
      fontFamily: fontFamily,
      fontSize: 15,
      fontWeight: FontWeight.w600,
      height: 1.55,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    bodySmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.65,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    dateLabel: TextStyle(
      fontFamily: fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 1.6,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    fieldLabel: TextStyle(
      fontFamily: fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w700,
      height: 1.6,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    calendarDay: TextStyle(
      fontFamily: fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w700,
      height: 1,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    caption: TextStyle(
      fontFamily: fontFamily,
      fontSize: 13,
      fontWeight: FontWeight.w600,
      height: 1.6,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    statLabel: TextStyle(
      fontFamily: fontFamily,
      fontSize: 12.5,
      fontWeight: FontWeight.w600,
      height: 1.55,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    label: TextStyle(
      fontFamily: fontFamily,
      fontSize: 12,
      fontWeight: FontWeight.w600,
      height: 1.55,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    calendarWeekday: TextStyle(
      fontFamily: fontFamily,
      fontSize: 12,
      fontWeight: FontWeight.w700,
      height: 1,
      leadingDistribution: TextLeadingDistribution.even,
    ),
  );

  /// Maps the Athar styles onto Material roles so stock widgets pick them up.
  TextTheme toTextTheme() => TextTheme(
    displayLarge: displayStreak,
    displayMedium: milestoneNumber,
    headlineLarge: screenTitle,
    headlineMedium: greeting,
    headlineSmall: emptyTitle,
    titleLarge: appBarTitle,
    titleMedium: cardTitle,
    titleSmall: buttonSmall,
    bodyLarge: body,
    bodyMedium: bodySmall,
    bodySmall: caption,
    labelLarge: button,
    labelMedium: caption,
    labelSmall: label,
  );
}
