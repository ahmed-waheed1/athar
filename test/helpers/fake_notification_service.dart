import 'package:athar/core/di/injection.dart';
import 'package:athar/core/notifications/notification_permission_cubit.dart';
import 'package:athar/core/services/notification_service.dart';

/// Records what would be scheduled; the permission is whatever the test sets.
class FakeNotificationService implements NotificationService {
  FakeNotificationService({
    this.permissionState = NotificationPermission.granted,
    this.permissionAfterRequest = NotificationPermission.granted,
  });

  NotificationPermission permissionState;

  /// What the system prompt ends in.
  NotificationPermission permissionAfterRequest;

  /// The pending notifications after the last [replaceScheduled].
  List<ScheduledNotification> scheduled = const [];
  NotificationChannelInfo? channel;
  final shown = <ScheduledNotification>[];
  int replaceCalls = 0;
  int requestCalls = 0;
  int openSettingsCalls = 0;
  void Function()? onOpened;

  @override
  Future<void> initialize({required void Function() onOpened}) async =>
      this.onOpened = onOpened;

  @override
  Future<NotificationPermission> permission() async => permissionState;

  @override
  Future<NotificationPermission> requestPermission() async {
    requestCalls++;
    return permissionState = permissionAfterRequest;
  }

  @override
  Future<void> openSystemSettings() async => openSettingsCalls++;

  @override
  Future<void> replaceScheduled(
    List<ScheduledNotification> notifications, {
    required NotificationChannelInfo channel,
  }) async {
    replaceCalls++;
    scheduled = List.unmodifiable(notifications);
    this.channel = channel;
  }

  @override
  Future<void> showNow(
    ScheduledNotification notification, {
    required NotificationChannelInfo channel,
  }) async {
    shown.add(notification);
    this.channel = channel;
  }
}

/// Registers the [NotificationPermissionCubit] the router hands to Settings
/// and Add / Edit Habit, over [service] (granted by default). `sl.reset()`
/// closes it.
FakeNotificationService registerFakeNotifications([
  FakeNotificationService? service,
]) {
  final fake = service ?? FakeNotificationService();
  sl.registerLazySingleton(
    () => NotificationPermissionCubit(fake),
    dispose: (cubit) => cubit.close(),
  );
  return fake;
}
