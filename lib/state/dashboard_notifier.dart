import 'dart:async';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:diplomka/state/day_record_notifier.dart';
import 'package:diplomka/state/streak_provider.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/model/barcode_lookup_result.dart';
import 'package:diplomka/model/day_record.dart';
import 'package:diplomka/model/exercise.dart';
import 'package:diplomka/model/ingredient.dart';
import 'package:diplomka/model/meal.dart';
import 'package:diplomka/model/meal_analysis_request.dart';
// RESEARCH-ONLY: imports for research-only telemetry wiring
import 'package:diplomka/model/meal_entry_source.dart';
import 'package:diplomka/services/ai_feature/ai_service_manager.dart';
// RESEARCH-ONLY: end
import 'package:diplomka/model/streak_info.dart';
import 'package:diplomka/services/ai_feature/ai_pipeline_service.dart';
import 'package:diplomka/services/barcode_lookup_service.dart';
import 'package:diplomka/services/day_record_repository.dart';
import 'package:diplomka/services/health_integration_service.dart';
import 'package:diplomka/services/nutrition_goals_service.dart';
import 'package:diplomka/services/selected_date_service.dart';
import 'package:diplomka/services/session_manager.dart';
import 'package:diplomka/services/tracking_reminder_service.dart';
import 'package:diplomka/utils/app_limits.dart';
import 'package:diplomka/utils/loading_visibility.dart';
import 'package:diplomka/utils/media_storage.dart';

/// Sentinel pro `copyWith`, aby šlo nullovatelná pole explicitně nastavit na `null`.
const Object _undefined = Object();

// =============================================================================
// 1) dailyRecordProvider — denní záznam, streak, rollover, health sync
// =============================================================================

/// Immutable stav dashboardu pro denní záznam a streak.
@immutable
class DailyRecordState {
  const DailyRecordState({
    required this.selectedDate,
    this.dayRecord,
    this.isLoadingDayRecord = false,
    this.initialLoadComplete = false,
    this.dayRecordError = '',
    this.streak = const AsyncLoading<StreakInfo>(),
    this.rolloverAmount = 0,
  });

  final DateTime selectedDate;
  final DayRecord? dayRecord;
  final bool isLoadingDayRecord;
  final bool initialLoadComplete;

  /// Locale klíč poslední chyby denního záznamu (dříve `showSnackBar`).
  /// Notifier nenaviguje ani nezobrazuje dialog; UI reaguje přes `ref.listen`.
  final String dayRecordError;

  /// Streak jako `AsyncValue` (loading/error/data) přebíraný z `streakInfoProvider`.
  /// Sjednocuje dřívější ruční trojici `streakInfo` + `isLoadingStreak` + `streakError`;
  /// UI čte přímo `streak.isLoading` / `streak.hasError` / `streak.valueOrNull`.
  final AsyncValue<StreakInfo> streak;

  final double rolloverAmount;

  DailyRecordState copyWith({
    DateTime? selectedDate,
    Object? dayRecord = _undefined,
    bool? isLoadingDayRecord,
    bool? initialLoadComplete,
    String? dayRecordError,
    AsyncValue<StreakInfo>? streak,
    double? rolloverAmount,
  }) {
    return DailyRecordState(
      selectedDate: selectedDate ?? this.selectedDate,
      dayRecord: dayRecord == _undefined ? this.dayRecord : dayRecord as DayRecord?,
      isLoadingDayRecord: isLoadingDayRecord ?? this.isLoadingDayRecord,
      initialLoadComplete: initialLoadComplete ?? this.initialLoadComplete,
      dayRecordError: dayRecordError ?? this.dayRecordError,
      streak: streak ?? this.streak,
      rolloverAmount: rolloverAmount ?? this.rolloverAmount,
    );
  }
}

