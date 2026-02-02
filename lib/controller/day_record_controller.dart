import 'package:get/get.dart';

import 'package:diplomka/model/calendar_day.dart';
import 'package:diplomka/model/day_record.dart';
import 'package:diplomka/services/day_record_repository.dart';

import '../model/meal.dart';
import 'base_controller.dart';

class DayRecordController extends BaseController {
  static DayRecordController get to => Get.find();

  DayRecordController({
    required DayRecordRepository repository,
  }) : _repository = repository;

  final DayRecordRepository _repository;

  @override
  void onInit() {
    super.onInit();
    refreshDayRecords();
  }

  final RxList<DayRecord> dayRecords = RxList<DayRecord>();
  final RxMap<DateTime, bool> weekStatuses = <DateTime, bool>{}.obs;

  // Method to load statuses for a week
  Future<void> loadWeek(DateTime mondayOfWeek) async {
    final Map<DateTime, bool> newStatuses = {};
    for (int i = 0; i < 7; i++) {
      final currentDay = mondayOfWeek.add(Duration(days: i));
      final normalizedDay = DateTime(currentDay.year, currentDay.month, currentDay.day);
      final dayRecord = await getDayRecord(normalizedDay);
      newStatuses[normalizedDay] = dayRecord != null && dayRecord.meals.isNotEmpty;
    }
    weekStatuses.addAll(newStatuses);
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
    weekStatuses[normalizedDate] = dayRecord.meals.isNotEmpty;
    await refreshDayRecords();
  }

  // Method to update an existing DayRecord (Upsert: updates if exists, inserts if not)
  Future<void> updateDayRecord(DayRecord updatedRecord) async {
    final normalizedDate = DateTime(updatedRecord.date.year, updatedRecord.date.month, updatedRecord.date.day);
    await _repository.upsertDayRecord(updatedRecord.copyWith(date: normalizedDate));
    weekStatuses[normalizedDate] = updatedRecord.meals.isNotEmpty;
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
            ))
        .toList();
  }

  Future<void> saveMealForDate({required DateTime date, required Meal mealToSave}) async {
    try {
      await _repository.saveMealForDate(date: date, meal: mealToSave);
      final normalizedDate = DateTime(date.year, date.month, date.day);
      weekStatuses[normalizedDate] = true;
      await refreshDayRecords();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error saving meal: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> deleteMeal(Meal meal) async {
    try {
      await _repository.deleteMeal(meal);
      await refreshDayRecords();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error deleting meal: ${e.toString()}',
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
        'Error',
        'Error updating favorite: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> refreshDayRecords() async {
    final records = await _repository.getAllDayRecords();
    dayRecords.assignAll(records);
    for (final record in records) {
      final normalizedDate = DateTime(record.date.year, record.date.month, record.date.day);
      weekStatuses[normalizedDate] = record.meals.isNotEmpty;
    }
  }

  @override
  void onHidden() {
    // TODO: implement onHidden
  }
}
