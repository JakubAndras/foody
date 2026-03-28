import 'package:diplomka/app_theme.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/model/ingredient.dart';
import 'package:diplomka/screens/meals/meal_components.dart';
import 'package:diplomka/screens/meals/meal_sheets.dart';
import 'package:diplomka/services/session_manager.dart';
import 'package:diplomka/widgets/edit_flow/edit_flow_widgets.dart';
import 'package:diplomka/widgets/custom_glass_app_bar.dart';
import 'package:diplomka/widgets/glass_popup.dart';
import 'package:diplomka/widgets/confirm_delete_dialog.dart';
import 'package:diplomka/widgets/glass_toggle_row.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

class EditIngredientResult {
  final Ingredient? ingredient;
  final bool deleted;

  const EditIngredientResult._({this.ingredient, this.deleted = false});

  factory EditIngredientResult.updated(Ingredient ingredient) {
    return EditIngredientResult._(ingredient: ingredient);
  }

  factory EditIngredientResult.deleted() {
    return const EditIngredientResult._(deleted: true);
  }
}

class EditIngredientScreen extends StatefulWidget {
  final Ingredient ingredient;
  final bool allowDelete;

  const EditIngredientScreen({super.key, required this.ingredient, this.allowDelete = true});

  @override
  State<EditIngredientScreen> createState() => _EditIngredientScreenState();
}

