import 'package:diplomka/model/day_record.dart';
import 'package:diplomka/model/streak_info.dart';
import 'package:get/get.dart';

class StreakService extends GetxService {
  static StreakService get to => Get.find();

  StreakInfo calculateStreakInfo(
    Iterable<DayRecord> records, {
    DateTime? now,
  }) {
    final DateTime today = _normalizeDate(now ?? DateTime.now());
    final Map<DateTime, bool> hasMealsByDate = _buildMealPresenceByDate(
      records: records,
      today: today,
    );

    final DateTime streakAnchorDate = _resolveStreakAnchorDate(
      today: today,
      hasMealsByDate: hasMealsByDate,
    );

    return StreakInfo(
      currentStreak: _calculateCurrentStreak(
        anchorDate: streakAnchorDate,
        hasMealsByDate: hasMealsByDate,
      ),
      activeDaysThisWeek: _calculateActiveDaysThisWeek(
        today: today,
        hasMealsByDate: hasMealsByDate,
      ),
    );
  }

  Map<DateTime, bool> _buildMealPresenceByDate({
    required Iterable<DayRecord> records,
    required DateTime today,
  }) {
    final Map<DateTime, bool> hasMealsByDate = <DateTime, bool>{};
    for (final DayRecord record in records) {
      final DateTime recordDate = _normalizeDate(record.date);
      if (recordDate.isAfter(today)) {
        continue;
      }

      final bool alreadyLoggedForDate = hasMealsByDate[recordDate] ?? false;
      hasMealsByDate[recordDate] = alreadyLoggedForDate || record.meals.isNotEmpty;
    }
    return hasMealsByDate;
  }

  DateTime _resolveStreakAnchorDate({
    required DateTime today,
    required Map<DateTime, bool> hasMealsByDate,
  }) {
    final bool hasMealsToday = hasMealsByDate[today] ?? false;
    if (hasMealsToday) {
      return today;
    }

    // Day can still be saved until midnight, so missing today's meal log
    // does not instantly reset the current streak.
    return today.subtract(const Duration(days: 1));
  }

  int _calculateCurrentStreak({
    required DateTime anchorDate,
    required Map<DateTime, bool> hasMealsByDate,
  }) {
    int currentStreak = 0;
    DateTime cursor = anchorDate;

    while (hasMealsByDate[cursor] ?? false) {
      currentStreak += 1;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    return currentStreak;
  }

  List<bool> _calculateActiveDaysThisWeek({
    required DateTime today,
    required Map<DateTime, bool> hasMealsByDate,
  }) {
    final List<bool> activeDaysThisWeek = List<bool>.filled(7, false);
    final DateTime monday = today.subtract(Duration(days: today.weekday - 1));

    for (int i = 0; i < 7; i++) {
      final DateTime weekDay = monday.add(Duration(days: i));
      activeDaysThisWeek[i] = hasMealsByDate[weekDay] ?? false;
    }

    return activeDaysThisWeek;
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
