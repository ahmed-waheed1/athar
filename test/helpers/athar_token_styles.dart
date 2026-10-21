import 'package:athar/core/theme/athar_typography.dart';
import 'package:flutter/painting.dart';

/// Every AtharTextStyles style by its name in design-tokens.json.
Map<String, TextStyle> tokenStyles(AtharTextStyles s) => {
  'displayStreak': s.displayStreak,
  'milestoneNumber': s.milestoneNumber,
  'screenTitle': s.screenTitle,
  'greeting': s.greeting,
  'emptyTitle': s.emptyTitle,
  'ringValue': s.ringValue,
  'statNumber': s.statNumber,
  'appBarTitle': s.appBarTitle,
  'progressTitle': s.progressTitle,
  'sectionTitle': s.sectionTitle,
  'button': s.button,
  'cardTitle': s.cardTitle,
  'body': s.body,
  'buttonSmall': s.buttonSmall,
  'toast': s.toast,
  'bodySmall': s.bodySmall,
  'dateLabel': s.dateLabel,
  'fieldLabel': s.fieldLabel,
  'calendarDay': s.calendarDay,
  'caption': s.caption,
  'statLabel': s.statLabel,
  'label': s.label,
  'calendarWeekday': s.calendarWeekday,
};
