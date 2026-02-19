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
  );

  CalendarDayRingStyle resolve(DayRecord? dayRecord) {
    if (dayRecord == null || dayRecord.calorieGoal <= 0) {
      return emptyStyle;
    }

    final consumedPercent = (dayRecord.totalCalories / dayRecord.calorieGoal) * 100;
    if (consumedPercent <= 0) {
      return emptyStyle;
    }

    int filledSegments = (consumedPercent / _segmentPercent).round().clamp(0, totalSegments);
    int overflowSegments = 0;

    if (consumedPercent > _overflowStartPercent) {
      overflowSegments = ((consumedPercent - 100) / _segmentPercent).round().clamp(1, totalSegments);
      filledSegments = totalSegments;
    }

    return CalendarDayRingStyle(
      filledSegments: filledSegments,
      overflowSegments: overflowSegments,
      totalSegments: totalSegments,
    );
  }
}
