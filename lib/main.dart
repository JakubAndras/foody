import 'package:diplomka/services/session_manager.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await setupServices();
  await SessionManager.to.onAppInit();

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
