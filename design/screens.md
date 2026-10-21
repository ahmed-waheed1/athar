# Athar · أثر — screen spec for Flutter

Each screen below lists its PNGs in `screens/`, its parts, the tokens it uses (names from `lib/core/theme/` and `design-tokens.json`), its spacing, how it adapts to tablet and wide, what mirrors in Arabic, and its motion. Values are logical px (dp). Every PNG is @2x.

---

## 0. Global rules

### Files
| Path | What |
|---|---|
| `lib/core/theme/athar_colors.dart` | `AtharColors` ThemeExtension (light/dark), `HabitAccent`, `HeatmapColors`, `toColorScheme()` |
| `lib/core/theme/athar_typography.dart` | `AtharTextStyles.latin` / `.arabic`, `forLocale()`, `toTextTheme()` |
| `lib/core/theme/athar_spacing.dart` | `AtharSpacing`, `AtharRadii`, `AtharSizes`, `AtharShadows`, `AtharBreakpoints`, `AtharMotion` |
| `lib/core/theme/athar_theme.dart` | Optional `AtharTheme.light(locale)` / `.dark(locale)` ThemeData builder |
| `design-tokens.json` | Same values as plain text |
| `icons/habit/*.svg`, `icons/ui/*.svg` | Icon set (see below) |
| `assets/brand`, `assets/illustrations` | App mark, illustrations, milestone rings, confetti pieces |

### Font
- **Cairo**, weights 400, 500, 600 and 700 only, for both scripts.
- Flutter needs TTF/OTF files. Download Cairo from Google Fonts (OFL licence). Then either declare the variable font once, or declare four static weights under `family: Cairo`.
- Pick styles with `AtharTextStyles.forLocale(locale)`. Arabic uses taller line heights than Latin on every multi-line style (for example body 1.65 vs 1.45, card title 1.6 vs 1.4) and never negative letter-spacing. Single-line numeric styles keep `height: 1.0` (calendar day and weekday).
- Every style sets `leadingDistribution: even`, so Cairo's tall built-in leading is split evenly and text centres inside buttons and chips.

### Numbers and dates
- **Arabic UI uses Arabic-Indic digits ٠١٢٣٤٥٦٧٨٩ for every number, percentage, time and date**: streaks, counts, ring values (٣/٥), percentages (٪٨٢), calendar days, times (٧:٠٠ م) and character counters (١٣/٤٠). English uses Western digits.
- Format with `intl` using locale `ar_EG`, e.g. `NumberFormat.decimalPattern('ar_EG')` and `DateFormat('EEEE، d MMMM', 'ar_EG')`. The plain `ar` locale may give Western digits.
- **Arabic plurals for "day":**
  - ٠ يوم
  - يوم واحد
  - يومان
  - ٣–١٠ أيام
  - ١١–٩٩ يومًا
  - ١٠٠ يوم (any exact hundred)
  - Use `Intl.plural` with zero, one, two, few, many and other.
- **Week start:** Sunday for English, Saturday for Arabic. Arabic weekday headers are single letters: س ح ن ث ر خ ج.

### Icons
- **Set:** a custom outline set drawn for Athar on a 24 × 24 grid. Strokes are 1.8 wide with round caps and joins, and colour comes from `currentColor`. It is not a third-party library; the closest off-the-shelf match is Lucide.
- **Files:**
  - Every icon is in `icons/` as SVG. Render with `flutter_svg` and tint with `ColorFilter.mode(color, BlendMode.srcIn)`.
  - Habit icons (`habit_*.svg`, 20 total) are stored by name in the database: book, drop, walk, journal, moon, chat, leaf, heart, dumbbell, sun, sparkle, cup, apple, bed, music, brush, bike, coin, phoneoff, clock.
  - UI icons are `ui_*.svg`. `ui_flame.svg` is the only filled icon.
- **Mirror in RTL** (wrap in `Transform.flip(flipX: isRtl)`):
  - ui_back
  - ui_next
  - ui_chev_start
  - ui_chev_end
  - the progress ring
  - the empty-state trail
  - the milestone dot ring
