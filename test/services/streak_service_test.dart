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

    test('streak spans across week boundary', () {
      // Sunday March 29 → Monday March 30 (new week)
      final now = DateTime(2026, 3, 30); // Monday
      final records = <DayRecord>[
        _dayRecord(DateTime(2026, 3, 30), hasMeal: true), // Mon (this week)
        _dayRecord(DateTime(2026, 3, 29), hasMeal: true), // Sun (last week)
        _dayRecord(DateTime(2026, 3, 28), hasMeal: true), // Sat
        _dayRecord(DateTime(2026, 3, 27), hasMeal: true), // Fri
        _dayRecord(DateTime(2026, 3, 26), hasMeal: true), // Thu
        _dayRecord(DateTime(2026, 3, 25), hasMeal: true), // Wed
        _dayRecord(DateTime(2026, 3, 24), hasMeal: true), // Tue
        _dayRecord(DateTime(2026, 3, 23), hasMeal: true), // Mon (last week)
      ];

      final result = service.calculateStreakInfo(records, now: now);

      expect(result.currentStreak, 8);
    });

    test('streak spans multiple weeks', () {
      final now = DateTime(2026, 3, 30); // Monday
      final records = <DayRecord>[
        for (int i = 0; i < 21; i++) _dayRecord(DateTime(2026, 3, 30 - i), hasMeal: true),
      ];

      final result = service.calculateStreakInfo(records, now: now);

      expect(result.currentStreak, 21);
    });

    test('longest streak counts correctly across DST spring-forward (Mar 29 CET)', () {
      final now = DateTime(2026, 4, 1);
      final records = <DayRecord>[
        _dayRecord(DateTime(2026, 3, 25), hasMeal: true),
        _dayRecord(DateTime(2026, 3, 26), hasMeal: true),
        _dayRecord(DateTime(2026, 3, 27), hasMeal: true),
        _dayRecord(DateTime(2026, 3, 28), hasMeal: true),
        _dayRecord(DateTime(2026, 3, 29), hasMeal: true), // DST spring-forward
      ];

      final result = service.calculateStreakInfo(records, now: now);

      expect(result.longestStreak, 5);
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
