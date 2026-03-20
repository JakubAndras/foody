import 'package:diplomka/database/entities/exercise_template_entity.dart';
import 'package:floor/floor.dart';

@dao
abstract class ExerciseTemplateDao {
  @Query('SELECT * FROM ExerciseTemplate ORDER BY lastUsedAt DESC')
  Future<List<ExerciseTemplateEntity>> getAllTemplates();

  @Query('SELECT * FROM ExerciseTemplate WHERE normalizedName = :normalizedName LIMIT 1')
  Future<ExerciseTemplateEntity?> findByNormalizedName(String normalizedName);

  @Query('SELECT * FROM ExerciseTemplate WHERE isFavorite = 1 ORDER BY lastUsedAt DESC')
  Future<List<ExerciseTemplateEntity>> getFavoriteTemplates();

  @Insert(onConflict: OnConflictStrategy.ignore)
  Future<int> insertTemplate(ExerciseTemplateEntity template);

  @update
  Future<void> updateTemplate(ExerciseTemplateEntity template);

  @Query('DELETE FROM ExerciseTemplate WHERE id = :id')
  Future<void> deleteTemplateById(int id);
}
