import 'package:floor/floor.dart';

import 'meal_template_entity.dart';

@Entity(
  tableName: 'MealTemplateIngredient',
  foreignKeys: [
    ForeignKey(
      childColumns: ['templateId'],
      parentColumns: ['id'],
      entity: MealTemplateEntity,
      onDelete: ForeignKeyAction.cascade,
    ),
  ],
)
class MealTemplateIngredientEntity {
  @PrimaryKey(autoGenerate: true)
  final int? id;
  final int templateId;
  final String name;
  final double weight;
  final double calories;
  final double proteins;
  final double carbs;
  final double fats;
  final String? dietaryViolation;

  MealTemplateIngredientEntity({
    this.id,
    required this.templateId,
    required this.name,
    required this.weight,
    required this.calories,
    required this.proteins,
    required this.carbs,
    required this.fats,
    this.dietaryViolation,
  });
}
