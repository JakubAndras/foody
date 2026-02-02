import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:diplomka/model/day_record.dart';
import 'package:diplomka/model/streak_info.dart';
import 'package:diplomka/controller/day_record_controller.dart';

import 'base_controller.dart';

class StreakController extends BaseController {
  static StreakController get to => Get.find();

  // Calculates streak information.
  Future<StreakInfo> getStreakInfo() async {
    try {
      final List<DayRecord> allRecordsRaw = await DayRecordController.to.getAllDayRecords();

      if (allRecordsRaw.isEmpty) {
        return StreakInfo.initial();
      }

      // Sort records by date in descending order (newest first)
      final List<DayRecord> allRecordsSorted = List<DayRecord>.from(allRecordsRaw);
      allRecordsSorted.sort((a, b) => b.date.compareTo(a.date));

      DateTime today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

      // Filter out records from the future for streak calculation.
      final relevantRecordsForStreak = allRecordsSorted.where((record) {
        DateTime recordDate = DateTime(record.date.year, record.date.month, record.date.day);
        return !recordDate.isAfter(today);
      }).toList();

      int currentStreak = 0;
      DateTime expectedStreakDate = today;

      for (final record in relevantRecordsForStreak) {
        DateTime recordDate = DateTime(record.date.year, record.date.month, record.date.day);

        if (recordDate.isAfter(expectedStreakDate)) {
          continue;
        }

        if (recordDate.isAtSameMomentAs(expectedStreakDate)) {
          if (record.meals.isNotEmpty) { // Assuming DayRecord has a 'meals' field
            currentStreak++;
            expectedStreakDate = expectedStreakDate.subtract(const Duration(days: 1));
          } else {
            break; // Record for expected date exists but has no meals, streak broken.
          }
        } else {
          break; // Gap encountered, streak broken.
        }
      }

      // Calculate active days for the current week (Mon-Sun)
      List<bool> activeDaysThisWeek = List.filled(7, false);
      DateTime firstDayOfWeek = today.subtract(Duration(days: today.weekday - 1)); // Monday

      for (int i = 0; i < 7; i++) {
        DateTime weekDay = firstDayOfWeek.add(Duration(days: i));
        final recordForWeekDay = allRecordsRaw.firstWhere(
          (r) => DateTime(r.date.year, r.date.month, r.date.day).isAtSameMomentAs(weekDay),
          // Ensure a valid DayRecord structure for orElse, matching your model's constructor
          orElse: () => DayRecord(date: DateTime(0), meals: [], calorieGoal: 0, proteinGoal: 0, carbsGoal: 0, fatGoal: 0) // Dummy record
        );
        // Check if it's not the dummy record AND has meals
        if (recordForWeekDay.date.year != 0 && recordForWeekDay.meals.isNotEmpty) {
          activeDaysThisWeek[i] = true;
        }
      }

      return StreakInfo(
        currentStreak: currentStreak,
        activeDaysThisWeek: activeDaysThisWeek,
      );
    } catch (e) {
      // Log the error and return initial/empty state or rethrow a custom exception
      debugPrint('Error calculating streak info: $e');
      // Consider returning StreakInfo.initial() or a specific error state
      // depending on how you want the UI to react.
      return StreakInfo.initial(); // Fallback to initial state on error
    }
  }

  @override
  void onHidden() {
    // TODO: implement onHidden
  }
}
