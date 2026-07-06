import 'package:diplomka/state/dashboard_notifier.dart';
import 'package:diplomka/services/health_integration_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Immutable stav ovladače integrace se zdravotními daty.
///
/// Proxy hodnoty (`isEnabled`, `lastSyncTime`, `platformName`) se do stavu
/// NEkopírují — čtou se přímo z `healthIntegrationProvider` (viz gettery v notifieru).
@immutable
class HealthControllerState {
  const HealthControllerState({this.isSyncing = false});

  final bool isSyncing;

  HealthControllerState copyWith({bool? isSyncing}) {
    return HealthControllerState(isSyncing: isSyncing ?? this.isSyncing);
  }
}

class HealthControllerNotifier extends Notifier<HealthControllerState> {
  @override
  HealthControllerState build() => const HealthControllerState();

  // Proxy hodnoty na stav služby — nekopírují se do vlastního stavu.
  bool get isEnabled => ref.watch(healthIntegrationProvider).isEnabled;
  DateTime? get lastSyncTime => ref.watch(healthIntegrationProvider).lastSyncTime;
  String get platformName => ref.read(healthIntegrationProvider.notifier).platformName;

  Future<void> toggleSync(bool enabled) async {
    state = state.copyWith(isSyncing: true);
    try {
      final success = await ref.read(healthIntegrationProvider.notifier).toggleEnabled(enabled);
      if (success) {
        ref.read(dailyRecordProvider.notifier).refresh();
      }
    } finally {
      state = state.copyWith(isSyncing: false);
    }
  }

  Future<void> manualSync() async {
    state = state.copyWith(isSyncing: true);
    try {
      await ref.read(healthIntegrationProvider.notifier).syncToday();
      ref.read(dailyRecordProvider.notifier).refresh();
    } finally {
      state = state.copyWith(isSyncing: false);
    }
  }

  Future<void> openHealthApp() async {
    await ref.read(healthIntegrationProvider.notifier).openHealthApp();
  }
}

final healthControllerProvider = NotifierProvider<HealthControllerNotifier, HealthControllerState>(HealthControllerNotifier.new);
