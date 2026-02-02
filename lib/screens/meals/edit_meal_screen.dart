import 'dart:io';

import 'package:diplomka/app_theme.dart';
import 'package:diplomka/controller/day_record_controller.dart';
import 'package:diplomka/model/ingredient.dart';
import 'package:diplomka/model/meal.dart';
import 'package:diplomka/screens/ingredients/edit_ingredient_screen.dart';
import 'package:diplomka/screens/meals/fix_result_screen.dart';
import 'package:diplomka/screens/meals/report_meal_screen.dart';
import 'package:diplomka/screens/meals/meal_components.dart';
import 'package:diplomka/screens/meals/meal_sheets.dart';
import 'package:diplomka/widgets/edit_flow/edit_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditMealScreen extends StatefulWidget {
  final Meal meal;
  final bool isNewMeal;
  final DateTime? selectedDate;
  final bool showAllergyAlert;
  final bool showCaloriesDelta;
  final String caloriesDelta;
  final MatchBadgeVariant matchBadgeVariant;
  final bool showSyncCards;

  const EditMealScreen({
    super.key,
    required this.meal,
    this.isNewMeal = false,
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
  late DateTime _selectedDate;
  late List<Ingredient> _ingredients;
  String _mealtime = 'Lunch';
  String _amountLabel = '400 x 1 g';
  bool _isSaving = false;

  static const List<String> _portionOptions = [
    'portion (300 g)',
    'small portion (150 g)',
    '100 g',
    '1 g',
  ];

  static const List<String> _mealtimeOptions = [
    'Breakfast',
    'Morning snack',
    'Lunch',
    'Afternoon snack',
    'Dinner',
    'Second dinner',
  ];

  @override
  void initState() {
    super.initState();
    _meal = widget.meal;
    _selectedDate = widget.selectedDate ?? _meal.timestamp;
    _ingredients = List<Ingredient>.from(_meal.ingredients);
  }

  double get _totalCalories => _ingredients.fold(0, (sum, item) => sum + item.calories);
  double get _totalProteins => _ingredients.fold(0, (sum, item) => sum + item.proteins);
  double get _totalCarbs => _ingredients.fold(0, (sum, item) => sum + item.carbs);
  double get _totalFats => _ingredients.fold(0, (sum, item) => sum + item.fats);

  bool get _isValid => _ingredients.isNotEmpty && _totalCalories > 0;

  ImageProvider? get _heroImage {
    final path = _meal.photoPath;
    if (path == null || path.isEmpty) return null;
    final file = File(path);
    if (!file.existsSync()) return null;
    return FileImage(file);
  }

  DateTime _applyDate(DateTime original, DateTime date) {
    return DateTime(date.year, date.month, date.day, original.hour, original.minute);
  }

  Future<void> _handleSave() async {
    if (!_isValid) return;

    setState(() => _isSaving = true);
    final updated = _meal.copyWith(
      ingredients: List<Ingredient>.from(_ingredients),
      timestamp: _applyDate(_meal.timestamp, _selectedDate),
    );

    await DayRecordController.to.saveMealForDate(
      date: _selectedDate,
      mealToSave: updated,
    );

    if (!mounted) return;
    setState(() => _isSaving = false);
    Get.back(result: updated);
  }

  Future<void> _toggleFavorite() async {
    final next = !_meal.isFavorite;
    setState(() => _meal = _meal.copyWith(isFavorite: next));

    if (_meal.id == null || _meal.dayRecordId == null) return;
    await DayRecordController.to.setMealFavorite(meal: _meal, isFavorite: next);
  }

  Future<void> _handleDeleteMeal() async {
    final confirm = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: EditConfirmSheet(
          title: 'Delete meal?',
          message: 'This will remove the meal and all its ingredients.',
          confirmLabel: 'Delete',
          cancelLabel: 'Cancel',
          confirmColor: AppColors.destructive,
          onCancel: () => Navigator.of(context).pop(false),
          onConfirm: () => Navigator.of(context).pop(true),
        ),
      ),
    );

    if (confirm == true) {
      await DayRecordController.to.deleteMeal(_meal);
      if (mounted) Get.back();
    }
  }

  void _openActionSheet() {
    final double topInset = MediaQuery.of(context).padding.top;
    final double topOffset = topInset + AppSpacing.md + AppSizes.mealTopBarHeight;

    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Meal actions',
      barrierColor: AppColors.overlayDark40.withValues(alpha: 0.2),
      transitionDuration: AppTheme.transitionDuration,
      pageBuilder: (context, _, __) {
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
                top: topOffset,
                right: AppSpacing.edge,
                child: Material(
                  color: Colors.transparent,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints.tightFor(width: AppSizes.actionSheetWidth),
                    child: GlassActionSheet(
                      items: [
                        GlassActionSheetItem(
                          label: 'Share',
                          icon: Icons.share_outlined,
                          onTap: () {
                            Navigator.of(context).pop();
                            Get.snackbar('Share', 'Sharing is not implemented yet.');
                          },
                        ),
                        GlassActionSheetItem(
                          label: 'Report',
                          icon: Icons.report_outlined,
                          onTap: () {
                            Navigator.of(context).pop();
                            Get.to(() => const ReportMealScreen());
                          },
                        ),
                        GlassActionSheetItem(
                          label: 'Save Image',
                          icon: Icons.download_outlined,
                          onTap: () {
                            Navigator.of(context).pop();
                            Get.snackbar('Save Image', 'Saving is not implemented yet.');
                          },
                        ),
                        GlassActionSheetItem(
                          label: 'Delete',
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
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
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

  void _openMealtimePicker() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: PickerSheet(
          options: _mealtimeOptions,
          selectedIndex: _mealtimeOptions.indexOf(_mealtime).clamp(0, _mealtimeOptions.length - 1),
          onSelected: (index) {
            setState(() => _mealtime = _mealtimeOptions[index]);
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  void _openDatePicker() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        DateTime displayMonth = DateTime(_selectedDate.year, _selectedDate.month);
        return StatefulBuilder(
          builder: (context, setSheetState) => Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: DatePickerCard(
              month: displayMonth,
              selectedDate: _selectedDate,
              onPrevMonth: () => setSheetState(() {
                displayMonth = DateTime(displayMonth.year, displayMonth.month - 1);
              }),
              onNextMonth: () => setSheetState(() {
                displayMonth = DateTime(displayMonth.year, displayMonth.month + 1);
              }),
              onSelected: (date) {
                setState(() => _selectedDate = date);
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
      name: 'New Ingredient',
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

  @override
  Widget build(BuildContext context) {
    final bool showIngredientsError = _ingredients.isEmpty;
    final bool showCaloriesError = _ingredients.isNotEmpty && _totalCalories <= 0;
    final double heroOverlap = AppSpacing.lg;

    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: AppSizes.buttonHeight + AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.showAllergyAlert)
                  Column(
                    children: [
                      SizedBox(
                        height: AppSizes.mealHeroHeight + AppSizes.alertCardHeight - heroOverlap,
                        child: Stack(
                          children: [
                            MealHeroHeader(
                              title: _meal.name,
                              timeLabel: _formatTime(_meal.timestamp),
                              image: _heroImage,
                            ),
                            Positioned(
                              left: AppSpacing.edge,
                              right: AppSpacing.edge,
                              top: AppSizes.mealHeroHeight - heroOverlap,
                              child: const AllergyAlertCard(
                                title: 'Allergy Alert',
                                subtitle: 'This meal contains: Fish',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.edge),
                        child: CaloriesSummaryCard(
                          label: 'Calories',
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
                        MealHeroHeader(
                          title: _meal.name,
                          timeLabel: _formatTime(_meal.timestamp),
                          image: _heroImage,
                        ),
                        Positioned(
                          left: AppSpacing.edge,
                          right: AppSpacing.edge,
                          top: AppSizes.mealHeroHeight - heroOverlap,
                          child: CaloriesSummaryCard(
                            label: 'Calories',
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
                const SizedBox(height: AppSpacing.sm),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.edge),
                  child: Row(
                    children: [
                      MacroStatCard(
                        label: 'Protein',
                        value: '${_totalProteins.toStringAsFixed(0)}g',
                        icon: Icons.bolt,
                        iconColor: AppColors.macroProtein,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      MacroStatCard(
                        label: 'Carbs',
                        value: '${_totalCarbs.toStringAsFixed(0)}g',
                        icon: Icons.grain,
                        iconColor: AppColors.macroCarbsStrong,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      MacroStatCard(
                        label: 'Fats',
                        value: '${_totalFats.toStringAsFixed(0)}g',
                        icon: Icons.opacity,
                        iconColor: AppColors.macroFats,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                MealRecordCard(
                  amount: _amountLabel,
                  mealtime: _mealtime,
                  date: _formatDate(_selectedDate),
                  onAmountTap: _openPortionPicker,
                  onMealtimeTap: _openMealtimePicker,
                  onDateTap: _openDatePicker,
                  margin: const EdgeInsets.symmetric(horizontal: AppSpacing.edge),
                ),
                const SizedBox(height: AppSpacing.xl),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.edge),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Ingredients', style: AppTextStyles.sectionHeader16),
                      InkWell(
                        onTap: _addIngredient,
                        borderRadius: BorderRadius.circular(AppRadii.sm),
                        child: Row(
                          children: [
                            const Icon(Icons.add, size: AppSizes.iconSm, color: AppColors.textTertiary),
                            const SizedBox(width: AppSpacing.xxs),
                            Text(
                              'Add',
                              style: AppTextStyles.caption12.copyWith(color: AppColors.textTertiary, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (showIngredientsError)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.edge),
                    child: InlineErrorText(message: 'Add at least one ingredient.'),
                  )
                else if (showCaloriesError)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.edge),
                    child: InlineErrorText(message: 'Calories must be greater than 0.'),
                  ),
                const SizedBox(height: AppSpacing.sm),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.edge),
                  child: Column(
                    children: List.generate(_ingredients.length, (index) {
                      final ingredient = _ingredients[index];
                      final isAlert = widget.showAllergyAlert && index == 0;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: EditIngredientRow(
                          ingredient: ingredient,
                          highlighted: isAlert,
                          alertText: isAlert ? 'Contains: Fish' : null,
                          onTap: () => _editIngredient(index),
                        ),
                      );
                    }),
                  ),
                ),
                if (widget.showSyncCards) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.edge),
                    child: Column(
                      children: const [
                        SyncCard(
                          title: 'Calories changed. Sync macros to match?',
                          primaryLabel: 'Sync',
                          secondaryLabel: "Don't sync",
                        ),
                        SizedBox(height: AppSpacing.md),
                        SyncCard(
                          title: 'Macros changed. Sync calories to match?',
                          primaryLabel: 'Sync',
                          secondaryLabel: "Don't sync",
                        ),
                        SizedBox(height: AppSpacing.md),
                        SyncCard(
                          title: 'Always sync automatically?',
                          primaryLabel: 'Always sync',
                          secondaryLabel: 'Decide later',
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.edge, AppSpacing.md, AppSpacing.edge, AppSpacing.md),
              child: _EditMealTopBar(
                onBack: () => Navigator.of(context).maybePop(),
                isFavorite: _meal.isFavorite,
                onBookmark: _toggleFavorite,
                onMenu: _openActionSheet,
              ),
            ),
          ),
          if (_isSaving)
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
      bottomNavigationBar: SafeArea(
        top: false,
        child: EditBottomActionBar(
          primaryLabel: 'Done',
          onPrimary: _isSaving || !_isValid ? null : _handleSave,
          secondaryLabel: 'Fix Issue',
          secondaryIcon: Icons.auto_fix_high,
          onSecondary: () => Get.to(
            () => FixResultScreen(
              baseMeal: _meal,
              selectedDate: _selectedDate,
              isNewMeal: widget.isNewMeal,
            ),
          ),
          padding: const EdgeInsets.fromLTRB(AppSpacing.edge, AppSpacing.sm, AppSpacing.edge, AppSpacing.md),
        ),
      ),
    );
  }

  String _formatTime(DateTime date) {
    final hour = date.hour == 0 ? 12 : date.hour > 12 ? date.hour - 12 : date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final suffix = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $suffix';
  }

  String _formatDate(DateTime date) {
    return '${date.day}. ${date.month}. ${date.year}';
  }

  String _matchText(MatchBadgeVariant variant) {
    switch (variant) {
      case MatchBadgeVariant.medium:
        return '72% Match';
      case MatchBadgeVariant.low:
        return '48% Match';
      case MatchBadgeVariant.good:
        return '94% Match';
    }
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
      height: AppSizes.mealTopBarHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _GlassIconButton(icon: Icons.chevron_left, onTap: onBack),
          Row(
            children: [
              _GlassIconButton(icon: isFavorite ? Icons.bookmark : Icons.bookmark_border, onTap: onBookmark),
              const SizedBox(width: AppSpacing.sm),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.pill),
      child: Ink(
        width: AppSizes.backButtonSize,
        height: AppSizes.backButtonSize,
        decoration: BoxDecoration(
          color: AppColors.glassSheet,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          boxShadow: AppShadows.cardSmall,
        ),
        child: Icon(icon, size: AppSizes.iconMd, color: AppColors.textPrimary),
      ),
    );
  }
}