class _EditIngredientScreenState extends State<EditIngredientScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _caloriesController;
  late final TextEditingController _proteinsController;
  late final TextEditingController _carbsController;
  late final TextEditingController _fatsController;
  late final TextEditingController _amountController;
  final FocusNode _amountFocusNode = FocusNode();
  final FocusNode _caloriesFocusNode = FocusNode();
  final FocusNode _proteinsFocusNode = FocusNode();
  final FocusNode _carbsFocusNode = FocusNode();
  final FocusNode _fatsFocusNode = FocusNode();
  late Ingredient _baseIngredient;
  late double _calories;
  late double _proteins;
  late double _carbs;
  late double _fats;
  late double _weight;
  late bool _autoSync;
  bool _showValidationError = false;
  bool _isSyncing = false;

  late List<_UnitOption> _unitOptions;
  late _UnitOption _selectedUnit;

  @override
  void initState() {
    super.initState();
    _baseIngredient = widget.ingredient;
    _nameController = TextEditingController(text: _baseIngredient.name);
    _calories = _baseIngredient.calories;
    _proteins = _baseIngredient.proteins;
    _carbs = _baseIngredient.carbs;
    _fats = _baseIngredient.fats;
    _weight = _baseIngredient.weight;
    _autoSync = SessionManager.to.autoAdjustMacrosEnabled.value;

    // Build unit options — per-unit weight derived from AI data
    final perUnit = _baseIngredient.amount > 0 ? _weight / _baseIngredient.amount : _weight;
    _unitOptions = [const _UnitOption('1 g', 1), const _UnitOption('100 g', 100), if (perUnit > 1 && perUnit != 100) _UnitOption('${perUnit.toStringAsFixed(0)} g', perUnit)];
    // Pick the best matching default unit
    _selectedUnit = _unitOptions.firstWhere((u) => u.grams == perUnit, orElse: () => _unitOptions.first);
    final amount = (_weight / _selectedUnit.grams).round();

    _amountController = TextEditingController(text: amount.toString());
    _caloriesController = TextEditingController(text: _calories.toStringAsFixed(0));
    _proteinsController = TextEditingController(text: _proteins.toStringAsFixed(0));
    _carbsController = TextEditingController(text: _carbs.toStringAsFixed(0));
    _fatsController = TextEditingController(text: _fats.toStringAsFixed(0));

    _amountController.addListener(_onAmountChanged);
    _caloriesController.addListener(_onCaloriesChanged);
    _proteinsController.addListener(_onProteinsChanged);
    _carbsController.addListener(_onCarbsChanged);
    _fatsController.addListener(_onFatsChanged);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountFocusNode.dispose();
    _caloriesFocusNode.dispose();
    _proteinsFocusNode.dispose();
    _carbsFocusNode.dispose();
    _fatsFocusNode.dispose();
    _amountController.dispose();
    _caloriesController.dispose();
    _proteinsController.dispose();
    _carbsController.dispose();
    _fatsController.dispose();
    super.dispose();
  }

  void _onCaloriesChanged() {
    if (_isSyncing) return;
    final value = double.tryParse(_caloriesController.text.replaceAll(',', '.'));
    if (value == null || value < 0) return;
    if (_autoSync && _calories > 0) {
      final ratio = value / _calories;
      _isSyncing = true;
      setState(() {
        _proteins = (_proteins * ratio).roundToDouble();
        _carbs = (_carbs * ratio).roundToDouble();
        _fats = (_fats * ratio).roundToDouble();
        _calories = value;
        _proteinsController.text = _proteins.toStringAsFixed(0);
        _carbsController.text = _carbs.toStringAsFixed(0);
        _fatsController.text = _fats.toStringAsFixed(0);
      });
      _isSyncing = false;
    } else {
      _calories = value;
    }
  }

  void _onProteinsChanged() {
    if (_isSyncing) return;
    final value = double.tryParse(_proteinsController.text.replaceAll(',', '.'));
    if (value == null || value < 0) return;
    _proteins = value;
    if (_autoSync) {
      _isSyncing = true;
      _recalcCalories();
      _caloriesController.text = _calories.toStringAsFixed(0);
      _isSyncing = false;
    }
  }

  void _onCarbsChanged() {
    if (_isSyncing) return;
    final value = double.tryParse(_carbsController.text.replaceAll(',', '.'));
    if (value == null || value < 0) return;
    _carbs = value;
    if (_autoSync) {
      _isSyncing = true;
      _recalcCalories();
      _caloriesController.text = _calories.toStringAsFixed(0);
      _isSyncing = false;
    }
  }

  void _onFatsChanged() {
    if (_isSyncing) return;
    final value = double.tryParse(_fatsController.text.replaceAll(',', '.'));
    if (value == null || value < 0) return;
    _fats = value;
    if (_autoSync) {
      _isSyncing = true;
      _recalcCalories();
      _caloriesController.text = _calories.toStringAsFixed(0);
      _isSyncing = false;
    }
  }

  void _onAmountChanged() {
    if (_isSyncing) return;
    final value = int.tryParse(_amountController.text);
    if (value == null || value <= 0) return;
    final newWeight = value * _selectedUnit.grams;
    if (_weight > 0) {
      final ratio = newWeight / _weight;
      _isSyncing = true;
      setState(() {
        _calories = (_calories * ratio).roundToDouble();
        _proteins = (_proteins * ratio).roundToDouble();
        _carbs = (_carbs * ratio).roundToDouble();
        _fats = (_fats * ratio).roundToDouble();
        _weight = newWeight;
        _caloriesController.text = _calories.toStringAsFixed(0);
        _proteinsController.text = _proteins.toStringAsFixed(0);
        _carbsController.text = _carbs.toStringAsFixed(0);
        _fatsController.text = _fats.toStringAsFixed(0);
      });
      _isSyncing = false;
    } else {
      _weight = newWeight;
    }
  }

  void _onUnitSelected(_UnitOption unit) {
    if (unit == _selectedUnit) return;
    setState(() {
      _selectedUnit = unit;
      final newAmount = (_weight / unit.grams).round().clamp(1, 999999);
      _isSyncing = true;
      _amountController.text = newAmount.toString();
      _isSyncing = false;
    });
  }

  void _openUnitPicker() {
    final labels = _unitOptions.map((u) => u.label).toList();
    final initialIndex = _unitOptions.indexOf(_selectedUnit).clamp(0, _unitOptions.length - 1);
    MealtimePickerSheet.show(context, options: labels, initialIndex: initialIndex, onChanged: (index) => _onUnitSelected(_unitOptions[index]));
  }

  Ingredient? _buildIngredientFromInputs() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return null;
    final calories = double.tryParse(_caloriesController.text.replaceAll(',', '.')) ?? _calories;
    final proteins = double.tryParse(_proteinsController.text.replaceAll(',', '.')) ?? _proteins;
    final carbs = double.tryParse(_carbsController.text.replaceAll(',', '.')) ?? _carbs;
    final fats = double.tryParse(_fatsController.text.replaceAll(',', '.')) ?? _fats;
    final amount = int.tryParse(_amountController.text) ?? 1;
    final weight = amount * _selectedUnit.grams;
    if (weight <= 0 || calories < 0 || proteins < 0 || carbs < 0 || fats < 0) return null;
    return _baseIngredient.copyWith(name: name, weight: weight, amount: amount.toDouble(), calories: calories, proteins: proteins, carbs: carbs, fats: fats);
  }

  String? get _validationMessage {
    if (_nameController.text.trim().isEmpty) return tr(LocaleKeys.ingredient_name_required);
    final amount = int.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) return tr(LocaleKeys.ingredient_valid_amount);
    if (_calories < 0 || _proteins < 0 || _carbs < 0 || _fats < 0) return tr(LocaleKeys.ingredient_no_negative);
    return null;
  }

  void _recalcCalories() {
    _calories = (_proteins * 4 + _carbs * 4 + _fats * 9).roundToDouble();
  }

  bool get _hasUnsavedChanges {
    if (_nameController.text.trim() != _baseIngredient.name) return true;
    if ((_calories - _baseIngredient.calories).abs() > 0.01) return true;
    if ((_proteins - _baseIngredient.proteins).abs() > 0.01) return true;
    if ((_carbs - _baseIngredient.carbs).abs() > 0.01) return true;
    if ((_fats - _baseIngredient.fats).abs() > 0.01) return true;
    final amount = int.tryParse(_amountController.text) ?? 1;
    final currentWeight = amount * _selectedUnit.grams;
    if ((currentWeight - _baseIngredient.weight).abs() > 0.01) return true;
    return false;
  }

  Future<void> _handleBack() async {
    if (!_hasUnsavedChanges) {
      Navigator.of(context).pop();
      return;
    }
    final confirmed = await showConfirmationDialog(
      context: context,
      title: tr(LocaleKeys.common_unsaved_changes_message),
      primaryLabel: tr(LocaleKeys.common_save),
      secondaryLabel: tr(LocaleKeys.common_discard),
    );
    if (!mounted || confirmed == null) return;
    if (confirmed) {
      _handleDone();
    } else {
      Navigator.of(context).pop();
    }
  }

  void _openMoreMenu() {
    showGlassPopup(
      context: context,
      items: [
        GlassPopupItem(label: tr(LocaleKeys.common_favorites), icon: CupertinoIcons.bookmark, onTap: () => Navigator.of(context).pop()),
        if (widget.allowDelete)
          GlassPopupItem(
            label: tr(LocaleKeys.common_delete),
            icon: CupertinoIcons.trash,
            color: AppColors.error,
            showDividerAbove: true,
            onTap: () {
              Navigator.of(context).pop();
              _confirmDelete();
            },
          ),
      ],
    );
  }

  Future<void> _confirmDelete() async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: EditConfirmSheet(
          title: tr(LocaleKeys.ingredient_delete_title),
          message: tr(LocaleKeys.ingredient_delete_message),
          confirmLabel: tr(LocaleKeys.common_delete),
          cancelLabel: tr(LocaleKeys.common_cancel),
          confirmColor: AppColors.error,
          onCancel: () => Navigator.of(context).pop(false),
          onConfirm: () => Navigator.of(context).pop(true),
        ),
      ),
    );

    if (result == true) {
      Get.back(result: EditIngredientResult.deleted());
    }
  }

  void _handleDone() {
    final updated = _buildIngredientFromInputs();
    if (updated == null) {
      setState(() => _showValidationError = true);
      return;
    }
    Get.back(result: EditIngredientResult.updated(updated));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _handleBack();
      },
      child: LiquidGlassScope(
        child: Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: AppColors.background,
          appBar: CustomGlassAppBar(
            title: "Ingredient",
            leadingIconSize: AppSizes.iconLg,
            horizontalPadding: AppSpacing.m,
            onBack: _handleBack,
            actions: [
              CustomGlassIconButtonGroup(
                iconSize: AppSizes.iconLg,
                items: [
                  (icon: CupertinoIcons.checkmark, onPressed: _handleDone),
                  (icon: CupertinoIcons.ellipsis, onPressed: _openMoreMenu)
                ],
              ),
            ],
          ),
          body: LiquidGlassBackground(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.edge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.xs),
                    // Name field
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: SessionManager.to.sectionHeaderPaddingEnabled.value ? AppSpacing.s : 0),
                      child: TextField(
                        controller: _nameController,
                        style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          hintText: tr(LocaleKeys.ingredient_name),
                          hintStyle: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w700, color: AppColors.textTertiary),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    // Calories card
                    CaloriesSummaryCard(
                      label: tr(LocaleKeys.common_calories),
                      value: _calories.toStringAsFixed(0),
                      height: AppSizes.caloriesCardHeight,
                      controller: _caloriesController,
                      focusNode: _caloriesFocusNode,
                    ),
                    const SizedBox(height: AppSpacing.s),
                    // Macro cards row
                    Row(
                      children: [
                        Expanded(
                          child: MacroStatCard(
                            label: tr(LocaleKeys.common_protein),
                            value: '${_proteins.toStringAsFixed(0)}${tr(LocaleKeys.common_g)}',
                            icon: AppIcons.protein,
                            iconColor: AppColors.macroProtein,
                            controller: _proteinsController,
                            focusNode: _proteinsFocusNode,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.s),
                        Expanded(
                          child: MacroStatCard(
                            label: tr(LocaleKeys.common_carbs),
                            value: '${_carbs.toStringAsFixed(0)}${tr(LocaleKeys.common_g)}',
                            icon: AppIcons.carbs,
                            iconColor: AppColors.warningStrong,
                            controller: _carbsController,
                            focusNode: _carbsFocusNode,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.s),
                        Expanded(
                          child: MacroStatCard(
                            label: tr(LocaleKeys.common_fats),
                            value: '${_fats.toStringAsFixed(0)}${tr(LocaleKeys.common_g)}',
                            icon: AppIcons.fats,
                            iconColor: AppColors.macroFats,
                            controller: _fatsController,
                            focusNode: _fatsFocusNode,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: SessionManager.to.sectionHeaderPaddingEnabled.value ? AppSpacing.s : 0),
                      child: GlassToggleRow(
                        title: tr(LocaleKeys.preferences_auto_adjust),
                        subtitle: tr(LocaleKeys.preferences_auto_adjust_desc),
                        isOn: _autoSync,
                        onChanged: (value) => setState(() => _autoSync = value),
                        showDivider: false,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    // Amount × Unit card
                    Row(
                      children: [
                        // Amount pill — same width as one MacroStatCard (1/3)
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => _amountFocusNode.requestFocus(),
                            child: Container(
                              height: AppSizes.editFormRowHeight,
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(AppRadii.pill),
                                border: Border.all(color: AppColors.outline),
                                color: AppColors.surface,
                              ),
                              child: Center(
                                child: IntrinsicWidth(
                                  child: TextField(
                                    controller: _amountController,
                                    focusNode: _amountFocusNode,
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.body16,
                                    decoration: const InputDecoration(isDense: true, border: InputBorder.none, contentPadding: EdgeInsets.zero),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.s),
                        // Unit pill — takes remaining 2/3
                        Expanded(
                          flex: 2,
                          child: GestureDetector(
                            onTap: _openUnitPicker,
                            child: Container(
                              height: AppSizes.editFormRowHeight,
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(AppRadii.pill),
                                border: Border.all(color: AppColors.outline),
                                color: AppColors.surface,
                              ),
                              child: Row(
                                children: [
                                  Text(_selectedUnit.label, style: AppTextStyles.body16),
                                  const Spacer(),
                                  const Icon(CupertinoIcons.chevron_down, size: AppSizes.iconSm, color: AppColors.textTertiary),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_showValidationError && _validationMessage != null) ...[const SizedBox(height: AppSpacing.s), InlineErrorText(message: _validationMessage!)],
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _UnitOption {
  final String label;
  final double grams;

  const _UnitOption(this.label, this.grams);
}
