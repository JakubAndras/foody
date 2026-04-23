class AppLimits {
  AppLimits._();

  // Exercise
  static const int exerciseMaxCalories = 10000;
  static const int exerciseMaxDurationMinutes = 1440;

  // Ingredient
  static const int ingredientMaxCalories = 9999;
  static const int ingredientMaxMacro = 999;
  static const int ingredientMaxWeightGrams = 2000;
  static const int ingredientMaxAmount = 99999;

  // Meal
  static const int mealMaxCalories = 50000;

  // Nutrition Goals
  static const int goalMaxCalories = 9999;
  static const int goalMaxMacro = 999;

  // Weight
  static const double weightMinKg = 20;
  static const double weightMaxKg = 500;

  // AI input limits
  static const int aiQueryMaxLength = 500;
  static const int aiDescriptionMaxLength = 200;
  static const int aiDietPreferencesMaxLength = 300;
}
