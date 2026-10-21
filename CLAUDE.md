# Athar (أثر)

Bilingual (English/Arabic) habit tracker built in Flutter. Users add daily habits, check them off, track streaks, and see history in a heatmap and monthly calendar. All data is local; there are no accounts.

## Stack
- State: flutter_bloc (Cubit) + equatable
- DI: get_it (lib/core/di)
- Routing: go_router (lib/core/router)
- Storage: hive_ce + hive_ce_flutter (habits), shared_preferences (settings: language, theme, onboarding done)
- Localization: easy_localization, locales en-US and ar, JSON files in assets/translations/. Until the user picks a language, it follows the device: Arabic if the device language is Arabic, otherwise English.
- Responsive: athar_spacing.dart tokens + LayoutBuilder breakpoints (AtharBreakpoints: phone < 600, tablet 600–1024, wide > 1024). No flutter_screenutil or other scaling packages.
- Notifications: flutter_local_notifications + timezone + flutter_timezone. Request notification permission with flutter_local_notifications' own APIs (no permission_handler).
- UI: flutter_svg, flutter_slidable

## Architecture
Feature-first clean architecture: lib/features/{onboarding,habits,settings}/{data,domain,presentation}.
- domain: entities, repository interfaces, use cases (pure Dart, no Flutter imports)
- data: Hive models/adapters, datasources, repository implementations
- presentation: cubits, screens, widgets
Shared code goes in lib/core/.

## Habit rules
- A habit stores completedDates as normalized dates (yyyy-MM-dd, local time). Never store streak values; compute current and best streak from completedDates.
- An unchecked today does not break the current streak until the day ends.
- Streak logic must have unit tests in test/features/habits/domain covering gaps, today unchecked, and month/year boundaries.

## Design
- Specs: design/screens.md is the source of truth for every screen (components, tokens, spacing, RTL behavior, animations). design/screens/{phone,tablet,wide}/*.png show every screen and state. design/design-tokens.json lists all values.
- Theme: use lib/core/theme/ (AtharColors, AtharTextStyles, athar_spacing, athar_theme). Never hardcode colors, sizes, or text styles in widgets.
- Font: Cairo, bundled locally (400/500/600/700). Never use google_fonts.
- Icons: custom SVGs in assets/icons/ui/ and assets/icons/habit/ via flutter_svg; flip the ones screens.md marks as directional in RTL. Brand marks are in assets/brand/, illustrations in assets/illustrations/.
- Arabic: Arabic-Indic digits, Arabic plural forms for "day", and weeks start on Saturday (Sunday in English), as described in screens.md.

## Rules
- No hardcoded user-facing strings; every string goes in both en.json and ar.json.
- In widgets, always use context.tr()/context.plural(), never 'key'.tr().
- RTL-safe layout only: EdgeInsetsDirectional, AlignmentDirectional, start/end. Never left/right.
- Run flutter analyze after each change and keep it at zero issues.
- Build one screen or feature at a time and stop for review.
- Ignore store/ (store listing assets) and design/icon-options/ (unused icon drafts).
- Native setup for flutter_local_notifications (including core library desugaring) must follow the package's current README.
- Reminders are inexact daily notifications. Never add SCHEDULE_EXACT_ALARM or USE_EXACT_ALARM.
