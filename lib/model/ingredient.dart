import 'package:floor/floor.dart';

@entity
class Ingredient {
  @PrimaryKey(autoGenerate: true)
  final int? id;
  final String name;
  final double weight;
  final double calories;
  final double proteins;
  final double carbs;
  final double fats;

  Ingredient({
    this.id,
    required this.name,
    required this.weight,
    required this.calories,
    required this.proteins,
    required this.carbs,
    required this.fats,
  });

  // Factory constructor for creating a new Ingredient instance from a map.
  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      id: json['id'] as int?,
      name: json['name'] as String,
      weight: (json['weight'] as num).toDouble(),
      calories: (json['calories'] as num).toDouble(),
      proteins: (json['proteins'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fats: (json['fats'] as num).toDouble(),
    );
  }

  // Method for converting an Ingredient instance to a map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'weight': weight,
      'calories': calories,
      'proteins': proteins,
      'carbs': carbs,
      'fats': fats,
    };
  }

  // Method to create a copy of this Ingredient instance with an optional new value for each field.
  Ingredient copyWith({
    int? id,
    String? name,
    double? weight,
    double? calories,
    double? proteins,
    double? carbs,
    double? fats,
  }) {
    return Ingredient(
      id: id ?? this.id,
      name: name ?? this.name,
      weight: weight ?? this.weight,
      calories: calories ?? this.calories,
      proteins: proteins ?? this.proteins,
      carbs: carbs ?? this.carbs,
      fats: fats ?? this.fats,
    );
  }
}
