import 'package:diplomka/database/app_database.dart';
import 'package:diplomka/database/dao/exercise_template_dao.dart';
import 'package:diplomka/database/entities/exercise_template_entity.dart';
import 'package:diplomka/model/exercise.dart';
import 'package:diplomka/model/exercise_template.dart';
import 'package:get/get.dart';

class ExerciseTemplateRepository extends GetxService {
  static ExerciseTemplateRepository get to => Get.find();

  ExerciseTemplateRepository({required AppDatabase database}) : _database = database;

  final AppDatabase _database;
  ExerciseTemplateDao get _templateDao => _database.exerciseTemplateDao;

  final RxList<ExerciseTemplate> allTemplates = RxList<ExerciseTemplate>();

  @override
  void onInit() {
    super.onInit();
    refreshTemplates();
  }

  Future<void> refreshTemplates() async {
    final entities = await _templateDao.getAllTemplates();
    allTemplates.assignAll(entities.map(_buildFromEntity).toList());
  }

  Future<void> upsertFromExercise(Exercise exercise) async {
    if (exercise.name.trim().isEmpty) return;
    if (exercise.isFromHealthSync) return;
    final normalized = ExerciseTemplate.normalize(exercise.name);
    final existing = await _templateDao.findByNormalizedName(normalized);

    if (existing != null) {
      await _templateDao.updateTemplate(existing.copyWith(
        usageCount: existing.usageCount + 1,
      ));
    } else {
      await _templateDao.insertTemplate(ExerciseTemplateEntity(
        name: exercise.name,
        normalizedName: normalized,
        durationMinutes: exercise.durationMinutes,
        caloriesBurned: exercise.caloriesBurned,
        lastUsedAt: exercise.timestamp,
      ));
    }
    await refreshTemplates();
  }

  Future<void> setFavorite(ExerciseTemplate template, bool isFavorite) async {
    if (template.id == null) return;
    final entity = await _templateDao.findByNormalizedName(template.normalizedName);
    if (entity == null) return;
    await _templateDao.updateTemplate(entity.copyWith(isFavorite: isFavorite));
    await refreshTemplates();
  }

  Future<void> deleteTemplate(ExerciseTemplate template) async {
    if (template.id == null) return;
    await _templateDao.deleteTemplateById(template.id!);
    await refreshTemplates();
  }

  ExerciseTemplate _buildFromEntity(ExerciseTemplateEntity entity) {
    return ExerciseTemplate(
      id: entity.id,
      name: entity.name,
      normalizedName: entity.normalizedName,
      durationMinutes: entity.durationMinutes,
      caloriesBurned: entity.caloriesBurned,
      isFavorite: entity.isFavorite,
      lastUsedAt: entity.lastUsedAt,
      usageCount: entity.usageCount,
    );
  }
}
