import 'package:diplomka/app_theme.dart';
import 'package:diplomka/controller/day_record_controller.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/model/exercise.dart';
import 'package:diplomka/model/exercise_template.dart';
import 'package:diplomka/services/exercise_template_repository.dart';
import 'package:diplomka/screens/logs/exercise_widgets.dart';
import 'package:diplomka/widgets/confirm_delete_dialog.dart';
import 'package:diplomka/widgets/custom_glass_app_bar.dart';
import 'package:diplomka/widgets/foody_glass_buttons.dart';
import 'package:diplomka/widgets/glass_popup.dart';
import 'package:diplomka/widgets/logged_snackbar.dart';
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

  @override
  void initState() {
    super.initState();
    _exercise = widget.exercise;
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
    final rate = (_exercise.caloriesBurned / (_exercise.durationMinutes ?? 1)).round();

    return ProfileGradientScaffold(
      scroll: true,
      padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 0, AppSpacing.screen, AppSpacing.xl),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
        width: MediaQuery.of(context).size.width - (AppSpacing.screen * 2),
        child: Row(
          children: [
            Expanded(
              child: ProfilePrimaryButton(
                label: tr(LocaleKeys.exercise_log_btn),
                height: AppSizes.buttonHeight,
                onPressed: () => _showSnack(context, tr(LocaleKeys.exercise_log_btn)),
              ),
            ),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: ProfileOutlineButton(
                label: tr(LocaleKeys.exercise_save_log),
                height: AppSizes.buttonHeight,
                onPressed: () => _showSnack(context, tr(LocaleKeys.exercise_save_log)),
              ),
            ),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomGlassAppBar(
            title: tr(LocaleKeys.exercise_detail_title),
            leadingIconSize: AppSizes.iconLg,
            onBack: () => Navigator.of(context).maybePop(),
            actions: [
              CustomGlassIconButtonGroup(
                iconSize: AppSizes.iconLg,
                items: [
                  (icon: _exercise.isFavorite ? Icons.bookmark : CupertinoIcons.bookmark, onPressed: _toggleFavorite),
                  (icon: CupertinoIcons.ellipsis, onPressed: () => _showOptions(context)),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.l),
          Container(
            height: 118,
            padding: const EdgeInsets.all(AppSpacing.l),
            decoration: BoxDecoration(gradient: AppGradients.primary, borderRadius: BorderRadius.circular(AppRadii.l)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tr(LocaleKeys.exercise_activity), style: AppTextStyles.body14.copyWith(color: AppColors.onPrimary.withValues(alpha: 0.6))),
                const SizedBox(height: AppSpacing.xs),
                Text(_exercise.name, style: AppTextStyles.h2.copyWith(color: AppColors.onPrimary)),
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
                ),
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: ExerciseStatCard(
                  gradient: AppGradients.exerciseDuration,
                  icon: CupertinoIcons.clock,
                  label: tr(LocaleKeys.common_duration),
                  value: '${_exercise.durationMinutes ?? 0}',
                  unit: tr(LocaleKeys.common_min),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          ExerciseInfoCard(
            gradient: AppGradients.exerciseCaloriesAlt,
            icon: CupertinoIcons.graph_square,
            label: tr(LocaleKeys.exercise_calories_per_minute),
            value: '$rate',
            unit: tr(LocaleKeys.exercise_kcal_min),
          ),
          const SizedBox(height: AppSpacing.m),
          ExerciseCalculationCard(
            rate: '$rate ${tr(LocaleKeys.exercise_kcal_min)}',
            duration: '${_exercise.durationMinutes ?? 0} ${tr(LocaleKeys.common_min)}',
            total: '${_exercise.caloriesBurned.round()} ${tr(LocaleKeys.common_kcal)}',
          ),
          const SizedBox(height: AppSpacing.huge),
        ],
      ),
    );
  }

  void _showOptions(BuildContext context) {
    showGlassPopup(
      context: context,
      items: [
        GlassPopupItem(
          label: tr(LocaleKeys.common_share),
          icon: CupertinoIcons.share,
          onTap: () {
            Navigator.of(context).pop();
            _showSnack(context, tr(LocaleKeys.common_share));
          },
        ),
        GlassPopupItem(
          label: tr(LocaleKeys.common_delete),
          icon: CupertinoIcons.trash,
          color: AppColors.error,
          showDividerAbove: true,
          onTap: () {
            Navigator.of(context).pop();
            _handleDeleteExercise();
          },
        ),
      ],
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

  void _showSnack(BuildContext context, String message) {
    showSnackBar(context: context, message: message, type: SnackBarType.info);
  }
}
