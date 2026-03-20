import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:get/get.dart';

import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/model/calendar_day.dart';
import 'package:diplomka/model/calendar_day_ring_style.dart';
import 'package:diplomka/model/day_record.dart';
import 'package:diplomka/model/exercise.dart';
import 'package:diplomka/services/calendar_day_ring_service.dart';
import 'package:diplomka/services/day_record_repository.dart';
import 'package:diplomka/services/exercise_template_repository.dart';
import 'package:diplomka/services/home_widget/widget_sync_service.dart';
import 'package:diplomka/services/meal_template_repository.dart';

import '../model/meal.dart';
import 'base_controller.dart';

class DayRecordController extends BaseController {
  static DayRecordController get to => Get.find();

  DayRecordController({
    required DayRecordRepository repository,
    CalendarDayRingService? calendarDayRingService,
  })  : _repository = repository,
        _calendarDayRingService = calendarDayRingService;

  final DayRecordRepository _repository;
  final CalendarDayRingService? _calendarDayRingService;

  @override
  void onInit() {
    super.onInit();
    refreshDayRecords();
  }

  final RxList<DayRecord> dayRecords = RxList<DayRecord>();
  final RxMap<DateTime, CalendarDayRingStyle> weekRingStyles = <DateTime, CalendarDayRingStyle>{}.obs;

  // Method to load ring states for a week
  Future<void> loadWeek(DateTime mondayOfWeek) async {
    final Map<DateTime, CalendarDayRingStyle> newStatuses = {};
    for (int i = 0; i < 7; i++) {
      final currentDay = mondayOfWeek.add(Duration(days: i));
      final normalizedDay = DateTime(currentDay.year, currentDay.month, currentDay.day);
      final dayRecord = await getDayRecord(normalizedDay);
      newStatuses[normalizedDay] = _resolveRingStyle(dayRecord);
    }
    weekRingStyles.addAll(newStatuses);
  }

  Future<DayRecord?> getDayRecord(DateTime date) async {
    return _repository.getDayRecord(date);
  }

  Future<List<DayRecord>> getAllDayRecords() async {
    await refreshDayRecords();
    return dayRecords;
  }

  // Adds a new DayRecord or updates an existing one based on the date.
  Future<void> addOrUpdateDayRecord(DayRecord dayRecord) async {
    final normalizedDate = DateTime(dayRecord.date.year, dayRecord.date.month, dayRecord.date.day);
    await _repository.upsertDayRecord(dayRecord.copyWith(date: normalizedDate));
    weekRingStyles[normalizedDate] = _resolveRingStyle(dayRecord);
    await refreshDayRecords();
  }

  // Method to update an existing DayRecord (Upsert: updates if exists, inserts if not)
  Future<void> updateDayRecord(DayRecord updatedRecord) async {
    final normalizedDate = DateTime(updatedRecord.date.year, updatedRecord.date.month, updatedRecord.date.day);
    await _repository.upsertDayRecord(updatedRecord.copyWith(date: normalizedDate));
    weekRingStyles[normalizedDate] = _resolveRingStyle(updatedRecord);
    await refreshDayRecords();
  }

  Future<void> addDayRecord(DayRecord newRecord) async {
    await addOrUpdateDayRecord(newRecord);
  }

  Future<List<CalendarDay>> getCalendarDays() async {
    final records = await _repository.getAllDayRecords();
    return records
        .map((record) => CalendarDay(
              date: record.date,
              hasMeals: record.meals.isNotEmpty,
              dayRecord: record,
              ringStyle: _resolveRingStyle(record),
            ))
        .toList();
  }

