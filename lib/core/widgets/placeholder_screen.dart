import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../theme/athar_colors.dart';
import '../theme/athar_spacing.dart';
import '../theme/athar_typography.dart';
import 'athar_icon.dart';

/// Stand-in for screens that are built in a later step.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key, required this.titleKey});

  final String titleKey;

  @override
  Widget build(BuildContext context) {
    final colors = AtharColors.of(context);
    final text = AtharTextStyles.forLocale(context.locale);
    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors.background,
        surfaceTintColor: colors.background,
        automaticallyImplyLeading: false,
        leading: canPop
            ? IconButton(
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                onPressed: () => Navigator.of(context).maybePop(),
                icon: AtharIcon.ui('back', color: colors.textPrimary),
              )
            : null,
        title: Text(
          titleKey.tr(),
          style: text.appBarTitle.copyWith(color: colors.textPrimary),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsetsDirectional.all(AtharSpacing.xl),
          child: Text(
            'placeholder.body'.tr(),
            textAlign: TextAlign.center,
            style: text.body.copyWith(color: colors.textSecondary),
          ),
        ),
      ),
    );
  }
}
