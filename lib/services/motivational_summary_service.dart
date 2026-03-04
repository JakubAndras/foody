import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/model/motivational_summary_setting.dart';
import 'package:diplomka/services/shared_preferences_manager.dart';
import 'package:diplomka/services/tracking_reminder_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:timezone/timezone.dart' as tz;

const String motivationalSummaryChannelId = 'motivational_summary';

class MotivationalSummaryService extends GetxService {
  static MotivationalSummaryService get to => Get.find();

  FlutterLocalNotificationsPlugin get _plugin => TrackingReminderService.to.notificationsPlugin;

  Future<void> initialize() async {
    await _createAndroidChannel();
  }

  Future<void> _createAndroidChannel() async {
    final channel = AndroidNotificationChannel(
      motivationalSummaryChannelId,
      tr(LocaleKeys.motivational_summary_channel_name),
      description: tr(LocaleKeys.motivational_summary_channel_desc),
      importance: Importance.high,
    );
    final androidImpl = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.createNotificationChannel(channel);
  }

  Future<List<MotivationalSummarySetting>> loadSettingsFromStorage() async {
    final List<MotivationalSummarySetting> settings = [];
    for (final type in MotivationalSummaryType.values) {
      settings.add(await SharedPreferencesService.to.getMotivationalSummarySetting(type));
    }
    return settings;
  }

  Future<void> rescheduleAllFromStorage() async {
    final settings = await loadSettingsFromStorage();
    for (final setting in settings) {
      if (setting.enabled) {
        await scheduleNotification(setting);
      } else {
        await cancelNotification(setting.type);
      }
    }
  }

  Future<void> scheduleNotification(MotivationalSummarySetting setting) async {
    final scheduledDate = _nextTriggerDate(setting);
    final notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        motivationalSummaryChannelId,
        tr(LocaleKeys.motivational_summary_channel_name),
        channelDescription: tr(LocaleKeys.motivational_summary_channel_desc),
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _plugin.zonedSchedule(
      setting.type.notificationId,
      tr(LocaleKeys.motivational_summary_notification_title),
      _notificationBody(setting.type),
      scheduledDate,
      notificationDetails,
      payload: 'motivational_${setting.type.code}',
      matchDateTimeComponents: setting.type.dateTimeComponents,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> cancelNotification(MotivationalSummaryType type) async {
    await _plugin.cancel(type.notificationId);
  }

  tz.TZDateTime _nextTriggerDate(MotivationalSummarySetting setting) {
    final now = tz.TZDateTime.now(tz.local);

    switch (setting.type) {
      case MotivationalSummaryType.daily:
        var date = tz.TZDateTime(tz.local, now.year, now.month, now.day, setting.hour, setting.minute);
        if (!date.isAfter(now)) {
          date = date.add(const Duration(days: 1));
        }
        return date;

      case MotivationalSummaryType.weekly:
        var date = tz.TZDateTime(tz.local, now.year, now.month, now.day, setting.hour, setting.minute);
        while (date.weekday != DateTime.sunday || !date.isAfter(now)) {
          date = date.add(const Duration(days: 1));
        }
        return date;

      case MotivationalSummaryType.monthly:
        var date = tz.TZDateTime(tz.local, now.year, now.month, 1, setting.hour, setting.minute);
        if (!date.isAfter(now)) {
          if (now.month == 12) {
            date = tz.TZDateTime(tz.local, now.year + 1, 1, 1, setting.hour, setting.minute);
          } else {
            date = tz.TZDateTime(tz.local, now.year, now.month + 1, 1, setting.hour, setting.minute);
          }
        }
        return date;
    }
  }

  String _notificationBody(MotivationalSummaryType type) {
    switch (type) {
      case MotivationalSummaryType.daily:
        return tr(LocaleKeys.motivational_summary_body_daily);
      case MotivationalSummaryType.weekly:
        return tr(LocaleKeys.motivational_summary_body_weekly);
      case MotivationalSummaryType.monthly:
        return tr(LocaleKeys.motivational_summary_body_monthly);
    }
  }
}
