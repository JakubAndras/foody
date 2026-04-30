import 'package:diplomka/database/entities/ingredient_entity.dart';
import 'package:floor/floor.dart';

@dao
abstract class IngredientDao {
  @Query('''SELECT * FROM Ingredient WHERE mealId = :mealId AND deletedAtMs IS NULL''')
  Future<List<IngredientEntity>> findIngredientsForMeal(int mealId);

  // RESEARCH-ONLY: research-only — returns soft-deleted ingredients as well
  // so long-term test exports keep the full AI signal even when the user
  // removed an ingredient mid-edit or scrapped the parent meal. See
  // RESEARCH_ONLY.md.
  @Query('''SELECT * FROM Ingredient WHERE mealId = :mealId''')
  Future<List<IngredientEntity>> findAllIngredientsForMealIncludingDeleted(int mealId);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<int> insertIngredient(IngredientEntity ingredient);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<List<int>> insertIngredients(List<IngredientEntity> ingredients);

  @update
  Future<void> updateIngredient(IngredientEntity ingredient);

  @delete
  Future<void> deleteIngredient(IngredientEntity ingredient);

  @Query('''DELETE FROM Ingredient WHERE mealId = :mealId''')
  Future<void> deleteIngredientsForMeal(int mealId);

  // RESEARCH-ONLY: research-only soft-delete. Used both when the user
  // deletes a meal (cascades to its ingredients) and on meal-edit save where
  // we'd otherwise lose track of which AI-suggested ingredients got removed.
  // Drop with the `deletedAtMs` column. See RESEARCH_ONLY.md.
  @Query('''UPDATE Ingredient SET deletedAtMs = :deletedAtMs WHERE mealId = :mealId AND deletedAtMs IS NULL''')
  Future<void> softDeleteIngredientsForMeal(int mealId, int deletedAtMs);
}
