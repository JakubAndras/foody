import 'package:diplomka/model/tracking_reminder_setting.dart';
import 'package:diplomka/services/shared_preferences_manager.dart';
import 'package:diplomka/services/tracking_reminder_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

/// Immutable stav připomínek pro sledování.
@immutable
class TrackingRemindersUiState {
  const TrackingRemindersUiState({
    this.reminders = const <TrackingReminderSetting>[],
    this.notificationPermissionDenied = false,
    this.isLoaded = false,
  });

  final List<TrackingReminderSetting> reminders;
  final bool notificationPermissionDenied;
  final bool isLoaded;

  TrackingRemindersUiState copyWith({
    List<TrackingReminderSetting>? reminders,
    bool? notificationPermissionDenied,
    bool? isLoaded,
  }) {
    return TrackingRemindersUiState(
      reminders: reminders ?? this.reminders,
      notificationPermissionDenied: notificationPermissionDenied ?? this.notificationPermissionDenied,
      isLoaded: isLoaded ?? this.isLoaded,
    );
  }
}

class TrackingRemindersNotifier extends Notifier<TrackingRemindersUiState> {
  SharedPreferencesService get _sharedPreferencesService => ref.read(sharedPreferencesServiceProvider);
  TrackingReminderService get _trackingReminderService => ref.read(trackingReminderServiceProvider);

  @override
  TrackingRemindersUiState build() {
    loadInitialState();
    return const TrackingRemindersUiState();
  }

  Future<void> loadInitialState() async {
    final reminders = await _trackingReminderService.loadSettingsFromStorage();
    state = state.copyWith(reminders: reminders);
    await refreshPermissionState();
    state = state.copyWith(isLoaded: true);
  }

  Future<void> refreshPermissionState() async {
    final hasPermission = await _trackingReminderService.hasNotificationPermission();
    state = state.copyWith(notificationPermissionDenied: !hasPermission);
  }

  TrackingReminderSetting? reminderForType(TrackingReminderType type) {
    for (final reminder in state.reminders) {
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
      final granted = await _trackingReminderService.ensureNotificationPermission();
      state = state.copyWith(notificationPermissionDenied: !granted);
      if (!granted) {
        return;
      }
      // Best-effort: ask for exact alarms so reminders fire on time. If the
      // user declines, scheduleReminder falls back to inexact mode.
      await _trackingReminderService.ensureExactAlarmsPermission();
    }

    final updated = current.copyWith(enabled: enabled);
    _upsertReminder(updated);
    await _sharedPreferencesService.setTrackingReminderSetting(updated);

    if (enabled) {
      await _trackingReminderService.scheduleReminder(updated);
    } else {
      await _trackingReminderService.cancelReminder(type);
    }
  }

  Future<void> changeReminderTime(TrackingReminderType type, TimeOfDay timeOfDay) async {
    final current = reminderForType(type);
    if (current == null) {
      return;
    }

    final updated = current.copyWith(hour: timeOfDay.hour, minute: timeOfDay.minute);
    _upsertReminder(updated);
    await _sharedPreferencesService.setTrackingReminderSetting(updated);

    if (updated.enabled) {
      final hasPermission = await _trackingReminderService.hasNotificationPermission();
      state = state.copyWith(notificationPermissionDenied: !hasPermission);
      if (hasPermission) {
        await _trackingReminderService.scheduleReminder(updated);
      }
    }
  }

  Future<void> openSystemNotificationSettings() async {
    await openAppSettings();
    await refreshPermissionState();

    if (!state.notificationPermissionDenied) {
      await _trackingReminderService.rescheduleAllFromStorage();
    }
  }

  void _upsertReminder(TrackingReminderSetting updated) {
    final reminders = List<TrackingReminderSetting>.from(state.reminders);
    final index = reminders.indexWhere((item) => item.type == updated.type);
    if (index == -1) {
      reminders.add(updated);
    } else {
      reminders[index] = updated;
    }
    state = state.copyWith(reminders: reminders);
  }
}

final trackingRemindersProvider = NotifierProvider<TrackingRemindersNotifier, TrackingRemindersUiState>(TrackingRemindersNotifier.new);
