# Riverpod Contract (A2) — autoritativní slovník providerů

> Tento dokument je **jediný zdroj pravdy** pro migraci GetX → Riverpod (Tier B fan-out).
> Každý fan-out agent převádí právě jeden zdrojový soubor a MUSÍ použít názvy, typy a
> signatury přesně podle tohoto dokumentu. Vzory transformací viz `plans/refactor_migrate_getx_to_riverpod.md` (4.5).

## Konvence názvů

| Vrstva | Vzor názvu | Kind |
|--------|-----------|------|
| Bezstavová služba / klient / repozitář | `xxxServiceProvider` / `xxxClientProvider` / `xxxRepositoryProvider` | `Provider<T>` |
| Reaktivní kolekce s async načtením | `xxxProvider` | `AsyncNotifierProvider<Notifier, T>` |
| Reaktivní stav (controller/služba se stavem) | `xxxProvider` | `NotifierProvider<Notifier, State>` |
| Odvozený stav | `xxxProvider` | `Provider` / `FutureProvider` |

- Stavové třídy jsou **immutable** (`const` konstruktor, `copyWith`).
- Notifier NIKDY nenaviguje ani neukazuje dialog. Vystaví stav/událost, UI reaguje přes `ref.listen`.
- Závislosti se čtou přes `ref.read/watch(<provider>)`. Žádné `Get.find`, žádné `.to`, žádný globální locator v běžném kódu.
- Mimo widget tree (notifikace, home widget) se čte jen z root `ProviderContainer` drženého v `main()`.
- **Co-location:** provider se deklaruje ve **stejném souboru** jako jeho třída/Notifier (idiomatický Riverpod), NE v centrálním registru. `lib/di/providers.dart` drží jen `databaseProvider` (+ `networkStatusProvider`). Cross-reference funguje importem cílového souboru; názvy fixuje tento kontrakt.

### Referenční implementace (vzory — přesně je následuj)
- **`Provider` + db:** `lib/services/weight_entry_repository.dart` (`weightEntryRepositoryProvider`)
- **`Notifier` (jednoduchý stav):** `lib/services/selected_date_service.dart` (`selectedDateProvider`)
- **`AsyncNotifier` (async kolekce) + odvozený `Provider`:** `lib/state/weight_entry_notifier.dart` (`weightEntriesProvider`, `latestWeightEntryProvider`)

---

## 0. Databáze & infrastruktura

| Provider | Kind | Poznámka |
|----------|------|----------|
| `databaseProvider` | `Provider<AppDatabase>` | Override v `main()` (`overrideWithValue(db)`). Nahrazuje `Get.putAsync`. |
| `networkStatusProvider` | `StreamProvider<bool>` | Online/offline z `connectivity_plus`. Nahrazuje `RestClient.hasNetworkConnection` (RxBool). |

`base_controller.dart` se **rozpouští** (není provider):
- `hasInternet({withDialog})` → UI helper `requireInternet(ref, context)` čtoucí `networkStatusProvider` + `DialogUtils`.
- `progressWidget` → sdílený widget (`AppProgressIndicator`).
- lifecycle (`onResumed/onPaused/...`) → `AppLifecycleListener` v root widgetu; jednotliví notifieri, kteří to potřebují (dashboard), si registrují observer sami.

---

## 1. Síť & AI (skupina B-SVC: S01–S07)

