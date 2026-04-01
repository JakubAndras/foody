import 'dart:async';

import 'package:diplomka/controller/dashboard_controller.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/model/nutrition_goals.dart';
import 'package:diplomka/services/nutrition_goals_service.dart';
import 'package:diplomka/services/selected_date_service.dart';
import 'package:diplomka/widgets/confirm_delete_dialog.dart';
import 'package:diplomka/widgets/custom_glass_app_bar.dart';
import 'package:diplomka/widgets/glass_popup.dart';
import 'package:diplomka/widgets/logged_snackbar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import 'package:diplomka/app_theme.dart';
import 'package:diplomka/services/ai_feature/ai_pipeline_service.dart';
import 'package:diplomka/utils/app_limits.dart';


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
  bool _isGenerating = false;
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

  double? _parseGoal(TextEditingController controller, {required int max}) {
    final value = double.tryParse(controller.text.trim().replaceAll(',', '.'));
    if (value == null || value <= 0) {
      return null;
    }
    return value.clamp(1, max.toDouble());
  }

  void _showMorePopup(BuildContext context) {
    showGlassPopup(
      context: context,
      items: [
        GlassPopupItem(
          label: tr(LocaleKeys.nutrition_goals_generate_ai_long),
          icon: CupertinoIcons.sparkles,
          onTap: () {
            Navigator.of(context).pop();
            _generateWithAi();
          },
        ),
        GlassPopupItem(
          label: tr(LocaleKeys.nutrition_goals_revert),
          icon: CupertinoIcons.arrow_counterclockwise,
          onTap: _isDirty
              ? () {
                  Navigator.of(context).pop();
                  _revertGoals();
                }
              : null,
        ),
      ],
    );
  }

  Future<void> _generateWithAi() async {
    setState(() => _isGenerating = true);
    try {
      final goals = await AiPipelineService.to.generateNutritionGoals();
      if (!mounted) return;
      if (goals == null) {
        showSnackBar(context: context, message: tr(LocaleKeys.nutrition_goals_ai_failed), type: SnackBarType.warning);
        return;
      }
      _setControllersFromGoals(goals);
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  void _revertGoals() {
    _setControllersFromGoals(_originalGoals);
  }

  Future<void> _handleBack() async {
    if (!_isDirty) {
      Navigator.of(context).pop();
      return;
    }
    final confirmed = await showConfirmationDialog(
      context: context,
      title: tr(LocaleKeys.common_unsaved_changes_message),
      primaryLabel: tr(LocaleKeys.common_save),
      secondaryLabel: tr(LocaleKeys.common_discard),
    );
    if (!mounted) return;
    if (confirmed == true) {
      _saveGoals();
    } else if (confirmed == false) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _saveGoals() async {
    final calorieGoal = _parseGoal(_calorieController, max: AppLimits.goalMaxCalories);
    final proteinGoal = _parseGoal(_proteinController, max: AppLimits.goalMaxMacro);
    final carbsGoal = _parseGoal(_carbsController, max: AppLimits.goalMaxMacro);
    final fatGoal = _parseGoal(_fatController, max: AppLimits.goalMaxMacro);

    if (calorieGoal == null || proteinGoal == null || carbsGoal == null || fatGoal == null) {
      showSnackBar(context: context, message: tr(LocaleKeys.nutrition_goals_invalid_values), type: SnackBarType.warning);
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
      showSnackBar(context: context, message: tr(LocaleKeys.nutrition_goals_updated));
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
    final bool enabled = !_isLoading && !_isSaving && !_isGenerating;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _handleBack();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: LiquidGlassScope(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 0, AppSpacing.screen, AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomGlassAppBar(
                  title: tr(LocaleKeys.nutrition_goals_title),
                  leadingIconSize: AppSizes.iconLg,
                  onBack: _handleBack,
                  actions: [
                    CustomGlassIconButtonGroup(
                      iconSize: AppSizes.iconLg,
                      items: [
                        (icon: CupertinoIcons.checkmark, onPressed: enabled && _isDirty ? _saveGoals : () {}),
                        (icon: CupertinoIcons.ellipsis, onPressed: enabled ? () => _showMorePopup(context) : () {}),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.m),
                _GoalRow(
                  label: tr(LocaleKeys.nutrition_goals_calorie_goal),
                  controller: _calorieController,
                  focusNode: _calorieFocus,
                  unit: tr(LocaleKeys.common_kcal),
                  color: AppColors.textPrimary,
                  icon: CupertinoIcons.flame,
                  enabled: enabled,
                  maxLength: 4,
                  shimmer: _isGenerating,
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
                  maxLength: 3,
                  shimmer: _isGenerating,
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
                  maxLength: 3,
                  shimmer: _isGenerating,
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
                  maxLength: 3,
                  shimmer: _isGenerating,
                ),
                if (_isLoading) ...[
                  const SizedBox(height: AppSpacing.m),
                  const LinearProgressIndicator(),
                ],
              ],
            ),
          ),
        ),
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
    this.maxLength,
    this.shimmer = false,
  });

  final String label;
  final TextEditingController controller;
  final FocusNode focusNode;
  final String unit;
  final Color color;
  final IconData icon;
  final bool enabled;
  final int? maxLength;
  final bool shimmer;

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
                  Stack(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: controller,
                              focusNode: focusNode,
                              enabled: enabled,
                              maxLength: maxLength,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isCollapsed: true,
                                hintText: '0',
                                counterText: '',
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
                      if (shimmer)
                        Positioned.fill(
                          child: _ShimmerOverlay(color: color),
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

class _ShimmerOverlay extends StatefulWidget {
  const _ShimmerOverlay({required this.color});

  final Color color;

  @override
  State<_ShimmerOverlay> createState() => _ShimmerOverlayState();
}

class _ShimmerOverlayState extends State<_ShimmerOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.s),
            gradient: LinearGradient(
              begin: Alignment(-1.0 + 2.0 * _controller.value, 0),
              end: Alignment(1.0 + 2.0 * _controller.value, 0),
              colors: [
                AppColors.surface,
                widget.color.withValues(alpha: 0.12),
                AppColors.surface,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
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
