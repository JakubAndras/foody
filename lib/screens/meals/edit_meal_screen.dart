import 'package:diplomka/app_theme.dart';
import 'package:diplomka/controller/dashboard_controller.dart';
import 'package:diplomka/controller/day_record_controller.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/model/ingredient.dart';
import 'package:diplomka/model/meal.dart';
import 'package:diplomka/screens/ingredients/edit_ingredient_screen.dart';
import 'package:diplomka/screens/meals/fix_result_screen.dart';
import 'package:diplomka/screens/meals/report_meal_screen.dart';
import 'package:diplomka/screens/meals/meal_components.dart';
import 'package:diplomka/screens/meals/meal_copy_to_sheet.dart';
import 'package:diplomka/screens/meals/meal_date_picker_sheet.dart';
import 'package:diplomka/screens/meals/meal_sheets.dart';
import 'package:diplomka/widgets/confirm_delete_dialog.dart';
import 'package:diplomka/widgets/custom_glass_app_bar.dart';
import 'package:diplomka/widgets/glass_popup.dart';
import 'package:diplomka/widgets/foody_glass_buttons.dart';
import 'package:diplomka/services/share/app_share_service.dart';
import 'package:diplomka/services/share/meal_share_builder.dart';
import 'package:diplomka/services/selected_date_service.dart';
import 'package:diplomka/services/session_manager.dart';
import 'package:diplomka/utils/media_storage.dart';
import 'package:diplomka/model/meal_template.dart';
import 'package:diplomka/services/meal_template_repository.dart';
import 'package:diplomka/widgets/edit_flow/edit_flow_widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum MealScreenMode { view, edit }

class EditMealScreen extends StatefulWidget {
  final Meal meal;
  final MealScreenMode initialMode;
  final bool isNewMeal;
  final bool openedFromLogScreen;
  final DateTime? selectedDate;
  final bool showAllergyAlert;
  final bool showCaloriesDelta;
  final String caloriesDelta;
  final MatchBadgeVariant matchBadgeVariant;
  final bool showSyncCards;

  const EditMealScreen({
    super.key,
    required this.meal,
    this.initialMode = MealScreenMode.edit,
    this.isNewMeal = false,
    this.openedFromLogScreen = false,
    this.selectedDate,
    this.showAllergyAlert = false,
    this.showCaloriesDelta = false,
    this.caloriesDelta = '+125',
    this.matchBadgeVariant = MatchBadgeVariant.good,
    this.showSyncCards = false,
  });

  @override
  State<EditMealScreen> createState() => _EditMealScreenState();
}

class _EditMealScreenState extends State<EditMealScreen> {
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
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  double get _totalCalories => _ingredients.fold(0, (sum, item) => sum + item.calories);

  double get _totalProteins => _ingredients.fold(0, (sum, item) => sum + item.proteins);

  double get _totalCarbs => _ingredients.fold(0, (sum, item) => sum + item.carbs);

  double get _totalFats => _ingredients.fold(0, (sum, item) => sum + item.fats);

  bool get _isEditMode => _mode == MealScreenMode.edit;

  bool get _isValid => _ingredients.isNotEmpty && _totalCalories > 0;

  bool get _isBusy => _isSaving || _isDeleting;

  bool get _canEditNutrients => SessionManager.to.editableNutrientsEnabled1.value;

  bool get _isFromToday {
    final now = DateTime.now();
    return _selectedDate.year == now.year && _selectedDate.month == now.month && _selectedDate.day == now.day;
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
      _handlePrimaryAction();
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
    if (_heroImage == null) return const SizedBox.shrink();

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: AppSizes.mealHeroHeight + _topPullExtent,
      child: ClipRect(
        child: IgnorePointer(
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
    return _meal.copyWith(ingredients: List<Ingredient>.from(_ingredients), timestamp: _applyDate(_meal.timestamp, date));
  }

  double _initialAmountValue() {
    final totalWeight = _meal.ingredients.fold<double>(0, (sum, ingredient) => sum + ingredient.weight);
    return totalWeight > 0 ? totalWeight : 1;
  }

  static const List<String> _fractionLabels = ['\u2013', '\u215B', '\u00BC', '\u2153', '\u215C', '\u00BD', '\u2154', '\u215D', '\u00BE', '\u215E'];
  static const List<double> _fractionValues = [0, 0.125, 0.25, 1 / 3, 0.375, 0.5, 2 / 3, 0.625, 0.75, 0.875];

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
    if (_isEditMode) return;
    setState(() => _mode = MealScreenMode.edit);
  }

  Future<void> _handleSaveInEditMode() async {
    if (!_isValid || _isSaving) return;

    setState(() => _isSaving = true);
    final updated = _buildWorkingMeal();

    await DayRecordController.to.saveMealForDate(date: _selectedDate, mealToSave: updated);

    if (!mounted) return;
    setState(() => _isSaving = false);
    Get.back(result: updated);
  }

  Future<void> _handleSaveInViewMode() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);
    final targetDate = widget.selectedDate ?? SelectedDateService.to.selectedDate.value;
    final mealToSave = _buildWorkingMeal(forDate: targetDate).copyWith(id: null, dayRecordId: null);

