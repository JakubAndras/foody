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
      iOS: DarwinInitializationSettings(requestAlertPermission: true, requestBadgePermission: true, requestSoundPermission: true),
    );

    await notificationsPlugin.initialize(initializationSettings, onDidReceiveNotificationResponse: _onNotificationTap);
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
      _safeTr(LocaleKeys.tracking_reminders_channel_name),
      description: _safeTr(LocaleKeys.tracking_reminders_channel_desc),
      importance: Importance.high,
    );

    final AndroidFlutterLocalNotificationsPlugin? androidImplementation = notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidImplementation?.createNotificationChannel(channel);
  }

  /// Whether the OS permits scheduling exact alarms. Always true on iOS.
  /// On Android < 12 exact alarms work without runtime grant; permission_handler
  /// resolves those cases as already-granted.
  Future<bool> hasExactAlarmsPermission() async {
    if (!Platform.isAndroid) return true;
    final granted = await Permission.scheduleExactAlarm.isGranted;
    print('[Notifications] hasExactAlarms (Android): $granted');
    return granted;
  }

  /// Opens the system "Alarms & reminders" page (Android 12+) so the user can
  /// allow exact alarms. Returns the resulting grant state. Falls back to
  /// inexact scheduling automatically when the user declines.
  Future<bool> ensureExactAlarmsPermission() async {
    if (!Platform.isAndroid) return true;
    if (await Permission.scheduleExactAlarm.isGranted) return true;
    final status = await Permission.scheduleExactAlarm.request();
    print('[Notifications] Exact alarms permission requested: $status');
    return status.isGranted;
  }

  /// Picks `exactAllowWhileIdle` when the OS permits, otherwise falls back to
  /// `inexactAllowWhileIdle`. Inexact alarms may be delayed by Doze; exact ones
  /// fire on time.
  Future<AndroidScheduleMode> resolveAndroidScheduleMode() async {
    if (!Platform.isAndroid) return AndroidScheduleMode.exactAllowWhileIdle;
    return await hasExactAlarmsPermission() ? AndroidScheduleMode.exactAllowWhileIdle : AndroidScheduleMode.inexactAllowWhileIdle;
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
      final bool? granted = await iosImplementation?.requestPermissions(alert: true, badge: true, sound: true);
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
      await cancelReminder(setting.type);
      if (setting.enabled) {
        await scheduleReminder(setting);
      }
    }
  }

  Future<void> scheduleReminder(TrackingReminderSetting setting) async {
    await initialize();

    final scheduledDate = nextTriggerDate(setting.hour, setting.minute);
    final notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        trackingRemindersChannelId,
        _safeTr(LocaleKeys.tracking_reminders_channel_name),
        channelDescription: _safeTr(LocaleKeys.tracking_reminders_channel_desc),
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: const DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true),
    );

    final scheduleMode = await resolveAndroidScheduleMode();
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
        androidScheduleMode: scheduleMode,
      );
      print('[Notifications] Scheduled ${setting.type.code} for $scheduledDate (id=${setting.type.notificationId}, mode=$scheduleMode)');
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
    return _safeTr(LocaleKeys.tracking_reminders_notification_title);
  }

  String _notificationBody(TrackingReminderType type) {
    switch (type) {
      case TrackingReminderType.breakfast:
        return _safeTr(LocaleKeys.tracking_reminders_body_breakfast);
      case TrackingReminderType.lunch:
        return _safeTr(LocaleKeys.tracking_reminders_body_lunch);
      case TrackingReminderType.snack:
        return _safeTr(LocaleKeys.tracking_reminders_body_snack);
      case TrackingReminderType.dinner:
        return _safeTr(LocaleKeys.tracking_reminders_body_dinner);
      case TrackingReminderType.endOfDay:
        return _safeTr(LocaleKeys.tracking_reminders_body_end_of_day);
    }
  }

  String _safeTr(String key) {
    final resolved = tr(key);
    assert(() {
      if (resolved == key) {
        // ignore: avoid_print
        print('[Notifications] WARNING: tr() returned the raw key "$key" — EasyLocalization not ready.');
      }
      return true;
    }());
    return resolved;
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