| Provider | Kind | Zdroj (soubor) | Stav / klíčové metody | Závislosti |
|----------|------|----------------|------------------------|-----------|
| `openFoodFactsClientProvider` | `Provider<OpenFoodFactsClient>` | `network/open_food_facts_client.dart` (S03) | `fetchProductByBarcode(barcode,{locale})` | — |
| `openaiRestClientProvider` | `Provider<OpenaiRestClient>` | `network/openai_rest_client.dart` (S04) | `generateResponse/…/preScreenForInjection/fetchChatGptApiKey` | `aiAttemptLogServiceProvider` (telemetrie, guard) |
| `geminiRestClientProvider` | `Provider<GeminiRestClient>` | (network/gemini_rest_client.dart) | — | — |
| `aiAttemptLogServiceProvider` | `Provider<AiAttemptLogService>` | `ai_feature/ai_attempt_log_service.dart` (S05) | `log(...)`, `getAttempts(...)` | `databaseProvider` (konstruktor `database:`) |
| `openAiServiceProvider` | `Provider<OpenAiService>` | `ai_feature/openai_service.dart` | `generateResponse(...)` (impl `AiService`) | `openaiRestClientProvider` |
| `geminiServiceProvider` | `Provider<GeminiService>` | `ai_feature/gemini_service.dart` | `generateResponse(...)` (impl `AiService`) | `geminiRestClientProvider` |
| `aiServiceManagerProvider` | `NotifierProvider<AiServiceManagerNotifier, AiServiceProviderType>` | `ai_feature/ai_service_manager.dart` (S07) | stav = aktivní provider; `switchService(type)`; gettery `currentProviderCode/currentModelCode` | — |
| `aiServiceProvider` | `Provider<AiService>` | (odvozený) | vrací OpenAI/Gemini dle `aiServiceManagerProvider` | `aiServiceManagerProvider`, `openAiServiceProvider`, `geminiServiceProvider` |
| `aiPipelineServiceProvider` | `Provider<AiPipelineService>` | `ai_feature/ai_pipeline_service.dart` (S06) | `analyzeMeal/analyzeExercise/generateNutritionGoals` | `aiServiceProvider`, `aiServiceManagerProvider`, `aiAttemptLogServiceProvider`, `sessionProvider`, `openaiRestClientProvider` |

> `base_rest_client.dart` / `rest_client.dart` (S01/S02): reaktivní connectivity se přesouvá do `networkStatusProvider`; Dio konfigurace zůstává v klientech (`openaiRestClientProvider` atd.). `RestClient.to` mizí.
> `ai_service.dart` je čisté rozhraní (`AiService`), zůstává beze změny.

---

## 2. Repozitáře & data (skupina B-SVC: S09, S11, S13, S15, S23)

| Provider | Kind | Zdroj | Klíčové metody | Závislosti |
|----------|------|-------|----------------|-----------|
| `dayRecordRepositoryProvider` | `Provider<DayRecordRepository>` | `day_record_repository.dart` (S09) | `watchDayRecords/getDayRecord/upsertDayRecord/saveMealForDate/saveExerciseForDate/deleteMeal/deleteExercise/updateXFavorite/…` | `databaseProvider` |
| `weightEntryRepositoryProvider` | `Provider<WeightEntryRepository>` | `weight_entry_repository.dart` (S23) | `getAllEntries/watchEntries/upsertEntry/deleteEntry` | `databaseProvider` |
| `mealTemplatesProvider` | `AsyncNotifierProvider<MealTemplatesNotifier, List<MealTemplate>>` | `meal_template_repository.dart` (S15) | `build()`=load; `upsertFromMeal/setFavorite/deleteTemplate` (re-emit stavu) | `databaseProvider` |
| `ingredientTemplatesProvider` | `AsyncNotifierProvider<IngredientTemplatesNotifier, List<IngredientTemplate>>` | `ingredient_template_repository.dart` (S13) | `build()`=load; `upsertFromIngredient(s)/updateTemplate/setFavorite/deleteTemplate` | `databaseProvider` |
| `exerciseTemplatesProvider` | `AsyncNotifierProvider<ExerciseTemplatesNotifier, List<ExerciseTemplate>>` | `exercise_template_repository.dart` (S11) | `build()`=load; `upsertFromExercise/setFavorite/updateTemplateValues/deleteTemplate` | `databaseProvider` |