- **Never mirror:** check, plus, close, flame, bell, lock, trash, edit, calendar, globe, warn, and every habit icon. The app mark never mirrors either.

### Illustrations and animation assets
- **App mark:**
  - `assets/brand/athar-mark-{light,dark,white}.svg` is the 4×4 trace grid with no background, used on the splash and the nav rail.
  - `assets/brand/app-icon-*.svg` is the approved launcher icon, Direction A (Heatmap path).
- **Illustrations:** `assets/illustrations/` holds the following, each in light and dark versions:
  - empty-state trail
  - onboarding 1–3
  - notification bell
- **Milestone rings:** `milestone-ring-{7,30,100}.svg` hold the dots only, tinted with `currentColor` (the habit accent). Draw the number and flame as live text on top. It's simpler to draw the ring with a `CustomPainter` (N dots on radius 78 inside a 180 box) so the dots can animate in one by one.
- **Confetti:** `confetti-pieces.svg` holds the two shapes (8 × 14 rounded rect and 10 px circle) in the 8 accent colours. Animate them in code; see screen 07.
- **No Lottie files are included.** Every motion is a simple transform (scale, sweep, slide, fall), so it's easiest built with `AnimationController` and `CustomPainter` from the specs below. If you'd rather use Lottie, the confetti and milestone ring are the two worth converting.

### Layout shell and breakpoints
Use `AtharBreakpoints.of(width)` to pick the layout:

| Layout | Width | Navigation | Gutter | Content |
|---|---|---|---|---|
| phone | < 600 | `NavigationBar`, 84 high incl. bottom inset; 3 items Today / History / Settings; pill indicator 64 × 32, radius 16 | 20 | Single column |
| tablet | 600–1024 | `NavigationRail` 88 wide on the **start** side, app mark (44) at top, indicator 56 × 32 | 32 | Two-column habit grid |
| wide | > 1024 | Rail 88 + habit list column 380 on the start side + details panel filling the end side | 22 list / 32 panel | Master-detail |

- **Top inset:** content starts 52 below the top safe area on phone (44 on screens with an app bar). There is no custom status bar.
- **Tap targets:** at least 48 × 48 everywhere (`AtharSizes.minTapTarget`). The check button is 52 (48 in the wide list).
- **Card:** `surface` colour, radius `card` 20, padding 12, gap 14, min height 72, shadow `AtharShadows.card`.
- **Section card:** `surface` colour, radius `sectionPhone` 24 (28 on tablet/wide), padding 16 (progress card 18).
- **Primary button:** 56 high, radius 18, `primary` / `onPrimary`, style `button`. Disabled: `surfaceVariant` / `textTertiary`.
- **Text field:**
  - 56 high, radius 16, `surface` fill, style `body` w600.
  - Resting border 1.5 `fieldBorder`; focused border 2 `primary`; error border 2 `error`.
  - Label above in style `fieldLabel`, 8 gap; error text below in style `caption` w600 colour `error` with ui_warn 16.

### Mirroring in RTL
Wrap the app in `Directionality` from the locale and build only with `EdgeInsetsDirectional`, `AlignmentDirectional` and `PositionedDirectional`. Then:
- Rows, gutters and the rail/list/panel order flip automatically. The rail and habit list sit on the right in Arabic.
- **Back arrow** points right in Arabic (flip `ui_back`).
- **Progress ring** fills clockwise in LTR and counter-clockwise in RTL: flip the painter horizontally and keep the start at 12 o'clock.
- **Progress dots, onboarding indicator and heatmap columns** run from the start edge. In the heatmap the newest week sits on the **end** side, at the left in Arabic.
- **Swipe actions:** swipe toward the start edge to reveal Edit + Delete on the end side. That is a swipe left in English with actions on the right, and a swipe right in Arabic with actions on the left. In `Dismissible`/`Slidable` use the end-to-start direction resolved for text direction.
- **Switches** read "on" with the knob at the end edge (left in Arabic). Material's `Switch` does this automatically.
- **Time:** Arabic shows ٧:٠٠ م. In the time-picker wheel the column order follows reading order (hour on the right in Arabic).
- **Language picker** always labels its options "English" and "العربية" in their own scripts, whatever the UI language.

