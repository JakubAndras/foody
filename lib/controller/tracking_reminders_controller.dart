import 'package:diplomka/model/tracking_reminder_setting.dart';
import 'package:diplomka/services/shared_preferences_manager.dart';
import 'package:diplomka/services/tracking_reminder_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class TrackingRemindersController extends GetxController {
  TrackingRemindersController({
    required this.sharedPreferencesService,
    required this.trackingReminderService,
  });

  static TrackingRemindersController get to => Get.find();

  final SharedPreferencesService sharedPreferencesService;
  final TrackingReminderService trackingReminderService;

  final RxList<TrackingReminderSetting> reminders = <TrackingReminderSetting>[].obs;
  final RxBool notificationPermissionDenied = false.obs;
  final RxBool isLoaded = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadInitialState();
  }

  Future<void> loadInitialState() async {
    reminders.value = await trackingReminderService.loadSettingsFromStorage();
    await refreshPermissionState();
    isLoaded.value = true;
  }

  Future<void> refreshPermissionState() async {
    final hasPermission = await trackingReminderService.hasNotificationPermission();
    notificationPermissionDenied.value = !hasPermission;
  }

  TrackingReminderSetting? reminderForType(TrackingReminderType type) {
    for (final reminder in reminders) {
      if (reminder.type == type) {
        return reminder;
      }
    }
    return null;
  }

  Future<void> toggleReminder(TrackingReminderType type, bool enabled) async {
    final current = reminderForType(type);
    if (current == null) {
      return;
    }

    if (enabled) {
      final granted = await trackingReminderService.ensureNotificationPermission();
      notificationPermissionDenied.value = !granted;
      if (!granted) {
        return;
      }
    }

    final updated = current.copyWith(enabled: enabled);
    _upsertReminder(updated);
    await sharedPreferencesService.setTrackingReminderSetting(updated);

    if (enabled) {
      await trackingReminderService.scheduleReminder(updated);
    } else {
      await trackingReminderService.cancelReminder(type);
    }
  }

  Future<void> changeReminderTime(TrackingReminderType type, TimeOfDay timeOfDay) async {
    final current = reminderForType(type);
    if (current == null) {
      return;
    }

    final updated = current.copyWith(hour: timeOfDay.hour, minute: timeOfDay.minute);
    _upsertReminder(updated);
    await sharedPreferencesService.setTrackingReminderSetting(updated);

    if (updated.enabled) {
      final hasPermission = await trackingReminderService.hasNotificationPermission();
      notificationPermissionDenied.value = !hasPermission;
      if (hasPermission) {
        await trackingReminderService.scheduleReminder(updated);
      }
    }
  }

  Future<void> openSystemNotificationSettings() async {
    await openAppSettings();
    await refreshPermissionState();

    if (!notificationPermissionDenied.value) {
      await trackingReminderService.rescheduleAllFromStorage();
    }
  }

  void _upsertReminder(TrackingReminderSetting updated) {
    final index = reminders.indexWhere((item) => item.type == updated.type);
    if (index == -1) {
      reminders.add(updated);
      return;
    }
    reminders[index] = updated;
  }
}