///
/// Reaktivita nahrazuje původní `ever`/`listen` workery:
///  * `ref.watch(selectedDateProvider)` — při změně data se `build()` spustí
///    znovu a přenačte denní záznam (nahrazuje `selectedDate.listen`),
///  * `ref.watch(dayRecordProvider)` — při změně záznamů (např. po uložení
///    jídla/cvičení) se `build()` spustí znovu a přepočítá stav z aktuálních
///    záznamů (nahrazuje `ever(dayRecords, _updateStreakFromRecords)`),
///  * streak se přebírá z odvozeného `streakInfoProvider` (sám se přepočítá nad
///    aktuálními záznamy) a `ref.listen` jeho `AsyncValue` promítá do stavu.
class DailyRecordNotifier extends Notifier<DailyRecordState> {
  int _fetchGeneration = 0;
  bool _healthSyncKicked = false;

  // Pole přežívající napříč `build()` (stejná instance notifieru), aby se při
  // reaktivním rebuildu neztrácela kontinuita zobrazovaných hodnot.
  DayRecord? _lastDayRecord;
  bool _initialLoadComplete = false;
  double _lastRollover = 0;

  @override
  DailyRecordState build() {
    final selectedDate = ref.watch(selectedDateProvider);
    // Rebuild při změně záznamů → přenačtení denního záznamu i přepočet streaku.
    ref.watch(dayRecordProvider);

    // Streak z odvozeného provideru. `listen` promítá pozdější změny do stavu
    // bez dalšího rebuildu; iniciální hodnotu bereme přes `read`.
    ref.listen<AsyncValue<StreakInfo>>(streakInfoProvider, (previous, next) => _applyStreakAsync(next));
    final streakAsync = ref.read(streakInfoProvider);
    debugPrint('[Streak] dashboard build: streakAsync=$streakAsync (loading=${streakAsync.isLoading})');

    final generation = ++_fetchGeneration;
    unawaited(_fetchDayRecord(selectedDate, generation));

    // Health sync se spustí jen jednou (jinak by zápis cvičení → změna záznamů
    // → rebuild → další sync tvořily smyčku).
    if (!_healthSyncKicked) {
      _healthSyncKicked = true;
      unawaited(_syncHealthDataIfEnabled());
    }

    return DailyRecordState(
      selectedDate: selectedDate,
      dayRecord: _lastDayRecord,
      isLoadingDayRecord: true,
      initialLoadComplete: _initialLoadComplete,
      dayRecordError: '',
      rolloverAmount: _lastRollover,
      streak: streakAsync,
    );
  }

  void _applyStreakAsync(AsyncValue<StreakInfo> async) {
    debugPrint('[Streak] dashboard applyStreak: loading=${async.isLoading}, current=${async.valueOrNull?.currentStreak}, hasError=${async.hasError}');
    state = state.copyWith(streak: async);
  }

  Future<void> _syncHealthDataIfEnabled() async {
    try {
      final healthNotifier = ref.read(healthIntegrationProvider.notifier);
      await healthNotifier.waitForSettingsLoaded();
      if (ref.read(healthIntegrationProvider).isEnabled) {
        await healthNotifier.syncRecentDays();
        // Zápisy cvičení už změnily `dayRecordProvider`, což spustí rebuild;
        // pro jistotu vynutíme přenačtení i explicitně.
        refresh();
      }
    } catch (_) {
      // Health sync je best-effort; při chybě dashboard nerušíme.
    }
  }

