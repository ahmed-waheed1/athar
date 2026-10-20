import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/habits/domain/repositories/habit_repository.dart';
import '../di/injection.dart';
import '../router/app_router.dart';
import 'sample_habits.dart';

/// DEBUG ONLY: sample data and the design test screen. Opened by
/// long-pressing the Home greeting. Does nothing in release builds.
/// [onChanged] runs after the stored habits change.
Future<void> showDebugToolsSheet(
  BuildContext context, {
  required VoidCallback onChanged,
}) async {
  if (!kDebugMode) return;
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(title: Text('debug.menuTitle'.tr())),
          ListTile(
            title: Text('debug.insertSamples'.tr()),
            onTap: () async {
              final repository = sl<HabitRepository>();
              // Fixed ids: inserting again resets the samples.
              for (final habit in buildSampleHabits(
                now: DateTime.now(),
                name: (key) => key.tr(),
              )) {
                await repository.addHabit(habit);
              }
              if (sheetContext.mounted) Navigator.of(sheetContext).pop();
              onChanged();
            },
          ),
          ListTile(
            title: Text('debug.clearHabits'.tr()),
            onTap: () async {
              final repository = sl<HabitRepository>();
              for (final habit in await repository.getHabits()) {
                await repository.deleteHabit(habit.id);
              }
              if (sheetContext.mounted) Navigator.of(sheetContext).pop();
              onChanged();
            },
          ),
          ListTile(
            title: Text('debug.openDesignTest'.tr()),
            onTap: () {
              Navigator.of(sheetContext).pop();
              context.push(AppRoutes.designTest);
            },
          ),
        ],
      ),
    ),
  );
}
