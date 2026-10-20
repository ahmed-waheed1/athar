# Athar · أثر — Flutter design handoff

```
lib/core/theme/
  athar_colors.dart       AtharColors ThemeExtension (light + dark), HabitAccent, HeatmapColors
  athar_typography.dart   AtharTextStyles.latin / .arabic (Cairo 400–700)
  athar_spacing.dart      spacing, radii, sizes, shadows, breakpoints, motion
  athar_theme.dart        optional ThemeData builder: AtharTheme.light(locale) / .dark(locale)
design-tokens.json        every value above as plain text
screens.md                per-screen build spec (components, tokens, spacing, tablet/wide, RTL, motion)
screens/phone|tablet|wide PNG references @2x, named NN_screen_state_lang_theme[_device].png
icons/habit, icons/ui     24×24 outline SVG icon set (stroke 1.8, currentColor)
assets/brand              app mark + approved launcher icon (Direction A) SVGs
assets/illustrations      empty state, onboarding, notification bell, milestone rings, confetti pieces
```

## Quick start

```yaml
# pubspec.yaml
dependencies:
  flutter_localizations:
    sdk: flutter
  intl: any
  flutter_svg: any

flutter:
  fonts:
    - family: Cairo
      fonts:
        - asset: assets/fonts/Cairo-Regular.ttf
        - asset: assets/fonts/Cairo-Medium.ttf
          weight: 500
        - asset: assets/fonts/Cairo-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/Cairo-Bold.ttf
          weight: 700
  assets:
    - icons/habit/
    - icons/ui/
    - assets/brand/
    - assets/illustrations/
```

Cairo is OFL-licensed. Download it from Google Fonts. The font files are not included here.

```dart
MaterialApp(
  locale: locale,                       // Locale('en') or Locale('ar', 'EG')
  theme: AtharTheme.light(locale),
  darkTheme: AtharTheme.dark(locale),
  themeMode: themeMode,                 // from Settings: light / dark / system
  supportedLocales: const [Locale('en'), Locale('ar', 'EG')],
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  ...
);

final c = AtharColors.of(context);      // c.flame, c.accent('coral').soft, c.heatmap.missed ...
final t = AtharTextStyles.forLocale(Localizations.localeOf(context));
final layout = AtharBreakpoints.of(MediaQuery.sizeOf(context).width);
```

## Notes
- **Colors:** every hex is taken from the existing Athar design. Three tokens are expressed rather than new:
  - `success` reuses the Leaf habit accent.
  - Soft accent chips are each accent at 12% alpha (light) or 18% alpha (dark).
  - `flameSoft` in dark mode is the flame colour at 18% alpha.
- **Typography:** this export uses **Cairo** for both scripts, as requested, at weights 400–700. Places where the canvas used weight 800 map to 700. Arabic uses taller line heights; the dartdoc on each style gives both values.
- **Not compiled:** the Dart files were written against Flutter 3.22+ / Dart 3 APIs (`ThemeExtension`, `WidgetStatePropertyAll`, `surfaceContainer*`), but no Dart SDK was available, so run `flutter analyze` once after dropping them in.
