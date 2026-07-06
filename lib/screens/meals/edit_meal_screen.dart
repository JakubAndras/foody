import 'dart:io';
import 'dart:ui';

import 'package:diplomka/app_theme.dart';
import 'package:diplomka/state/dashboard_notifier.dart';
import 'package:diplomka/state/day_record_notifier.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/model/ingredient.dart';
import 'package:diplomka/model/meal.dart';
import 'package:diplomka/screens/ingredients/edit_ingredient_screen.dart';
import 'package:diplomka/screens/log_meal/select_meal_screen.dart';
import 'package:diplomka/screens/meals/fix_result_screen.dart';
import 'package:diplomka/screens/meals/meal_components.dart';
import 'package:diplomka/screens/meals/meal_copy_to_sheet.dart';
import 'package:diplomka/screens/meals/meal_date_picker_sheet.dart';
import 'package:diplomka/screens/meals/meal_sheets.dart';
import 'package:diplomka/widgets/confirm_delete_dialog.dart';
import 'package:diplomka/widgets/custom_glass_app_bar.dart';
import 'package:diplomka/widgets/glass_popup.dart';
import 'package:diplomka/services/share/app_share_service.dart';
import 'package:diplomka/services/share/meal_share_builder.dart';
import 'package:diplomka/services/dietary_violation_service.dart';
import 'package:diplomka/services/selected_date_service.dart';
import 'package:diplomka/services/session_manager.dart';
import 'package:diplomka/utils/app_limits.dart';
import 'package:diplomka/utils/media_storage.dart';
import 'package:diplomka/model/meal_template.dart';
import 'package:diplomka/services/meal_template_repository.dart';
import 'package:diplomka/widgets/edit_flow/edit_flow_widgets.dart';
import 'package:diplomka/widgets/glass_toggle_row.dart';
import 'package:diplomka/widgets/logged_snackbar.dart';
import 'package:diplomka/widgets/sheet_drag_handle.dart';
import 'package:diplomka/widgets/sheet_top_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum MealScreenMode { view, edit }

class EditMealScreen extends ConsumerStatefulWidget {
  final Meal meal;
  final MealScreenMode initialMode;
  final bool isNewMeal;
  final bool openedFromLogScreen;
  final DateTime? selectedDate;
  final bool showCaloriesDelta;
  final String caloriesDelta;
  final MatchBadgeVariant matchBadgeVariant;
  final bool showSyncCards;

  /// When true, the screen is fully read-only: no editing, no deleting, no mode toggle.
  /// Used when previewing meals from Ask AI or calendar overview.
  final bool isPreview;

  const EditMealScreen({
    super.key,
    required this.meal,
    this.initialMode = MealScreenMode.edit,
    this.isNewMeal = false,
    this.openedFromLogScreen = false,
    this.selectedDate,
    this.showCaloriesDelta = false,
    this.caloriesDelta = '+125',
    this.matchBadgeVariant = MatchBadgeVariant.good,
    this.showSyncCards = false,
    this.isPreview = false,
  });

  @override
  ConsumerState<EditMealScreen> createState() => _EditMealScreenState();
}

class _EditMealScreenState extends ConsumerState<EditMealScreen> {
  late Meal _meal;
  late MealScreenMode _mode;
  late DateTime _selectedDate;
  late List<Ingredient> _ingredients;
  late String _initialName;
  late List<Ingredient> _initialIngredients;
  late DateTime _initialDate;
  late String _initialMealtime;
  late double _initialAmount;
  final ScrollController _scrollController = ScrollController();
  ImageProvider? _heroImage;
  double _topPullExtent = 0;
  String _mealtime = 'Lunch'; // internal key, not displayed directly
  double _amountValue = 1;
  bool _isSaving = false;
  bool _isDeleting = false;
  late bool _autoSync;
  bool _isSyncing = false;
  double _savedProteinRatio = 0;
  double _savedCarbsRatio = 0;
  double _savedFatsRatio = 0;
  double _calorieOffset = 0;
  String _lastCaloriesText = '';
  String _lastProteinText = '';
  String _lastCarbsText = '';
  String _lastFatsText = '';

  // Inline editing for isNewMeal
  late final TextEditingController _nameController;
  late final FocusNode _nameFocus;
  late final TextEditingController _caloriesController;
  late final TextEditingController _proteinController;
  late final TextEditingController _carbsController;
  late final TextEditingController _fatsController;
  late final FocusNode _caloriesFocus;
  late final FocusNode _proteinFocus;
  late final FocusNode _carbsFocus;
  late final FocusNode _fatsFocus;

  static const List<String> _mealtimeKeys = ['Breakfast', 'Morning snack', 'Lunch', 'Afternoon snack', 'Dinner', 'Second dinner'];

  List<String> get _mealtimeDisplayOptions => [
    tr(LocaleKeys.meal_mealtime_breakfast),
    tr(LocaleKeys.meal_mealtime_morning_snack),
    tr(LocaleKeys.meal_mealtime_lunch),
    tr(LocaleKeys.meal_mealtime_afternoon_snack),
    tr(LocaleKeys.meal_mealtime_dinner),
    tr(LocaleKeys.meal_mealtime_second_dinner),
  ];

  String get _mealtimeDisplay {
    final index = _mealtimeKeys.indexOf(_mealtime);
    if (index < 0) return _mealtime;
    return _mealtimeDisplayOptions[index];
  }

  @override
  void initState() {
    super.initState();
    _meal = widget.meal;
    _mode = widget.initialMode;
    final initialDate = widget.selectedDate ?? _meal.timestamp;
    _selectedDate = DateTime(initialDate.year, initialDate.month, initialDate.day);
    _meal = _meal.copyWith(timestamp: _applyDate(_meal.timestamp, _selectedDate));
    _mealtime = _mealtimeFromTimestamp(_meal.timestamp);
    _amountValue = _initialAmountValue();
    _ingredients = List<Ingredient>.from(_meal.ingredients);
    _initialName = _meal.name;
    _initialIngredients = List<Ingredient>.from(_meal.ingredients);
    _initialDate = _selectedDate;
    _initialMealtime = _mealtime;
    _initialAmount = _amountValue;
    _heroImage = _resolveHeroImage(_meal.photoPath);
    _autoSync = ref.read(sessionProvider).autoAdjustMacrosEnabled;
    if (_totalCalories > 0) {
      _savedProteinRatio = _totalProteins / _totalCalories;
      _savedCarbsRatio = _totalCarbs / _totalCalories;
      _savedFatsRatio = _totalFats / _totalCalories;
    }
    _calorieOffset = _totalCalories - (_totalProteins * 4 + _totalCarbs * 4 + _totalFats * 9);
    _scrollController.addListener(_handleScroll);

    _nameController = TextEditingController(text: _meal.name);
    _nameFocus = FocusNode();
    _caloriesController = TextEditingController(text: _totalCalories > 0 ? _totalCalories.toStringAsFixed(0) : '');
    _proteinController = TextEditingController(text: _totalProteins > 0 ? _totalProteins.toStringAsFixed(0) : '');
    _carbsController = TextEditingController(text: _totalCarbs > 0 ? _totalCarbs.toStringAsFixed(0) : '');
    _fatsController = TextEditingController(text: _totalFats > 0 ? _totalFats.toStringAsFixed(0) : '');
    _caloriesFocus = FocusNode();
    _proteinFocus = FocusNode();
    _carbsFocus = FocusNode();
    _fatsFocus = FocusNode();
    _lastCaloriesText = _caloriesController.text;
    _lastProteinText = _proteinController.text;
    _lastCarbsText = _carbsController.text;
    _lastFatsText = _fatsController.text;
    _caloriesController.addListener(_onInlineCaloriesChanged);
    _proteinController.addListener(_onInlineProteinChanged);
    _carbsController.addListener(_onInlineCarbsChanged);
    _fatsController.addListener(_onInlineFatsChanged);
    _nameController.addListener(_onInlineNameChanged);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    _nameController.dispose();
    _nameFocus.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatsController.dispose();
    _caloriesFocus.dispose();
    _proteinFocus.dispose();
    _carbsFocus.dispose();
    _fatsFocus.dispose();
    super.dispose();
  }

