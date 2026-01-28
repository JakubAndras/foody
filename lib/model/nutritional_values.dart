part of 'ai_response.dart';

@JsonSerializable()
class NutritionalValues {
  final int calories;
  final double proteins;
  final double fats;
  final double carbs;

  NutritionalValues({
    required this.calories,
    required this.proteins,
    required this.fats,
    required this.carbs,
  });

  factory NutritionalValues.fromJson(Map<String, dynamic> json) => _$NutritionalValuesFromJson(json);
  Map<String, dynamic> toJson() => _$NutritionalValuesToJson(this);
}
