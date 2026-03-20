import 'package:floor/floor.dart';

@Entity(tableName: 'MealTemplate', indices: [
  Index(value: ['normalizedName'], unique: true),
])
class MealTemplateEntity {
  @PrimaryKey(autoGenerate: true)
  final int? id;
  final String name;
  final String normalizedName;
  final String? photoPath;
  final bool isFavorite;
  final DateTime lastUsedAt;
  final int usageCount;

  MealTemplateEntity({
    this.id,
    required this.name,
    required this.normalizedName,
    this.photoPath,
    this.isFavorite = false,
    required this.lastUsedAt,
    this.usageCount = 1,
  });

  MealTemplateEntity copyWith({
    int? id,
    String? name,
    String? normalizedName,
    String? photoPath,
    bool? isFavorite,
    DateTime? lastUsedAt,
    int? usageCount,
  }) {
    return MealTemplateEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      normalizedName: normalizedName ?? this.normalizedName,
      photoPath: photoPath ?? this.photoPath,
      isFavorite: isFavorite ?? this.isFavorite,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      usageCount: usageCount ?? this.usageCount,
    );
  }
}
