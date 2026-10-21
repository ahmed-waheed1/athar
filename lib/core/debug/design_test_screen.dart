import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../features/settings/presentation/widgets/settings_controls.dart';
import '../constants/athar_assets.dart';
import '../theme/athar_colors.dart';
import '../theme/athar_spacing.dart';
import '../theme/athar_typography.dart';
import '../utils/localized_numbers.dart';
import '../widgets/athar_icon.dart';

/// TEMPORARY: shows the theme, fonts, icons and locale switching. Delete once real screens exist.
/// Token and style names are code identifiers, so they are shown untranslated on purpose.
class DesignTestScreen extends StatelessWidget {
  const DesignTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AtharColors.of(context);
    final text = AtharTextStyles.forLocale(context.locale);

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final layout = AtharBreakpoints.of(constraints.maxWidth);
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AtharSizes.sheetMaxWidth,
                ),
                child: ListView(
                  padding: EdgeInsetsDirectional.symmetric(
                    horizontal: AtharSpacing.gutter(layout),
                    vertical: AtharSpacing.xl,
                  ),
                  children: [
                    Text(
                      'designTest.title'.tr(),
                      style: text.screenTitle.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AtharSpacing.md),
                    const _Section(
                      titleKey: 'designTest.controls',
                      child: _Controls(),
                    ),
                    const _Section(
                      titleKey: 'designTest.brandMark',
                      child: _BrandMarks(),
                    ),
                    const _Section(
                      titleKey: 'designTest.numbers',
                      child: _Numbers(),
                    ),
                    const _Section(
                      titleKey: 'designTest.icons',
                      child: _Icons(),
                    ),
                    const _Section(
                      titleKey: 'designTest.colors',
                      child: _Swatches(),
                    ),
                    const _Section(
                      titleKey: 'designTest.textStyles',
                      child: _TextStyles(),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.titleKey, required this.child});

  final String titleKey;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = AtharColors.of(context);
    final text = AtharTextStyles.forLocale(context.locale);

    return Container(
      margin: const EdgeInsetsDirectional.only(bottom: AtharSpacing.md),
      padding: const EdgeInsetsDirectional.all(AtharSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AtharRadii.sectionPhone),
        boxShadow: AtharShadows.card(Theme.of(context).brightness),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            titleKey.tr(),
            style: text.sectionTitle.copyWith(color: colors.textPrimary),
          ),
          const SizedBox(height: AtharSpacing.sm),
          child,
        ],
      ),
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls();

  @override
  Widget build(BuildContext context) {
    final colors = AtharColors.of(context);
    final text = AtharTextStyles.forLocale(context.locale);
    final labelStyle = text.fieldLabel.copyWith(color: colors.textSecondary);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('settings.language'.tr(), style: labelStyle),
        const SizedBox(height: AtharSpacing.xs),
        const LanguageControl(),
        const SizedBox(height: AtharSpacing.md),
        Text('settings.appearance'.tr(), style: labelStyle),
        const SizedBox(height: AtharSpacing.xs),
        const ThemeModeControl(),
      ],
    );
  }
}

class _BrandMarks extends StatelessWidget {
  const _BrandMarks();

  @override
  Widget build(BuildContext context) {
    final colors = AtharColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        // Rail size (44) in the variant for the current theme.
        SvgPicture.asset(
          isDark ? AtharAssets.brandMarkDark : AtharAssets.brandMarkLight,
          width: AtharSizes.iconTile,
          height: AtharSizes.iconTile,
        ),
        const SizedBox(width: AtharSpacing.md),
        // White mark on a primary tile, as on the light splash.
        Container(
          width: AtharSizes.iconTileDetails,
          height: AtharSizes.iconTileDetails,
          padding: const EdgeInsetsDirectional.all(AtharSpacing.sm),
          decoration: BoxDecoration(
            color: colors.primary,
            borderRadius: BorderRadius.circular(AtharRadii.button),
          ),
          child: SvgPicture.asset(AtharAssets.brandMarkWhite),
        ),
        const SizedBox(width: AtharSpacing.md),
        Text(
          'app.name'.tr(),
          style: AtharTextStyles.forLocale(context.locale).greeting
              .copyWith(color: colors.primary),
        ),
      ],
    );
  }
}

class _Numbers extends StatelessWidget {
  const _Numbers();

  @override
  Widget build(BuildContext context) {
    final colors = AtharColors.of(context);
    final text = AtharTextStyles.forLocale(context.locale);
    final locale = context.locale;

    Widget row(String labelKey, String value) => Padding(
      padding: const EdgeInsetsDirectional.only(bottom: AtharSpacing.xxs),
      child: Row(
        children: [
          Expanded(
            child: Text(
              labelKey.tr(),
              style: text.bodySmall.copyWith(color: colors.textSecondary),
            ),
          ),
          Text(
            value,
            style: text.statNumber.copyWith(color: colors.textPrimary),
          ),
        ],
      ),
    );

    return Column(
      children: [
        row(
          'designTest.numberDecimal',
          LocalizedNumbers.decimal(1234567, locale),
        ),
        row('designTest.numberStreak', LocalizedNumbers.decimal(21, locale)),
        row('designTest.numberPercent', LocalizedNumbers.percent(0.82, locale)),
      ],
    );
  }
}

