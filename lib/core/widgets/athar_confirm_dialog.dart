import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../theme/athar_colors.dart';
import '../theme/athar_spacing.dart';
import '../theme/athar_typography.dart';
import '../utils/motion.dart';
import 'athar_icon.dart';

/// Sizes of the shared destructive dialog (design/screens.md · Dialogs).
abstract final class _DialogMetrics {
  static const double padding = AtharSpacing.xl;
  static const double gap = AtharSpacing.sm;
  static const double iconTile = AtharSizes.iconTileDetails;
  static const double iconTileRadius = AtharRadii.button;
  static const double icon = 28;
  static const double titleSize = 22;
  static const double buttonHeight = 52;
  static const double buttonGap = AtharSpacing.sm;
  static const double actionsTop = AtharSpacing.xl;
  static const double scaleFrom = 0.92;
}

/// Destructive confirmation (delete habit, reset data). Resolves to true when
/// the destructive action was chosen.
Future<bool> showAtharConfirmDialog(
  BuildContext context, {
  required String iconName,
  required String title,
  required String body,
  required String cancelLabel,
  required String confirmLabel,
}) async {
  final colors = AtharColors.of(context);
  final confirmed = await showGeneralDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: colors.scrim,
    transitionDuration: motionDuration(context, AtharMotion.dialogIn),
    pageBuilder: (context, _, _) => _ConfirmDialog(
      iconName: iconName,
      title: title,
      body: body,
      cancelLabel: cancelLabel,
      confirmLabel: confirmLabel,
    ),
    transitionBuilder: (context, animation, _, child) {
      final scale = CurvedAnimation(
        parent: animation,
        curve: AtharMotion.dialogInCurve,
      );
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: ScaleTransition(
          scale: Tween(
            begin: _DialogMetrics.scaleFrom,
            end: 1.0,
          ).animate(scale),
          child: child,
        ),
      );
    },
  );
  return confirmed ?? false;
}

class _ConfirmDialog extends StatelessWidget {
  const _ConfirmDialog({
    required this.iconName,
    required this.title,
    required this.body,
    required this.cancelLabel,
    required this.confirmLabel,
  });

  final String iconName;
  final String title;
  final String body;
  final String cancelLabel;
  final String confirmLabel;

  @override
  Widget build(BuildContext context) {
    final colors = AtharColors.of(context);
    final text = AtharTextStyles.forLocale(context.locale);
    final brightness = Theme.of(context).brightness;

    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: AtharSpacing.xl,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AtharSizes.dialogMaxWidth,
            ),
            child: Material(
              type: MaterialType.transparency,
              child: Container(
                padding: const EdgeInsetsDirectional.all(
                  _DialogMetrics.padding,
                ),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: AtharRadii.dialogRadius,
                  boxShadow: AtharShadows.raised(brightness),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: _DialogMetrics.iconTile,
                      height: _DialogMetrics.iconTile,
                      decoration: BoxDecoration(
                        color: colors.errorContainer,
                        borderRadius: BorderRadius.circular(
                          _DialogMetrics.iconTileRadius,
                        ),
                      ),
                      alignment: AlignmentDirectional.center,
                      child: AtharIcon.ui(
                        iconName,
                        size: _DialogMetrics.icon,
                        color: colors.error,
                      ),
                    ),
                    const SizedBox(height: _DialogMetrics.gap * 2),
                    Semantics(
                      header: true,
                      child: Text(
                        title,
                        style: text.emptyTitle.copyWith(
                          fontSize: _DialogMetrics.titleSize,
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: _DialogMetrics.gap),
                    Text(
                      body,
                      style: text.bodySmall.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: _DialogMetrics.actionsTop),
                    Row(
                      children: [
                        Expanded(
                          child: _DialogButton(
                            label: cancelLabel,
                            background: colors.surfaceVariant,
                            foreground: colors.textPrimary,
                            onPressed: () => Navigator.of(context).pop(false),
                          ),
                        ),
                        const SizedBox(width: _DialogMetrics.buttonGap),
                        Expanded(
                          child: _DialogButton(
                            label: confirmLabel,
                            background: colors.error,
                            foreground: colors.onError,
                            onPressed: () => Navigator.of(context).pop(true),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DialogButton extends StatelessWidget {
  const _DialogButton({
    required this.label,
    required this.background,
    required this.foreground,
    required this.onPressed,
  });

  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final text = AtharTextStyles.forLocale(context.locale);
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(_DialogMetrics.buttonHeight),
        backgroundColor: background,
        foregroundColor: foreground,
        shape: const RoundedRectangleBorder(
          borderRadius: AtharRadii.fieldRadius,
        ),
        textStyle: text.button,
      ),
      child: Text(label),
    );
  }
}
