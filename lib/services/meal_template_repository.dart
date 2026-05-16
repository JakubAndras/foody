import 'package:diplomka/database/app_database.dart';
import 'package:diplomka/database/dao/meal_template_dao.dart';
import 'package:diplomka/database/dao/meal_template_ingredient_dao.dart';
import 'package:diplomka/database/entities/meal_template_entity.dart';
import 'package:diplomka/database/entities/meal_template_ingredient_entity.dart';
import 'package:diplomka/model/ingredient.dart';
import 'package:diplomka/model/meal.dart';
import 'package:diplomka/model/meal_template.dart';
import 'package:get/get.dart';

class MealTemplateRepository extends GetxService {
  static MealTemplateRepository get to => Get.find();

  MealTemplateRepository({required AppDatabase database}) : _database = database;

  final AppDatabase _database;
  MealTemplateDao get _templateDao => _database.mealTemplateDao;
  MealTemplateIngredientDao get _ingredientDao => _database.mealTemplateIngredientDao;

  final RxList<MealTemplate> allTemplates = RxList<MealTemplate>();

  @override
  void onInit() {
    super.onInit();
    refreshTemplates();
  }

  Future<void> refreshTemplates() async {
    final entities = await _templateDao.getAllTemplates();
    final templates = await Future.wait(entities.map(_buildFromEntity));
    allTemplates.assignAll(templates);
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
    await refreshTemplates();
  }

  Future<void> setFavorite(MealTemplate template, bool isFavorite) async {
    if (template.id == null) return;
    final entity = await _templateDao.findByNormalizedName(template.normalizedName);
    if (entity == null) return;
    await _templateDao.updateTemplate(entity.copyWith(isFavorite: isFavorite));
    await refreshTemplates();
  }

  Future<void> deleteTemplate(MealTemplate template) async {
    if (template.id == null) return;
    await _templateDao.deleteTemplateById(template.id!);
    await refreshTemplates();
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
