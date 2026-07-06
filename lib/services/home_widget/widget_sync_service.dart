import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:diplomka/state/day_record_notifier.dart';
import 'package:diplomka/model/day_record.dart';
import 'package:diplomka/model/home_widget_payload.dart';
import 'package:diplomka/services/home_widget/widget_action_router.dart';
import 'package:diplomka/services/home_widget/widget_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';

class WidgetSyncService {
  WidgetSyncService(this._ref);

  final Ref _ref;

  StreamSubscription<Uri?>? _widgetClickSubscription;
  bool _isInitialized = false;
  bool _isIOSBridgeReady = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;

    await _configureBridgeIfNeeded();
    _bindWidgetActionListeners();
    await syncToday(reason: 'app_init');
  }

  Future<void> syncToday({String reason = 'manual'}) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dayRecord = await _ref.read(dayRecordProvider.notifier).getDayRecord(today);
    await syncFromRecordOrFallback(
      dayRecord,
      date: today,
      reason: reason,
    );
  }

  Future<void> syncRecord(
    DayRecord record, {
    String reason = 'manual',
  }) async {
    if (!_isSupportedPlatform) return;
    try {
      await _configureBridgeIfNeeded();

      final payload = _buildPayload(
        record: record,
        generatedAt: DateTime.now(),
      );
      final encoded = jsonEncode(payload.toJson());
      await HomeWidget.saveWidgetData<String>(WidgetConstants.payloadStorageKey, encoded);
      await HomeWidget.saveWidgetData<String>('home_widget_last_reason', reason);

      await _requestWidgetRefresh();
    } catch (error) {
      // Keep widget updates best-effort. UI flow must not fail due to widget bridge issues.
      debugPrint('Widget sync failed: $error');
    }
  }

  Future<void> syncFromRecordOrFallback(
    DayRecord? record, {
    required DateTime date,
    String reason = 'manual',
  }) async {
    await syncRecord(
      record ?? DayRecord.initial(date),
      reason: reason,
    );
  }

  HomeWidgetPayload _buildPayload({
    required DayRecord record,
    required DateTime generatedAt,
  }) {
    final caloriesGoal = record.calorieGoal;
    final rawProgress = caloriesGoal <= 0 ? 0.0 : record.totalCalories / caloriesGoal;
    final progress = rawProgress.clamp(0.0, 1.0);

    return HomeWidgetPayload(
      schemaVersion: WidgetConstants.schemaVersion,
      caloriesToday: record.totalCalories,
      caloriesGoal: record.calorieGoal,
      proteinToday: record.totalProteins,
      proteinGoal: record.proteinGoal,
      carbsToday: record.totalCarbs,
      carbsGoal: record.carbsGoal,
      fatToday: record.totalFats,
      fatGoal: record.fatGoal,
      progress: progress,
      lastUpdatedAtMillis: generatedAt.millisecondsSinceEpoch,
      quickActions: [
        HomeWidgetQuickAction(
          id: WidgetConstants.actionOpenDashboard,
          label: 'Dashboard',
          uri: _buildWidgetUri(WidgetConstants.actionOpenDashboard),
        ),
        HomeWidgetQuickAction(
          id: WidgetConstants.actionScanFood,
          label: 'Scan Food',
          uri: _buildWidgetUri(WidgetConstants.actionScanFood),
        ),
        HomeWidgetQuickAction(
          id: WidgetConstants.actionScanBarcode,
          label: 'Barcode',
          uri: _buildWidgetUri(WidgetConstants.actionScanBarcode),
        ),
      ],
    );
  }

  String _buildWidgetUri(String action) {
    return Uri(
      scheme: WidgetConstants.deepLinkScheme,
      host: WidgetConstants.deepLinkHost,
      path: action,
      queryParameters: const {'homeWidget': '1'},
    ).toString();
  }

  Future<void> _requestWidgetRefresh() async {
    if (Platform.isAndroid) {
      await HomeWidget.updateWidget(name: WidgetConstants.nutritionAndroidProvider);
      await HomeWidget.updateWidget(name: WidgetConstants.scanFoodAndroidProvider);
      await HomeWidget.updateWidget(name: WidgetConstants.barcodeAndroidProvider);
      return;
    }

    if (Platform.isIOS) {
      await HomeWidget.updateWidget(iOSName: WidgetConstants.nutritionIOSKind);
      await HomeWidget.updateWidget(iOSName: WidgetConstants.scanFoodIOSKind);
      await HomeWidget.updateWidget(iOSName: WidgetConstants.barcodeIOSKind);
    }
  }

  Future<void> _configureBridgeIfNeeded() async {
    if (!_isSupportedPlatform) return;
    if (Platform.isIOS && !_isIOSBridgeReady) {
      await HomeWidget.setAppGroupId(WidgetConstants.iOSAppGroupId);
      _isIOSBridgeReady = true;
    }
  }

  void _bindWidgetActionListeners() {
    if (!_isSupportedPlatform) return;

    _widgetClickSubscription ??= HomeWidget.widgetClicked.listen((uri) {
      if (uri == null) return;
      unawaited(_ref.read(widgetActionRouterProvider).handleWidgetUri(uri));
    });

    unawaited(() async {
      final launchUri = await HomeWidget.initiallyLaunchedFromHomeWidget();
      if (launchUri == null) return;
      await _ref.read(widgetActionRouterProvider).handleWidgetUri(launchUri);
    }());
  }

  bool get _isSupportedPlatform => Platform.isAndroid || Platform.isIOS;

  void dispose() {
    _widgetClickSubscription?.cancel();
    _widgetClickSubscription = null;
  }
}

final widgetSyncServiceProvider = Provider<WidgetSyncService>((ref) {
  final service = WidgetSyncService(ref);
  ref.onDispose(service.dispose);
  return service;
});
