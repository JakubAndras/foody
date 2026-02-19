import 'package:diplomka/model/ingredient.dart';
import 'package:diplomka/model/meal.dart';
import 'package:diplomka/screens/meals/edit_meal_screen.dart';
import 'package:diplomka/screens/meals/meal_components.dart';
import 'package:flutter/material.dart';

class MealDetailScreen extends StatelessWidget {
  final Meal? meal;
  final bool showAllergyAlert;
  final bool showCaloriesDelta;
  final MatchBadgeVariant matchBadgeVariant;
  final bool openedFromLogScreen;
  final DateTime? selectedDate;

  const MealDetailScreen({
    super.key,
    this.meal,
    this.showAllergyAlert = false,
    this.showCaloriesDelta = false,
    this.matchBadgeVariant = MatchBadgeVariant.good,
    this.openedFromLogScreen = false,
    this.selectedDate,
  });

  @override
  Widget build(BuildContext context) {
    return EditMealScreen(
      meal: meal ?? _stubMeal,
      initialMode: MealScreenMode.view,
      openedFromLogScreen: openedFromLogScreen,
      selectedDate: selectedDate,
      showAllergyAlert: showAllergyAlert,
      showCaloriesDelta: showCaloriesDelta,
      matchBadgeVariant: matchBadgeVariant,
    );
  }
}

Meal get _stubMeal {
  return Meal(
    name: 'Salmon & Vegetables',
    timestamp: DateTime(2026, 1, 11, 13, 15),
    ingredients: [
      Ingredient(name: 'Salmon Fillet', weight: 34, calories: 565, proteins: 34, carbs: 0, fats: 15),
      Ingredient(name: 'Quinoa', weight: 34, calories: 120, proteins: 34, carbs: 0, fats: 15),
      Ingredient(name: 'Broccoli', weight: 34, calories: 55, proteins: 34, carbs: 0, fats: 15),
      Ingredient(name: 'Bell Peppers', weight: 34, calories: 45, proteins: 34, carbs: 0, fats: 15),
      Ingredient(name: 'Olive Oil', weight: 34, calories: 65, proteins: 34, carbs: 0, fats: 15),
    ],
  );
}