  double get _totalCalories => _ingredients.fold(0, (sum, item) => sum + item.calories);

  double get _totalProteins => _ingredients.fold(0, (sum, item) => sum + item.proteins);

  double get _totalCarbs => _ingredients.fold(0, (sum, item) => sum + item.carbs);

  double get _totalFats => _ingredients.fold(0, (sum, item) => sum + item.fats);

  double get _totalWeight => _ingredients.fold(0, (sum, item) => sum + item.weight);

  // Unique dietary violation reasons across current (possibly-edited) ingredients.
  // Used both for showing the AllergyAlertCard banner and composing its subtitle.
  List<String> get _mealViolationsList {
    final service = ref.read(dietaryViolationServiceProvider);
    final seen = <String>{};
    final ordered = <String>[];
    for (final ing in _ingredients) {
      final reason = service.checkIngredient(ing);
      if (reason != null && seen.add(reason)) ordered.add(reason);
    }
    return ordered;
  }

  String? get _weightLabelText {
    final w = _totalWeight;
    if (w <= 0) return null;
    return tr(LocaleKeys.meal_total_weight, namedArgs: {'weight': w.toStringAsFixed(0)});
  }

  bool get _isEditMode => _mode == MealScreenMode.edit;

  bool get _isValid {
    if (widget.isNewMeal && _nameController.text.trim().isEmpty) return false;
    return (_ingredients.isNotEmpty && _totalCalories > 0) || widget.isNewMeal;
  }

  void _showValidationError() {
    showSnackBar(context: context, message: tr(LocaleKeys.meal_validation_name_required), type: SnackBarType.error);
  }

  bool get _isBusy => _isSaving || _isDeleting;

  bool get _isInteractionDisabled => _isBusy || widget.isPreview;

  bool get _canEditNutrients => widget.isNewMeal || _ingredients.length <= 1 || ref.read(sessionProvider).editableNutrientsEnabled1;



  bool get _useInlineNutrientEditing => widget.isNewMeal || _ingredients.length <= 1;

  void _onInlineNameChanged() {
    setState(() {
      _meal = _meal.copyWith(name: _nameController.text);
    });
  }

  void _updateSingleIngredient({double? calories, double? proteins, double? carbs, double? fats}) {
    setState(() {
      if (_ingredients.isEmpty) {
        _ingredients.add(Ingredient(
          name: _meal.name.isEmpty ? 'Manual' : _meal.name,
          weight: 0,
          amount: _amountValue,
          calories: calories ?? 0,
          proteins: proteins ?? 0,
          carbs: carbs ?? 0,
          fats: fats ?? 0,
        ));
      } else {
        _ingredients[0] = _ingredients[0].copyWith(
          calories: calories ?? _ingredients[0].calories,
          proteins: proteins ?? _ingredients[0].proteins,
          carbs: carbs ?? _ingredients[0].carbs,
          fats: fats ?? _ingredients[0].fats,
        );
      }
    });
  }

  double _recalcCaloriesFromMacros({double? proOverride, double? carbOverride, double? fatOverride}) {
    final pro = proOverride ?? (_ingredients.isEmpty ? 0.0 : _ingredients[0].proteins);
    final carb = carbOverride ?? (_ingredients.isEmpty ? 0.0 : _ingredients[0].carbs);
    final fat = fatOverride ?? (_ingredients.isEmpty ? 0.0 : _ingredients[0].fats);
    final raw = pro * 4 + carb * 4 + fat * 9 + _calorieOffset;
    return (raw < 0 ? 0.0 : raw).roundToDouble();
  }

  void _recomputeCalorieOffset() {
    _calorieOffset = _totalCalories - (_totalProteins * 4 + _totalCarbs * 4 + _totalFats * 9);
  }

  void _updateSavedRatios({required double cal, required double pro, required double carb, required double fat}) {
    if (cal <= 0) return;
    if (pro > 0) _savedProteinRatio = pro / cal;
    if (carb > 0) _savedCarbsRatio = carb / cal;
    if (fat > 0) _savedFatsRatio = fat / cal;
  }

  void _onInlineCaloriesChanged() {
    if (_isSyncing || _ingredients.length > 1) return;
    if (_caloriesController.text == _lastCaloriesText) return;
    _lastCaloriesText = _caloriesController.text;
    var value = double.tryParse(_caloriesController.text.replaceAll(',', '.'));
    if (value == null || value < 0) return;
    value = value.clamp(0.0, AppLimits.mealMaxCalories.toDouble());
    final oldCal = _ingredients.isEmpty ? 0.0 : _ingredients[0].calories;
    final oldPro = _ingredients.isEmpty ? 0.0 : _ingredients[0].proteins;
    final oldCarb = _ingredients.isEmpty ? 0.0 : _ingredients[0].carbs;
    final oldFat = _ingredients.isEmpty ? 0.0 : _ingredients[0].fats;
    if (value == oldCal) return;
    if (_autoSync) {
      double newPro;
      double newCarb;
      double newFat;
      if (oldCal > 0) {
        final ratio = value / oldCal;
        newPro = (oldPro * ratio).roundToDouble();
        newCarb = (oldCarb * ratio).roundToDouble();
        newFat = (oldFat * ratio).roundToDouble();
        if (newPro == 0 && _savedProteinRatio > 0) newPro = (value * _savedProteinRatio).roundToDouble();
        if (newCarb == 0 && _savedCarbsRatio > 0) newCarb = (value * _savedCarbsRatio).roundToDouble();
        if (newFat == 0 && _savedFatsRatio > 0) newFat = (value * _savedFatsRatio).roundToDouble();
      } else if (_savedProteinRatio > 0 || _savedCarbsRatio > 0 || _savedFatsRatio > 0) {
        newPro = (value * _savedProteinRatio).roundToDouble();
        newCarb = (value * _savedCarbsRatio).roundToDouble();
        newFat = (value * _savedFatsRatio).roundToDouble();
      } else {
        _updateSingleIngredient(calories: value);
        _recomputeCalorieOffset();
        _updateSavedRatios(cal: value, pro: oldPro, carb: oldCarb, fat: oldFat);
        return;
      }
      _isSyncing = true;
      _proteinController.text = newPro.toStringAsFixed(0);
      _carbsController.text = newCarb.toStringAsFixed(0);
      _fatsController.text = newFat.toStringAsFixed(0);
      _lastProteinText = _proteinController.text;
      _lastCarbsText = _carbsController.text;
      _lastFatsText = _fatsController.text;
      _updateSingleIngredient(calories: value, proteins: newPro, carbs: newCarb, fats: newFat);
      _isSyncing = false;
      _recomputeCalorieOffset();
      _updateSavedRatios(cal: value, pro: newPro, carb: newCarb, fat: newFat);
    } else {
      _updateSingleIngredient(calories: value);
      _recomputeCalorieOffset();
      _updateSavedRatios(cal: value, pro: oldPro, carb: oldCarb, fat: oldFat);
    }
  }

  void _onInlineProteinChanged() {
    if (_isSyncing || _ingredients.length > 1) return;
    if (_proteinController.text == _lastProteinText) return;
    _lastProteinText = _proteinController.text;
    var value = double.tryParse(_proteinController.text.replaceAll(',', '.'));
    if (value == null || value < 0) return;
    value = value.clamp(0.0, AppLimits.ingredientMaxMacro.toDouble());
    final currentPro = _ingredients.isEmpty ? 0.0 : _ingredients[0].proteins;
    if (value == currentPro) return;
    if (_autoSync) {
      _isSyncing = true;
      final newCal = _recalcCaloriesFromMacros(proOverride: value);
      _caloriesController.text = newCal.toStringAsFixed(0);
      _lastCaloriesText = _caloriesController.text;
      _updateSingleIngredient(calories: newCal, proteins: value);
      _isSyncing = false;
    } else {
      _updateSingleIngredient(proteins: value);
    }
    _updateSavedRatios(cal: _totalCalories, pro: _totalProteins, carb: _totalCarbs, fat: _totalFats);
  }

