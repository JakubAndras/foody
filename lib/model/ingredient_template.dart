import 'package:diplomka/model/ingredient.dart';

class IngredientTemplate {
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

  const IngredientTemplate({
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

  Ingredient toIngredient() {
    return Ingredient(
      name: name,
      weight: weight,
      amount: amount,
      calories: calories,
      proteins: proteins,
      carbs: carbs,
      fats: fats,
      isFavorite: isFavorite,
    );
  }

  static String normalize(String name) => name.trim().toLowerCase();
}