  Future<void> _fetchDayRecord(DateTime date, int generation) async {
    // Závislosti zachytíme synchronně (běží ještě ve fázi build), aby se `ref`
    // nevolalo v async pokračování po případné změně watchnuté závislosti
    // (jinak Riverpod hodí „Cannot use ref functions after the dependency changed").
    final dayRecordNotifier = ref.read(dayRecordProvider.notifier);
    final nutritionGoals = ref.read(nutritionGoalsProvider.notifier);
    final session = ref.read(sessionProvider);
    final repository = ref.read(dayRecordRepositoryProvider);
    try {
      final record = await dayRecordNotifier.getDayRecord(date);
      if (generation != _fetchGeneration) return;
      nutritionGoals.syncFromDayRecord(date: date, dayRecord: record);
      final rollover = await _calculateRollover(session, repository, date);
      if (generation != _fetchGeneration) return;

      _lastDayRecord = record;
      _initialLoadComplete = true;
      _lastRollover = rollover;
      state = state.copyWith(dayRecord: record, isLoadingDayRecord: false, initialLoadComplete: true, dayRecordError: '', rolloverAmount: rollover);
    } catch (e) {
      if (generation != _fetchGeneration) return;
      nutritionGoals.syncFromDayRecord(date: date, dayRecord: null);

      _lastDayRecord = null;
      _lastRollover = 0;
      state = state.copyWith(dayRecord: null, isLoadingDayRecord: false, dayRecordError: LocaleKeys.common_something_went_wrong, rolloverAmount: 0);
    }
  }

  Future<double> _calculateRollover(SessionState session, DayRecordRepository repository, DateTime date) async {
    if (!session.rolloverCaloriesEnabled) return 0;
    final yesterday = date.subtract(const Duration(days: 1));
    final yesterdayRecord = await repository.getDayRecord(yesterday);
    if (yesterdayRecord == null) return 0;

    final bool burnedEnabled = session.burnedCaloriesEnabled;
    final double yesterdayConsumed = burnedEnabled ? yesterdayRecord.netCalories : yesterdayRecord.totalCalories;
    final double leftover = yesterdayRecord.calorieGoal - yesterdayConsumed;
    return leftover.clamp(0, 500);
  }

  void updateDate(DateTime newDate) {
    ref.read(selectedDateProvider.notifier).setSelectedDate(newDate);
  }

  void refresh() {
    final date = ref.read(selectedDateProvider);
    final generation = ++_fetchGeneration;
    unawaited(_fetchDayRecord(date, generation));
    ref.invalidate(streakInfoProvider);
  }
}

final dailyRecordProvider = NotifierProvider<DailyRecordNotifier, DailyRecordState>(DailyRecordNotifier.new);

// =============================================================================
// 2) mealAnalysisProvider — analýza jídla (foto / hlas / text / čárový kód)
// =============================================================================

/// Immutable stav analýzy jídla. Chyby se nevrací přes stav (stav drží jen
/// příznak načítání) — výsledky a chyby analýzy nesou návratové
/// `MealAnalysisFlowResult`.
@immutable
class MealAnalysisState {
  const MealAnalysisState({this.newMealAnalyzeLoading = false});

  final bool newMealAnalyzeLoading;

  MealAnalysisState copyWith({bool? newMealAnalyzeLoading}) {
    return MealAnalysisState(newMealAnalyzeLoading: newMealAnalyzeLoading ?? this.newMealAnalyzeLoading);
  }
}

/// Notifier nenaviguje a nezobrazuje snackbary; úspěch/neúspěch signalizují
/// návratové hodnoty a případná systémová notifikace na pozadí.
class MealAnalysisNotifier extends Notifier<MealAnalysisState> {
  final LoadingVisibilityTracker _visibility = LoadingVisibilityTracker();

  // TODO Tier C: skutečné napojení na AppLifecycleListener (onResumed/onPaused).
  // ignore: prefer_final_fields
  bool _isInForeground = true;

  @override
  MealAnalysisState build() => const MealAnalysisState();

  Future<void> pickImage(ImageSource source) async {
    // Camera always needs runtime permission. Gallery: iOS needs Photos
    // permission; Android 13+ uses the system Photo Picker via image_picker
    // which is sandboxed and requires no runtime permission.
    final bool needsPermission = source == ImageSource.camera || Platform.isIOS;
    if (needsPermission) {
      final permission = source == ImageSource.camera ? Permission.camera : Permission.photos;
      final status = await permission.request();

      if (!status.isGranted && !status.isLimited) {
        // Dříve showSnackBar (permission denied / open settings) — řeší UI (Tier C).
        debugPrint('Image permission denied for source=$source (permanentlyDenied=${status.isPermanentlyDenied})');
        return;
      }
    }

    final ImagePicker picker = ImagePicker();
    final XFile? imageFile = await picker.pickImage(source: source);

    if (imageFile == null) {
      debugPrint('No image selected.');
      return;
    }

    try {
      await analyzeMealFromImage(selectedDate: ref.read(selectedDateProvider), imagePath: imageFile.path);
    } catch (e) {
      debugPrint('Error calling AI Service: $e');
    }
  }

