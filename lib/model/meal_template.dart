import 'package:diplomka/model/ingredient.dart';
import 'package:diplomka/model/meal.dart';

class MealTemplate {
  final int? id;
  final String name;
  final String normalizedName;
  final String? photoPath;
  final bool isFavorite;
  final DateTime lastUsedAt;
  final int usageCount;
  final List<Ingredient> ingredients;

  const MealTemplate({
    this.id,
    required this.name,
    required this.normalizedName,
    this.photoPath,
    this.isFavorite = false,
    required this.lastUsedAt,
    this.usageCount = 1,
    this.ingredients = const [],
  });

  double get totalCalories => ingredients.fold(0, (sum, item) => sum + item.calories);
  double get totalProteins => ingredients.fold(0, (sum, item) => sum + item.proteins);
  double get totalCarbs => ingredients.fold(0, (sum, item) => sum + item.carbs);
  double get totalFats => ingredients.fold(0, (sum, item) => sum + item.fats);

  Meal toMeal({required DateTime timestamp}) {
    return Meal(
      name: name,
      ingredients: ingredients,
      timestamp: timestamp,
      photoPath: photoPath,
      isFavorite: isFavorite,
    );
  }

  static String normalize(String name) => name.trim().toLowerCase();
}
