part of 'ai_response.dart';

@JsonSerializable()
class Answer {
  final String name;
  final double confidence;
  final double amount;
  @JsonKey(name: 'nutritional_values')
  final NutritionalValues nutritionalValues;
  final List<IngredientResponse> ingredients;

  Answer({
    required this.name,
    required this.confidence,
    this.amount = 1.0,
    required this.nutritionalValues,
    required this.ingredients,
  });

  factory Answer.fromJson(Map<String, dynamic> json) => _$AnswerFromJson(json);
  Map<String, dynamic> toJson() => _$AnswerToJson(this);
}
