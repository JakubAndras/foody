import 'package:diplomka/app_theme.dart';
import 'package:diplomka/controller/dashboard_controller.dart';
import 'package:diplomka/controller/day_record_controller.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/model/exercise.dart';
import 'package:diplomka/screens/logs/exercise_widgets.dart';
import 'package:diplomka/services/selected_date_service.dart';
import 'package:diplomka/widgets/custom_glass_app_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

enum ExerciseTrackingMode { total, perMinute }

class AddExerciseScreen extends StatefulWidget {
  const AddExerciseScreen({super.key, this.initialName, this.initialDurationMinutes, this.initialCaloriesTotal, this.initialCaloriesPerMinute, this.initialTrackingMode});

  final String? initialName;
  final int? initialDurationMinutes;
  final int? initialCaloriesTotal;
  final double? initialCaloriesPerMinute;
  final ExerciseTrackingMode? initialTrackingMode;

  @override
  State<AddExerciseScreen> createState() => _AddExerciseScreenState();
}

class _AddExerciseScreenState extends State<AddExerciseScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _totalController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  ExerciseTrackingMode _mode = ExerciseTrackingMode.total;
  bool _isSaving = false;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _mode = _resolveInitialMode();
    if (widget.initialName != null && widget.initialName!.isNotEmpty) {
      _nameController.text = widget.initialName!;
    } else {
      _nameController.text = 'Morning Run';
    }

    if (widget.initialCaloriesTotal != null) {
      _totalController.text = widget.initialCaloriesTotal.toString();
    }
    if (widget.initialCaloriesPerMinute != null) {
      _rateController.text = _formatNumber(widget.initialCaloriesPerMinute!);
    }
    if (widget.initialDurationMinutes != null) {
      _durationController.text = widget.initialDurationMinutes.toString();
    }

    if (_totalController.text.isEmpty) {
      _totalController.text = '123';
    }
    if (_rateController.text.isEmpty) {
      _rateController.text = '10';
    }
    if (_durationController.text.isEmpty) {
      _durationController.text = '30';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _totalController.dispose();
    _rateController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  int get _calculatedTotal {
    final rate = double.tryParse(_rateController.text) ?? 0;
    final duration = int.tryParse(_durationController.text) ?? 0;
    return (rate * duration).round();
  }

  ExerciseTrackingMode _resolveInitialMode() {
    if (widget.initialTrackingMode != null) {
      return widget.initialTrackingMode!;
    }
    if (widget.initialCaloriesTotal != null) {
      return ExerciseTrackingMode.total;
    }
    if (widget.initialCaloriesPerMinute != null) {
      return ExerciseTrackingMode.perMinute;
    }
    return ExerciseTrackingMode.total;
  }

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    return LiquidGlassScope(
      child: Scaffold(
        backgroundColor: AppColors.background,
        extendBodyBehindAppBar: true,
        appBar: CustomGlassAppBar(
          title: tr(LocaleKeys.exercise_add_title),
          onBack: () => Navigator.of(context).maybePop(),
          actions: [
            CustomGlassIconButton(icon: _isFavorite ? Icons.bookmark : Icons.bookmark_border, iconSize: AppSizes.iconMd, onPressed: () => setState(() => _isFavorite = !_isFavorite)),
          ],
        ),
        body: LiquidGlassBackground(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.l, AppSpacing.s, AppSpacing.l, AppSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tr(LocaleKeys.exercise_exercise_name), style: AppTextStyles.body14.copyWith(fontWeight: FontWeight.w500)),
                      const SizedBox(height: AppSpacing.xs),
                      _TextInput(controller: _nameController, hintText: tr(LocaleKeys.exercise_name_hint)),
                      const SizedBox(height: AppSpacing.l),
                      Text(tr(LocaleKeys.exercise_track_question), style: AppTextStyles.body14.copyWith(fontWeight: FontWeight.w500)),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          Expanded(
                            child: ExerciseTrackingOptionCard(
                              selected: _mode == ExerciseTrackingMode.total,
                              gradient: AppGradients.exerciseCalories,
                              icon: Icons.local_fire_department,
                              label: tr(LocaleKeys.exercise_total_calories),
                              subtitle: tr(LocaleKeys.exercise_enter_total),
                              onTap: () => setState(() => _mode = ExerciseTrackingMode.total),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.m),
                          Expanded(
                            child: ExerciseTrackingOptionCard(
                              selected: _mode == ExerciseTrackingMode.perMinute,
                              gradient: AppGradients.exerciseCaloriesAlt,
                              icon: Icons.trending_up,
                              label: tr(LocaleKeys.exercise_per_minute),
                              subtitle: tr(LocaleKeys.exercise_kcal_min_desc),
                              onTap: () => setState(() => _mode = ExerciseTrackingMode.perMinute),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.l),
                      if (_mode == ExerciseTrackingMode.total) ...[
                        Text(tr(LocaleKeys.exercise_total_burned), style: AppTextStyles.body14.copyWith(fontWeight: FontWeight.w500)),
                        const SizedBox(height: AppSpacing.xs),
                        _InputCard(
                          controller: _totalController,
                          label: tr(LocaleKeys.common_calories),
                          unit: tr(LocaleKeys.common_kcal),
                          gradient: AppGradients.exerciseCalories,
                          icon: Icons.local_fire_department,
                        ),
                        const SizedBox(height: AppSpacing.s),
                        Text(tr(LocaleKeys.exercise_enter_total), style: AppTextStyles.label12.copyWith(color: AppColors.textTertiary)),
                      ] else ...[
                        Text(tr(LocaleKeys.exercise_calories_per_minute), style: AppTextStyles.body14.copyWith(fontWeight: FontWeight.w500)),
                        const SizedBox(height: AppSpacing.xs),
                        _InputCard(
                          controller: _rateController,
                          label: tr(LocaleKeys.exercise_kcal_min),
                          unit: tr(LocaleKeys.exercise_kcal_min),
                          gradient: AppGradients.exerciseCaloriesAlt,
                          icon: Icons.trending_up,
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: AppSpacing.m),
                        Text(tr(LocaleKeys.exercise_duration_label), style: AppTextStyles.body14.copyWith(fontWeight: FontWeight.w500)),
                        const SizedBox(height: AppSpacing.xs),
                        _InputCard(
                          controller: _durationController,
                          label: tr(LocaleKeys.common_min),
                          unit: tr(LocaleKeys.common_min),
                          gradient: AppGradients.exerciseDuration,
                          icon: Icons.schedule,
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: AppSpacing.m),
                        Text(tr(LocaleKeys.exercise_total_burned), style: AppTextStyles.body14.copyWith(fontWeight: FontWeight.w500)),
                        const SizedBox(height: AppSpacing.xs),
                        ExerciseTotalSummaryCard(value: '$_calculatedTotal'),
                      ],
                    ],
                  ),
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
                  child: GestureDetector(
                    onTap: _isSaving ? null : _saveExercise,
                    child: Container(
                      height: AppSizes.buttonHeightCompact,
                      decoration: BoxDecoration(gradient: AppGradients.primary, borderRadius: BorderRadius.circular(AppRadii.pill), boxShadow: AppShadows.button),
                      child: Center(
                        child: Text(
                          _isSaving ? tr(LocaleKeys.common_saving) : tr(LocaleKeys.exercise_add_title),
                          style: AppTextStyles.button18.copyWith(color: AppColors.onPrimary),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveExercise() async {
    final String exerciseName = _nameController.text.trim().isEmpty ? tr(LocaleKeys.common_exercise) : _nameController.text.trim();
    final int? durationMinutes = int.tryParse(_durationController.text.trim());
    final double caloriesBurned = _mode == ExerciseTrackingMode.total
        ? (double.tryParse(_totalController.text.trim()) ?? 0)
        : (double.tryParse(_rateController.text.trim()) ?? 0) * (durationMinutes ?? 0);

    if (caloriesBurned <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr(LocaleKeys.exercise_invalid_calories))));
      return;
    }

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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr(LocaleKeys.exercise_exercise_added))));
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
      height: AppSizes.exerciseInputHeight,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.outline, width: 1),
        boxShadow: AppShadows.cardSmall,
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: AppTextStyles.body16.copyWith(color: AppColors.textTertiary),
        ),
        style: AppTextStyles.body16,
      ),
    );
  }
}

class _InputCard extends StatelessWidget {
  const _InputCard({required this.controller, required this.label, required this.unit, required this.gradient, required this.icon, this.onChanged});

  final TextEditingController controller;
  final String label;
  final String unit;
  final Gradient gradient;
  final IconData icon;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.exerciseInputHeight,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.outline, width: 1),
        boxShadow: AppShadows.cardSmall,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(gradient: gradient, borderRadius: BorderRadius.circular(AppRadii.md)),
            child: Icon(icon, color: AppColors.onPrimary, size: AppSizes.iconSm),
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: onChanged,
              style: AppTextStyles.title24.copyWith(color: AppColors.textDisabled),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: label,
                hintStyle: AppTextStyles.body14.copyWith(color: AppColors.textTertiary),
              ),
            ),
          ),
          Text(unit, style: AppTextStyles.body14.copyWith(color: AppColors.textTertiary)),
        ],
      ),
    );
  }
}
