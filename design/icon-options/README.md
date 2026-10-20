# Athar · أثر — app icon exports

Three directions, each in its own folder:

- `athar-icon-a-heatmap`: Heatmap path, a 4×4 grid filling in along a rising diagonal
- `athar-icon-b-trail`: Rising trail, four step marks climbing up and to the right
- `athar-icon-c-alef`: Alef of traces, the letter أ with its stem built from trace dots

## Files in each folder

| File | Size | Notes |
|---|---|---|
| `master-1024.png` | 1024×1024 | App Store / master. Square, full-bleed, opaque RGB (no alpha channel), no rounded corners |
| `master-dark-1024.png` | 1024×1024 | Dark-mode variant (Ink 950 #0E1412 ground, Mint #6CCBAF marks) |
| `play-store-512.png` | 512×512 | Google Play listing icon, opaque RGB |
| `android/ic_launcher_foreground-432.png` | 432×432 | Transparent; white mark kept inside the 66 dp safe zone (about 52 dp across) |
| `android/ic_launcher_background-432.png` | 432×432 | Solid Teal 700 #1E6B5A |
| `android/ic_launcher_monochrome-432.png` | 432×432 | Android 13+ themed icon: single-color white mark on transparent; the system tints it |
| `preview-48.png` | 48×48 | Small-size legibility check |
| `svg/*.svg` | vector | Editable sources for every PNG above |

Colors: Teal 700 `#1E6B5A`, White `#FFFFFF`, Ink 950 `#0E1412`, Mint 300 `#6CCBAF`.

## Flutter setup (flutter_launcher_icons)

Copy the chosen folder into `assets/icon/`, then in `pubspec.yaml`:

```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.14.0

flutter_launcher_icons:
  image_path: "assets/icon/master-1024.png"
  android: true
  ios: true
  remove_alpha_ios: true
  adaptive_icon_background: "#1E6B5A"
  adaptive_icon_foreground: "assets/icon/android/ic_launcher_foreground-432.png"
  adaptive_icon_monochrome: "assets/icon/android/ic_launcher_monochrome-432.png"
```

Then run `dart run flutter_launcher_icons`.

For iOS 18 dark and tinted app icons, add `master-dark-1024.png` as the Dark appearance in Xcode: Runner › Assets.xcassets › AppIcon › Appearances › Any, Dark.
