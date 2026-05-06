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

  // AI input limits — single uniform cap for any user-supplied text reaching the AI pipeline
  static const int aiInputMaxLength = 500;
}
