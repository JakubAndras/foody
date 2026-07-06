import 'package:diplomka/navigation.dart';
import 'package:diplomka/screens/main_screen.dart';
import 'package:diplomka/screens/scan/scan_camera_screen.dart';
import 'package:diplomka/screens/scan/scan_onboarding_screen.dart';
import 'package:diplomka/services/home_widget/widget_constants.dart';
import 'package:diplomka/services/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Routuje akce z home widgetu (deep-link URI) na obrazovky aplikace.
/// Běží mimo widget tree, proto naviguje přes globální [navigatorKey] a čte
/// providery přes [Ref] (drženo v root [ProviderContainer]).
class WidgetActionRouter {
  WidgetActionRouter(this._ref);

  final Ref _ref;

  Future<void> handleWidgetUri(Uri uri) async {
    if (!_isWidgetUri(uri)) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_ref.read(sessionProvider).onboardingComplete) return;

      _ref.read(mainScreenProvider.notifier).changeTab(0);
      final action = _extractAction(uri);
      switch (action) {
        case WidgetConstants.actionOpenDashboard:
          return;
        case WidgetConstants.actionScanFood:
          _openScanFood();
          return;
        case WidgetConstants.actionScanBarcode:
          navigatorKey.currentState?.push(
            MaterialPageRoute(builder: (_) => const ScanCameraScreen(initialMode: ScanMode.barcode)),
          );
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
    if (_ref.read(sessionProvider).scanOnboardingComplete) {
      navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (_) => const ScanCameraScreen()),
      );
      return;
    }
    navigatorKey.currentState?.push(
      MaterialPageRoute(builder: (_) => const ScanOnboardingScreen()),
    );
  }
}

final widgetActionRouterProvider = Provider<WidgetActionRouter>(
  (ref) => WidgetActionRouter(ref),
);
