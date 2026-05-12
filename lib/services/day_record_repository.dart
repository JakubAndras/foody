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
import 'package:diplomka/model/nutrition_goals.dart';
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

  // RESEARCH-ONLY: research-only — returns aggregates that include
  // soft-deleted meals and ingredients so the export preserves the full AI
  // signal even for records the user removed. Drop with the rest of the
  // soft-delete telemetry. See RESEARCH_ONLY.md.
  Future<List<DayRecord>> getAllDayRecordsForExport() async {
    final entities = await _dayRecordDao.getAllDayRecords();
    final records = await Future.wait(entities.map((e) => _buildDayRecordFromEntity(e, includeDeleted: true)));
    records.sort((a, b) => b.date.compareTo(a.date));
    return records;
  }

  Future<DayRecord> upsertDayRecord(DayRecord record) async {
    final normalizedDate = _normalizeDate(record.date);
    final existing = await _dayRecordDao.findDayRecordByDate(normalizedDate.millisecondsSinceEpoch);
    DayRecordEntity entity;

    if (existing != null) {
      entity = existing.copyWith(calorieGoal: record.calorieGoal, proteinGoal: record.proteinGoal, carbsGoal: record.carbsGoal, fatGoal: record.fatGoal);
      await _dayRecordDao.updateDayRecord(entity);
    } else {
      entity = DayRecordEntity(date: normalizedDate, calorieGoal: record.calorieGoal, proteinGoal: record.proteinGoal, carbsGoal: record.carbsGoal, fatGoal: record.fatGoal);
      final id = await _dayRecordDao.insertDayRecord(entity);
      entity = entity.copyWith(id: id);
    }

    return _buildDayRecordFromEntity(entity);
  }

  Future<DayRecord> saveMealForDate({required DateTime date, required Meal meal}) async {
    final normalizedDate = _normalizeDate(date);
    final dayRecordId = await _ensureDayRecordId(normalizedDate);

    // RESEARCH-ONLY: edit-detection block. Research-only — remove with the
    // entity columns. See RESEARCH_ONLY.md.
    final bool mealHasAiSnapshot = meal.aiOriginalCalories != null;
    bool mealEditedNow = meal.wasEditedByUser;
    DateTime? mealEditedAt = meal.editedAt;
    if (mealHasAiSnapshot && !meal.wasEditedByUser) {
      final divergent =
          (meal.name != (meal.aiOriginalName ?? meal.name)) ||
          _diverges(meal.totalCalories, meal.aiOriginalCalories) ||
          _diverges(meal.totalProteins, meal.aiOriginalProteins) ||
          _diverges(meal.totalCarbs, meal.aiOriginalCarbs) ||
          _diverges(meal.totalFats, meal.aiOriginalFats);
      if (divergent) {
        mealEditedNow = true;
        mealEditedAt ??= DateTime.now();
      }
    }

    final mealEntity = MealEntity(
      id: meal.id,
      dayRecordId: dayRecordId,
      name: meal.name,
      timestamp: meal.timestamp,
      photoPath: meal.photoPath,
      isFavorite: meal.isFavorite,
      confidence: meal.confidence,
      barcode: meal.barcode,
      // RESEARCH-ONLY: research-only fields below
      inputSource: meal.inputSource,
      aiProvider: meal.aiProvider,
      aiModel: meal.aiModel,
      aiOriginalName: meal.aiOriginalName,
      aiOriginalCalories: meal.aiOriginalCalories,
      aiOriginalProteins: meal.aiOriginalProteins,
      aiOriginalCarbs: meal.aiOriginalCarbs,
      aiOriginalFats: meal.aiOriginalFats,
      aiOriginalConfidence: meal.aiOriginalConfidence,
      wasEditedByUser: mealEditedNow,
      editedAtMs: mealEditedAt?.millisecondsSinceEpoch,
    );

    int mealId;
    if (meal.id == null) {
      mealId = await _mealDao.insertMeal(mealEntity);
    } else {
      await _mealDao.updateMeal(mealEntity);
      mealId = meal.id!;
      // RESEARCH-ONLY: soft-delete previous ingredients on edit so the AI
      // snapshot of any removed ingredient survives in the export. The next
      // insert below writes the user's current ingredient list. Drop with the
      // `deletedAtMs` column. See RESEARCH_ONLY.md.
      await _ingredientDao.softDeleteIngredientsForMeal(mealId, DateTime.now().millisecondsSinceEpoch);
    }

    final ingredients = meal.ingredients.map((ingredient) {
      // RESEARCH-ONLY: per-ingredient edit-detection. Research-only.
      final bool ingHasSnapshot = ingredient.aiOriginalCalories != null;
      bool ingEdited = ingredient.wasEditedByUser;
      if (ingHasSnapshot && !ingredient.wasEditedByUser) {
        final divergent =
            (ingredient.name != (ingredient.aiOriginalName ?? ingredient.name)) ||
            _diverges(ingredient.weight, ingredient.aiOriginalWeight) ||
            _diverges(ingredient.amount, ingredient.aiOriginalAmount) ||
            _diverges(ingredient.calories, ingredient.aiOriginalCalories) ||
            _diverges(ingredient.proteins, ingredient.aiOriginalProteins) ||
            _diverges(ingredient.carbs, ingredient.aiOriginalCarbs) ||
            _diverges(ingredient.fats, ingredient.aiOriginalFats);
        if (divergent) ingEdited = true;
      }
      return IngredientEntity(
        mealId: mealId,
        name: ingredient.name,
        weight: ingredient.weight,
        amount: ingredient.amount,
        calories: ingredient.calories,
        proteins: ingredient.proteins,
        carbs: ingredient.carbs,
        fats: ingredient.fats,
        confidence: ingredient.confidence,
        isFavorite: ingredient.isFavorite,
        // RESEARCH-ONLY: research-only fields below
        aiOriginalName: ingredient.aiOriginalName,
        aiOriginalWeight: ingredient.aiOriginalWeight,
        aiOriginalAmount: ingredient.aiOriginalAmount,
        aiOriginalCalories: ingredient.aiOriginalCalories,
        aiOriginalProteins: ingredient.aiOriginalProteins,
        aiOriginalCarbs: ingredient.aiOriginalCarbs,
        aiOriginalFats: ingredient.aiOriginalFats,
        aiOriginalConfidence: ingredient.aiOriginalConfidence,
        wasEditedByUser: ingEdited,
      );
    }).toList();

    if (ingredients.isNotEmpty) {
      await _ingredientDao.insertIngredients(ingredients);
    }

    final entity = await _dayRecordDao.findDayRecordById(dayRecordId);
    return _buildDayRecordFromEntity(entity!);
  }

  // RESEARCH-ONLY: divergence helper for edit detection. Research-only.
  static const double _editTolerance = 0.5;

  static bool _diverges(double current, double? original) {
    if (original == null) return false;
    return (current - original).abs() > _editTolerance;
  }

  // RESEARCH-ONLY: end

  Future<void> deleteMeal(Meal meal) async {
    if (meal.id == null) return;
    // RESEARCH-ONLY: soft-delete preserves the AI snapshot for the export.
    // To revert to hard delete, swap these two calls back to
    // `deleteIngredientsForMeal` + `deleteMealById`. See RESEARCH_ONLY.md.
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    await _ingredientDao.softDeleteIngredientsForMeal(meal.id!, nowMs);
    await _mealDao.softDeleteMealById(meal.id!, nowMs);
  }

  Future<void> deleteExercise(Exercise exercise) async {
    if (exercise.id == null) return;
    await _exerciseDao.deleteExerciseById(exercise.id!);
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
      confidence: exercise.confidence,
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
      barcode: meal.barcode,
      // RESEARCH-ONLY: research-only fields below
      inputSource: meal.inputSource,
      aiProvider: meal.aiProvider,
      aiModel: meal.aiModel,
      aiOriginalName: meal.aiOriginalName,
      aiOriginalCalories: meal.aiOriginalCalories,
      aiOriginalProteins: meal.aiOriginalProteins,
      aiOriginalCarbs: meal.aiOriginalCarbs,
      aiOriginalFats: meal.aiOriginalFats,
      aiOriginalConfidence: meal.aiOriginalConfidence,
      wasEditedByUser: meal.wasEditedByUser,
      editedAtMs: meal.editedAt?.millisecondsSinceEpoch,
    );
    await _mealDao.updateMeal(entity);
  }

  Future<void> updateIngredientFavorite({required Ingredient ingredient, required bool isFavorite}) async {
    if (ingredient.id == null || ingredient.mealId == null) return;
    final entity = IngredientEntity(
      id: ingredient.id,
      mealId: ingredient.mealId!,
      name: ingredient.name,
      weight: ingredient.weight,
      amount: ingredient.amount,
      calories: ingredient.calories,
      proteins: ingredient.proteins,
      carbs: ingredient.carbs,
      fats: ingredient.fats,
      confidence: ingredient.confidence,
      isFavorite: isFavorite,
      // RESEARCH-ONLY: research-only fields below
      aiOriginalName: ingredient.aiOriginalName,
      aiOriginalWeight: ingredient.aiOriginalWeight,
      aiOriginalAmount: ingredient.aiOriginalAmount,
      aiOriginalCalories: ingredient.aiOriginalCalories,
      aiOriginalProteins: ingredient.aiOriginalProteins,
      aiOriginalCarbs: ingredient.aiOriginalCarbs,
      aiOriginalFats: ingredient.aiOriginalFats,
      aiOriginalConfidence: ingredient.aiOriginalConfidence,
      wasEditedByUser: ingredient.wasEditedByUser,
    );
    await _ingredientDao.updateIngredient(entity);
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
      confidence: exercise.confidence,
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

        await _mealDao.updateMeal(mealEntity.copyWith(photoPath: nextPhotoPath));
      }
    }
  }

  Future<int> _ensureDayRecordId(DateTime normalizedDate) async {
    final existing = await _dayRecordDao.findDayRecordByDate(normalizedDate.millisecondsSinceEpoch);
    if (existing != null) {
      return existing.id!;
    }

    final seed = await _resolveSeedGoalsForNewRecord(normalizedDate);
    final id = await _dayRecordDao.insertDayRecord(
      DayRecordEntity(date: normalizedDate, calorieGoal: seed.calorieGoal, proteinGoal: seed.proteinGoal, carbsGoal: seed.carbsGoal, fatGoal: seed.fatGoal),
    );
    return id;
  }

  Future<NutritionGoals> _resolveSeedGoalsForNewRecord(DateTime normalizedDate) async {
    final prior = await _dayRecordDao.findMostRecentDayRecordBefore(normalizedDate.millisecondsSinceEpoch);
    if (prior != null) {
      return NutritionGoals(calorieGoal: prior.calorieGoal, proteinGoal: prior.proteinGoal, carbsGoal: prior.carbsGoal, fatGoal: prior.fatGoal);
    }
    final anyExisting = await _dayRecordDao.findMostRecentDayRecord();
    if (anyExisting != null) {
      return NutritionGoals(calorieGoal: anyExisting.calorieGoal, proteinGoal: anyExisting.proteinGoal, carbsGoal: anyExisting.carbsGoal, fatGoal: anyExisting.fatGoal);
    }
    return NutritionGoals.defaults;
  }

  Future<DayRecord> _buildDayRecordFromEntity(DayRecordEntity entity, {bool includeDeleted = false}) async {
    final mealEntities = includeDeleted ? await _mealDao.findAllMealsForDayRecordIncludingDeleted(entity.id!) : await _mealDao.findMealsForDayRecord(entity.id!);
    final exerciseEntities = await _exerciseDao.findExercisesForDayRecord(entity.id!);
    final meals = await Future.wait(mealEntities.map((m) => _buildMealFromEntity(m, includeDeleted: includeDeleted)));
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

  Future<Meal> _buildMealFromEntity(MealEntity mealEntity, {bool includeDeleted = false}) async {
    final ingredientEntities = includeDeleted
        ? await _ingredientDao.findAllIngredientsForMealIncludingDeleted(mealEntity.id!)
        : await _ingredientDao.findIngredientsForMeal(mealEntity.id!);
    final ingredients = ingredientEntities
        .map(
          (ingredient) => Ingredient(
            id: ingredient.id,
            mealId: ingredient.mealId,
            name: ingredient.name,
            weight: ingredient.weight,
            amount: ingredient.amount ?? 1.0,
            calories: ingredient.calories,
            proteins: ingredient.proteins,
            carbs: ingredient.carbs,
            fats: ingredient.fats,
            confidence: ingredient.confidence,
            isFavorite: ingredient.isFavorite,
            // RESEARCH-ONLY: research-only fields below
            aiOriginalName: ingredient.aiOriginalName,
            aiOriginalWeight: ingredient.aiOriginalWeight,
            aiOriginalAmount: ingredient.aiOriginalAmount,
            aiOriginalCalories: ingredient.aiOriginalCalories,
            aiOriginalProteins: ingredient.aiOriginalProteins,
            aiOriginalCarbs: ingredient.aiOriginalCarbs,
            aiOriginalFats: ingredient.aiOriginalFats,
            aiOriginalConfidence: ingredient.aiOriginalConfidence,
            wasEditedByUser: ingredient.wasEditedByUser,
            deletedAt: ingredient.deletedAtMs != null ? DateTime.fromMillisecondsSinceEpoch(ingredient.deletedAtMs!) : null,
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
      barcode: mealEntity.barcode,
      // RESEARCH-ONLY: research-only fields below
      inputSource: mealEntity.inputSource,
      aiProvider: mealEntity.aiProvider,
      aiModel: mealEntity.aiModel,
      aiOriginalName: mealEntity.aiOriginalName,
      aiOriginalCalories: mealEntity.aiOriginalCalories,
      aiOriginalProteins: mealEntity.aiOriginalProteins,
      aiOriginalCarbs: mealEntity.aiOriginalCarbs,
      aiOriginalFats: mealEntity.aiOriginalFats,
      aiOriginalConfidence: mealEntity.aiOriginalConfidence,
      wasEditedByUser: mealEntity.wasEditedByUser,
      editedAt: mealEntity.editedAtMs != null ? DateTime.fromMillisecondsSinceEpoch(mealEntity.editedAtMs!) : null,
      deletedAt: mealEntity.deletedAtMs != null ? DateTime.fromMillisecondsSinceEpoch(mealEntity.deletedAtMs!) : null,
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
      confidence: exerciseEntity.confidence,
    );
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
