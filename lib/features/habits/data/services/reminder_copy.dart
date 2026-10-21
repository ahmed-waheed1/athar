import 'dart:convert';

import 'package:flutter/services.dart';

import '../../../../core/localization/app_locales.dart';
import '../../../../core/services/notification_service.dart';
import '../../../settings/domain/entities/app_settings.dart';

/// Reminder notification text in one language (`reminders.notification` in
/// the translation files).
class ReminderCopy {
  const ReminderCopy({
    required this.titleTemplate,
    required this.body,
    required this.channel,
  });

  /// Contains `{name}`.
  final String titleTemplate;
  final String body;
  final NotificationChannelInfo channel;

  String title(String habitName) =>
      titleTemplate.replaceAll('{name}', habitName);
}

/// Reads [ReminderCopy] straight from assets/translations, for any language.
/// Reminders are rescheduled as soon as the language changes, before
/// easy_localization has loaded it for the UI.
class ReminderCopySource {
  ReminderCopySource({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;
  final _cache = <AppLanguage, ReminderCopy>{};

  Future<ReminderCopy> load(AppLanguage language) async {
    if (_cache[language] case final copy?) return copy;
    final json = jsonDecode(
      await _bundle.loadString(
        '${AppLocales.translationsPath}/'
        '${language.locale.languageCode}.json',
      ),
    ) as Map<String, dynamic>;
    final strings =
        (json['reminders'] as Map<String, dynamic>)['notification']
            as Map<String, dynamic>;
    return _cache[language] = ReminderCopy(
      titleTemplate: strings['title'] as String,
      body: strings['body'] as String,
      channel: NotificationChannelInfo(
        name: strings['channelName'] as String,
        description: strings['channelDescription'] as String,
      ),
    );
  }
}
