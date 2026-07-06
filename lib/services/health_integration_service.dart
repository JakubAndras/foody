import 'dart:io';

import 'package:diplomka/state/day_record_notifier.dart';
import 'package:diplomka/model/exercise.dart';
import 'package:diplomka/services/day_record_repository.dart';
import 'package:diplomka/services/shared_preferences_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health/health.dart';
import 'package:url_launcher/url_launcher.dart';

/// Immutable stav integrace se zdravotními daty (Apple Health / Health Connect).
@immutable
class HealthIntegrationState {
  const HealthIntegrationState({
    this.isEnabled = false,
    this.lastSyncTime,
    this.hasPermission = false,
  });

  final bool isEnabled;
  final DateTime? lastSyncTime;
  final bool hasPermission;

  HealthIntegrationState copyWith({
    bool? isEnabled,
    Object? lastSyncTime = _undefined,
    bool? hasPermission,
  }) {
    return HealthIntegrationState(
      isEnabled: isEnabled ?? this.isEnabled,
      lastSyncTime: lastSyncTime == _undefined ? this.lastSyncTime : lastSyncTime as DateTime?,
      hasPermission: hasPermission ?? this.hasPermission,
    );
  }
}

/// Sentinel pro `copyWith`, aby šlo nullovatelné pole explicitně nastavit na `null`.
const Object _undefined = Object();

class HealthIntegrationNotifier extends Notifier<HealthIntegrationState> {
  final _health = Health();
  bool _configured = false;
  Future<void>? _settingsLoaded;

  String get platformName => Platform.isIOS ? 'Apple Health' : 'Health Connect';

  String get _sourceTag => Platform.isIOS ? 'apple_health' : 'health_connect';

  SharedPreferencesService get _prefs => ref.read(sharedPreferencesServiceProvider);

  @override
  HealthIntegrationState build() {
    _settingsLoaded = _loadSettings();
    return const HealthIntegrationState(isEnabled: false, lastSyncTime: null, hasPermission: false);
  }

  /// Await this before reading [HealthIntegrationState.isEnabled] to ensure SharedPreferences values are loaded.
  Future<void> waitForSettingsLoaded() => _settingsLoaded ?? Future.value();

  Future<void> _ensureConfigured() async {
    if (!_configured) {
      await _health.configure();
      _configured = true;
    }
  }

  Future<void> _loadSettings() async {
    final isEnabled = await _prefs.getBool(key: healthIntegrationEnabledKey) ?? false;
    DateTime? lastSyncTime;
    final lastSyncIso = await _prefs.getString(key: healthIntegrationLastSyncKey);
    if (lastSyncIso != null) {
      lastSyncTime = DateTime.tryParse(lastSyncIso);
    }
    state = state.copyWith(isEnabled: isEnabled, lastSyncTime: lastSyncTime);
  }

  Future<void> _persistSettings() async {
    await _prefs.setBool(key: healthIntegrationEnabledKey, value: state.isEnabled);
    if (state.lastSyncTime != null) {
      await _prefs.setString(key: healthIntegrationLastSyncKey, value: state.lastSyncTime!.toIso8601String());
    } else {
      await _prefs.remove(healthIntegrationLastSyncKey);
    }
  }

  Future<bool> requestPermission() async {
    try {
      await _ensureConfigured();
      final types = [HealthDataType.ACTIVE_ENERGY_BURNED];
      final permissions = [HealthDataAccess.READ];

      if (Platform.isAndroid) {
        final status = await _health.getHealthConnectSdkStatus();
        if (status != HealthConnectSdkStatus.sdkAvailable) {
          return false;
        }
      }

      final authorized = await _health.requestAuthorization(types, permissions: permissions);
      state = state.copyWith(hasPermission: authorized);
      return authorized;
    } catch (e) {
      print('HealthIntegrationService.requestPermission error: $e');
      state = state.copyWith(hasPermission: false);
      return false;
    }
  }