  Future<MealAnalysisFlowResult> analyzeMealFromImage({
    required DateTime selectedDate,
    String? imagePath,
    String? description,
    String? preferredMealName,
    bool scrollToTodayMealsOnStart = false,
  }) async {
    return analyzeMeal(
      MealAnalysisRequest(
        selectedDate: selectedDate,
        source: MealInputSource.photo,
        imagePath: imagePath,
        description: description,
        preferredMealName: preferredMealName,
        scrollToTodayMealsOnStart: scrollToTodayMealsOnStart,
      ),
    );
  }

  Future<MealAnalysisFlowResult> analyzeMealFromVoice({required DateTime selectedDate, required String description, bool scrollToTodayMealsOnStart = false}) {
    return analyzeMeal(MealAnalysisRequest.voice(selectedDate: selectedDate, description: description, scrollToTodayMealsOnStart: scrollToTodayMealsOnStart));
  }

  Future<MealAnalysisFlowResult> analyzeMeal(MealAnalysisRequest request) async {
    if (request.scrollToTodayMealsOnStart) {
      ref.read(activityAnalysisProvider.notifier).requestScrollToTodayMealsBottom();
    }

    if (request.source == MealInputSource.photo && request.trimmedImagePath == null) {
      return MealAnalysisFlowResult.failure(message: LocaleKeys.error_analysis_no_photo);
    }
    if (request.source == MealInputSource.voice && request.trimmedDescription == null) {
      return MealAnalysisFlowResult.failure(message: LocaleKeys.error_exercise_empty_desc);
    }

    _beginMealAnalysis();
    try {
      final String? rawImagePath = request.trimmedImagePath;
      final String? storedPhotoRef = await _resolvePhotoPath(rawImagePath);
      if (request.source == MealInputSource.photo && rawImagePath != null && storedPhotoRef == null) {
        return MealAnalysisFlowResult.failure(message: LocaleKeys.error_analysis_no_photo);
      }
      if (rawImagePath != null && storedPhotoRef == null) {
        debugPrint('Meal photo could not be persisted. sourcePath=$rawImagePath');
      }

      if (storedPhotoRef != null && ref.read(sessionProvider).savePhotosToGallery) {
        MediaStorage.saveToGallery(storedPhotoRef);
      }

      final String? resolvedPhotoPath = await MediaStorage.resolveStoredMealPhotoPath(storedPhotoRef);
      final List<File>? imageFiles = resolvedPhotoPath == null ? null : <File>[File(resolvedPhotoPath)];

      final flowResult = await _analyzeAndSaveMealWithAi(
        selectedDate: request.selectedDate,
        imageFiles: imageFiles,
        photoPathToSave: storedPhotoRef,
        description: request.trimmedDescription,
        preferredMealName: request.preferredMealName,
        // RESEARCH-ONLY: entrySource arg is research-only
        entrySource: request.source == MealInputSource.voice ? MealEntrySource.voiceAi : MealEntrySource.photoAi,
      );
      if (flowResult.success) {
        _notifyRecognitionComplete(message: tr(LocaleKeys.dashboard_meal_recognised), notificationId: 4001, showForegroundSnackBar: false);
      }
      return flowResult;
    } catch (e) {
      debugPrint('Error calling AI Service: $e');
      return MealAnalysisFlowResult.failure(message: e.toString());
    } finally {
      await _endMealAnalysis();
    }
  }

