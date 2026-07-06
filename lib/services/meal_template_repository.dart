import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:diplomka/database/app_database.dart';
import 'package:diplomka/database/dao/meal_template_dao.dart';
import 'package:diplomka/database/dao/meal_template_ingredient_dao.dart';
import 'package:diplomka/database/entities/meal_template_entity.dart';
import 'package:diplomka/database/entities/meal_template_ingredient_entity.dart';
import 'package:diplomka/di/providers.dart';
import 'package:diplomka/model/ingredient.dart';
import 'package:diplomka/model/meal.dart';
import 'package:diplomka/model/meal_template.dart';

/// Reaktivní seznam šablon jídel (uživatelova osobní knihovna).
/// Stav je `AsyncValue<List<MealTemplate>>` — `build()` provede iniciální načtení,
/// mutace zapíší do DB a znovu načtou stav.
class MealTemplatesNotifier extends AsyncNotifier<List<MealTemplate>> {
  AppDatabase get _database => ref.watch(databaseProvider);
  MealTemplateDao get _templateDao => _database.mealTemplateDao;
  MealTemplateIngredientDao get _ingredientDao => _database.mealTemplateIngredientDao;

  @override
  Future<List<MealTemplate>> build() => _loadTemplates();

  Future<List<MealTemplate>> _loadTemplates() async {
    final entities = await _templateDao.getAllTemplates();
    return Future.wait(entities.map(_buildFromEntity));
  }

  Future<void> upsertFromMeal(Meal meal) async {
    if (meal.name.trim().isEmpty) return;
    final normalized = MealTemplate.normalize(meal.name);
    final existing = await _templateDao.findByNormalizedName(normalized);

    if (existing != null) {
      await _templateDao.updateTemplate(existing.copyWith(
        usageCount: existing.usageCount + 1,
        photoPath: meal.photoPath ?? existing.photoPath,
      ));
    } else {
      final templateId = await _templateDao.insertTemplate(MealTemplateEntity(
        name: meal.name,
        normalizedName: normalized,
        photoPath: meal.photoPath,
        lastUsedAt: meal.timestamp,
      ));
      if (templateId > 0 && meal.ingredients.isNotEmpty) {
        await _ingredientDao.insertIngredients(
          meal.ingredients
              .map((i) => MealTemplateIngredientEntity(
                    templateId: templateId,
                    name: i.name,
                    weight: i.weight,
                    calories: i.calories,
                    proteins: i.proteins,
                    carbs: i.carbs,
                    fats: i.fats,
                    dietaryViolation: i.dietaryViolation,
                  ))
              .toList(),
        );
      }
    }
    state = await AsyncValue.guard(_loadTemplates);
  }

  Future<void> setFavorite(MealTemplate template, bool isFavorite) async {
    if (template.id == null) return;
    final entity = await _templateDao.findByNormalizedName(template.normalizedName);
    if (entity == null) return;
    await _templateDao.updateTemplate(entity.copyWith(isFavorite: isFavorite));
    state = await AsyncValue.guard(_loadTemplates);
  }

  Future<void> deleteTemplate(MealTemplate template) async {
    if (template.id == null) return;
    await _templateDao.deleteTemplateById(template.id!);
    state = await AsyncValue.guard(_loadTemplates);
  }

  Future<MealTemplate> _buildFromEntity(MealTemplateEntity entity) async {
    final ingredientEntities = await _ingredientDao.findForTemplate(entity.id!);
    final ingredients = ingredientEntities
        .map((e) => Ingredient(
              name: e.name,
              weight: e.weight,
              calories: e.calories,
              proteins: e.proteins,
              carbs: e.carbs,
              fats: e.fats,
              dietaryViolation: e.dietaryViolation,
            ))
        .toList();
    return MealTemplate(
      id: entity.id,
      name: entity.name,
      normalizedName: entity.normalizedName,
      photoPath: entity.photoPath,
      isFavorite: entity.isFavorite,
      lastUsedAt: entity.lastUsedAt,
      usageCount: entity.usageCount,
      ingredients: ingredients,
    );
  }
}

final mealTemplatesProvider = AsyncNotifierProvider<MealTemplatesNotifier, List<MealTemplate>>(MealTemplatesNotifier.new);
