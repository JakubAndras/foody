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
  final double? amount;
  final double calories;
  final double proteins;
  final double carbs;
  final double fats;
  final double? confidence;
  final bool isFavorite;

  // Dietary violation reason flagged by AI at log time, or null if not flagged.
  // Free-text in user locale; recomputed only on Fix-with-AI.
  // Legacy rows pre-migration v1→v2 are null and fall back to keyword matching.
  final String? dietaryViolation;

  // RESEARCH-ONLY: all fields below are research-only. Drop columns
  // (`aiOriginal*`, `wasEditedByUser`, `deletedAtMs`) and constructor params
  // before production. See RESEARCH_ONLY.md.
  final String? aiOriginalName;
  final double? aiOriginalWeight;
  final double? aiOriginalAmount;
  final double? aiOriginalCalories;
  final double? aiOriginalProteins;
  final double? aiOriginalCarbs;
  final double? aiOriginalFats;
  final double? aiOriginalConfidence;
  final bool wasEditedByUser;
  final int? deletedAtMs;
  // RESEARCH-ONLY: end

  IngredientEntity({
    this.id,
    required this.mealId,
    required this.name,
    required this.weight,
    this.amount = 1.0,
    required this.calories,
    required this.proteins,
    required this.carbs,
    required this.fats,
    this.confidence,
    this.isFavorite = false,
    this.dietaryViolation,
    // RESEARCH-ONLY: research-only ctor params below
    this.aiOriginalName,
    this.aiOriginalWeight,
    this.aiOriginalAmount,
    this.aiOriginalCalories,
    this.aiOriginalProteins,
    this.aiOriginalCarbs,
    this.aiOriginalFats,
    this.aiOriginalConfidence,
    this.wasEditedByUser = false,
    this.deletedAtMs,
  });

  IngredientEntity copyWith({
    int? id,
    int? mealId,
    String? name,
    double? weight,
    double? amount,
    double? calories,
    double? proteins,
    double? carbs,
    double? fats,
    double? confidence,
    bool? isFavorite,
    String? dietaryViolation,
    // RESEARCH-ONLY: research-only copyWith params below
    String? aiOriginalName,
    double? aiOriginalWeight,
    double? aiOriginalAmount,
    double? aiOriginalCalories,
    double? aiOriginalProteins,
    double? aiOriginalCarbs,
    double? aiOriginalFats,
    double? aiOriginalConfidence,
    bool? wasEditedByUser,
    int? deletedAtMs,
  }) {
    return IngredientEntity(
      id: id ?? this.id,
      mealId: mealId ?? this.mealId,
      name: name ?? this.name,
      weight: weight ?? this.weight,
      amount: amount ?? this.amount,
      calories: calories ?? this.calories,
      proteins: proteins ?? this.proteins,
      carbs: carbs ?? this.carbs,
      fats: fats ?? this.fats,
      confidence: confidence ?? this.confidence,
      isFavorite: isFavorite ?? this.isFavorite,
      dietaryViolation: dietaryViolation ?? this.dietaryViolation,
      aiOriginalName: aiOriginalName ?? this.aiOriginalName,
      aiOriginalWeight: aiOriginalWeight ?? this.aiOriginalWeight,
      aiOriginalAmount: aiOriginalAmount ?? this.aiOriginalAmount,
      aiOriginalCalories: aiOriginalCalories ?? this.aiOriginalCalories,
      aiOriginalProteins: aiOriginalProteins ?? this.aiOriginalProteins,
      aiOriginalCarbs: aiOriginalCarbs ?? this.aiOriginalCarbs,
      aiOriginalFats: aiOriginalFats ?? this.aiOriginalFats,
      aiOriginalConfidence: aiOriginalConfidence ?? this.aiOriginalConfidence,
      wasEditedByUser: wasEditedByUser ?? this.wasEditedByUser,
      deletedAtMs: deletedAtMs ?? this.deletedAtMs,
    );
  }
}
