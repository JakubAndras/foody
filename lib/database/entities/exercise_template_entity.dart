import 'package:floor/floor.dart';

@Entity(tableName: 'ExerciseTemplate', indices: [
  Index(value: ['normalizedName'], unique: true),
])
class ExerciseTemplateEntity {
  @PrimaryKey(autoGenerate: true)
  final int? id;
  final String name;
  final String normalizedName;
  final int? durationMinutes;
  final double caloriesBurned;
  final bool isFavorite;
  final DateTime lastUsedAt;
  final int usageCount;

  ExerciseTemplateEntity({
    this.id,
    required this.name,
    required this.normalizedName,
    this.durationMinutes,
    required this.caloriesBurned,
    this.isFavorite = false,
    required this.lastUsedAt,
    this.usageCount = 1,
  });

  ExerciseTemplateEntity copyWith({
    int? id,
    String? name,
    String? normalizedName,
    int? durationMinutes,
    double? caloriesBurned,
    bool? isFavorite,
    DateTime? lastUsedAt,
    int? usageCount,
  }) {
    return ExerciseTemplateEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      normalizedName: normalizedName ?? this.normalizedName,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      isFavorite: isFavorite ?? this.isFavorite,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      usageCount: usageCount ?? this.usageCount,
    );
  }
}
