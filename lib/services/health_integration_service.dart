import 'dart:io';

import 'package:diplomka/controller/day_record_controller.dart';
import 'package:diplomka/model/exercise.dart';
import 'package:diplomka/services/day_record_repository.dart';
import 'package:diplomka/services/shared_preferences_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:health/health.dart';
import 'package:url_launcher/url_launcher.dart';

class HealthIntegrationService extends GetxService {
  static HealthIntegrationService get to => Get.find();

  final RxBool isEnabled = false.obs;
  final Rxn<DateTime> lastSyncTime = Rxn<DateTime>();
  final RxBool hasPermission = false.obs;

  final _health = Health();
  bool _configured = false;

  String get platformName => Platform.isIOS ? 'Apple Health' : 'Health Connect';

  String get _sourceTag => Platform.isIOS ? 'apple_health' : 'health_connect';

  SharedPreferencesService get _prefs => SharedPreferencesService.to;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  Future<void> _ensureConfigured() async {
    if (!_configured) {
      await _health.configure();
      _configured = true;
    }
  }

  Future<void> _loadSettings() async {
    isEnabled.value = await _prefs.getBool(key: healthIntegrationEnabledKey) ?? false;
    final lastSyncIso = await _prefs.getString(key: healthIntegrationLastSyncKey);
    if (lastSyncIso != null) {
      lastSyncTime.value = DateTime.tryParse(lastSyncIso);
    }
  }

  Future<void> _persistSettings() async {
    await _prefs.setBool(key: healthIntegrationEnabledKey, value: isEnabled.value);
    if (lastSyncTime.value != null) {
      await _prefs.setString(key: healthIntegrationLastSyncKey, value: lastSyncTime.value!.toIso8601String());
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
      hasPermission.value = authorized;
      return authorized;
    } catch (e) {
      debugPrint('HealthIntegrationService.requestPermission error: $e');
      hasPermission.value = false;
      return false;
    }
  }

  Future<bool> toggleEnabled(bool enabled) async {
    if (enabled) {
      final granted = await requestPermission();
      if (!granted) return false;
      isEnabled.value = true;
      await _persistSettings();
      await syncToday();
      return true;
    } else {
      isEnabled.value = false;
      await _persistSettings();
      return true;
    }
  }

  Future<void> syncToday() async {
    if (!isEnabled.value) return;
    final now = DateTime.now();
    await syncBurnedCalories(now);
  }

  Future<void> syncBurnedCalories(DateTime date) async {
    try {
      final calories = await getActiveEnergyBurned(date);
      if (calories == null || calories <= 0) return;

      final repo = DayRecordRepository.to;
      final existing = await repo.findHealthSyncExercise(date: date, source: _sourceTag);

      final exercise = Exercise(
        id: existing?.id,
        dayRecordId: existing?.dayRecordId,
        name: platformName,
        timestamp: existing?.timestamp ?? DateTime(date.year, date.month, date.day, 12),
        caloriesBurned: calories,
        source: _sourceTag,
      );

      await DayRecordController.to.saveExerciseForDate(
        date: date,
        exerciseToSave: exercise,
      );

      lastSyncTime.value = DateTime.now();
      await _persistSettings();
    } catch (e) {
      debugPrint('HealthIntegrationService.syncBurnedCalories error: $e');
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

      if (dataPoints.isEmpty) return null;

      final cleaned = _health.removeDuplicates(dataPoints);

      double total = 0;
      for (final point in cleaned) {
        final value = point.value;
        if (value is NumericHealthValue) {
          total += value.numericValue.toDouble();
        }
      }

      return total > 0 ? total : null;
    } catch (e) {
      debugPrint('HealthIntegrationService.getActiveEnergyBurned error: $e');
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
