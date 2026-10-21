import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../../../core/services/notification_service.dart';
import '../../../settings/domain/entities/app_settings.dart';
import '../../domain/services/reminder_planner.dart';
import '../../domain/usecases/get_habits.dart';
import '../../domain/usecases/watch_habit_changes.dart';
import 'reminder_copy.dart';

/// Keeps the scheduled notifications in step with the habits.
///
/// Every sync plans all reminders again ([ReminderPlanner]) and replaces the
/// pending ones. It runs at start, whenever the stored habits change (add,
/// edit, delete, check-in, reset), when the language changes (the text
/// follows it) and when the app comes back to the foreground (a new day, or
/// a changed time zone).
class HabitReminderScheduler {
  HabitReminderScheduler({
    required this._getHabits,
    required this._watchHabitChanges,
    required this._notifications,
    required this._copy,
    required this._language,
    required this._languageChanges,
    this._planner = const ReminderPlanner(),
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final GetHabits _getHabits;
  final WatchHabitChanges _watchHabitChanges;
  final NotificationService _notifications;
  final ReminderCopySource _copy;
  final AppLanguage Function() _language;
  final Stream<AppLanguage> _languageChanges;
  final ReminderPlanner _planner;
  final DateTime Function() _now;

  final _subscriptions = <StreamSubscription<Object?>>[];
  AppLifecycleListener? _lifecycle;

  /// Debug tools: extra test notifications, kept until they have fired.
  final _testNotifications = <ScheduledNotification>[];

  Future<void>? _running;
  bool _syncAgain = false;

  /// Starts listening and runs the first sync.
  Future<void> start() {
    _subscriptions
      ..add(_watchHabitChanges().listen((_) => sync()))
      ..add(_languageChanges.distinct().listen((_) => sync()));
    _lifecycle = AppLifecycleListener(onResume: sync);
    return sync();
  }

  /// Replaces the pending reminders. Calls during a sync are folded into one
  /// more run after it; the future completes once the reminders are current.
  Future<void> sync() {
    if (_running case final running?) {
      _syncAgain = true;
      return running;
    }
    return _running = _syncWhileRequested().whenComplete(() => _running = null);
  }

  /// Debug tools: a test reminder [delay] from now, through the same inexact
  /// scheduling as real ones.
  Future<void> scheduleTestReminder(
    Duration delay, {
    required String name,
  }) async {
    final copy = await _copy.load(_language());
    _testNotifications.add(
      ScheduledNotification(
        at: _now().add(delay),
        title: copy.title(name),
        body: copy.body,
      ),
    );
    await sync();
  }

  /// Debug tools: a test reminder right away.
  Future<void> showTestReminder({required String name}) async {
    final copy = await _copy.load(_language());
    await _notifications.showNow(
      ScheduledNotification(
        at: _now(),
        title: copy.title(name),
        body: copy.body,
      ),
      channel: copy.channel,
    );
  }

  Future<void> dispose() async {
    _lifecycle?.dispose();
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    _subscriptions.clear();
  }

  Future<void> _syncWhileRequested() async {
    do {
      _syncAgain = false;
      await _syncOnce();
    } while (_syncAgain);
  }

  Future<void> _syncOnce() async {
    try {
      final now = _now();
      final copy = await _copy.load(_language());
      final planned = _planner.plan(await _getHabits(), now);
      _testNotifications.removeWhere((n) => !n.at.isAfter(now));
      await _notifications.replaceScheduled([
        for (final reminder in planned)
          ScheduledNotification(
            at: reminder.at,
            title: copy.title(reminder.habit.name),
            body: copy.body,
          ),
        ..._testNotifications,
      ], channel: copy.channel);
    } catch (error, stackTrace) {
      // Reminders never take the app down; the next sync tries again.
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'reminders',
          context: ErrorDescription('scheduling habit reminders'),
        ),
      );
    }
  }
}
