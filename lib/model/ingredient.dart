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
  final bool isFavorite;

  // RESEARCH-ONLY: all fields below are research-only. Mirror
  // IngredientEntity telemetry. See RESEARCH_ONLY.md.
  final String? aiOriginalName;
  final double? aiOriginalWeight;
  final double? aiOriginalAmount;
  final double? aiOriginalCalories;
  final double? aiOriginalProteins;
  final double? aiOriginalCarbs;
  final double? aiOriginalFats;
  final double? aiOriginalConfidence;
  final bool wasEditedByUser;
  final DateTime? deletedAt;
  // RESEARCH-ONLY: end

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
    this.isFavorite = false,
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
    this.deletedAt,
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
      isFavorite: json['isFavorite'] == true || json['isFavorite'] == 1,
      // RESEARCH-ONLY: research-only fromJson fields below
      aiOriginalName: json['aiOriginalName'] as String?,
      aiOriginalWeight: (json['aiOriginalWeight'] as num?)?.toDouble(),
      aiOriginalAmount: (json['aiOriginalAmount'] as num?)?.toDouble(),
      aiOriginalCalories: (json['aiOriginalCalories'] as num?)?.toDouble(),
      aiOriginalProteins: (json['aiOriginalProteins'] as num?)?.toDouble(),
      aiOriginalCarbs: (json['aiOriginalCarbs'] as num?)?.toDouble(),
      aiOriginalFats: (json['aiOriginalFats'] as num?)?.toDouble(),
      aiOriginalConfidence: (json['aiOriginalConfidence'] as num?)?.toDouble(),
      wasEditedByUser: json['wasEditedByUser'] == true || json['wasEditedByUser'] == 1,
      deletedAt: json['deletedAt'] != null ? DateTime.tryParse(json['deletedAt'] as String) : null,
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
      'isFavorite': isFavorite,
      // RESEARCH-ONLY: research-only toJson fields below
      'aiOriginalName': aiOriginalName,
      'aiOriginalWeight': aiOriginalWeight,
      'aiOriginalAmount': aiOriginalAmount,
      'aiOriginalCalories': aiOriginalCalories,
      'aiOriginalProteins': aiOriginalProteins,
      'aiOriginalCarbs': aiOriginalCarbs,
      'aiOriginalFats': aiOriginalFats,
      'aiOriginalConfidence': aiOriginalConfidence,
      'wasEditedByUser': wasEditedByUser,
      'deletedAt': deletedAt?.toIso8601String(),
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
    bool? isFavorite,
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
    DateTime? deletedAt,
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
      isFavorite: isFavorite ?? this.isFavorite,
      aiOriginalName: aiOriginalName ?? this.aiOriginalName,
      aiOriginalWeight: aiOriginalWeight ?? this.aiOriginalWeight,
      aiOriginalAmount: aiOriginalAmount ?? this.aiOriginalAmount,
      aiOriginalCalories: aiOriginalCalories ?? this.aiOriginalCalories,
      aiOriginalProteins: aiOriginalProteins ?? this.aiOriginalProteins,
      aiOriginalCarbs: aiOriginalCarbs ?? this.aiOriginalCarbs,
      aiOriginalFats: aiOriginalFats ?? this.aiOriginalFats,
      aiOriginalConfidence: aiOriginalConfidence ?? this.aiOriginalConfidence,
      wasEditedByUser: wasEditedByUser ?? this.wasEditedByUser,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  static const List<String> _fractionLabels = ['–', '½', '⅓', '¼', '⅛', '⅔', '¾', '⅜', '⅝', '⅞'];
  static const List<double> _fractionValues = [0, 0.5, 1 / 3, 0.25, 0.125, 2 / 3, 0.75, 0.375, 0.625, 0.875];

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