> Template repozitáře dnes drží `RxList allTemplates` + `onInit → refreshTemplates()`. V Riverpodu drží kolekci jako `state` (AsyncNotifier), `build()` provede iniciální load, mutační metody po zápisu do DB znovu načtou/aktualizují `state`.

---

## 3. Bezstavové služby (skupina B-SVC: S08, S10, S16, S18–S22, S24)

| Provider | Kind | Zdroj | Klíčové metody | Závislosti |
|----------|------|-------|----------------|-----------|
| `sharedPreferencesServiceProvider` | `Provider<SharedPreferencesService>` | `shared_preferences_manager.dart` (S20) | get/set*/tracking+motivational setting helpers | — |
| `streakServiceProvider` | `Provider<StreakService>` | `streak_service.dart` (S21) | `calculateStreakInfo(records,{now})` | — (čistá logika) |
| `calendarDayRingServiceProvider` | `Provider<CalendarDayRingService>` | `calendar_day_ring_service.dart` | `resolve(dayRecord,{consumed,effectiveGoal})` | — (čistá logika) |
| `dietaryViolationServiceProvider` | `Provider<DietaryViolationService>` | `dietary_violation_service.dart` (S10) | `checkIngredient/mealViolations/hasDietaryViolations/checkDayRecord` | `sessionProvider` (dietType, customDietPreferences) |
| `recipeServiceProvider` | `Provider<RecipeService>` | `services/recipe_service.dart` | `getRecipes()` | — (mock, aktuálně nevyužito) |
| `barcodeLookupServiceProvider` | `Provider<BarcodeLookupService>` | `barcode_lookup_service.dart` (S08) | `normalizeBarcode/isSupportedBarcode/lookupProductByBarcode/getEanCountryHint` | `openFoodFactsClientProvider`; locale (bez `Get.locale`) |
| `trackingReminderServiceProvider` | `Provider<TrackingReminderService>` | `tracking_reminder_service.dart` (S22) | `initialize/schedule/cancel/permission helpers/nextTriggerDate`; pole `notificationsPlugin` | `sharedPreferencesServiceProvider`; tap-callback → navigace přes `navigatorKey` |
| `motivationalSummaryServiceProvider` | `Provider<MotivationalSummaryService>` | `motivational_summary_service.dart` (S16) | `initialize/loadSettingsFromStorage/rescheduleAllFromStorage/schedule/cancel` | `trackingReminderServiceProvider`, `sharedPreferencesServiceProvider` |
| `widgetSyncServiceProvider` | `Provider<WidgetSyncService>` | `home_widget/widget_sync_service.dart` (S24) | `initialize/syncToday/syncRecord/syncFromRecordOrFallback`; `onClose` → `ref.onDispose` | `dayRecordProvider` (getDayRecord), `widgetActionRouterProvider` |
| `widgetActionRouterProvider` | `Provider<WidgetActionRouter>` | `home_widget/widget_action_router.dart` (S24) | `handleWidgetUri(uri)` | `sessionProvider`, `mainScreenProvider`; navigace přes `navigatorKey` |
| `healthIntegrationServiceProvider` | viz §4 (má reaktivní stav) | | | |

---

## 4. Stavové služby → Notifier (skupina B-SVC: S12, S14, S17, S18, S19)

