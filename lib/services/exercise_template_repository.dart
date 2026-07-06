import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:diplomka/database/dao/exercise_template_dao.dart';
import 'package:diplomka/database/entities/exercise_template_entity.dart';
import 'package:diplomka/di/providers.dart';
import 'package:diplomka/model/exercise.dart';
import 'package:diplomka/model/exercise_template.dart';

/// Reaktivní seznam šablon cvičení.
/// Stav je `AsyncValue<List<ExerciseTemplate>>` — `build()` provede iniciální načtení,
/// mutace zapíší do DB a znovu načtou stav.
class ExerciseTemplatesNotifier extends AsyncNotifier<List<ExerciseTemplate>> {
  ExerciseTemplateDao get _templateDao => ref.watch(databaseProvider).exerciseTemplateDao;

  @override
  Future<List<ExerciseTemplate>> build() => _loadTemplates();

  Future<List<ExerciseTemplate>> _loadTemplates() async {
    final entities = await _templateDao.getAllTemplates();
    return entities.map(_buildFromEntity).toList();
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
    state = await AsyncValue.guard(_loadTemplates);
  }

  Future<void> setFavorite(ExerciseTemplate template, bool isFavorite) async {
    if (template.id == null) return;
    final entity = await _templateDao.findByNormalizedName(template.normalizedName);
    if (entity == null) return;
    await _templateDao.updateTemplate(entity.copyWith(isFavorite: isFavorite));
    state = await AsyncValue.guard(_loadTemplates);
  }

  Future<void> updateTemplateValues({
    required ExerciseTemplate template,
    required String name,
    required double caloriesBurned,
    int? durationMinutes,
  }) async {
    if (template.id == null) return;
    final entity = await _templateDao.findByNormalizedName(template.normalizedName);
    if (entity == null) return;
    await _templateDao.updateTemplate(entity.copyWith(
      name: name,
      normalizedName: ExerciseTemplate.normalize(name),
      caloriesBurned: caloriesBurned,
      durationMinutes: durationMinutes,
    ));
    state = await AsyncValue.guard(_loadTemplates);
  }

  Future<void> deleteTemplate(ExerciseTemplate template) async {
    if (template.id == null) return;
    await _templateDao.deleteTemplateById(template.id!);
    state = await AsyncValue.guard(_loadTemplates);
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

final exerciseTemplatesProvider = AsyncNotifierProvider<ExerciseTemplatesNotifier, List<ExerciseTemplate>>(ExerciseTemplatesNotifier.new);