  void _onInlineCarbsChanged() {
    if (_isSyncing || _ingredients.length > 1) return;
    if (_carbsController.text == _lastCarbsText) return;
    _lastCarbsText = _carbsController.text;
    var value = double.tryParse(_carbsController.text.replaceAll(',', '.'));
    if (value == null || value < 0) return;
    value = value.clamp(0.0, AppLimits.ingredientMaxMacro.toDouble());
    final currentCarb = _ingredients.isEmpty ? 0.0 : _ingredients[0].carbs;
    if (value == currentCarb) return;
    if (_autoSync) {
      _isSyncing = true;
      final newCal = _recalcCaloriesFromMacros(carbOverride: value);
      _caloriesController.text = newCal.toStringAsFixed(0);
      _lastCaloriesText = _caloriesController.text;
      _updateSingleIngredient(calories: newCal, carbs: value);
      _isSyncing = false;
    } else {
      _updateSingleIngredient(carbs: value);
    }
    _updateSavedRatios(cal: _totalCalories, pro: _totalProteins, carb: _totalCarbs, fat: _totalFats);
  }

  void _onInlineFatsChanged() {
    if (_isSyncing || _ingredients.length > 1) return;
    if (_fatsController.text == _lastFatsText) return;
    _lastFatsText = _fatsController.text;
    var value = double.tryParse(_fatsController.text.replaceAll(',', '.'));
    if (value == null || value < 0) return;
    value = value.clamp(0.0, AppLimits.ingredientMaxMacro.toDouble());
    final currentFat = _ingredients.isEmpty ? 0.0 : _ingredients[0].fats;
    if (value == currentFat) return;
    if (_autoSync) {
      _isSyncing = true;
      final newCal = _recalcCaloriesFromMacros(fatOverride: value);
      _caloriesController.text = newCal.toStringAsFixed(0);
      _lastCaloriesText = _caloriesController.text;
      _updateSingleIngredient(calories: newCal, fats: value);
      _isSyncing = false;
    } else {
      _updateSingleIngredient(fats: value);
    }
    _updateSavedRatios(cal: _totalCalories, pro: _totalProteins, carb: _totalCarbs, fat: _totalFats);
  }

  void _syncNutrientControllers() {
    if (_ingredients.length > 1) return;
    _isSyncing = true;
    _caloriesController.text = _totalCalories > 0 ? _totalCalories.toStringAsFixed(0) : '';
    _proteinController.text = _totalProteins > 0 ? _totalProteins.toStringAsFixed(0) : '';
    _carbsController.text = _totalCarbs > 0 ? _totalCarbs.toStringAsFixed(0) : '';
    _fatsController.text = _totalFats > 0 ? _totalFats.toStringAsFixed(0) : '';
    _lastCaloriesText = _caloriesController.text;
    _lastProteinText = _proteinController.text;
    _lastCarbsText = _carbsController.text;
    _lastFatsText = _fatsController.text;
    _isSyncing = false;
    _recomputeCalorieOffset();
    _updateSavedRatios(cal: _totalCalories, pro: _totalProteins, carb: _totalCarbs, fat: _totalFats);
  }

  String get _mealTitle => _meal.name.trim().isEmpty ? tr(LocaleKeys.meal_untitled) : _meal.name.trim();