| Provider | Kind | Zdroj | Stavová třída (pole) | Metody | Závislosti |
|----------|------|-------|----------------------|--------|-----------|
| `sessionProvider` | `NotifierProvider<SessionNotifier, SessionState>` | `session_manager.dart` (S19) | **SessionState** (immutable): `themeMode, caloriesPlanEnabled, onboardingComplete, scanOnboardingComplete, heightCm?, weightKg?, goalWeightKg?, sex?, goal?, dietType?, customDietPreferences?, prefersMetric, dateOfBirth?, weightChangeRateKgPerWeek?, savePhotosToGallery, burnedCaloriesEnabled, rolloverCaloriesEnabled, autoAdjustMacrosEnabled, editableNutrientsEnabled1, sectionHeaderPaddingEnabled, workoutsPerWeek?, voiceLogMode, bmr?`; getter `isDarkMode` | `onAppInit()`; `setThemeMode/setHeightCm/…` (všechny settery z analýzy) | `sharedPreferencesServiceProvider`; theme apply mimo GetX (`Get.changeThemeMode` → přes `themeMode` v `MaterialApp`) |
| `selectedDateProvider` | `NotifierProvider<SelectedDateNotifier, DateTime>` | `selected_date_service.dart` (S18) | stav = `DateTime` (normalizovaný) | `setSelectedDate(date)`; static `normalize` | — |
| `healthIntegrationProvider` | `NotifierProvider<HealthIntegrationNotifier, HealthIntegrationState>` | `health_integration_service.dart` (S12) | **HealthIntegrationState**: `isEnabled, lastSyncTime?, hasPermission`; getter `platformName` | `waitForSettingsLoaded/requestPermission/toggleEnabled/syncToday/syncRecentDays/syncBurnedCalories/getActiveEnergyBurned/openHealthApp/isHealthConnectAvailable` | `sharedPreferencesServiceProvider`, `dayRecordRepositoryProvider`, `dayRecordProvider` |
| `languageSettingsServiceProvider` | `Provider<LanguageSettingsService>` | `language_settings_service.dart` (S14) | (bezstavové po odebrání Rx) | `load/setVoiceLogLanguagePreference/resolveVoiceLogLanguageCode` | `sharedPreferencesServiceProvider` |
| `nutritionGoalsProvider` | `NotifierProvider<NutritionGoalsNotifier, Map<DateTime, NutritionGoals>>` | `nutrition_goals_service.dart` (S17) | stav = `goalsByDate` | `goalsForDate/refreshForDate/syncFromDayRecord/saveGoalsEffectiveFromDate` | `selectedDateProvider`, `dayRecordProvider`, `dayRecordRepositoryProvider` |

---

## 5. Controllery → Notifier (skupina B-CTL: C01–C13)

