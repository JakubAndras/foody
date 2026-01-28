import 'package:diplomka/model/meal.dart';
import 'package:floor/floor.dart';

@dao
abstract class MealDao {
  @Query('''SELECT * FROM Meal WHERE dayRecordId = :dayRecordId''')
  Future<List<Meal>> findMealsForDayRecord(int dayRecordId);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<int> insertMeal(Meal meal);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<List<int>> insertMeals(List<Meal> meals);

  @update
  Future<void> updateMeal(Meal meal);

  @delete
  Future<void> deleteMeal(Meal meal);
}
