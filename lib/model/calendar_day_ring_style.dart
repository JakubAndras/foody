class CalendarDayRingStyle {
  CalendarDayRingStyle({
    required this.filledSegments,
    this.overflowSegments = 0,
    this.totalSegments = 10,
    this.roundedPercent = 0,
  });

  final int filledSegments;
  final int overflowSegments;
  final int totalSegments;
  final int roundedPercent;
}