| Provider | Kind | Zdroj (task) | Stavová třída (pole) | Metody | Závislosti |
|----------|------|--------------|----------------------|--------|-----------|
| `streakInfoProvider` | `FutureProvider<StreakInfo>` (odvozený) | `streak_controller.dart` (C01) | — | odvozeno z day records | `dayRecordProvider`, `streakServiceProvider` |
| `weightEntriesProvider` | `AsyncNotifierProvider<WeightEntriesNotifier, List<WeightEntry>>` | `weight_entry_controller.dart` (C02) | stav = seznam; getter `latestEntry` | `build()`=refresh; `saveEntry/deleteEntry` | `weightEntryRepositoryProvider` |
| `languageSettingsProvider` | `NotifierProvider<LanguageSettingsNotifier, LanguageSettingsState>` | `language_settings_controller.dart` (C03) | **LanguageSettingsState**: `appLanguage, voiceLogLanguagePreference`; getter `effectiveVoiceLogLanguage` | `initializeFromContext(context)/setAppLanguage/setVoiceLogLanguagePreference` | `languageSettingsServiceProvider`; `context.locale`/`context.setLocale` |
| `healthControllerProvider` | `NotifierProvider<HealthControllerNotifier, HealthControllerState>` | `health_integration_controller.dart` (C04) | **HealthControllerState**: `isSyncing` (+ čte `healthIntegrationProvider` pro isEnabled/lastSyncTime/platformName) | `toggleSync/manualSync/openHealthApp` | `healthIntegrationProvider`, `dailyRecordProvider` (refresh) |
| `recipeServiceProvider` | `Provider<RecipeService>` | `recipe_service.dart` (C05) | — | `getRecipes()` | — |
| `motivationalSummaryProvider` | `NotifierProvider<MotivationalSummaryNotifier, MotivationalSummaryUiState>` | `motivational_summary_controller.dart` (C06) | **MotivationalSummaryUiState**: `summaries, notificationPermissionDenied, isLoaded` | `loadInitialState/settingForType/toggleSummary/changeSummaryTime/openSystemNotificationSettings` | `sharedPreferencesServiceProvider`, `motivationalSummaryServiceProvider`, `trackingReminderServiceProvider` |
| `trackingRemindersProvider` | `NotifierProvider<TrackingRemindersNotifier, TrackingRemindersUiState>` | `tracking_reminders_controller.dart` (C07) | **TrackingRemindersUiState**: `reminders, notificationPermissionDenied, isLoaded` | `loadInitialState/refreshPermissionState/reminderForType/toggleReminder/changeReminderTime/openSystemNotificationSettings` | `sharedPreferencesServiceProvider`, `trackingReminderServiceProvider` |
| `barcodeScanProvider` | `NotifierProvider<BarcodeScanNotifier, BarcodeScanUiState>` | `barcode_scan_controller.dart` (C08) | **BarcodeScanUiState**: `state(BarcodeScanState enum), latestResult?, activeBarcode, latestMessage, latestFailureType?`; getter `isProcessing` | `resetForScanning/processDetectedBarcode` | `barcodeLookupServiceProvider` |
| `exportProvider` | `NotifierProvider<ExportNotifier, ExportState>` | `export_controller.dart` (C09) | **ExportState**: `selectedRange(ExportDateRange), customStart?, customEnd?, isExporting` | `selectRange/setCustomDates/exportPdf/exportCsv` | `dayRecordRepositoryProvider`, `weightEntryRepositoryProvider`, `nutritionGoalsProvider`, `sessionProvider`, `aiAttemptLogServiceProvider`(guard) |
| `dayRecordProvider` | `NotifierProvider<DayRecordNotifier, DayRecordState>` | `day_record_controller.dart` (C10) | **DayRecordState**: `dayRecords(List<DayRecord>), weekRingStyles(Map<DateTime,CalendarDayRingStyle>)` | `loadWeek/getDayRecord/getAllDayRecords/addOrUpdateDayRecord/updateDayRecord/addDayRecord/getCalendarDays/saveMealForDate/saveExerciseForDate/deleteMeal/deleteExercise/setXFavorite/refreshDayRecords` | `dayRecordRepositoryProvider`, `calendarDayRingServiceProvider`, `sessionProvider`, `mealTemplatesProvider`, `ingredientTemplatesProvider`, `exerciseTemplatesProvider`, `widgetSyncServiceProvider`(guard) |
| `askAiProvider` | `NotifierProvider<AskAiNotifier, AskAiState>` | `ask_ai_controller.dart` (C11) | **AskAiState**: `query?(lastQuery), result(AsyncValue<AskAiQueryResponse?>)` (loading/error/data) | `clearResponse/submitQuery(query)` | `dayRecordRepositoryProvider`, `openaiRestClientProvider`, `sessionProvider`(guard), `aiAttemptLogServiceProvider`(guard) |
| `dailyRecordProvider` | `NotifierProvider<DailyRecordNotifier, DailyRecordState>` | `dashboard_controller.dart` (C12a) | **DailyRecordState**: `selectedDate, dayRecord?, isLoadingDayRecord, initialLoadComplete, dayRecordError, streak(AsyncValue<StreakInfo>) (loading/error/data), rolloverAmount` | `updateDate/refresh` (+ interní fetch/rollover/streak/health) | `dayRecordProvider`, `streakInfoProvider`, `selectedDateProvider`, `nutritionGoalsProvider`, `healthIntegrationProvider`, `sessionProvider`, `dayRecordRepositoryProvider` |
| `mealAnalysisProvider` | `NotifierProvider<MealAnalysisNotifier, MealAnalysisState>` | `dashboard_controller.dart` (C12b) | **MealAnalysisState**: `newMealAnalyzeLoading` | `pickImage/analyzeMealFromImage/analyzeMealFromVoice/analyzeMeal/analyzeMealFromBarcode` | `aiPipelineServiceProvider`, `aiServiceManagerProvider`, `barcodeLookupServiceProvider`, `dayRecordProvider` (save) |
| `activityAnalysisProvider` | `NotifierProvider<ActivityAnalysisNotifier, ActivityAnalysisState>` | `dashboard_controller.dart` (C12c) | **ActivityAnalysisState**: `newExerciseAnalyzeLoading, scrollToTodayMealsRequestId, scrollToExercisesRequestId` | `analyzeExerciseFromVoice/requestScrollToTodayMealsBottom/requestScrollToExercises` | `aiPipelineServiceProvider`, `dayRecordProvider` (save), `trackingReminderServiceProvider` |
| `mainScreenProvider` | `NotifierProvider<MainScreenNotifier, int>` | `screens/main_screen.dart` (⚠ mimo state/, ověřit) | stav = index taba | `changeTab(index)` | — |

