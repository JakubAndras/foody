import 'package:diplomka/app_theme.dart';
import 'package:diplomka/screens/logs/exercise_widgets.dart';
import 'package:flutter/material.dart';

enum ExerciseTrackingMode { total, perMinute }

class AddExerciseScreen extends StatefulWidget {
  const AddExerciseScreen({
    super.key,
    this.initialName,
    this.initialDurationMinutes,
    this.initialCaloriesTotal,
    this.initialCaloriesPerMinute,
    this.initialTrackingMode,
  });

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
    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.l, AppSpacing.m, AppSpacing.l, AppSpacing.s),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _CircleButton(
                    icon: Icons.chevron_left,
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                  Text('Add Exercise', style: AppTextStyles.title18Tight),
                  _CircleButton(
                    icon: Icons.bookmark_border,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(AppSpacing.l, AppSpacing.s, AppSpacing.l, AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Exercise Name', style: AppTextStyles.body14.copyWith(fontWeight: FontWeight.w500)),
                  const SizedBox(height: AppSpacing.xs),
                  _TextInput(
                    controller: _nameController,
                    hintText: 'Exercise name',
                  ),
                  const SizedBox(height: AppSpacing.l),
                  Text('How would you like to track calories?', style: AppTextStyles.body14.copyWith(fontWeight: FontWeight.w500)),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Expanded(
                        child: ExerciseTrackingOptionCard(
                          selected: _mode == ExerciseTrackingMode.total,
                          gradient: AppGradients.exerciseCalories,
                          icon: Icons.local_fire_department,
                          label: 'Total Calories',
                          subtitle: 'Enter total burned',
                          onTap: () => setState(() => _mode = ExerciseTrackingMode.total),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.m),
                      Expanded(
                        child: ExerciseTrackingOptionCard(
                          selected: _mode == ExerciseTrackingMode.perMinute,
                          gradient: AppGradients.exerciseCaloriesAlt,
                          icon: Icons.trending_up,
                          label: 'Per Minute',
                          subtitle: 'Kcal/min + duration',
                          onTap: () => setState(() => _mode = ExerciseTrackingMode.perMinute),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.l),
                  if (_mode == ExerciseTrackingMode.total) ...[
                    Text('Total Calories Burned', style: AppTextStyles.body14.copyWith(fontWeight: FontWeight.w500)),
                    const SizedBox(height: AppSpacing.xs),
                    _InputCard(
                      controller: _totalController,
                      label: 'Calories',
                      unit: 'kcal',
                      gradient: AppGradients.exerciseCalories,
                      icon: Icons.local_fire_department,
                    ),
                    const SizedBox(height: AppSpacing.s),
                    Text(
                      'Enter the total amount of calories burned',
                      style: AppTextStyles.label12.copyWith(color: AppColors.textTertiary),
                    ),
                  ] else ...[
                    Text('Calories Per Minute', style: AppTextStyles.body14.copyWith(fontWeight: FontWeight.w500)),
                    const SizedBox(height: AppSpacing.xs),
                    _InputCard(
                      controller: _rateController,
                      label: 'kcal/min',
                      unit: 'kcal/min',
                      gradient: AppGradients.exerciseCaloriesAlt,
                      icon: Icons.trending_up,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: AppSpacing.m),
                    Text('Duration', style: AppTextStyles.body14.copyWith(fontWeight: FontWeight.w500)),
                    const SizedBox(height: AppSpacing.xs),
                    _InputCard(
                      controller: _durationController,
                      label: 'min',
                      unit: 'min',
                      gradient: AppGradients.exerciseDuration,
                      icon: Icons.schedule,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: AppSpacing.m),
                    Text('Total Calories Burned', style: AppTextStyles.body14.copyWith(fontWeight: FontWeight.w500)),
                    const SizedBox(height: AppSpacing.xs),
                    ExerciseTotalSummaryCard(value: '$_calculatedTotal'),
                  ],
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.l, AppSpacing.s, AppSpacing.l, AppSpacing.l),
            child: GestureDetector(
              onTap: () => _showSnack(context, 'Exercise added'),
              child: Container(
                height: AppSizes.buttonHeightCompact,
                decoration: BoxDecoration(
                  gradient: AppGradients.primary,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                  boxShadow: AppShadows.button,
                ),
                child: Center(
                  child: Text(
                    'Add Exercise',
                    style: AppTextStyles.button18.copyWith(color: AppColors.onPrimary),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _TextInput extends StatelessWidget {
  const _TextInput({
    required this.controller,
    required this.hintText,
  });

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
  const _InputCard({
    required this.controller,
    required this.label,
    required this.unit,
    required this.gradient,
    required this.icon,
    this.onChanged,
  });

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
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
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

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: AppSizes.backButtonSize,
        height: AppSizes.backButtonSize,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: Border.all(color: AppColors.outline, width: 1),
          boxShadow: AppShadows.control,
        ),
        child: Icon(icon, color: AppColors.textPrimary, size: AppSizes.iconMd),
      ),
    );
  }
}