    await DayRecordController.to.saveMealForDate(date: targetDate, mealToSave: mealToSave);

    if (!mounted) return;
    setState(() => _isSaving = false);
    Get.back(result: mealToSave);
  }

  Future<void> _handleDuplicateMeal() async {
    final today = DateTime.now();
    final todayNormalized = DateTime(today.year, today.month, today.day);
    final duplicate = _buildWorkingMeal(forDate: todayNormalized).copyWith(id: null, dayRecordId: null, timestamp: today);
    await DayRecordController.to.saveMealForDate(date: todayNormalized, mealToSave: duplicate);
    SelectedDateService.to.setSelectedDate(todayNormalized);
    DashboardController.to.refresh();
    if (!mounted) return;
    GlassToast.show(
      context,
      message: tr(LocaleKeys.meal_duplicated_to, namedArgs: {'date': DateFormat.MMMMd(context.locale.languageCode).format(todayNormalized)}),
      type: GlassToastType.success,
      position: GlassToastPosition.bottom,
    );
  }

  void _openCopyToSheet() {
    if (_isBusy) return;
    MealCopyToSheet.show(
      context,
      currentDate: _selectedDate,
      onDatesSelected: (dates) => _handleCopyToMultipleDates(dates),
    );
  }

  Future<void> _handleCopyToMultipleDates(List<DateTime> dates) async {
    final baseMeal = _buildWorkingMeal();
    for (final date in dates) {
      final copy = Meal(
        name: baseMeal.name,
        ingredients: baseMeal.ingredients.map((i) => Ingredient(name: i.name, weight: i.weight, amount: i.amount, calories: i.calories, proteins: i.proteins, carbs: i.carbs, fats: i.fats, confidence: i.confidence)).toList(),
        timestamp: DateTime(date.year, date.month, date.day, baseMeal.timestamp.hour, baseMeal.timestamp.minute),
        photoPath: baseMeal.photoPath,
        isFavorite: baseMeal.isFavorite,
        confidence: baseMeal.confidence,
      );
      await DayRecordController.to.saveMealForDate(date: date, mealToSave: copy);
    }
    DashboardController.to.refresh();
    if (!mounted) return;
    GlassToast.show(
      context,
      message: tr(LocaleKeys.meal_copied_to_dates, namedArgs: {'count': '${dates.length}'}),
      type: GlassToastType.success,
      position: GlassToastPosition.bottom,
    );
  }

  Future<void> _handleSaveImageToGallery() async {
    final saved = await MediaStorage.saveToGallery(_meal.photoPath);
    if (!mounted) return;
    if (saved) {
      Get.snackbar(tr(LocaleKeys.meal_save_image), tr(LocaleKeys.meal_save_image_success), snackPosition: SnackPosition.BOTTOM);
    } else {
      Get.snackbar(tr(LocaleKeys.meal_save_image), tr(LocaleKeys.meal_save_image_error), snackPosition: SnackPosition.BOTTOM);
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
    final next = !_meal.isFavorite;
    setState(() => _meal = _meal.copyWith(isFavorite: next));

    // Always sync to template (both paths need this)
    final normalized = MealTemplate.normalize(_meal.name);
    final template = MealTemplateRepository.to.allTemplates.firstWhereOrNull((t) => t.normalizedName == normalized);
    if (template != null) await MealTemplateRepository.to.setFavorite(template, next);

    if (widget.openedFromLogScreen) return;

    // Dashboard path: also update the Meal record
    if (_meal.id == null || _meal.dayRecordId == null) return;
    await DayRecordController.to.setMealFavorite(meal: _meal, isFavorite: next);
  }

  Future<void> _handleDeleteMeal() async {
    if (_isDeleting) return;
    if (_meal.id == null) {
      Get.snackbar(tr(LocaleKeys.meal_delete_title), tr(LocaleKeys.meal_delete_message), snackPosition: SnackPosition.BOTTOM);
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
    await DayRecordController.to.deleteMeal(_meal);

    if (!mounted) return;
    setState(() => _isDeleting = false);
    Get.back(result: true);
  }

  Future<void> _handleShareMeal() async {
    final mealToShare = _buildWorkingMeal();
    final request = MealShareBuilder.fromMeal(meal: mealToShare, mealtimeLabel: _mealtimeDisplay, includePhoto: true);

    try {
      await AppShareService.share(request: request, context: context);
    } catch (_) {
      if (!mounted) return;
      Get.snackbar(tr(LocaleKeys.common_share), tr(LocaleKeys.common_something_went_wrong), snackPosition: SnackPosition.BOTTOM);
    }
  }

  void _openPhotoSheet() {
    final bool hasPhoto = _meal.photoPath != null && _meal.photoPath!.isNotEmpty;
    showGlassPopup(
      context: context,
      items: [
        GlassPopupItem(
          label: hasPhoto ? tr(LocaleKeys.meal_change_photo) : tr(LocaleKeys.meal_add_photo),
          icon: Icons.photo_outlined,
          trailingIcon: Icons.keyboard_arrow_down_rounded,
        ),
        GlassPopupItem(
          label: tr(LocaleKeys.meal_take_photo),
          showDividerAbove: true,
          onTap: () {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
            _handleTakePhoto();
          },
        ),
        GlassPopupItem(
          label: tr(LocaleKeys.meal_upload_photo),
          onTap: () {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
            _handleUploadPhoto();
          },
        ),
        if (hasPhoto)
          GlassPopupItem(
            label: tr(LocaleKeys.meal_remove_photo),
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
    showGlassPopup(
      context: context,
      items: [
        GlassPopupItem(
          label: _meal.photoPath != null && _meal.photoPath!.isNotEmpty ? tr(LocaleKeys.meal_change_photo) : tr(LocaleKeys.meal_add_photo),
          icon: Icons.photo_outlined,
          trailingIcon: Icons.chevron_right_rounded,
          onTap: () => _openPhotoSheet(),
        ),
        GlassPopupItem(
          label: tr(LocaleKeys.meal_copy_to),
          icon: Icons.copy_outlined,
          onTap: () {
            Navigator.of(context).pop();
            _openCopyToSheet();
          },
        ),
        GlassPopupItem(
          label: tr(LocaleKeys.common_share),
          icon: Icons.share_outlined,
          onTap: () {
            Navigator.of(context).pop();
            _handleShareMeal();
          },
        ),
        // GlassPopupItem(
        //   label: tr(LocaleKeys.common_report),
        //   icon: Icons.report_outlined,
        //   onTap: () {
        //     Navigator.of(context).pop();
        //     Get.to(() => const ReportMealScreen());
        //   },
        // ),
        if (!_isFromToday)
          GlassPopupItem(
            label: tr(LocaleKeys.meal_duplicate_to_today),
            icon: Icons.content_copy_outlined,
            onTap: () {
              Navigator.of(context).pop();
              _handleDuplicateMeal();
            },
          ),
        GlassPopupItem(
          label: tr(LocaleKeys.meal_save_image),
          icon: Icons.download_outlined,
          onTap: () {
            Navigator.of(context).pop();
            _handleSaveImageToGallery();
          },
        ),
        GlassPopupItem(
          label: tr(LocaleKeys.common_delete),
          icon: Icons.delete_outline,
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
    if (_isBusy) return;
    _ensureEditMode();
    AmountPickerSheet.show(
      context,
      title: _mealTitle,
      initialValue: _amountValue,
      onChanged: (value) {
        if (_amountValue == 0 || value == _amountValue) return;
        final scale = value / _amountValue;
        setState(() {
          _ingredients = _ingredients
              .map((i) => i.copyWith(
                    weight: i.weight * scale,
                    calories: i.calories * scale,
                    proteins: i.proteins * scale,
                    carbs: i.carbs * scale,
                    fats: i.fats * scale,
                  ))
              .toList();
          _amountValue = value;
        });
      },
    );
  }

  Future<void> _openNutrientEditor({required String label, required double currentValue, required void Function(double) onSave}) async {
    if (_isBusy) return;
    _ensureEditMode();
    final result = await showModalBottomSheet<double>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.xl))),
      clipBehavior: Clip.antiAlias,
      showDragHandle: false,
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
      final targetDate = widget.selectedDate ?? SelectedDateService.to.selectedDate.value;
      final mealToSave = updated.copyWith(id: null, dayRecordId: null);
      await DayRecordController.to.saveMealForDate(date: targetDate, mealToSave: mealToSave);
    } else {
      await DayRecordController.to.saveMealForDate(date: _selectedDate, mealToSave: updated);
    }
    DashboardController.to.refresh();
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

  Future<void> _openMealNameEditor() async {
    if (_isBusy) return;
    _ensureEditMode();
    final updatedName = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.xl))),
      clipBehavior: Clip.antiAlias,
      showDragHandle: false,
      isScrollControlled: true,
      builder: (context) => _MealNameEditorSheet(initialName: _meal.name),
    );

    if (updatedName == null) return;
    final nextName = updatedName.trim();
    setState(() {
      _meal = _meal.copyWith(name: nextName);
    });
    _persistCurrentState();
  }

  void _openMealtimePicker() {
    if (_isBusy) return;
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
    if (_isBusy) return;
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

  Future<void> _editIngredient(int index) async {
    final ingredient = _ingredients[index];
    final result = await Get.to<EditIngredientResult>(() => EditIngredientScreen(ingredient: ingredient));

    if (!mounted || result == null) return;
    if (result.deleted) {
      setState(() => _ingredients.removeAt(index));
    } else if (result.ingredient != null) {
      setState(() => _ingredients[index] = result.ingredient!);
    }
  }

  Future<void> _addIngredient() async {
    final newIngredient = Ingredient(name: tr(LocaleKeys.meal_new_ingredient), weight: 0, calories: 0, proteins: 0, carbs: 0, fats: 0);

    final result = await Get.to<EditIngredientResult>(() => EditIngredientScreen(ingredient: newIngredient, allowDelete: false));

    if (!mounted || result == null || result.deleted) return;
    if (result.ingredient != null) {
      setState(() => _ingredients.add(result.ingredient!));
    }
  }

  String get _primaryLabel {
    if (_isSaving) return tr(LocaleKeys.common_saving);
    return tr(LocaleKeys.common_done);
  }

  VoidCallback? get _onPrimaryTap {
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
            backgroundColor: AppColors.surface,
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
                                  decoration: const BoxDecoration(color: AppColors.surface),
                                  child: const SizedBox.expand(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.showAllergyAlert)
                              Column(
                                children: [
                                  SizedBox(
                                    height: AppSizes.mealHeroHeight + AppSizes.alertCardHeight - heroOverlap,
                                    child: Stack(
                                      children: [
                                        MealHeroHeader(title: _mealTitle, timeLabel: _formatTime(_meal.timestamp), onTitleTap: _isBusy ? null : _openMealNameEditor),
                                        Positioned(
                                          left: AppSpacing.edge,
                                          right: AppSpacing.edge,
                                          top: AppSizes.mealHeroHeight - heroOverlap,
                                          child: AllergyAlertCard(
                                            title: tr(LocaleKeys.meal_allergy_alert),
                                            subtitle: tr(LocaleKeys.meal_allergy_contains, namedArgs: {'allergen': 'Fish'}),
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
                                    ),
                                  ),
                                ],
                              )
                            else
                              SizedBox(
                                height: AppSizes.mealHeroHeight + AppSizes.caloriesCardHeight - heroOverlap,
                                child: Stack(
                                  children: [
                                    MealHeroHeader(title: _mealTitle, timeLabel: _formatTime(_meal.timestamp), onTitleTap: _isBusy ? null : _openMealNameEditor),
                                    Positioned(
                                      left: AppSpacing.edge,
                                      right: AppSpacing.edge,
                                      top: AppSizes.mealHeroHeight - heroOverlap,
                                      child: GestureDetector(
                                        onTap: _isBusy || !_canEditNutrients ? null : _openCaloriesEditor,
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
                                    child: GestureDetector(
                                      onTap: _isBusy || !_canEditNutrients ? null : _openProteinEditor,
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
                                    child: GestureDetector(
                                      onTap: _isBusy || !_canEditNutrients ? null : _openCarbsEditor,
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
                                    child: GestureDetector(
                                      onTap: _isBusy || !_canEditNutrients ? null : _openFatsEditor,
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
                            const SizedBox(height: AppSpacing.s),
                            MealRecordCard(
                              amount: _amountLabel,
                              mealtime: _mealtimeDisplay,
                              date: _formatDate(_selectedDate),
                              onAmountTap: _isBusy ? null : _openPortionPicker,
                              onMealtimeTap: _isBusy ? null : _openMealtimePicker,
                              onDateTap: _isBusy ? null : _openDatePicker,
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
                                      onTap: _isBusy
                                          ? null
                                          : () {
                                              _ensureEditMode();
                                              _addIngredient();
                                            },
                                      borderRadius: BorderRadius.circular(AppRadii.s),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.add, size: AppSizes.iconSm, color: AppColors.textTertiary),
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
                                    final isAlert = widget.showAllergyAlert && index == 0;
                                    if (!_isEditMode) {
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: AppSpacing.s),
                                        child: IngredientRow(
                                          ingredient: ingredient,
                                          highlighted: isAlert,
                                          alertText: isAlert ? 'Contains: Fish' : null,
                                          onTap: _isBusy
                                              ? null
                                              : () {
                                                  _ensureEditMode();
                                                  _editIngredient(index);
                                                },
                                          onFavorite: () {},
                                          onEdit: _isBusy
                                              ? null
                                              : () {
                                                  _ensureEditMode();
                                                  _editIngredient(index);
                                                },
                                          onDelete: _isBusy ? null : () => setState(() => _ingredients.removeAt(index)),
                                        ),
                                      );
                                    }
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: AppSpacing.s),
                                      child: EditIngredientRow(
                                        ingredient: ingredient,
                                        highlighted: isAlert,
                                        alertText: isAlert ? 'Contains: Fish' : null,
                                        onTap: _isBusy ? null : () => _editIngredient(index),
                                        onFavorite: () {},
                                        onEdit: _isBusy ? null : () => _editIngredient(index),
                                        onDelete: _isBusy ? null : () => setState(() => _ingredients.removeAt(index)),
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
                    child: _EditMealTopBar(onBack: _handleBack, isFavorite: _meal.isFavorite, onBookmark: _toggleFavorite, onMenu: _openActionSheet),
                  ),
                  if (_isBusy)
                    Positioned.fill(
                      child: ColoredBox(
                        color: AppColors.overlayDark40,
                        child: const Center(child: CircularProgressIndicator(color: AppColors.onPrimary)),
                      ),
                    ),
                ],
              ),
            ),
            bottomSheet: Container(
              decoration: BoxDecoration(
                gradient: AppGradients.bottomBarFadeGrey,
              ),
              child: SafeArea(
                top: false,
                child: EditBottomActionBar(
                  primaryLabel: _primaryLabel,
                  onPrimary: _onPrimaryTap,
                  secondaryLabel: tr(LocaleKeys.meal_fix_issue),
                  secondaryIcon: Icons.auto_fix_high,
                  onSecondary: _isBusy ? null : () => Get.to(() => FixResultScreen(baseMeal: _buildWorkingMeal(), selectedDate: _selectedDate, isNewMeal: widget.isNewMeal)),
                  padding: const EdgeInsets.fromLTRB(AppSpacing.safeAreaBottom, AppSpacing.s, AppSpacing.safeAreaBottom, 32),
                ),
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
    final hour = date.hour == 0
        ? 12
        : date.hour > 12
        ? date.hour - 12
        : date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final suffix = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $suffix';
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

class _MealNameEditorSheet extends StatefulWidget {
  final String initialName;

  const _MealNameEditorSheet({required this.initialName});

  @override
  State<_MealNameEditorSheet> createState() => _MealNameEditorSheetState();
}

class _MealNameEditorSheetState extends State<_MealNameEditorSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
            Text(tr(LocaleKeys.common_name), style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: AppSpacing.m),
            TextField(
              controller: _controller,
              autofocus: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (value) => Navigator.of(context).pop(value),
              decoration: InputDecoration(
                hintText: tr(LocaleKeys.meal_enter_meal_name),
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
                    onTap: () => Navigator.of(context).pop(_controller.text),
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

class _EditMealTopBar extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onBookmark;
  final VoidCallback onMenu;
  final bool isFavorite;

  const _EditMealTopBar({required this.onBack, required this.onBookmark, required this.onMenu, required this.isFavorite});

  @override
  Widget build(BuildContext context) {
    return CustomGlassAppBar(
      //leadingIcon: Icons.close,
      leadingIconSize: AppSizes.iconLg,
      onBack: onBack,
      actions: [
        CustomGlassIconButtonGroup(
          iconSize: AppSizes.iconLg,
          items: [(icon: isFavorite ? Icons.bookmark : Icons.bookmark_border, onPressed: onBookmark), (icon: Icons.more_horiz, onPressed: onMenu)],
        ),
      ],
    );
  }
}
