import 'package:diplomka/app_theme.dart';
import 'package:diplomka/state/dashboard_notifier.dart';
import 'package:diplomka/state/day_record_notifier.dart';
import 'package:diplomka/widgets/logged_snackbar.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/model/exercise.dart';
import 'package:diplomka/screens/logs/exercise_widgets.dart';
import 'package:diplomka/services/selected_date_service.dart';
import 'package:diplomka/widgets/custom_glass_app_bar.dart';
import 'package:diplomka/utils/app_limits.dart';
import 'package:diplomka/widgets/duration_picker_sheet.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:diplomka/screens/profile/profile_widgets.dart';

class AddExerciseScreen extends ConsumerStatefulWidget {
  const AddExerciseScreen({super.key, this.initialName, this.initialDurationMinutes, this.initialCaloriesTotal});

  final String? initialName;
  final int? initialDurationMinutes;
  final int? initialCaloriesTotal;

  @override
  ConsumerState<AddExerciseScreen> createState() => _AddExerciseScreenState();
}

class _AddExerciseScreenState extends ConsumerState<AddExerciseScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _caloriesController;
  late int _durationMinutes;
  bool _isSaving = false;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _caloriesController = TextEditingController(text: widget.initialCaloriesTotal != null ? '${widget.initialCaloriesTotal}' : '');
    _durationMinutes = widget.initialDurationMinutes ?? 0;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    super.dispose();
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

  Future<void> _saveExercise() async {
    final String exerciseName = _nameController.text.trim();

    if (exerciseName.isEmpty) {
      showSnackBar(context: context, message: tr(LocaleKeys.exercise_name_required), type: SnackBarType.warning);
      return;
    }

    final double caloriesBurned = double.tryParse(_caloriesController.text.trim()) ?? 0;
    if (caloriesBurned <= 0) {
      showSnackBar(context: context, message: tr(LocaleKeys.exercise_invalid_calories), type: SnackBarType.warning);
      return;
    }

    setState(() => _isSaving = true);

    try {
      final selectedDate = ref.read(selectedDateProvider);
      final now = DateTime.now();
      final exercise = Exercise(
        name: exerciseName,
        timestamp: DateTime(selectedDate.year, selectedDate.month, selectedDate.day, now.hour, now.minute, now.second, now.millisecond, now.microsecond),
        durationMinutes: _durationMinutes > 0 ? _durationMinutes : null,
        caloriesBurned: caloriesBurned,
        isFavorite: _isFavorite,
      );

      await ref.read(dayRecordProvider.notifier).saveExerciseForDate(date: selectedDate, exerciseToSave: exercise);
      ref.read(dailyRecordProvider.notifier).refresh();

      if (!mounted) return;
      showSnackBar(context: context, message: tr(LocaleKeys.exercise_exercise_added));
      Navigator.of(context).maybePop();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
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
            title: tr(LocaleKeys.exercise_add_title),
            leadingIconSize: AppSizes.iconLg,
            onBack: () => Navigator.of(context).maybePop(),
            actions: [
              CustomGlassIconButtonGroup(
                iconSize: AppSizes.iconLg,
                items: [
                  (icon: CupertinoIcons.checkmark, onPressed: _isSaving ? () {} : _saveExercise),
                  (icon: _isFavorite ? CupertinoIcons.heart_fill : CupertinoIcons.heart, onPressed: () => setState(() => _isFavorite = !_isFavorite)),
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
                  maxLength: AppLimits.aiInputMaxLength,
                  style: AppTextStyles.h2.copyWith(color: AppColors.onPrimary),
                  decoration: InputDecoration(
                    hintText: tr(LocaleKeys.common_name),
                    hintStyle: AppTextStyles.h2.copyWith(color: AppColors.onPrimary.withValues(alpha: 0.6)),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    counterText: '',
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
                  value: '',
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
}
