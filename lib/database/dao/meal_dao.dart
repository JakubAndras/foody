import 'package:diplomka/database/entities/meal_entity.dart';
import 'package:floor/floor.dart';

@dao
abstract class MealDao {
  @Query('''SELECT * FROM Meal WHERE dayRecordId = :dayRecordId''')
  Future<List<MealEntity>> findMealsForDayRecord(int dayRecordId);

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
}
