import 'package:diplomka/controller/ask_ai_controller.dart';
import 'package:diplomka/controller/health_integration_controller.dart';
import 'package:diplomka/services/health_integration_service.dart';
import 'package:diplomka/controller/export_controller.dart';
import 'package:diplomka/controller/barcode_scan_controller.dart';
import 'package:diplomka/controller/dashboard_controller.dart';
import 'package:diplomka/controller/language_settings_controller.dart';
import 'package:diplomka/controller/motivational_summary_controller.dart';
import 'package:diplomka/controller/tracking_reminders_controller.dart';
import 'package:diplomka/services/motivational_summary_service.dart';
import 'package:diplomka/screens/main_screen.dart';
import 'package:diplomka/controller/day_record_controller.dart';
import 'package:diplomka/controller/recipe_service.dart';
import 'package:diplomka/services/day_record_repository.dart';
import 'package:diplomka/network/open_food_facts_client.dart';
import 'package:diplomka/services/barcode_lookup_service.dart';
import 'package:diplomka/services/calendar_day_ring_service.dart';
import 'package:diplomka/services/dietary_violation_service.dart';
import 'package:diplomka/services/selected_date_service.dart';
import 'package:diplomka/services/ai_feature/ai_attempt_log_service.dart';
import 'package:diplomka/services/ai_feature/ai_service_manager.dart';
import 'package:diplomka/services/ai_feature/gemini_service.dart';
import 'package:diplomka/services/ai_feature/openai_service.dart';
import 'package:diplomka/services/ai_feature/ai_pipeline_service.dart';
import 'package:diplomka/services/home_widget/widget_action_router.dart';
import 'package:diplomka/services/home_widget/widget_sync_service.dart';
import 'package:diplomka/services/language_settings_service.dart';
import 'package:diplomka/services/nutrition_goals_service.dart';
import 'package:diplomka/services/session_manager.dart';
import 'package:diplomka/services/streak_service.dart';
import 'package:diplomka/services/shared_preferences_manager.dart';
import 'package:diplomka/services/tracking_reminder_service.dart';
import 'package:diplomka/services/exercise_template_repository.dart';
import 'package:diplomka/services/ingredient_template_repository.dart';
import 'package:diplomka/services/meal_template_repository.dart';
import 'package:diplomka/services/weight_entry_repository.dart';
import 'package:diplomka/utils/media_storage.dart';
import 'package:get/get.dart';

import 'controller/streak_controller.dart';
import 'controller/weight_entry_controller.dart';
import 'database/app_database.dart';
import 'database/migrations.dart';
Future<void> setupServices() async {
  await MediaStorage.initialize();
  final AppDatabase db = await Get.putAsync(() => $FloorAppDatabase.databaseBuilder(AppDatabase.databaseName).addMigrations(appMigrations).build());

  /// Inicializace singleton GetxService - jednodušší nalezení controlleru v paměti;
  Get.lazyPut<SharedPreferencesService>(() => SharedPreferencesService());
  Get.lazyPut<OpenAiService>(() => OpenAiService());
  Get.lazyPut<GeminiService>(() => GeminiService());
  Get.put(AiServiceManager(), permanent: true);
  // RESEARCH-ONLY: research-only attempt log. Drop with telemetry.
  Get.put(AiAttemptLogService(database: db), permanent: true);
  Get.lazyPut<AiPipelineService>(() => AiPipelineService());
  Get.put(OpenFoodFactsClient(), permanent: true);
  Get.put(
    BarcodeLookupService(client: OpenFoodFactsClient.to),
    permanent: true,
  );
  Get.put(
    BarcodeScanController(lookupService: BarcodeLookupService.to),
    permanent: true,
  );
  Get.lazyPut<MainScreenController>(() => MainScreenController());
  Get.lazyPut<SessionManager>(() => SessionManager());
  Get.put(LanguageSettingsService(), permanent: true);
  Get.put(TrackingReminderService(), permanent: true);
  Get.put(MotivationalSummaryService(), permanent: true);
  Get.put(StreakService(), permanent: true);
  Get.put(WidgetActionRouter(), permanent: true);
  Get.put(WidgetSyncService(), permanent: true);
  Get.lazyPut<RecipeService>(() => RecipeService());
  Get.lazyPut<StreakController>(() => StreakController());
  Get.put(SelectedDateService(), permanent: true);
  //Get.lazyPut<GeniusSongRestClient>(() => GeniusSongRestClient());
  // Get.lazyPut<GeniusSongService>(() => GeniusSongService());

  /// Inicializace singleton GetxController -> permanent: true -> zamezí smazání z paměti
  Get.put(DayRecordRepository(database: db), permanent: true);
  Get.put(MealTemplateRepository(database: db), permanent: true);
  Get.put(ExerciseTemplateRepository(database: db), permanent: true);
  Get.put(IngredientTemplateRepository(database: db), permanent: true);
  Get.put(CalendarDayRingService(), permanent: true);
  Get.put(DietaryViolationService(), permanent: true);
  Get.put(
    DayRecordController(
      repository: DayRecordRepository.to,
      calendarDayRingService: Get.find<CalendarDayRingService>(),
    ),
    permanent: true,
  );
  Get.put(NutritionGoalsService(), permanent: true);
  Get.put(HealthIntegrationService(), permanent: true);
  Get.put(DashboardController(), permanent: true);
  Get.lazyPut<LanguageSettingsController>(
    () => LanguageSettingsController(
      languageSettingsService: LanguageSettingsService.to,
    ),
    fenix: true,
  );
  Get.lazyPut<TrackingRemindersController>(
    () => TrackingRemindersController(
      sharedPreferencesService: SharedPreferencesService.to,
      trackingReminderService: TrackingReminderService.to,
    ),
    fenix: true,
  );
  Get.lazyPut<MotivationalSummaryController>(
    () => MotivationalSummaryController(
      sharedPreferencesService: SharedPreferencesService.to,
      motivationalSummaryService: MotivationalSummaryService.to,
      trackingReminderService: TrackingReminderService.to,
    ),
    fenix: true,
  );
  Get.put(WeightEntryRepository(database: db), permanent: true);
  Get.put(WeightEntryController(repository: WeightEntryRepository.to), permanent: true);
  Get.lazyPut<HealthIntegrationController>(() => HealthIntegrationController(), fenix: true);
  Get.lazyPut<AskAiController>(() => AskAiController(), fenix: true);
  Get.lazyPut<ExportController>(() => ExportController(), fenix: true);
}
