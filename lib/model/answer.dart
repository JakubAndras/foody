part of 'ai_response.dart';

@JsonSerializable()
class Answer {
  final String name;
  final double confidence;
  @JsonKey(name: 'nutritional_values')
  final NutritionalValues nutritionalValues;
  final List<IngredientResponse> ingredients;

  Answer({
    required this.name,
    required this.confidence,
    required this.nutritionalValues,
    required this.ingredients,
  });

  factory Answer.fromJson(Map<String, dynamic> json) => _$AnswerFromJson(json);
  Map<String, dynamic> toJson() => _$AnswerToJson(this);
}