> **C13 `base_controller.dart`** není provider — rozpouští se (viz §0).
> **Dashboard (C12a–c)** je rozdělen na 3 nezávislé notifiery → 3 paralelní agenti. Sdílené loading-visibility helpery (`_beginX/_endX`, min-visible 900 ms) extrahovat do `utils/loading_visibility.dart`.
> **`streakControllerProvider`** neexistuje — `StreakController` se rozpouští do odvozeného `streakInfoProvider` (FutureProvider nad day records).

---

## 5b. Migrační mapa pro UI (staré GetX → nový Riverpod)

Widgety: `StatelessWidget`+`Obx`/`GetView` → `ConsumerWidget`; `StatefulWidget` → `ConsumerStatefulWidget` (`ref` v `build`/State). `Obx(() => W)` → `Consumer(builder: (_, ref, _) => W)` nebo přímo `ref.watch(...)` v ConsumerWidget.

| Staré (GetX) | Nové (Riverpod) |
|--------------|-----------------|
| `Get.to(() => X())` | `Navigator.of(context).push(MaterialPageRoute(builder: (_) => const X()))` |
| `Get.back([r])` | `Navigator.of(context).pop(r)` |
| `Get.offAll(() => X())` | `Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const X()), (_) => false)` |
| `Get.theme` / `Get.context` | `Theme.of(context)` / `context` |
| `SessionManager.to.FIELD.value` | `ref.watch(sessionProvider).FIELD` (bez `.value`) |
| `SessionManager.to.setX(...)` | `ref.read(sessionProvider.notifier).setX(...)` |
| `SelectedDateService.to.selectedDate.value` | `ref.watch(selectedDateProvider)` |
| `SelectedDateService.to.setSelectedDate(d)` | `ref.read(selectedDateProvider.notifier).setSelectedDate(d)` |
| `DayRecordController.to.dayRecords` | `ref.watch(dayRecordProvider).dayRecords` |
| `DayRecordController.to.METODA(...)` | `ref.read(dayRecordProvider.notifier).METODA(...)` |
| `DashboardController.to` — denní záznam/streak/rollover (selectedDate, dayRecord, isLoadingDayRecord, streakInfo, streakError, isLoadingStreak, rolloverAmount, dayRecordError, updateDate, refresh) | `dailyRecordProvider` (stav) / `.notifier` (metody) |
| `DashboardController.to` — jídla (newMealAnalyzeLoading, analyzeMeal*, pickImage, analyzeMealFromBarcode) | `mealAnalysisProvider` |
| `DashboardController.to` — cvičení + scroll signály (newExerciseAnalyzeLoading, analyzeExerciseFromVoice, scrollToTodayMealsRequestId, scrollToExercisesRequestId, requestScroll*) | `activityAnalysisProvider` |
| `NutritionGoalsService.to.goalsForDate(...)` | `ref.watch(nutritionGoalsProvider)` (mapa) / `ref.read(nutritionGoalsProvider.notifier).goalsForDate(...)` |
| `WeightEntryController.to.entries` | `ref.watch(weightEntriesProvider)` (AsyncValue → `.when/.valueOrNull`) |
| `WeightEntryController.to.latestEntry` | `ref.watch(latestWeightEntryProvider)` |
| `WeightEntryController.to.METODA(...)` | `ref.read(weightEntriesProvider.notifier).METODA(...)` |
| `StreakController.to.getStreakInfo()` | `ref.watch(streakInfoProvider)` (AsyncValue<StreakInfo>) |
| `HealthIntegrationController.to` | `healthControllerProvider` (stav `isSyncing`; isEnabled/lastSyncTime přes `.notifier` gettery) |
| `HealthIntegrationService.to` | `ref.watch(healthIntegrationProvider)` / `.notifier` |
| `AskAiController.to` | `askAiProvider` (stav: `result` AsyncValue, `lastQuery`) / `.notifier.submitQuery(...)` |
| `ExportController.to` | `exportProvider` / `.notifier` |
| `BarcodeScanController.to` | `barcodeScanProvider` (pole `scanState`!) / `.notifier` |
| `LanguageSettingsController.to` | `languageSettingsProvider` / `.notifier` |
| `MotivationalSummaryController.to` | `motivationalSummaryProvider` / `.notifier` |
| `TrackingRemindersController.to` | `trackingRemindersProvider` / `.notifier` |
| `MainScreenController.to` | `mainScreenProvider` (stav `MainScreenState`) / `.notifier` |
| `Meal/Ingredient/ExerciseTemplateRepository.to.allTemplates` | `ref.watch(mealTemplatesProvider)` … (AsyncValue) |
| `...TemplateRepository.to.METODA(...)` | `ref.read(mealTemplatesProvider.notifier).METODA(...)` |
| `DietaryViolationService.to` | `ref.read(dietaryViolationServiceProvider)` |
| `CalendarDayRingService.to` | `ref.read(calendarDayRingServiceProvider)` |
| `RecipeService.to` | `ref.read(recipeServiceProvider)` |
| `AiPipelineService.to` | `ref.read(aiPipelineServiceProvider)` |
| Controller getter `progressWidget` | sdílený widget (Tier C: `AppProgressIndicator`) |
| Controller `hasInternet()` | UI helper nad `networkStatusProvider` (Tier C) |

