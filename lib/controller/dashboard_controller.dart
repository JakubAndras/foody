import 'dart:io';

import 'package:diplomka/controller/streak_controller.dart';
import 'package:diplomka/services/background_task_service.dart';
import 'package:diplomka/services/tracking_reminder_service.dart';
import 'package:diplomka/utils/app_limits.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:diplomka/services/health_integration_service.dart';
import 'package:diplomka/services/session_manager.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/model/barcode_lookup_result.dart';
import 'package:diplomka/model/exercise.dart';
import 'package:diplomka/model/meal_analysis_request.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:diplomka/widgets/logged_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:diplomka/model/day_record.dart';
import 'package:diplomka/model/ingredient.dart';
import 'package:diplomka/model/streak_info.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:diplomka/model/meal.dart';
import 'package:diplomka/services/barcode_lookup_service.dart';
import 'package:diplomka/services/ai_feature/ai_pipeline_service.dart';
import 'package:diplomka/services/day_record_repository.dart';
import 'package:diplomka/services/nutrition_goals_service.dart';
import 'package:diplomka/services/selected_date_service.dart';
import 'package:diplomka/utils/media_storage.dart';
import 'base_controller.dart';
import 'package:image_picker/image_picker.dart';
import 'day_record_controller.dart';

class DashboardController extends BaseController {
  static DashboardController get to => Get.find();

  final _dayRecordController = DayRecordController.to;
  final _streakController = StreakController.to;
  final _selectedDateService = SelectedDateService.to;

  late final Rx<DateTime> selectedDate = _selectedDateService.selectedDate;

  final Rx<DayRecord?> dayRecord = Rx<DayRecord?>(null);
  final RxBool isLoadingDayRecord = false.obs;
  final RxBool initialLoadComplete = false.obs;
  final RxString dayRecordError = ''.obs;

  final Rx<StreakInfo?> streakInfo = Rx<StreakInfo?>(null);
  final RxBool isLoadingStreak = false.obs;
  final RxString streakError = ''.obs;

  final RxDouble rolloverAmount = 0.0.obs;

  int _fetchGeneration = 0;

  final RxBool newMealAnalyzeLoading = false.obs;
  final RxBool newExerciseAnalyzeLoading = false.obs;
  final RxInt scrollToTodayMealsRequestId = 0.obs;
  final RxInt scrollToExercisesRequestId = 0.obs;
  Worker? _dayRecordsWorker;
  int _activeMealAnalyses = 0;
  int _activeExerciseAnalyses = 0;
  DateTime? _mealAnalysisLoadingStartedAt;
  DateTime? _exerciseAnalysisLoadingStartedAt;
  static const Duration _minMealLoadingVisible = Duration(milliseconds: 900);
  static const Duration _minExerciseLoadingVisible = Duration(milliseconds: 900);
  bool _isInForeground = true;

  @override
  void onResumed() => _isInForeground = true;

  @override
  void onPaused() => _isInForeground = false;

  @override
  void onInit() {
    super.onInit();
    _fetchDayRecord(selectedDate.value);
    _fetchStreakInfo();
    _syncHealthDataIfEnabled();
    _dayRecordsWorker = ever<List<DayRecord>>(
      _dayRecordController.dayRecords,
      _updateStreakFromRecords,
    );

    selectedDate.listen((date) {
      _fetchDayRecord(date);
    });
  }

  Future<void> _syncHealthDataIfEnabled() async {
    try {
      final healthService = HealthIntegrationService.to;
      await healthService.waitForSettingsLoaded();
      if (healthService.isEnabled.value) {
        await healthService.syncRecentDays();
        _fetchDayRecord(selectedDate.value);
      }
    } catch (_) {
      // Health sync is best-effort; do not disrupt dashboard on failure
    }
  }

