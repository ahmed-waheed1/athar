import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../theme/athar_colors.dart';
import '../theme/athar_spacing.dart';
import '../theme/athar_typography.dart';
import '../utils/motion.dart';

/// Sizes of the shared modal sheet (design/screens.md · 05, 09).
abstract final class _SheetMetrics {
  static const double paddingTop = AtharSpacing.sm;
  static const double paddingH = AtharSpacing.xl;
  static const double paddingBottom = AtharSpacing.xxl;
  static const double handleWidth = 36;
  static const double handleHeight = 4;
  static const double titleTop = AtharSpacing.lg;
  static const double contentTop = AtharSpacing.md;
}

/// A modal bottom sheet in the Athar style: radius 28 at the top, a drag
/// handle, an optional title, and at most [AtharSizes.sheetMaxWidth] wide.
Future<T?> showAtharBottomSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  String? title,
}) {
  final colors = AtharColors.of(context);
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: colors.surface,
    barrierColor: colors.scrim,
    shape: const RoundedRectangleBorder(borderRadius: AtharRadii.sheetRadius),
    constraints: const BoxConstraints(maxWidth: AtharSizes.sheetMaxWidth),
    sheetAnimationStyle: AnimationStyle(
      duration: motionDuration(context, AtharMotion.sheetIn),
      curve: AtharMotion.sheetInCurve,
    ),
    builder: (context) => _SheetFrame(title: title, child: builder(context)),
  );
}

class _SheetFrame extends StatelessWidget {
  const _SheetFrame({required this.title, required this.child});

  final String? title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = AtharColors.of(context);
    final text = AtharTextStyles.forLocale(context.locale);
    final title = this.title;
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(
        _SheetMetrics.paddingH,
        _SheetMetrics.paddingTop,
        _SheetMetrics.paddingH,
        _SheetMetrics.paddingBottom + MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: _SheetMetrics.handleWidth,
              height: _SheetMetrics.handleHeight,
              decoration: BoxDecoration(
                color: colors.divider,
                borderRadius: BorderRadius.circular(AtharRadii.full),
              ),
            ),
          ),
          if (title != null) ...[
            const SizedBox(height: _SheetMetrics.titleTop),
            Semantics(
              header: true,
              child: Text(
                title,
                style: text.appBarTitle.copyWith(color: colors.textPrimary),
              ),
            ),
          ],
          const SizedBox(height: _SheetMetrics.contentTop),
          Flexible(child: child),
        ],
      ),
    );
  }
}
