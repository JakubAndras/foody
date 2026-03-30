import 'package:diplomka/app_theme.dart';
import 'package:diplomka/controller/dashboard_controller.dart';
import 'package:diplomka/controller/day_record_controller.dart';
import 'package:diplomka/widgets/logged_snackbar.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/model/exercise.dart';
import 'package:diplomka/services/selected_date_service.dart';
import 'package:diplomka/widgets/custom_glass_app_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:diplomka/screens/profile/profile_widgets.dart';

class AddExerciseScreen extends StatefulWidget {
  const AddExerciseScreen({super.key, this.initialName, this.initialDurationMinutes, this.initialCaloriesTotal});

  final String? initialName;
  final int? initialDurationMinutes;
  final int? initialCaloriesTotal;

  @override
  State<AddExerciseScreen> createState() => _AddExerciseScreenState();
}

class _AddExerciseScreenState extends State<AddExerciseScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _totalController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  bool _isSaving = false;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialName != null && widget.initialName!.isNotEmpty) {
      _nameController.text = widget.initialName!;
    }
    if (widget.initialCaloriesTotal != null) {
      _totalController.text = widget.initialCaloriesTotal.toString();
    }
    if (widget.initialDurationMinutes != null) {
      _durationController.text = widget.initialDurationMinutes.toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _totalController.dispose();
    _durationController.dispose();
    super.dispose();
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
                  (icon: _isFavorite ? CupertinoIcons.bookmark_fill : CupertinoIcons.bookmark, onPressed: () => setState(() => _isFavorite = !_isFavorite)),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.l),
          Text(tr(LocaleKeys.exercise_exercise_name), style: AppTextStyles.body14.copyWith(fontWeight: FontWeight.w500)),
          const SizedBox(height: AppSpacing.xs),
          _TextInput(controller: _nameController, hintText: tr(LocaleKeys.exercise_name_hint)),
          const SizedBox(height: AppSpacing.l),
          Text(tr(LocaleKeys.exercise_total_burned), style: AppTextStyles.body14.copyWith(fontWeight: FontWeight.w500)),
          const SizedBox(height: AppSpacing.xs),
          _InputCard(
            controller: _totalController,
            label: tr(LocaleKeys.common_calories),
            unit: tr(LocaleKeys.common_kcal),
            gradient: AppGradients.exerciseCalories,
            icon: CupertinoIcons.flame,
          ),
          const SizedBox(height: AppSpacing.l),
          Text(tr(LocaleKeys.exercise_duration_label), style: AppTextStyles.body14.copyWith(fontWeight: FontWeight.w500)),
          const SizedBox(height: AppSpacing.xs),
          _InputCard(
            controller: _durationController,
            label: tr(LocaleKeys.common_min),
            unit: tr(LocaleKeys.common_min),
            gradient: AppGradients.exerciseDuration,
            icon: CupertinoIcons.clock,
          ),
          const SizedBox(height: AppSpacing.huge),
        ],
      ),
    );
  }

  Future<void> _saveExercise() async {
    final String exerciseName = _nameController.text.trim();

    if (exerciseName.isEmpty) {
      showSnackBar(context: context, message: tr(LocaleKeys.exercise_name_required), type: SnackBarType.warning);
      return;
    }

    final double caloriesBurned = double.tryParse(_totalController.text.trim()) ?? 0;
    if (caloriesBurned <= 0) {
      showSnackBar(context: context, message: tr(LocaleKeys.exercise_invalid_calories), type: SnackBarType.warning);
      return;
    }

    final int? durationMinutes = int.tryParse(_durationController.text.trim());

    setState(() {
      _isSaving = true;
    });

    try {
      final selectedDate = SelectedDateService.to.selectedDate.value;
      final exercise = Exercise(
        name: exerciseName,
        timestamp: _applyDateToTime(DateTime.now(), selectedDate),
        durationMinutes: durationMinutes,
        caloriesBurned: caloriesBurned,
        isFavorite: _isFavorite,
      );

      await DayRecordController.to.saveExerciseForDate(date: selectedDate, exerciseToSave: exercise);
      DashboardController.to.refresh();

      if (!mounted) return;
      showSnackBar(context: context, message: tr(LocaleKeys.exercise_exercise_added));
      Navigator.of(context).maybePop();
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  DateTime _applyDateToTime(DateTime source, DateTime targetDate) {
    return DateTime(targetDate.year, targetDate.month, targetDate.day, source.hour, source.minute, source.second, source.millisecond, source.microsecond);
  }
}

class _TextInput extends StatelessWidget {
  const _TextInput({required this.controller, required this.hintText});

  final TextEditingController controller;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.scanInputHeight,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.l),
        border: Border.all(color: AppColors.outline, width: 1),
      ),
      child: Center(
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            border: InputBorder.none,
            isCollapsed: true,
            contentPadding: EdgeInsets.zero,
            hintText: hintText,
            hintStyle: AppTextStyles.body16.copyWith(color: AppColors.textTertiary),
          ),
          style: AppTextStyles.body16,
        ),
      ),
    );
  }
}

class _InputCard extends StatelessWidget {
  const _InputCard({required this.controller, required this.label, required this.unit, required this.gradient, required this.icon});

  final TextEditingController controller;
  final String label;
  final String unit;
  final Gradient gradient;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.scanInputHeight,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.l),
        border: Border.all(color: AppColors.outline, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(gradient: gradient, borderRadius: BorderRadius.circular(AppRadii.m)),
            child: Icon(icon, color: AppColors.onPrimary, size: AppSizes.iconSm),
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Center(
              child: TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: AppTextStyles.body16,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isCollapsed: true,
                  contentPadding: EdgeInsets.zero,
                  hintText: label,
                  hintStyle: AppTextStyles.body16.copyWith(color: AppColors.textTertiary),
                ),
              ),
            ),
          ),
          Text(unit, style: AppTextStyles.body14.copyWith(color: AppColors.textTertiary)),
        ],
      ),
    );
  }
}