### Motion (`AtharMotion`)
| Token | Duration | Curve | Used for |
|---|---|---|---|
| checkPop | 500 | easeOutBack | Check button scales 0.82 → 1.0; `HapticFeedback.lightImpact()` |
| ringProgress | 1400 | easeOutCubic | Ring sweeps from old to new value; progress dots fill in sync |
| swipeReveal | 350 | fastOutSlowIn | Card slides 144 toward the start edge |
| toastIn / toastOut | 250 / 200 | easeOutCubic / easeInCubic | Toast slides up 16 + fades; visible 3000 |
| dialogIn | 350 | easeOutBack | Fade + scale 0.92 → 1.0; scrim fades in 200 |
| sheetIn | 300 | easeOutCubic | Bottom sheets slide up |
| pageTransition | 300 | easeInOutCubic | Push/pop slides with text direction (Cupertino-style builder on both platforms); fade-through between nav tabs |
| milestoneDotStagger | 90 per dot | easeOutBack | Milestone dots pop in one by one (each 500) |
| confetti | 2600–4200 per piece | linear | 36 pieces fall and rotate 540°, looping while the modal is open |
| onboardingPage | 350 | easeOutCubic | PageView slide; active indicator widens 8 → 24 |

If `MediaQuery.disableAnimationsOf(context)` is true, use `Duration.zero` and skip the confetti.

---

## 01 · Splash
`01_splash_{en,ar}_light.png`
- **Background:** `primary` #1E6B5A in light, `background` #0E1412 in dark.
- **Content, centred:**
  - App-icon tile, 120 × 120, radius 22.37%: `surface` fill with the mark in `primary` (light), or #161F1C with the mark in mint (dark).
  - 18 gap, then the wordmark "Athar" / "أثر" in Cairo 48 w700, `onPrimary`.
  - The tagline in 17 w500, colour #D3EAE2 (light) or `textSecondary` (dark).
- **Loader:** three 8 px dots, 64 from the bottom, at opacities 0.25, 0.6 and 1, pulsing in sequence (1.6 s loop, 0.2 s stagger).
- **Motion:** the mark's cells fade and scale in from 0.6 (each 900 easeOutCubic, 60 stagger from bottom-left to top-right). Then route to onboarding (first run) or Home.
- **RTL:** nothing mirrors.

## 02 · Onboarding (3 slides)
`02_onboarding_slide1-language_*`, `02_onboarding_slide2_*`, `02_onboarding_slide3_*`
- **Layout:** padding 52 top / 24 sides / 40 bottom. A top row 48 high holds **Skip** (text button, style `buttonSmall`, `textSecondary`) at the end edge, hidden on slide 3.
- **Illustration:** a box 290 high, centred, using `onboarding-{1,2,3}-*.svg`.
- **Text:** page indicator (pills 8 × 8, active 24 × 8, radius 4, gap 6, 20 above / 18 below); title in `screenTitle` 28 w700; body in `body`, `textSecondary`, 8 gap.
- **Slide 1 language picker:**
  - 20 below the body: a label row with ui_globe 18 and "Language" (`fieldLabel`).
  - Then a segmented control: track `surfaceVariant`, radius 16, padding 4; segments 48 high, radius 12; the selected one is `surface` + card shadow.
  - Switching language rebuilds the app in place (locale + `Directionality`) without leaving the slide.
- **CTA:** primary button pinned to the bottom, "Next" + ui_next 20 (mirrored), "Get started" on slide 3.
- **Tablet/wide:** centre a 480-wide column. The illustration can grow to 340.
- **RTL:** Skip moves to the left, the indicator fills from the right, the Next arrow points left, and the lock badge on illustration 3 sits on the start-bottom corner (flip the SVG).
- **Motion:** `onboardingPage`; the illustration fades and scales in from 0.94 (350).

## 03 · Home / Today
`03_home_{empty,none,partial,alldone,swipe-actions,delete-dialog}_*` (+ `_tablet`, `_wide` for partial)

