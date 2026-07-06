import 'package:diplomka/model/motivational_summary_setting.dart';
import 'package:diplomka/services/motivational_summary_service.dart';
import 'package:diplomka/services/shared_preferences_manager.dart';
import 'package:diplomka/services/tracking_reminder_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

/// Immutable UI stav pro obrazovku motivačních souhrnů.
@immutable
class MotivationalSummaryUiState {
  const MotivationalSummaryUiState({
    this.summaries = const <MotivationalSummarySetting>[],
    this.notificationPermissionDenied = false,
    this.isLoaded = false,
  });

  final List<MotivationalSummarySetting> summaries;
  final bool notificationPermissionDenied;
  final bool isLoaded;

  MotivationalSummaryUiState copyWith({
    List<MotivationalSummarySetting>? summaries,
    bool? notificationPermissionDenied,
    bool? isLoaded,
  }) {
    return MotivationalSummaryUiState(
      summaries: summaries ?? this.summaries,
      notificationPermissionDenied: notificationPermissionDenied ?? this.notificationPermissionDenied,
      isLoaded: isLoaded ?? this.isLoaded,
    );
  }
}

class MotivationalSummaryNotifier extends Notifier<MotivationalSummaryUiState> {
  SharedPreferencesService get _sharedPreferencesService => ref.read(sharedPreferencesServiceProvider);
  MotivationalSummaryService get _motivationalSummaryService => ref.read(motivationalSummaryServiceProvider);
  TrackingReminderService get _trackingReminderService => ref.read(trackingReminderServiceProvider);

  @override
  MotivationalSummaryUiState build() {
    loadInitialState();
    return const MotivationalSummaryUiState();
  }

  Future<void> loadInitialState() async {
    final summaries = await _motivationalSummaryService.loadSettingsFromStorage();
    state = state.copyWith(summaries: summaries);
    await _refreshPermissionState();
    state = state.copyWith(isLoaded: true);
  }

  Future<void> _refreshPermissionState() async {
    final hasPermission = await _trackingReminderService.hasNotificationPermission();
    state = state.copyWith(notificationPermissionDenied: !hasPermission);
  }

  MotivationalSummarySetting? settingForType(MotivationalSummaryType type) {
    for (final s in state.summaries) {
      if (s.type == type) return s;
    }
    return null;
  }

  Future<void> toggleSummary(MotivationalSummaryType type, bool enabled) async {
    final current = settingForType(type);
    if (current == null) return;

    if (enabled) {
      final granted = await _trackingReminderService.ensureNotificationPermission();
      state = state.copyWith(notificationPermissionDenied: !granted);
      if (!granted) return;
      await _trackingReminderService.ensureExactAlarmsPermission();
    }

    final updated = current.copyWith(enabled: enabled);
    _upsertSummary(updated);
    await _sharedPreferencesService.setMotivationalSummarySetting(updated);

    if (enabled) {
      await _motivationalSummaryService.scheduleNotification(updated);
    } else {
      await _motivationalSummaryService.cancelNotification(type);
    }
  }

  Future<void> changeSummaryTime(MotivationalSummaryType type, TimeOfDay timeOfDay) async {
    final current = settingForType(type);
    if (current == null) return;

    final updated = current.copyWith(hour: timeOfDay.hour, minute: timeOfDay.minute);
    _upsertSummary(updated);
    await _sharedPreferencesService.setMotivationalSummarySetting(updated);

    if (updated.enabled) {
      final hasPermission = await _trackingReminderService.hasNotificationPermission();
      state = state.copyWith(notificationPermissionDenied: !hasPermission);
      if (hasPermission) {
        await _motivationalSummaryService.scheduleNotification(updated);
      }
    }
  }

  Future<void> openSystemNotificationSettings() async {
    await openAppSettings();
    await _refreshPermissionState();

    if (!state.notificationPermissionDenied) {
      await _motivationalSummaryService.rescheduleAllFromStorage();
    }
  }

  void _upsertSummary(MotivationalSummarySetting updated) {
    final summaries = List<MotivationalSummarySetting>.from(state.summaries);
    final index = summaries.indexWhere((item) => item.type == updated.type);
    if (index == -1) {
      summaries.add(updated);
    } else {
      summaries[index] = updated;
    }
    state = state.copyWith(summaries: summaries);
  }
}

final motivationalSummaryProvider = NotifierProvider<MotivationalSummaryNotifier, MotivationalSummaryUiState>(MotivationalSummaryNotifier.new);
