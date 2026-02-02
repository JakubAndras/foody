import 'package:floor/floor.dart';

import 'meal_entity.dart';

@Entity(
  tableName: 'Ingredient',
  foreignKeys: [
    ForeignKey(
      childColumns: ['mealId'],
      parentColumns: ['id'],
      entity: MealEntity,
      onDelete: ForeignKeyAction.cascade,
    ),
  ],
)
class IngredientEntity {
  @PrimaryKey(autoGenerate: true)
  final int? id;
  final int mealId;
  final String name;
  final double weight;
  final double calories;
  final double proteins;
  final double carbs;
  final double fats;

  IngredientEntity({
    this.id,
    required this.mealId,
    required this.name,
    required this.weight,
    required this.calories,
    required this.proteins,
    required this.carbs,
    required this.fats,
  });

  IngredientEntity copyWith({
    int? id,
    int? mealId,
    String? name,
    double? weight,
    double? calories,
    double? proteins,
    double? carbs,
    double? fats,
  }) {
    return IngredientEntity(
      id: id ?? this.id,
      mealId: mealId ?? this.mealId,
      name: name ?? this.name,
      weight: weight ?? this.weight,
      calories: calories ?? this.calories,
      proteins: proteins ?? this.proteins,
      carbs: carbs ?? this.carbs,
      fats: fats ?? this.fats,
    );
  }
}
