import 'package:diplomka/model/exercise.dart';

class ExerciseTemplate {
  final int? id;
  final String name;
  final String normalizedName;
  final int? durationMinutes;
  final double caloriesBurned;
  final bool isFavorite;
  final DateTime lastUsedAt;
  final int usageCount;

  const ExerciseTemplate({
    this.id,
    required this.name,
    required this.normalizedName,
    this.durationMinutes,
    required this.caloriesBurned,
    this.isFavorite = false,
    required this.lastUsedAt,
    this.usageCount = 1,
  });

  Exercise toExercise({required DateTime timestamp}) {
    return Exercise(
      name: name,
      timestamp: timestamp,
      durationMinutes: durationMinutes,
      caloriesBurned: caloriesBurned,
    );
  }

  static String normalize(String name) => name.trim().toLowerCase();
}