  Future<Meal?> saveMealForDate({required DateTime date, required Meal mealToSave}) async {
    try {
      final savedDayRecord = await _repository.saveMealForDate(date: date, meal: mealToSave);
      final normalizedDate = DateTime(date.year, date.month, date.day);
      weekRingStyles[normalizedDate] = _resolveRingStyle(savedDayRecord);
      await refreshDayRecords();
      if (mealToSave.name.trim().isNotEmpty) {
        unawaited(MealTemplateRepository.to.upsertFromMeal(mealToSave));
      }
      // Return the saved meal (with DB-assigned id) for undo support
      if (mealToSave.id != null) {
        return savedDayRecord.meals.where((m) => m.id == mealToSave.id).firstOrNull;
      }
      return savedDayRecord.meals.where((m) => m.name == mealToSave.name).fold<Meal?>(null, (best, m) => best == null || (m.id ?? 0) > (best.id ?? 0) ? m : best);
    } catch (e) {
      Get.snackbar(
        tr(LocaleKeys.common_error),
        tr(LocaleKeys.error_saving_meal),
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
  }

  Future<Exercise?> saveExerciseForDate({required DateTime date, required Exercise exerciseToSave}) async {
    try {
      final savedDayRecord = await _repository.saveExerciseForDate(date: date, exercise: exerciseToSave);
      final normalizedDate = DateTime(date.year, date.month, date.day);
      weekRingStyles[normalizedDate] = _resolveRingStyle(savedDayRecord);
      await refreshDayRecords();
      if (exerciseToSave.name.trim().isNotEmpty && !exerciseToSave.isFromHealthSync) {
        unawaited(ExerciseTemplateRepository.to.upsertFromExercise(exerciseToSave));
      }
      // Return the saved exercise (with DB-assigned id) for undo support
      if (exerciseToSave.id != null) {
        return savedDayRecord.exercises.where((e) => e.id == exerciseToSave.id).firstOrNull;
      }
      return savedDayRecord.exercises.where((e) => e.name == exerciseToSave.name).fold<Exercise?>(null, (best, e) => best == null || (e.id ?? 0) > (best.id ?? 0) ? e : best);
    } catch (e) {
      Get.snackbar(
        tr(LocaleKeys.common_error),
        tr(LocaleKeys.error_saving_exercise),
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
  }

  Future<void> deleteMeal(Meal meal) async {
    try {
      await _repository.deleteMeal(meal);
      await refreshDayRecords();
    } catch (e) {
      Get.snackbar(
        tr(LocaleKeys.common_error),
        tr(LocaleKeys.error_deleting_meal),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> deleteExercise(Exercise exercise) async {
    try {
      await _repository.deleteExercise(exercise);
      await refreshDayRecords();
    } catch (e) {
      Get.snackbar(
        tr(LocaleKeys.common_error),
        tr(LocaleKeys.error_saving_exercise),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> setMealFavorite({required Meal meal, required bool isFavorite}) async {
    try {
      await _repository.updateMealFavorite(meal: meal, isFavorite: isFavorite);
      await refreshDayRecords();
    } catch (e) {
      Get.snackbar(
        tr(LocaleKeys.common_error),
        tr(LocaleKeys.error_updating_favorite),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> setExerciseFavorite({required Exercise exercise, required bool isFavorite}) async {
    try {
      await _repository.updateExerciseFavorite(exercise: exercise, isFavorite: isFavorite);
      await refreshDayRecords();
    } catch (e) {
      Get.snackbar(
        tr(LocaleKeys.common_error),
        tr(LocaleKeys.error_updating_favorite),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> refreshDayRecords() async {
    final records = await _repository.getAllDayRecords();
    dayRecords.assignAll(records);
    weekRingStyles.clear();
    for (final record in records) {
      final normalizedDate = DateTime(record.date.year, record.date.month, record.date.day);
      weekRingStyles[normalizedDate] = _resolveRingStyle(record);
    }
    _syncHomeWidgetForToday(records);
  }

  void _syncHomeWidgetForToday(List<DayRecord> records) {
    if (!Get.isRegistered<WidgetSyncService>()) return;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    DayRecord? todayRecord;
    for (final record in records) {
      final recordDate = DateTime(record.date.year, record.date.month, record.date.day);
      if (recordDate == today) {
        todayRecord = record;
        break;
      }
    }

    unawaited(
      WidgetSyncService.to.syncFromRecordOrFallback(
        todayRecord,
        date: today,
        reason: 'day_record_refresh',
      ),
    );
  }

  CalendarDayRingStyle _resolveRingStyle(DayRecord? dayRecord) {
    return _calendarDayRingService?.resolve(dayRecord) ?? CalendarDayRingService.emptyStyle;
  }

  @override
  void onHidden() {
    // TODO: implement onHidden
  }
}
