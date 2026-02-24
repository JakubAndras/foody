import 'dart:io';

import 'package:diplomka/controller/streak_controller.dart';
import 'package:diplomka/model/barcode_lookup_result.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:diplomka/model/day_record.dart';
import 'package:diplomka/model/ingredient.dart';
import 'package:diplomka/model/streak_info.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:diplomka/model/meal.dart';
import 'package:diplomka/services/barcode_lookup_service.dart';
import 'package:diplomka/services/ai_feature/ai_pipeline_service.dart';
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
  final RxInt scrollToTodayMealsRequestId = 0.obs;
  int _activeMealAnalyses = 0;

  @override
  void onInit() {
    super.onInit();
    _fetchDayRecord(selectedDate.value);
    _fetchStreakInfo();

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
    } catch (e) {
      dayRecordError.value = "Failed to load daily record: ${e.toString()}";
      dayRecord.value = null;
      Get.snackbar("Error", dayRecordError.value);
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
      streakError.value = "Failed to load streak info: ${e.toString()}";
      streakInfo.value = null;
      Get.snackbar("Error", streakError.value);
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

  Future<void> pickImage(ImageSource source) async {
    final permission = source == ImageSource.camera ? Permission.camera : Permission.photos;
    final status = await permission.request();

    if (!status.isGranted) {
      String message;
      if (status.isPermanentlyDenied) {
        message = source == ImageSource.camera
            ? 'Camera permission is permanently denied. Please enable it in app settings.'
            : 'Photo library permission is permanently denied. Please enable it in app settings.';
        Get.snackbar(
          'Permission Denied',
          message,
          mainButton: TextButton(
            onPressed: () => openAppSettings(),
            child: const Text('Settings'),
          ),
          duration: const Duration(seconds: 5),
        );
      } else {
        message = source == ImageSource.camera ? 'Camera permission denied.' : 'Photo library permission denied.';
        Get.snackbar('Permission Denied', message, duration: const Duration(seconds: 3));
      }
      debugPrint(message);
      return;
    }

    final ImagePicker picker = ImagePicker();
    final XFile? imageFile = await picker.pickImage(source: source);

    if (imageFile == null) {
      Get.snackbar('Image Picker', 'No image selected.', duration: const Duration(seconds: 2));
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
        'Error',
        'Error analyzing image: $e',
        duration: const Duration(seconds: 3),
      );
      debugPrint('Error calling AI Service: $e');
    }
  }

  Future<void> analyzeMealFromImage({
    required DateTime selectedDate,
    String? imagePath,
    String? description,
    String? preferredMealName,
    bool scrollToTodayMealsOnStart = false,
  }) async {
    if (scrollToTodayMealsOnStart) {
      requestScrollToTodayMealsBottom();
    }
    _beginMealAnalysis();
    try {
      final String? storedPhotoRef = await _resolvePhotoPath(imagePath);
      if (imagePath != null && imagePath.isNotEmpty && storedPhotoRef == null) {
        debugPrint('Meal photo could not be persisted. sourcePath=$imagePath');
      }
      final String? resolvedPhotoPath = await MediaStorage.resolveStoredMealPhotoPath(storedPhotoRef);
      final List<File>? imageFiles = resolvedPhotoPath == null ? null : [File(resolvedPhotoPath)];
      await _analyzeAndSaveMealWithAi(
        selectedDate: selectedDate,
        imageFiles: imageFiles,
        photoPathToSave: storedPhotoRef,
        description: description,
        preferredMealName: preferredMealName,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error analyzing image: $e',
        duration: const Duration(seconds: 3),
      );
      debugPrint('Error calling AI Service: $e');
    } finally {
      _endMealAnalysis();
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
        'Error',
        'Error analyzing barcode: $e',
        duration: const Duration(seconds: 3),
      );
      debugPrint('Error calling barcode analysis flow: $e');
    } finally {
      _endMealAnalysis();
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

  Future<void> _analyzeAndSaveMealWithAi({
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
        Get.snackbar('Low confidence', result.message ?? 'Please review the result.');
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
    } else {
      Get.snackbar(
        'Analysis failed',
        result.message ?? 'Could not analyze the image. Please try again.',
        duration: const Duration(seconds: 3),
      );
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
    newMealAnalyzeLoading.value = true;
  }

  void _endMealAnalysis() {
    if (_activeMealAnalyses > 0) {
      _activeMealAnalyses -= 1;
    }
    newMealAnalyzeLoading.value = _activeMealAnalyses > 0;
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
