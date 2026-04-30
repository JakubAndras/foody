import 'package:diplomka/database/entities/meal_entity.dart';
import 'package:floor/floor.dart';

@dao
abstract class MealDao {
  @Query('''SELECT * FROM Meal WHERE dayRecordId = :dayRecordId AND deletedAtMs IS NULL''')
  Future<List<MealEntity>> findMealsForDayRecord(int dayRecordId);

  // RESEARCH-ONLY: research-only — returns soft-deleted meals as well so
  // long-term test exports preserve the full AI signal even for records the
  // user removed. See RESEARCH_ONLY.md.
  @Query('''SELECT * FROM Meal WHERE dayRecordId = :dayRecordId''')
  Future<List<MealEntity>> findAllMealsForDayRecordIncludingDeleted(int dayRecordId);

  @Query('''SELECT * FROM Meal WHERE id = :id''')
  Future<MealEntity?> findMealById(int id);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<int> insertMeal(MealEntity meal);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<List<int>> insertMeals(List<MealEntity> meals);

  @update
  Future<void> updateMeal(MealEntity meal);

  @delete
  Future<void> deleteMeal(MealEntity meal);

  @Query('''DELETE FROM Meal WHERE id = :id''')
  Future<void> deleteMealById(int id);

  @Query('''DELETE FROM Meal WHERE dayRecordId = :dayRecordId''')
  Future<void> deleteMealsForDayRecord(int dayRecordId);

  // RESEARCH-ONLY: research-only soft-delete. Replaces hard `deleteMealById`
  // in the user-facing flow so the AI snapshot survives in the export. Drop
  // this query along with the `deletedAtMs` column. See RESEARCH_ONLY.md.
  @Query('''UPDATE Meal SET deletedAtMs = :deletedAtMs WHERE id = :id''')
  Future<void> softDeleteMealById(int id, int deletedAtMs);
}
