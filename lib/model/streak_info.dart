
/// Data class to hold streak information.
class StreakInfo {
  final int currentStreak;
  final int longestStreak;
  final List<bool> activeDaysThisWeek; // 7 booleans, Monday to Sunday

  StreakInfo({
    required this.currentStreak,
    required this.longestStreak,
    required this.activeDaysThisWeek,
  });

  /// Creates an initial or empty state for StreakInfo.
  factory StreakInfo.initial() {
    return StreakInfo(
      currentStreak: 0,
      longestStreak: 0,
      activeDaysThisWeek: List.filled(7, false),
    );
  }
}
