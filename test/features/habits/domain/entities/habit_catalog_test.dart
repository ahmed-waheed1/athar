import 'dart:io';

import 'package:athar/core/constants/athar_assets.dart';
import 'package:athar/core/theme/athar_colors.dart';
import 'package:athar/features/habits/domain/entities/habit_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('icon keys are exactly the files in assets/icons/habit', () {
    final files = Directory('assets/icons/habit')
        .listSync()
        .map((f) => f.uri.pathSegments.last)
        .where((name) => name.endsWith('.svg'))
        .toSet();
    expect(
      HabitCatalog.iconKeys
          .map((k) => AtharAssets.habitIcon(k).split('/').last)
          .toSet(),
      files,
    );
    expect(
      HabitCatalog.iconKeys.toSet(),
      hasLength(HabitCatalog.iconKeys.length),
    );
  });

  test('color keys match the habit accents in both themes, in order', () {
    expect(AtharColors.light.accents.map((a) => a.id), HabitCatalog.colorKeys);
    expect(AtharColors.dark.accents.map((a) => a.id), HabitCatalog.colorKeys);
  });

  test('defaults are part of the catalog', () {
    expect(HabitCatalog.iconKeys, contains(HabitCatalog.defaultIconKey));
    expect(HabitCatalog.colorKeys, contains(HabitCatalog.defaultColorKey));
  });

  test('a new habit starts with the first icon and color (screens.md 05)', () {
    expect(HabitCatalog.newHabitIconKey, HabitCatalog.iconKeys.first);
    expect(HabitCatalog.newHabitColorKey, HabitCatalog.colorKeys.first);
  });

  test('known keys pass through, unknown keys fall back', () {
    expect(HabitCatalog.iconOrDefault('drop'), 'drop');
    expect(HabitCatalog.iconOrDefault('unicorn'), HabitCatalog.defaultIconKey);
    expect(HabitCatalog.iconOrDefault(''), HabitCatalog.defaultIconKey);
    expect(HabitCatalog.colorOrDefault('plum'), 'plum');
    expect(HabitCatalog.colorOrDefault('beige'), HabitCatalog.defaultColorKey);
  });
}
