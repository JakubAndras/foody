import 'dart:async';

import 'package:diplomka/app_theme.dart';
import 'package:diplomka/controller/dashboard_controller.dart';
import 'package:diplomka/controller/day_record_controller.dart';
import 'package:diplomka/model/ingredient.dart';
import 'package:diplomka/model/meal.dart';
import 'package:diplomka/screens/meals/edit_meal_screen.dart';
import 'package:diplomka/screens/meals/meal_detail_screen.dart';
import 'package:diplomka/screens/log_meal/select_meal_widgets.dart';
import 'package:diplomka/screens/logs/voice_log_screen.dart';
import 'package:diplomka/screens/scan/scan_camera_screen.dart';
import 'package:diplomka/screens/scan/scan_onboarding_screen.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/services/session_manager.dart';
import 'package:diplomka/services/selected_date_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

enum SelectMealTab { all, favorites, meals, ingredients }

enum SelectMealSort { mostRecent, alphabetic }

class SelectMealScreen extends StatefulWidget {
  const SelectMealScreen({
    super.key,
    this.showLoading = false,
    this.errorMessage,
    this.initialTab = SelectMealTab.all,
  });

  final bool showLoading;
  final String? errorMessage;
  final SelectMealTab initialTab;

  @override
  State<SelectMealScreen> createState() => _SelectMealScreenState();
}

