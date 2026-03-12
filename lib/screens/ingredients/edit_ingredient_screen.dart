import 'package:diplomka/app_theme.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/model/ingredient.dart';
import 'package:diplomka/screens/meals/meal_components.dart';
import 'package:diplomka/widgets/edit_flow/edit_flow_widgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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

  const EditIngredientScreen({
    super.key,
    required this.ingredient,
    this.allowDelete = true,
  });

  @override
  State<EditIngredientScreen> createState() => _EditIngredientScreenState();
}

class _EditIngredientScreenState extends State<EditIngredientScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _amountController;
  late final TextEditingController _caloriesController;
  late final TextEditingController _proteinController;
  late final TextEditingController _carbsController;
  late final TextEditingController _fatController;
  late Ingredient _baseIngredient;
  int _selectedMeasurement = 1;
  bool _showValidationError = false;

  @override
  void initState() {
    super.initState();
    _baseIngredient = widget.ingredient;
    _nameController = TextEditingController(text: _baseIngredient.name);
    _amountController = TextEditingController(text: _formatNumber(_baseIngredient.weight));
    _caloriesController = TextEditingController(text: _formatNumber(_baseIngredient.calories));
    _proteinController = TextEditingController(text: _formatNumber(_baseIngredient.proteins));
    _carbsController = TextEditingController(text: _formatNumber(_baseIngredient.carbs));
    _fatController = TextEditingController(text: _formatNumber(_baseIngredient.fats));
    _registerInputListeners();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  void _registerInputListeners() {
    final controllers = [
      _nameController,
      _amountController,
      _caloriesController,
      _proteinController,
      _carbsController,
      _fatController,
    ];
    for (final controller in controllers) {
      controller.addListener(_handleInputChanged);
    }
  }

  void _handleInputChanged() {
    if (!mounted) return;
    setState(() {});
  }

  String _formatNumber(double value) {
    final asInt = value.toInt();
    if ((value - asInt).abs() < 0.000001) {
      return '$asInt';
    }
    final fixed = value.toStringAsFixed(2);
    return fixed.replaceFirst(RegExp(r'\.?0+$'), '');
  }

  double? _parseNumber(String text) {
    final normalized = text.trim().replaceAll(',', '.');
    if (normalized.isEmpty) return null;
    final match = RegExp(r'[-+]?\d*\.?\d+').firstMatch(normalized);
    if (match == null) return null;
    return double.tryParse(match.group(0)!);
  }

  Ingredient? _buildIngredientFromInputs() {
    final name = _nameController.text.trim();
    final weight = _parseNumber(_amountController.text);
    final calories = _parseNumber(_caloriesController.text);
    final protein = _parseNumber(_proteinController.text);
    final carbs = _parseNumber(_carbsController.text);
    final fat = _parseNumber(_fatController.text);

    if (name.isEmpty || weight == null || calories == null || protein == null || carbs == null || fat == null) {
      return null;
    }

    if (weight <= 0 || calories < 0 || protein < 0 || carbs < 0 || fat < 0) {
      return null;
    }

    return _baseIngredient.copyWith(
      name: name,
      weight: weight,
      calories: calories,
      proteins: protein,
      carbs: carbs,
      fats: fat,
    );
  }

  bool get _isValid => _buildIngredientFromInputs() != null;

  String? get _validationMessage {
    if (_nameController.text.trim().isEmpty) {
      return tr(LocaleKeys.ingredient_name_required);
    }
    final weight = _parseNumber(_amountController.text);
    if (weight == null || weight <= 0) {
      return tr(LocaleKeys.ingredient_valid_amount);
    }
    final calories = _parseNumber(_caloriesController.text);
    final protein = _parseNumber(_proteinController.text);
    final carbs = _parseNumber(_carbsController.text);
    final fat = _parseNumber(_fatController.text);
    if (calories == null || protein == null || carbs == null || fat == null) {
      return tr(LocaleKeys.ingredient_valid_numbers);
    }
    if (calories < 0 || protein < 0 || carbs < 0 || fat < 0) {
      return tr(LocaleKeys.ingredient_no_negative);
    }
    return null;
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
          confirmColor: AppColors.destructive,
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
    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: AppSizes.editTopBarHeight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.edge),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _CircleIconButton(
                      icon: Icons.chevron_left,
                      onTap: () => Navigator.of(context).maybePop(),
                    ),
                    Text(tr(LocaleKeys.ingredient_title), style: AppTextStyles.navTitle18),
                    if (widget.allowDelete)
                      _CircleIconButton(
                        icon: Icons.delete_outline,
                        onTap: _confirmDelete,
                      )
                    else
                      const SizedBox(width: AppSizes.backButtonSize),
                  ],
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: AppSpacing.xs),
                          TextField(
                            controller: _nameController,
                            textCapitalization: TextCapitalization.words,
                            style: AppTextStyles.headline36,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                              hintText: tr(LocaleKeys.ingredient_name),
                              hintStyle: AppTextStyles.headline36.copyWith(color: AppColors.textTertiary),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.l),
                          Text(tr(LocaleKeys.ingredient_measurement), style: AppTextStyles.formLabel16),
                          const SizedBox(height: AppSpacing.s),
                          MeasurementChips(
                            options: [tr(LocaleKeys.ingredient_fraction), tr(LocaleKeys.common_g), tr(LocaleKeys.ingredient_small), tr(LocaleKeys.ingredient_medium), tr(LocaleKeys.ingredient_large)],
                            selectedIndex: _selectedMeasurement,
                            onChanged: (index) => setState(() => _selectedMeasurement = index),
                          ),
                          const SizedBox(height: AppSpacing.l),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(tr(LocaleKeys.ingredient_amount), style: AppTextStyles.formLabel16),
                              _AmountInputField(
                                controller: _amountController,
                                onChanged: (_) {},
                              ),
                            ],
                          ),
                          if (_showValidationError && _validationMessage != null)
                            Padding(
                              padding: const EdgeInsets.only(top: AppSpacing.s),
                              child: InlineErrorText(message: _validationMessage!),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.l),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.edge),
                      child: _EditableCaloriesCard(
                        controller: _caloriesController,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.m),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.edge),
                      child: Row(
                        children: [
                          Expanded(
                            child: _EditableMacroCard(
                              label: tr(LocaleKeys.common_protein),
                              icon: AppIcons.protein,
                              iconColor: AppColors.macroProtein,
                              controller: _proteinController,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s),
                          Expanded(
                            child: _EditableMacroCard(
                              label: tr(LocaleKeys.common_carbs),
                              icon: AppIcons.carbs,
                              iconColor: AppColors.macroCarbsStrong,
                              controller: _carbsController,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s),
                          Expanded(
                            child: _EditableMacroCard(
                              label: tr(LocaleKeys.common_fats),
                              icon: AppIcons.fats,
                              iconColor: AppColors.macroFats,
                              controller: _fatController,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.edge,
            AppSpacing.s,
            AppSpacing.edge,
            AppSpacing.bottom + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: GradientPillButton(
            label: tr(LocaleKeys.common_done),
            gradient: AppGradients.primary,
            height: AppSizes.buttonHeightCompact,
            onTap: _isValid ? _handleDone : null,
          ),
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.pill),
      child: Ink(
        width: AppSizes.backButtonSize,
        height: AppSizes.backButtonSize,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: Border.all(color: AppColors.outline, width: AppSizes.dividerThin),
        ),
        child: Icon(icon, size: AppSizes.iconMd, color: AppColors.textPrimary),
      ),
    );
  }
}

class _AmountInputField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  const _AmountInputField({
    required this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppSizes.amountFieldWidth,
      height: AppSizes.chipHeight,
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textAlign: TextAlign.center,
        style: AppTextStyles.formValue16,
        onChanged: onChanged,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.zero,
          filled: true,
          fillColor: AppColors.surface,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
            borderSide: const BorderSide(color: AppColors.surfaceMuted, width: AppSizes.dividerThin),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
            borderSide: const BorderSide(color: AppColors.primary, width: AppSizes.dividerThin),
          ),
        ),
      ),
    );
  }
}

class _EditableCaloriesCard extends StatelessWidget {
  final TextEditingController controller;

  const _EditableCaloriesCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.caloriesCardHeight,
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        boxShadow: AppShadows.cardSmall,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tr(LocaleKeys.common_calories), style: AppTextStyles.body14.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: AppSpacing.xs),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: AppTextStyles.stat48.copyWith(color: AppColors.primary),
                    decoration: const InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: Text(
                    tr(LocaleKeys.common_kcal),
                    style: AppTextStyles.body14.copyWith(color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EditableMacroCard extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final Color iconColor;

  const _EditableMacroCard({
    required this.label,
    required this.controller,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: AppSizes.macroCardSize,
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        boxShadow: AppShadows.cardSmall,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: AppSizes.iconMd, color: iconColor),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption12.copyWith(color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: AppTextStyles.title24.copyWith(color: AppColors.primary),
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              Text(
                tr(LocaleKeys.common_g),
                style: AppTextStyles.caption12.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