  Future<void> analyzeMealFromBarcode({required DateTime selectedDate, required String barcode}) async {
    ref.read(activityAnalysisProvider.notifier).requestScrollToTodayMealsBottom();
    _beginMealAnalysis();
    try {
      final BarcodeLookupResult? lookupResult = await _tryLookupBarcode(barcode);
      final String? barcodePhotoRef = await _resolveBarcodePhotoPath(lookupResult);
      if (barcodePhotoRef != null && ref.read(sessionProvider).savePhotosToGallery) {
        MediaStorage.saveToGallery(barcodePhotoRef);
      }
      final String? barcodePhotoPath = await MediaStorage.resolveStoredMealPhotoPath(barcodePhotoRef);
      final List<File>? barcodeImageFiles = barcodePhotoPath == null ? null : <File>[File(barcodePhotoPath)];

      if (lookupResult != null && lookupResult.hasCompleteNutrientsForDirectUse) {
        final meal = _buildMealFromBarcodeLookup(selectedDate: selectedDate, result: lookupResult, photoPath: barcodePhotoRef);
        await ref.read(dayRecordProvider.notifier).saveMealForDate(date: selectedDate, mealToSave: meal);
        _notifyRecognitionComplete(message: tr(LocaleKeys.dashboard_meal_recognised), notificationId: 4001, showForegroundSnackBar: false);
        return;
      }

      await _analyzeAndSaveMealWithAi(
        selectedDate: selectedDate,
        imageFiles: barcodeImageFiles,
        photoPathToSave: barcodePhotoRef,
        description: _buildBarcodeAiFallbackDescription(barcode: barcode, result: lookupResult),
        preferredMealName: lookupResult?.productName,
        // RESEARCH-ONLY: entrySource + barcodeOverride args are research-only
        entrySource: MealEntrySource.barcodeAiFallback,
        barcodeOverride: barcode,
      );
    } catch (e) {
      debugPrint('Error calling barcode analysis flow: $e');
    } finally {
      await _endMealAnalysis();
    }
  }

