import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:diplomka/database/app_database.dart';

/// Riverpod DI kontrakt — Tier A (scaffold).
///
/// Autoritativní specifikace všech providerů je v `lib/di/CONTRACT.md`.
/// Tento soubor drží jen funkční jádro (`databaseProvider`). Ostatní providery
/// jsou **co-located** — deklarují se v souboru své třídy/Notifieru (viz CONTRACT.md).
/// Seznam níže je jen orientační mapa názvů → kde je hledat.
///
/// Konvence:
///  - bezstavová služba/klient/repo → `Provider<T>`
///  - reaktivní kolekce s async načtením → `AsyncNotifierProvider`
///  - reaktivní stav (controller/služba) → `NotifierProvider`
///  - Notifier NEnaviguje a NEukazuje dialog — vystaví stav, UI reaguje přes `ref.listen`.

// ── 0. Infrastruktura ────────────────────────────────────────────────────────

/// Databáze. Staví se v `main()` a injektuje se přes
/// `ProviderScope(overrides: [databaseProvider.overrideWithValue(db)])`.
final databaseProvider = Provider<AppDatabase>(
  (ref) => throw UnimplementedError('Override v main() přes ProviderScope.'),
);

/// Root ProviderContainer — nastaví `main()`. Slouží VÝHRADNĚ pro čtení providerů
/// z vnějších vstupních bodů mimo widget tree (tap na notifikaci, akce home widgetu,
/// deep-link). V běžném kódu (widgety, notifieri) čti přes `ref`, NIKDY přes tohle.
late ProviderContainer rootContainer;

/// Online/offline status z connectivity_plus. Nahrazuje `RestClient.hasNetworkConnection`
/// (RxBool). `true` = připojeno. `base_rest_client.dart` a `rest_client.dart` tím zanikají
/// (klienti mají vlastní Dio) — smazat v Tier C.
final networkStatusProvider = StreamProvider<bool>((ref) async* {
  final connectivity = Connectivity();
  final initial = await connectivity.checkConnectivity();
  yield initial != ConnectivityResult.none;
  yield* connectivity.onConnectivityChanged.map((result) => result != ConnectivityResult.none);
});

// ── 1. Síť & AI (S03–S07) ─────────────────────────────────────────────────────
//  openFoodFactsClientProvider   Provider<OpenFoodFactsClient>
//  openaiRestClientProvider      Provider<OpenaiRestClient>
//  geminiRestClientProvider      Provider<GeminiRestClient>
//  aiAttemptLogServiceProvider   Provider<AiAttemptLogService>       (databaseProvider)
//  openAiServiceProvider         Provider<OpenAiService>
//  geminiServiceProvider         Provider<GeminiService>
//  aiServiceManagerProvider      NotifierProvider<AiServiceManagerNotifier, AiServiceProviderType>
//  aiServiceProvider             Provider<AiService>                 (odvozený)
//  aiPipelineServiceProvider     Provider<AiPipelineService>

// ── 2. Repozitáře & data (S09, S11, S13, S15, S23) ────────────────────────────
//  dayRecordRepositoryProvider   Provider<DayRecordRepository>       (databaseProvider)
//  weightEntryRepositoryProvider Provider<WeightEntryRepository>     (databaseProvider)
//  mealTemplatesProvider         AsyncNotifierProvider<MealTemplatesNotifier, List<MealTemplate>>
//  ingredientTemplatesProvider   AsyncNotifierProvider<IngredientTemplatesNotifier, List<IngredientTemplate>>
//  exerciseTemplatesProvider     AsyncNotifierProvider<ExerciseTemplatesNotifier, List<ExerciseTemplate>>

// ── 3. Bezstavové služby (S08, S10, S16, S20–S22, S24) ────────────────────────
//  sharedPreferencesServiceProvider  Provider<SharedPreferencesService>
//  streakServiceProvider             Provider<StreakService>
//  calendarDayRingServiceProvider    Provider<CalendarDayRingService>
//  dietaryViolationServiceProvider   Provider<DietaryViolationService>   (sessionProvider)
//  recipeServiceProvider             Provider<RecipeService>
//  barcodeLookupServiceProvider      Provider<BarcodeLookupService>      (openFoodFactsClientProvider)
//  trackingReminderServiceProvider   Provider<TrackingReminderService>   (sharedPreferencesServiceProvider)
//  motivationalSummaryServiceProvider Provider<MotivationalSummaryService>
//  widgetSyncServiceProvider         Provider<WidgetSyncService>
//  widgetActionRouterProvider        Provider<WidgetActionRouter>

// ── 4. Stavové služby → Notifier (S12, S14, S17–S19) ──────────────────────────
//  sessionProvider               NotifierProvider<SessionNotifier, SessionState>
//  selectedDateProvider          NotifierProvider<SelectedDateNotifier, DateTime>
//  healthIntegrationProvider     NotifierProvider<HealthIntegrationNotifier, HealthIntegrationState>
//  languageSettingsServiceProvider Provider<LanguageSettingsService>
//  nutritionGoalsProvider        NotifierProvider<NutritionGoalsNotifier, Map<DateTime, NutritionGoals>>

// ── 5. Controllery → Notifier (C01–C12) ───────────────────────────────────────
//  streakInfoProvider            FutureProvider<StreakInfo>          (odvozený; StreakController se rozpouští)
//  weightEntriesProvider         AsyncNotifierProvider<WeightEntriesNotifier, List<WeightEntry>>
//  languageSettingsProvider      NotifierProvider<LanguageSettingsNotifier, LanguageSettingsState>
//  healthControllerProvider      NotifierProvider<HealthControllerNotifier, HealthControllerState>
//  motivationalSummaryProvider   NotifierProvider<MotivationalSummaryNotifier, MotivationalSummaryUiState>
//  trackingRemindersProvider     NotifierProvider<TrackingRemindersNotifier, TrackingRemindersUiState>
//  barcodeScanProvider           NotifierProvider<BarcodeScanNotifier, BarcodeScanUiState>
//  exportProvider                NotifierProvider<ExportNotifier, ExportState>
//  dayRecordProvider             NotifierProvider<DayRecordNotifier, DayRecordState>
//  askAiProvider                 NotifierProvider<AskAiNotifier, AskAiState>
//  dailyRecordProvider           NotifierProvider<DailyRecordNotifier, DailyRecordState>       (dashboard C12a)
//  mealAnalysisProvider          NotifierProvider<MealAnalysisNotifier, MealAnalysisState>     (dashboard C12b)
//  activityAnalysisProvider      NotifierProvider<ActivityAnalysisNotifier, ActivityAnalysisState> (dashboard C12c)
//  mainScreenProvider            NotifierProvider<MainScreenNotifier, int>                     (ověřit main_screen.dart)
//
// base_controller.dart se rozpouští (viz CONTRACT.md §0): hasInternet → UI helper nad
// networkStatusProvider, progressWidget → sdílený widget, lifecycle → AppLifecycleListener.
