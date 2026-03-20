import 'package:diplomka/database/entities/meal_template_ingredient_entity.dart';
import 'package:floor/floor.dart';

@dao
abstract class MealTemplateIngredientDao {
  @Query('SELECT * FROM MealTemplateIngredient WHERE templateId = :templateId')
  Future<List<MealTemplateIngredientEntity>> findForTemplate(int templateId);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<List<int>> insertIngredients(List<MealTemplateIngredientEntity> ingredients);

  @Query('DELETE FROM MealTemplateIngredient WHERE templateId = :templateId')
  Future<void> deleteForTemplate(int templateId);
}
