import 'dart:async';

import 'package:diplomka/controller/dashboard_controller.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/model/nutrition_goals.dart';
import 'package:diplomka/services/nutrition_goals_service.dart';
import 'package:diplomka/services/selected_date_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:diplomka/app_theme.dart';
import 'package:diplomka/screens/profile/profile_widgets.dart';
import 'package:diplomka/widgets/foody_glass_buttons.dart';
import 'package:diplomka/widgets/keyboard_action_scaffold.dart';

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

  final FocusNode _calorieFocus = FocusNode();
  final FocusNode _proteinFocus = FocusNode();
  final FocusNode _carbsFocus = FocusNode();
  final FocusNode _fatFocus = FocusNode();

  bool _isSaving = false;
  bool _isLoading = true;
  bool _isDirty = false;
  late final DateTime _selectedDate;
  late NutritionGoals _originalGoals;

  @override
  void initState() {
    super.initState();
    _selectedDate = SelectedDateService.to.selectedDate.value;
    _originalGoals = _nutritionGoalsService.goalsForDate(_selectedDate);
    _setControllersFromGoals(_originalGoals);
    unawaited(_refreshGoals());

    for (final c in [_calorieController, _proteinController, _carbsController, _fatController]) {
      c.addListener(_checkDirty);
    }
  }

  void _checkDirty() {
    final dirty = _calorieController.text != _originalGoals.calorieGoal.toStringAsFixed(0) ||
        _proteinController.text != _originalGoals.proteinGoal.toStringAsFixed(0) ||
        _carbsController.text != _originalGoals.carbsGoal.toStringAsFixed(0) ||
        _fatController.text != _originalGoals.fatGoal.toStringAsFixed(0);
    if (dirty != _isDirty) {
      setState(() => _isDirty = dirty);
    }
  }

  @override
  void dispose() {
    for (final c in [_calorieController, _proteinController, _carbsController, _fatController]) {
      c.removeListener(_checkDirty);
    }
    _calorieFocus.dispose();
    _proteinFocus.dispose();
    _carbsFocus.dispose();
    _fatFocus.dispose();
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
      _originalGoals = _nutritionGoalsService.goalsForDate(_selectedDate);
      _setControllersFromGoals(_originalGoals);
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

  void _revertGoals() {
    _setControllersFromGoals(_originalGoals);
  }

  void _generateWithAi() {
    // TODO: implement AI goal generation
  }

  Future<void> _saveGoals() async {
    final calorieGoal = _parseGoal(_calorieController);
    final proteinGoal = _parseGoal(_proteinController);
    final carbsGoal = _parseGoal(_carbsController);
    final fatGoal = _parseGoal(_fatController);

    if (calorieGoal == null || proteinGoal == null || carbsGoal == null || fatGoal == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr(LocaleKeys.nutrition_goals_invalid_values))),
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
        SnackBar(content: Text(tr(LocaleKeys.nutrition_goals_updated))),
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
    final bool enabled = !_isLoading && !_isSaving;

    return KeyboardActionScaffold(
      focusNodes: [_calorieFocus, _proteinFocus, _carbsFocus, _fatFocus],
      onRevert: _revertGoals,
      onSave: _saveGoals,
      actionsEnabled: enabled,
      saveLabel: _isSaving ? tr(LocaleKeys.common_saving) : null,
      bottomBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.screen, AppSpacing.s, AppSpacing.screen, AppSpacing.s),
          child: Row(
            children: [
              Expanded(
                child: FoodySecondaryButton(
                  label: _isDirty ? tr(LocaleKeys.nutrition_goals_generate_ai) : tr(LocaleKeys.nutrition_goals_generate_ai_long),
                  icon: Icons.auto_awesome,
                  onTap: enabled ? _generateWithAi : null,
                  height: AppSizes.buttonHeight,
                ),
              ),
              if (_isDirty) ...[
                const SizedBox(width: AppSpacing.s),
                Expanded(
                  child: FoodyPrimaryButton(
                    label: _isSaving ? tr(LocaleKeys.common_saving) : tr(LocaleKeys.common_save),
                    onTap: enabled ? _saveGoals : null,
                    height: AppSizes.buttonHeight,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 0, AppSpacing.screen, AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfileTopBar(title: tr(LocaleKeys.nutrition_goals_title), onBack: () => Get.back()),
            const SizedBox(height: AppSpacing.l),
            _GoalRow(
              label: tr(LocaleKeys.nutrition_goals_calorie_goal),
              controller: _calorieController,
              focusNode: _calorieFocus,
              unit: tr(LocaleKeys.common_kcal),
              color: AppColors.textPrimary,
              icon: Icons.local_fire_department_outlined,
              enabled: enabled,
            ),
            const SizedBox(height: AppSpacing.m),
            _GoalRow(
              label: tr(LocaleKeys.nutrition_goals_protein_goal),
              controller: _proteinController,
              focusNode: _proteinFocus,
              unit: tr(LocaleKeys.common_g),
              color: AppColors.error,
              icon: AppIcons.protein,
              enabled: enabled,
            ),
            const SizedBox(height: AppSpacing.m),
            _GoalRow(
              label: tr(LocaleKeys.nutrition_goals_carb_goal),
              controller: _carbsController,
              focusNode: _carbsFocus,
              unit: tr(LocaleKeys.common_g),
              color: AppColors.macroCarbs,
              icon: AppIcons.carbs,
              enabled: enabled,
            ),
            const SizedBox(height: AppSpacing.m),
            _GoalRow(
              label: tr(LocaleKeys.nutrition_goals_fat_goal),
              controller: _fatController,
              focusNode: _fatFocus,
              unit: tr(LocaleKeys.common_g),
              color: AppColors.info,
              icon: AppIcons.fats,
              enabled: enabled,
            ),
            if (_isLoading) ...[
              const SizedBox(height: AppSpacing.m),
              const LinearProgressIndicator(),
            ],
          ],
        ),
      ),
    );
  }
}

class _GoalRow extends StatelessWidget {
  const _GoalRow({
    required this.label,
    required this.controller,
    required this.focusNode,
    required this.unit,
    required this.color,
    required this.icon,
    required this.enabled,
  });

  final String label;
  final TextEditingController controller;
  final FocusNode focusNode;
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
                borderRadius: BorderRadius.circular(AppRadii.m),
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
                          focusNode: focusNode,
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
