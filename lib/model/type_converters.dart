import 'dart:convert';
import 'package:floor/floor.dart';
import 'package:diplomka/model/meal.dart';

import 'ingredient.dart';

class DateTimeConverter extends TypeConverter<DateTime, int> {
  @override
  DateTime decode(int databaseValue) {
    return DateTime.fromMillisecondsSinceEpoch(databaseValue);
  }

  @override
  int encode(DateTime value) {
    return value.millisecondsSinceEpoch;
  }
}

class MealListConverter extends TypeConverter<List<Meal>, String> {
  @override
  List<Meal> decode(String databaseValue) {
    if (databaseValue.isEmpty) {
      return [];
    }
    final List<dynamic> listJson = json.decode(databaseValue);
    return listJson.map((jsonItem) => Meal.fromJson(jsonItem as Map<String, dynamic>)).toList();
  }

  @override
  String encode(List<Meal> value) {
    if (value.isEmpty) {
      return ''; // Store empty string for empty list
    }
    return json.encode(value.map((meal) => meal.toJson()).toList());
  }
}

class IngredientListConverter extends TypeConverter<List<Ingredient>, String> {
  @override
  List<Ingredient> decode(String databaseValue) {
    if (databaseValue.isEmpty) {
      return [];
    }
    final List<dynamic> listJson = json.decode(databaseValue);
    return listJson.map((jsonItem) => Ingredient.fromJson(jsonItem as Map<String, dynamic>)).toList();
  }

  @override
  String encode(List<Ingredient> value) {
    if (value.isEmpty) {
      return ''; // Store empty string for empty list
    }
    return json.encode(value.map((ingredient) => ingredient.toJson()).toList());
  }
}
