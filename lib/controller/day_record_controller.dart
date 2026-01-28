import 'package:get/get.dart';

import 'package:diplomka/database/dao/day_record_dao.dart';
import 'package:diplomka/model/calendar_day.dart';
import 'package:diplomka/model/day_record.dart';

import '../database/app_database.dart';
import '../model/meal.dart';
import 'base_controller.dart';

class DayRecordController extends BaseController {
  static DayRecordController get to => Get.find();

  DayRecordController({
    required AppDatabase database,
  }) : _database = database;

  final AppDatabase _database;
  late final DayRecordDao _dayRecordDao;

  @override
  void onInit() {
    super.onInit();
    _dayRecordDao = _database.dayRecordDao;

    final Stream<List<DayRecord>> dayRecordsStream = _dayRecordDao.watchDayRecords();

    dayRecords.bindStream(dayRecordsStream);
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
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final record = await _dayRecordDao.findDayRecordByDate(normalizedDate.millisecondsSinceEpoch);
    return record;
  }

  Future<List<DayRecord>> getAllDayRecords() async {
    return dayRecords; // await _dayRecordDao.getAllDayRecords();
  }

  // Adds a new DayRecord or updates an existing one based on the date.
  Future<void> addOrUpdateDayRecord(DayRecord dayRecord) async {
    final normalizedDate = DateTime(dayRecord.date.year, dayRecord.date.month, dayRecord.date.day);
    final normalizedRecord = dayRecord.copyWith(date: normalizedDate);

    final existingRecord = await getDayRecord(normalizedDate);

    if (existingRecord != null) {
      await _dayRecordDao.updateDayRecord(normalizedRecord.copyWith(id: existingRecord.id));
    } else {
      await _dayRecordDao.insertDayRecord(normalizedRecord);
    }
    // Update reactive state
    weekStatuses[normalizedDate] = normalizedRecord.meals.isNotEmpty;
  }

  // Method to update an existing DayRecord (Upsert: updates if exists, inserts if not)
  Future<void> updateDayRecord(DayRecord updatedRecord) async {
    final normalizedDate = DateTime(updatedRecord.date.year, updatedRecord.date.month, updatedRecord.date.day);
    DayRecord recordToSave = updatedRecord.copyWith(date: normalizedDate);

    final existingRecord = await getDayRecord(normalizedDate);

    if (existingRecord != null) {
      recordToSave = recordToSave.copyWith(id: existingRecord.id);
      await _dayRecordDao.updateDayRecord(recordToSave);
    } else {
      await _dayRecordDao.insertDayRecord(recordToSave);
    }
    // Update reactive state
    weekStatuses[normalizedDate] = recordToSave.meals.isNotEmpty;
  }

  Future<void> addDayRecord(DayRecord newRecord) async {
    final normalizedDate = DateTime(newRecord.date.year, newRecord.date.month, newRecord.date.day);
    final normalizedRecord = newRecord.copyWith(date: normalizedDate);

    await _dayRecordDao.insertDayRecord(normalizedRecord);
    // Update reactive state
    weekStatuses[normalizedDate] = normalizedRecord.meals.isNotEmpty;
  }

  Future<List<CalendarDay>> getCalendarDays() async {
    final dayRecords = await _dayRecordDao.getAllDayRecords();

    return dayRecords.map((record) {
      return CalendarDay(
        date: record.date,
        hasMeals: record.meals.isNotEmpty,
        dayRecord: record,
      );
    }).toList();
  }

  Future<void> addMealToDayRecord({required DayRecord dayRecord, required Meal mealToSave, bool isNewMeal = false}) async {
    try {
      List<Meal> updatedMeals;

      if (isNewMeal) {
        updatedMeals = List<Meal>.from(dayRecord.meals)
          ..add(mealToSave);
      } else {
        // This is an update to an existing meal in the list
        // Need to find the existing meal and replace it or handle ID carefully
        int existingMealIndex = dayRecord.meals.indexWhere((m) => m.id == mealToSave.id);
        if (existingMealIndex != -1) {
          updatedMeals = List<Meal>.from(dayRecord.meals);
          updatedMeals[existingMealIndex] = mealToSave;
        } else {
          // If not found by ID (e.g. ID was null for a template being added), treat as new
          updatedMeals = List<Meal>.from(dayRecord.meals)
            ..add(mealToSave);
        }
      }

      final updatedDayRecord = dayRecord.copyWith(meals: updatedMeals);
      await DayRecordController.to.addOrUpdateDayRecord(updatedDayRecord);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error saving meal: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  void onHidden() {
    // TODO: implement onHidden
  }
}
