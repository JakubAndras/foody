import 'package:diplomka/app_theme.dart';
import 'package:diplomka/model/ingredient.dart';
import 'package:diplomka/screens/meals/meal_components.dart';
import 'package:diplomka/widgets/edit_flow/edit_flow_widgets.dart';
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
  late final TextEditingController _amountController;
  late Ingredient _baseIngredient;
  int _selectedMeasurement = 1;
  double _currentWeight = 0;

  @override
  void initState() {
    super.initState();
    _baseIngredient = widget.ingredient;
    _currentWeight = _baseIngredient.weight > 0 ? _baseIngredient.weight : 0;
    _amountController = TextEditingController(text: _formatAmount(_currentWeight));
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  String _formatAmount(double value) {
    if (value <= 0) return '';
    return '${value.toStringAsFixed(0)}g';
  }

  double _parseAmount(String text) {
    final match = RegExp(r'\d+(?:\.\d+)?').firstMatch(text);
    if (match == null) return 0;
    return double.tryParse(match.group(0)!) ?? 0;
  }

  Ingredient _scaledIngredient() {
    final baseWeight = _baseIngredient.weight <= 0 ? 1 : _baseIngredient.weight;
    final factor = _currentWeight / baseWeight;
    return _baseIngredient.copyWith(
      weight: _currentWeight,
      calories: _baseIngredient.calories * factor,
      proteins: _baseIngredient.proteins * factor,
      carbs: _baseIngredient.carbs * factor,
      fats: _baseIngredient.fats * factor,
    );
  }

  void _handleAmountChanged(String value) {
    setState(() {
      _currentWeight = _parseAmount(value);
    });
  }

  Future<void> _confirmDelete() async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: EditConfirmSheet(
          title: 'Delete ingredient?',
          message: 'This will remove the ingredient from the meal.',
          confirmLabel: 'Delete',
          cancelLabel: 'Cancel',
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
    if (_currentWeight <= 0) return;
    Get.back(result: EditIngredientResult.updated(_scaledIngredient()));
  }

  @override
  Widget build(BuildContext context) {
    final ingredient = _scaledIngredient();
    final isValid = _currentWeight > 0;

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
                    Text('Edit Ingredient', style: AppTextStyles.navTitle18),
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
                          Text(ingredient.name, style: AppTextStyles.headline36),
                          const SizedBox(height: AppSpacing.lg),
                          Text('Measurement', style: AppTextStyles.formLabel16),
                          const SizedBox(height: AppSpacing.sm),
                          MeasurementChips(
                            options: const ['Fraction', 'G', 'Small', 'Medium', 'Large'],
                            selectedIndex: _selectedMeasurement,
                            onChanged: (index) => setState(() => _selectedMeasurement = index),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Amount', style: AppTextStyles.formLabel16),
                              _AmountInputField(
                                controller: _amountController,
                                onChanged: _handleAmountChanged,
                              ),
                            ],
                          ),
                          if (!isValid) const InlineErrorText(message: 'Enter a valid amount.'),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.edge),
                      child: CaloriesSummaryCard(
                        label: 'Calories',
                        value: ingredient.calories.toStringAsFixed(0),
                        height: AppSizes.caloriesCardHeight,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.edge),
                      child: Row(
                        children: [
                          MacroStatCard(
                            label: 'Protein',
                            value: '${ingredient.proteins.toStringAsFixed(0)}g',
                            icon: Icons.bolt,
                            iconColor: AppColors.macroProtein,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          MacroStatCard(
                            label: 'Carbs',
                            value: '${ingredient.carbs.toStringAsFixed(0)}g',
                            icon: Icons.grain,
                            iconColor: AppColors.macroCarbsStrong,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          MacroStatCard(
                            label: 'Fats',
                            value: '${ingredient.fats.toStringAsFixed(0)}g',
                            icon: Icons.opacity,
                            iconColor: AppColors.macroFats,
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
            AppSpacing.sm,
            AppSpacing.edge,
            AppSpacing.lg + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: GradientPillButton(
            label: 'Done',
            gradient: AppGradients.primary,
            height: AppSizes.buttonHeightCompact,
            onTap: isValid ? _handleDone : null,
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
