import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:diplomka/database/app_database.dart';
import 'package:diplomka/database/dao/ingredient_template_dao.dart';
import 'package:diplomka/database/entities/ingredient_template_entity.dart';
import 'package:diplomka/di/providers.dart';
import 'package:diplomka/model/ingredient.dart';
import 'package:diplomka/model/ingredient_template.dart';

/// Reaktivní seznam šablon ingrediencí.
/// Stav je `AsyncValue<List<IngredientTemplate>>` — `build()` provede iniciální načtení,
/// mutační metody zapíší do DB a znovu načtou stav.
class IngredientTemplatesNotifier extends AsyncNotifier<List<IngredientTemplate>> {
  AppDatabase get _database => ref.watch(databaseProvider);
  IngredientTemplateDao get _templateDao => _database.ingredientTemplateDao;

  @override
  Future<List<IngredientTemplate>> build() => _loadTemplates();

  Future<List<IngredientTemplate>> _loadTemplates() async {
    final entities = await _templateDao.getAllTemplates();
    return entities.map(_buildFromEntity).toList();
  }

  Future<void> _writeFromIngredient(Ingredient ingredient) async {
    if (ingredient.name.trim().isEmpty) return;
    final normalized = IngredientTemplate.normalize(ingredient.name);
    final existing = await _templateDao.findByNormalizedName(normalized);

    if (existing != null) {
      await _templateDao.updateTemplate(existing.copyWith(
        name: ingredient.name,
        weight: ingredient.weight,
        amount: ingredient.amount,
        calories: ingredient.calories,
        proteins: ingredient.proteins,
        carbs: ingredient.carbs,
        fats: ingredient.fats,
        usageCount: existing.usageCount + 1,
        dietaryViolation: ingredient.dietaryViolation,
      ));
    } else {
      await _templateDao.insertTemplate(IngredientTemplateEntity(
        name: ingredient.name,
        normalizedName: normalized,
        weight: ingredient.weight,
        amount: ingredient.amount,
        calories: ingredient.calories,
        proteins: ingredient.proteins,
        carbs: ingredient.carbs,
        fats: ingredient.fats,
        isFavorite: ingredient.isFavorite,
        lastUsedAt: DateTime.now(),
        dietaryViolation: ingredient.dietaryViolation,
      ));
    }
  }

  Future<void> upsertFromIngredient(Ingredient ingredient) async {
    await _writeFromIngredient(ingredient);
    state = await AsyncValue.guard(_loadTemplates);
  }

  Future<void> upsertFromIngredients(List<Ingredient> ingredients) async {
    for (final ingredient in ingredients) {
      await _writeFromIngredient(ingredient);
    }
    state = await AsyncValue.guard(_loadTemplates);
  }

  Future<void> updateTemplate(IngredientTemplate template) async {
    if (template.id == null) return;
    final entity = await _templateDao.findByNormalizedName(template.normalizedName);
    if (entity == null) return;
    await _templateDao.updateTemplate(entity.copyWith(
      name: template.name,
      weight: template.weight,
      amount: template.amount,
      calories: template.calories,
      proteins: template.proteins,
      carbs: template.carbs,
      fats: template.fats,
    ));
    state = await AsyncValue.guard(_loadTemplates);
  }

  Future<void> setFavorite(IngredientTemplate template, bool isFavorite) async {
    if (template.id == null) return;
    final entity = await _templateDao.findByNormalizedName(template.normalizedName);
    if (entity == null) return;
    await _templateDao.updateTemplate(entity.copyWith(isFavorite: isFavorite));
    state = await AsyncValue.guard(_loadTemplates);
  }

  Future<void> deleteTemplate(IngredientTemplate template) async {
    if (template.id == null) return;
    await _templateDao.deleteTemplateById(template.id!);
    state = await AsyncValue.guard(_loadTemplates);
  }

  IngredientTemplate _buildFromEntity(IngredientTemplateEntity entity) {
    return IngredientTemplate(
      id: entity.id,
      name: entity.name,
      normalizedName: entity.normalizedName,
      weight: entity.weight,
      amount: entity.amount,
      calories: entity.calories,
      proteins: entity.proteins,
      carbs: entity.carbs,
      fats: entity.fats,
      isFavorite: entity.isFavorite,
      lastUsedAt: entity.lastUsedAt,
      usageCount: entity.usageCount,
    );
  }
}

final ingredientTemplatesProvider = AsyncNotifierProvider<IngredientTemplatesNotifier, List<IngredientTemplate>>(IngredientTemplatesNotifier.new);