class _Icons extends StatelessWidget {
  const _Icons();

  static const _uiIcons = [
    'back',
    'next',
    'chev_start',
    'chev_end',
    'check',
    'plus',
    'bell',
    'globe',
    'calendar',
  ];
  static const _habitIcons = ['book', 'drop', 'walk', 'moon', 'chat'];

  @override
  Widget build(BuildContext context) {
    final colors = AtharColors.of(context);
    final text = AtharTextStyles.forLocale(context.locale);
    final accents = colors.accents;

    Widget tile(Widget icon, Color background) => Container(
      width: AtharSizes.iconTile,
      height: AtharSizes.iconTile,
      alignment: AlignmentDirectional.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: AtharRadii.chipRadius,
      ),
      child: icon,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'designTest.iconsMirrorHint'.tr(),
          style: text.caption.copyWith(color: colors.textTertiary),
        ),
        const SizedBox(height: AtharSpacing.xs),
        Wrap(
          spacing: AtharSpacing.xs,
          runSpacing: AtharSpacing.xs,
          children: [
            for (final name in _uiIcons)
              tile(
                AtharIcon.ui(name, color: colors.textPrimary),
                colors.surfaceVariant,
              ),
            tile(AtharIcon.ui('flame', color: colors.flame), colors.flameSoft),
          ],
        ),
        const SizedBox(height: AtharSpacing.sm),
        Wrap(
          spacing: AtharSpacing.xs,
          runSpacing: AtharSpacing.xs,
          children: [
            for (var i = 0; i < _habitIcons.length; i++)
              tile(
                AtharIcon.habit(_habitIcons[i], color: accents[i].color),
                accents[i].soft,
              ),
          ],
        ),
      ],
    );
  }
}

class _Swatches extends StatelessWidget {
  const _Swatches();

  @override
  Widget build(BuildContext context) {
    final colors = AtharColors.of(context);
    final text = AtharTextStyles.forLocale(context.locale);

    final named = <String, Color>{
      'primary': colors.primary,
      'onPrimary': colors.onPrimary,
      'primaryContainer': colors.primaryContainer,
      'background': colors.background,
      'surface': colors.surface,
      'surfaceVariant': colors.surfaceVariant,
      'textPrimary': colors.textPrimary,
      'textSecondary': colors.textSecondary,
      'textTertiary': colors.textTertiary,
      'divider': colors.divider,
      'error': colors.error,
      'errorContainer': colors.errorContainer,
      'flame': colors.flame,
      'flameSoft': colors.flameSoft,
      'ringTrack': colors.ringTrack,
      'inverseSurface': colors.inverseSurface,
      for (final accent in colors.accents) accent.id: accent.color,
      for (var i = 0; i < colors.heatmap.levels.length; i++)
        'heatmap${i + 1}': colors.heatmap.levels[i],
    };

    return Wrap(
      spacing: AtharSpacing.sm,
      runSpacing: AtharSpacing.sm,
      children: [
        for (final entry in named.entries)
          SizedBox(
            width: AtharSizes.colorSwatch * 2,
            child: Column(
              children: [
                Container(
                  width: AtharSizes.colorSwatch,
                  height: AtharSizes.colorSwatch,
                  decoration: BoxDecoration(
                    color: entry.value,
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.divider),
                  ),
                ),
                const SizedBox(height: AtharSpacing.xxs),
                Text(
                  entry.key,
                  style: text.label.copyWith(color: colors.textSecondary),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _TextStyles extends StatelessWidget {
  const _TextStyles();

  static Map<String, TextStyle> _styles(AtharTextStyles s) => {
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

  @override
  Widget build(BuildContext context) {
    final colors = AtharColors.of(context);
    final current = AtharTextStyles.forLocale(context.locale);
    final latin = _styles(AtharTextStyles.latin);
    final arabic = _styles(AtharTextStyles.arabic);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final name in latin.keys) ...[
          Text(
            '$name · ${latin[name]!.fontSize} · w${latin[name]!.fontWeight!.value}',
            style: current.label.copyWith(color: colors.textTertiary),
          ),
          // Each script in its own style set and direction, regardless of the UI language.
          Text(
            'designTest.sampleEnglish'.tr(),
            textDirection: TextDirection.ltr,
            style: latin[name]!.copyWith(color: colors.textPrimary),
          ),
          Text(
            'designTest.sampleArabic'.tr(),
            textDirection: TextDirection.rtl,
            style: arabic[name]!.copyWith(color: colors.textPrimary),
          ),
          const Divider(height: AtharSpacing.xl),
        ],
      ],
    );
  }
}
