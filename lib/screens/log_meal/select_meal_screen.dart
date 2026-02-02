import 'dart:async';

import 'package:diplomka/app_theme.dart';
import 'package:diplomka/controller/day_record_controller.dart';
import 'package:diplomka/model/ingredient.dart';
import 'package:diplomka/model/meal.dart';
import 'package:diplomka/screens/meals/edit_meal_screen.dart';
import 'package:diplomka/screens/log_meal/select_meal_widgets.dart';
import 'package:diplomka/screens/logs/voice_log_screen.dart';
import 'package:diplomka/screens/scan/scan_camera_screen.dart';
import 'package:diplomka/screens/scan/scan_onboarding_screen.dart';
import 'package:diplomka/services/session_manager.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

enum SelectMealTab { all, favorites, meals, ingredients }

enum SelectMealSort { mostRecent, alphabetic }

class SelectMealScreen extends StatefulWidget {
  const SelectMealScreen({
    super.key,
    this.showLoading = false,
    this.errorMessage,
    this.useMockData = true,
    this.initialTab = SelectMealTab.all,
  });

  final bool showLoading;
  final String? errorMessage;
  final bool useMockData;
  final SelectMealTab initialTab;

  @override
  State<SelectMealScreen> createState() => _SelectMealScreenState();
}

