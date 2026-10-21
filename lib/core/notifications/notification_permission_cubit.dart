import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../services/notification_service.dart';

/// Whether Athar may show notifications, shared by Settings and Add / Edit
/// Habit. Re-read whenever the app returns to the foreground, since the user
/// may have changed it in the system settings.
class NotificationPermissionCubit extends Cubit<NotificationPermission> {
  NotificationPermissionCubit(this._notifications)
    : super(NotificationPermission.notDetermined) {
    _lifecycle = AppLifecycleListener(onResume: refresh);
  }

  final NotificationService _notifications;
  late final AppLifecycleListener _lifecycle;

  Future<void> refresh() async {
    try {
      final permission = await _notifications.permission();
      if (!isClosed) emit(permission);
    } catch (error, stackTrace) {
      addError(error, stackTrace);
    }
  }

  /// Shows the system prompt. Returns the permission afterwards.
  Future<NotificationPermission> request() async {
    try {
      final permission = await _notifications.requestPermission();
      if (!isClosed) emit(permission);
    } catch (error, stackTrace) {
      addError(error, stackTrace);
    }
    return state;
  }

  Future<void> openSystemSettings() async {
    try {
      await _notifications.openSystemSettings();
    } catch (error, stackTrace) {
      addError(error, stackTrace);
    }
  }

  @override
  Future<void> close() {
    _lifecycle.dispose();
    return super.close();
  }
}
