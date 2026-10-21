import 'package:app_settings/app_settings.dart' as system_settings;
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../theme/athar_colors.dart';
import 'notification_service.dart';

/// [NotificationService] on flutter_local_notifications (Android and iOS).
///
/// Reminders are one-off, inexact notifications
/// ([AndroidScheduleMode.inexactAllowWhileIdle]): no exact-alarm permission
/// is needed, and Android may deliver them a few minutes late.
class LocalNotificationService implements NotificationService {
  LocalNotificationService(
    this._prefs, {
    FlutterLocalNotificationsPlugin? plugin,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  /// Set once the system prompt has been shown, so a later "not enabled"
  /// reads as denied rather than not asked yet.
  static const permissionRequestedKey = 'notifications.permissionRequested';

  static const channelId = 'habit_reminders';

  /// Monochrome status-bar icon (android/app/src/main/res/drawable).
  static const androidIcon = 'ic_stat_athar';

  /// Debug test notifications; reminders are numbered from 0.
  static const _testNotificationId = 1 << 30;

  final SharedPreferences _prefs;
  final FlutterLocalNotificationsPlugin _plugin;

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  IOSFlutterLocalNotificationsPlugin? get _ios => _plugin
      .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin
      >();

  @override
  Future<void> initialize({required void Function() onOpened}) async {
    await _setUpTimeZone();
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings(androidIcon),
        // Never prompt at launch: the explanation sheet asks first.
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (_) => onOpened(),
    );
  }

  /// Reminders are scheduled by local wall-clock time, so the plugin needs
  /// the device's zone. Unknown zones fall back to UTC; times stay right
  /// because each one is converted from a local [DateTime].
  Future<void> _setUpTimeZone() async {
    tz_data.initializeTimeZones();
    try {
      final zone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(zone.identifier));
    } catch (error, stackTrace) {
      _report(error, stackTrace, 'reading the local time zone');
      tz.setLocalLocation(tz.UTC);
    }
  }

  @override
  Future<NotificationPermission> permission() async {
    if (await _enabled()) return NotificationPermission.granted;
    return _prefs.getBool(permissionRequestedKey) ?? false
        ? NotificationPermission.denied
        : NotificationPermission.notDetermined;
  }

  Future<bool> _enabled() async {
    if (_android case final android?) {
      return await android.areNotificationsEnabled() ?? false;
    }
    if (_ios case final ios?) {
      return (await ios.checkPermissions())?.isEnabled ?? false;
    }
    return false;
  }

  @override
  Future<NotificationPermission> requestPermission() async {
    await _prefs.setBool(permissionRequestedKey, true);
    if (_android case final android?) {
      await android.requestNotificationsPermission();
    } else if (_ios case final ios?) {
      await ios.requestPermissions(alert: true, sound: true);
    }
    return permission();
  }

  @override
  Future<void> openSystemSettings() =>
      system_settings.AppSettings.openAppSettings(
        type: system_settings.AppSettingsType.notification,
      );

  @override
  Future<void> replaceScheduled(
    List<ScheduledNotification> notifications, {
    required NotificationChannelInfo channel,
  }) async {
    // Creating an existing channel again renames it (language changes).
    await _android?.createNotificationChannel(
      AndroidNotificationChannel(
        channelId,
        channel.name,
        description: channel.description,
      ),
    );
    await _plugin.cancelAllPendingNotifications();
    final details = _details(channel);
    for (final (id, notification) in notifications.indexed) {
      await _plugin.zonedSchedule(
        id: id,
        scheduledDate: tz.TZDateTime.from(notification.at, tz.local),
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        title: notification.title,
        body: notification.body,
      );
    }
  }

  @override
  Future<void> showNow(
    ScheduledNotification notification, {
    required NotificationChannelInfo channel,
  }) => _plugin.show(
    id: _testNotificationId,
    title: notification.title,
    body: notification.body,
    notificationDetails: _details(channel),
  );

  NotificationDetails _details(NotificationChannelInfo channel) =>
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channel.name,
          channelDescription: channel.description,
          icon: androidIcon,
          color: AtharColors.light.primary,
        ),
        iOS: const DarwinNotificationDetails(),
      );

  void _report(Object error, StackTrace stackTrace, String context) =>
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'notifications',
          context: ErrorDescription(context),
        ),
      );
}
