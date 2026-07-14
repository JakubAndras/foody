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
import 'package:sqflite/sqflite.dart' show DatabaseException;

import 'app.dart';

/// Retry politika root ProviderContaineru (Riverpod 3.0).
///
/// AI a síťové chyby zásadně NEopakujeme: jde o placené requesty a chceme
/// okamžitou, viditelnou chybu místo tichého opakování. Přechodné chyby lokální
/// SQLite (busy/locked) naopak krátce zkusíme znovu, aby se DB-backed providery
/// (váha, šablony, streak) nezasekly natrvalo v error stavu po souběhu při startu.
/// Ostatní DB chyby (constraint, syntax, no such table...) jsou trvalé → neopakovat.
///
/// Přechodnost se pozná z textu hlášky, ne z `getResultCode()`: ten parsuje kód
/// z hlášky a při neznámém formátu vrací null (přeskočil by legitimní busy),
/// navíc by číselné porovnání mohlo splést ne-SQLite kód. SQLite hlásí zámek
/// napříč platformami textem „database is locked" / „database table is locked".
Duration? _rootRetry(int retryCount, Object error) {
  const maxRetries = 3;
  if (retryCount >= maxRetries) return null;
  if (error is! DatabaseException) return null;
  final message = error.toString().toLowerCase();
  final isTransient = message.contains('database is locked') ||
      message.contains('database table is locked') ||
      message.contains('database is busy') ||
      message.contains('sqlite_busy') ||
      message.contains('sqlite_locked');
  if (!isTransient) return null;
  return Duration(milliseconds: 200 * (1 << retryCount)); // 200 / 400 / 800 ms
}

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
    // Riverpod 3.0 defaultně 10× retry-uje chybující providery. Nahrazeno cílenou
    // politikou (viz `_rootRetry`): žádný retry pro AI/síť, krátký retry jen pro
    // přechodné chyby lokální SQLite.
    retry: _rootRetry,
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
