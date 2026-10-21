import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/notifications/notification_metrics.dart';
import '../../../../core/notifications/notification_permission_cubit.dart';
import '../../../../core/notifications/notification_prompt_sheet.dart';
import '../../../../core/notifications/notifications_blocked_banner.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/theme/athar_colors.dart';
import '../../../../core/theme/athar_spacing.dart';
import '../../../../core/theme/athar_typography.dart';
import '../../../../core/utils/localized_numbers.dart';
import '../../../../core/widgets/athar_confirm_dialog.dart';
import '../../../../core/widgets/athar_icon.dart';
import '../../domain/entities/app_version.dart';
import '../cubit/reset_data_cubit.dart';
import '../widgets/settings_controls.dart';
import '../widgets/settings_metrics.dart';

/// Settings (design/screens.md · 08): language, appearance, reminders, your
/// data and the app version. Needs a [NotificationPermissionCubit] above it.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.version});

  final AppVersion version;

  Future<void> _confirmReset(BuildContext context) async {
    final cubit = context.read<ResetDataCubit>();
    final summary = await cubit.summary();
    if (!context.mounted) return;
    if (summary == null) return _showResetFailed(context);

    final numbers = LocalizedNumbers.formatter(context.locale);
    final body = summary.habits == 0
        ? context.tr('settings.reset.bodyEmpty')
        : context.tr(
            'settings.reset.body',
            namedArgs: {
              'habits': context.plural(
                'settings.reset.habits',
                summary.habits,
                format: numbers,
              ),
              'traces': context.plural(
                'settings.reset.traces',
                summary.traces,
                format: numbers,
              ),
            },
          );
    final confirmed = await showAtharConfirmDialog(
      context,
      iconName: 'trash',
      title: context.tr('settings.reset.title'),
      body: body,
      cancelLabel: context.tr('settings.reset.cancel'),
      confirmLabel: context.tr('settings.reset.confirm'),
    );
    if (confirmed) await cubit.reset();
  }

  void _showResetFailed(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(context.tr('settings.reset.failed')),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AtharColors.of(context);
    final text = AtharTextStyles.forLocale(context.locale);
    final layout = AtharBreakpoints.of(MediaQuery.sizeOf(context).width);
    final top = MediaQuery.paddingOf(context).top;

    return BlocListener<ResetDataCubit, ResetDataStatus>(
      listener: (context, status) {
        switch (status) {
          case ResetDataStatus.done:
            // Home reloads by itself and shows its empty state.
            context.go(AppRoutes.home);
          case ResetDataStatus.failure:
            _showResetFailed(context);
          case ResetDataStatus.idle || ResetDataStatus.resetting:
            break;
        }
      },
      child: Align(
        alignment: AlignmentDirectional.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: SettingsMetrics.maxContentWidth,
          ),
          child: ListView(
            padding: EdgeInsetsDirectional.fromSTEB(
              AtharSpacing.gutter(layout),
              top + SettingsMetrics.topPadding,
              AtharSpacing.gutter(layout),
              AtharSpacing.xxl,
            ),
            children: [
              Semantics(
                header: true,
                child: Text(
                  context.tr('settings.title'),
                  style: text.screenTitle.copyWith(color: colors.textPrimary),
                ),
              ),
              const SizedBox(height: SettingsMetrics.sectionGap),
              _SectionLabel(context.tr('settings.language')),
              const LanguageControl(),
              const SizedBox(height: SettingsMetrics.sectionGap),
              _SectionLabel(context.tr('settings.appearance')),
              const ThemeModeControl(),
              const SizedBox(height: SettingsMetrics.sectionGap),
              _SectionLabel(context.tr('settings.preferences')),
              const _Group(children: [_RemindersRow()]),
              const SizedBox(height: SettingsMetrics.sectionGap),
              _SectionLabel(context.tr('settings.yourData')),
              _Group(
                children: [
                  _SettingsRow(
                    iconName: 'lock',
                    iconColor: colors.textSecondary,
                    iconBackground: colors.surfaceVariant,
                    title: Text(
                      context.tr('settings.localOnly'),
                      style: text.body.copyWith(color: colors.textSecondary),
                    ),
                  ),
                  _SettingsRow(
                    iconName: 'trash',
                    iconColor: colors.error,
                    iconBackground: colors.errorContainer,
                    title: Text(
                      context.tr('settings.reset.row'),
                      style: text.buttonSmall.copyWith(color: colors.error),
                    ),
                    subtitle: context.tr('settings.reset.rowSubtitle'),
                    onTap: () => _confirmReset(context),
                  ),
                ],
              ),
              const SizedBox(height: SettingsMetrics.versionTop),
              Text(
                context.tr(
                  'settings.version',
                  namedArgs: {
                    'version': LocalizedNumbers.digits(
                      version.version,
                      context.locale,
                    ),
                    'build': LocalizedNumbers.digits(
                      version.buildNumber,
                      context.locale,
                    ),
                  },
                ),
                textAlign: TextAlign.center,
                style: text.caption.copyWith(color: colors.textTertiary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = AtharColors.of(context);
    final text = AtharTextStyles.forLocale(context.locale);
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        start: SettingsMetrics.labelInset,
        end: SettingsMetrics.labelInset,
        bottom: SettingsMetrics.labelGap,
      ),
      child: Semantics(
        header: true,
        child: Text(
          label,
          style: text.fieldLabel.copyWith(
            fontSize: SettingsMetrics.labelSize,
            color: colors.textTertiary,
          ),
        ),
      ),
    );
  }
}

/// A settings card: rows separated by inset dividers.
class _Group extends StatelessWidget {
  const _Group({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = AtharColors.of(context);
    return Container(
      padding: const EdgeInsetsDirectional.all(SettingsMetrics.groupPadding),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(SettingsMetrics.groupRadius),
        boxShadow: AtharShadows.card(Theme.of(context).brightness),
      ),
      child: Column(
        children: [
          for (final (index, child) in children.indexed) ...[
            if (index > 0)
              Divider(
                height: 1,
                thickness: 1,
                color: colors.divider,
                indent: SettingsMetrics.dividerInset,
                endIndent: SettingsMetrics.dividerInset,
              ),
            child,
          ],
        ],
      ),
    );
  }
}

/// Reminders: whether the system lets Athar notify (design/screens.md · 08,
/// 09). Only the system can take the permission back, so turning the switch
/// off opens the system settings. When notifications are blocked, the
/// switch is disabled and a banner links to the system settings.
class _RemindersRow extends StatelessWidget {
  const _RemindersRow();

  @override
  Widget build(BuildContext context) {
    final colors = AtharColors.of(context);
    final text = AtharTextStyles.forLocale(context.locale);
    final permissions = context.read<NotificationPermissionCubit>();
    final permission = context.watch<NotificationPermissionCubit>().state;
    final ValueChanged<bool>? onChanged = switch (permission) {
      NotificationPermission.granted => (_) => permissions.openSystemSettings(),
      NotificationPermission.notDetermined => (_) => allowReminders(context),
      NotificationPermission.denied => null,
    };
    final isOn = permission == NotificationPermission.granted;
    final title = context.tr('settings.reminders.title');

    return Column(
      children: [
        _SettingsRow(
          iconName: permission == NotificationPermission.denied
              ? 'bell_off'
              : 'bell',
          iconColor: colors.onPrimaryContainer,
          iconBackground: colors.primaryContainer,
          title: Text(
            title,
            style: text.cardTitle.copyWith(color: colors.textPrimary),
          ),
          subtitle: context.tr(switch (permission) {
            NotificationPermission.granted => 'settings.reminders.on',
            NotificationPermission.notDetermined => 'settings.reminders.off',
            NotificationPermission.denied => 'settings.reminders.blocked',
          }),
          onTap: onChanged == null ? null : () => onChanged(!isOn),
          trailing: Opacity(
            opacity: onChanged == null
                ? NotificationMetrics.disabledSwitchOpacity
                : 1,
            child: Semantics(
              label: title,
              child: Switch(value: isOn, onChanged: onChanged),
            ),
          ),
        ),
        if (permission == NotificationPermission.denied)
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              SettingsMetrics.bannerInset,
              0,
              SettingsMetrics.bannerInset,
              SettingsMetrics.bannerInset,
            ),
            child: NotificationsBlockedBanner(
              onOpenSettings: permissions.openSystemSettings,
            ),
          ),
      ],
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.iconName,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    this.subtitle,
    this.onTap,
    this.trailing,
  });

  final String iconName;
  final Color iconColor;
  final Color iconBackground;
  final Widget title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = AtharColors.of(context);
    final text = AtharTextStyles.forLocale(context.locale);
    final row = ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: SettingsMetrics.rowMinHeight,
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          vertical: SettingsMetrics.rowPaddingV,
          horizontal: SettingsMetrics.rowPaddingH,
        ),
        child: Row(
          children: [
            Container(
              width: SettingsMetrics.rowIconTile,
              height: SettingsMetrics.rowIconTile,
              decoration: BoxDecoration(
                color: iconBackground,
                borderRadius: BorderRadius.circular(
                  SettingsMetrics.rowIconTileRadius,
                ),
              ),
              alignment: AlignmentDirectional.center,
              child: AtharIcon.ui(
                iconName,
                size: SettingsMetrics.rowIcon,
                color: iconColor,
              ),
            ),
            const SizedBox(width: SettingsMetrics.rowGap),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  title,
                  if (subtitle case final subtitle?)
                    Text(
                      subtitle,
                      style: text.bodySmall.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            if (trailing case final trailing?) ...[
              const SizedBox(width: SettingsMetrics.rowGap),
              trailing,
            ],
          ],
        ),
      ),
    );
    if (onTap == null) return row;
    return Semantics(
      button: true,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(
            SettingsMetrics.groupRadius - SettingsMetrics.groupPadding,
          ),
          child: row,
        ),
      ),
    );
  }
}
