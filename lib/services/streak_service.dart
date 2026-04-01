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

    final currentStreak = _calculateCurrentStreak(
      anchorDate: streakAnchorDate,
      hasMealsByDate: hasMealsByDate,
    );

    return StreakInfo(
      currentStreak: currentStreak,
      longestStreak: _calculateLongestStreak(hasMealsByDate: hasMealsByDate, currentStreak: currentStreak),
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
    return DateTime(today.year, today.month, today.day - 1);
  }

  int _calculateCurrentStreak({
    required DateTime anchorDate,
    required Map<DateTime, bool> hasMealsByDate,
  }) {
    int currentStreak = 0;
    DateTime cursor = anchorDate;

    while (hasMealsByDate[cursor] ?? false) {
      currentStreak += 1;
      cursor = DateTime(cursor.year, cursor.month, cursor.day - 1);
    }

    return currentStreak;
  }

  int _calculateLongestStreak({required Map<DateTime, bool> hasMealsByDate, required int currentStreak}) {
    if (hasMealsByDate.isEmpty) return 0;

    final sortedDates = hasMealsByDate.keys.where((d) => hasMealsByDate[d] == true).toList()..sort();
    if (sortedDates.isEmpty) return 0;

    int longest = 1;
    int run = 1;
    for (int i = 1; i < sortedDates.length; i++) {
      final prev = sortedDates[i - 1];
      final nextDay = DateTime(prev.year, prev.month, prev.day + 1);
      if (sortedDates[i] == nextDay) {
        run++;
        if (run > longest) longest = run;
      } else {
        run = 1;
      }
    }
    return longest > currentStreak ? longest : currentStreak;
  }

  List<bool> _calculateActiveDaysThisWeek({
    required DateTime today,
    required Map<DateTime, bool> hasMealsByDate,
  }) {
    final List<bool> activeDaysThisWeek = List<bool>.filled(7, false);
    final DateTime monday = DateTime(today.year, today.month, today.day - (today.weekday - 1));

    for (int i = 0; i < 7; i++) {
      final DateTime weekDay = DateTime(monday.year, monday.month, monday.day + i);
      activeDaysThisWeek[i] = hasMealsByDate[weekDay] ?? false;
    }

    return activeDaysThisWeek;
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
