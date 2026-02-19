import 'package:diplomka/model/day_record.dart';
import 'package:diplomka/model/calendar_day_ring_style.dart';

class CalendarDay {
  final DateTime date;
  final bool hasMeals;
  final DayRecord? dayRecord;
  final CalendarDayRingStyle? ringStyle;

  CalendarDay({
    required this.date,
    this.hasMeals = false,
    this.dayRecord,
    this.ringStyle,
  });
}
