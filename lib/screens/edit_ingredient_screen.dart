import 'package:diplomka/model/ingredient.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum NutrientInputType { calories, proteins, fat, carbs }

class EditIngredientScreen extends StatefulWidget {
  final Ingredient? initialIngredient;

  const EditIngredientScreen({super.key, this.initialIngredient});

  @override
  State<EditIngredientScreen> createState() => _EditIngredientScreenState();
}

class _EditIngredientScreenState extends State<EditIngredientScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _weightController;
  late TextEditingController _caloriesController;
  late TextEditingController _proteinsController;
  late TextEditingController _fatController;
  late TextEditingController _carbsController;

  bool _isPerServing = true;

  bool get _isNewIngredient => widget.initialIngredient == null;

  @override
  void initState() {
    super.initState();
    final ingredient = widget.initialIngredient;
    _nameController = TextEditingController(text: ingredient?.name ?? '');
    _weightController = TextEditingController(text: ingredient?.weight.toInt().toString() ?? '');
    // Assuming nutrient values are per serving if weight is present, else per 100g
    _caloriesController = TextEditingController(text: ingredient?.calories.toInt().toString() ?? '');
    _proteinsController = TextEditingController(text: ingredient?.proteins.toInt().toString() ?? '');
    _fatController = TextEditingController(text: ingredient?.fats.toInt().toString() ?? '');
    _carbsController = TextEditingController(text: ingredient?.carbs.toInt().toString() ?? '');

    if (ingredient != null && ingredient.weight > 0) {
      _isPerServing = true;
    } else {
      _isPerServing = false; // Default to per 100g if new or no weight
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _caloriesController.dispose();
    _proteinsController.dispose();
    _fatController.dispose();
    _carbsController.dispose();
    super.dispose();
  }

  // Handles saving the ingredient.
  void _saveIngredient() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final name = _nameController.text;
      final weight = double.tryParse(_weightController.text) ?? 0;
      final calories = double.tryParse(_caloriesController.text) ?? 0;
      final proteins = double.tryParse(_proteinsController.text) ?? 0;
      final fats = double.tryParse(_fatController.text) ?? 0;
      final carbs = double.tryParse(_carbsController.text) ?? 0;

      // Note: The logic for handling 'per serving' vs 'per 100g'
      // when saving needs to be implemented.
      // If _isPerServing is true, the entered values are for the specified weight.
      // If false, they are per 100g, and you might need to calculate
      // total nutrients based on the entered weight.

      final resultIngredient = Ingredient(
        id: widget.initialIngredient?.id ?? DateTime.now().millisecondsSinceEpoch, // Generate new ID if null
        name: name,
        weight: _isPerServing ? weight : 100.0, // Save weight if per serving, else it's per 100g
        calories: calories,
        proteins: proteins,
        carbs: carbs,
        fats: fats,
        // If values are per 100g and a weight is also entered,
        // you might want to store the base per 100g values
        // and calculate totals dynamically, or store totals.
        // For now, storing the direct input.
      );
      Navigator.of(context).pop(resultIngredient);
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Ingredient'),
          content: const Text('Are you sure you want to delete this ingredient?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Delete', style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      Navigator.of(context).pop('DELETED');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_isNewIngredient ? 'Add Ingredient' : 'Edit Ingredient'),
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        foregroundColor: theme.colorScheme.onSurface,
        actions: [
          if (!_isNewIngredient)
            IconButton(
              icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
              onPressed: _confirmDelete,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (_isNewIngredient)
                _buildEditableTextField(
                  controller: _nameController,
                  label: 'Ingredient Name',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter ingredient name';
                    }
                    return null;
                  },
                )
              else
                Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Text(
                    widget.initialIngredient!.name,
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              if (_isNewIngredient) const SizedBox(height: 16),
              _buildEditableCard(
                context: context,
                label: 'Weight',
                controller: _weightController,
                suffixText: 'g',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  if (double.tryParse(value) == null) return 'Invalid number';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildUnitToggle(),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildEditableCard(
                      context: context,
                      label: 'Calories',
                      controller: _caloriesController,
                      suffixText: 'kcal',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Required';
                        if (double.tryParse(value) == null) return 'Invalid';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildEditableCard(
                      context: context,
                      label: 'Proteins',
                      controller: _proteinsController,
                      prefixIcon: _buildNutrientIcon('P', Colors.orange),
                      suffixText: 'g',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Required';
                        if (double.tryParse(value) == null) return 'Invalid';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildEditableCard(
                      context: context,
                      label: 'Fat',
                      controller: _fatController,
                      prefixIcon: _buildNutrientIcon('F', Colors.yellow.shade700),
                      suffixText: 'g',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Required';
                        if (double.tryParse(value) == null) return 'Invalid';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildEditableCard(
                      context: context,
                      label: 'Carbs',
                      controller: _carbsController,
                      prefixIcon: _buildNutrientIcon('C', Colors.blue.shade300),
                      suffixText: 'g',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Required';
                        if (double.tryParse(value) == null) return 'Invalid';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 70), // Space for FAB
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SizedBox(
          width: double.infinity,
          child: FloatingActionButton.extended(
            onPressed: _saveIngredient,
            label: Text('Save', style: theme.textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }

  // Builds a toggle button for "per serving" and "per 100g".
  Widget _buildUnitToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        ToggleButtons(
          isSelected: [_isPerServing, !_isPerServing],
          onPressed: (int index) {
            setState(() {
              _isPerServing = index == 0;
              // TODO: Add logic here to convert values if necessary when toggling
              // e.g., if switching from "per 100g" to "per serving",
              // and a weight is entered, calculate values for that serving.
              // Or, if switching from "per serving" to "per 100g",
              // calculate the base per 100g values.
            });
          },
          borderRadius: BorderRadius.circular(8.0),
          selectedColor: Colors.white,
          color: Colors.black,
          fillColor: Colors.black,
          splashColor: Colors.grey.withOpacity(0.12),
          hoverColor: Colors.grey.withOpacity(0.04),
          constraints: const BoxConstraints(minHeight: 36.0, minWidth: 100.0),
          children: const <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text('per serving'),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text('per 100g'),
            ),
          ],
        ),
      ],
    );
  }

  // Builds an icon for nutrients.
  Widget _buildNutrientIcon(String letter, Color color) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Text(
        letter,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  // Builds a generic editable text field.
  Widget _buildEditableTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    String? suffixText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            suffixText: suffixText,
          ),
        ),
      ],
    );
  }

  // Builds an editable card with a label, text field, and edit icon.
  Widget _buildEditableCard({
    required BuildContext context,
    required String label,
    required TextEditingController controller,
    Widget? prefixIcon,
    String? suffixText,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelMedium?.copyWith(color: Colors.grey.shade700)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          decoration: InputDecoration(
            prefixIcon: prefixIcon != null ? Padding(padding: const EdgeInsets.only(left: 12.0, right: 8.0), child: prefixIcon) : null,
            prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0), // To make prefix icon align better
            // suffixIcon: Padding(
            //   padding: const EdgeInsets.only(right: 4.0),
            //   child: IconButton( // Using IconButton for better tap target, though no action here
            //     icon: Icon(Icons.edit_outlined, size: 20, color: Colors.grey.shade500),
            //     onPressed: null, // Visually indicates editability
            //   ),
            // ),
            hintText: '0', // Default placeholder
            hintStyle: TextStyle(color: Colors.grey.shade400),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: theme.primaryColor, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            suffixText: suffixText,
          ),
          style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
          textAlignVertical: TextAlignVertical.center,
        ),
      ],
    );
  }
}
