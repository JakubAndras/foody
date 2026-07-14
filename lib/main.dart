import 'package:diplomka/database/app_database.dart';
import 'package:diplomka/database/migrations.dart';
import 'package:diplomka/di/providers.dart';
import 'package:diplomka/services/home_widget/widget_sync_service.dart';
import 'package:diplomka/services/language_settings_service.dart';
import 'package:diplomka/services/session_manager.dart';
import 'package:diplomka/utils/media_storage.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await LiquidGlassWidgets.initialize();
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {}

  await MediaStorage.initialize();

  // Databáze se staví před UI a injektuje se do grafu providerů přes override.
  final db = await $FloorAppDatabase.databaseBuilder(AppDatabase.databaseName).addMigrations(appMigrations).build();

  // Načtené SharedPreferences pro synchronní přístup v grafu providerů.
  final prefs = await SharedPreferences.getInstance();

  rootContainer = ProviderContainer(
    overrides: [
      databaseProvider.overrideWithValue(db),
      sharedPreferencesProvider.overrideWithValue(prefs),
    ],
  );

  await rootContainer.read(sessionProvider.notifier).onAppInit();
  await rootContainer.read(languageSettingsServiceProvider).load();
  await rootContainer.read(widgetSyncServiceProvider).initialize();

  runApp(
    UncontrolledProviderScope(
      container: rootContainer,
      child: EasyLocalization(
        supportedLocales: InitUtils.supportedLocales,
        path: InitUtils.localizationPath,
        fallbackLocale: InitUtils.supportedLocales.first,
        useFallbackTranslations: true,
        child: const App(),
      ),
    ),
  );
}

class InitUtils {
  static String localizationPath = 'assets/translations';
  static List<Locale> supportedLocales = [const Locale('en'), const Locale('cs')];
}
