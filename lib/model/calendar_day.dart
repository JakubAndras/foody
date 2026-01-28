import 'package:diplomka/model/day_record.dart';

class CalendarDay {
  final DateTime date;
  final bool hasMeals;
  final DayRecord? dayRecord;

  CalendarDay({
    required this.date,
    this.hasMeals = false,
    this.dayRecord,
  });
}