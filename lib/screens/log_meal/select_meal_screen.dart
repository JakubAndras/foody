import 'dart:async';
import 'dart:io';

import 'package:diplomka/app_theme.dart';
import 'package:diplomka/controller/dashboard_controller.dart';
import 'package:diplomka/controller/day_record_controller.dart';
import 'package:diplomka/model/ingredient.dart';
import 'package:diplomka/model/meal.dart';
import 'package:diplomka/model/meal_template.dart';
import 'package:diplomka/services/meal_template_repository.dart';
import 'package:diplomka/screens/meals/edit_meal_screen.dart';
import 'package:diplomka/screens/meals/meal_detail_screen.dart';
import 'package:diplomka/screens/log_meal/select_meal_widgets.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/utils/media_storage.dart';
import 'package:diplomka/services/language_settings_service.dart';
import 'package:diplomka/services/selected_date_service.dart';
import 'package:diplomka/services/voice/voice_transcription_service.dart';
import 'package:diplomka/widgets/custom_glass_app_bar.dart';
import 'package:diplomka/widgets/glass_popup.dart';
import 'package:diplomka/widgets/logged_snackbar.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

enum SelectMealTab { all, favorites, meals, ingredients }

enum SelectMealSort { mostRecent, aToZ, zToA, mostProtein }

class SelectMealScreen extends StatefulWidget {
  const SelectMealScreen({super.key, this.showLoading = false, this.errorMessage, this.initialTab = SelectMealTab.all});

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
  bool _showSearch = false;
  SelectMealTab _tab = SelectMealTab.all;
  SelectMealSort _sort = SelectMealSort.mostRecent;
  int _selectedMealtimeIndex = 1;

  // Voice search
  final VoiceTranscriptionService _voiceService = VoiceTranscriptionService();
  bool _isListening = false;
  bool _speechReady = false;

