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
import 'package:diplomka/screens/meals/meal_sheets.dart';
import 'package:diplomka/services/share/app_share_service.dart';
import 'package:diplomka/services/share/meal_share_builder.dart';
import 'package:diplomka/services/selected_date_service.dart';
import 'package:diplomka/utils/media_storage.dart';
import 'package:diplomka/widgets/edit_flow/edit_flow_widgets.dart';
import 'package:diplomka/widgets/liquid_glass/liquid_glass_back_button.dart';
import 'package:easy_localization/easy_localization.dart';
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
  final ScrollController _scrollController = ScrollController();
  ImageProvider? _heroImage;
  double _topPullExtent = 0;
  String _mealtime = 'Lunch'; // internal key, not displayed directly
  String _amountLabel = '400 x 1 g';
  bool _isSaving = false;
  bool _isDeleting = false;

  List<String> get _portionOptions => [
        tr(LocaleKeys.meal_portion_300g),
        tr(LocaleKeys.meal_portion_150g),
        tr(LocaleKeys.meal_portion_100g),
        tr(LocaleKeys.meal_portion_1g),
      ];

  static const List<String> _mealtimeKeys = [
    'Breakfast',
    'Morning snack',
    'Lunch',
    'Afternoon snack',
    'Dinner',
    'Second dinner',
  ];

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
    _amountLabel = _initialAmountLabel();
    _ingredients = List<Ingredient>.from(_meal.ingredients);
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
  String get _mealTitle => _meal.name.trim().isEmpty ? tr(LocaleKeys.meal_untitled) : _meal.name.trim();

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
                child: Image(
                  image: _heroImage!,
                  fit: BoxFit.cover,
                  alignment: _heroImageAlignment,
                ),
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
    return _meal.copyWith(
      ingredients: List<Ingredient>.from(_ingredients),
      timestamp: _applyDate(_meal.timestamp, date),
    );
  }

  String _initialAmountLabel() {
    final totalWeight = _meal.ingredients.fold<double>(0, (sum, ingredient) => sum + ingredient.weight);
    if (totalWeight <= 0) {
      return _portionOptions.first;
    }
    if ((totalWeight - totalWeight.roundToDouble()).abs() < 0.01) {
      return '${totalWeight.toStringAsFixed(0)} g';
    }
    return '${totalWeight.toStringAsFixed(1)} g';
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

  TimeOfDay _timeOfDayForMealtime(String mealtime) {
    switch (mealtime) {
      case 'Breakfast':
        return const TimeOfDay(hour: 8, minute: 0);
      case 'Morning snack':
        return const TimeOfDay(hour: 10, minute: 30);
      case 'Lunch':
        return const TimeOfDay(hour: 13, minute: 0);
      case 'Afternoon snack':
        return const TimeOfDay(hour: 16, minute: 0);
      case 'Dinner':
        return const TimeOfDay(hour: 19, minute: 0);
      case 'Second dinner':
        return const TimeOfDay(hour: 21, minute: 30);
    }
    return const TimeOfDay(hour: 13, minute: 0);
  }

  void _ensureEditMode() {
    if (_isEditMode) return;
    setState(() => _mode = MealScreenMode.edit);
  }

  Future<void> _handleSaveInEditMode() async {
    if (!_isValid || _isSaving) return;

    setState(() => _isSaving = true);
    final updated = _buildWorkingMeal();

    await DayRecordController.to.saveMealForDate(
      date: _selectedDate,
      mealToSave: updated,
    );

    if (!mounted) return;
    setState(() => _isSaving = false);
    Get.back(result: updated);
  }

  Future<void> _handleSaveInViewMode() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);
    final targetDate = widget.selectedDate ?? SelectedDateService.to.selectedDate.value;
    final mealToSave = _buildWorkingMeal(forDate: targetDate).copyWith(
      id: null,
      dayRecordId: null,
    );

    await DayRecordController.to.saveMealForDate(
      date: targetDate,
      mealToSave: mealToSave,
    );

    if (!mounted) return;
    setState(() => _isSaving = false);
    Get.back(result: mealToSave);
  }

  Future<void> _handleDuplicateMeal() async {
    final today = DateTime.now();
    final todayNormalized = DateTime(today.year, today.month, today.day);
    final duplicate = _buildWorkingMeal(forDate: todayNormalized).copyWith(
      id: null,
      dayRecordId: null,
      timestamp: today,
    );
    await DayRecordController.to.saveMealForDate(
      date: todayNormalized,
      mealToSave: duplicate,
    );
    SelectedDateService.to.setSelectedDate(todayNormalized);
    DashboardController.to.refresh();
    if (!mounted) return;
    Get.snackbar(tr(LocaleKeys.meal_duplicated), _meal.name, snackPosition: SnackPosition.BOTTOM);
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

  Future<void> _handlePrimaryAction() async {
    if (_isEditMode) {
      await _handleSaveInEditMode();
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

    if (_meal.id == null || _meal.dayRecordId == null) return;
    await DayRecordController.to.setMealFavorite(meal: _meal, isFavorite: next);
  }

  Future<void> _handleDeleteMeal() async {
    if (_isDeleting) return;
    if (_meal.id == null) {
      Get.snackbar(
        tr(LocaleKeys.meal_delete_title),
        tr(LocaleKeys.meal_delete_message),
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final confirm = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: EditConfirmSheet(
          title: tr(LocaleKeys.meal_delete_title),
          message: tr(LocaleKeys.meal_delete_message),
          confirmLabel: tr(LocaleKeys.common_delete),
          cancelLabel: tr(LocaleKeys.common_cancel),
          confirmColor: AppColors.destructive,
          onCancel: () => Navigator.of(context).pop(false),
          onConfirm: () => Navigator.of(context).pop(true),
        ),
      ),
    );

    if (confirm != true) return;

    setState(() => _isDeleting = true);
    await DayRecordController.to.deleteMeal(_meal);

    if (!mounted) return;
    setState(() => _isDeleting = false);
    Get.back(result: true);
  }

  Future<void> _handleShareMeal() async {
    final mealToShare = _buildWorkingMeal();
    final request = MealShareBuilder.fromMeal(
      meal: mealToShare,
      mealtimeLabel: _mealtimeDisplay,
      includePhoto: true,
    );

    try {
      await AppShareService.share(request: request, context: context);
    } catch (_) {
      if (!mounted) return;
      Get.snackbar(
        tr(LocaleKeys.common_share),
        tr(LocaleKeys.common_something_went_wrong),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _openActionSheet() {
    final double topInset = MediaQuery.of(context).padding.top;

    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Meal actions',
      barrierColor: AppColors.overlayDark40.withValues(alpha: 0.2),
      transitionDuration: AppTheme.transitionDuration,
      pageBuilder: (context, _, _) {
        return SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.of(context).pop(),
                  child: const SizedBox.expand(),
                ),
              ),
              Positioned(
                top: topInset,
                right: AppSpacing.edge,
                child: Material(
                  color: Colors.transparent,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints.tightFor(width: AppSizes.actionSheetWidth),
                    child: GlassActionSheet(
                      items: [
                        GlassActionSheetItem(
                          label: tr(LocaleKeys.common_share),
                          icon: Icons.share_outlined,
                          onTap: () {
                            Navigator.of(context).pop();
                            _handleShareMeal();
                          },
                        ),
                        GlassActionSheetItem(
                          label: tr(LocaleKeys.common_report),
                          icon: Icons.report_outlined,
                          onTap: () {
                            Navigator.of(context).pop();
                            Get.to(() => const ReportMealScreen());
                          },
                        ),
                        GlassActionSheetItem(
                          label: tr(LocaleKeys.meal_duplicate_to_today),
                          icon: Icons.content_copy_outlined,
                          onTap: () {
                            Navigator.of(context).pop();
                            _handleDuplicateMeal();
                          },
                        ),
                        GlassActionSheetItem(
                          label: tr(LocaleKeys.meal_save_image),
                          icon: Icons.download_outlined,
                          onTap: () {
                            Navigator.of(context).pop();
                            _handleSaveImageToGallery();
                          },
                        ),
                        GlassActionSheetItem(
                          label: tr(LocaleKeys.common_delete),
                          icon: Icons.delete_outline,
                          color: AppColors.destructive,
                          onTap: () {
                            Navigator.of(context).pop();
                            _handleDeleteMeal();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.96, end: 1).animate(curved),
            alignment: Alignment.topRight,
            child: child,
          ),
        );
      },
    );
  }

  void _openPortionPicker() {
    if (_isBusy) return;
    _ensureEditMode();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.lg3)),
      ),
      clipBehavior: Clip.antiAlias,
      showDragHandle: false,
      builder: (context) => SafeArea(
        top: false,
        child: PickerSheet(
          options: _portionOptions,
          selectedIndex: _portionOptions.indexOf(_amountLabel).clamp(0, _portionOptions.length - 1),
          onSelected: (index) {
            setState(() => _amountLabel = _portionOptions[index]);
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  Future<void> _openMealNameEditor() async {
    if (_isBusy) return;
    _ensureEditMode();
    final updatedName = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.lg3)),
      ),
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
  }

  void _openMealtimePicker() {
    if (_isBusy) return;
    _ensureEditMode();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.lg3)),
      ),
      clipBehavior: Clip.antiAlias,
      showDragHandle: false,
      builder: (context) => SafeArea(
        top: false,
        child: PickerSheet(
          options: _mealtimeDisplayOptions,
          selectedIndex: _mealtimeKeys.indexOf(_mealtime).clamp(0, _mealtimeKeys.length - 1),
          onSelected: (index) {
            final selectedMealtime = _mealtimeKeys[index];
            final selectedTime = _timeOfDayForMealtime(selectedMealtime);
            setState(() {
              _mealtime = selectedMealtime;
              _meal = _meal.copyWith(
                timestamp: DateTime(
                  _meal.timestamp.year,
                  _meal.timestamp.month,
                  _meal.timestamp.day,
                  selectedTime.hour,
                  selectedTime.minute,
                ),
              );
            });
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  void _openDatePicker() {
    if (_isBusy) return;
    _ensureEditMode();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.lg3)),
      ),
      clipBehavior: Clip.antiAlias,
      showDragHandle: false,
      isScrollControlled: true,
      builder: (context) {
        DateTime displayMonth = DateTime(_selectedDate.year, _selectedDate.month);
        return SafeArea(
          top: false,
          child: StatefulBuilder(
            builder: (context, setSheetState) => DatePickerCard(
              month: displayMonth,
              selectedDate: _selectedDate,
              onPrevMonth: () => setSheetState(() {
                displayMonth = DateTime(displayMonth.year, displayMonth.month - 1);
              }),
              onNextMonth: () => setSheetState(() {
                displayMonth = DateTime(displayMonth.year, displayMonth.month + 1);
              }),
              onSelected: (date) {
                final normalizedDate = DateTime(date.year, date.month, date.day);
                setState(() {
                  _selectedDate = normalizedDate;
                  _meal = _meal.copyWith(
                    timestamp: _applyDate(_meal.timestamp, normalizedDate),
                  );
                });
                Navigator.of(context).pop();
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _editIngredient(int index) async {
    final ingredient = _ingredients[index];
    final result = await Get.to<EditIngredientResult>(
      () => EditIngredientScreen(ingredient: ingredient),
    );

    if (!mounted || result == null) return;
    if (result.deleted) {
      setState(() => _ingredients.removeAt(index));
    } else if (result.ingredient != null) {
      setState(() => _ingredients[index] = result.ingredient!);
    }
  }

  Future<void> _addIngredient() async {
    final newIngredient = Ingredient(
      name: tr(LocaleKeys.meal_new_ingredient),
      weight: 0,
      calories: 0,
      proteins: 0,
      carbs: 0,
      fats: 0,
    );

    final result = await Get.to<EditIngredientResult>(
      () => EditIngredientScreen(ingredient: newIngredient, allowDelete: false),
    );

    if (!mounted || result == null || result.deleted) return;
    if (result.ingredient != null) {
      setState(() => _ingredients.add(result.ingredient!));
    }
  }

  String get _primaryLabel {
    if (_isEditMode) return _isSaving ? tr(LocaleKeys.common_saving) : tr(LocaleKeys.common_done);
    if (widget.openedFromLogScreen) return _isSaving ? tr(LocaleKeys.common_saving) : tr(LocaleKeys.common_save);
    return tr(LocaleKeys.common_edit);
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
    final double bottomActionClearance =
        AppSizes.buttonHeight + AppSpacing.s + AppSpacing.m + MediaQuery.paddingOf(context).bottom + AppSpacing.m;

    final ThemeData screenTheme = Theme.of(context).copyWith(
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
      ),
    );

    return Theme(
      data: screenTheme,
      child: Scaffold(
        backgroundColor: AppColors.backgroundAlt,
        body: Stack(
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
                            decoration: const BoxDecoration(
                              color: AppColors.backgroundAlt,
                            ),
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
                                  GestureDetector(
                                    onTap: _isBusy ? null : _openMealNameEditor,
                                    child: MealHeroHeader(
                                      title: _mealTitle,
                                      timeLabel: _formatTime(_meal.timestamp),
                                    ),
                                  ),
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
                                badge: MatchBadge(
                                  text: _matchText(widget.matchBadgeVariant),
                                  variant: widget.matchBadgeVariant,
                                ),
                              ),
                            ),
                          ],
                        )
                      else
                        SizedBox(
                          height: AppSizes.mealHeroHeight + AppSizes.caloriesCardHeight - heroOverlap,
                          child: Stack(
                            children: [
                              GestureDetector(
                                onTap: _isBusy ? null : _openMealNameEditor,
                                child: MealHeroHeader(
                                  title: _mealTitle,
                                  timeLabel: _formatTime(_meal.timestamp),
                                ),
                              ),
                              Positioned(
                                left: AppSpacing.edge,
                                right: AppSpacing.edge,
                                top: AppSizes.mealHeroHeight - heroOverlap,
                                child: CaloriesSummaryCard(
                                  label: tr(LocaleKeys.common_calories),
                                  value: _totalCalories.toStringAsFixed(0),
                                  delta: widget.showCaloriesDelta ? widget.caloriesDelta : null,
                                  height: AppSizes.caloriesCardHeight,
                                  badge: MatchBadge(
                                    text: _matchText(widget.matchBadgeVariant),
                                    variant: widget.matchBadgeVariant,
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
                              child: MacroStatCard(
                                label: tr(LocaleKeys.common_protein),
                                value: '${_totalProteins.toStringAsFixed(0)}${tr(LocaleKeys.common_g)}',
                                icon: Icons.bolt,
                                iconColor: AppColors.macroProtein,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.s),
                            Expanded(
                              child: MacroStatCard(
                                label: tr(LocaleKeys.common_carbs),
                                value: '${_totalCarbs.toStringAsFixed(0)}${tr(LocaleKeys.common_g)}',
                                icon: Icons.grain,
                                iconColor: AppColors.macroCarbsStrong,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.s),
                            Expanded(
                              child: MacroStatCard(
                                label: tr(LocaleKeys.common_fats),
                                value: '${_totalFats.toStringAsFixed(0)}${tr(LocaleKeys.common_g)}',
                                icon: Icons.opacity,
                                iconColor: AppColors.macroFats,
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
                      const SizedBox(height: AppSpacing.xl),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.edge),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(tr(LocaleKeys.meal_ingredients_title), style: AppTextStyles.sectionHeader16),
                            InkWell(
                              onTap: _isBusy
                                  ? null
                                  : () {
                                      _ensureEditMode();
                                      _addIngredient();
                                    },
                              borderRadius: BorderRadius.circular(AppRadii.sm),
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
                              ),
                            );
                          }),
                        ),
                      ),
                      if (widget.showSyncCards) ...[
                        const SizedBox(height: AppSpacing.l),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.edge),
                          child: Column(
                            children: [
                              SyncCard(
                                title: tr(LocaleKeys.meal_sync_macros_prompt),
                                primaryLabel: tr(LocaleKeys.meal_sync),
                                secondaryLabel: tr(LocaleKeys.meal_dont_sync),
                              ),
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
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.edge, 0, AppSpacing.edge, 0),
                child: _EditMealTopBar(
                  onBack: () => Navigator.of(context).maybePop(),
                  isFavorite: _meal.isFavorite,
                  onBookmark: _toggleFavorite,
                  onMenu: _openActionSheet,
                ),
              ),
            ),
            if (_isBusy)
              Positioned.fill(
                child: ColoredBox(
                  color: AppColors.overlayDark40,
                  child: const Center(
                    child: CircularProgressIndicator(color: AppColors.onPrimary),
                  ),
                ),
              ),
          ],
        ),
        bottomSheet: SafeArea(
          top: false,
          child: EditBottomActionBar(
            primaryLabel: _primaryLabel,
            onPrimary: _onPrimaryTap,
            secondaryLabel: tr(LocaleKeys.meal_fix_issue),
            secondaryIcon: Icons.auto_fix_high,
            onSecondary: _isBusy
                ? null
                : () => Get.to(
                      () => FixResultScreen(
                        baseMeal: _buildWorkingMeal(),
                        selectedDate: _selectedDate,
                        isNewMeal: widget.isNewMeal,
                      ),
                    ),
            padding: const EdgeInsets.fromLTRB(AppSpacing.edge, AppSpacing.s, AppSpacing.edge, AppSpacing.bottom),
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

  String _matchText(MatchBadgeVariant variant) {
    switch (variant) {
      case MatchBadgeVariant.medium:
        return '72% Confidence';
      case MatchBadgeVariant.low:
        return '48% Confidence';
      case MatchBadgeVariant.good:
        return '94% Confidence';
    }
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
        padding: EdgeInsets.only(
          left: AppSpacing.l,
          right: AppSpacing.l,
          top: AppSpacing.l,
          bottom: AppSpacing.l + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tr(LocaleKeys.meal_meal_name),
              style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w700),
            ),
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadii.md),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.m,
                  vertical: AppSpacing.m,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            Row(
              children: [
                Expanded(
                  child: OutlinePillButton(
                    label: tr(LocaleKeys.common_cancel),
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: AppSpacing.s),
                Expanded(
                  child: GradientPillButton(
                    label: tr(LocaleKeys.common_save),
                    gradient: AppGradients.askAiPrimary,
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

class _EditMealTopBar extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onBookmark;
  final VoidCallback onMenu;
  final bool isFavorite;

  const _EditMealTopBar({
    required this.onBack,
    required this.onBookmark,
    required this.onMenu,
    required this.isFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSizes.backButtonSize,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          LiquidGlassBackButton.back(onTap: onBack),
          Row(
            children: [
              _GlassIconButton(icon: isFavorite ? Icons.bookmark : Icons.bookmark_border, onTap: onBookmark),
              const SizedBox(width: AppSpacing.s),
              _GlassIconButton(icon: Icons.more_horiz, onTap: onMenu),
            ],
          ),
        ],
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _GlassIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        child: Ink(
          width: AppSizes.backButtonSize,
          height: AppSizes.backButtonSize,
          decoration: BoxDecoration(
            color: AppColors.glassSheet,
            border: Border.all(color: AppColors.outline),
            borderRadius: BorderRadius.circular(AppRadii.pill),
          ),
          child: Icon(icon, size: AppSizes.iconMd, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}

