import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants/athar_assets.dart';
import '../services/notification_service.dart';
import '../theme/athar_colors.dart';
import '../theme/athar_spacing.dart';
import '../theme/athar_typography.dart';
import '../widgets/athar_bottom_sheet.dart';
import 'notification_metrics.dart';
import 'notification_permission_cubit.dart';

/// Call before turning a reminder on. While notifications were never asked
/// for, explains them first (design/screens.md · 09 prompt) and then shows
/// the system prompt. Returns false only when the user chose "Not now" (the
/// reminder stays off); a refusal in the system prompt still returns true,
/// and the blocked banner explains it.
Future<bool> allowReminders(BuildContext context) async {
  final permissions = context.read<NotificationPermissionCubit>();
  await permissions.refresh();
  if (permissions.state != NotificationPermission.notDetermined) return true;
  if (!context.mounted) return false;
  final allow = await showNotificationPromptSheet(context);
  if (!allow) return false;
  await permissions.request();
  return true;
}

/// The pre-permission sheet. Resolves to true for "Allow reminders".
Future<bool> showNotificationPromptSheet(BuildContext context) async =>
    await showAtharBottomSheet<bool>(
      context,
      builder: (context) => const _NotificationPrompt(),
    ) ??
    false;

class _NotificationPrompt extends StatelessWidget {
  const _NotificationPrompt();

  @override
  Widget build(BuildContext context) {
    final colors = AtharColors.of(context);
    final text = AtharTextStyles.forLocale(context.locale);
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: SvgPicture.asset(
              AtharAssets.notificationBell(Theme.of(context).brightness),
              width: NotificationMetrics.bellSize,
              height: NotificationMetrics.bellSize,
              excludeFromSemantics: true,
            ),
          ),
          const SizedBox(height: NotificationMetrics.titleTop),
          Semantics(
            header: true,
            child: Text(
              context.tr('reminders.prompt.title'),
              textAlign: TextAlign.center,
              style: text.emptyTitle.copyWith(color: colors.textPrimary),
            ),
          ),
          const SizedBox(height: NotificationMetrics.bodyTop),
          Text(
            context.tr('reminders.prompt.body'),
            textAlign: TextAlign.center,
            style: text.bodySmall.copyWith(
              fontSize: NotificationMetrics.bodySize,
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: NotificationMetrics.actionsTop),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(context.tr('reminders.prompt.allow')),
          ),
          const SizedBox(height: NotificationMetrics.notNowTop),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(
              minimumSize: const Size.fromHeight(AtharSizes.minTapTarget),
              foregroundColor: colors.primary,
              textStyle: text.buttonSmall,
            ),
            child: Text(context.tr('reminders.prompt.notNow')),
          ),
        ],
      ),
    );
  }
}
