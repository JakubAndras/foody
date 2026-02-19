import 'package:diplomka/controller/dashboard_controller.dart';
import 'package:diplomka/screens/main_screen.dart';
import 'package:diplomka/controller/day_record_controller.dart';
import 'package:diplomka/controller/recipe_service.dart';
import 'package:diplomka/services/day_record_repository.dart';
import 'package:diplomka/services/calendar_day_ring_service.dart';
import 'package:diplomka/services/selected_date_service.dart';
import 'package:diplomka/services/ai_feature/ai_service_manager.dart';
import 'package:diplomka/services/ai_feature/gemini_service.dart';
import 'package:diplomka/services/ai_feature/openai_service.dart';
import 'package:diplomka/services/ai_feature/ai_pipeline_service.dart';
import 'package:diplomka/services/session_manager.dart';
import 'package:diplomka/services/shared_preferences_manager.dart';
import 'package:diplomka/services/weight_entry_repository.dart';
import 'package:get/get.dart';

import 'controller/streak_controller.dart';
import 'controller/weight_entry_controller.dart';
import 'database/app_database.dart';
import 'database/migrations.dart';

Future<void> setupServices() async {
  final AppDatabase db = await Get.putAsync(() => $FloorAppDatabase
      .databaseBuilder(AppDatabase.databaseName)
      .addMigrations([migration1to2, migration2to3, migration3to4, migration4to5]).build());

  /// Inicializace singleton GetxService - jednodušší nalezení controlleru v paměti;
  Get.lazyPut<SharedPreferencesService>(() => SharedPreferencesService());
  Get.lazyPut<OpenAiService>(() => OpenAiService());
  Get.lazyPut<GeminiService>(() => GeminiService());
  Get.put(AiServiceManager(), permanent: true);
  Get.lazyPut<AiPipelineService>(() => AiPipelineService());
  Get.lazyPut<MainScreenController>(() => MainScreenController());
  Get.lazyPut<SessionManager>(() => SessionManager());
  Get.lazyPut<RecipeService>(() => RecipeService());
  Get.lazyPut<StreakController>(() => StreakController());
  Get.put(SelectedDateService(), permanent: true);
  //Get.lazyPut<GeniusSongRestClient>(() => GeniusSongRestClient());
  // Get.lazyPut<GeniusSongService>(() => GeniusSongService());

  /// Inicializace singleton GetxController -> permanent: true -> zamezí smazání z paměti
  Get.put(DayRecordRepository(database: db), permanent: true);
  Get.put(CalendarDayRingService(), permanent: true);
  Get.put(
    DayRecordController(
      repository: DayRecordRepository.to,
      calendarDayRingService: Get.find<CalendarDayRingService>(),
    ),
    permanent: true,
  );
  Get.put(DashboardController(), permanent: true);
  Get.put(WeightEntryRepository(database: db), permanent: true);
  Get.put(WeightEntryController(repository: WeightEntryRepository.to), permanent: true);
}
