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
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      ),
    );

    await notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
    await _createAndroidChannel();
    _initialized = true;
    print('[Notifications] Plugin initialized');
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
      final result = await androidImplementation?.areNotificationsEnabled() ?? true;
      print('[Notifications] hasPermission (Android): $result');
      return result;
    }

    if (Platform.isIOS) {
      final status = await Permission.notification.status;
      print('[Notifications] hasPermission (iOS): status=$status, isGranted=${status.isGranted}');
      return status.isGranted;
    }

    return true;
  }

  Future<bool> ensureNotificationPermission() async {
    await initialize();
    final alreadyGranted = await hasNotificationPermission();
    if (alreadyGranted) {
      print('[Notifications] Permission already granted');
      return true;
    }

    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation = notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      final bool? granted = await androidImplementation?.requestNotificationsPermission();
      print('[Notifications] Android permission requested: $granted');
      return granted ?? await hasNotificationPermission();
    }

    if (Platform.isIOS) {
      final IOSFlutterLocalNotificationsPlugin? iosImplementation = notificationsPlugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      print('[Notifications] iOS plugin resolved: ${iosImplementation != null}');
      final bool? granted = await iosImplementation?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      print('[Notifications] iOS permission requested: $granted');
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

    try {
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
      print('[Notifications] Scheduled ${setting.type.code} for $scheduledDate (id=${setting.type.notificationId})');
    } catch (e) {
      print('[Notifications] ERROR scheduling ${setting.type.code}: $e');
    }
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
    print('[Notifications] Tap received: payload=$payload, type=${response.notificationResponseType}');

    try {
      // Pop any pushed routes back to MainScreen so the tab switch is visible
      if (Get.currentRoute != '/') {
        Get.until((route) => route.isFirst);
      }

      if (payload.startsWith('motivational_')) {
        MainScreenController.to.showProgressTabAndScrollToEnergy();
      } else {
        // Tracking reminders → Dashboard on today's date
        MainScreenController.to.showDashboardTab();
        DashboardController.to.updateDate(DateTime.now());
      }
    } catch (e) {
      print('[Notifications] Error handling tap: $e');
    }
  }
}