  @override
  void initState() {
    super.initState();
    _tab = widget.initialTab;
    _searchFocusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _voiceService.cancelListening().catchError((_) {});
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

  void _toggleSearch() {
    if (_isListening) {
      _voiceService.stopListening().catchError((_) {});
    }
    setState(() {
      _showSearch = !_showSearch;
      _isListening = false;
      if (!_showSearch) {
        _searchController.clear();
        _query = '';
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _query = '';
      _showSuggestions = false;
    });
  }

  Future<void> _toggleVoiceSearch() async {
    if (_isListening) {
      await _voiceService.stopListening();
      if (!mounted) return;
      setState(() => _isListening = false);
      return;
    }

    // Check permissions
    final micStatus = await Permission.microphone.status;
    PermissionStatus speechStatus = PermissionStatus.granted;
    if (Platform.isIOS) speechStatus = await Permission.speech.status;

    if (!micStatus.isGranted || !speechStatus.isGranted) {
      final micResult = await Permission.microphone.request();
      PermissionStatus speechResult = PermissionStatus.granted;
      if (Platform.isIOS) speechResult = await Permission.speech.request();
      if (!micResult.isGranted || !speechResult.isGranted) return;
    }

    // Initialize speech engine
    if (!_speechReady) {
      final available = await _voiceService.initialize(
        onError: (SpeechRecognitionError error) {
          if (!mounted) return;
          setState(() => _isListening = false);
        },
        onStatus: (String status) {
          if (!mounted) return;
          if (status == 'done' || status == 'notListening') {
            setState(() => _isListening = false);
          }
        },
      );
      if (!available) return;
      _speechReady = true;
    }

    // Start listening
    if (!mounted) return;
    final appLocale = context.locale;
    final preferredLanguageCode = LanguageSettingsService.to.resolveVoiceLogLanguageCode(appLanguageCode: appLocale.languageCode);

    _searchFocusNode.unfocus();
    await _voiceService.startListening(
      onResult: (SpeechRecognitionResult result) {
        if (!mounted) return;
        final text = result.recognizedWords.trim();
        _searchController.text = text;
        _searchController.selection = TextSelection.fromPosition(TextPosition(offset: text.length));
        _onSearchChanged(text);
      },
      appLocale: appLocale,
      preferredLanguageCode: preferredLanguageCode,
    );
    if (!mounted) return;
    setState(() => _isListening = true);
  }

  void _openSortPicker() {
    showGlassPopup(
      context: context,
      items: SelectMealSort.values.map((sort) {
        return GlassPopupItem(
          label: _sortLabel(sort),
          selected: _sort == sort,
          onTap: () {
            setState(() => _sort = sort);
            Navigator.of(context).pop();
          },
        );
      }).toList(),
    );
  }

  String _sortLabel(SelectMealSort sort) {
    switch (sort) {
      case SelectMealSort.mostRecent:
        return tr(LocaleKeys.common_most_recent);
      case SelectMealSort.aToZ:
        return tr(LocaleKeys.common_a_z);
      case SelectMealSort.zToA:
        return tr(LocaleKeys.common_z_a);
      case SelectMealSort.mostProtein:
        return tr(LocaleKeys.common_most_protein);
    }
  }

  void _openManualLog() {
    final selectedDate = SelectedDateService.to.selectedDate.value;
    final meal = Meal(name: '', ingredients: const [], timestamp: _applyDateToTime(DateTime.now(), selectedDate));
    Get.to(() => EditMealScreen(meal: meal, isNewMeal: true, selectedDate: selectedDate));
  }

  DateTime _applyDateToTime(DateTime source, DateTime targetDate) {
    return DateTime(targetDate.year, targetDate.month, targetDate.day, source.hour, source.minute, source.second, source.millisecond, source.microsecond);
  }

  ImageProvider? _resolveImage(String? path) {
    final file = MediaStorage.existingMealPhotoFile(path);
    if (file == null) return null;
    return FileImage(file);
  }

  List<_IngredientItem> _resolveIngredients(List<MealTemplate> templates) {
    final Map<String, _IngredientItem> unique = {};
    for (final template in templates) {
      if (template.ingredients.length <= 1) continue;
      for (final ingredient in template.ingredients) {
        unique.putIfAbsent(ingredient.name, () => _IngredientItem(ingredient: ingredient, subtitle: '${ingredient.calories.toStringAsFixed(0)} ${tr(LocaleKeys.common_kcal)}'));
      }
    }
    return unique.values.toList();
  }

  List<MealTemplate> _applyMealFilters(List<MealTemplate> templates) {
    var filtered = templates;
    if (_query.isNotEmpty) {
      filtered = filtered.where((t) => t.name.toLowerCase().contains(_query.toLowerCase())).toList();
    }
    if (_tab == SelectMealTab.favorites) {
      filtered = filtered.where((t) => t.isFavorite).toList();
    }
    switch (_sort) {
      case SelectMealSort.mostRecent:
        filtered.sort((a, b) => b.lastUsedAt.compareTo(a.lastUsedAt));
      case SelectMealSort.aToZ:
        filtered.sort((a, b) => a.name.compareTo(b.name));
      case SelectMealSort.zToA:
        filtered.sort((a, b) => b.name.compareTo(a.name));
      case SelectMealSort.mostProtein:
        filtered.sort((a, b) => b.totalProteins.compareTo(a.totalProteins));
    }
    return filtered;
  }

  List<_IngredientItem> _applyIngredientFilters(List<_IngredientItem> items, List<MealTemplate> favoriteTemplates) {
    var filtered = items;
    if (_query.isNotEmpty) {
      filtered = filtered.where((item) => item.ingredient.name.toLowerCase().contains(_query.toLowerCase())).toList();
    }
    if (_tab == SelectMealTab.favorites) {
      final favoriteIngredientNames = favoriteTemplates.expand((t) => t.ingredients).map((i) => i.name).toSet();
      filtered = filtered.where((item) => favoriteIngredientNames.contains(item.ingredient.name)).toList();
    }
    switch (_sort) {
      case SelectMealSort.mostRecent:
        break;
      case SelectMealSort.aToZ:
        filtered.sort((a, b) => a.ingredient.name.compareTo(b.ingredient.name));
      case SelectMealSort.zToA:
        filtered.sort((a, b) => b.ingredient.name.compareTo(a.ingredient.name));
      case SelectMealSort.mostProtein:
        filtered.sort((a, b) => b.ingredient.proteins.compareTo(a.ingredient.proteins));
    }
    return filtered;
  }

  Future<void> _addMealToToday(MealTemplate template) async {
    final selectedDate = SelectedDateService.to.selectedDate.value;
    final newMeal = template.toMeal(timestamp: _applyDateToTime(DateTime.now(), selectedDate));
    final savedMeal = await DayRecordController.to.saveMealForDate(date: selectedDate, mealToSave: newMeal);
    DashboardController.to.refresh();
    if (!mounted) return;
    showLoggedSnackbar(
      context: context,
      message: tr(LocaleKeys.common_food_logged),
      onView: () => Get.back(),
      onUndo: () async {
        if (savedMeal != null) {
          await DayRecordController.to.deleteMeal(savedMeal);
          DashboardController.to.refresh();
        }
      },
    );
  }

  Future<void> _addIngredientToToday(Ingredient ingredient) async {
    final selectedDate = SelectedDateService.to.selectedDate.value;
    final meal = Meal(name: ingredient.name, ingredients: [ingredient], timestamp: _applyDateToTime(DateTime.now(), selectedDate));
    final savedMeal = await DayRecordController.to.saveMealForDate(date: selectedDate, mealToSave: meal);
    DashboardController.to.refresh();
    if (!mounted) return;
    showLoggedSnackbar(
      context: context,
      message: tr(LocaleKeys.common_food_logged),
      onView: () => Get.back(),
      onUndo: () async {
        if (savedMeal != null) {
          await DayRecordController.to.deleteMeal(savedMeal);
          DashboardController.to.refresh();
        }
      },
    );
  }

  bool get _showMealsSection => _tab == SelectMealTab.all || _tab == SelectMealTab.meals || _tab == SelectMealTab.favorites;

  bool get _showIngredientsSection => _tab == SelectMealTab.all || _tab == SelectMealTab.ingredients || _tab == SelectMealTab.favorites;

  @override
  Widget build(BuildContext context) {
    return LiquidGlassScope(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: AppColors.background,
        appBar: _showSearch
            ? PreferredSize(
                preferredSize: const Size.fromHeight(AppSizes.topBarHeight),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s),
                    child: SizedBox(
                      height: AppSizes.topBarHeight,
                      child: Row(
                        children: [
                          Expanded(
                            child: GlassContainer(
                              useOwnLayer: true,
                              quality: GlassQuality.premium,
                              settings: AppGlass.standard,
                              shape: LiquidRoundedSuperellipse(borderRadius: AppRadii.pill),
                              child: SizedBox(
                                height: 44,
                                child: Row(
                                  children: [
                                    const SizedBox(width: AppSpacing.m),
                                    Icon(Icons.search_rounded, color: AppColors.textSecondary, size: AppSizes.iconMd),
                                    const SizedBox(width: AppSpacing.s),
                                    Expanded(
                                      child: TextField(
                                        controller: _searchController,
                                        focusNode: _searchFocusNode,
                                        onChanged: _onSearchChanged,
                                        autofocus: true,
                                        style: AppTextStyles.body16.copyWith(color: AppColors.textPrimary),
                                        decoration: InputDecoration(
                                          hintText: tr(LocaleKeys.meal_search_food),
                                          hintStyle: AppTextStyles.body16.copyWith(color: AppColors.textSecondary),
                                          border: InputBorder.none,
                                          isDense: true,
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                      ),
                                    ),
                                    if (_searchController.text.isNotEmpty)
                                      GestureDetector(
                                        onTap: _clearSearch,
                                        child: Icon(Icons.cancel_rounded, color: AppColors.textSecondary, size: AppSizes.iconMd),
                                      )
                                    else
                                      GestureDetector(
                                        onTap: _toggleVoiceSearch,
                                        child: Icon(Icons.mic_rounded, color: _isListening ? AppColors.error : AppColors.textSecondary, size: AppSizes.iconMd),
                                      ),
                                    const SizedBox(width: AppSpacing.m),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s),
                          CustomGlassIconButton(
                            icon: Icons.close_rounded,
                            onPressed: _toggleSearch,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            : CustomGlassAppBar(
                //leadingIcon: Icons.close,
                leadingIconSize: AppSizes.iconLg,
                onBack: () => Get.back(),
                titleWidget: Text(tr(LocaleKeys.meal_select_title), style: AppTextStyles.selectMealTitle),
                actions: [
                  CustomGlassIconButtonGroup(
                    iconSize: AppSizes.iconLg,
                    items: [
                      (icon: Icons.search_rounded, onPressed: _toggleSearch),
                      (icon: Icons.add_rounded, onPressed: _openManualLog),
                    ],
                  ),
                ],
              ),
        body: LiquidGlassBackground(
          child: Obx(() {
            final allTemplates = MealTemplateRepository.to.allTemplates.toList();
            final meals = _applyMealFilters(allTemplates);
            final favoriteTemplates = allTemplates.where((t) => t.isFavorite).toList();
            final ingredients = _applyIngredientFilters(_resolveIngredients(allTemplates), favoriteTemplates);
            final visibleMeals = _showMealsSection ? meals : <MealTemplate>[];
            final visibleIngredients = _showIngredientsSection ? ingredients : <_IngredientItem>[];
            final isEmptyState = visibleMeals.isEmpty && visibleIngredients.isEmpty;

            return SafeArea(
              bottom: false,
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.s),
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
                      child: SelectMealSegmentedTabs(
                        labels: [tr(LocaleKeys.common_all), tr(LocaleKeys.common_favorites), tr(LocaleKeys.common_meals), tr(LocaleKeys.common_ingredients)],
                        activeIndex: _tab.index,
                        onTap: (index) => setState(() => _tab = SelectMealTab.values[index]),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.s),
                  Expanded(
                    child: CustomScrollView(
                      slivers: [
                        if (widget.showLoading)
                          const SliverFillRemaining(hasScrollBody: false, child: SelectMealLoadingState())
                        else if (widget.errorMessage != null)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: SelectMealErrorState(message: widget.errorMessage!, onRetry: () => setState(() {})),
                          )
                        else if (isEmptyState)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: SelectMealEmptyState(title: tr(LocaleKeys.common_no_items_found), message: tr(LocaleKeys.common_try_adjusting_search)),
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
                                          _sortLabel(_sort),
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
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate((context, index) {
                                  final template = meals[index];
                                  final selectedDate = SelectedDateService.to.selectedDate.value;
                                  final previewMeal = template.toMeal(timestamp: _applyDateToTime(DateTime.now(), selectedDate));
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                                    child: SelectMealCard(
                                      title: template.name,
                                      kcal: template.totalCalories.toStringAsFixed(0),
                                      protein: '${template.totalProteins.toStringAsFixed(0)}g',
                                      carbs: '${template.totalCarbs.toStringAsFixed(0)}g',
                                      fats: '${template.totalFats.toStringAsFixed(0)}g',
                                      imageProvider: _resolveImage(template.photoPath),
                                      onTap: () => Get.to(() => MealDetailScreen(meal: previewMeal, openedFromLogScreen: true, selectedDate: selectedDate)),
                                      onAdd: () => _addMealToToday(template),
                                    ),
                                  );
                                }, childCount: meals.length),
                              ),
                            ),
                            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.l)),
                          ],
                          if (_showIngredientsSection) ...[
                            SliverPadding(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
                              sliver: SliverToBoxAdapter(
                                child: SelectMealSectionHeader(
                                  title: tr(LocaleKeys.common_ingredients),
                                  trailing: GestureDetector(
                                    onTap: _openSortPicker,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.tune, color: AppColors.textSecondary, size: AppSizes.iconSm),
                                        const SizedBox(width: 6),
                                        Text(
                                          _sortLabel(_sort),
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
                                delegate: SliverChildBuilderDelegate((context, index) {
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
                                }, childCount: ingredients.length),
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
            );
          }),
        ),
      ),
    );
  }
}

class _IngredientItem {
  final Ingredient ingredient;
  final String subtitle;

  const _IngredientItem({required this.ingredient, required this.subtitle});
}

class _SuggestionItem {
  final String name;
  final int frequency;

  const _SuggestionItem({required this.name, required this.frequency});
}
