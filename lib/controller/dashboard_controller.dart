import 'dart:io';

import 'package:diplomka/controller/streak_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:diplomka/model/day_record.dart';
import 'package:diplomka/model/streak_info.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:diplomka/model/ai_response.dart';
import 'package:diplomka/model/meal.dart';
import 'package:diplomka/screens/edit_meal_screen.dart';
import 'package:diplomka/services/ai_feature/openai_service.dart';
import 'base_controller.dart';
import 'package:image_picker/image_picker.dart';
import 'day_record_controller.dart';

class DashboardController extends BaseController {
  static DashboardController get to => Get.find();

  final _dayRecordController = DayRecordController.to;
  final _streakController = StreakController.to;

  final Rx<DateTime> selectedDate = Rx<DateTime>(DateTime.now());

  final Rx<DayRecord?> dayRecord = Rx<DayRecord?>(null);
  final RxBool isLoadingDayRecord = false.obs;
  final RxString dayRecordError = ''.obs;

  final Rx<StreakInfo?> streakInfo = Rx<StreakInfo?>(null);
  final RxBool isLoadingStreak = false.obs;
  final RxString streakError = ''.obs;

  final RxBool newMealAnalyzeLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    final now = DateTime.now();
    selectedDate.value = DateTime(now.year, now.month, now.day);

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
    selectedDate.value = DateTime(newDate.year, newDate.month, newDate.day);
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
        message = source == ImageSource.camera
            ? 'Camera permission denied.'
            : 'Photo library permission denied.';
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
      newMealAnalyzeLoading.value = true;
      final File file = File(imageFile.path);
      final aiService = OpenAiService(); // AiServiceManager.to.currentServiceType.value;
      final AiResponse? analyzedData = await aiService.generateResponse(imageFiles: [file]);

      if (analyzedData != null && analyzedData.valid) {
        final Meal meal = Meal.fromAnswer(analyzedData.answer);
        final DateTime selectedDate = DateTime.now();
        await DayRecordController.to.addMealToDayRecord(dayRecord: dayRecord.value ?? DayRecord.initial(selectedDate), mealToSave: meal, isNewMeal: true);
        refresh(); // Assuming refresh() is a method in this controller to update data.
      } else {
        debugPrint('Failed to analyze image or invalid database.');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error analyzing image: $e',
        duration: const Duration(seconds: 3),
      );
      debugPrint('Error calling AI Service: $e');
    } finally {
      newMealAnalyzeLoading.value = false;
    }
  }

  // Placeholder for refresh method, if it needs to be part of this controller
  void refresh() {
    _fetchDayRecord(selectedDate.value);
    _fetchStreakInfo();
    // Add other refresh logic if needed
  }
}