**Structure (phone)**
- **Padding:** 52 top, 20 sides, 16 vertical gap.
- **Header row:** date (`dateLabel`, `textTertiary`) over greeting (`greeting` 26). At the end edge, an add button 48 × 48, radius 16, `primary` fill, ui_plus 24 stroke 2.2.
- **Progress card:**
  - Section card, padding 18, gap 18.
  - Ring 96 with stroke 10, track `ringTrack`, arc `primary`, round cap, start at 12 o'clock. Inside: value (`ringValue` 24, "3/5") over a percentage (`label`, `textTertiary`).
  - Text column: `progressTitle` 18 ("3 of 5 done today") and `bodySmall` (`textSecondary`).
  - Five progress dots, 10 px, gap 6: done dots are `primary` fill; open dots have a 2 px `divider` ring.
- **Section header:** "Today's habits" (`sectionTitle`), 4 inset. In the swipe state a hint "Swipe for options" sits at the end edge.
- **Habit list:** gap 10. Each habit card:
  - Icon tile 44, radius 14, `accent.soft` fill, `accent.color` icon 24.
  - Name (`cardTitle`) over a streak row: flame 16 (`flame`) + `caption` "21 days" in `flame`.
  - Check button 52: border 2.5 accent; when done, filled with the accent and a check 26 at stroke 2.8 in `accent.onColor`.
  - Semantics: a toggle button, "Mark done: {name}" / "Undo: {name}".
- **Bottom navigation:** NavigationBar.

**States**
| State | Ring | Title / sub | Notes |
|---|---|---|---|
| none | 0/5, 0% | "0 of 5 done today" / "5 traces waiting for you today" | All checks open |
| partial | 3/5, 60% | "3 of 5 done today" / "2 more traces to leave today" | |
| alldone | full ring with a check 34 instead of a number | "All 5 done today" / "Every trace left today. See you tomorrow!" | |
| swipe-actions | — | — | Read 10 pages slid 144 toward the start edge, sitting on a `surfaceVariant` backdrop (radius 20) holding two 64 × 56 action buttons, radius 16, gap 8, padding 8: Edit (`primaryContainer`/`onPrimaryContainer`) and Delete (`error`/`onError`), each icon 20 over `label` 12 w700 |
| delete-dialog | — | — | AlertDialog (see Dialogs below): "Delete “Read 10 pages”?" / "Its 21-day streak and all of its history will be removed. This can’t be undone." Cancel / Delete |
| empty | — | — | No progress card or list. Centred: `empty-state-trail-*.svg` (300 × 200), title `emptyTitle` 24, body `body` max-width 290, primary button "Create your first habit" (ui_plus 20), then "Or start with one of these" (`caption`, `textTertiary`) and three suggestion chips (48 high, radius 24, 1.5 `divider` border, `surface` fill, accent icon 18 + `bodySmall` w600) that prefill Add Habit |

**Dialogs** (shared by delete and reset):
- `surface` fill, radius 28, padding 24, max width 400, gap 12, shadow `raised`.
- Icon tile 56, radius 18, `errorContainer` / `error`. Title 22 w700, body `bodySmall` / 15 in `textSecondary`.
- Two equal buttons, 52 high, radius 16: Cancel (`surfaceVariant`) and the destructive action (`error` / `onError`), with the destructive one on the end side. Scrim uses the `scrim` colour.

**Tablet (600–1024)**
- Rail on the start side.
- Content padding 40 / 32. Header with "Add habit" as a labelled button (48 high, radius 16).
- Progress card: radius 28, padding 22 / 26, ring 120, `progressTitle` at 21.
- Habit grid: 2 columns, gap 14. A dashed "Add habit" card (2 px dashed `divider`, radius 20) fills the last cell.
- "Your path · last 26 weeks" card: an all-habits heatmap of 18 px cells, gap 3, levels `heatmap.levels`, with a Less → More legend.

**Wide (> 1024)**
- Rail, then the habit list column (380, `divider` border on the end side, padding 28 / 22).
  - Header: greeting 24 + add button.
  - Compact progress card: ring 64, stroke 12.
  - Habit list rows: check 48, icon tile 42.
- The end panel shows an **Overview** when no habit is selected:
  - Three stat tiles ("3/5 done today", "40 longest active streak", "82% consistency this month"), number 32 w700.
  - The 26-week all-habits heatmap at 20 px cells.
  - A "next milestone" row with a `flameSoft` icon tile.
