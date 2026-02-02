import 'package:diplomka/database/entities/ingredient_entity.dart';
import 'package:floor/floor.dart';

@dao
abstract class IngredientDao {
  @Query('''SELECT * FROM Ingredient WHERE mealId = :mealId''')
  Future<List<IngredientEntity>> findIngredientsForMeal(int mealId);

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
}