  bool get _hasUnsavedChanges {
    if (_meal.name != _initialName) return true;
    if (_selectedDate != _initialDate) return true;
    if (_mealtime != _initialMealtime) return true;
    if ((_amountValue - _initialAmount).abs() > 0.01) return true;
    if (_ingredients.length != _initialIngredients.length) return true;
    for (int i = 0; i < _ingredients.length; i++) {
      final a = _ingredients[i];
      final b = _initialIngredients[i];
      if (a.name != b.name || a.weight != b.weight || a.calories != b.calories || a.proteins != b.proteins || a.carbs != b.carbs || a.fats != b.fats) return true;
    }
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
      if (widget.isNewMeal && !_isValid) {
        if (mounted) _showValidationError();
        return;
      }
      await _handlePrimaryAction();
    } else {
      Navigator.of(context).pop();
    }
  }

  ImageProvider? _resolveHeroImage(String? path) {
    final file = MediaStorage.existingMealPhotoFile(path);
    if (file == null) return null;
    return FileImage(file);
  }

  void _handleScroll() {
    final offset = _scrollController.offset;
    final nextPullExtent = offset < 0 ? -offset : 0.0;
    if ((nextPullExtent - _topPullExtent).abs() < 0.5) return;
    setState(() => _topPullExtent = nextPullExtent);
  }

  double get _heroBackdropHeight => AppSizes.mealHeroHeight * 1.8;

  double get _heroBackdropBaseTop => -((_heroBackdropHeight - AppSizes.mealHeroHeight) / 2);

  double get _heroBackdropTop {
    final maxDown = (-_heroBackdropBaseTop).clamp(0.0, double.infinity);
    final downShift = (_topPullExtent * 0.45).clamp(0.0, maxDown);
    return _heroBackdropBaseTop + downShift;
  }

  Alignment get _heroImageAlignment {
    final progress = (_topPullExtent / AppSizes.mealHeroHeight).clamp(0.0, 1.0);
    final y = -0.7 * progress;
    return Alignment(0, y);
  }

  Widget _buildHeroBackdrop() {
    if (_heroImage == null) {
      return Positioned(
        top: 0,
        left: 0,
        right: 0,
        height: AppSizes.mealHeroHeight + _topPullExtent,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onLongPress: widget.isPreview ? null : _openPhotoSheet,
          child: Container(
            color: AppColors.surfaceMuted,
            child: Center(
              child: Icon(CupertinoIcons.photo, size: 48, color: AppColors.textTertiary),
            ),
          ),
        ),
      );
    }

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: AppSizes.mealHeroHeight + _topPullExtent,
      child: ClipRect(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onLongPress: widget.isPreview ? null : _openPhotoSheet,
          child: Stack(
            children: [
              Positioned(
                top: _heroBackdropTop,
                left: 0,
                right: 0,
                height: _heroBackdropHeight,
                child: Image(image: _heroImage!, fit: BoxFit.cover, alignment: _heroImageAlignment),
              ),
            ],
          ),
        ),
      ),
    );
  }

  DateTime _applyDate(DateTime original, DateTime date) {
    return DateTime(date.year, date.month, date.day, original.hour, original.minute);
  }

  Meal _buildWorkingMeal({DateTime? forDate}) {
    final date = forDate ?? _selectedDate;
    final syncedIngredients = _ingredients.map((i) => i.amount != _amountValue ? i.copyWith(amount: _amountValue) : i).toList();
    return _meal.copyWith(ingredients: syncedIngredients, timestamp: _applyDate(_meal.timestamp, date));
  }

  double _initialAmountValue() {
    if (_meal.ingredients.isEmpty) return 1;
    return _meal.ingredients.first.amount;
  }

  static const List<String> _fractionLabels = ['\u2013', '\u00BD', '\u2153', '\u00BC', '\u215B', '\u2154', '\u00BE', '\u215C', '\u215D', '\u215E'];
  static const List<double> _fractionValues = [0, 0.5, 1 / 3, 0.25, 0.125, 2 / 3, 0.75, 0.375, 0.625, 0.875];

  String get _amountLabel {
    final whole = _amountValue.truncate();
    final frac = _amountValue - whole;
    if (frac < 0.001) return '$whole';
    int bestIndex = 0;
    double bestDiff = double.infinity;
    for (int i = 1; i < _fractionValues.length; i++) {
      final diff = (frac - _fractionValues[i]).abs();
      if (diff < bestDiff) {
        bestDiff = diff;
        bestIndex = i;
      }
    }
    if (whole == 0) return _fractionLabels[bestIndex];
    return '$whole${_fractionLabels[bestIndex]}';
  }

  String _mealtimeFromTimestamp(DateTime timestamp) {
    final minutes = timestamp.hour * 60 + timestamp.minute;
    if (minutes < 9 * 60 + 30) return 'Breakfast';
    if (minutes < 12 * 60) return 'Morning snack';
    if (minutes < 15 * 60) return 'Lunch';
    if (minutes < 18 * 60) return 'Afternoon snack';
    if (minutes < 21 * 60) return 'Dinner';
    return 'Second dinner';
  }

  void _ensureEditMode() {
    if (widget.isPreview) return;
    if (_isEditMode) return;
    setState(() => _mode = MealScreenMode.edit);
  }

  Future<void> _handleSaveInEditMode() async {
    if (!_isValid || _isSaving) return;

    setState(() => _isSaving = true);
    final updated = _buildWorkingMeal();

    await ref.read(dayRecordProvider.notifier).saveMealForDate(date: _selectedDate, mealToSave: updated);

    if (!mounted) return;
    setState(() => _isSaving = false);
    Navigator.of(context).pop(updated);
  }

  Future<void> _handleSaveInViewMode() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);
    final DateTime targetDate = widget.selectedDate ?? ref.read(selectedDateProvider);
    final mealToSave = _buildWorkingMeal(forDate: targetDate).copyWith(id: null, dayRecordId: null);

    await ref.read(dayRecordProvider.notifier).saveMealForDate(date: targetDate, mealToSave: mealToSave);

    if (!mounted) return;
    setState(() => _isSaving = false);
    Navigator.of(context).pop(mealToSave);
  }

  void _openCopyToSheet() {
    if (_isBusy || widget.isPreview) return;
    MealCopyToSheet.show(context, currentDate: _selectedDate, onDatesSelected: (dates) => _handleCopyToMultipleDates(dates));
  }

  Future<void> _handleCopyToMultipleDates(List<DateTime> dates) async {
    final baseMeal = _buildWorkingMeal();
    for (final date in dates) {
      final copy = Meal(
        name: baseMeal.name,
        ingredients: baseMeal.ingredients
            .map(
              (i) => Ingredient(
                name: i.name,
                weight: i.weight,
                amount: i.amount,
                calories: i.calories.clamp(0, AppLimits.ingredientMaxCalories.toDouble()).toDouble(),
                proteins: i.proteins.clamp(0, AppLimits.ingredientMaxMacro.toDouble()).toDouble(),
                carbs: i.carbs.clamp(0, AppLimits.ingredientMaxMacro.toDouble()).toDouble(),
                fats: i.fats.clamp(0, AppLimits.ingredientMaxMacro.toDouble()).toDouble(),
                confidence: i.confidence,
                // RESEARCH-ONLY: research-only fields below
                aiOriginalName: i.aiOriginalName,
                aiOriginalWeight: i.aiOriginalWeight,
                aiOriginalAmount: i.aiOriginalAmount,
                aiOriginalCalories: i.aiOriginalCalories,
                aiOriginalProteins: i.aiOriginalProteins,
                aiOriginalCarbs: i.aiOriginalCarbs,
                aiOriginalFats: i.aiOriginalFats,
                aiOriginalConfidence: i.aiOriginalConfidence,
                wasEditedByUser: i.wasEditedByUser,
              ),
            )
            .toList(),
        timestamp: DateTime(date.year, date.month, date.day, DateTime.now().hour, DateTime.now().minute),
        photoPath: baseMeal.photoPath,
        isFavorite: baseMeal.isFavorite,
        confidence: baseMeal.confidence,
        barcode: baseMeal.barcode,
        // RESEARCH-ONLY: research-only fields below
        inputSource: baseMeal.inputSource,
        aiProvider: baseMeal.aiProvider,
        aiModel: baseMeal.aiModel,
        aiOriginalName: baseMeal.aiOriginalName,
        aiOriginalCalories: baseMeal.aiOriginalCalories,
        aiOriginalProteins: baseMeal.aiOriginalProteins,
        aiOriginalCarbs: baseMeal.aiOriginalCarbs,
        aiOriginalFats: baseMeal.aiOriginalFats,
        aiOriginalConfidence: baseMeal.aiOriginalConfidence,
        wasEditedByUser: baseMeal.wasEditedByUser,
        editedAt: baseMeal.editedAt,
      );
      await ref.read(dayRecordProvider.notifier).saveMealForDate(date: date, mealToSave: copy);
    }
    ref.read(dailyRecordProvider.notifier).refresh();
    if (!mounted) return;
    final viewDate = dates.first;
    showSnackBar(
      context: context,
      message: tr(LocaleKeys.meal_copied_to_dates, namedArgs: {'count': '${dates.length}'}),
      primaryLabel: tr(LocaleKeys.common_view),
      onPrimary: () {
        ref.read(selectedDateProvider.notifier).setSelectedDate(viewDate);
        Navigator.of(context).pop();
      },
    );
  }

  Future<void> _handleFixWithAi() async {
    final result = await Navigator.of(context).push<Meal>(
      MaterialPageRoute(builder: (_) => FixResultScreen(baseMeal: _buildWorkingMeal(), selectedDate: _selectedDate, isNewMeal: widget.isNewMeal)),
    );
    if (result == null || !mounted) return;
    _applyFixResult(result);
  }

  void _applyFixResult(Meal updatedMeal) {
    setState(() {
      _meal = updatedMeal;
      _ingredients = List<Ingredient>.from(updatedMeal.ingredients);
      _heroImage = _resolveHeroImage(updatedMeal.photoPath);
    });
    _syncNutrientControllers();
    _nameController.text = updatedMeal.name;
  }

  Future<void> _handleSaveImageToGallery() async {
    final saved = await MediaStorage.saveToGallery(_meal.photoPath);
    if (!mounted) return;
    if (saved) {
      showSnackBar(context: context, message: tr(LocaleKeys.meal_save_image), subtitle: tr(LocaleKeys.meal_save_image_success));
    } else {
      showSnackBar(context: context, message: tr(LocaleKeys.meal_save_image), subtitle: tr(LocaleKeys.meal_save_image_error), type: SnackBarType.error);
    }
  }

  Future<void> _handleTakePhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);
    if (image == null || !mounted) return;
    final storedPath = await MediaStorage.persistMealPhoto(image.path);
    if (storedPath == null || !mounted) return;
    setState(() {
      _meal = _meal.copyWith(photoPath: storedPath);
      _heroImage = _resolveHeroImage(storedPath);
    });
    _persistCurrentState();
  }

  Future<void> _handleUploadPhoto() async {
    if (Platform.isIOS) {
      final status = await Permission.photos.request();
      if (!status.isGranted && !status.isLimited) {
        if (status.isPermanentlyDenied) {
          await openAppSettings();
        }
        return;
      }
    }
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null || !mounted) return;
    final storedPath = await MediaStorage.persistMealPhoto(image.path);
    if (storedPath == null || !mounted) return;
    setState(() {
      _meal = _meal.copyWith(photoPath: storedPath);
      _heroImage = _resolveHeroImage(storedPath);
    });
    _persistCurrentState();
  }

  void _handleRemovePhoto() {
    setState(() {
      _meal = _meal.copyWith(clearPhotoPath: true);
      _heroImage = null;
    });
    _persistCurrentState();
  }

  Future<void> _handlePrimaryAction() async {
    if (widget.isPreview) return;
    if (_isEditMode) {
      if (widget.openedFromLogScreen) {
        await _handleSaveInViewMode();
      } else {
        await _handleSaveInEditMode();
      }
      return;
    }

    if (widget.openedFromLogScreen) {
      await _handleSaveInViewMode();
      return;
    }

    setState(() => _mode = MealScreenMode.edit);
  }

  Future<void> _toggleFavorite() async {
    if (widget.isPreview) return;
    final next = !_meal.isFavorite;
    setState(() => _meal = _meal.copyWith(isFavorite: next));

    // Always sync to template (both paths need this)
    final normalized = MealTemplate.normalize(_meal.name);
    final templates = ref.read(mealTemplatesProvider).valueOrNull ?? const <MealTemplate>[];
    MealTemplate? template;
    for (final t in templates) {
      if (t.normalizedName == normalized) {
        template = t;
        break;
      }
    }
    if (template != null) await ref.read(mealTemplatesProvider.notifier).setFavorite(template, next);

    if (widget.openedFromLogScreen) return;

    // Dashboard path: also update the Meal record
    if (_meal.id == null || _meal.dayRecordId == null) return;
    await ref.read(dayRecordProvider.notifier).setMealFavorite(meal: _meal, isFavorite: next);

    if (next && mounted) {
      showSnackBar(
        context: context,
        message: tr(LocaleKeys.common_added_to_favorites),
        icon: CupertinoIcons.heart_fill,
        primaryLabel: tr(LocaleKeys.common_view),
        onPrimary: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SelectMealScreen(initialTab: SelectMealTab.favorites))),
        duration: const Duration(seconds: 3),
      );
    }
  }

  Future<void> _handleDeleteMeal() async {
    if (_isDeleting || widget.isPreview) return;
    if (_meal.id == null) {
      showSnackBar(context: context, message: tr(LocaleKeys.meal_delete_title), subtitle: tr(LocaleKeys.meal_delete_message), type: SnackBarType.warning);
      return;
    }

    final confirmed = await showConfirmationDialog(
      context: context,
      title: tr(LocaleKeys.meal_delete_title),
      subtitle: tr(LocaleKeys.common_cannot_undo),
      primaryLabel: tr(LocaleKeys.common_delete),
      secondaryLabel: tr(LocaleKeys.common_cancel),
      isDestructive: true,
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isDeleting = true);
    await ref.read(dayRecordProvider.notifier).deleteMeal(_meal);

    if (!mounted) return;
    setState(() => _isDeleting = false);
    Navigator.of(context).pop(true);
  }

  Future<void> _handleShareMeal() async {
    final mealToShare = _buildWorkingMeal();
    final request = MealShareBuilder.fromMeal(meal: mealToShare, mealtimeLabel: _mealtimeDisplay, includePhoto: true);

    try {
      await AppShareService.share(request: request, context: context);
    } catch (_) {
      if (!mounted) return;
      showSnackBar(context: context, message: tr(LocaleKeys.common_share), subtitle: tr(LocaleKeys.common_something_went_wrong), type: SnackBarType.error);
    }
  }

  void _openPhotoSheet() {
    final bool hasPhoto = _meal.photoPath != null && _meal.photoPath!.isNotEmpty;

    if (widget.isNewMeal) {
      showGlassPopup(
        context: context,
        items: [
          GlassPopupItem(
            label: tr(LocaleKeys.meal_take_photo),
            icon: CupertinoIcons.camera,
            onTap: () {
              Navigator.of(context).pop();
              _handleTakePhoto();
            },
          ),
          GlassPopupItem(
            label: tr(LocaleKeys.meal_upload_photo),
            icon: CupertinoIcons.photo_on_rectangle,
            onTap: () {
              Navigator.of(context).pop();
              _handleUploadPhoto();
            },
          ),
          if (hasPhoto)
            GlassPopupItem(
              label: tr(LocaleKeys.meal_remove_photo),
              icon: CupertinoIcons.trash,
              color: AppColors.error,
              onTap: () {
                Navigator.of(context).pop();
                _handleRemovePhoto();
              },
            ),
        ],
      );
      return;
    }

    showGlassPopup(
      context: context,
      items: [
        GlassPopupItem(
          label: hasPhoto ? tr(LocaleKeys.meal_change_photo) : tr(LocaleKeys.meal_add_photo),
          icon: CupertinoIcons.photo,
          trailingIcon: CupertinoIcons.chevron_down,
          onTap: () => Navigator.of(context).pop(),
        ),
        GlassPopupItem(
          showDividerAbove: true,
          label: tr(LocaleKeys.meal_take_photo),
          icon: CupertinoIcons.camera,
          onTap: () {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
            _handleTakePhoto();
          },
        ),
        GlassPopupItem(
          label: tr(LocaleKeys.meal_upload_photo),
          icon: CupertinoIcons.photo_on_rectangle,
          onTap: () {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
            _handleUploadPhoto();
          },
        ),
        if (hasPhoto)
          GlassPopupItem(
            label: tr(LocaleKeys.meal_remove_photo),
            icon: CupertinoIcons.trash,
            color: AppColors.error,
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              _handleRemovePhoto();
            },
          ),
      ],
    );
  }

  void _openActionSheet() {
    if (widget.isPreview) return;
    showGlassPopup(
      context: context,
      items: [
        GlassPopupItem(
          label: _meal.photoPath != null && _meal.photoPath!.isNotEmpty ? tr(LocaleKeys.meal_change_photo) : tr(LocaleKeys.meal_add_photo),
          icon: CupertinoIcons.photo,
          trailingIcon: CupertinoIcons.chevron_right,
          onTap: () => _openPhotoSheet(),
        ),
        GlassPopupItem(
          label: tr(LocaleKeys.meal_copy_to),
          icon: CupertinoIcons.doc_on_doc,
          onTap: () {
            Navigator.of(context).pop();
            _openCopyToSheet();
          },
        ),
        GlassPopupItem(
          label: tr(LocaleKeys.common_share),
          icon: CupertinoIcons.share,
          onTap: () {
            Navigator.of(context).pop();
            _handleShareMeal();
          },
        ),
        // GlassPopupItem(
        //   label: tr(LocaleKeys.common_report),
        //   icon: CupertinoIcons.flag,
        //   onTap: () {
        //     Navigator.of(context).pop();
        //     Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ReportMealScreen()));
        //   },
        // ),
        GlassPopupItem(
          label: tr(LocaleKeys.meal_fix_issue),
          icon: CupertinoIcons.sparkles,
          onTap: () {
            Navigator.of(context).pop();
            if (!_isBusy) _handleFixWithAi();
          },
        ),
        GlassPopupItem(
          label: tr(LocaleKeys.meal_save_image),
          icon: CupertinoIcons.arrow_down_to_line,
          onTap: () {
            Navigator.of(context).pop();
            _handleSaveImageToGallery();
          },
        ),
        GlassPopupItem(
          label: tr(LocaleKeys.common_delete),
          icon: CupertinoIcons.trash,
          color: AppColors.error,
          showDividerAbove: true,
          onTap: () {
            Navigator.of(context).pop();
            _handleDeleteMeal();
          },
        ),
      ],
    );
  }

  void _openPortionPicker() {
    if (_isBusy || widget.isPreview) return;
    _ensureEditMode();
    if (_ingredients.isEmpty) {
      final cal = double.tryParse(_caloriesController.text.replaceAll(',', '.')) ?? 0;
      final pro = double.tryParse(_proteinController.text.replaceAll(',', '.')) ?? 0;
      final carb = double.tryParse(_carbsController.text.replaceAll(',', '.')) ?? 0;
      final fat = double.tryParse(_fatsController.text.replaceAll(',', '.')) ?? 0;
      if (cal > 0 || pro > 0 || carb > 0 || fat > 0) {
        _ingredients.add(Ingredient(
          name: _meal.name.isEmpty ? 'Manual' : _meal.name,
          weight: 0,
          amount: _amountValue,
          calories: cal,
          proteins: pro,
          carbs: carb,
          fats: fat,
        ));
      }
    }
    final baseIngredients = List<Ingredient>.from(_ingredients);
    final baseAmount = _amountValue;
    AmountPickerSheet.show(
      context,
      title: _mealTitle,
      initialValue: _amountValue,
      onChanged: (value) {
        if (baseAmount == 0 || value == _amountValue) return;
        final scale = value / baseAmount;
        setState(() {
          _ingredients = baseIngredients
              .map((i) => i.copyWith(
                    weight: (i.weight * scale).roundToDouble(),
                    amount: value,
                    calories: (i.calories * scale).roundToDouble(),
                    proteins: (i.proteins * scale).roundToDouble(),
                    carbs: (i.carbs * scale).roundToDouble(),
                    fats: (i.fats * scale).roundToDouble(),
                  ))
              .toList();
          _amountValue = value;
        });
        _syncNutrientControllers();
      },
    );
  }

  Future<void> _openNutrientEditor({required String label, required double currentValue, required void Function(double) onSave}) async {
    if (_isBusy || widget.isPreview) return;
    _ensureEditMode();
    final result = await showModalBottomSheet<double>(
      context: context,
      backgroundColor: Colors.transparent,
      elevation: 0,
      barrierColor: AppColors.overlayDark40,
      isScrollControlled: true,
      builder: (context) => _NutrientEditorSheet(label: label, initialValue: currentValue),
    );
    if (result == null) return;
    onSave(result);
    _persistCurrentState();
  }

  Future<void> _persistCurrentState() async {
    final updated = _buildWorkingMeal();
    if (widget.openedFromLogScreen) {
      final DateTime targetDate = widget.selectedDate ?? ref.read(selectedDateProvider);
      final mealToSave = updated.copyWith(id: null, dayRecordId: null);
      await ref.read(dayRecordProvider.notifier).saveMealForDate(date: targetDate, mealToSave: mealToSave);
    } else {
      await ref.read(dayRecordProvider.notifier).saveMealForDate(date: _selectedDate, mealToSave: updated);
    }
    ref.read(dailyRecordProvider.notifier).refresh();
    _syncInitialState();
  }

  void _syncInitialState() {
    _initialName = _meal.name;
    _initialIngredients = List<Ingredient>.from(_ingredients);
    _initialDate = _selectedDate;
    _initialMealtime = _mealtime;
    _initialAmount = _amountValue;
  }

  void _updateNutrientProportionally(double newTotal, double Function(Ingredient) getter, Ingredient Function(Ingredient, double) updater) {
    final oldTotal = _ingredients.fold<double>(0, (sum, i) => sum + getter(i));
    setState(() {
      if (_ingredients.length == 1 || oldTotal == 0) {
        if (_ingredients.isNotEmpty) {
          _ingredients[0] = updater(_ingredients[0], newTotal);
        }
      } else {
        for (int i = 0; i < _ingredients.length; i++) {
          final ratio = getter(_ingredients[i]) / oldTotal;
          _ingredients[i] = updater(_ingredients[i], newTotal * ratio);
        }
      }
    });
  }

  void _openCaloriesEditor() => _openNutrientEditor(
    label: tr(LocaleKeys.common_calories),
    currentValue: _totalCalories,
    onSave: (v) => _updateNutrientProportionally(v, (i) => i.calories, (i, val) => i.copyWith(calories: val)),
  );

  void _openProteinEditor() => _openNutrientEditor(
    label: tr(LocaleKeys.common_protein),
    currentValue: _totalProteins,
    onSave: (v) => _updateNutrientProportionally(v, (i) => i.proteins, (i, val) => i.copyWith(proteins: val)),
  );

  void _openCarbsEditor() => _openNutrientEditor(
    label: tr(LocaleKeys.common_carbs),
    currentValue: _totalCarbs,
    onSave: (v) => _updateNutrientProportionally(v, (i) => i.carbs, (i, val) => i.copyWith(carbs: val)),
  );

  void _openFatsEditor() => _openNutrientEditor(
    label: tr(LocaleKeys.common_fats),
    currentValue: _totalFats,
    onSave: (v) => _updateNutrientProportionally(v, (i) => i.fats, (i, val) => i.copyWith(fats: val)),
  );

  void _openMealtimePicker() {
    if (_isBusy || widget.isPreview) return;
    _ensureEditMode();
    MealtimePickerSheet.show(
      context,
      options: _mealtimeDisplayOptions,
      initialIndex: _mealtimeKeys.indexOf(_mealtime).clamp(0, _mealtimeKeys.length - 1),
      onChanged: (index) {
        setState(() => _mealtime = _mealtimeKeys[index]);
      },
    );
  }

  void _openDatePicker() {
    if (_isBusy || widget.isPreview) return;
    _ensureEditMode();
    MealDatePickerSheet.show(
      context,
      selectedDate: _selectedDate,
      onDateSelected: (date) {
        final normalizedDate = DateTime(date.year, date.month, date.day);
        setState(() {
          _selectedDate = normalizedDate;
          _meal = _meal.copyWith(timestamp: _applyDate(_meal.timestamp, normalizedDate));
        });
      },
    );
  }

  Future<void> _confirmDeleteIngredient(int index) async {
    final confirmed = await showConfirmationDialog(
      context: context,
      title: tr(LocaleKeys.ingredient_delete_title),
      subtitle: tr(LocaleKeys.common_cannot_undo),
      primaryLabel: tr(LocaleKeys.common_delete),
      secondaryLabel: tr(LocaleKeys.common_cancel),
      isDestructive: true,
    );
    if (confirmed != true || !mounted) return;
    setState(() => _ingredients.removeAt(index));
    _syncNutrientControllers();
  }

  Future<void> _toggleIngredientFavorite(int index) async {
    final ingredient = _ingredients[index];
    final next = !ingredient.isFavorite;
    setState(() => _ingredients[index] = ingredient.copyWith(isFavorite: next));

    if (widget.openedFromLogScreen) return;
    if (ingredient.id == null || ingredient.mealId == null) return;
    await ref.read(dayRecordProvider.notifier).setIngredientFavorite(ingredient: ingredient, isFavorite: next);
  }

  Future<void> _editIngredient(int index) async {
    final ingredient = _ingredients[index];
    final result = await Navigator.of(context).push<EditIngredientResult>(MaterialPageRoute(builder: (_) => EditIngredientScreen(ingredient: ingredient)));

    if (!mounted || result == null) return;
    if (result.deleted) {
      setState(() => _ingredients.removeAt(index));
      _syncNutrientControllers();
    } else if (result.ingredient != null) {
      setState(() => _ingredients[index] = result.ingredient!);
      _syncNutrientControllers();
    }
  }

  Future<void> _addIngredient() async {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SelectMealScreen(initialTab: SelectMealTab.ingredients)));
  }

  VoidCallback? get _onPrimaryTap {
    if (widget.isPreview) return null;
    if (_isBusy) return null;
    if (_isEditMode && !_isValid) return null;
    return () => _handlePrimaryAction();
  }

  @override
  Widget build(BuildContext context) {
    final bool showIngredientsError = _isEditMode && _ingredients.isEmpty;
    final bool showCaloriesError = _isEditMode && _ingredients.isNotEmpty && _totalCalories <= 0;
    final double heroOverlap = AppSpacing.l;
    final double bottomActionClearance = AppSizes.buttonHeight + AppSpacing.s + AppSpacing.m + MediaQuery.paddingOf(context).bottom + AppSpacing.m;

    final ThemeData screenTheme = Theme.of(context).copyWith(
      bottomSheetTheme: const BottomSheetThemeData(backgroundColor: Colors.transparent, surfaceTintColor: Colors.transparent, shadowColor: Colors.transparent, elevation: 0),
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _handleBack();
      },
      child: Theme(
        data: screenTheme,
          child: LiquidGlassScope(
          child: Scaffold(
            backgroundColor: AppColors.background,
            extendBodyBehindAppBar: true,
            body: LiquidGlassBackground(
              child: Stack(
                children: [
                  _buildHeroBackdrop(),
                  SingleChildScrollView(
                    controller: _scrollController,
                    padding: EdgeInsets.only(bottom: bottomActionClearance),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          top: 24,
                          child: Column(
                            children: [
                              SizedBox(height: AppSizes.mealHeroHeight - heroOverlap),
                              Expanded(
                                child: DecoratedBox(
                                  decoration: BoxDecoration(color: AppColors.background),
                                  child: const SizedBox.expand(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_mealViolationsList.isNotEmpty)
                              Column(
                                children: [
                                  SizedBox(
                                    height: AppSizes.mealHeroHeight + (Platform.isAndroid ? AppSizes.alertCardHeight + 10 : AppSizes.alertCardHeight) - heroOverlap,
                                    child: Stack(
                                      children: [
                                        MealHeroHeader(
                                          title: _mealTitle,
                                          timeLabel: _formatTime(_meal.timestamp),
                                          trailingLabel: _weightLabelText,
                                          showTime: !widget.openedFromLogScreen,
                                          titleController: _isInteractionDisabled ? null : _nameController,
                                          titleFocusNode: _isInteractionDisabled ? null : _nameFocus,
                                        ),
                                        Positioned(
                                          left: AppSpacing.edge,
                                          right: AppSpacing.edge,
                                          top: AppSizes.mealHeroHeight - heroOverlap,
                                          child: AllergyAlertCard(
                                            title: tr(LocaleKeys.meal_allergy_alert),
                                            subtitle: tr(LocaleKeys.meal_allergy_contains, namedArgs: {'allergen': _mealViolationsList.join(', ')}),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.s),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.edge),
                                    child: CaloriesSummaryCard(
                                      label: tr(LocaleKeys.common_calories),
                                      value: _totalCalories.toStringAsFixed(0),
                                      delta: widget.showCaloriesDelta ? widget.caloriesDelta : null,
                                      height: AppSizes.caloriesCardHeight,
                                      badge: _meal.confidence != null ? MatchBadge(text: _confidenceText, variant: _confidenceVariant) : null,
                                      controller: _useInlineNutrientEditing ? _caloriesController : null,
                                      focusNode: _useInlineNutrientEditing ? _caloriesFocus : null,
                                      maxLength: _useInlineNutrientEditing ? 5 : null,
                                    ),
                                  ),
                                ],
                              )
                            else
                              SizedBox(
                                height: AppSizes.mealHeroHeight + AppSizes.caloriesCardHeight - heroOverlap,
                                child: Stack(
                                  children: [
                                    MealHeroHeader(
                                      title: _mealTitle,
                                      timeLabel: _formatTime(_meal.timestamp),
                                      trailingLabel: _weightLabelText,
                                      showTime: !widget.openedFromLogScreen,
                                      titleController: _isInteractionDisabled ? null : _nameController,
                                      titleFocusNode: _isInteractionDisabled ? null : _nameFocus,
                                    ),
                                    Positioned(
                                      left: AppSpacing.edge,
                                      right: AppSpacing.edge,
                                      top: AppSizes.mealHeroHeight - heroOverlap,
                                      child: _useInlineNutrientEditing
                                          ? CaloriesSummaryCard(
                                              label: tr(LocaleKeys.common_calories),
                                              value: _totalCalories.toStringAsFixed(0),
                                              delta: widget.showCaloriesDelta ? widget.caloriesDelta : null,
                                              height: AppSizes.caloriesCardHeight,
                                              badge: _meal.confidence != null ? MatchBadge(text: _confidenceText, variant: _confidenceVariant) : null,
                                              controller: _caloriesController,
                                              focusNode: _caloriesFocus,
                                              maxLength: 5,
                                            )
                                          : GestureDetector(
                                              onTap: _isInteractionDisabled || !_canEditNutrients ? null : _openCaloriesEditor,
                                              child: CaloriesSummaryCard(
                                                label: tr(LocaleKeys.common_calories),
                                                value: _totalCalories.toStringAsFixed(0),
                                                delta: widget.showCaloriesDelta ? widget.caloriesDelta : null,
                                                height: AppSizes.caloriesCardHeight,
                                                badge: _meal.confidence != null ? MatchBadge(text: _confidenceText, variant: _confidenceVariant) : null,
                                              ),
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                            const SizedBox(height: AppSpacing.s),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.edge),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _useInlineNutrientEditing
                                        ? MacroStatCard(
                                            label: tr(LocaleKeys.common_protein),
                                            value: '${_totalProteins.toStringAsFixed(0)}${tr(LocaleKeys.common_g)}',
                                            icon: AppIcons.protein,
                                            iconColor: AppColors.macroProtein,
                                            controller: _proteinController,
                                            focusNode: _proteinFocus,
                                            maxLength: 4,
                                          )
                                        : GestureDetector(
                                            onTap: _isInteractionDisabled || !_canEditNutrients ? null : _openProteinEditor,
                                            child: MacroStatCard(
                                              label: tr(LocaleKeys.common_protein),
                                              value: '${_totalProteins.toStringAsFixed(0)}${tr(LocaleKeys.common_g)}',
                                              icon: AppIcons.protein,
                                              iconColor: AppColors.macroProtein,
                                            ),
                                          ),
                                  ),
                                  const SizedBox(width: AppSpacing.s),
                                  Expanded(
                                    child: _useInlineNutrientEditing
                                        ? MacroStatCard(
                                            label: tr(LocaleKeys.common_carbs),
                                            value: '${_totalCarbs.toStringAsFixed(0)}${tr(LocaleKeys.common_g)}',
                                            icon: AppIcons.carbs,
                                            iconColor: AppColors.warningStrong,
                                            controller: _carbsController,
                                            focusNode: _carbsFocus,
                                            maxLength: 4,
                                          )
                                        : GestureDetector(
                                            onTap: _isInteractionDisabled || !_canEditNutrients ? null : _openCarbsEditor,
                                            child: MacroStatCard(
                                              label: tr(LocaleKeys.common_carbs),
                                              value: '${_totalCarbs.toStringAsFixed(0)}${tr(LocaleKeys.common_g)}',
                                              icon: AppIcons.carbs,
                                              iconColor: AppColors.warningStrong,
                                            ),
                                          ),
                                  ),
                                  const SizedBox(width: AppSpacing.s),
                                  Expanded(
                                    child: _useInlineNutrientEditing
                                        ? MacroStatCard(
                                            label: tr(LocaleKeys.common_fats),
                                            value: '${_totalFats.toStringAsFixed(0)}${tr(LocaleKeys.common_g)}',
                                            icon: AppIcons.fats,
                                            iconColor: AppColors.macroFats,
                                            controller: _fatsController,
                                            focusNode: _fatsFocus,
                                            maxLength: 4,
                                          )
                                        : GestureDetector(
                                            onTap: _isInteractionDisabled || !_canEditNutrients ? null : _openFatsEditor,
                                            child: MacroStatCard(
                                              label: tr(LocaleKeys.common_fats),
                                              value: '${_totalFats.toStringAsFixed(0)}${tr(LocaleKeys.common_g)}',
                                              icon: AppIcons.fats,
                                              iconColor: AppColors.macroFats,
                                            ),
                                          ),
                                  ),
                                ],
                              ),
                            ),
                            if (_useInlineNutrientEditing) ...[
                              const SizedBox(height: AppSpacing.xxs),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: AppSpacing.edge + (ref.watch(sessionProvider).sectionHeaderPaddingEnabled ? AppSpacing.s : 0)),
                                child: GlassToggleRow(
                                  title: tr(LocaleKeys.preferences_auto_adjust),
                                  subtitle: tr(LocaleKeys.preferences_auto_adjust_desc),
                                  isOn: _autoSync,
                                  onChanged: (value) => setState(() => _autoSync = value),
                                  showDivider: false,
                                ),
                              ),
                            ],
                            const SizedBox(height: AppSpacing.s),
                            MealRecordCard(
                              amount: _amountLabel,
                              mealtime: _mealtimeDisplay,
                              date: _formatDate(_selectedDate),
                              onAmountTap: _isInteractionDisabled ? null : _openPortionPicker,
                              onMealtimeTap: _isInteractionDisabled ? null : _openMealtimePicker,
                              onDateTap: _isInteractionDisabled ? null : _openDatePicker,
                              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.edge),
                            ),
                            if (_ingredients.length > 1) ...[
                              const SizedBox(height: AppSpacing.xl),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(tr(LocaleKeys.meal_ingredients_title), style: AppTextStyles.body16.copyWith(fontWeight: FontWeight.w600, letterSpacing: -0.3125)),
                                    InkWell(
                                      onTap: _isInteractionDisabled
                                          ? null
                                          : () {
                                              _ensureEditMode();
                                              _addIngredient();
                                            },
                                      borderRadius: BorderRadius.circular(AppRadii.s),
                                      child: Row(
                                        children: [
                                          Icon(CupertinoIcons.add, size: AppSizes.iconSm, color: AppColors.textTertiary),
                                          const SizedBox(width: AppSpacing.xxs),
                                          Text(
                                            tr(LocaleKeys.common_add),
                                            style: AppTextStyles.caption12.copyWith(color: AppColors.textTertiary, fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (showIngredientsError)
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.edge),
                                  child: InlineErrorText(message: tr(LocaleKeys.meal_add_ingredient)),
                                )
                              else if (showCaloriesError)
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.edge),
                                  child: InlineErrorText(message: tr(LocaleKeys.meal_calories_positive)),
                                ),
                              const SizedBox(height: AppSpacing.s),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.edge),
                                child: Column(
                                  children: List.generate(_ingredients.length, (index) {
                                    final ingredient = _ingredients[index];
                                    final violationReason = ref.read(dietaryViolationServiceProvider).checkIngredient(ingredient);
                                    final isViolation = violationReason != null;
                                    if (!_isEditMode) {
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: AppSpacing.s),
                                        child: IngredientRow(
                                          ingredient: ingredient,
                                          highlighted: isViolation,
                                          alertText: violationReason,
                                          onTap: _isInteractionDisabled
                                              ? null
                                              : () {
                                                  _ensureEditMode();
                                                  _editIngredient(index);
                                                },
                                          onFavorite: _isInteractionDisabled ? null : () => _toggleIngredientFavorite(index),
                                          onEdit: _isInteractionDisabled
                                              ? null
                                              : () {
                                                  _ensureEditMode();
                                                  _editIngredient(index);
                                                },
                                          onDelete: _isInteractionDisabled ? null : () => _confirmDeleteIngredient(index),
                                        ),
                                      );
                                    }
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: AppSpacing.s),
                                      child: EditIngredientRow(
                                        ingredient: ingredient,
                                        highlighted: isViolation,
                                        alertText: violationReason,
                                        onTap: _isInteractionDisabled ? null : () => _editIngredient(index),
                                        onFavorite: _isInteractionDisabled ? null : () => _toggleIngredientFavorite(index),
                                        onEdit: _isInteractionDisabled ? null : () => _editIngredient(index),
                                        onDelete: _isInteractionDisabled ? null : () => _confirmDeleteIngredient(index),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            ],
                            if (widget.showSyncCards) ...[
                              const SizedBox(height: AppSpacing.l),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.edge),
                                child: Column(
                                  children: [
                                    SyncCard(title: tr(LocaleKeys.meal_sync_macros_prompt), primaryLabel: tr(LocaleKeys.meal_sync), secondaryLabel: tr(LocaleKeys.meal_dont_sync)),
                                    const SizedBox(height: AppSpacing.m),
                                    SyncCard(
                                      title: tr(LocaleKeys.meal_sync_calories_prompt),
                                      primaryLabel: tr(LocaleKeys.meal_sync),
                                      secondaryLabel: tr(LocaleKeys.meal_dont_sync),
                                    ),
                                    const SizedBox(height: AppSpacing.m),
                                    SyncCard(
                                      title: tr(LocaleKeys.meal_always_sync),
                                      primaryLabel: tr(LocaleKeys.meal_always_sync),
                                      secondaryLabel: tr(LocaleKeys.meal_decide_later),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: AppSpacing.xl),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
                    child: widget.isPreview
                        ? _EditMealTopBar(onBack: _handleBack, onDone: null, isFavorite: _meal.isFavorite, onFavorite: null, onMenu: null)
                        : _EditMealTopBar(
                            onBack: _handleBack,
                            onDone: widget.isNewMeal
                                ? () {
                                    if (_isValid) {
                                      _handlePrimaryAction();
                                    } else {
                                      _showValidationError();
                                    }
                                  }
                                : _onPrimaryTap,
                            isFavorite: _meal.isFavorite,
                            onFavorite: _toggleFavorite,
                            onPhoto: widget.isNewMeal ? _openPhotoSheet : null,
                            onMenu: widget.isNewMeal ? null : _openActionSheet,
                          ),
                  ),
                  if (_isBusy)
                    Positioned.fill(
                      child: ColoredBox(
                        color: AppColors.overlayDark40,
                        child: Center(child: CircularProgressIndicator(color: AppColors.onPrimary)),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}. ${date.month}. ${date.year}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  MatchBadgeVariant get _confidenceVariant {
    final c = _meal.confidence;
    if (c == null || c >= 0.75) return MatchBadgeVariant.good;
    if (c >= 0.45) return MatchBadgeVariant.medium;
    return MatchBadgeVariant.low;
  }

  String get _confidenceText {
    final c = _meal.confidence;
    if (c == null) return '';
    return '${(c * 100).round()}% ${tr(LocaleKeys.common_confidence)}';
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
    final bottomSpacing = Platform.isAndroid ? AppSpacing.xs + AppSpacing.xxxl : AppSpacing.xs;
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: bottomSpacing),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppRadii.xxl),
          topRight: Radius.circular(AppRadii.xxl),
          bottomLeft: Radius.circular(AppRadii.xxl + 10),
          bottomRight: Radius.circular(AppRadii.xxl + 10),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          child: CustomPaint(
            painter: const _GlassEditorSheetPainter(),
            child: SafeArea(
              top: false,
              bottom: false,
              child: Padding(
                padding: EdgeInsets.only(bottom: keyboardInset),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: AppSpacing.xxs),
                    SheetDragHandle(color: AppColors.greyLight3),
                    const SizedBox(height: AppSpacing.s),
                    SheetTopBar(title: widget.label, onClose: () => Navigator.of(context).pop(), onConfirm: _submit),
                    const SizedBox(height: AppSpacing.m),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
                      child: TextField(
                        controller: _controller,
                        autofocus: true,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _submit(),
                        style: AppTextStyles.body16,
                        decoration: InputDecoration(
                          hintText: widget.label,
                          hintStyle: AppTextStyles.body16.copyWith(color: AppColors.textTertiary),
                          filled: true,
                          fillColor: AppColors.surfaceMuted,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadii.m), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: AppSpacing.m),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
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

class _GlassEditorSheetPainter extends CustomPainter {
  const _GlassEditorSheetPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromLTRBAndCorners(
      0, 0, size.width, size.height,
      topLeft: Radius.circular(AppRadii.xxl),
      topRight: Radius.circular(AppRadii.xxl),
      bottomLeft: Radius.circular(AppRadii.xxl + 10),
      bottomRight: Radius.circular(AppRadii.xxl + 10),
    );
    canvas.drawRRect(rrect, Paint()..color = AppColors.pickerGlassSolid);
    canvas.drawRRect(rrect.deflate(0.4), Paint()..style = PaintingStyle.stroke..strokeWidth = 0.8..color = AppColors.glassBorder);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _EditMealTopBar extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback? onDone;
  final VoidCallback? onFavorite;
  final VoidCallback? onMenu;
  final VoidCallback? onPhoto;
  final bool isFavorite;

  const _EditMealTopBar({required this.onBack, this.onDone, this.onFavorite, this.onMenu, this.onPhoto, required this.isFavorite});

  @override
  Widget build(BuildContext context) {
    final hasActions = onDone != null || onFavorite != null || onMenu != null || onPhoto != null;
    return CustomGlassAppBar(
      //leadingIcon: CupertinoIcons.xmark,
      leadingIconSize: AppSizes.iconLg,
      onBack: onBack,
      actions: [
        if (hasActions)
          CustomGlassIconButtonGroup(
            iconSize: AppSizes.iconLg,
            items: [
              if (onDone != null) (icon: CupertinoIcons.checkmark, onPressed: onDone!),
              if (onFavorite != null) (icon: isFavorite ? CupertinoIcons.heart_fill : CupertinoIcons.heart, onPressed: onFavorite!),
              if (onPhoto != null) (icon: CupertinoIcons.camera, onPressed: onPhoto!),
              if (onMenu != null) (icon: CupertinoIcons.ellipsis, onPressed: onMenu!),
            ],
          ),
      ],
    );
  }
}
