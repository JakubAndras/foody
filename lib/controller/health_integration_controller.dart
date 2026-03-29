import 'package:diplomka/controller/dashboard_controller.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/services/health_integration_service.dart';
import 'package:diplomka/widgets/logged_snackbar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:get/get.dart';

class HealthIntegrationController extends GetxController {
  final _service = HealthIntegrationService.to;

  RxBool get isEnabled => _service.isEnabled;
  Rxn<DateTime> get lastSyncTime => _service.lastSyncTime;
  String get platformName => _service.platformName;

  final RxBool isSyncing = false.obs;

  Future<void> toggleSync(bool enabled) async {
    isSyncing.value = true;
    try {
      final success = await _service.toggleEnabled(enabled);
      if (!success && enabled) {
        showSnackBar(
          message: tr(LocaleKeys.error_permission_denied),
          subtitle: tr(LocaleKeys.health_sync_error, namedArgs: {'platform': platformName}),
          type: SnackBarType.error,
        );
      }
      if (success) {
        DashboardController.to.refresh();
      }
    } finally {
      isSyncing.value = false;
    }
  }

  Future<void> manualSync() async {
    isSyncing.value = true;
    try {
      await _service.syncToday();
      DashboardController.to.refresh();
    } finally {
      isSyncing.value = false;
    }
  }

  Future<void> openHealthApp() async {
    await _service.openHealthApp();
  }
}