- Selecting a habit swaps the panel to Habit Details (see 06). The selected row gets a 2 px accent border and a tinted background (light #F1F1FB, dark #1C2230, from the canvas).

**Motion**
- Checking a habit: checkPop on the button, then ringProgress, and the toast (04) appears.
- Unchecking: reverse with no toast.
- Swipe: swipeReveal. Delete: the card collapses its height (300, easeInCubic) after confirmation.

## 04 · Check-in feedback (toast)
`04_checkin_toast_*`
- **Shape:** a floating SnackBar, 16 from the side edges and 16 above the nav bar. Radius 20, `inverseSurface` fill, padding 10 / 12, shadow `toast`.
- **Content:**
  - Flame tile, 40 × 40, radius 12. In light mode: flame #F2925A on an 18% tint of it. In dark mode: flame #C4521F on #FBE6DB. The tile uses the opposite theme's flame colours, because it sits on an inverse surface.
  - Text in `toast` 15 w600, `onInverseSurface`: "Trace added · 6-day streak" / "أُضيف أثر · سلسلة ٦ أيام".
  - Action "Undo" / "تراجع": `buttonSmall`, 48 high, in the **opposite theme's primary** (#6CCBAF in light, #1E6B5A in dark). It reverses the check.
- **Timing:** toastIn, stays 3000, toastOut. A new check replaces the current toast.
- **RTL:** the flame sits on the right and Undo on the left (automatic).
- **Milestones:** on 7 / 14 / 30 / 60 / 100 / 365 the toast is skipped and the milestone modal (07) opens instead.

## 05 · Add habit / Edit habit
`05_addhabit_{empty,filled,error-empty-name,error-name-too-long,icon-picker,color-picker,reminder-time}_*`, `05_edithabit_filled_*`
- **Screen:** full-screen route on phone. Padding 44 top / 20 sides / 32 bottom.
- **App bar:** 48 high. Back button 48 (ui_back, mirrored), title `appBarTitle` 20. Edit mode adds a delete icon button 48 at the end edge in `error`, which opens the delete dialog.
- **Form, in order:**
  1. **Live preview card:** a habit card in the "Starts today" state, using the current name, icon and colour. With no name yet, the placeholder "Habit name" shows in `textTertiary`.
  2. **Name field:**
     - 20 above. Label row: "Habit name" + counter "13/40" at the end edge (`caption`, `textTertiary`).
     - Max 40 characters; the counter counts graphemes.
     - Hint: "e.g. Read 10 pages" / "مثال: قراءة ١٠ صفحات".
  3. **Icon row:**
     - 18 above. Label "Icon" + a "More" text button (`primary`) that opens the icon sheet.
     - A horizontal list of 56 × 56 cells, radius 16, gap 8, that bleeds off the end edge to signal scrolling.
     - The selected cell has a 2 px accent border, `accent.soft` fill and accent icon.
  4. **Colour grid:**
     - 18 above. Label "Color" + the selected colour's name at the end edge.
     - A 4 × 2 grid of 40 swatches inside 52 tap cells.
     - The selected swatch shows a check 20 in `onColor` plus a double ring: 3 `background` + 2.5 accent.
  5. **Reminder row:**
     - 14 above. `surface` fill, radius 18, padding 10 / 14.
     - Bell tile 40, radius 12, `primaryContainer` fill. Title "Daily reminder" over "Optional · 7:00 PM" (or "Optional · Off").
     - A Switch at the end edge. Tapping the row opens the time sheet.
  6. **Save button:** pinned to the bottom. "Save habit", or "Save changes" when editing.
- **States:**
  - **empty:** no name; first icon (book) and colour (indigo) preselected; reminder off; Save disabled.
  - **filled:** "Learn English", chat icon, coral, reminder 7:00 PM; field focused.
  - **error-empty-name:** shown after tapping Save with no name. The label and border turn `error`; helper "Give your habit a name".
  - **error-name-too-long:** the counter turns `error` (e.g. 64/40); helper "Keep the name under 40 characters"; Save is blocked.
  - **icon-picker:** a modal bottom sheet (radius 28 at the top, padding 12 / 24 / 32, drag handle 36 × 4). Title "Choose an icon" (`appBarTitle`), a 5-column grid of all 20 icons (56 high cells, radius 16, gap 10, `surfaceVariant` fill), and a "Done" button.
  - **color-picker:** the selected colour (Teal) also gets a 2 px `textPrimary` focus ring for keyboard focus, and the preview card updates live.
  - **reminder-time:**
    - A bottom sheet titled "Reminder time" with a three-column wheel (hour : minute, AM/PM; ص / م in Arabic) and a selection band (`surfaceVariant`, radius 14, 44 high).
    - Selected value 26 w700; neighbours 20 w500 in `textTertiary`, the outer ones at 45% opacity.
    - Helper "You’ll get one gentle notification at this time every day."
    - Buttons Cancel / Set reminder. Use `CupertinoDatePicker(mode: time)` styled with the tokens, or a custom `ListWheelScrollView`.
  - **edit filled:** existing values; the streak label shows the current streak.
- **Tablet/wide:** opens as a centred dialog 520 wide with a radius 28 sheet on a scrim, a close button instead of back, and the same form.
- **RTL:** back arrow, counters and labels mirror; the icon row scrolls from the right. The wheel order follows reading order.
- **Motion:** sheets use sheetIn. A validation error shakes the field 3 × 4 px (300). Enabling the first reminder triggers screen 09.

## 06 · Habit details
`06_details_{active,broken,new,heatmap-calendar}_*` (+ `_tablet`, `_wide` for active)
- **Padding:** 44 top, 20 sides, 14 vertical gap. The screen scrolls.
- **Top row:** back 48 at the start edge, edit 48 at the end edge.
- **Header:** icon tile 56, radius 18, `accent.soft`; name `emptyTitle` 24; meta in `dateLabel` `textTertiary` ("Every day · Reminder 8:30 PM").
- **Streak hero:**
  - Radius 28, padding 20 / 22, accent fill with `accent.onColor` text.
  - "Current streak" (14 w700); number `displayStreak` 72 + "days" 18 w700 on the baseline; a note line (14 w600).
  - Flame 64 at 92% opacity on the end side.
- **Stats row:** three cards, radius 20, padding 12 / 14, gap 10: number `statNumber` 24, label `statLabel`. Best streak, Completions, Consistency (% of days since start).
- **Heatmap card:**
  - Section card. Title "Last 18 weeks" (`cardTitle`) and a legend (Missed = `heatmap.missed`, Done = accent; 10 px squares, `label`).
  - Grid: 7 rows (week start per locale) × 18 columns, cells 14, gap 3, radius 4.
  - Done cells = accent; missed = `heatmap.missed`; future = transparent.
  - Today gets a 2 px `surface` gap and a 1.5 px `textPrimary` ring.
- **Month calendar card:**
  - Header: prev / next buttons 48 (chevrons mirrored); next is disabled at 35% on the current month. Title `cardTitle` ("October 2026").
  - Weekday row: `calendarWeekday`, `textTertiary`, 24 high.
  - 7-column grid, gap 4, cells 40 high (38 tablet, 34 wide), radius 12.
  - Done = accent fill + `onColor` number; missed = `surfaceVariant`; future = no fill, `textTertiary` w500.
  - Today = inset 2 px `textPrimary` ring.
- **States:**
  - **active:** 21 days; note "Best is 34 — 13 to go", or "Your best ever — keep going" when current = best.
  - **broken (0 days):** the hero switches to a `surfaceVariant` fill with `textPrimary` text and the flame in `textTertiary` at 50%. Note "Streak paused. Best is 12 — start again today". History stays.
  - **new (no history):** the hero uses `primaryContainer` / `onPrimaryContainer`, "0 days", note "Your first trace is one tap away".
    - Stats show "—", "0", "—".
    - Heatmap cells before today use `heatmap.noData`, distinct from missed.
    - Calendar days before creation have no fill.
  - **heatmap-calendar:** the same screen scrolled 340 to show the heatmap and calendar.
- **Tablet:** rail; content padding 32.
  - Header row: back, header, and an outlined "Edit" button (48 high, radius 14, 1.5 `divider`).
  - Two columns: hero (number 64) + stats on one side; a "This month" card on the other (number 56 in accent, "of 20 days", 20 dots of 14 px, gap 8).
  - Then a 26-week heatmap (cells 18, gap 4) and the calendar at max width 420.
- **Wide:** the panel next to the list (see 03). Two columns of hero + stats | calendar (cells 34), then the 26-week heatmap full width.
- **RTL:** the hero flame sits on the left, newest heatmap week on the left, calendar columns start Saturday on the right, chevrons mirror.
- **Motion:**
  - The hero number counts up from 0 (600, easeOutCubic) when the screen opens.
  - Heatmap cells fade in column by column from the start edge (20 per column, 200 each).
  - Month change slides the grid horizontally in reading direction (250).

## 07 · Streak milestone celebration
`07_milestone_{7,30,100}_*`
- **When:** checking a habit lands on 7, 14, 30, 60, 100 or 365 days. Shown over Home with the `scrim` colour.
- **Card:** `surface`, radius 32, padding 28 / 24 / 24, margin 20, centred, shadow `raised`. A close button 48 sits in the top end corner.
- **Ring:** N dots in the habit accent on a 78 radius circle inside 180 × 180. Dot size: 20 at 7, 11 at 30, 5 at 100 (`milestone-ring-*.svg`, or draw in code).
- **Centre stack:** flame 28 (`flame`), number `milestoneNumber` 56, unit `label` 14 w700 in `textTertiary` ("days"; in Arabic أيام / يومًا / يوم by the plural rule).
- **Text:**
  - Title `greeting` 26: "7-day streak!" / "سلسلة ٧ أيام!".
  - Body `body` in `textSecondary`, naming the habit.
  - A pill with the next milestone (`surfaceVariant`, radius full, padding 6 / 14, `caption` w700).
  - Primary button "Keep going" / "واصل الطريق".
- **Copy:**
  - 7: "A full week of traces for “Drink water”. Your path is taking shape."
  - 30: "A month of showing up for “Pray on time”. That’s a real habit now."
  - 100: "100 mornings of “Morning walk”. This trace is here to stay."
- **Motion:**
  - dialogIn; then the ring dots pop in (milestoneDotStagger, 90 ms apart, each 500 easeOutBack; at 100 dots use 12 ms apart).
  - Confetti: 36 pieces over the whole screen in the 8 accent colours, 2/3 rectangles and 1/3 circles. Each falls from −40 to screen height + 40 over 2.6–4.2 s, rotating 540°, with random start delays, looping until dismissed.
  - `HapticFeedback.mediumImpact()` on open.
- **RTL:** the ring fills counter-clockwise and the close button moves to the top left.

## 08 · Settings
`08_settings_{main,reset-dialog}_*`
- **Layout:** padding 52 top / 20 sides, 10 gap. Title `screenTitle` 28.
- **Section labels:** `fieldLabel` at 13 in `textTertiary`.
- **Language:** a segmented control (English | العربية, each in its own script). Switching changes locale, `Directionality` and digits instantly, and persists locally.
- **Appearance:** a 3-segment control: Light / Dark / System (ui_theme_light, ui_theme_dark, ui_system at 18).
- **Preferences group:**
  - Card, radius 22, padding 6. Rows 60 min high, padding 8 / 12, icon tile 40 radius 12 `primaryContainer`.
  - **Reminders:** a switch; subtitle "On · per-habit times".
  - **Week starts on:** the value at the end edge + a mirrored chevron. It defaults by locale.
  - 1 px `divider` lines between rows, inset 12.
- **Your data group:**
  - Lock row with "Saved only on this device. No account, no cloud."
  - "Reset all data" row in `error`, with an `errorContainer` icon tile and subtitle "Deletes every habit and its history".
- **reset-dialog:**
  - "Reset all data?" / "This removes 5 habits and 412 traces from this device. It can’t be undone." with Cancel / Reset.
  - Show the real counts. After confirming, clear storage and route to Home (empty).
- **Tablet/wide:** a centred column with max width 560 inside the rail layout.
- **RTL:** chevrons flip, and switches show "on" with the knob on the left.
- **Motion:** theme changes use `AnimatedTheme` (300). Language changes rebuild without animation.

## 09 · Notifications
`09_notifications_{prompt,denied}_*`
- **prompt:**
  - **When:** the user turns on a reminder (the switch, or setting a time) while notifications were never requested. Show this pre-permission sheet before the OS dialog. The same applies to the Settings Reminders switch.
  - **Sheet:** a bottom sheet over Add Habit, radius 28, padding 12 / 24 / 32, with a drag handle.
  - **Content:**
    - `notification-bell-*.svg` at 120.
    - Title `emptyTitle` 24: "Want a gentle nudge?" / "هل تريد تذكيرًا لطيفًا؟".
    - Body `bodySmall` / 15 in `textSecondary`, centred.
    - Primary button "Allow reminders", which opens the OS prompt with flutter_local_notifications' own APIs: `AndroidFlutterLocalNotificationsPlugin.requestNotificationsPermission()` on Android 13+ and `IOSFlutterLocalNotificationsPlugin.requestPermissions(alert: true, sound: true)` on iOS. No `permission_handler`. Then the reminder turns on even if the OS prompt is refused; the denied banner explains why it can't arrive.
    - A text button "Not now" (48 high, `primary`) that leaves the reminder off. The sheet shows again next time, since the OS was never asked.
  - **Permission state:** granted when the OS reports notifications enabled (`areNotificationsEnabled()` / `checkPermissions().isEnabled`). Otherwise it is denied if the app has requested before (a flag kept in shared_preferences), or not yet asked. It is re-read whenever the app returns to the foreground.
- **denied:**
  - **Settings:** the Reminders row shows ui_bell_off, the subtitle "Blocked by the system" and a disabled switch at 45% opacity.
  - **Banner:** below the row (inside the Preferences card, inset 6), radius 16, `errorContainer` fill, padding 12. Warn icon 20 in `error`, text `bodySmall` "Notifications are blocked, so reminders can’t reach you. Turn them on in your phone’s settings." and a button "Open settings" (40 high, radius 12, `surface`). The button opens the app's notification settings with the `app_settings` package: `AppSettings.openAppSettings(type: AppSettingsType.notification)`. Import it with a prefix (`import 'package:app_settings/app_settings.dart' as system_settings;`), because its `AppSettings` clashes with the app's `AppSettings` entity.
  - **Add Habit:** the same banner appears 8 below the reminder row while the reminder is on and notifications are denied.
- **Settings Reminders row (granted / not asked):**
  - Granted: ui_bell, subtitle "On · per-habit times", switch on. Only the OS can revoke the permission, so turning the switch off opens the same system notification settings.
  - Not asked yet: ui_bell, subtitle "Off", switch off. Turning it on runs the prompt above.
- **Notifications:**
  - Title "Time for “{name}”" / "حان وقت «{name}»", body "Leave today’s trace and keep your path going." / "اترك أثر اليوم وواصل طريقك.", in the app language.
  - Android channel `habit_reminders`, named "Habit reminders" / "تذكيرات العادات" and renamed when the language changes.
  - Small icon `ic_stat_athar`: the Athar mark, white on transparent. Tapping a notification opens Home.
- **RTL:** the banner icon sits on the right, and the button aligns to the start edge.

---

### PNG index
- **Phone:** 30 screens × EN/AR in light, plus dark for 7 of them (home empty / partial / alldone, details active / heatmap-calendar, settings main / reset-dialog).
- **Tablet and wide:** `03_home_partial` and `06_details_active` in EN/AR × light/dark.
- **Sizes:** phone 375 × 812 → 750 × 1624 px; tablet 768 × 1024 → 1536 × 2048 px; wide 1200 × 800 → 2400 × 1600 px.
- **Sample data** (same on every screen): Pray on time (teal, moon, 40 days), Drink water (sky, drop, 6), Read 10 pages (indigo, book, 21, best 34), Morning walk (leaf, walk, 14), Learn English (coral, chat, 9). Today is Tuesday 20 October 2026.
