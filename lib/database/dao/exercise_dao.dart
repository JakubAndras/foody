import 'package:diplomka/database/entities/exercise_entity.dart';
import 'package:floor/floor.dart';

@dao
abstract class ExerciseDao {
  @Query('''SELECT * FROM Exercise WHERE dayRecordId = :dayRecordId ORDER BY timestamp DESC''')
  Future<List<ExerciseEntity>> findExercisesForDayRecord(int dayRecordId);

  @Query('''SELECT * FROM Exercise WHERE dayRecordId = :dayRecordId AND source = :source LIMIT 1''')
  Future<ExerciseEntity?> findExerciseByDayRecordAndSource(int dayRecordId, String source);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<int> insertExercise(ExerciseEntity exercise);

  @update
  Future<void> updateExercise(ExerciseEntity exercise);

  @delete
  Future<void> deleteExercise(ExerciseEntity exercise);

  @Query('''DELETE FROM Exercise WHERE id = :id''')
  Future<void> deleteExerciseById(int id);
}
