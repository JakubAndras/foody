import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:diplomka/model/calendar_day_ring_style.dart';
import 'package:diplomka/model/day_record.dart';

class CalendarDayRingService {
  static const int totalSegments = 10;
  static const double _segmentPercent = 10;
  static const double _overflowStartPercent = 105;

  static final CalendarDayRingStyle emptyStyle = CalendarDayRingStyle(
    filledSegments: 0,
    overflowSegments: 0,
    totalSegments: totalSegments,
    roundedPercent: 0,
  );

  CalendarDayRingStyle resolve(DayRecord? dayRecord, {double? consumed, double? effectiveGoal}) {
    final goal = effectiveGoal ?? dayRecord?.calorieGoal ?? 0;
    if (dayRecord == null || goal <= 0) {
      return emptyStyle;
    }

    final actualConsumed = consumed ?? dayRecord.totalCalories;
    final consumedPercent = (actualConsumed / goal) * 100;
    final roundedPercent = consumedPercent.round();
    if (roundedPercent <= 0) {
      return emptyStyle;
    }

    int filledSegments = (consumedPercent / _segmentPercent).round().clamp(0, totalSegments);
    int overflowSegments = 0;

    double overflowFraction = 0.0;

    if (consumedPercent > _overflowStartPercent) {
      overflowSegments = ((consumedPercent - 100) / _segmentPercent).round().clamp(1, totalSegments);
      filledSegments = totalSegments;
      overflowFraction = ((consumedPercent - 100) / 100).clamp(0.0, 1.0);
    }

    return CalendarDayRingStyle(
      filledSegments: filledSegments,
      overflowSegments: overflowSegments,
      totalSegments: totalSegments,
      roundedPercent: roundedPercent,
      overflowFraction: overflowFraction,
    );
  }
}

final calendarDayRingServiceProvider = Provider<CalendarDayRingService>((ref) => CalendarDayRingService());
