import 'package:diplomka/services/motivational_summary_service.dart';
import 'package:diplomka/services/session_manager.dart';
import 'package:diplomka/services/home_widget/widget_sync_service.dart';
import 'package:diplomka/services/language_settings_service.dart';
import 'package:diplomka/services/tracking_reminder_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import 'app.dart';
import 'locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await LiquidGlassWidgets.initialize();
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {}
  await setupServices();
  await SessionManager.to.onAppInit();
  await LanguageSettingsService.to.load();
  await TrackingReminderService.to.initialize();
  await TrackingReminderService.to.rescheduleAllFromStorage();
  await MotivationalSummaryService.to.initialize();
  await MotivationalSummaryService.to.rescheduleAllFromStorage();
  await WidgetSyncService.to.initialize();

  runApp(
    EasyLocalization(
      supportedLocales: InitUtils.supportedLocales,
      path: InitUtils.localizationPath,
      fallbackLocale: InitUtils.supportedLocales.first,
      useFallbackTranslations: true,
      child: App(),
    ),
  );
}

class InitUtils {
  static String localizationPath = 'assets/translations';
  static List<Locale> supportedLocales = [
    const Locale('en'),
    const Locale('cs'),
  ];
}
