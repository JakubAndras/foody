import 'package:diplomka/app_theme.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/model/ingredient.dart';
import 'package:diplomka/screens/meals/meal_components.dart';
import 'package:diplomka/screens/meals/meal_sheets.dart';
import 'package:diplomka/services/session_manager.dart';
import 'package:diplomka/widgets/edit_flow/edit_flow_widgets.dart';
import 'package:diplomka/widgets/custom_glass_app_bar.dart';
import 'package:diplomka/widgets/foody_glass_buttons.dart';
import 'package:diplomka/widgets/glass_popup.dart';
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
  late Ingredient _baseIngredient;
  late double _calories;
  late double _proteins;
  late double _carbs;
  late double _fats;
  late double _weight;
  late double _amount;
  late bool _autoSync;
  bool _showValidationError = false;

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
    _amount = _baseIngredient.amount;
    _autoSync = SessionManager.to.autoAdjustMacrosEnabled.value;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String get _amountLabel {
    final whole = _amount.truncate();
    final frac = _amount - whole;
    if (frac < 0.001) return '$whole';
    const fractionLabels = ['\u2013', '\u215B', '\u00BC', '\u2153', '\u215C', '\u00BD', '\u2154', '\u215D', '\u00BE', '\u215E'];
    const fractionValues = [0.0, 0.125, 0.25, 1 / 3, 0.375, 0.5, 2 / 3, 0.625, 0.75, 0.875];
    int bestIndex = 0;
    double bestDiff = double.infinity;
    for (int i = 1; i < fractionValues.length; i++) {
      final diff = (frac - fractionValues[i]).abs();
      if (diff < bestDiff) {
        bestDiff = diff;
        bestIndex = i;
      }
    }
    if (whole == 0) return fractionLabels[bestIndex];
    return '$whole${fractionLabels[bestIndex]}';
  }

  Ingredient? _buildIngredientFromInputs() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return null;
    if (_weight <= 0 || _calories < 0 || _proteins < 0 || _carbs < 0 || _fats < 0) return null;
    return _baseIngredient.copyWith(name: name, weight: _weight, amount: _amount, calories: _calories, proteins: _proteins, carbs: _carbs, fats: _fats);
  }

  String? get _validationMessage {
    if (_nameController.text.trim().isEmpty) return tr(LocaleKeys.ingredient_name_required);
    if (_weight <= 0) return tr(LocaleKeys.ingredient_valid_amount);
    if (_calories < 0 || _proteins < 0 || _carbs < 0 || _fats < 0) return tr(LocaleKeys.ingredient_no_negative);
    return null;
  }

  Future<void> _openNutrientEditor({required String label, required double currentValue, required void Function(double) onSave}) async {
    final result = await showModalBottomSheet<double>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.xl))),
      clipBehavior: Clip.antiAlias,
      isScrollControlled: true,
      builder: (context) => _NutrientEditorSheet(label: label, initialValue: currentValue),
    );
    if (result == null) return;
    onSave(result);
  }

  void _openCaloriesEditor() {
    _openNutrientEditor(
      label: tr(LocaleKeys.common_calories),
      currentValue: _calories,
      onSave: (value) {
        if (_autoSync && _calories > 0) {
          final ratio = value / _calories;
          setState(() {
            _proteins = (_proteins * ratio).roundToDouble();
            _carbs = (_carbs * ratio).roundToDouble();
            _fats = (_fats * ratio).roundToDouble();
            _calories = value;
          });
        } else {
          setState(() => _calories = value);
        }
      },
    );
  }

  void _openProteinEditor() {
    _openNutrientEditor(
      label: tr(LocaleKeys.common_protein),
      currentValue: _proteins,
      onSave: (value) => setState(() {
        _proteins = value;
        if (_autoSync) _recalcCalories();
      }),
    );
  }

  void _openCarbsEditor() {
    _openNutrientEditor(
      label: tr(LocaleKeys.common_carbs),
      currentValue: _carbs,
      onSave: (value) => setState(() {
        _carbs = value;
        if (_autoSync) _recalcCalories();
      }),
    );
  }

  void _openFatsEditor() {
    _openNutrientEditor(
      label: tr(LocaleKeys.common_fats),
      currentValue: _fats,
      onSave: (value) => setState(() {
        _fats = value;
        if (_autoSync) _recalcCalories();
      }),
    );
  }

  void _recalcCalories() {
    _calories = (_proteins * 4 + _carbs * 4 + _fats * 9).roundToDouble();
  }

  void _openWeightEditor() {
    _openNutrientEditor(
      label: tr(LocaleKeys.common_weight),
      currentValue: _weight,
      onSave: (value) {
        if (value <= 0) return;
        if (_weight > 0) {
          final ratio = value / _weight;
          setState(() {
            _calories = (_calories * ratio).roundToDouble();
            _proteins = (_proteins * ratio).roundToDouble();
            _carbs = (_carbs * ratio).roundToDouble();
            _fats = (_fats * ratio).roundToDouble();
            _weight = value;
          });
        } else {
          setState(() => _weight = value);
        }
      },
    );
  }

  void _openAmountPicker() {
    AmountPickerSheet.show(
      context,
      title: _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : tr(LocaleKeys.ingredient_amount),
      initialValue: _amount,
      onChanged: (value) {
        if (_amount == 0 || value == _amount) return;
        final scale = value / _amount;
        setState(() {
          _weight = (_weight * scale).roundToDouble();
          _calories = (_calories * scale).roundToDouble();
          _proteins = (_proteins * scale).roundToDouble();
          _carbs = (_carbs * scale).roundToDouble();
          _fats = (_fats * scale).roundToDouble();
          _amount = value;
        });
      },
    );
  }

  void _openMoreMenu() {
    showGlassPopup(
      context: context,
      items: [
        GlassPopupItem(
          label: tr(LocaleKeys.common_favorites),
          icon: Icons.bookmark_border,
          onTap: () => Navigator.of(context).pop(),
        ),
        if (widget.allowDelete)
          GlassPopupItem(
            label: tr(LocaleKeys.common_delete),
            icon: Icons.delete_outline,
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
    return LiquidGlassScope(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: AppColors.background,
        appBar: CustomGlassAppBar(
          title: "Ingredient",
          leadingIconSize: AppSizes.iconLg,
          horizontalPadding: AppSpacing.m,
          onBack: () => Navigator.of(context).maybePop(),
          actions: [
            CustomGlassIconButtonGroup(
              iconSize: AppSizes.iconLg,
              items: [
                (icon: CupertinoIcons.checkmark, onPressed: _handleDone),
                (icon: Icons.more_horiz, onPressed: _openMoreMenu),
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
                  const SizedBox(height: AppSpacing.m),
                  // Name field
                  TextField(
                    controller: _nameController,
                    style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: tr(LocaleKeys.ingredient_name),
                      hintStyle: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w700, color: AppColors.textTertiary),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.l),
                  // Calories card
                  GestureDetector(
                    onTap: _openCaloriesEditor,
                    child: CaloriesSummaryCard(label: tr(LocaleKeys.common_calories), value: _calories.toStringAsFixed(0), height: AppSizes.caloriesCardHeight),
                  ),
                  const SizedBox(height: AppSpacing.s),
                  // Macro cards row
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: _openProteinEditor,
                          child: MacroStatCard(
                            label: tr(LocaleKeys.common_protein),
                            value: '${_proteins.toStringAsFixed(0)}${tr(LocaleKeys.common_g)}',
                            icon: AppIcons.protein,
                            iconColor: AppColors.macroProtein,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s),
                      Expanded(
                        child: GestureDetector(
                          onTap: _openCarbsEditor,
                          child: MacroStatCard(
                            label: tr(LocaleKeys.common_carbs),
                            value: '${_carbs.toStringAsFixed(0)}${tr(LocaleKeys.common_g)}',
                            icon: AppIcons.carbs,
                            iconColor: AppColors.warningStrong,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s),
                      Expanded(
                        child: GestureDetector(
                          onTap: _openFatsEditor,
                          child: MacroStatCard(
                            label: tr(LocaleKeys.common_fats),
                            value: '${_fats.toStringAsFixed(0)}${tr(LocaleKeys.common_g)}',
                            icon: AppIcons.fats,
                            iconColor: AppColors.macroFats,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s),
                  GlassToggleRow(
                    title: tr(LocaleKeys.preferences_auto_adjust),
                    subtitle: tr(LocaleKeys.preferences_auto_adjust_desc),
                    isOn: _autoSync,
                    onChanged: (value) => setState(() => _autoSync = value),
                    showDivider: false,
                  ),
                  const SizedBox(height: AppSpacing.s),
                  // Amount card (weight + fraction)
                  Container(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.l, AppSpacing.m, AppSpacing.l, AppSpacing.m),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadii.l),
                      border: AppBorders.screenCard ?? Border.all(color: AppColors.separator),
                      boxShadow: AppShadows.screenCard,
                    ),
                    child: Column(
                      children: [
                        _RecordRow(
                          label: tr(LocaleKeys.common_weight),
                          value: '${_weight.toStringAsFixed(0)}${tr(LocaleKeys.common_g)}',
                          onTap: _openWeightEditor,
                          showChevron: true,
                        ),
                        const Divider(color: AppColors.separator, height: AppSpacing.m, thickness: AppSizes.dividerThin),
                        _RecordRow(label: tr(LocaleKeys.ingredient_amount), value: _amountLabel, onTap: _openAmountPicker, showChevron: true),
                      ],
                    ),
                  ),
                  if (_showValidationError && _validationMessage != null) ...[const SizedBox(height: AppSpacing.s), InlineErrorText(message: _validationMessage!)],
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RecordRow extends StatelessWidget {
  final String label;
  final String value;
  final bool showChevron;
  final VoidCallback? onTap;

  const _RecordRow({required this.label, required this.value, this.showChevron = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.s),
      child: SizedBox(
        height: AppSizes.editFormRowHeight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTextStyles.body16.copyWith(letterSpacing: -0.3125)),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(value, style: AppTextStyles.body16.copyWith(letterSpacing: -0.3125)),
                if (showChevron) ...[const SizedBox(width: AppSpacing.xs), const Icon(Icons.keyboard_arrow_down, size: AppSizes.iconSm, color: AppColors.textSecondary)],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NutrientEditorSheet extends StatefulWidget {
  final String label;
  final double initialValue;

  const _NutrientEditorSheet({required this.label, required this.initialValue});

  @override
  State<_NutrientEditorSheet> createState() => _NutrientEditorSheetState();
}

class _NutrientEditorSheetState extends State<_NutrientEditorSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final display = widget.initialValue == widget.initialValue.roundToDouble() ? widget.initialValue.toStringAsFixed(0) : widget.initialValue.toStringAsFixed(1);
    _controller = TextEditingController(text: display);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final parsed = double.tryParse(_controller.text.replaceAll(',', '.'));
    if (parsed != null && parsed >= 0) Navigator.of(context).pop(parsed);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(left: AppSpacing.l, right: AppSpacing.l, top: AppSpacing.l, bottom: AppSpacing.l + MediaQuery.viewInsetsOf(context).bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.label, style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: AppSpacing.m),
            TextField(
              controller: _controller,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                hintText: widget.label,
                hintStyle: AppTextStyles.body16.copyWith(color: AppColors.textTertiary),
                filled: true,
                fillColor: AppColors.surfaceMuted,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadii.m), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: AppSpacing.m),
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            Row(
              children: [
                Expanded(
                  child: FoodySecondaryButton(label: tr(LocaleKeys.common_cancel), onTap: () => Navigator.of(context).pop()),
                ),
                const SizedBox(width: AppSpacing.s),
                Expanded(
                  child: FoodyPrimaryButton(
                    label: tr(LocaleKeys.common_save),
                    gradient: LinearGradient(colors: [AppColors.primary, AppColors.primary]),
                    onTap: _submit,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
