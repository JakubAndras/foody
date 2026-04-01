import 'package:diplomka/app_theme.dart';
import 'package:diplomka/controller/day_record_controller.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/model/exercise.dart';
import 'package:diplomka/model/exercise_template.dart';
import 'package:diplomka/services/exercise_template_repository.dart';
import 'package:diplomka/screens/logs/exercise_widgets.dart';
import 'package:diplomka/widgets/confirm_delete_dialog.dart';
import 'package:diplomka/widgets/custom_glass_app_bar.dart';
import 'package:diplomka/utils/app_limits.dart';
import 'package:diplomka/widgets/duration_picker_sheet.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:diplomka/screens/profile/profile_widgets.dart';

class ExerciseDetailScreen extends StatefulWidget {
  const ExerciseDetailScreen({super.key, required this.exercise, this.openedFromLogScreen = false, this.selectedDate});

  final Exercise exercise;
  final bool openedFromLogScreen;
  final DateTime? selectedDate;

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  late Exercise _exercise;
  late final TextEditingController _nameController;
  late final TextEditingController _caloriesController;
  late int _durationMinutes;

  @override
  void initState() {
    super.initState();
    _exercise = widget.exercise;
    _nameController = TextEditingController(text: _exercise.name);
    _caloriesController = TextEditingController(text: '${_exercise.caloriesBurned.round()}');
    _durationMinutes = _exercise.durationMinutes ?? 0;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  Exercise _buildExercise() {
    return _exercise.copyWith(
      name: _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : _exercise.name,
      caloriesBurned: double.tryParse(_caloriesController.text) ?? _exercise.caloriesBurned,
      durationMinutes: _durationMinutes,
    );
  }

  void _handleDone() {
    Navigator.of(context).pop(_buildExercise());
  }

  String _formatDuration(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h > 0) return '${h}h ${m}min';
    return '${m}min';
  }

  Future<void> _openDurationPicker() async {
    await showDurationPickerSheet(
      context: context,
      title: tr(LocaleKeys.common_duration),
      initialMinutes: _durationMinutes,
      onChanged: (minutes) => setState(() => _durationMinutes = minutes),
    );
  }

  Future<void> _toggleFavorite() async {
    final next = !_exercise.isFavorite;
    setState(() => _exercise = _exercise.copyWith(isFavorite: next));

    // Always sync to template (both paths need this)
    final normalized = ExerciseTemplate.normalize(_exercise.name);
    final template = ExerciseTemplateRepository.to.allTemplates.firstWhereOrNull((t) => t.normalizedName == normalized);
    if (template != null) await ExerciseTemplateRepository.to.setFavorite(template, next);

    if (widget.openedFromLogScreen) return;

    // Dashboard path: also update the Exercise record
    if (_exercise.id == null || _exercise.dayRecordId == null) return;
    await DayRecordController.to.setExerciseFavorite(exercise: _exercise, isFavorite: next);
  }

  @override
  Widget build(BuildContext context) {
    return ProfileGradientScaffold(
      scroll: true,
      padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 0, AppSpacing.screen, AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomGlassAppBar(
            title: '',
            leadingIconSize: AppSizes.iconLg,
            onBack: () => Navigator.of(context).maybePop(),
            actions: [
              CustomGlassIconButtonGroup(
                iconSize: AppSizes.iconLg,
                items: [
                  (icon: CupertinoIcons.checkmark, onPressed: _handleDone),
                  (icon: _exercise.isFavorite ? CupertinoIcons.bookmark_fill : CupertinoIcons.bookmark, onPressed: _toggleFavorite),
                  (icon: CupertinoIcons.trash, onPressed: _handleDeleteExercise),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.l),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.l),
            decoration: BoxDecoration(gradient: AppGradients.primary, borderRadius: BorderRadius.circular(AppRadii.l)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tr(LocaleKeys.common_exercise), style: AppTextStyles.body14.copyWith(color: AppColors.onPrimary.withValues(alpha: 0.6))),
                const SizedBox(height: AppSpacing.xs),
                TextField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.sentences,
                  cursorColor: AppColors.onPrimary,
                  style: AppTextStyles.h2.copyWith(color: AppColors.onPrimary),
                  decoration: InputDecoration(
                    hintText: tr(LocaleKeys.common_name),
                    hintStyle: AppTextStyles.h2.copyWith(color: AppColors.onPrimary.withValues(alpha: 0.6)),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          Row(
            children: [
              Expanded(
                child: ExerciseStatCard(
                  gradient: AppGradients.exerciseCalories,
                  icon: CupertinoIcons.flame,
                  label: tr(LocaleKeys.exercise_total_calories),
                  value: '${_exercise.caloriesBurned.round()}',
                  unit: tr(LocaleKeys.common_kcal),
                  controller: _caloriesController,
                  maxValue: AppLimits.exerciseMaxCalories,
                ),
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: GestureDetector(
                  onTap: _openDurationPicker,
                  child: ExerciseStatCard(
                    gradient: AppGradients.exerciseDuration,
                    icon: CupertinoIcons.clock,
                    label: tr(LocaleKeys.common_duration),
                    value: _formatDuration(_durationMinutes),
                    unit: '',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.huge),
        ],
      ),
    );
  }

  Future<void> _handleDeleteExercise() async {
    final confirmed = await showConfirmationDialog(
      context: context,
      title: tr(LocaleKeys.exercise_delete_title),
      subtitle: tr(LocaleKeys.common_cannot_undo),
      primaryLabel: tr(LocaleKeys.common_delete),
      secondaryLabel: tr(LocaleKeys.common_cancel),
      isDestructive: true,
    );
    if (confirmed != true || !mounted) return;

    if (widget.openedFromLogScreen) {
      // Log screen path: delete the template
      final normalized = ExerciseTemplate.normalize(_exercise.name);
      final template = ExerciseTemplateRepository.to.allTemplates.firstWhereOrNull((t) => t.normalizedName == normalized);
      if (template != null) await ExerciseTemplateRepository.to.deleteTemplate(template);
    } else {
      // Dashboard path: delete the exercise record
      if (_exercise.id == null) return;
      await DayRecordController.to.deleteExercise(_exercise);
    }
    if (!mounted) return;
    Get.back(result: true);
  }
}
