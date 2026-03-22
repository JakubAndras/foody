import 'package:diplomka/model/motivational_summary_setting.dart';
import 'package:diplomka/services/motivational_summary_service.dart';
import 'package:diplomka/services/shared_preferences_manager.dart';
import 'package:diplomka/services/tracking_reminder_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class MotivationalSummaryController extends GetxController {
  MotivationalSummaryController({
    required this.sharedPreferencesService,
    required this.motivationalSummaryService,
    required this.trackingReminderService,
  });

  static MotivationalSummaryController get to => Get.find();

  final SharedPreferencesService sharedPreferencesService;
  final MotivationalSummaryService motivationalSummaryService;
  final TrackingReminderService trackingReminderService;

  final RxList<MotivationalSummarySetting> summaries = <MotivationalSummarySetting>[].obs;
  final RxBool notificationPermissionDenied = false.obs;
  final RxBool isLoaded = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadInitialState();
  }

  Future<void> loadInitialState() async {
    summaries.value = await motivationalSummaryService.loadSettingsFromStorage();
    await _refreshPermissionState();
    isLoaded.value = true;
  }

  Future<void> _refreshPermissionState() async {
    final hasPermission = await trackingReminderService.hasNotificationPermission();
    notificationPermissionDenied.value = !hasPermission;
  }

  MotivationalSummarySetting? settingForType(MotivationalSummaryType type) {
    for (final s in summaries) {
      if (s.type == type) return s;
    }
    return null;
  }

  Future<void> toggleSummary(MotivationalSummaryType type, bool enabled) async {
    final current = settingForType(type);
    if (current == null) return;

    if (enabled) {
      final granted = await trackingReminderService.ensureNotificationPermission();
      notificationPermissionDenied.value = !granted;
      if (!granted) return;
    }

    final updated = current.copyWith(enabled: enabled);
    _upsertSummary(updated);
    await sharedPreferencesService.setMotivationalSummarySetting(updated);

    if (enabled) {
      await motivationalSummaryService.scheduleNotification(updated);
    } else {
      await motivationalSummaryService.cancelNotification(type);
    }
  }

  Future<void> changeSummaryTime(MotivationalSummaryType type, TimeOfDay timeOfDay) async {
    final current = settingForType(type);
    if (current == null) return;

    final updated = current.copyWith(hour: timeOfDay.hour, minute: timeOfDay.minute);
    _upsertSummary(updated);
    await sharedPreferencesService.setMotivationalSummarySetting(updated);

    if (updated.enabled) {
      final hasPermission = await trackingReminderService.hasNotificationPermission();
      notificationPermissionDenied.value = !hasPermission;
      if (hasPermission) {
        await motivationalSummaryService.scheduleNotification(updated);
      }
    }
  }

  Future<void> openSystemNotificationSettings() async {
    await openAppSettings();
    await _refreshPermissionState();

    if (!notificationPermissionDenied.value) {
      await motivationalSummaryService.rescheduleAllFromStorage();
    }
  }

  void _upsertSummary(MotivationalSummarySetting updated) {
    final index = summaries.indexWhere((item) => item.type == updated.type);
    if (index == -1) {
      summaries.add(updated);
      return;
    }
    summaries[index] = updated;
  }
}
