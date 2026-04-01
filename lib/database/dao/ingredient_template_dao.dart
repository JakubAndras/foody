import 'package:diplomka/database/entities/ingredient_template_entity.dart';
import 'package:floor/floor.dart';

@dao
abstract class IngredientTemplateDao {
  @Query('SELECT * FROM IngredientTemplate ORDER BY lastUsedAt DESC')
  Future<List<IngredientTemplateEntity>> getAllTemplates();

  @Query('SELECT * FROM IngredientTemplate WHERE normalizedName = :normalizedName LIMIT 1')
  Future<IngredientTemplateEntity?> findByNormalizedName(String normalizedName);

  @Query('SELECT * FROM IngredientTemplate WHERE isFavorite = 1 ORDER BY lastUsedAt DESC')
  Future<List<IngredientTemplateEntity>> getFavoriteTemplates();

  @Insert(onConflict: OnConflictStrategy.ignore)
  Future<int> insertTemplate(IngredientTemplateEntity template);

  @update
  Future<void> updateTemplate(IngredientTemplateEntity template);

  @Query('DELETE FROM IngredientTemplate WHERE id = :id')
  Future<void> deleteTemplateById(int id);
}