  Future<BarcodeLookupResult?> _tryLookupBarcode(String barcode) async {
    try {
      return await ref.read(barcodeLookupServiceProvider).lookupProductByBarcode(barcode);
    } on BarcodeLookupException {
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<MealAnalysisFlowResult> _analyzeAndSaveMealWithAi({
    required DateTime selectedDate,
    required List<File>? imageFiles,
    required String? photoPathToSave,
    // RESEARCH-ONLY: required entrySource + optional barcodeOverride are
    // research-only. Strip these params (and their use-sites below) when
    // removing telemetry.
    required MealEntrySource entrySource,
    String? description,
    String? preferredMealName,
    String? barcodeOverride,
  }) async {
    final result = await ref
        .read(aiPipelineServiceProvider)
        .analyzeMeal(
          imageFiles: imageFiles,
          description: description,
          // RESEARCH-ONLY: modality routed to AiAttempt log
          modality: entrySource.code,
        );

    if (result.isSuccess && result.response != null) {
      // RESEARCH-ONLY: providerCode/modelCode reads are research-only
      final providerCode = ref.read(aiServiceManagerProvider.notifier).currentProviderCode;
      final modelCode = ref.read(aiServiceManagerProvider.notifier).currentModelCode;
      Meal meal = Meal.fromAnswer(result.response!.answer).copyWith(
        timestamp: _applyDateToTime(DateTime.now(), selectedDate),
        photoPath: photoPathToSave,
        // RESEARCH-ONLY: research-only fields below
        inputSource: entrySource.code,
        aiProvider: providerCode,
        aiModel: modelCode,
        barcode: barcodeOverride,
      );
      final String trimmedName = preferredMealName?.trim() ?? '';
      if (trimmedName.isNotEmpty) {
        meal = meal.copyWith(name: trimmedName);
      }

      await ref.read(dayRecordProvider.notifier).saveMealForDate(date: selectedDate, mealToSave: meal);
      return MealAnalysisFlowResult.success(status: result.status);
    } else {
      return MealAnalysisFlowResult.failure(message: result.message);
    }
  }

  Meal _buildMealFromBarcodeLookup({required DateTime selectedDate, required BarcodeLookupResult result, String? photoPath}) {
    final timestamp = _applyDateToTime(DateTime.now(), selectedDate);
    final nutriments = result.nutriments;
    final productWeight = _parseProductWeightGrams(result.quantity);
    final scale = productWeight / 100.0;

    return Meal(
      name: result.productName,
      ingredients: <Ingredient>[
        Ingredient(
          name: result.productName,
          weight: productWeight,
          amount: 1,
          calories: ((nutriments.caloriesPer100g ?? 0) * scale).clamp(0, AppLimits.ingredientMaxCalories.toDouble()),
          proteins: ((nutriments.proteinsPer100g ?? 0) * scale).clamp(0, AppLimits.ingredientMaxMacro.toDouble()),
          carbs: ((nutriments.carbsPer100g ?? 0) * scale).clamp(0, AppLimits.ingredientMaxMacro.toDouble()),
          fats: ((nutriments.fatsPer100g ?? 0) * scale).clamp(0, AppLimits.ingredientMaxMacro.toDouble()),
        ),
      ],
      timestamp: timestamp,
      photoPath: photoPath,
      barcode: result.barcode,
      // RESEARCH-ONLY: research-only field
      inputSource: MealEntrySource.barcode.code,
    );
  }

  /// Parses product weight in grams from the Open Food Facts quantity string.
  /// Handles formats like "190 g", "200g", "4 x 125 g", "500 ml".
  /// Returns 100 as fallback when parsing fails.
  double _parseProductWeightGrams(String? quantity) {
    if (quantity == null || quantity.isEmpty) return 100;
    final normalized = quantity.trim().toLowerCase();

    // Handle "4 x 125 g" style (multi-pack)
    final multiMatch = RegExp(r'(\d+)\s*[x×]\s*(\d+(?:[.,]\d+)?)\s*(g|ml)').firstMatch(normalized);
    if (multiMatch != null) {
      final count = double.tryParse(multiMatch.group(1)!) ?? 1;
      final unit = double.tryParse(multiMatch.group(2)!.replaceAll(',', '.')) ?? 100;
      return count * unit;
    }

    // Handle simple "190 g", "200g", "500 ml", "1.5 kg", "1 l"
    final simpleMatch = RegExp(r'(\d+(?:[.,]\d+)?)\s*(kg|g|ml|l|cl)\b').firstMatch(normalized);
    if (simpleMatch != null) {
      final value = double.tryParse(simpleMatch.group(1)!.replaceAll(',', '.')) ?? 100;
      final unit = simpleMatch.group(2)!;
      if (unit == 'kg') return value * 1000;
      if (unit == 'l') return value * 1000;
      if (unit == 'cl') return value * 10;
      return value; // g or ml
    }

    return 100;
  }

  String _buildBarcodeAiFallbackDescription({required String barcode, BarcodeLookupResult? result}) {
    final buffer = StringBuffer();
    buffer.writeln('Barcode scan fallback request.');
    buffer.writeln('barcode: $barcode');
    final countryHint = ref.read(barcodeLookupServiceProvider).getEanCountryHint(barcode);
    if (countryHint != null) {
      buffer.writeln('product_origin: $countryHint');
    }
    if (result != null) {
      buffer.writeln('product_name: ${result.productName}');
      if (result.brand != null && result.brand!.isNotEmpty) {
        buffer.writeln('brand: ${result.brand}');
      }
      if (result.quantity != null && result.quantity!.isNotEmpty) {
        buffer.writeln('quantity: ${result.quantity}');
      }
      final nutriments = result.nutriments;
      if (nutriments.caloriesPer100g != null) {
        buffer.writeln('energy_kcal_100g_or_equivalent: ${nutriments.caloriesPer100g}');
      }
      if (nutriments.proteinsPer100g != null) {
        buffer.writeln('proteins_100g_or_equivalent: ${nutriments.proteinsPer100g}');
      }
      if (nutriments.carbsPer100g != null) {
        buffer.writeln('carbohydrates_100g_or_equivalent: ${nutriments.carbsPer100g}');
      }
      if (nutriments.fatsPer100g != null) {
        buffer.writeln('fat_100g_or_equivalent: ${nutriments.fatsPer100g}');
      }
    }
    buffer.writeln('Please infer a realistic meal and return structured ingredients with macros.');
    return buffer.toString();
  }

  Future<String?> _resolvePhotoPath(String? rawPath) async {
    if (rawPath == null || rawPath.isEmpty) return null;
    try {
      return await MediaStorage.persistMealPhoto(rawPath);
    } catch (_) {
      return null;
    }
  }

  Future<String?> _resolveBarcodePhotoPath(BarcodeLookupResult? lookupResult) async {
    final imageUrl = lookupResult?.imageUrl;
    if (imageUrl == null || imageUrl.trim().isEmpty) {
      return null;
    }
    return MediaStorage.persistMealPhotoFromUrl(imageUrl);
  }

  void _beginMealAnalysis() {
    _visibility.begin();
    state = state.copyWith(newMealAnalyzeLoading: true);
  }

  Future<void> _endMealAnalysis() async {
    final stillVisible = await _visibility.end();
    state = state.copyWith(newMealAnalyzeLoading: stillVisible);
  }

  void _notifyRecognitionComplete({required String message, required int notificationId, bool showForegroundSnackBar = true}) {
    _showRecognitionNotification(ref, isInForeground: _isInForeground, message: message, notificationId: notificationId, showForegroundSnackBar: showForegroundSnackBar);
  }
}

final mealAnalysisProvider = NotifierProvider<MealAnalysisNotifier, MealAnalysisState>(MealAnalysisNotifier.new);

// =============================================================================
// 3) activityAnalysisProvider — analýza cvičení + scroll signály
// =============================================================================

/// Immutable stav analýzy cvičení a scroll signálů. `scrollTo*RequestId` se
/// pouze inkrementují; UI reaguje na změnu hodnoty.
@immutable
class ActivityAnalysisState {
  const ActivityAnalysisState({this.newExerciseAnalyzeLoading = false, this.scrollToTodayMealsRequestId = 0, this.scrollToExercisesRequestId = 0});

  final bool newExerciseAnalyzeLoading;
  final int scrollToTodayMealsRequestId;
  final int scrollToExercisesRequestId;

  ActivityAnalysisState copyWith({bool? newExerciseAnalyzeLoading, int? scrollToTodayMealsRequestId, int? scrollToExercisesRequestId}) {
    return ActivityAnalysisState(
      newExerciseAnalyzeLoading: newExerciseAnalyzeLoading ?? this.newExerciseAnalyzeLoading,
      scrollToTodayMealsRequestId: scrollToTodayMealsRequestId ?? this.scrollToTodayMealsRequestId,
      scrollToExercisesRequestId: scrollToExercisesRequestId ?? this.scrollToExercisesRequestId,
    );
  }
}

class ActivityAnalysisNotifier extends Notifier<ActivityAnalysisState> {
  final LoadingVisibilityTracker _visibility = LoadingVisibilityTracker();

  // TODO Tier C: skutečné napojení na AppLifecycleListener (onResumed/onPaused).
  // ignore: prefer_final_fields
  bool _isInForeground = true;

  @override
  ActivityAnalysisState build() => const ActivityAnalysisState();

  Future<void> analyzeExerciseFromVoice({required DateTime selectedDate, required String description, bool scrollToTodayMealsOnStart = true}) async {
    final trimmedDescription = description.trim();
    if (trimmedDescription.isEmpty) {
      // Dříve showSnackBar (prázdný popis) — UI (Tier C).
      return;
    }

    if (scrollToTodayMealsOnStart) {
      requestScrollToExercises();
    }

    _beginExerciseAnalysis();
    try {
      final result = await ref.read(aiPipelineServiceProvider).analyzeExercise(description: trimmedDescription);
      if (!result.isSuccess || result.analysis == null) {
        // Dříve showSnackBar (analýza selhala) — UI (Tier C).
        return;
      }

      final answer = result.analysis!.answer;
      final int? duration = answer.durationMinutes;
      final double caloriesBurned = answer.caloriesTotal?.toDouble() ?? ((answer.caloriesPerMinute ?? 0) * (duration ?? 0));

      if (caloriesBurned <= 0) {
        // Dříve showSnackBar (žádné kalorie) — UI (Tier C).
        return;
      }

      final exercise = Exercise(
        name: answer.name,
        timestamp: _applyDateToTime(DateTime.now(), selectedDate),
        durationMinutes: duration,
        caloriesBurned: caloriesBurned,
        confidence: answer.confidence,
      );

      await ref.read(dayRecordProvider.notifier).saveExerciseForDate(date: selectedDate, exerciseToSave: exercise);
      _notifyRecognitionComplete(message: tr(LocaleKeys.dashboard_exercise_recognised), notificationId: 4002);
    } catch (e) {
      // Dříve showSnackBar (vytvoření cvičení selhalo) — UI (Tier C).
      debugPrint('Error in exercise voice analysis flow: $e');
    } finally {
      await _endExerciseAnalysis();
    }
  }

  void requestScrollToTodayMealsBottom() {
    state = state.copyWith(scrollToTodayMealsRequestId: state.scrollToTodayMealsRequestId + 1);
  }

  void requestScrollToExercises() {
    state = state.copyWith(scrollToExercisesRequestId: state.scrollToExercisesRequestId + 1);
  }

  void _beginExerciseAnalysis() {
    _visibility.begin();
    state = state.copyWith(newExerciseAnalyzeLoading: true);
  }

  Future<void> _endExerciseAnalysis() async {
    final stillVisible = await _visibility.end();
    state = state.copyWith(newExerciseAnalyzeLoading: stillVisible);
  }

  void _notifyRecognitionComplete({required String message, required int notificationId, bool showForegroundSnackBar = true}) {
    _showRecognitionNotification(ref, isInForeground: _isInForeground, message: message, notificationId: notificationId, showForegroundSnackBar: showForegroundSnackBar);
  }
}

final activityAnalysisProvider = NotifierProvider<ActivityAnalysisNotifier, ActivityAnalysisState>(ActivityAnalysisNotifier.new);

// =============================================================================
// Sdílené pomocné funkce (bez GetX)
// =============================================================================

/// Přenese časovou složku [source] na kalendářní den [targetDate].
DateTime _applyDateToTime(DateTime source, DateTime targetDate) {
  return DateTime(targetDate.year, targetDate.month, targetDate.day, source.hour, source.minute, source.second, source.millisecond, source.microsecond);
}

/// Oznámí dokončení rozpoznání. Na popředí dřív zobrazoval snackbar (nyní řeší
/// UI přes `ref.listen` — Tier C), na pozadí odešle systémovou notifikaci.
void _showRecognitionNotification(Ref ref, {required bool isInForeground, required String message, required int notificationId, bool showForegroundSnackBar = true}) {
  if (isInForeground) {
    // TODO Tier C: úspěšné oznámení na popředí (dříve showSnackBar) řeší UI.
    return;
  }
  ref
      .read(trackingReminderServiceProvider)
      .notificationsPlugin
      .show(
        notificationId,
        tr(LocaleKeys.common_app_name),
        message,
        const NotificationDetails(
          android: AndroidNotificationDetails(trackingRemindersChannelId, 'Foody', importance: Importance.high, priority: Priority.high),
          iOS: DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true),
        ),
      );
}
