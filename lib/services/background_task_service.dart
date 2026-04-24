import 'dart:io';

import 'package:flutter/services.dart';

class BackgroundTaskService {
  BackgroundTaskService._();

  static const _channel = MethodChannel('com.foody/background_task');

  static Future<void> begin() async {
    if (!Platform.isIOS) return;
    try {
      await _channel.invokeMethod('beginBackgroundTask');
    } catch (_) {}
  }

  static Future<void> end() async {
    if (!Platform.isIOS) return;
    try {
      await _channel.invokeMethod('endBackgroundTask');
    } catch (_) {}
  }
}
