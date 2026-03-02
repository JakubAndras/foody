import 'dart:io';

import 'package:diplomka/controller/streak_controller.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/model/barcode_lookup_result.dart';
import 'package:diplomka/model/exercise.dart';
import 'package:diplomka/model/meal_analysis_request.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:diplomka/model/day_record.dart';
import 'package:diplomka/model/ingredient.dart';
import 'package:diplomka/model/streak_info.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:diplomka/model/meal.dart';
import 'package:diplomka/services/barcode_lookup_service.dart';
import 'package:diplomka/services/ai_feature/ai_pipeline_service.dart';
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
  final RxString dayRecordError = ''.obs;

  final Rx<StreakInfo?> streakInfo = Rx<StreakInfo?>(null);
  final RxBool isLoadingStreak = false.obs;
  final RxString streakError = ''.obs;

  final RxBool newMealAnalyzeLoading = false.obs;
  final RxBool newExerciseAnalyzeLoading = false.obs;
  final RxInt scrollToTodayMealsRequestId = 0.obs;
  Worker? _dayRecordsWorker;
  int _activeMealAnalyses = 0;
  int _activeExerciseAnalyses = 0;
  DateTime? _mealAnalysisLoadingStartedAt;
  DateTime? _exerciseAnalysisLoadingStartedAt;
  static const Duration _minMealLoadingVisible = Duration(milliseconds: 900);
  static const Duration _minExerciseLoadingVisible = Duration(milliseconds: 900);

  @override
  void onInit() {
    super.onInit();
    _fetchDayRecord(selectedDate.value);
    _fetchStreakInfo();
    _dayRecordsWorker = ever<List<DayRecord>>(
      _dayRecordController.dayRecords,
      _updateStreakFromRecords,
    );

    selectedDate.listen((date) {
      _fetchDayRecord(date);
    });
  }

  Future<void> _fetchDayRecord(DateTime date) async {
    isLoadingDayRecord.value = true;
    dayRecordError.value = '';
    try {
      final record = await _dayRecordController.getDayRecord(date);
      dayRecord.value = record;
      NutritionGoalsService.to.syncFromDayRecord(date: date, dayRecord: record);
    } catch (e) {
      dayRecordError.value = e.toString();
      dayRecord.value = null;
      NutritionGoalsService.to.syncFromDayRecord(date: date, dayRecord: null);
      Get.snackbar(tr(LocaleKeys.common_error), tr(LocaleKeys.common_something_went_wrong));
    } finally {
      isLoadingDayRecord.value = false;
    }
  }

  Future<void> _fetchStreakInfo() async {
    isLoadingStreak.value = true;
    streakError.value = '';
    try {
      streakInfo.value = await _streakController.getStreakInfo();
    } catch (e) {
      streakError.value = e.toString();
      streakInfo.value = null;
      Get.snackbar(tr(LocaleKeys.common_error), tr(LocaleKeys.common_something_went_wrong));
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

    if (!status.isGranted) {
      String message;
      if (status.isPermanentlyDenied) {
        message = source == ImageSource.camera ? tr(LocaleKeys.error_camera_permanently_denied) : tr(LocaleKeys.error_gallery_permanently_denied);
        Get.snackbar(
          tr(LocaleKeys.error_permission_denied),
          message,
          mainButton: TextButton(
            onPressed: () => openAppSettings(),
            child: Text(tr(LocaleKeys.tracking_reminders_open_settings)),
          ),
          duration: const Duration(seconds: 5),
        );
      } else {
        message = source == ImageSource.camera ? tr(LocaleKeys.error_camera_denied) : tr(LocaleKeys.error_gallery_denied);
        Get.snackbar(tr(LocaleKeys.error_permission_denied), message, duration: const Duration(seconds: 3));
      }
      debugPrint(message);
      return;
    }

    final ImagePicker picker = ImagePicker();
    final XFile? imageFile = await picker.pickImage(source: source);

    if (imageFile == null) {
      Get.snackbar(tr(LocaleKeys.error_image_picker_title), tr(LocaleKeys.error_no_image_selected), duration: const Duration(seconds: 2));
      debugPrint('No image selected.');
      return;
    }

    try {
      await analyzeMealFromImage(
        selectedDate: selectedDate.value,
        imagePath: imageFile.path,
      );
    } catch (e) {
      Get.snackbar(
        tr(LocaleKeys.common_error),
        tr(LocaleKeys.error_analysis_image),
        duration: const Duration(seconds: 3),
      );
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
        Get.snackbar(
          tr(LocaleKeys.error_analysis_failed),
          tr(LocaleKeys.error_analysis_no_photo),
          duration: const Duration(seconds: 3),
        );
        return MealAnalysisFlowResult.failure(
          message: tr(LocaleKeys.error_analysis_no_photo),
        );
      }
      if (rawImagePath != null && storedPhotoRef == null) {
        debugPrint('Meal photo could not be persisted. sourcePath=$rawImagePath');
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
      return flowResult;
    } catch (e) {
      Get.snackbar(
        tr(LocaleKeys.common_error),
        tr(LocaleKeys.error_analysis_meal),
        duration: const Duration(seconds: 3),
      );
      debugPrint('Error calling AI Service: $e');
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
      Get.snackbar(
        tr(LocaleKeys.common_error),
        tr(LocaleKeys.error_analysis_barcode),
        duration: const Duration(seconds: 3),
      );
      debugPrint('Error calling barcode analysis flow: $e');
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
      Get.snackbar(
        tr(LocaleKeys.error_exercise_analysis_failed),
        tr(LocaleKeys.error_exercise_empty_desc),
      );
      return;
    }

    if (scrollToTodayMealsOnStart) {
      requestScrollToTodayMealsBottom();
    }

    _beginExerciseAnalysis();
    try {
      final result = await AiPipelineService.to.analyzeExercise(description: trimmedDescription);
      if (!result.isSuccess || result.analysis == null) {
        Get.snackbar(tr(LocaleKeys.error_exercise_analysis_failed), result.message ?? tr(LocaleKeys.common_try_again));
        return;
      }

      if (result.status == AiExerciseAnalysisStatus.lowConfidence) {
        Get.snackbar(
          tr(LocaleKeys.error_low_confidence),
          result.message ?? tr(LocaleKeys.error_low_confidence_review),
        );
      }

      final answer = result.analysis!.answer;
      final int? duration = answer.durationMinutes;
      final double caloriesBurned = answer.caloriesTotal?.toDouble() ?? ((answer.caloriesPerMinute ?? 0) * (duration ?? 0));

      if (caloriesBurned <= 0) {
        Get.snackbar(
          tr(LocaleKeys.error_exercise_analysis_failed),
          tr(LocaleKeys.error_exercise_no_calories),
        );
        return;
      }

      final exercise = Exercise(
        name: answer.name,
        timestamp: _applyDateToTime(DateTime.now(), selectedDate),
        durationMinutes: duration,
        caloriesBurned: caloriesBurned,
      );

      await DayRecordController.to.saveExerciseForDate(
        date: selectedDate,
        exerciseToSave: exercise,
      );
      refresh();
    } catch (e) {
      Get.snackbar(
        tr(LocaleKeys.error_exercise_analysis_failed),
        tr(LocaleKeys.error_exercise_create_failed),
      );
      debugPrint('Error in exercise voice analysis flow: $e');
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
      if (result.status == AiAnalysisStatus.lowConfidence) {
        Get.snackbar(tr(LocaleKeys.error_low_confidence), result.message ?? tr(LocaleKeys.error_low_confidence_review));
      }
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
      Get.snackbar(
        tr(LocaleKeys.error_analysis_failed),
        result.message ?? tr(LocaleKeys.error_analysis_could_not),
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

    return Meal(
      name: result.productName,
      ingredients: <Ingredient>[
        Ingredient(
          name: result.productName,
          weight: 100,
          calories: nutriments.caloriesPer100g ?? 0,
          proteins: nutriments.proteinsPer100g ?? 0,
          carbs: nutriments.carbsPer100g ?? 0,
          fats: nutriments.fatsPer100g ?? 0,
        ),
      ],
      timestamp: timestamp,
      photoPath: photoPath,
    );
  }

  String _buildBarcodeAiFallbackDescription({
    required String barcode,
    BarcodeLookupResult? result,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('Barcode scan fallback request.');
    buffer.writeln('barcode: $barcode');
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
  }

  void _beginExerciseAnalysis() {
    _activeExerciseAnalyses += 1;
    _exerciseAnalysisLoadingStartedAt ??= DateTime.now();
    newExerciseAnalyzeLoading.value = true;
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
  }

  void requestScrollToTodayMealsBottom() {
    scrollToTodayMealsRequestId.value += 1;
  }

  // Placeholder for refresh method, if it needs to be part of this controller
  @override
  void refresh() {
    _fetchDayRecord(selectedDate.value);
    _fetchStreakInfo();
    // Add other refresh logic if needed
  }
}
