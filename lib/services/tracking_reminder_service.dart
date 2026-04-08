import 'dart:io';

import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/controller/dashboard_controller.dart';
import 'package:diplomka/model/tracking_reminder_setting.dart';
import 'package:diplomka/screens/main_screen.dart';
import 'package:diplomka/services/shared_preferences_manager.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

const String trackingRemindersChannelId = 'tracking_reminders';

class TrackingReminderService extends GetxService {
  static TrackingReminderService get to => Get.find();

  final FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    await _configureLocalTimeZone();

    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );

    await notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
    await _createAndroidChannel();
    _initialized = true;
  }

  Future<void> _configureLocalTimeZone() async {
    tz_data.initializeTimeZones();

    try {
      final String localTimeZone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localTimeZone));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }
  }

  Future<void> _createAndroidChannel() async {
    final channel = AndroidNotificationChannel(
      trackingRemindersChannelId,
      tr(LocaleKeys.tracking_reminders_channel_name),
      description: tr(LocaleKeys.tracking_reminders_channel_desc),
      importance: Importance.high,
    );

    final AndroidFlutterLocalNotificationsPlugin? androidImplementation = notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidImplementation?.createNotificationChannel(channel);
  }

  Future<bool> hasNotificationPermission() async {
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation = notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      return await androidImplementation?.areNotificationsEnabled() ?? true;
    }

    if (Platform.isIOS) {
      final status = await Permission.notification.status;
      // Only return false for permanentlyDenied — that's when the user
      // explicitly denied and must go to system settings to fix it.
      // isDenied on iOS means "not yet asked", so treat it as OK.
      return !status.isPermanentlyDenied;
    }

    return true;
  }

  Future<bool> ensureNotificationPermission() async {
    await initialize();
    if (await hasNotificationPermission()) {
      return true;
    }

    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation = notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      final bool? granted = await androidImplementation?.requestNotificationsPermission();
      return granted ?? await hasNotificationPermission();
    }

    if (Platform.isIOS) {
      final IOSFlutterLocalNotificationsPlugin? iosImplementation = notificationsPlugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      final bool? granted = await iosImplementation?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return true;
  }

  Future<List<TrackingReminderSetting>> loadSettingsFromStorage() async {
    final List<TrackingReminderSetting> settings = [];
    for (final type in TrackingReminderType.values) {
      settings.add(await SharedPreferencesService.to.getTrackingReminderSetting(type));
    }
    return settings;
  }

  Future<void> rescheduleAllFromStorage() async {
    await initialize();
    final settings = await loadSettingsFromStorage();
    for (final setting in settings) {
      if (setting.enabled) {
        await scheduleReminder(setting);
      } else {
        await cancelReminder(setting.type);
      }
    }
  }

  Future<void> scheduleReminder(TrackingReminderSetting setting) async {
    await initialize();

    final scheduledDate = nextTriggerDate(setting.hour, setting.minute);
    final notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        trackingRemindersChannelId,
        tr(LocaleKeys.tracking_reminders_channel_name),
        channelDescription: tr(LocaleKeys.tracking_reminders_channel_desc),
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await notificationsPlugin.zonedSchedule(
      setting.type.notificationId,
      _notificationTitle(),
      _notificationBody(setting.type),
      scheduledDate,
      notificationDetails,
      payload: setting.type.code,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> cancelReminder(TrackingReminderType type) async {
    await initialize();
    await notificationsPlugin.cancel(type.notificationId);
  }

  tz.TZDateTime nextTriggerDate(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduleDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    if (!scheduleDate.isAfter(now)) {
      scheduleDate = scheduleDate.add(const Duration(days: 1));
    }

    return scheduleDate;
  }

  String _notificationTitle() {
    return tr(LocaleKeys.tracking_reminders_notification_title);
  }

  String _notificationBody(TrackingReminderType type) {
    switch (type) {
      case TrackingReminderType.breakfast:
        return tr(LocaleKeys.tracking_reminders_body_breakfast);
      case TrackingReminderType.lunch:
        return tr(LocaleKeys.tracking_reminders_body_lunch);
      case TrackingReminderType.snack:
        return tr(LocaleKeys.tracking_reminders_body_snack);
      case TrackingReminderType.dinner:
        return tr(LocaleKeys.tracking_reminders_body_dinner);
      case TrackingReminderType.endOfDay:
        return tr(LocaleKeys.tracking_reminders_body_end_of_day);
    }
  }

  static void _onNotificationTap(NotificationResponse response) {
    final payload = response.payload ?? '';
    if (payload.startsWith('motivational_')) {
      MainScreenController.to.showProgressTabAndScrollToEnergy();
    } else {
      // Tracking reminders → Dashboard on today's date
      MainScreenController.to.showDashboardTab();
      DashboardController.to.updateDate(DateTime.now());
    }
  }
}
