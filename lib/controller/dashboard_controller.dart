import 'dart:io';

import 'package:diplomka/controller/streak_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:diplomka/model/day_record.dart';
import 'package:diplomka/model/streak_info.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:diplomka/model/meal.dart';
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
  }) async {
    _beginMealAnalysis();
    try {
      final String? resolvedPhotoPath = await _resolvePhotoPath(imagePath);
      final List<File>? imageFiles = resolvedPhotoPath == null ? null : [File(resolvedPhotoPath)];
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
          photoPath: resolvedPhotoPath,
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

  Future<String?> _resolvePhotoPath(String? rawPath) async {
    if (rawPath == null || rawPath.isEmpty) return null;
    final persisted = await MediaStorage.persistMealPhoto(rawPath);
    if (persisted != null) {
      return persisted;
    }
    if (await File(rawPath).exists()) {
      return rawPath;
    }
    return null;
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

  // Placeholder for refresh method, if it needs to be part of this controller
  @override
  void refresh() {
    _fetchDayRecord(selectedDate.value);
    _fetchStreakInfo();
    // Add other refresh logic if needed
  }
}