  Future<bool> toggleEnabled(bool enabled) async {
    if (enabled) {
      final granted = await requestPermission();
      if (!granted) return false;
      state = state.copyWith(isEnabled: true);
      await _persistSettings();
      await syncRecentDays();
      return true;
    } else {
      state = state.copyWith(isEnabled: false);
      await _persistSettings();
      return true;
    }
  }

  Future<void> syncToday() async {
    if (!state.isEnabled) return;
    final now = DateTime.now();
    await syncBurnedCalories(now);
  }

  /// Syncs burned calories for the last [maxDays] days up to today.
  /// Called on app startup to backfill days the user didn't open the app.
  Future<void> syncRecentDays({int maxDays = 3}) async {
    if (!state.isEnabled) return;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startDate = today.subtract(Duration(days: maxDays));

    var current = startDate;
    while (!current.isAfter(today)) {
      await syncBurnedCalories(current);
      current = current.add(const Duration(days: 1));
    }
  }

  Future<void> syncBurnedCalories(DateTime date) async {
    try {
      print('HealthSync: syncing date=${date.toIso8601String()}');
      final calories = await getActiveEnergyBurned(date) ?? 0;
      print('HealthSync: date=${date.toIso8601String()} calories=$calories');

      final repo = ref.read(dayRecordRepositoryProvider);
      final existing = await repo.findHealthSyncExercise(date: date, source: _sourceTag);
      print('HealthSync: existing=${existing?.id}, existingCal=${existing?.caloriesBurned}');

      // Skip if record already exists and calories haven't changed.
      if (existing != null && existing.caloriesBurned == calories) return;

      final exercise = Exercise(
        id: existing?.id,
        dayRecordId: existing?.dayRecordId,
        name: platformName,
        timestamp: existing?.timestamp ?? DateTime(date.year, date.month, date.day, 12),
        caloriesBurned: calories,
        source: _sourceTag,
      );

      await ref.read(dayRecordProvider.notifier).saveExerciseForDate(
            date: date,
            exerciseToSave: exercise,
          );

      state = state.copyWith(lastSyncTime: DateTime.now());
      await _persistSettings();
    } catch (e) {
      print('HealthIntegrationService.syncBurnedCalories error: $e');
    }
  }

  Future<double?> getActiveEnergyBurned(DateTime date) async {
    try {
      await _ensureConfigured();
      final start = DateTime(date.year, date.month, date.day);
      final end = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final dataPoints = await _health.getHealthDataFromTypes(
        types: [HealthDataType.ACTIVE_ENERGY_BURNED],
        startTime: start,
        endTime: end,
      );

      print('HealthSync: date=${date.toIso8601String()} dataPoints=${dataPoints.length}');

      if (dataPoints.isEmpty) return null;

      final cleaned = _health.removeDuplicates(dataPoints);
      print('HealthSync: date=${date.toIso8601String()} cleaned=${cleaned.length}');

      double total = 0;
      for (final point in cleaned) {
        final value = point.value;
        if (value is NumericHealthValue) {
          total += value.numericValue.toDouble();
        }
      }

      return total > 0 ? total : null;
    } catch (e) {
      print('HealthIntegrationService.getActiveEnergyBurned error: $e');
      return null;
    }
  }

  Future<void> openHealthApp() async {
    if (Platform.isIOS) {
      final uri = Uri.parse('x-apple-health://');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } else {
      final uri = Uri.parse('market://details?id=com.google.android.apps.healthdata');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    }
  }

  Future<bool> isHealthConnectAvailable() async {
    if (!Platform.isAndroid) return true;
    try {
      await _ensureConfigured();
      final status = await _health.getHealthConnectSdkStatus();
      return status == HealthConnectSdkStatus.sdkAvailable;
    } catch (_) {
      return false;
    }
  }
}

final healthIntegrationProvider = NotifierProvider<HealthIntegrationNotifier, HealthIntegrationState>(HealthIntegrationNotifier.new);
