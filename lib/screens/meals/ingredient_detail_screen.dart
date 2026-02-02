import 'package:diplomka/model/ingredient.dart';
import 'package:diplomka/screens/ingredients/edit_ingredient_screen.dart';
import 'package:flutter/material.dart';

class IngredientDetailScreen extends StatelessWidget {
  final Ingredient? ingredient;

  const IngredientDetailScreen({super.key, this.ingredient});

  @override
  Widget build(BuildContext context) {
    return EditIngredientScreen(
      ingredient: ingredient ?? _stubIngredient,
    );
  }
}

final Ingredient _stubIngredient = Ingredient(
  name: 'Apple',
  weight: 125,
  calories: 125,
  proteins: 1,
  carbs: 25,
  fats: 0,
);
