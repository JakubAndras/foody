import 'package:flutter/foundation.dart';

// Represents a recipe item.
@immutable
class Recipe {
  final String id;
  final String name;
  final String imageUrl; // Placeholder, could be a network URL or local asset path
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  // In a real app, this would include ingredients, instructions, etc.

  const Recipe({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
  });

  // Optional: For potential future use with JSON, etc.
  // factory Recipe.fromJson(Map<String, dynamic> json) => ...
  // Map<String, dynamic> toJson() => ...
}
