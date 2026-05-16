// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AiResponse _$AiResponseFromJson(Map<String, dynamic> json) => AiResponse(
      valid: json['valid'] as bool,
      answer: Answer.fromJson(json['answer'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AiResponseToJson(AiResponse instance) =>
    <String, dynamic>{
      'valid': instance.valid,
      'answer': instance.answer,
    };

Answer _$AnswerFromJson(Map<String, dynamic> json) => Answer(
      name: json['name'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      amount: (json['amount'] as num?)?.toDouble() ?? 1.0,
      nutritionalValues: NutritionalValues.fromJson(
          json['nutritional_values'] as Map<String, dynamic>),
      ingredients: (json['ingredients'] as List<dynamic>)
          .map((e) => IngredientResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AnswerToJson(Answer instance) => <String, dynamic>{
      'name': instance.name,
      'confidence': instance.confidence,
      'amount': instance.amount,
      'nutritional_values': instance.nutritionalValues,
      'ingredients': instance.ingredients,
    };

IngredientResponse _$IngredientResponseFromJson(Map<String, dynamic> json) =>
    IngredientResponse(
      name: json['name'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      quantity: json['quantity'] as String,
      weightGrams: (json['weight_grams'] as num?)?.toDouble(),
      nutritionalValues: NutritionalValues.fromJson(
          json['nutritional_values'] as Map<String, dynamic>),
      dietaryViolation: json['dietary_violation'] as String?,
    );

Map<String, dynamic> _$IngredientResponseToJson(IngredientResponse instance) =>
    <String, dynamic>{
      'name': instance.name,
      'confidence': instance.confidence,
      'quantity': instance.quantity,
      'weight_grams': instance.weightGrams,
      'nutritional_values': instance.nutritionalValues,
      'dietary_violation': instance.dietaryViolation,
    };

NutritionalValues _$NutritionalValuesFromJson(Map<String, dynamic> json) =>
    NutritionalValues(
      calories: (json['calories'] as num).toInt(),
      proteins: (json['proteins'] as num).toDouble(),
      fats: (json['fats'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
    );

Map<String, dynamic> _$NutritionalValuesToJson(NutritionalValues instance) =>
    <String, dynamic>{
      'calories': instance.calories,
      'proteins': instance.proteins,
      'fats': instance.fats,
      'carbs': instance.carbs,
    };
