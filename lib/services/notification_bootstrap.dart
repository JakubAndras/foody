import 'package:diplomka/services/motivational_summary_service.dart';
import 'package:diplomka/services/session_manager.dart';
import 'package:diplomka/services/shared_preferences_manager.dart';
import 'package:diplomka/services/tracking_reminder_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Bootstraps notification channels and scheduled reminders after
/// `EasyLocalization` has mounted, so that `tr()` resolves real strings
/// instead of raw locale keys.
///
/// Must be invoked from a post-frame callback (or any later point in the
/// widget lifecycle) — never from `main()` before `runApp()`. Volá se z widget
/// tree (root `App`), proto čte providery přes předaný [WidgetRef], ne přes
/// globální `rootContainer`.
class NotificationBootstrap {
  NotificationBootstrap._();

  static const String _channelMigrationFlag = 'notification_channels_migrated_v2';

  static bool _done = false;

  static Future<void> run(WidgetRef ref) async {
    if (_done) {
      return;
    }
    _done = true;

    await _migrateLegacyChannelsIfNeeded(ref);

    final trackingReminder = ref.read(trackingReminderServiceProvider);
    await trackingReminder.initialize();
    await trackingReminder.rescheduleAllFromStorage();
    final motivationalSummary = ref.read(motivationalSummaryServiceProvider);
    await motivationalSummary.initialize();
    await motivationalSummary.rescheduleAllFromStorage();

    if (ref.read(sessionProvider).onboardingComplete) {
      // ignore: avoid_print
      print('[Notifications] Requesting permission at startup...');
      final granted = await trackingReminder.ensureNotificationPermission();
      // ignore: avoid_print
      print('[Notifications] Permission result: $granted');
    } else {
      // ignore: avoid_print
      print('[Notifications] Skipping permission request (onboarding not complete)');
    }
  }

  /// One-time cleanup for testers that installed the buggy build. The old
  /// Android channels cached the raw locale keys as their display names;
  /// deleting them lets `initialize()` recreate them with the now-correctly
  /// translated names.
  static Future<void> _migrateLegacyChannelsIfNeeded(WidgetRef ref) async {
    final prefs = ref.read(sharedPreferencesServiceProvider);
    final migrated = await prefs.getBool(key: _channelMigrationFlag) ?? false;
    if (migrated) {
      return;
    }

    final android = ref.read(trackingReminderServiceProvider).notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    try {
      await android?.deleteNotificationChannel('tracking_reminders');
      await android?.deleteNotificationChannel('motivational_summary');
    } catch (e) {
      // ignore: avoid_print
      print('[Notifications] Legacy channel cleanup failed: $e');
    }
    await prefs.setBool(key: _channelMigrationFlag, value: true);
  }
}
