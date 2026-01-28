import 'package:diplomka/model/ingredient.dart';
import 'package:floor/floor.dart';

@dao
abstract class IngredientDao {
  @Query('''SELECT * FROM Ingredient WHERE mealId = :mealId''')
  Future<List<Ingredient>> findIngredientsForMeal(int mealId);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<int> insertIngredient(Ingredient ingredient);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<List<int>> insertIngredients(List<Ingredient> ingredients);

  @update
  Future<void> updateIngredient(Ingredient ingredient);

  @delete
  Future<void> deleteIngredient(Ingredient ingredient);
}
