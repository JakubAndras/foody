import 'package:floor/floor.dart';

@Entity(tableName: 'IngredientTemplate', indices: [
  Index(value: ['normalizedName'], unique: true),
])
class IngredientTemplateEntity {
  @PrimaryKey(autoGenerate: true)
  final int? id;
  final String name;
  final String normalizedName;
  final double weight;
  final double amount;
  final double calories;
  final double proteins;
  final double carbs;
  final double fats;
  final bool isFavorite;
  final DateTime lastUsedAt;
  final int usageCount;

  IngredientTemplateEntity({
    this.id,
    required this.name,
    required this.normalizedName,
    required this.weight,
    this.amount = 1.0,
    required this.calories,
    required this.proteins,
    required this.carbs,
    required this.fats,
    this.isFavorite = false,
    required this.lastUsedAt,
    this.usageCount = 1,
  });

  IngredientTemplateEntity copyWith({
    int? id,
    String? name,
    String? normalizedName,
    double? weight,
    double? amount,
    double? calories,
    double? proteins,
    double? carbs,
    double? fats,
    bool? isFavorite,
    DateTime? lastUsedAt,
    int? usageCount,
  }) {
    return IngredientTemplateEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      normalizedName: normalizedName ?? this.normalizedName,
      weight: weight ?? this.weight,
      amount: amount ?? this.amount,
      calories: calories ?? this.calories,
      proteins: proteins ?? this.proteins,
      carbs: carbs ?? this.carbs,
      fats: fats ?? this.fats,
      isFavorite: isFavorite ?? this.isFavorite,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      usageCount: usageCount ?? this.usageCount,
    );
  }
}
