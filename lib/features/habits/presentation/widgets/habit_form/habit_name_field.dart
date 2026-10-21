import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/theme/athar_colors.dart';
import '../../../../../core/theme/athar_typography.dart';
import '../../../../../core/utils/localized_numbers.dart';
import '../../../../../core/utils/motion.dart';
import '../../../../../core/widgets/athar_icon.dart';
import '../../../domain/entities/habit_name.dart';
import 'habit_form_metrics.dart';

/// Label row with the live counter, the name field, and its error. Shakes
/// whenever [shakeTrigger] changes.
class HabitNameField extends StatefulWidget {
  const HabitNameField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.length,
    required this.error,
    required this.shakeTrigger,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;

  /// Graphemes in the normalized name.
  final int length;
  final HabitNameError? error;
  final int shakeTrigger;
  final ValueChanged<String> onChanged;

  @override
  State<HabitNameField> createState() => _HabitNameFieldState();
}

class _HabitNameFieldState extends State<HabitNameField>
    with SingleTickerProviderStateMixin {
  late final _shake = AnimationController(
    vsync: this,
    duration: HabitFormMetrics.shakeDuration,
  );

  @override
  void didUpdateWidget(HabitNameField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shakeTrigger != oldWidget.shakeTrigger) {
      _shake.duration = motionDuration(context, HabitFormMetrics.shakeDuration);
      _shake.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _shake.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AtharColors.of(context);
    final text = AtharTextStyles.forLocale(context.locale);
    final numbers = LocalizedNumbers.formatter(context.locale);
    final inputTheme = Theme.of(context).inputDecorationTheme;
    final error = widget.error;
    final hasError = error != null;
    final isTooLong = error == HabitNameError.tooLong;

    final errorText = switch (error) {
      null => null,
      HabitNameError.empty => context.tr('habitForm.name.errorEmpty'),
      HabitNameError.tooLong => context.plural(
        'habitForm.name.errorTooLong',
        HabitName.maxLength,
        format: numbers,
      ),
    };

    return AnimatedBuilder(
      animation: _shake,
      builder: (context, child) {
        final t = _shake.value;
        final dx = _shake.isAnimating
            ? math.sin(t * HabitFormMetrics.shakeCount * 2 * math.pi) *
                  HabitFormMetrics.shakeOffset
            : 0.0;
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  context.tr('habitForm.name.label'),
                  style: text.fieldLabel.copyWith(
                    color: hasError ? colors.error : colors.textSecondary,
                  ),
                ),
              ),
              Text(
                context.tr(
                  'habitForm.name.counter',
                  namedArgs: {
                    'count': numbers.format(widget.length),
                    'max': numbers.format(HabitName.maxLength),
                  },
                ),
                style: text.caption.copyWith(
                  color: isTooLong ? colors.error : colors.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: HabitFormMetrics.labelGap),
          TextField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            onChanged: widget.onChanged,
            onTapOutside: (_) => widget.focusNode.unfocus(),
            minLines: 1,
            maxLines: HabitFormMetrics.nameMaxLines,
            textInputAction: TextInputAction.done,
            textCapitalization: TextCapitalization.sentences,
            // A name is one line, even when pasted.
            inputFormatters: [
              FilteringTextInputFormatter.deny(
                RegExp(r'[\r\n]+'),
                replacementString: ' ',
              ),
            ],
            style: text.body.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: context.tr('habitForm.name.hint'),
              enabledBorder: hasError ? inputTheme.errorBorder : null,
              focusedBorder: hasError ? inputTheme.focusedErrorBorder : null,
            ),
          ),
          if (errorText != null) ...[
            const SizedBox(height: HabitFormMetrics.errorGap),
            Semantics(
              liveRegion: true,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                      top: HabitFormMetrics.errorIconTop,
                    ),
                    child: AtharIcon.ui(
                      'warn',
                      size: HabitFormMetrics.errorIcon,
                      color: colors.error,
                    ),
                  ),
                  const SizedBox(width: HabitFormMetrics.errorIconGap),
                  Expanded(
                    child: Text(
                      errorText,
                      style: text.caption.copyWith(color: colors.error),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
