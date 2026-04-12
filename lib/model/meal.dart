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
  final double? confidence;
  final String? barcode;

  Meal({
    this.id,
    this.dayRecordId,
    required this.name,
    required this.ingredients,
    required this.timestamp,
    this.photoPath,
    this.isFavorite = false,
    this.confidence,
    this.barcode,
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
      confidence: (json['confidence'] as num?)?.toDouble(),
      barcode: json['barcode'] as String?,
    );
  }

  // Factory constructor for creating a new Meal instance from an Answer object.
  factory Meal.fromAnswer(Answer answer) {
    final snappedAmount = _snapToFraction(answer.amount.clamp(0.0, 100.875));

    List<Ingredient> ingredients = answer.ingredients.map((ingResponse) {
      double weight = ingResponse.weightGrams ?? 0.0;
      // Fallback: parse weight from quantity string if AI didn't provide weight_grams
      if (weight <= 0) {
        final RegExp numRegExp = RegExp(r'\d+(\.\d+)?');
        final Match? match = numRegExp.firstMatch(ingResponse.quantity);
        if (match != null) {
          weight = double.tryParse(match.group(0)!) ?? 0.0;
        }
      }

      return Ingredient(
        name: ingResponse.name,
        weight: weight,
        amount: snappedAmount,
        calories: ingResponse.nutritionalValues.calories.toDouble(),
        proteins: ingResponse.nutritionalValues.proteins,
        carbs: ingResponse.nutritionalValues.carbs,
        fats: ingResponse.nutritionalValues.fats,
        confidence: ingResponse.confidence,
      );
    }).toList();

    return Meal(
      name: answer.name,
      ingredients: ingredients,
      timestamp: DateTime.now(),
      confidence: answer.confidence,
    );
  }

  /// Snaps a double to the nearest supported whole + fraction value.
  /// Supported fractions: 0, ⅛(0.125), ¼(0.25), ⅓(0.333), ⅜(0.375), ½(0.5), ⅔(0.667), ⅝(0.625), ¾(0.75), ⅞(0.875).
  static double _snapToFraction(double value) {
    if (value <= 0) return 0.125; // minimum allowed amount
    const fractions = [0.0, 0.125, 0.25, 1 / 3, 0.375, 0.5, 2 / 3, 0.625, 0.75, 0.875];
    final whole = value.truncate();
    final frac = value - whole;
    double bestFrac = 0;
    double bestDiff = double.infinity;
    for (final f in fractions) {
      final diff = (frac - f).abs();
      if (diff < bestDiff) {
        bestDiff = diff;
        bestFrac = f;
      }
    }
    final result = whole + bestFrac;
    return result <= 0 ? 0.125 : result;
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
      'confidence': confidence,
      'barcode': barcode,
    };
  }

  Meal copyWith({
    int? id,
    int? dayRecordId,
    String? name,
    List<Ingredient>? ingredients,
    DateTime? timestamp,
    String? photoPath,
    bool clearPhotoPath = false,
    bool? isFavorite,
    double? confidence,
    String? barcode,
  }) {
    return Meal(
      id: id ?? this.id,
      dayRecordId: dayRecordId ?? this.dayRecordId,
      name: name ?? this.name,
      ingredients: ingredients ?? this.ingredients,
      timestamp: timestamp ?? this.timestamp,
      photoPath: clearPhotoPath ? null : (photoPath ?? this.photoPath),
      isFavorite: isFavorite ?? this.isFavorite,
      confidence: confidence ?? this.confidence,
      barcode: barcode ?? this.barcode,
    );
  }

  double get totalCalories =>
      ingredients.fold(0, (sum, item) => sum + item.calories);
  double get totalProteins =>
      ingredients.fold(0, (sum, item) => sum + item.proteins);
  double get totalCarbs =>
      ingredients.fold(0, (sum, item) => sum + item.carbs);
  double get totalFats => ingredients.fold(0, (sum, item) => sum + item.fats);
  double get totalWeight => ingredients.fold(0, (sum, item) => sum + item.weight);
}
