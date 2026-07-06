import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/model/calendar_day.dart';
import 'package:diplomka/model/calendar_day_ring_style.dart';
import 'package:diplomka/model/day_record.dart';
import 'package:diplomka/model/exercise.dart';
import 'package:diplomka/model/ingredient.dart';
import 'package:diplomka/model/meal.dart';
import 'package:diplomka/services/calendar_day_ring_service.dart';
import 'package:diplomka/services/day_record_repository.dart';
import 'package:diplomka/services/exercise_template_repository.dart';
import 'package:diplomka/services/home_widget/widget_sync_service.dart';
import 'package:diplomka/services/ingredient_template_repository.dart';
import 'package:diplomka/services/meal_template_repository.dart';
import 'package:diplomka/services/session_manager.dart';

/// Sentinel pro `copyWith`, aby šlo nullovatelné `error` explicitně nastavit na `null`.
const Object _undefined = Object();

/// Immutable stav centrálního záznamu dnů.
/// Rx pole (`dayRecords`, `weekRingStyles`) se stala poli neměnného stavu.
@immutable
class DayRecordState {
  const DayRecordState({
    this.dayRecords = const [],
    this.weekRingStyles = const {},
    this.error,
  });

  final List<DayRecord> dayRecords;
  final Map<DateTime, CalendarDayRingStyle> weekRingStyles;

  /// Locale klíč poslední uživatelsky viditelné chyby (dříve `showSnackBar`).
  /// Notifier nenaviguje ani nezobrazuje dialog; UI reaguje přes `ref.listen`.
  final String? error;

  DayRecordState copyWith({
    List<DayRecord>? dayRecords,
    Map<DateTime, CalendarDayRingStyle>? weekRingStyles,
    Object? error = _undefined,
  }) {
    return DayRecordState(
      dayRecords: dayRecords ?? this.dayRecords,
      weekRingStyles: weekRingStyles ?? this.weekRingStyles,
      error: error == _undefined ? this.error : error as String?,
    );
  }
}

/// Kolekce se nikdy nemutují in-place — vždy se vytvoří nový `state` přes `copyWith`.
class DayRecordNotifier extends Notifier<DayRecordState> {
  int _loadWeekGeneration = 0;

  DayRecordRepository get _repository => ref.read(dayRecordRepositoryProvider);
  CalendarDayRingService get _calendarDayRingService => ref.read(calendarDayRingServiceProvider);

  @override
  DayRecordState build() {
    // Ekvivalent onInit(): iniciální načtení dat.
    unawaited(refreshDayRecords());
    return const DayRecordState();
  }

  // Method to load ring states for a week
  Future<void> loadWeek(DateTime mondayOfWeek) async {
    final generation = ++_loadWeekGeneration;
    final session = ref.read(sessionProvider);
    final bool burnedEnabled = session.burnedCaloriesEnabled;
    final bool rolloverEnabled = session.rolloverCaloriesEnabled;

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
    state = state.copyWith(weekRingStyles: {...state.weekRingStyles, ...newStatuses});
  }

  Future<DayRecord?> getDayRecord(DateTime date) async {
    return _repository.getDayRecord(date);
  }

  Future<List<DayRecord>> getAllDayRecords() async {
    await refreshDayRecords();
    return state.dayRecords;
  }

  // Adds a new DayRecord or updates an existing one based on the date.
  Future<void> addOrUpdateDayRecord(DayRecord dayRecord) async {
    final normalizedDate = DateTime(dayRecord.date.year, dayRecord.date.month, dayRecord.date.day);
    await _repository.upsertDayRecord(dayRecord.copyWith(date: normalizedDate));
    state = state.copyWith(weekRingStyles: {...state.weekRingStyles, normalizedDate: _resolveRingStyle(dayRecord)});
    await refreshDayRecords();
  }

