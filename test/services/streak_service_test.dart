import 'package:diplomka/model/day_record.dart';
import 'package:diplomka/model/meal.dart';
import 'package:diplomka/services/streak_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StreakService', () {
    final service = StreakService();

    test('keeps yesterday streak when today has no meal log yet', () {
      final now = DateTime(2026, 2, 26);
      final records = <DayRecord>[
        _dayRecord(DateTime(2026, 2, 25), hasMeal: true),
        _dayRecord(DateTime(2026, 2, 24), hasMeal: true),
      ];

      final result = service.calculateStreakInfo(records, now: now);

      expect(result.currentStreak, 2);
    });

    test('resets streak to zero when previous day is missed', () {
      final now = DateTime(2026, 2, 26);
      final records = <DayRecord>[
        _dayRecord(DateTime(2026, 2, 24), hasMeal: true),
      ];

      final result = service.calculateStreakInfo(records, now: now);

      expect(result.currentStreak, 0);
    });

    test('starts a new streak when today is logged after a break', () {
      final now = DateTime(2026, 2, 26);
      final records = <DayRecord>[
        _dayRecord(DateTime(2026, 2, 26), hasMeal: true),
        _dayRecord(DateTime(2026, 2, 24), hasMeal: true),
      ];

      final result = service.calculateStreakInfo(records, now: now);

      expect(result.currentStreak, 1);
    });

    test('calculates active days in current week and ignores future logs', () {
      final now = DateTime(2026, 2, 26); // Thursday
      final records = <DayRecord>[
        _dayRecord(DateTime(2026, 2, 23), hasMeal: true), // Monday
        _dayRecord(DateTime(2026, 2, 24), hasMeal: true), // Tuesday
        _dayRecord(DateTime(2026, 2, 26), hasMeal: true), // Thursday
        _dayRecord(DateTime(2026, 2, 27), hasMeal: true), // Friday (future)
      ];

      final result = service.calculateStreakInfo(records, now: now);

      expect(result.activeDaysThisWeek, <bool>[true, true, false, true, false, false, false]);
    });
  });
}

DayRecord _dayRecord(
  DateTime date, {
  required bool hasMeal,
}) {
  return DayRecord(
    date: date,
    meals: hasMeal ? <Meal>[_mealAt(date)] : <Meal>[],
  );
}

Meal _mealAt(DateTime date) {
  return Meal(
    name: 'Meal',
    ingredients: const [],
    timestamp: DateTime(date.year, date.month, date.day, 12),
  );
}
