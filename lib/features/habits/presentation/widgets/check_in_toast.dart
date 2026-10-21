import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/athar_colors.dart';
import '../../../../core/theme/athar_spacing.dart';
import '../../../../core/theme/athar_typography.dart';
import '../../../../core/utils/localized_numbers.dart';
import '../../../../core/utils/motion.dart';
import '../../../../core/widgets/athar_icon.dart';
import 'home_metrics.dart';

/// "Trace added · 6-day streak" with Undo (design/screens.md · 04). A new
/// check-in replaces the toast on screen.
void showCheckInToast(
  BuildContext context, {
  required int streak,
  required VoidCallback onUndo,
}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.removeCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      content: _CheckInToast(
        message: context.plural(
          'toast.checkIn',
          streak,
          format: LocalizedNumbers.formatter(context.locale),
        ),
        onUndo: () {
          messenger.hideCurrentSnackBar();
          onUndo();
        },
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      padding: EdgeInsets.zero,
      margin: const EdgeInsetsDirectional.all(HomeMetrics.toastMargin),
      behavior: SnackBarBehavior.floating,
      duration: HomeMetrics.toastVisible,
    ),
    snackBarAnimationStyle: AnimationStyle(
      duration: motionDuration(context, AtharMotion.toastIn),
      reverseDuration: motionDuration(context, AtharMotion.toastOut),
      curve: AtharMotion.toastInCurve,
      reverseCurve: AtharMotion.toastOutCurve,
    ),
  );
}

class _CheckInToast extends StatelessWidget {
  const _CheckInToast({required this.message, required this.onUndo});

  final String message;
  final VoidCallback onUndo;

  @override
  Widget build(BuildContext context) {
    final colors = AtharColors.of(context);
    final text = AtharTextStyles.forLocale(context.locale);
    final brightness = Theme.of(context).brightness;
    // The toast is an inverse surface, so its flame tile and action use the
    // opposite theme's colors.
    final inverse = brightness == Brightness.light
        ? AtharColors.dark
        : AtharColors.light;

    return Container(
      padding: const EdgeInsetsDirectional.symmetric(
        vertical: HomeMetrics.toastPaddingV,
        horizontal: HomeMetrics.toastPaddingH,
      ),
      decoration: BoxDecoration(
        color: colors.inverseSurface,
        borderRadius: AtharRadii.cardRadius,
        boxShadow: AtharShadows.toast(brightness),
      ),
      child: Row(
        children: [
          Container(
            width: HomeMetrics.toastTile,
            height: HomeMetrics.toastTile,
            decoration: BoxDecoration(
              color: inverse.flameSoft,
              borderRadius: BorderRadius.circular(HomeMetrics.toastTileRadius),
            ),
            alignment: AlignmentDirectional.center,
            child: AtharIcon.ui(
              'flame',
              size: HomeMetrics.toastFlame,
              color: inverse.flame,
            ),
          ),
          const SizedBox(width: AtharSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: text.toast.copyWith(color: colors.onInverseSurface),
            ),
          ),
          TextButton(
            onPressed: onUndo,
            style: TextButton.styleFrom(
              minimumSize: const Size(
                AtharSizes.minTapTarget,
                AtharSizes.minTapTarget,
              ),
              foregroundColor: inverse.primary,
              textStyle: text.buttonSmall,
            ),
            child: Text(context.tr('toast.undo')),
          ),
        ],
      ),
    );
  }
}
