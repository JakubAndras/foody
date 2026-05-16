part of 'ai_response.dart';

@JsonSerializable()
class IngredientResponse {
  final String name;
  final double confidence;
  final String quantity;
  @JsonKey(name: 'weight_grams')
  final double? weightGrams;
  @JsonKey(name: 'nutritional_values')
  final NutritionalValues nutritionalValues;
  // Free-text reason from AI in user locale if ingredient violates user's diet, else null.
  @JsonKey(name: 'dietary_violation')
  final String? dietaryViolation;

  IngredientResponse({
    required this.name,
    required this.confidence,
    required this.quantity,
    this.weightGrams,
    required this.nutritionalValues,
    this.dietaryViolation,
  });

  factory IngredientResponse.fromJson(Map<String, dynamic> json) => _$IngredientResponseFromJson(json);
  Map<String, dynamic> toJson() => _$IngredientResponseToJson(this);
}
