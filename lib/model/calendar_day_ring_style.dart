class CalendarDayRingStyle {
  CalendarDayRingStyle({
    required this.filledSegments,
    this.overflowSegments = 0,
    this.totalSegments = 10,
    this.roundedPercent = 0,
    this.overflowFraction = 0.0,
  });

  final int filledSegments;
  final int overflowSegments;
  final int totalSegments;
  final int roundedPercent;

  /// Continuous overflow fraction (0.0–1.0) for smooth red arc rendering.
  /// Represents how much of the ring the excess fills (excess / goal).
  final double overflowFraction;
}
