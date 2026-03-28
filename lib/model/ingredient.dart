class Ingredient {
  final int? id;
  final int? mealId;
  final String name;
  final double weight;
  final double amount;
  final double calories;
  final double proteins;
  final double carbs;
  final double fats;
  final double? confidence;

  Ingredient({
    this.id,
    this.mealId,
    required this.name,
    required this.weight,
    this.amount = 1.0,
    required this.calories,
    required this.proteins,
    required this.carbs,
    required this.fats,
    this.confidence,
  });

  // Factory constructor for creating a new Ingredient instance from a map.
  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      id: json['id'] as int?,
      mealId: json['mealId'] as int?,
      name: json['name'] as String,
      weight: (json['weight'] as num).toDouble(),
      amount: (json['amount'] as num?)?.toDouble() ?? 1.0,
      calories: (json['calories'] as num).toDouble(),
      proteins: (json['proteins'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fats: (json['fats'] as num).toDouble(),
      confidence: (json['confidence'] as num?)?.toDouble(),
    );
  }

  // Method for converting an Ingredient instance to a map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mealId': mealId,
      'name': name,
      'weight': weight,
      'amount': amount,
      'calories': calories,
      'proteins': proteins,
      'carbs': carbs,
      'fats': fats,
      'confidence': confidence,
    };
  }

  // Method to create a copy of this Ingredient instance with an optional new value for each field.
  Ingredient copyWith({
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
  }) {
    return Ingredient(
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
    );
  }

  static const List<String> _fractionLabels = ['\u2013', '\u215B', '\u00BC', '\u2153', '\u215C', '\u00BD', '\u2154', '\u215D', '\u00BE', '\u215E'];
  static const List<double> _fractionValues = [0, 0.125, 0.25, 1 / 3, 0.375, 0.5, 2 / 3, 0.625, 0.75, 0.875];

  String get amountLabel {
    final whole = amount.truncate();
    final frac = amount - whole;
    if (frac < 0.001) return '$whole';
    int bestIndex = 0;
    double bestDiff = double.infinity;
    for (int i = 1; i < _fractionLabels.length; i++) {
      final diff = (frac - _fractionValues[i]).abs();
      if (diff < bestDiff) {
        bestDiff = diff;
        bestIndex = i;
      }
    }
    if (whole == 0) return _fractionLabels[bestIndex];
    return '$whole${_fractionLabels[bestIndex]}';
  }
}
