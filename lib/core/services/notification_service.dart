import 'package:equatable/equatable.dart';

/// Whether the system lets Athar show notifications.
enum NotificationPermission {
  granted,

  /// Asked before and refused, or turned off in the system settings. Only
  /// the system settings can change it now.
  denied,

  /// Never asked: the explanation sheet (design/screens.md · 09) comes first.
  notDetermined,
}

/// One notification to show at [at], a local wall-clock time.
class ScheduledNotification extends Equatable {
  const ScheduledNotification({
    required this.at,
    required this.title,
    required this.body,
  });

  final DateTime at;
  final String title;
  final String body;

  @override
  List<Object> get props => [at, title, body];
}

/// The Android channel reminders are posted on, named in the app language.
class NotificationChannelInfo extends Equatable {
  const NotificationChannelInfo({
    required this.name,
    required this.description,
  });

  final String name;
  final String description;

  @override
  List<Object> get props => [name, description];
}

/// Local notifications, behind an interface so tests can use a fake.
abstract interface class NotificationService {
  /// Sets up the plugin and the local time zone. [onOpened] runs when the
  /// user taps a notification while the app is running.
  Future<void> initialize({required void Function() onOpened});

  Future<NotificationPermission> permission();

  /// Shows the system prompt (when the system still allows one) and returns
  /// the resulting permission.
  Future<NotificationPermission> requestPermission();

  /// Opens this app's notification settings in the system settings.
  Future<void> openSystemSettings();

  /// Replaces every pending reminder with [notifications]. Notifications
  /// already in the tray are left alone.
  Future<void> replaceScheduled(
    List<ScheduledNotification> notifications, {
    required NotificationChannelInfo channel,
  });

  /// Shows a notification right away (debug tools).
  Future<void> showNow(
    ScheduledNotification notification, {
    required NotificationChannelInfo channel,
  });
}
