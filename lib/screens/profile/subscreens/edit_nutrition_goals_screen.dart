import 'dart:async';

import 'package:diplomka/controller/dashboard_controller.dart';
import 'package:diplomka/model/nutrition_goals.dart';
import 'package:diplomka/services/nutrition_goals_service.dart';
import 'package:diplomka/services/selected_date_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:diplomka/app_theme.dart';
import 'package:diplomka/screens/profile/profile_widgets.dart';

class EditNutritionGoalsScreen extends StatefulWidget {
  const EditNutritionGoalsScreen({super.key});

  @override
  State<EditNutritionGoalsScreen> createState() => _EditNutritionGoalsScreenState();
}

class _EditNutritionGoalsScreenState extends State<EditNutritionGoalsScreen> {
  final NutritionGoalsService _nutritionGoalsService = NutritionGoalsService.to;
  final TextEditingController _calorieController = TextEditingController();
  final TextEditingController _proteinController = TextEditingController();
  final TextEditingController _carbsController = TextEditingController();
  final TextEditingController _fatController = TextEditingController();

  bool _isSaving = false;
  bool _isLoading = true;
  late final DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = SelectedDateService.to.selectedDate.value;
    _setControllersFromGoals(_nutritionGoalsService.goalsForDate(_selectedDate));
    unawaited(_refreshGoals());
  }

  @override
  void dispose() {
    _calorieController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  Future<void> _refreshGoals() async {
    try {
      await _nutritionGoalsService.refreshForDate(_selectedDate);
      if (!mounted) return;
      _setControllersFromGoals(_nutritionGoalsService.goalsForDate(_selectedDate));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _setControllersFromGoals(NutritionGoals goals) {
    _calorieController.text = goals.calorieGoal.toStringAsFixed(0);
    _proteinController.text = goals.proteinGoal.toStringAsFixed(0);
    _carbsController.text = goals.carbsGoal.toStringAsFixed(0);
    _fatController.text = goals.fatGoal.toStringAsFixed(0);
  }

  double? _parseGoal(TextEditingController controller) {
    final value = double.tryParse(controller.text.trim().replaceAll(',', '.'));
    if (value == null || value <= 0) {
      return null;
    }
    return value;
  }

  Future<void> _saveGoals() async {
    final calorieGoal = _parseGoal(_calorieController);
    final proteinGoal = _parseGoal(_proteinController);
    final carbsGoal = _parseGoal(_carbsController);
    final fatGoal = _parseGoal(_fatController);

    if (calorieGoal == null || proteinGoal == null || carbsGoal == null || fatGoal == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid positive values for all goals.')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _nutritionGoalsService.saveGoalsEffectiveFromDate(
        effectiveDate: _selectedDate,
        goals: NutritionGoals(
          calorieGoal: calorieGoal,
          proteinGoal: proteinGoal,
          carbsGoal: carbsGoal,
          fatGoal: fatGoal,
        ),
      );
      DashboardController.to.refresh();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nutrition goals updated')),
      );
      Get.back();
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProfileGradientScaffold(
      scroll: true,
      padding: const EdgeInsets.fromLTRB(AppSpacing.screen, AppSpacing.l, AppSpacing.screen, AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileBackButton(onPressed: () => Get.back()),
          const SizedBox(height: AppSpacing.m),
          Text('Edit nutrition goals', style: AppTextStyles.h1.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.l),
          _GoalRow(
            label: 'Calorie goal',
            controller: _calorieController,
            unit: 'kcal',
            color: AppColors.primarySoft,
            icon: Icons.local_fire_department_outlined,
            enabled: !_isLoading && !_isSaving,
          ),
          const SizedBox(height: AppSpacing.m),
          _GoalRow(
            label: 'Protein goal',
            controller: _proteinController,
            unit: 'g',
            color: AppColors.error,
            icon: Icons.fitness_center_outlined,
            enabled: !_isLoading && !_isSaving,
          ),
          const SizedBox(height: AppSpacing.m),
          _GoalRow(
            label: 'Carb goal',
            controller: _carbsController,
            unit: 'g',
            color: AppColors.macroCarbs,
            icon: Icons.grain,
            enabled: !_isLoading && !_isSaving,
          ),
          const SizedBox(height: AppSpacing.m),
          _GoalRow(
            label: 'Fat goal',
            controller: _fatController,
            unit: 'g',
            color: AppColors.info,
            icon: Icons.water_drop_outlined,
            enabled: !_isLoading && !_isSaving,
          ),
          if (_isLoading) ...[
            const SizedBox(height: AppSpacing.m),
            const LinearProgressIndicator(),
          ],
          const SizedBox(height: AppSpacing.l),
          ProfilePrimaryButton(
            label: _isSaving ? 'Saving...' : 'Save goals',
            onPressed: _isSaving || _isLoading ? null : _saveGoals,
            leading: const Icon(Icons.check, color: AppColors.onPrimary, size: AppSizes.iconMd),
            height: AppSizes.buttonHeightCompact,
            shadow: AppShadows.control,
          ),
        ],
      ),
    );
  }
}

class _GoalRow extends StatelessWidget {
  const _GoalRow({
    required this.label,
    required this.controller,
    required this.unit,
    required this.color,
    required this.icon,
    required this.enabled,
  });

  final String label;
  final TextEditingController controller;
  final String unit;
  final Color color;
  final IconData icon;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSizes.goalRowHeight,
      child: Row(
        children: [
          _MacroIcon(color: color, icon: icon),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Container(
              height: AppSizes.goalRowHeight,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadii.md2),
                border: Border.all(color: AppColors.outline),
              ),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTextStyles.body13.copyWith(color: AppColors.textTertiary)),
                  const SizedBox(height: AppSpacing.xxs),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller,
                          enabled: enabled,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isCollapsed: true,
                            hintText: '0',
                          ),
                          style: AppTextStyles.body16.copyWith(fontSize: 19, fontWeight: FontWeight.w700),
                        ),
                      ),
                      Text(
                        unit,
                        style: AppTextStyles.body14.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MacroIcon extends StatelessWidget {
  const _MacroIcon({required this.color, required this.icon});

  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppSizes.macroIconSize,
      height: AppSizes.macroIconSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 3),
            ),
          ),
          Icon(icon, size: AppSizes.iconMd, color: color),
        ],
      ),
    );
  }
}
