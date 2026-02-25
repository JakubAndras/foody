import 'package:diplomka/screens/main_screen.dart';
import 'package:diplomka/screens/scan/scan_camera_screen.dart';
import 'package:diplomka/screens/scan/scan_onboarding_screen.dart';
import 'package:diplomka/services/home_widget/widget_constants.dart';
import 'package:diplomka/services/session_manager.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class WidgetActionRouter extends GetxService {
  static WidgetActionRouter get to => Get.find();

  Future<void> handleWidgetUri(Uri uri) async {
    if (!_isWidgetUri(uri)) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!SessionManager.to.onboardingComplete.value) return;

      MainScreenController.to.showDashboardTab();
      final action = _extractAction(uri);
      switch (action) {
        case WidgetConstants.actionOpenDashboard:
          return;
        case WidgetConstants.actionScanFood:
          _openScanFood();
          return;
        case WidgetConstants.actionScanBarcode:
          Get.to(() => const ScanCameraScreen(initialMode: ScanMode.barcode));
          return;
        default:
          return;
      }
    });
  }

  bool _isWidgetUri(Uri uri) {
    return uri.scheme == WidgetConstants.deepLinkScheme && uri.host == WidgetConstants.deepLinkHost;
  }

  String _extractAction(Uri uri) {
    if (uri.pathSegments.isNotEmpty) {
      return uri.pathSegments.first;
    }
    return uri.queryParameters['action'] ?? '';
  }

  void _openScanFood() {
    if (SessionManager.to.scanOnboardingComplete.value) {
      Get.to(() => const ScanCameraScreen());
      return;
    }
    Get.to(() => const ScanOnboardingScreen());
  }
}
