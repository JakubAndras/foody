import 'package:diplomka/controller/dashboard_controller.dart';
import 'package:diplomka/screens/main_screen.dart';
import 'package:diplomka/controller/day_record_controller.dart';
import 'package:diplomka/controller/recipe_service.dart';
import 'package:diplomka/services/ai_feature/ai_service.dart';
import 'package:diplomka/services/ai_feature/gemini_service.dart';
import 'package:diplomka/services/ai_feature/openai_service.dart';
import 'package:diplomka/services/session_manager.dart';
import 'package:diplomka/services/shared_preferences_manager.dart';
import 'package:get/get.dart';

import 'controller/streak_controller.dart';
import 'database/app_database.dart';

Future<void> setupServices() async {
  final AppDatabase db = await Get.putAsync(() => $FloorAppDatabase
      .databaseBuilder(AppDatabase.databaseName)
      .build());

  /// Inicializace singleton GetxService - jednodušší nalezení controlleru v paměti;
  Get.lazyPut<SharedPreferencesService>(() => SharedPreferencesService());
  Get.lazyPut<OpenAiService>(() => OpenAiService());
  Get.lazyPut<GeminiService>(() => GeminiService());
  Get.lazyPut<MainScreenController>(() => MainScreenController());
  Get.lazyPut<SessionManager>(() => SessionManager());
  Get.lazyPut<RecipeService>(() => RecipeService());
  Get.lazyPut<StreakController>(() => StreakController());
  //Get.lazyPut<GeniusSongRestClient>(() => GeniusSongRestClient());
  // Get.lazyPut<GeniusSongService>(() => GeniusSongService());

  /// Inicializace singleton GetxController -> permanent: true -> zamezí smazání z paměti
  Get.put(DayRecordController(database: db), permanent: true);
  Get.put(DashboardController(), permanent: true);
}