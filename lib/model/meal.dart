import 'package:diplomka/model/ai_response.dart';
import 'package:diplomka/model/ingredient.dart';

class Meal {
  final int? id;
  final int? dayRecordId;
  final String name;
  final List<Ingredient> ingredients;
  final DateTime timestamp;
  final String? photoPath;
  final bool isFavorite;

  Meal({
    this.id,
    this.dayRecordId,
    required this.name,
    required this.ingredients,
    required this.timestamp,
    this.photoPath,
    this.isFavorite = false,
  });

  // Factory constructor for creating a new Meal instance from a map.
  factory Meal.fromJson(Map<String, dynamic> json) {
    var ingredientsList = json['ingredients'] as List;
    List<Ingredient> ingredients = ingredientsList.map((i) => Ingredient.fromJson(i as Map<String, dynamic>)).toList();
    return Meal(
      id: json['id'] as int?,
      dayRecordId: json['dayRecordId'] as int?,
      name: json['name'] as String,
      ingredients: ingredients,
      timestamp: DateTime.parse(json['timestamp'] as String),
      photoPath: json['photoPath'] as String?,
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }

  // Factory constructor for creating a new Meal instance from an Answer object.
  factory Meal.fromAnswer(Answer answer) {
    List<Ingredient> ingredients = answer.ingredients.map((ingResponse) {
      double weight = 0.0;
      // Attempt to parse weight from quantity string
      final RegExp numRegExp = RegExp(r'\d+(\.\d+)?');
      final Match? match = numRegExp.firstMatch(ingResponse.quantity);
      if (match != null) {
        weight = double.tryParse(match.group(0)!) ?? 0.0;
      }

      return Ingredient(
        name: ingResponse.name,
        weight: weight,
        calories: ingResponse.nutritionalValues.calories.toDouble(),
        proteins: ingResponse.nutritionalValues.proteins,
        carbs: ingResponse.nutritionalValues.carbs,
        fats: ingResponse.nutritionalValues.fats, // Corrected from 'fats' to 'fat' if Ingredient model uses 'fat'
      );
    }).toList();

    return Meal(
      name: answer.name,
      ingredients: ingredients,
      timestamp: DateTime.now(), // Defaulting to current time, adjust if needed
    );
  }

  // Method for converting a Meal instance to a map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dayRecordId': dayRecordId,
      'name': name,
      'ingredients': ingredients.map((i) => i.toJson()).toList(),
      'timestamp': timestamp.toIso8601String(),
      'photoPath': photoPath,
      'isFavorite': isFavorite,
    };
  }

  Meal copyWith({
    int? id,
    int? dayRecordId,
    String? name,
    List<Ingredient>? ingredients,
    DateTime? timestamp,
    String? photoPath,
    bool? isFavorite,
  }) {
    return Meal(
      id: id ?? this.id,
      dayRecordId: dayRecordId ?? this.dayRecordId,
      name: name ?? this.name,
      ingredients: ingredients ?? this.ingredients,
      timestamp: timestamp ?? this.timestamp,
      photoPath: photoPath ?? this.photoPath,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  double get totalCalories =>
      ingredients.fold(0, (sum, item) => sum + item.calories);
  double get totalProteins =>
      ingredients.fold(0, (sum, item) => sum + item.proteins);
  double get totalCarbs =>
      ingredients.fold(0, (sum, item) => sum + item.carbs);
  double get totalFats => ingredients.fold(0, (sum, item) => sum + item.fats);
}
