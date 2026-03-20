import 'package:diplomka/database/entities/meal_template_entity.dart';
import 'package:floor/floor.dart';

@dao
abstract class MealTemplateDao {
  @Query('SELECT * FROM MealTemplate ORDER BY lastUsedAt DESC')
  Future<List<MealTemplateEntity>> getAllTemplates();

  @Query('SELECT * FROM MealTemplate WHERE normalizedName = :normalizedName LIMIT 1')
  Future<MealTemplateEntity?> findByNormalizedName(String normalizedName);

  @Query('SELECT * FROM MealTemplate WHERE isFavorite = 1 ORDER BY lastUsedAt DESC')
  Future<List<MealTemplateEntity>> getFavoriteTemplates();

  @Insert(onConflict: OnConflictStrategy.ignore)
  Future<int> insertTemplate(MealTemplateEntity template);

  @update
  Future<void> updateTemplate(MealTemplateEntity template);

  @Query('DELETE FROM MealTemplate WHERE id = :id')
  Future<void> deleteTemplateById(int id);
}