  Future<void> _fetchDayRecord(DateTime date) async {
    final generation = ++_fetchGeneration;
    isLoadingDayRecord.value = true;
    dayRecordError.value = '';
    try {
      final record = await _dayRecordController.getDayRecord(date);
      if (generation != _fetchGeneration) return;
      dayRecord.value = record;
      NutritionGoalsService.to.syncFromDayRecord(date: date, dayRecord: record);
      initialLoadComplete.value = true;
      rolloverAmount.value = await _calculateRollover(date);
    } catch (e) {
      if (generation != _fetchGeneration) return;
      dayRecordError.value = e.toString();
      dayRecord.value = null;
      rolloverAmount.value = 0;
      NutritionGoalsService.to.syncFromDayRecord(date: date, dayRecord: null);
      showSnackBar(message: tr(LocaleKeys.common_error), subtitle: tr(LocaleKeys.common_something_went_wrong), type: SnackBarType.error);
    } finally {
      isLoadingDayRecord.value = false;
    }
  }

  Future<double> _calculateRollover(DateTime date) async {
    if (!SessionManager.to.rolloverCaloriesEnabled.value) return 0;
    final yesterday = date.subtract(const Duration(days: 1));
    final yesterdayRecord = await DayRecordRepository.to.getDayRecord(yesterday);
    if (yesterdayRecord == null) return 0;

    final bool burnedEnabled = SessionManager.to.burnedCaloriesEnabled.value;
    final double yesterdayConsumed = burnedEnabled ? yesterdayRecord.netCalories : yesterdayRecord.totalCalories;
    final double leftover = yesterdayRecord.calorieGoal - yesterdayConsumed;
    return leftover.clamp(0, 500);
  }

  Future<void> _fetchStreakInfo() async {
    isLoadingStreak.value = true;
    streakError.value = '';
    try {
      streakInfo.value = await _streakController.getStreakInfo();
    } catch (e) {
      streakError.value = e.toString();
      streakInfo.value = null;
      showSnackBar(message: tr(LocaleKeys.common_error), subtitle: tr(LocaleKeys.common_something_went_wrong), type: SnackBarType.error);
    } finally {
      isLoadingStreak.value = false;
    }
  }

  void _updateStreakFromRecords(List<DayRecord> records) {
    try {
      streakInfo.value = _streakController.calculateFromRecords(records);
      streakError.value = '';
    } catch (e) {
      streakError.value = e.toString();
      streakInfo.value = null;
    } finally {
      isLoadingStreak.value = false;
    }
  }

  void updateDate(DateTime newDate) {
    _selectedDateService.setSelectedDate(newDate);
  }

  @override
  void onHidden() {
    // TODO: implement onHidden
  }

  @override
  void onClose() {
    _dayRecordsWorker?.dispose();
    super.onClose();
  }

