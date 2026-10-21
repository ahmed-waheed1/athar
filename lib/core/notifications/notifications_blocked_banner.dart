import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../theme/athar_colors.dart';
import '../theme/athar_typography.dart';
import '../widgets/athar_icon.dart';
import 'notification_metrics.dart';

/// "Notifications are blocked" with a button to the system settings
/// (design/screens.md · 09 denied). Shown in Settings under the Reminders
/// row, and in Add / Edit Habit under the reminder row.
class NotificationsBlockedBanner extends StatelessWidget {
  const NotificationsBlockedBanner({super.key, required this.onOpenSettings});

  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final colors = AtharColors.of(context);
    final text = AtharTextStyles.forLocale(context.locale);
    return Container(
      padding: const EdgeInsetsDirectional.all(
        NotificationMetrics.bannerPadding,
      ),
      decoration: BoxDecoration(
        color: colors.errorContainer,
        borderRadius: BorderRadius.circular(NotificationMetrics.bannerRadius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AtharIcon.ui(
            'warn',
            size: NotificationMetrics.bannerIcon,
            color: colors.error,
          ),
          const SizedBox(width: NotificationMetrics.bannerIconGap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('reminders.blocked.body'),
                  style: text.bodySmall.copyWith(color: colors.textPrimary),
                ),
                const SizedBox(height: NotificationMetrics.bannerButtonTop),
                FilledButton(
                  onPressed: onOpenSettings,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(
                      0,
                      NotificationMetrics.bannerButtonHeight,
                    ),
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: NotificationMetrics.bannerButtonPaddingH,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        NotificationMetrics.bannerButtonRadius,
                      ),
                    ),
                    backgroundColor: colors.surface,
                    foregroundColor: colors.textPrimary,
                    textStyle: text.buttonSmall,
                  ),
                  child: Text(context.tr('reminders.blocked.openSettings')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
