import 'package:diplomka/database/app_database.dart';
import 'package:diplomka/database/dao/day_record_dao.dart';
import 'package:diplomka/database/dao/exercise_dao.dart';
import 'package:diplomka/database/dao/ingredient_dao.dart';
import 'package:diplomka/database/dao/meal_dao.dart';
import 'package:diplomka/database/entities/day_record_entity.dart';
import 'package:diplomka/database/entities/exercise_entity.dart';
import 'package:diplomka/database/entities/ingredient_entity.dart';
import 'package:diplomka/database/entities/meal_entity.dart';
import 'package:diplomka/model/day_record.dart';
import 'package:diplomka/model/exercise.dart';
import 'package:diplomka/model/ingredient.dart';
import 'package:diplomka/model/meal.dart';
import 'package:diplomka/utils/media_storage.dart';
import 'package:get/get.dart';

class DayRecordRepository extends GetxService {
  static DayRecordRepository get to => Get.find();

  DayRecordRepository({required AppDatabase database}) : _database = database;

  final AppDatabase _database;

  DayRecordDao get _dayRecordDao => _database.dayRecordDao;
  MealDao get _mealDao => _database.mealDao;
  IngredientDao get _ingredientDao => _database.ingredientDao;
  ExerciseDao get _exerciseDao => _database.exerciseDao;

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
      confidence: meal.confidence,
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
              confidence: ingredient.confidence,
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

  Future<DayRecord> saveExerciseForDate({required DateTime date, required Exercise exercise}) async {
    final normalizedDate = _normalizeDate(date);
    final dayRecordId = await _ensureDayRecordId(normalizedDate);

    final exerciseEntity = ExerciseEntity(
      id: exercise.id,
      dayRecordId: dayRecordId,
      name: exercise.name,
      timestamp: exercise.timestamp,
      durationMinutes: exercise.durationMinutes,
      caloriesBurned: exercise.caloriesBurned,
      isFavorite: exercise.isFavorite,
      source: exercise.source,
    );

    if (exercise.id == null) {
      await _exerciseDao.insertExercise(exerciseEntity);
    } else {
      await _exerciseDao.updateExercise(exerciseEntity);
    }

    final entity = await _dayRecordDao.findDayRecordById(dayRecordId);
    return _buildDayRecordFromEntity(entity!);
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
      confidence: meal.confidence,
    );
    await _mealDao.updateMeal(entity);
  }

  Future<void> updateExerciseFavorite({required Exercise exercise, required bool isFavorite}) async {
    if (exercise.id == null || exercise.dayRecordId == null) return;
    final entity = ExerciseEntity(
      id: exercise.id,
      dayRecordId: exercise.dayRecordId!,
      name: exercise.name,
      timestamp: exercise.timestamp,
      durationMinutes: exercise.durationMinutes,
      caloriesBurned: exercise.caloriesBurned,
      isFavorite: isFavorite,
      source: exercise.source,
    );
    await _exerciseDao.updateExercise(entity);
  }

  Future<Exercise?> findHealthSyncExercise({required DateTime date, required String source}) async {
    final normalizedDate = _normalizeDate(date);
    final existing = await _dayRecordDao.findDayRecordByDate(normalizedDate.millisecondsSinceEpoch);
    if (existing == null) return null;
    final entity = await _exerciseDao.findExerciseByDayRecordAndSource(existing.id!, source);
    if (entity == null) return null;
    return _buildExerciseFromEntity(entity);
  }

  Future<void> repairMealPhotoPaths() async {
    final dayRecordEntities = await _dayRecordDao.getAllDayRecords();

    for (final dayRecordEntity in dayRecordEntities) {
      final dayRecordId = dayRecordEntity.id;
      if (dayRecordId == null) continue;
      final mealEntities = await _mealDao.findMealsForDayRecord(dayRecordId);

      for (final mealEntity in mealEntities) {
        final path = mealEntity.photoPath;
        if (path == null || path.isEmpty) continue;

        String? repairedPath;
        try {
          repairedPath = await MediaStorage.persistMealPhoto(path);
        } catch (_) {
          repairedPath = null;
        }

        // Keep original path when repair fails; never destroy user data on uncertain state.
        if (repairedPath == null) {
          continue;
        }

        final nextPhotoPath = repairedPath;
        if (nextPhotoPath == mealEntity.photoPath) {
          continue;
        }

        await _mealDao.updateMeal(
          MealEntity(
            id: mealEntity.id,
            dayRecordId: mealEntity.dayRecordId,
            name: mealEntity.name,
            timestamp: mealEntity.timestamp,
            photoPath: nextPhotoPath,
            isFavorite: mealEntity.isFavorite,
            confidence: mealEntity.confidence,
          ),
        );
      }
    }
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
    final exerciseEntities = await _exerciseDao.findExercisesForDayRecord(entity.id!);
    final meals = await Future.wait(mealEntities.map(_buildMealFromEntity));
    final exercises = exerciseEntities.map(_buildExerciseFromEntity).toList();
    return DayRecord(
      id: entity.id,
      date: entity.date,
      meals: meals,
      exercises: exercises,
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
            confidence: ingredient.confidence,
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
      confidence: mealEntity.confidence,
    );
  }

  Exercise _buildExerciseFromEntity(ExerciseEntity exerciseEntity) {
    return Exercise(
      id: exerciseEntity.id,
      dayRecordId: exerciseEntity.dayRecordId,
      name: exerciseEntity.name,
      timestamp: exerciseEntity.timestamp,
      durationMinutes: exerciseEntity.durationMinutes,
      caloriesBurned: exerciseEntity.caloriesBurned,
      isFavorite: exerciseEntity.isFavorite,
      source: exerciseEntity.source,
    );
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
