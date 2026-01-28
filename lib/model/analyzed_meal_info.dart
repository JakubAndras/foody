import 'dart:convert';

class AnalyzedMealInfo {
  final String dishName;
  final List<AnalyzedIngredientInfo> ingredients;
  final String source;
  final DateTime timestamp;

  AnalyzedMealInfo({
    required this.dishName,
    required this.ingredients,
    required this.source,
    required this.timestamp,
  });

  factory AnalyzedMealInfo.fromJson(Map<String, dynamic> json) {
    var ingredientsList = json['ingredients'] as List;
    List<AnalyzedIngredientInfo> ingredients = ingredientsList
        .map((i) => AnalyzedIngredientInfo.fromJson(i))
        .toList();

    return AnalyzedMealInfo(
      dishName: json['dishName'],
      ingredients: ingredients,
      source: json['source'] ?? 'AI Analysis',
      timestamp: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'AnalyzedMealInfo(dishName: $dishName, ingredients: $ingredients, source: $source, timestamp: $timestamp)';
  }
}

class AnalyzedIngredientInfo {
  final String name;
  final double weight;
  final double calories;
  final double protein;
  final double carbohydrates;
  final double fat;

  AnalyzedIngredientInfo({
    required this.name,
    required this.weight,
    required this.calories,
    required this.protein,
    required this.carbohydrates,
    required this.fat,
  });

  factory AnalyzedIngredientInfo.fromJson(Map<String, dynamic> json) {
    return AnalyzedIngredientInfo(
      name: json['name'],
      weight: (json['weight'] as num).toDouble(),
      calories: (json['calories'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      carbohydrates: (json['carbohydrates'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
    );
  }

  @override
  String toString() {
    return 'AnalyzedIngredientInfo(name: $name, weight: $weight, calories: $calories, protein: $protein, carbohydrates: $carbohydrates, fat: $fat)';
  }
}