Pozn.: metody, které dřív bývaly na controlleru a měnily stav, jsou nyní na `.notifier`. Čtení reaktivních polí přes `ref.watch(provider).pole`. Pro `AsyncNotifier` providery (weightEntries, templates, streakInfo, askAi.result) použij `.when(...)`/`.valueOrNull`.

## 6. Otevřené body kontraktu (rozhodnout před/na začátku Tier B)

- [ ] `mainScreenProvider` — ověřit `MainScreenController` v `screens/main_screen.dart` (registrován `Get.lazyPut`), doplnit přesná pole (tab index, případně FAB stav).
- [ ] `HealthIntegrationController` dnes nemá `.to` — po migraci se čte `healthControllerProvider`; ověřit všechny call-sites.
- [ ] Theme apply: `SessionManager` dnes volá `Get.changeThemeMode` + `AppColors.updateDarkMode`. Po migraci řídí téma `themeMode` ze `sessionProvider` → `MaterialApp.themeMode`; `AppColors.updateDarkMode` volat z UI reakce (`ref.listen(sessionProvider…)`).
- [ ] `LanguageSettingsService` vs `LanguageSettingsController` — reaktivní pole (`voiceLogLanguagePreference`) přesunuto z služby do `languageSettingsProvider` (notifier); služba zůstává bezstavová (persistence/resolve).