class _SelectMealScreenState extends State<SelectMealScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  String _query = '';
  SelectMealTab _tab = SelectMealTab.all;
  SelectMealSort _sort = SelectMealSort.mostRecent;
  int _selectedMealtimeIndex = 1;

  @override
  void initState() {
    super.initState();
    _tab = widget.initialTab;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      setState(() {
        _query = value.trim();
      });
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _query = '';
    });
  }

  void _openMealtimePicker() {
    showModalBottomSheet<void>(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.lg)),
      builder: (context) {
        return SelectMealPickerSheet(
          title: '',
          options: const ['Breakfast', 'Lunch', 'Dinner', 'Snack'],
          selectedIndex: _selectedMealtimeIndex,
          onSelected: (index) {
            setState(() {
              _selectedMealtimeIndex = index;
            });
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  void _openSortPicker() {
    showModalBottomSheet<void>(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.lg)),
      builder: (context) {
        return SelectMealPickerSheet(
          title: 'Sort by',
          options: const ['Most Recent', 'A-Z'],
          selectedIndex: _sort == SelectMealSort.mostRecent ? 0 : 1,
          onSelected: (index) {
            setState(() {
              _sort = index == 0 ? SelectMealSort.mostRecent : SelectMealSort.alphabetic;
            });
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  void _openManualLog() {
    final meal = Meal(name: '', ingredients: const [], timestamp: DateTime.now());
    Get.to(() => EditMealScreen(
          meal: meal,
          isNewMeal: true,
          selectedDate: DateTime.now(),
        ));
  }

  List<_IngredientItem> _resolveIngredients(List<Meal> meals) {
    final Map<String, _IngredientItem> unique = {};
    for (final meal in meals) {
      for (final ingredient in meal.ingredients) {
        unique.putIfAbsent(
          ingredient.name,
          () => _IngredientItem(
            ingredient: ingredient,
            subtitle: '${ingredient.calories.toStringAsFixed(0)} kcal',
          ),
        );
      }
    }
    return unique.values.toList();
  }

  List<Meal> _applyMealFilters(List<Meal> meals) {
    var filtered = meals;
    if (_query.isNotEmpty) {
      filtered = filtered.where((meal) => meal.name.toLowerCase().contains(_query.toLowerCase())).toList();
    }
    if (_tab == SelectMealTab.favorites) {
      filtered = filtered.where((meal) => meal.isFavorite).toList();
    }
    if (_sort == SelectMealSort.mostRecent) {
      filtered.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } else {
      filtered.sort((a, b) => a.name.compareTo(b.name));
    }
    return filtered;
  }

  List<_IngredientItem> _applyIngredientFilters(List<_IngredientItem> items) {
    var filtered = items;
    if (_query.isNotEmpty) {
      filtered = filtered.where((item) => item.ingredient.name.toLowerCase().contains(_query.toLowerCase())).toList();
    }
    if (_tab == SelectMealTab.favorites) {
      filtered = filtered.where((item) => _favoriteIngredientNames.contains(item.ingredient.name)).toList();
    }
    filtered.sort((a, b) => a.ingredient.name.compareTo(b.ingredient.name));
    return filtered;
  }

  bool get _showMealsSection => _tab == SelectMealTab.all || _tab == SelectMealTab.meals || _tab == SelectMealTab.favorites;
  bool get _showIngredientsSection =>
      _tab == SelectMealTab.all || _tab == SelectMealTab.ingredients || _tab == SelectMealTab.favorites;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundSoft,
      body: SafeArea(
        bottom: false,
        child: Obx(() {
          final dbMeals = DayRecordController.to.dayRecords.expand((record) => record.meals).toList();
          final useMock = widget.useMockData && dbMeals.isEmpty;
          final baseMeals = useMock ? _mockMeals : dbMeals;
          final meals = _applyMealFilters(baseMeals);
          final ingredients = _applyIngredientFilters(useMock ? _mockIngredients : _resolveIngredients(dbMeals));
          final visibleMeals = _showMealsSection ? meals : <Meal>[];
          final visibleIngredients = _showIngredientsSection ? ingredients : <_IngredientItem>[];
          final isEmptyState = visibleMeals.isEmpty && visibleIngredients.isEmpty;

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  color: AppColors.surface,
                  padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.md),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 40,
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => Get.back(),
                              child: const SizedBox(
                                width: 40,
                                height: 40,
                                child: Icon(Icons.close, color: AppColors.primary),
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: GestureDetector(
                                  onTap: _openMealtimePicker,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('Select a Meal', style: AppTextStyles.selectMealTitle),
                                      const SizedBox(width: AppSpacing.xs),
                                      const Icon(Icons.keyboard_arrow_down, color: AppColors.primary, size: AppSizes.iconMd),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 40, height: 40),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      SelectMealSearchBar(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        onClear: _clearSearch,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      SelectMealSegmentedTabs(
                        labels: const ['All', 'Favorites', 'Meals', 'Ingredients'],
                        activeIndex: _tab.index,
                        onTap: (index) => setState(() => _tab = SelectMealTab.values[index]),
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      Expanded(
                        child: SelectMealQuickActionTile(
                          icon: Icons.photo_camera_outlined,
                          label: 'Meal scan',
                          onTap: () {
                            if (SessionManager.to.scanOnboardingComplete.value) {
                              Get.to(() => const ScanCameraScreen());
                            } else {
                              Get.to(() => const ScanOnboardingScreen());
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: SelectMealQuickActionTile(
                          icon: Icons.qr_code_2,
                          label: 'Barcode scan',
                          onTap: () => Get.to(() => const ScanCameraScreen(initialMode: ScanMode.barcode)),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: SelectMealQuickActionTile(
                          icon: Icons.mic,
                          label: 'Voice log',
                          onTap: () => Get.to(() => const VoiceLogScreen()),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: SelectMealQuickActionTile(
                          icon: Icons.add,
                          label: 'Manual log',
                          onTap: _openManualLog,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
              if (widget.showLoading)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: SelectMealLoadingState(),
                )
              else if (widget.errorMessage != null)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: SelectMealErrorState(
                    message: widget.errorMessage!,
                    onRetry: () => setState(() {}),
                  ),
                )
              else if (isEmptyState)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: SelectMealEmptyState(
                    title: 'No items found',
                    message: 'Try adjusting your search or filters.',
                  ),
                )
              else ...[
                if (_showMealsSection) ...[
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    sliver: SliverToBoxAdapter(
                      child: SelectMealSectionHeader(
                        title: 'Meals',
                        trailing: GestureDetector(
                          onTap: _openSortPicker,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.tune, color: AppColors.textSecondary, size: AppSizes.iconSm),
                              const SizedBox(width: 6),
                              Text(
                                _sort == SelectMealSort.mostRecent ? 'Most Recent' : 'A-Z',
                                style: AppTextStyles.selectMealSegmentLabel.copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm)),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final meal = meals[index];
                          final newMeal = meal.copyWith(
                            id: null,
                            dayRecordId: null,
                            timestamp: DateTime.now(),
                          );
                          return Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                            child: SelectMealCard(
                              title: meal.name,
                              kcal: meal.totalCalories.toStringAsFixed(0),
                              protein: '${meal.totalProteins.toStringAsFixed(0)}g',
                              carbs: '${meal.totalCarbs.toStringAsFixed(0)}g',
                              fats: '${meal.totalFats.toStringAsFixed(0)}g',
                              imageProvider: null,
                              onTap: () => Get.to(() => EditMealScreen(
                                    meal: newMeal,
                                    isNewMeal: true,
                                    selectedDate: DateTime.now(),
                                  )),
                            ),
                          );
                        },
                        childCount: meals.length,
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
                ],
                if (_showIngredientsSection) ...[
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    sliver: const SliverToBoxAdapter(
                      child: SelectMealSectionHeader(title: 'Ingredients'),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm)),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final item = ingredients[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                            child: SelectMealIngredientRow(
                              title: item.ingredient.name,
                              subtitle: item.subtitle,
                              onAdd: () => Get.snackbar('Added', '${item.ingredient.name} added'),
                              onTap: () => Get.snackbar('Ingredient', item.ingredient.name),
                            ),
                          );
                        },
                        childCount: ingredients.length,
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
                ],
              ],
            ],
          );
        }),
      ),
    );
  }
}

class _IngredientItem {
  final Ingredient ingredient;
  final String subtitle;

  const _IngredientItem({
    required this.ingredient,
    required this.subtitle,
  });
}

final List<Meal> _mockMeals = [
  Meal(
    name: 'Salmon & Vegetables',
    ingredients: [
      Ingredient(name: 'Salmon Fillet', weight: 200, calories: 565, proteins: 48, carbs: 0, fats: 24),
      Ingredient(name: 'Quinoa', weight: 120, calories: 200, proteins: 0, carbs: 32, fats: 0),
      Ingredient(name: 'Broccoli', weight: 80, calories: 45, proteins: 0, carbs: 0, fats: 0),
    ],
    timestamp: DateTime.now().subtract(const Duration(hours: 3)),
    isFavorite: true,
  ),
  Meal(
    name: 'Salmon & Vegetables',
    ingredients: [
      Ingredient(name: 'Salmon Fillet', weight: 200, calories: 565, proteins: 48, carbs: 32, fats: 24),
    ],
    timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
  ),
  Meal(
    name: 'Salmon & Vegetables',
    ingredients: [
      Ingredient(name: 'Salmon Fillet', weight: 200, calories: 565, proteins: 48, carbs: 32, fats: 24),
    ],
    timestamp: DateTime.now().subtract(const Duration(days: 2)),
  ),
];

final List<_IngredientItem> _mockIngredients = [
  _IngredientItem(
    ingredient: Ingredient(name: 'Banana', weight: 118, calories: 105, proteins: 1, carbs: 27, fats: 0),
    subtitle: '105 kcal, medium',
  ),
  _IngredientItem(
    ingredient: Ingredient(name: 'Olive oil', weight: 14, calories: 126, proteins: 0, carbs: 0, fats: 14),
    subtitle: '126 kcal',
  ),
];

final Set<String> _favoriteIngredientNames = {'Banana'};
