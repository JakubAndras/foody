import 'package:diplomka/app_theme.dart';
import 'package:diplomka/controller/day_record_controller.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/model/ingredient.dart';
import 'package:diplomka/screens/meals/meal_components.dart';
import 'package:diplomka/screens/meals/meal_sheets.dart';
import 'package:diplomka/services/session_manager.dart';
import 'package:diplomka/widgets/edit_flow/edit_flow_widgets.dart';
import 'package:diplomka/widgets/custom_glass_app_bar.dart';
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
  late bool _isFavorite;
  late String _lastCaloriesText;
  late String _lastProteinsText;
  late String _lastCarbsText;
  late String _lastFatsText;
  late String _lastAmountText;
  double _savedProteinRatio = 0;
  double _savedCarbsRatio = 0;
  double _savedFatsRatio = 0;
  double _savedCalPerGram = 0;
  double _savedProPerGram = 0;
  double _savedCarbPerGram = 0;
  double _savedFatPerGram = 0;
  double _calorieOffset = 0;

  late List<_UnitOption> _unitOptions;
  late _UnitOption _selectedUnit;
  late final double _initialDisplayWeight;

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
    _isFavorite = _baseIngredient.isFavorite;

    if (_calories > 0) {
      _savedProteinRatio = _proteins / _calories;
      _savedCarbsRatio = _carbs / _calories;
      _savedFatsRatio = _fats / _calories;
    }
    _calorieOffset = _calories - (_proteins * 4 + _carbs * 4 + _fats * 9);
    if (_weight > 0) {
      _savedCalPerGram = _calories / _weight;
      _savedProPerGram = _proteins / _weight;
      _savedCarbPerGram = _carbs / _weight;
      _savedFatPerGram = _fats / _weight;
    }

    // Build unit options — per-unit weight derived from AI data
    final perUnit = _baseIngredient.amount > 0 ? _weight / _baseIngredient.amount : _weight;
    _unitOptions = [const _UnitOption('1 g', 1), const _UnitOption('100 g', 100), if (perUnit > 1 && perUnit != 100) _UnitOption('${perUnit.toStringAsFixed(0)} g', perUnit)];
    // Pick the best matching default unit
    _selectedUnit = _unitOptions.firstWhere((u) => u.grams == perUnit, orElse: () => _unitOptions.first);
    final amount = (_weight / _selectedUnit.grams).round();
    _initialDisplayWeight = amount * _selectedUnit.grams;

    _amountController = TextEditingController(text: amount.toString());
    _caloriesController = TextEditingController(text: _calories.toStringAsFixed(0));
    _proteinsController = TextEditingController(text: _proteins.toStringAsFixed(0));
    _carbsController = TextEditingController(text: _carbs.toStringAsFixed(0));
    _fatsController = TextEditingController(text: _fats.toStringAsFixed(0));

    _lastAmountText = _amountController.text;
    _lastCaloriesText = _caloriesController.text;
    _lastProteinsText = _proteinsController.text;
    _lastCarbsText = _carbsController.text;
    _lastFatsText = _fatsController.text;

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
    if (_caloriesController.text == _lastCaloriesText) return;
    _lastCaloriesText = _caloriesController.text;
    final value = double.tryParse(_caloriesController.text.replaceAll(',', '.'));
    if (value == null || value < 0) return;
    if (value == _calories) return;
    if (_autoSync) {
      double newP;
      double newC;
      double newF;
      if (_calories > 0) {
        final ratio = value / _calories;
        newP = (_proteins * ratio).roundToDouble();
        newC = (_carbs * ratio).roundToDouble();
        newF = (_fats * ratio).roundToDouble();
        if (newP == 0 && _savedProteinRatio > 0) newP = (value * _savedProteinRatio).roundToDouble();
        if (newC == 0 && _savedCarbsRatio > 0) newC = (value * _savedCarbsRatio).roundToDouble();
        if (newF == 0 && _savedFatsRatio > 0) newF = (value * _savedFatsRatio).roundToDouble();
      } else if (_savedProteinRatio > 0 || _savedCarbsRatio > 0 || _savedFatsRatio > 0) {
        newP = (value * _savedProteinRatio).roundToDouble();
        newC = (value * _savedCarbsRatio).roundToDouble();
        newF = (value * _savedFatsRatio).roundToDouble();
      } else {
        _calories = value;
        _recomputeCalorieOffset();
        _updateSavedPerGram(weight: _weight, cal: _calories, pro: _proteins, carb: _carbs, fat: _fats);
        return;
      }
      _isSyncing = true;
      setState(() {
        _proteins = newP;
        _carbs = newC;
        _fats = newF;
        _calories = value;
        _proteinsController.text = _proteins.toStringAsFixed(0);
        _carbsController.text = _carbs.toStringAsFixed(0);
        _fatsController.text = _fats.toStringAsFixed(0);
        _lastProteinsText = _proteinsController.text;
        _lastCarbsText = _carbsController.text;
        _lastFatsText = _fatsController.text;
      });
      _isSyncing = false;
      _recomputeCalorieOffset();
      _updateSavedRatios(cal: _calories, pro: _proteins, carb: _carbs, fat: _fats);
      _updateSavedPerGram(weight: _weight, cal: _calories, pro: _proteins, carb: _carbs, fat: _fats);
    } else {
      _calories = value;
      _recomputeCalorieOffset();
      _updateSavedRatios(cal: _calories, pro: _proteins, carb: _carbs, fat: _fats);
      _updateSavedPerGram(weight: _weight, cal: _calories, pro: _proteins, carb: _carbs, fat: _fats);
    }
  }

  void _onProteinsChanged() {
    if (_isSyncing) return;
    if (_proteinsController.text == _lastProteinsText) return;
    _lastProteinsText = _proteinsController.text;
    final value = double.tryParse(_proteinsController.text.replaceAll(',', '.'));
    if (value == null || value < 0) return;
    if (value == _proteins) return;
    _proteins = value;
    if (_autoSync) {
      _isSyncing = true;
      _recalcCalories();
      _caloriesController.text = _calories.toStringAsFixed(0);
      _lastCaloriesText = _caloriesController.text;
      _isSyncing = false;
    }
    _updateSavedRatios(cal: _calories, pro: _proteins, carb: _carbs, fat: _fats);
    _updateSavedPerGram(weight: _weight, cal: _calories, pro: _proteins, carb: _carbs, fat: _fats);
  }

  void _onCarbsChanged() {
    if (_isSyncing) return;
    if (_carbsController.text == _lastCarbsText) return;
    _lastCarbsText = _carbsController.text;
    final value = double.tryParse(_carbsController.text.replaceAll(',', '.'));
    if (value == null || value < 0) return;
    if (value == _carbs) return;
    _carbs = value;
    if (_autoSync) {
      _isSyncing = true;
      _recalcCalories();
      _caloriesController.text = _calories.toStringAsFixed(0);
      _lastCaloriesText = _caloriesController.text;
      _isSyncing = false;
    }
    _updateSavedRatios(cal: _calories, pro: _proteins, carb: _carbs, fat: _fats);
    _updateSavedPerGram(weight: _weight, cal: _calories, pro: _proteins, carb: _carbs, fat: _fats);
  }

  void _onFatsChanged() {
    if (_isSyncing) return;
    if (_fatsController.text == _lastFatsText) return;
    _lastFatsText = _fatsController.text;
    final value = double.tryParse(_fatsController.text.replaceAll(',', '.'));
    if (value == null || value < 0) return;
    if (value == _fats) return;
    _fats = value;
    if (_autoSync) {
      _isSyncing = true;
      _recalcCalories();
      _caloriesController.text = _calories.toStringAsFixed(0);
      _lastCaloriesText = _caloriesController.text;
      _isSyncing = false;
    }
    _updateSavedRatios(cal: _calories, pro: _proteins, carb: _carbs, fat: _fats);
    _updateSavedPerGram(weight: _weight, cal: _calories, pro: _proteins, carb: _carbs, fat: _fats);
  }

  void _onAmountChanged() {
    if (_isSyncing) return;
    if (_amountController.text == _lastAmountText) return;
    _lastAmountText = _amountController.text;
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
        _lastCaloriesText = _caloriesController.text;
        _lastProteinsText = _proteinsController.text;
        _lastCarbsText = _carbsController.text;
        _lastFatsText = _fatsController.text;
      });
      _isSyncing = false;
    } else if (_savedCalPerGram > 0 || _savedProPerGram > 0 || _savedCarbPerGram > 0 || _savedFatPerGram > 0) {
      _isSyncing = true;
      setState(() {
        _calories = (newWeight * _savedCalPerGram).roundToDouble();
        _proteins = (newWeight * _savedProPerGram).roundToDouble();
        _carbs = (newWeight * _savedCarbPerGram).roundToDouble();
        _fats = (newWeight * _savedFatPerGram).roundToDouble();
        _weight = newWeight;
        _caloriesController.text = _calories.toStringAsFixed(0);
        _proteinsController.text = _proteins.toStringAsFixed(0);
        _carbsController.text = _carbs.toStringAsFixed(0);
        _fatsController.text = _fats.toStringAsFixed(0);
        _lastCaloriesText = _caloriesController.text;
        _lastProteinsText = _proteinsController.text;
        _lastCarbsText = _carbsController.text;
        _lastFatsText = _fatsController.text;
      });
      _isSyncing = false;
    } else {
      _weight = newWeight;
    }
    _recomputeCalorieOffset();
    _updateSavedRatios(cal: _calories, pro: _proteins, carb: _carbs, fat: _fats);
    _updateSavedPerGram(weight: _weight, cal: _calories, pro: _proteins, carb: _carbs, fat: _fats);
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
    MealtimePickerSheet.show(context, title: tr(LocaleKeys.ingredient_amount), options: labels, initialIndex: initialIndex, onChanged: (index) => _onUnitSelected(_unitOptions[index]));
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
    return _baseIngredient.copyWith(name: name, weight: weight, amount: amount.toDouble(), calories: calories, proteins: proteins, carbs: carbs, fats: fats, isFavorite: _isFavorite);
  }

  String? get _validationMessage {
    if (_nameController.text.trim().isEmpty) return tr(LocaleKeys.ingredient_name_required);
    final amount = int.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) return tr(LocaleKeys.ingredient_valid_amount);
    if (_calories < 0 || _proteins < 0 || _carbs < 0 || _fats < 0) return tr(LocaleKeys.ingredient_no_negative);
    return null;
  }

  void _recalcCalories() {
    final raw = _proteins * 4 + _carbs * 4 + _fats * 9 + _calorieOffset;
    _calories = (raw < 0 ? 0.0 : raw).roundToDouble();
  }

  void _recomputeCalorieOffset() {
    _calorieOffset = _calories - (_proteins * 4 + _carbs * 4 + _fats * 9);
  }

  void _updateSavedRatios({required double cal, required double pro, required double carb, required double fat}) {
    if (cal <= 0) return;
    if (pro > 0) _savedProteinRatio = pro / cal;
    if (carb > 0) _savedCarbsRatio = carb / cal;
    if (fat > 0) _savedFatsRatio = fat / cal;
  }

  void _updateSavedPerGram({required double weight, required double cal, required double pro, required double carb, required double fat}) {
    if (weight <= 0) return;
    if (cal > 0) _savedCalPerGram = cal / weight;
    if (pro > 0) _savedProPerGram = pro / weight;
    if (carb > 0) _savedCarbPerGram = carb / weight;
    if (fat > 0) _savedFatPerGram = fat / weight;
  }

  bool get _hasUnsavedChanges {
    if (_nameController.text.trim() != _baseIngredient.name) return true;
    if ((_calories - _baseIngredient.calories).abs() > 0.01) return true;
    if ((_proteins - _baseIngredient.proteins).abs() > 0.01) return true;
    if ((_carbs - _baseIngredient.carbs).abs() > 0.01) return true;
    if ((_fats - _baseIngredient.fats).abs() > 0.01) return true;
    final amount = int.tryParse(_amountController.text) ?? 1;
    final currentWeight = amount * _selectedUnit.grams;
    if ((currentWeight - _initialDisplayWeight).abs() > 0.01) return true;
    return false;
  }

  Future<void> _handleBack() async {
    final favoriteChanged = _isFavorite != _baseIngredient.isFavorite;
    if (!_hasUnsavedChanges && !favoriteChanged) {
      Navigator.of(context).pop();
      return;
    }
    if (!_hasUnsavedChanges && favoriteChanged) {
      Navigator.of(context).pop(EditIngredientResult.updated(_baseIngredient.copyWith(isFavorite: _isFavorite)));
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

  void _toggleFavorite() {
    final next = !_isFavorite;
    setState(() => _isFavorite = next);
    if (_baseIngredient.id != null && _baseIngredient.mealId != null) {
      DayRecordController.to.setIngredientFavorite(ingredient: _baseIngredient, isFavorite: next);
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showConfirmationDialog(
      context: context,
      title: tr(LocaleKeys.ingredient_delete_title),
      subtitle: tr(LocaleKeys.ingredient_delete_message),
      primaryLabel: tr(LocaleKeys.common_delete),
      secondaryLabel: tr(LocaleKeys.common_cancel),
      isDestructive: true,
    );
    if (confirmed != true) return;
    Get.back(result: EditIngredientResult.deleted());
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
            leadingIconSize: AppSizes.iconLg,
            horizontalPadding: AppSpacing.m,
            onBack: _handleBack,
            actions: [
              CustomGlassIconButtonGroup(
                iconSize: AppSizes.iconLg,
                items: [
                  (icon: CupertinoIcons.checkmark, onPressed: _handleDone),
                  (icon: _isFavorite ? CupertinoIcons.bookmark_fill : CupertinoIcons.bookmark, onPressed: _toggleFavorite),
                  if (widget.allowDelete) (icon: CupertinoIcons.trash, onPressed: _confirmDelete),
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
                                border: AppBorders.screenCard,
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
                                border: AppBorders.screenCard,
                                color: AppColors.surface,
                              ),
                              child: Row(
                                children: [
                                  Text(_selectedUnit.label, style: AppTextStyles.body16),
                                  const Spacer(),
                                  Icon(CupertinoIcons.chevron_down, size: AppSizes.iconSm, color: AppColors.textTertiary),
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
