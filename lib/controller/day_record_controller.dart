import 'dart:async';

import 'package:diplomka/widgets/logged_snackbar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:get/get.dart';

import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/model/calendar_day.dart';
import 'package:diplomka/model/calendar_day_ring_style.dart';
import 'package:diplomka/model/day_record.dart';
import 'package:diplomka/model/exercise.dart';
import 'package:diplomka/model/ingredient.dart';
import 'package:diplomka/services/calendar_day_ring_service.dart';
import 'package:diplomka/services/day_record_repository.dart';
import 'package:diplomka/services/exercise_template_repository.dart';
import 'package:diplomka/services/home_widget/widget_sync_service.dart';
import 'package:diplomka/services/ingredient_template_repository.dart';
import 'package:diplomka/services/meal_template_repository.dart';
import 'package:diplomka/services/session_manager.dart';

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
  int _loadWeekGeneration = 0;

  // Method to load ring states for a week
  Future<void> loadWeek(DateTime mondayOfWeek) async {
    final generation = ++_loadWeekGeneration;
    final bool burnedEnabled = SessionManager.to.burnedCaloriesEnabled.value;
    final bool rolloverEnabled = SessionManager.to.rolloverCaloriesEnabled.value;

    // Load all 8 days in parallel (Sunday for rollover + Mon-Sun)
    final sunday = DateTime(mondayOfWeek.year, mondayOfWeek.month, mondayOfWeek.day - 1);
    final daysToLoad = [DateTime(sunday.year, sunday.month, sunday.day), ...List.generate(7, (i) {
      return DateTime(mondayOfWeek.year, mondayOfWeek.month, mondayOfWeek.day + i);
    })];
    final results = await Future.wait(daysToLoad.map(getDayRecord));
    if (generation != _loadWeekGeneration) return;

    final Map<DateTime, CalendarDayRingStyle> newStatuses = {};
    DayRecord? prevRecord = results[0]; // Sunday
    for (int i = 1; i < results.length; i++) {
      final normalizedDay = daysToLoad[i];
      final dayRecord = results[i];
      final double rollover = _computeRollover(prevRecord, burnedEnabled: burnedEnabled, rolloverEnabled: rolloverEnabled);
      newStatuses[normalizedDay] = _resolveRingStyleWithSettings(dayRecord, burnedEnabled: burnedEnabled, rollover: rollover);
      prevRecord = dayRecord;
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
        if (mealToSave.ingredients.isNotEmpty) {
          unawaited(IngredientTemplateRepository.to.upsertFromIngredients(mealToSave.ingredients));
        }
      }
      // Return the saved meal (with DB-assigned id) for undo support
      if (mealToSave.id != null) {
        return savedDayRecord.meals.where((m) => m.id == mealToSave.id).firstOrNull;
      }
      return savedDayRecord.meals.where((m) => m.name == mealToSave.name).fold<Meal?>(null, (best, m) => best == null || (m.id ?? 0) > (best.id ?? 0) ? m : best);
    } catch (e) {
      showSnackBar(message: tr(LocaleKeys.common_error), subtitle: tr(LocaleKeys.error_saving_meal), type: SnackBarType.error);
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
      showSnackBar(message: tr(LocaleKeys.common_error), subtitle: tr(LocaleKeys.error_saving_exercise), type: SnackBarType.error);
      return null;
    }
  }

  Future<void> deleteMeal(Meal meal) async {
    try {
      await _repository.deleteMeal(meal);
      await refreshDayRecords();
    } catch (e) {
      showSnackBar(message: tr(LocaleKeys.common_error), subtitle: tr(LocaleKeys.error_deleting_meal), type: SnackBarType.error);
    }
  }

  Future<void> deleteExercise(Exercise exercise) async {
    try {
      await _repository.deleteExercise(exercise);
      await refreshDayRecords();
    } catch (e) {
      showSnackBar(message: tr(LocaleKeys.common_error), subtitle: tr(LocaleKeys.error_saving_exercise), type: SnackBarType.error);
    }
  }

  Future<void> setMealFavorite({required Meal meal, required bool isFavorite}) async {
    try {
      await _repository.updateMealFavorite(meal: meal, isFavorite: isFavorite);
      await refreshDayRecords();
    } catch (e) {
      showSnackBar(message: tr(LocaleKeys.common_error), subtitle: tr(LocaleKeys.error_updating_favorite), type: SnackBarType.error);
    }
  }

  Future<void> setIngredientFavorite({required Ingredient ingredient, required bool isFavorite}) async {
    try {
      await _repository.updateIngredientFavorite(ingredient: ingredient, isFavorite: isFavorite);
      await refreshDayRecords();
    } catch (e) {
      showSnackBar(message: tr(LocaleKeys.common_error), subtitle: tr(LocaleKeys.error_updating_favorite), type: SnackBarType.error);
    }
  }

  Future<void> setExerciseFavorite({required Exercise exercise, required bool isFavorite}) async {
    try {
      await _repository.updateExerciseFavorite(exercise: exercise, isFavorite: isFavorite);
      await refreshDayRecords();
    } catch (e) {
      showSnackBar(message: tr(LocaleKeys.common_error), subtitle: tr(LocaleKeys.error_updating_favorite), type: SnackBarType.error);
    }
  }

  Future<void> refreshDayRecords() async {
    final records = await _repository.getAllDayRecords();
    dayRecords.assignAll(records);

    final bool burnedEnabled = SessionManager.to.burnedCaloriesEnabled.value;
    final bool rolloverEnabled = SessionManager.to.rolloverCaloriesEnabled.value;

    // Sort by date so we can compute rollover from previous day
    final sorted = List<DayRecord>.from(records)..sort((a, b) => a.date.compareTo(b.date));

    weekRingStyles.clear();
    DayRecord? prevRecord;
    for (final record in sorted) {
      final normalizedDate = DateTime(record.date.year, record.date.month, record.date.day);
      final double rollover = _computeRollover(prevRecord, burnedEnabled: burnedEnabled, rolloverEnabled: rolloverEnabled);
      weekRingStyles[normalizedDate] = _resolveRingStyleWithSettings(record, burnedEnabled: burnedEnabled, rollover: rollover);
      prevRecord = record;
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

  CalendarDayRingStyle _resolveRingStyleWithSettings(DayRecord? dayRecord, {required bool burnedEnabled, required double rollover}) {
    if (dayRecord == null) return CalendarDayRingService.emptyStyle;
    final double consumed = burnedEnabled ? dayRecord.netCalories : dayRecord.totalCalories;
    final double goal = dayRecord.calorieGoal + rollover;
    return _calendarDayRingService?.resolve(dayRecord, consumed: consumed, effectiveGoal: goal > 0 ? goal : null) ?? CalendarDayRingService.emptyStyle;
  }

  double _computeRollover(DayRecord? prevRecord, {required bool burnedEnabled, required bool rolloverEnabled}) {
    if (!rolloverEnabled || prevRecord == null || prevRecord.calorieGoal <= 0) return 0;
    final double prevConsumed = burnedEnabled ? prevRecord.netCalories : prevRecord.totalCalories;
    return (prevRecord.calorieGoal - prevConsumed).clamp(0, 500);
  }

  CalendarDayRingStyle _resolveRingStyle(DayRecord? dayRecord) {
    final bool burnedEnabled = SessionManager.to.burnedCaloriesEnabled.value;
    return _resolveRingStyleWithSettings(dayRecord, burnedEnabled: burnedEnabled, rollover: 0);
  }

  @override
  void onHidden() {
    // TODO: implement onHidden
  }
}