  // Method to update an existing DayRecord (Upsert: updates if exists, inserts if not)
  Future<void> updateDayRecord(DayRecord updatedRecord) async {
    final normalizedDate = DateTime(updatedRecord.date.year, updatedRecord.date.month, updatedRecord.date.day);
    await _repository.upsertDayRecord(updatedRecord.copyWith(date: normalizedDate));
    state = state.copyWith(weekRingStyles: {...state.weekRingStyles, normalizedDate: _resolveRingStyle(updatedRecord)});
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
      state = state.copyWith(weekRingStyles: {...state.weekRingStyles, normalizedDate: _resolveRingStyle(savedDayRecord)});
      await refreshDayRecords();
      if (mealToSave.name.trim().isNotEmpty) {
        unawaited(ref.read(mealTemplatesProvider.notifier).upsertFromMeal(mealToSave));
        if (mealToSave.ingredients.isNotEmpty) {
          unawaited(ref.read(ingredientTemplatesProvider.notifier).upsertFromIngredients(mealToSave.ingredients));
        }
      }
      // Return the saved meal (with DB-assigned id) for undo support
      if (mealToSave.id != null) {
        return savedDayRecord.meals.where((m) => m.id == mealToSave.id).firstOrNull;
      }
      return savedDayRecord.meals.where((m) => m.name == mealToSave.name).fold<Meal?>(null, (best, m) => best == null || (m.id ?? 0) > (best.id ?? 0) ? m : best);
    } catch (e) {
      state = state.copyWith(error: LocaleKeys.error_saving_meal);
      return null;
    }
  }

  Future<Exercise?> saveExerciseForDate({required DateTime date, required Exercise exerciseToSave}) async {
    try {
      final savedDayRecord = await _repository.saveExerciseForDate(date: date, exercise: exerciseToSave);
      final normalizedDate = DateTime(date.year, date.month, date.day);
      state = state.copyWith(weekRingStyles: {...state.weekRingStyles, normalizedDate: _resolveRingStyle(savedDayRecord)});
      await refreshDayRecords();
      if (exerciseToSave.name.trim().isNotEmpty && !exerciseToSave.isFromHealthSync) {
        unawaited(ref.read(exerciseTemplatesProvider.notifier).upsertFromExercise(exerciseToSave));
      }
      // Return the saved exercise (with DB-assigned id) for undo support
      if (exerciseToSave.id != null) {
        return savedDayRecord.exercises.where((e) => e.id == exerciseToSave.id).firstOrNull;
      }
      return savedDayRecord.exercises.where((e) => e.name == exerciseToSave.name).fold<Exercise?>(null, (best, e) => best == null || (e.id ?? 0) > (best.id ?? 0) ? e : best);
    } catch (e) {
      state = state.copyWith(error: LocaleKeys.error_saving_exercise);
      return null;
    }
  }

  Future<void> deleteMeal(Meal meal) async {
    try {
      await _repository.deleteMeal(meal);
      await refreshDayRecords();
    } catch (e) {
      state = state.copyWith(error: LocaleKeys.error_deleting_meal);
    }
  }

  Future<void> deleteExercise(Exercise exercise) async {
    try {
      await _repository.deleteExercise(exercise);
      await refreshDayRecords();
    } catch (e) {
      state = state.copyWith(error: LocaleKeys.error_saving_exercise);
    }
  }

  Future<void> setMealFavorite({required Meal meal, required bool isFavorite}) async {
    try {
      await _repository.updateMealFavorite(meal: meal, isFavorite: isFavorite);
      await refreshDayRecords();
    } catch (e) {
      state = state.copyWith(error: LocaleKeys.error_updating_favorite);
    }
  }

  Future<void> setIngredientFavorite({required Ingredient ingredient, required bool isFavorite}) async {
    try {
      await _repository.updateIngredientFavorite(ingredient: ingredient, isFavorite: isFavorite);
      await refreshDayRecords();
    } catch (e) {
      state = state.copyWith(error: LocaleKeys.error_updating_favorite);
    }
  }

  Future<void> setExerciseFavorite({required Exercise exercise, required bool isFavorite}) async {
    try {
      await _repository.updateExerciseFavorite(exercise: exercise, isFavorite: isFavorite);
      await refreshDayRecords();
    } catch (e) {
      state = state.copyWith(error: LocaleKeys.error_updating_favorite);
    }
  }

  Future<void> refreshDayRecords() async {
    final records = await _repository.getAllDayRecords();

    final session = ref.read(sessionProvider);
    final bool burnedEnabled = session.burnedCaloriesEnabled;
    final bool rolloverEnabled = session.rolloverCaloriesEnabled;

    // Sort by date so we can compute rollover from previous day
    final sorted = List<DayRecord>.from(records)..sort((a, b) => a.date.compareTo(b.date));

    final Map<DateTime, CalendarDayRingStyle> newRingStyles = {};
    DayRecord? prevRecord;
    for (final record in sorted) {
      final normalizedDate = DateTime(record.date.year, record.date.month, record.date.day);
      final double rollover = _computeRollover(prevRecord, burnedEnabled: burnedEnabled, rolloverEnabled: rolloverEnabled);
      newRingStyles[normalizedDate] = _resolveRingStyleWithSettings(record, burnedEnabled: burnedEnabled, rollover: rollover);
      prevRecord = record;
    }

    state = state.copyWith(dayRecords: List<DayRecord>.from(records), weekRingStyles: newRingStyles);
    _syncHomeWidgetForToday(records);
  }

  void _syncHomeWidgetForToday(List<DayRecord> records) {
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
      ref.read(widgetSyncServiceProvider).syncFromRecordOrFallback(
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
    return _calendarDayRingService.resolve(dayRecord, consumed: consumed, effectiveGoal: goal > 0 ? goal : null);
  }

  double _computeRollover(DayRecord? prevRecord, {required bool burnedEnabled, required bool rolloverEnabled}) {
    if (!rolloverEnabled || prevRecord == null || prevRecord.calorieGoal <= 0) return 0;
    final double prevConsumed = burnedEnabled ? prevRecord.netCalories : prevRecord.totalCalories;
    return (prevRecord.calorieGoal - prevConsumed).clamp(0, 500);
  }

  CalendarDayRingStyle _resolveRingStyle(DayRecord? dayRecord) {
    final bool burnedEnabled = ref.read(sessionProvider).burnedCaloriesEnabled;
    return _resolveRingStyleWithSettings(dayRecord, burnedEnabled: burnedEnabled, rollover: 0);
  }
}

final dayRecordProvider = NotifierProvider<DayRecordNotifier, DayRecordState>(DayRecordNotifier.new);
