import 'dart:async';

import 'package:diplomka/controller/day_record_controller.dart';
import 'package:diplomka/model/day_record.dart';
import 'package:diplomka/model/nutrition_goals.dart';
import 'package:diplomka/services/day_record_repository.dart';
import 'package:diplomka/services/selected_date_service.dart';
import 'package:get/get.dart';

class NutritionGoalsService extends GetxService {
  static NutritionGoalsService get to {
    if (Get.isRegistered<NutritionGoalsService>()) {
      return Get.find<NutritionGoalsService>();
    }
    return Get.put(NutritionGoalsService(), permanent: true);
  }

  final RxMap<DateTime, NutritionGoals> goalsByDate = <DateTime, NutritionGoals>{}.obs;

  @override
  void onInit() {
    super.onInit();
    unawaited(refreshForDate(SelectedDateService.to.selectedDate.value));
  }

  NutritionGoals goalsForDate(DateTime date, {DayRecord? fallbackRecord}) {
    final normalizedDate = _normalize(date);
    final cached = goalsByDate[normalizedDate];
    if (cached != null) {
      return cached;
    }

    final historical = _resolveGoalsFromKnownDayRecords(normalizedDate);
    if (historical != null) {
      return historical;
    }

    if (fallbackRecord != null) {
      return NutritionGoals.fromDayRecord(fallbackRecord);
    }
    return NutritionGoals.defaults;
  }

  Future<void> refreshForDate(DateTime date) async {
    final normalizedDate = _normalize(date);
    final dayRecord = await DayRecordController.to.getDayRecord(normalizedDate);
    if (dayRecord == null) {
      goalsByDate.remove(normalizedDate);
      return;
    }
    goalsByDate[normalizedDate] = NutritionGoals.fromDayRecord(dayRecord);
  }

  void syncFromDayRecord({
    required DateTime date,
    required DayRecord? dayRecord,
  }) {
    final normalizedDate = _normalize(date);
    if (dayRecord == null) {
      goalsByDate.remove(normalizedDate);
      return;
    }
    goalsByDate[normalizedDate] = NutritionGoals.fromDayRecord(dayRecord);
  }

  Future<void> saveGoalsEffectiveFromDate({
    required DateTime effectiveDate,
    required NutritionGoals goals,
  }) async {
    final normalizedEffectiveDate = _normalize(effectiveDate);
    final records = await DayRecordController.to.getAllDayRecords();

    final futureOrTodayRecords = records.where((record) {
      final recordDate = _normalize(record.date);
      return !recordDate.isBefore(normalizedEffectiveDate);
    }).toList();

    if (!futureOrTodayRecords.any((record) => _normalize(record.date) == normalizedEffectiveDate)) {
      futureOrTodayRecords.add(DayRecord.initial(normalizedEffectiveDate));
    }

    for (final record in futureOrTodayRecords) {
      final normalizedDate = _normalize(record.date);
      final updatedRecord = goals.applyToDayRecord(record).copyWith(date: normalizedDate);
      await DayRecordRepository.to.upsertDayRecord(updatedRecord);
      goalsByDate[normalizedDate] = goals;
    }

    goalsByDate.removeWhere((date, _) => date.isAfter(normalizedEffectiveDate));
    goalsByDate[normalizedEffectiveDate] = goals;
    await DayRecordController.to.refreshDayRecords();
  }

  DateTime _normalize(DateTime date) => DateTime(date.year, date.month, date.day);

  NutritionGoals? _resolveGoalsFromKnownDayRecords(DateTime targetDate) {
    DayRecord? bestMatch;
    for (final record in DayRecordController.to.dayRecords) {
      final recordDate = _normalize(record.date);
      if (recordDate.isAfter(targetDate)) {
        continue;
      }
      if (bestMatch == null || recordDate.isAfter(_normalize(bestMatch.date))) {
        bestMatch = record;
      }
    }
    if (bestMatch == null) {
      return null;
    }
    return NutritionGoals.fromDayRecord(bestMatch);
  }
}
