import 'package:diplomka/database/app_database.dart';
import 'package:diplomka/database/dao/day_record_dao.dart';
import 'package:diplomka/database/dao/ingredient_dao.dart';
import 'package:diplomka/database/dao/meal_dao.dart';
import 'package:diplomka/database/entities/day_record_entity.dart';
import 'package:diplomka/database/entities/ingredient_entity.dart';
import 'package:diplomka/database/entities/meal_entity.dart';
import 'package:diplomka/model/day_record.dart';
import 'package:diplomka/model/ingredient.dart';
import 'package:diplomka/model/meal.dart';
import 'package:get/get.dart';

class DayRecordRepository extends GetxService {
  static DayRecordRepository get to => Get.find();

  DayRecordRepository({required AppDatabase database}) : _database = database;

  final AppDatabase _database;

  DayRecordDao get _dayRecordDao => _database.dayRecordDao;
  MealDao get _mealDao => _database.mealDao;
  IngredientDao get _ingredientDao => _database.ingredientDao;

  Stream<List<DayRecord>> watchDayRecords() {
    return _dayRecordDao.watchDayRecords().asyncMap((entities) async {
      final records = await Future.wait(entities.map(_buildDayRecordFromEntity));
      records.sort((a, b) => b.date.compareTo(a.date));
      return records;
    });
  }

  Future<DayRecord?> getDayRecord(DateTime date) async {
    final normalizedDate = _normalizeDate(date);
    final entity = await _dayRecordDao.findDayRecordByDate(normalizedDate.millisecondsSinceEpoch);
    if (entity == null) {
      return null;
    }
    return _buildDayRecordFromEntity(entity);
  }

  Future<List<DayRecord>> getAllDayRecords() async {
    final entities = await _dayRecordDao.getAllDayRecords();
    final records = await Future.wait(entities.map(_buildDayRecordFromEntity));
    records.sort((a, b) => b.date.compareTo(a.date));
    return records;
  }

  Future<DayRecord> upsertDayRecord(DayRecord record) async {
    final normalizedDate = _normalizeDate(record.date);
    final existing = await _dayRecordDao.findDayRecordByDate(normalizedDate.millisecondsSinceEpoch);
    DayRecordEntity entity;

    if (existing != null) {
      entity = existing.copyWith(
        calorieGoal: record.calorieGoal,
        proteinGoal: record.proteinGoal,
        carbsGoal: record.carbsGoal,
        fatGoal: record.fatGoal,
      );
      await _dayRecordDao.updateDayRecord(entity);
    } else {
      entity = DayRecordEntity(
        date: normalizedDate,
        calorieGoal: record.calorieGoal,
        proteinGoal: record.proteinGoal,
        carbsGoal: record.carbsGoal,
        fatGoal: record.fatGoal,
      );
      final id = await _dayRecordDao.insertDayRecord(entity);
      entity = entity.copyWith(id: id);
    }

    return _buildDayRecordFromEntity(entity);
  }

  Future<DayRecord> saveMealForDate({required DateTime date, required Meal meal}) async {
    final normalizedDate = _normalizeDate(date);
    final dayRecordId = await _ensureDayRecordId(normalizedDate);

    final mealEntity = MealEntity(
      id: meal.id,
      dayRecordId: dayRecordId,
      name: meal.name,
      timestamp: meal.timestamp,
      photoPath: meal.photoPath,
      isFavorite: meal.isFavorite,
    );

    int mealId;
    if (meal.id == null) {
      mealId = await _mealDao.insertMeal(mealEntity);
    } else {
      await _mealDao.updateMeal(mealEntity);
      mealId = meal.id!;
      await _ingredientDao.deleteIngredientsForMeal(mealId);
    }

    final ingredients = meal.ingredients
        .map((ingredient) => IngredientEntity(
              mealId: mealId,
              name: ingredient.name,
              weight: ingredient.weight,
              calories: ingredient.calories,
              proteins: ingredient.proteins,
              carbs: ingredient.carbs,
              fats: ingredient.fats,
            ))
        .toList();

    if (ingredients.isNotEmpty) {
      await _ingredientDao.insertIngredients(ingredients);
    }

    final entity = await _dayRecordDao.findDayRecordById(dayRecordId);
    return _buildDayRecordFromEntity(entity!);
  }

  Future<void> deleteMeal(Meal meal) async {
    if (meal.id == null) return;
    await _ingredientDao.deleteIngredientsForMeal(meal.id!);
    await _mealDao.deleteMealById(meal.id!);
  }

  Future<void> updateMealFavorite({required Meal meal, required bool isFavorite}) async {
    if (meal.id == null || meal.dayRecordId == null) return;
    final entity = MealEntity(
      id: meal.id,
      dayRecordId: meal.dayRecordId!,
      name: meal.name,
      timestamp: meal.timestamp,
      photoPath: meal.photoPath,
      isFavorite: isFavorite,
    );
    await _mealDao.updateMeal(entity);
  }

  Future<int> _ensureDayRecordId(DateTime normalizedDate) async {
    final existing = await _dayRecordDao.findDayRecordByDate(normalizedDate.millisecondsSinceEpoch);
    if (existing != null) {
      return existing.id!;
    }

    final id = await _dayRecordDao.insertDayRecord(
      DayRecordEntity(date: normalizedDate),
    );
    return id;
  }

  Future<DayRecord> _buildDayRecordFromEntity(DayRecordEntity entity) async {
    final mealEntities = await _mealDao.findMealsForDayRecord(entity.id!);
    final meals = await Future.wait(mealEntities.map(_buildMealFromEntity));
    return DayRecord(
      id: entity.id,
      date: entity.date,
      meals: meals,
      calorieGoal: entity.calorieGoal,
      proteinGoal: entity.proteinGoal,
      carbsGoal: entity.carbsGoal,
      fatGoal: entity.fatGoal,
    );
  }

  Future<Meal> _buildMealFromEntity(MealEntity mealEntity) async {
    final ingredientEntities = await _ingredientDao.findIngredientsForMeal(mealEntity.id!);
    final ingredients = ingredientEntities
        .map(
          (ingredient) => Ingredient(
            id: ingredient.id,
            mealId: ingredient.mealId,
            name: ingredient.name,
            weight: ingredient.weight,
            calories: ingredient.calories,
            proteins: ingredient.proteins,
            carbs: ingredient.carbs,
            fats: ingredient.fats,
          ),
        )
        .toList();

    return Meal(
      id: mealEntity.id,
      dayRecordId: mealEntity.dayRecordId,
      name: mealEntity.name,
      ingredients: ingredients,
      timestamp: mealEntity.timestamp,
      photoPath: mealEntity.photoPath,
      isFavorite: mealEntity.isFavorite,
    );
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
