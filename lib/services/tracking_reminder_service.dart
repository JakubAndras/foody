import 'dart:io';
import 'dart:ui';

import 'package:diplomka/model/tracking_reminder_setting.dart';
import 'package:diplomka/services/shared_preferences_manager.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

const String trackingRemindersChannelId = 'tracking_reminders';
const String trackingRemindersChannelName = 'Tracking Reminders';
const String trackingRemindersChannelDescription = 'Daily tracking reminder notifications.';

class TrackingReminderService extends GetxService {
  static TrackingReminderService get to => Get.find();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
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

    await _notificationsPlugin.initialize(initializationSettings);
    await _createAndroidChannel();
    _initialized = true;
  }

  Future<void> _configureLocalTimeZone() async {
    tz_data.initializeTimeZones();

    try {
      final String localTimeZone = await FlutterNativeTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localTimeZone));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }
  }

  Future<void> _createAndroidChannel() async {
    const channel = AndroidNotificationChannel(
      trackingRemindersChannelId,
      trackingRemindersChannelName,
      description: trackingRemindersChannelDescription,
      importance: Importance.high,
    );

    final AndroidFlutterLocalNotificationsPlugin? androidImplementation = _notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidImplementation?.createNotificationChannel(channel);
  }

  Future<bool> hasNotificationPermission() async {
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation = _notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      return await androidImplementation?.areNotificationsEnabled() ?? true;
    }

    if (Platform.isIOS) {
      final status = await Permission.notification.status;
      return status.isGranted || status.isLimited || status.isProvisional;
    }

    return true;
  }

  Future<bool> ensureNotificationPermission() async {
    await initialize();
    if (await hasNotificationPermission()) {
      return true;
    }

    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation = _notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      final bool? granted = await androidImplementation?.requestNotificationsPermission();
      return granted ?? await hasNotificationPermission();
    }

    if (Platform.isIOS) {
      final IOSFlutterLocalNotificationsPlugin? iosImplementation = _notificationsPlugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
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
      android: const AndroidNotificationDetails(
        trackingRemindersChannelId,
        trackingRemindersChannelName,
        channelDescription: trackingRemindersChannelDescription,
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _notificationsPlugin.zonedSchedule(
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
    await _notificationsPlugin.cancel(type.notificationId);
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
    final languageCode = PlatformDispatcher.instance.locale.languageCode.toLowerCase();
    if (languageCode == 'cs') {
      return 'Pripominka sledovani';
    }
    return 'Tracking Reminder';
  }

  String _notificationBody(TrackingReminderType type) {
    final languageCode = PlatformDispatcher.instance.locale.languageCode.toLowerCase();
    if (languageCode == 'cs') {
      switch (type) {
        case TrackingReminderType.breakfast:
          return 'Nezapomen zalogovat snidani.';
        case TrackingReminderType.lunch:
          return 'Nezapomen zalogovat obed.';
        case TrackingReminderType.snack:
          return 'Nezapomen zalogovat svacinu.';
        case TrackingReminderType.dinner:
          return 'Nezapomen zalogovat veceri.';
        case TrackingReminderType.endOfDay:
          return 'Nezapomen zapsat jidlo za cely den.';
      }
    }

    switch (type) {
      case TrackingReminderType.breakfast:
        return 'Do not forget to log your breakfast.';
      case TrackingReminderType.lunch:
        return 'Do not forget to log your lunch.';
      case TrackingReminderType.snack:
        return 'Do not forget to log your snack.';
      case TrackingReminderType.dinner:
        return 'Do not forget to log your dinner.';
      case TrackingReminderType.endOfDay:
        return 'Do not forget to log all meals for today.';
    }
  }
}