class _SelectMealScreenState extends State<SelectMealScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _debounce;
  String _query = '';
  bool _showSuggestions = false;
  SelectMealTab _tab = SelectMealTab.all;
  SelectMealSort _sort = SelectMealSort.mostRecent;
  int _selectedMealtimeIndex = 1;

  @override
  void initState() {
    super.initState();
    _tab = widget.initialTab;
    _searchFocusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchFocusNode.removeListener(_onFocusChanged);
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    setState(() {
      _showSuggestions = _searchFocusNode.hasFocus && _searchController.text.trim().isNotEmpty;
    });
  }

  void _onSearchChanged(String value) {
    setState(() {
      _showSuggestions = _searchFocusNode.hasFocus && value.trim().isNotEmpty;
    });
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
      _showSuggestions = false;
    });
  }

  void _onSuggestionTap(String name) {
    _searchController.text = name;
    _searchController.selection = TextSelection.fromPosition(TextPosition(offset: name.length));
    setState(() {
      _query = name;
      _showSuggestions = false;
    });
    _searchFocusNode.unfocus();
  }

  List<_SuggestionItem> _computeSuggestions(List<Meal> allMeals) {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return [];

    final Map<String, int> nameFreqs = {};

    final bool includeMeals = _tab == SelectMealTab.all || _tab == SelectMealTab.meals || _tab == SelectMealTab.favorites;
    final bool includeIngredients = _tab == SelectMealTab.all || _tab == SelectMealTab.ingredients || _tab == SelectMealTab.favorites;

    for (final meal in allMeals) {
      if (includeMeals && meal.name.isNotEmpty) {
        nameFreqs[meal.name] = (nameFreqs[meal.name] ?? 0) + 1;
      }
      if (includeIngredients) {
        for (final ing in meal.ingredients) {
          if (ing.name.isNotEmpty) {
            nameFreqs[ing.name] = (nameFreqs[ing.name] ?? 0) + 1;
          }
        }
      }
    }

    final suggestions = nameFreqs.entries
        .where((e) => e.key.toLowerCase().contains(query) && e.key.toLowerCase() != query)
        .map((e) => _SuggestionItem(name: e.key, frequency: e.value))
        .toList()
      ..sort((a, b) => b.frequency.compareTo(a.frequency));

    return suggestions.take(5).toList();
  }

  void _openMealtimePicker() {
    showModalBottomSheet<void>(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.lg)),
      builder: (context) {
        return SelectMealPickerSheet(
          title: '',
          options: [tr(LocaleKeys.meal_mealtime_breakfast), tr(LocaleKeys.meal_mealtime_lunch), tr(LocaleKeys.meal_mealtime_dinner), tr(LocaleKeys.meal_mealtime_afternoon_snack)],
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
          title: tr(LocaleKeys.common_sort_by),
          options: [tr(LocaleKeys.common_most_recent), tr(LocaleKeys.common_a_z)],
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
    final selectedDate = SelectedDateService.to.selectedDate.value;
    final meal = Meal(
      name: '',
      ingredients: const [],
      timestamp: _applyDateToTime(DateTime.now(), selectedDate),
    );
    Get.to(() => EditMealScreen(
          meal: meal,
          isNewMeal: true,
          selectedDate: selectedDate,
        ));
  }

  DateTime _applyDateToTime(DateTime source, DateTime targetDate) {
    return DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day,
      source.hour,
      source.minute,
      source.second,
      source.millisecond,
      source.microsecond,
    );
  }

  List<_IngredientItem> _resolveIngredients(List<Meal> meals) {
    final Map<String, _IngredientItem> unique = {};
    for (final meal in meals) {
      for (final ingredient in meal.ingredients) {
        unique.putIfAbsent(
          ingredient.name,
          () => _IngredientItem(
            ingredient: ingredient,
            subtitle: '${ingredient.calories.toStringAsFixed(0)} ${tr(LocaleKeys.common_kcal)}',
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

  List<_IngredientItem> _applyIngredientFilters(List<_IngredientItem> items, List<Meal> favoriteMeals) {
    var filtered = items;
    if (_query.isNotEmpty) {
      filtered = filtered.where((item) => item.ingredient.name.toLowerCase().contains(_query.toLowerCase())).toList();
    }
    if (_tab == SelectMealTab.favorites) {
      final favoriteIngredientNames = favoriteMeals.expand((m) => m.ingredients).map((i) => i.name).toSet();
      filtered = filtered.where((item) => favoriteIngredientNames.contains(item.ingredient.name)).toList();
    }
    filtered.sort((a, b) => a.ingredient.name.compareTo(b.ingredient.name));
    return filtered;
  }

  Future<void> _addMealToToday(Meal meal) async {
    final selectedDate = SelectedDateService.to.selectedDate.value;
    final newMeal = meal.copyWith(
      id: null,
      dayRecordId: null,
      timestamp: _applyDateToTime(DateTime.now(), selectedDate),
    );
    await DayRecordController.to.saveMealForDate(date: selectedDate, mealToSave: newMeal);
    DashboardController.to.refresh();
    Get.back();
    Get.snackbar(tr(LocaleKeys.common_add), meal.name, snackPosition: SnackPosition.BOTTOM);
  }

  Future<void> _addIngredientToToday(Ingredient ingredient) async {
    final selectedDate = SelectedDateService.to.selectedDate.value;
    final meal = Meal(
      name: ingredient.name,
      ingredients: [ingredient],
      timestamp: _applyDateToTime(DateTime.now(), selectedDate),
    );
    await DayRecordController.to.saveMealForDate(date: selectedDate, mealToSave: meal);
    DashboardController.to.refresh();
    Get.back();
    Get.snackbar(tr(LocaleKeys.common_add), ingredient.name, snackPosition: SnackPosition.BOTTOM);
  }

  bool get _showMealsSection => _tab == SelectMealTab.all || _tab == SelectMealTab.meals || _tab == SelectMealTab.favorites;
  bool get _showIngredientsSection => _tab == SelectMealTab.all || _tab == SelectMealTab.ingredients || _tab == SelectMealTab.favorites;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Obx(() {
          final dbMeals = DayRecordController.to.dayRecords.expand((record) => record.meals).toList();
          final meals = _applyMealFilters(dbMeals);
          final favoriteMeals = dbMeals.where((m) => m.isFavorite).toList();
          final ingredients = _applyIngredientFilters(_resolveIngredients(dbMeals), favoriteMeals);
          final visibleMeals = _showMealsSection ? meals : <Meal>[];
          final visibleIngredients = _showIngredientsSection ? ingredients : <_IngredientItem>[];
          final isEmptyState = visibleMeals.isEmpty && visibleIngredients.isEmpty;

          return Column(
            children: [
              Container(
                color: AppColors.surface,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
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
                                    Text(tr(LocaleKeys.meal_select_title), style: AppTextStyles.selectMealTitle),
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
                    const SizedBox(height: AppSpacing.s),
                    SelectMealSearchBar(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      onClear: _clearSearch,
                      focusNode: _searchFocusNode,
                    ),
                    const SizedBox(height: AppSpacing.m),
                    SelectMealSegmentedTabs(
                      labels: [tr(LocaleKeys.common_all), tr(LocaleKeys.common_favorites), tr(LocaleKeys.common_meals), tr(LocaleKeys.common_ingredients)],
                      activeIndex: _tab.index,
                      onTap: (index) => setState(() => _tab = SelectMealTab.values[index]),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    Column(
                      children: [
                        const SizedBox(height: AppSpacing.s),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
                          child: Row(
                            children: [
                              Expanded(
                                child: SelectMealQuickActionTile(
                                  icon: Icons.photo_camera_outlined,
                                  label: tr(LocaleKeys.meal_meal_scan),
                                  onTap: () {
                                    if (SessionManager.to.scanOnboardingComplete.value) {
                                      Get.to(() => const ScanCameraScreen());
                                    } else {
                                      Get.to(() => const ScanOnboardingScreen());
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: AppSpacing.s),
                              Expanded(
                                child: SelectMealQuickActionTile(
                                  icon: Icons.qr_code_2,
                                  label: tr(LocaleKeys.meal_barcode_scan),
                                  onTap: () => Get.to(() => const ScanCameraScreen(initialMode: ScanMode.barcode)),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.s),
                              Expanded(
                                child: SelectMealQuickActionTile(
                                  icon: Icons.mic,
                                  label: tr(LocaleKeys.meal_voice_log),
                                  onTap: () => Get.to(() => const VoiceLogScreen()),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.s),
                              Expanded(
                                child: SelectMealQuickActionTile(
                                  icon: Icons.add,
                                  label: tr(LocaleKeys.meal_manual_log),
                                  onTap: _openManualLog,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s),
                        Expanded(
                          child: CustomScrollView(
                  slivers: [
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
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: SelectMealEmptyState(
                          title: tr(LocaleKeys.common_no_items_found),
                          message: tr(LocaleKeys.common_try_adjusting_search),
                        ),
                      )
                    else ...[
                      if (_showMealsSection) ...[
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
                          sliver: SliverToBoxAdapter(
                            child: SelectMealSectionHeader(
                              title: tr(LocaleKeys.common_meals),
                              trailing: GestureDetector(
                                onTap: _openSortPicker,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.tune, color: AppColors.textSecondary, size: AppSizes.iconSm),
                                    const SizedBox(width: 6),
                                    Text(
                                      _sort == SelectMealSort.mostRecent ? tr(LocaleKeys.common_most_recent) : tr(LocaleKeys.common_a_z),
                                      style: AppTextStyles.selectMealSegmentLabel.copyWith(color: AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.s)),
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final meal = meals[index];
                                final selectedDate = SelectedDateService.to.selectedDate.value;
                                final newMeal = meal.copyWith(
                                  id: null,
                                  dayRecordId: null,
                                  timestamp: _applyDateToTime(meal.timestamp, selectedDate),
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
                                    onTap: () => Get.to(() => MealDetailScreen(
                                          meal: newMeal,
                                          openedFromLogScreen: true,
                                          selectedDate: selectedDate,
                                        )),
                                    onAdd: () => _addMealToToday(meal),
                                  ),
                                );
                              },
                              childCount: meals.length,
                            ),
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.l)),
                      ],
                      if (_showIngredientsSection) ...[
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
                          sliver: SliverToBoxAdapter(
                            child: SelectMealSectionHeader(title: tr(LocaleKeys.common_ingredients)),
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.s)),
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final item = ingredients[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                                  child: SelectMealIngredientRow(
                                    title: item.ingredient.name,
                                    subtitle: item.subtitle,
                                    onAdd: () => _addIngredientToToday(item.ingredient),
                                    onTap: () => Get.snackbar(tr(LocaleKeys.common_ingredients), item.ingredient.name),
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
                ),
                        ),
                      ],
                    ),
                    if (_showSuggestions) ...[
                      () {
                        final suggestions = _computeSuggestions(dbMeals);
                        if (suggestions.isEmpty) return const SizedBox.shrink();
                        return Positioned(
                          top: 0,
                          left: AppSpacing.l,
                          right: AppSpacing.l,
                          child: Material(
                            elevation: 4,
                            borderRadius: BorderRadius.circular(AppRadii.md),
                            color: AppColors.surface,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(AppRadii.md),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: suggestions.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final suggestion = entry.value;
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (index > 0) Divider(height: 1, indent: AppSpacing.m + AppSizes.iconSm + AppSpacing.s, color: AppColors.border),
                                      SelectMealSuggestionTile(
                                        name: suggestion.name,
                                        frequency: suggestion.frequency,
                                        onTap: () => _onSuggestionTap(suggestion.name),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        );
                      }(),
                    ],
                  ],
                ),
              ),
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

class _SuggestionItem {
  final String name;
  final int frequency;

  const _SuggestionItem({required this.name, required this.frequency});
}

