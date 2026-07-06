import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:diplomka/model/recipe.dart';

class RecipeService {
  // Mock database for recipes, imageUrls are placeholders
  final List<Recipe> _recipes = [
    const Recipe(
      id: '1',
      name: 'Pomazánka z tvarohu a tvarůžků',
      imageUrl: 'placeholder_1', // Placeholder identifier for future image loading
      calories: 106,
      protein: 14,
      carbs: 3,
      fat: 4,
      fiber: 0,
    ),
    const Recipe(
      id: '2',
      name: 'Tvarohová buchta ze špaldové mouky s borůvkami',
      imageUrl: 'placeholder_2',
      calories: 226,
      protein: 9,
      carbs: 25,
      fat: 9,
      fiber: 4,
    ),
    const Recipe(
      id: '3',
      name: 'Tuňáková pomazánka s vejci',
      imageUrl: 'placeholder_3',
      calories: 220,
      protein: 15,
      carbs: 2,
      fat: 17,
      fiber: 0,
    ),
    const Recipe(
      id: '4',
      name: 'Palačinky ze špaldové mouky',
      imageUrl: 'placeholder_4',
      calories: 161,
      protein: 8,
      carbs: 21,
      fat: 5,
      fiber: 1,
    ),
    const Recipe(
      id: '5',
      name: 'Strouhaný koláč s borůvkami',
      imageUrl: 'placeholder_5',
      calories: 294,
      protein: 6,
      carbs: 41,
      fat: 11,
      fiber: 2,
    ),
    const Recipe(
      id: '6',
      name: 'Cukeťák - slaný koláč z cukety',
      imageUrl: 'placeholder_6',
      calories: 131,
      protein: 10,
      carbs: 12,
      fat: 5,
      fiber: 3,
    ),
    const Recipe(
      id: '7',
      name: 'Kuřecí salát s jogurtovým dresinkem',
      imageUrl: 'placeholder_7',
      calories: 180,
      protein: 25,
      carbs: 5,
      fat: 7,
      fiber: 2,
    ),
    const Recipe(
      id: '8',
      name: 'Ovesná kaše s ovocem a ořechy',
      imageUrl: 'placeholder_8',
      calories: 350,
      protein: 12,
      carbs: 50,
      fat: 10,
      fiber: 8,
    ),
  ];

  Future<List<Recipe>> getRecipes() async {
    // In a real application, this would fetch database from an API or local database.
    // For now, we simulate a network delay.
    //await Future.delayed(const Duration(milliseconds: 500));
    return _recipes;
  }

// You can add other methods here later, e.g., for filtering, searching, etc.
}

final recipeServiceProvider = Provider<RecipeService>((ref) => RecipeService());