  Future<void> pickImage(ImageSource source) async {
    final permission = source == ImageSource.camera ? Permission.camera : Permission.photos;
    final status = await permission.request();

    if (!status.isGranted && !status.isLimited) {
      String message;
      if (status.isPermanentlyDenied) {
        message = source == ImageSource.camera ? tr(LocaleKeys.error_camera_permanently_denied) : tr(LocaleKeys.error_gallery_permanently_denied);
        showSnackBar(
          message: tr(LocaleKeys.error_permission_denied),
          subtitle: message,
          type: SnackBarType.error,
          primaryLabel: tr(LocaleKeys.tracking_reminders_open_settings),
          onPrimary: () => openAppSettings(),
          duration: const Duration(seconds: 5),
        );
      } else {
        message = source == ImageSource.camera ? tr(LocaleKeys.error_camera_denied) : tr(LocaleKeys.error_gallery_denied);
        showSnackBar(message: tr(LocaleKeys.error_permission_denied), subtitle: message, type: SnackBarType.error, duration: const Duration(seconds: 3));
      }
      print(message);
      return;
    }

    final ImagePicker picker = ImagePicker();
    final XFile? imageFile = await picker.pickImage(source: source);

    if (imageFile == null) {
      showSnackBar(message: tr(LocaleKeys.error_image_picker_title), subtitle: tr(LocaleKeys.error_no_image_selected), type: SnackBarType.info, duration: const Duration(seconds: 2));
      print('No image selected.');
      return;
    }

    try {
      await analyzeMealFromImage(
        selectedDate: selectedDate.value,
        imagePath: imageFile.path,
      );
    } catch (e) {
      showSnackBar(
        message: tr(LocaleKeys.common_error),
        subtitle: tr(LocaleKeys.error_analysis_image),
        type: SnackBarType.error,
        duration: const Duration(seconds: 3),
      );
      print('Error calling AI Service: $e');
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

  Future<MealAnalysisFlowResult> analyzeMealFromVoice({
    required DateTime selectedDate,
    required String description,
    bool scrollToTodayMealsOnStart = false,
  }) {
    return analyzeMeal(
      MealAnalysisRequest.voice(
        selectedDate: selectedDate,
        description: description,
        scrollToTodayMealsOnStart: scrollToTodayMealsOnStart,
      ),
    );
  }

  Future<MealAnalysisFlowResult> analyzeMeal(MealAnalysisRequest request) async {
    if (request.scrollToTodayMealsOnStart) {
      requestScrollToTodayMealsBottom();
    }

    if (request.source == MealInputSource.photo && request.trimmedImagePath == null) {
      return MealAnalysisFlowResult.failure(message: tr(LocaleKeys.error_analysis_no_photo));
    }
    if (request.source == MealInputSource.voice && request.trimmedDescription == null) {
      return MealAnalysisFlowResult.failure(message: tr(LocaleKeys.error_exercise_empty_desc));
    }

    _beginMealAnalysis();
    try {
      final String? rawImagePath = request.trimmedImagePath;
      final String? storedPhotoRef = await _resolvePhotoPath(rawImagePath);
      if (request.source == MealInputSource.photo && rawImagePath != null && storedPhotoRef == null) {
        showSnackBar(
          message: tr(LocaleKeys.error_analysis_failed),
          subtitle: tr(LocaleKeys.error_analysis_no_photo),
          type: SnackBarType.error,
          duration: const Duration(seconds: 3),
        );
        return MealAnalysisFlowResult.failure(
          message: tr(LocaleKeys.error_analysis_no_photo),
        );
      }
      if (rawImagePath != null && storedPhotoRef == null) {
        print('Meal photo could not be persisted. sourcePath=$rawImagePath');
      }

      if (storedPhotoRef != null && SessionManager.to.savePhotosToGallery.value) {
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
      );
      if (flowResult.success) {
        _notifyRecognitionComplete(message: tr(LocaleKeys.dashboard_meal_recognised), notificationId: 4001, showForegroundSnackBar: false);
      }
      return flowResult;
    } catch (e) {
      showSnackBar(
        message: tr(LocaleKeys.common_error),
        subtitle: tr(LocaleKeys.error_analysis_meal),
        type: SnackBarType.error,
        duration: const Duration(seconds: 3),
      );
      print('Error calling AI Service: $e');
      return MealAnalysisFlowResult.failure(message: e.toString());
    } finally {
      await _endMealAnalysis();
    }
  }

  Future<void> analyzeMealFromBarcode({
    required DateTime selectedDate,
    required String barcode,
  }) async {
    requestScrollToTodayMealsBottom();
    _beginMealAnalysis();
    try {
      final BarcodeLookupResult? lookupResult = await _tryLookupBarcode(barcode);
      final String? barcodePhotoRef = await _resolveBarcodePhotoPath(lookupResult);
      if (barcodePhotoRef != null && SessionManager.to.savePhotosToGallery.value) {
        MediaStorage.saveToGallery(barcodePhotoRef);
      }
      final String? barcodePhotoPath = await MediaStorage.resolveStoredMealPhotoPath(barcodePhotoRef);
      final List<File>? barcodeImageFiles = barcodePhotoPath == null ? null : <File>[File(barcodePhotoPath)];

      if (lookupResult != null && lookupResult.hasCompleteNutrientsForDirectUse) {
        final meal = _buildMealFromBarcodeLookup(
          selectedDate: selectedDate,
          result: lookupResult,
          photoPath: barcodePhotoRef,
        );
        await DayRecordController.to.saveMealForDate(
          date: selectedDate,
          mealToSave: meal,
        );
        await Future<void>.delayed(const Duration(milliseconds: 300));
        refresh();
        _notifyRecognitionComplete(message: tr(LocaleKeys.dashboard_meal_recognised), notificationId: 4001, showForegroundSnackBar: false);
        return;
      }

      await _analyzeAndSaveMealWithAi(
        selectedDate: selectedDate,
        imageFiles: barcodeImageFiles,
        photoPathToSave: barcodePhotoRef,
        description: _buildBarcodeAiFallbackDescription(
          barcode: barcode,
          result: lookupResult,
        ),
        preferredMealName: lookupResult?.productName,
      );
    } catch (e) {
      showSnackBar(
        message: tr(LocaleKeys.common_error),
        subtitle: tr(LocaleKeys.error_analysis_barcode),
        type: SnackBarType.error,
        duration: const Duration(seconds: 3),
      );
      print('Error calling barcode analysis flow: $e');
    } finally {
      await _endMealAnalysis();
    }
  }

  Future<void> analyzeExerciseFromVoice({
    required DateTime selectedDate,
    required String description,
    bool scrollToTodayMealsOnStart = true,
  }) async {
    final trimmedDescription = description.trim();
    if (trimmedDescription.isEmpty) {
      showSnackBar(
        message: tr(LocaleKeys.error_exercise_analysis_failed),
        subtitle: tr(LocaleKeys.error_exercise_empty_desc),
        type: SnackBarType.error,
      );
      return;
    }

    if (scrollToTodayMealsOnStart) {
      requestScrollToExercises();
    }

    _beginExerciseAnalysis();
    try {
      final result = await AiPipelineService.to.analyzeExercise(description: trimmedDescription);
      if (!result.isSuccess || result.analysis == null) {
        showSnackBar(message: tr(LocaleKeys.error_exercise_analysis_failed), subtitle: result.message ?? tr(LocaleKeys.common_try_again), type: SnackBarType.error);
        return;
      }

      final answer = result.analysis!.answer;
      final int? duration = answer.durationMinutes;
      final double caloriesBurned = answer.caloriesTotal?.toDouble() ?? ((answer.caloriesPerMinute ?? 0) * (duration ?? 0));

      if (caloriesBurned <= 0) {
        showSnackBar(
          message: tr(LocaleKeys.error_exercise_analysis_failed),
          subtitle: tr(LocaleKeys.error_exercise_no_calories),
          type: SnackBarType.error,
        );
        return;
      }

      final exercise = Exercise(
        name: answer.name,
        timestamp: _applyDateToTime(DateTime.now(), selectedDate),
        durationMinutes: duration,
        caloriesBurned: caloriesBurned,
        confidence: answer.confidence,
      );

      await DayRecordController.to.saveExerciseForDate(
        date: selectedDate,
        exerciseToSave: exercise,
      );
      refresh();
      _notifyRecognitionComplete(message: tr(LocaleKeys.dashboard_exercise_recognised), notificationId: 4002);
    } catch (e) {
      showSnackBar(
        message: tr(LocaleKeys.error_exercise_analysis_failed),
        subtitle: tr(LocaleKeys.error_exercise_create_failed),
        type: SnackBarType.error,
      );
      print('Error in exercise voice analysis flow: $e');
    } finally {
      await _endExerciseAnalysis();
    }
  }

  Future<BarcodeLookupResult?> _tryLookupBarcode(String barcode) async {
    try {
      return await BarcodeLookupService.to.lookupProductByBarcode(barcode);
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
    String? description,
    String? preferredMealName,
  }) async {
    final result = await AiPipelineService.to.analyzeMeal(
      imageFiles: imageFiles,
      description: description,
    );

    if (result.isSuccess && result.response != null) {
      Meal meal = Meal.fromAnswer(result.response!.answer).copyWith(
        timestamp: _applyDateToTime(DateTime.now(), selectedDate),
        photoPath: photoPathToSave,
      );
      final String trimmedName = preferredMealName?.trim() ?? '';
      if (trimmedName.isNotEmpty) {
        meal = meal.copyWith(name: trimmedName);
      }

      await DayRecordController.to.saveMealForDate(
        date: selectedDate,
        mealToSave: meal,
      );
      refresh();
      return MealAnalysisFlowResult.success(status: result.status);
    } else {
      showSnackBar(
        message: tr(LocaleKeys.error_analysis_failed),
        subtitle: result.message ?? tr(LocaleKeys.error_analysis_could_not),
        type: SnackBarType.error,
        duration: const Duration(seconds: 3),
      );
      return MealAnalysisFlowResult.failure(message: result.message);
    }
  }

  Meal _buildMealFromBarcodeLookup({
    required DateTime selectedDate,
    required BarcodeLookupResult result,
    String? photoPath,
  }) {
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

  String _buildBarcodeAiFallbackDescription({
    required String barcode,
    BarcodeLookupResult? result,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('Barcode scan fallback request.');
    buffer.writeln('barcode: $barcode');
    final countryHint = BarcodeLookupService.to.getEanCountryHint(barcode);
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

  DateTime _applyDateToTime(DateTime source, DateTime targetDate) {
    return DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day,
      source.hour,
      source.minute,
      source.second,
      source.millisecond,
      source.microsecond,
    );
  }

  void _beginMealAnalysis() {
    _activeMealAnalyses += 1;
    _mealAnalysisLoadingStartedAt ??= DateTime.now();
    newMealAnalyzeLoading.value = true;
    BackgroundTaskService.begin();
  }

  void _beginExerciseAnalysis() {
    _activeExerciseAnalyses += 1;
    _exerciseAnalysisLoadingStartedAt ??= DateTime.now();
    newExerciseAnalyzeLoading.value = true;
    BackgroundTaskService.begin();
  }

  Future<void> _endMealAnalysis() async {
    if (_activeMealAnalyses > 0) {
      _activeMealAnalyses -= 1;
    }

    if (_activeMealAnalyses > 0) {
      newMealAnalyzeLoading.value = true;
      return;
    }

    final startedAt = _mealAnalysisLoadingStartedAt;
    if (startedAt != null) {
      final elapsed = DateTime.now().difference(startedAt);
      if (elapsed < _minMealLoadingVisible) {
        await Future<void>.delayed(_minMealLoadingVisible - elapsed);
      }
    }

    _mealAnalysisLoadingStartedAt = null;
    newMealAnalyzeLoading.value = false;
    BackgroundTaskService.end();
  }

  Future<void> _endExerciseAnalysis() async {
    if (_activeExerciseAnalyses > 0) {
      _activeExerciseAnalyses -= 1;
    }

    if (_activeExerciseAnalyses > 0) {
      newExerciseAnalyzeLoading.value = true;
      return;
    }

    final startedAt = _exerciseAnalysisLoadingStartedAt;
    if (startedAt != null) {
      final elapsed = DateTime.now().difference(startedAt);
      if (elapsed < _minExerciseLoadingVisible) {
        await Future<void>.delayed(_minExerciseLoadingVisible - elapsed);
      }
    }

    _exerciseAnalysisLoadingStartedAt = null;
    newExerciseAnalyzeLoading.value = false;
    BackgroundTaskService.end();
  }

  void requestScrollToTodayMealsBottom() {
    scrollToTodayMealsRequestId.value += 1;
  }

  void requestScrollToExercises() {
    scrollToExercisesRequestId.value += 1;
  }

  void _notifyRecognitionComplete({required String message, required int notificationId, bool showForegroundSnackBar = true}) {
    print('[Notifications] _notifyRecognitionComplete: foreground=$_isInForeground');
    if (_isInForeground) {
      if (showForegroundSnackBar) showSnackBar(message: message, type: SnackBarType.success);
    } else {
      print('[Notifications] Sending instant notification id=$notificationId');
      TrackingReminderService.to.notificationsPlugin.show(
        notificationId,
        tr(LocaleKeys.common_app_name),
        message,
        const NotificationDetails(
          android: AndroidNotificationDetails(trackingRemindersChannelId, 'Foody', importance: Importance.high, priority: Priority.high),
          iOS: DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true),
        ),
      );
    }
  }

  void refresh() {
    _fetchDayRecord(selectedDate.value);
    _fetchStreakInfo();
  }
}
