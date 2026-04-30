import 'dart:async';
import 'dart:io';

import 'package:diplomka/app_theme.dart';
import 'package:diplomka/controller/dashboard_controller.dart';
import 'package:diplomka/controller/day_record_controller.dart';
import 'package:diplomka/model/ingredient.dart';
import 'package:diplomka/model/meal.dart';
// RESEARCH-ONLY: import for research-only inputSource tagging
import 'package:diplomka/model/meal_entry_source.dart';
import 'package:diplomka/model/meal_template.dart';
import 'package:diplomka/services/meal_template_repository.dart';
import 'package:diplomka/model/ingredient_template.dart';
import 'package:diplomka/services/ingredient_template_repository.dart';
import 'package:diplomka/screens/ingredients/edit_ingredient_screen.dart';
import 'package:diplomka/screens/meals/edit_meal_screen.dart';
import 'package:diplomka/screens/meals/meal_components.dart';
import 'package:diplomka/screens/meals/meal_detail_screen.dart';
import 'package:diplomka/screens/log_meal/select_meal_widgets.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/utils/media_storage.dart';
import 'package:diplomka/screens/main_screen.dart';
import 'package:diplomka/services/language_settings_service.dart';
import 'package:diplomka/services/selected_date_service.dart';
import 'package:diplomka/services/voice/voice_transcription_service.dart';
import 'package:diplomka/widgets/custom_glass_app_bar.dart';
import 'package:diplomka/widgets/glass_popup.dart';
import 'package:diplomka/widgets/logged_snackbar.dart';
import 'package:diplomka/widgets/recently_uploaded_card.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
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
  late final PageController _pageController;
  int _selectedMealtimeIndex = 1;

  // Voice search
  final VoiceTranscriptionService _voiceService = VoiceTranscriptionService();
  bool _isListening = false;
  bool _speechReady = false;

  @override
  void initState() {
    super.initState();
    _tab = widget.initialTab;
    _pageController = PageController(initialPage: widget.initialTab.index);
    _searchFocusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _voiceService.cancelListening().catchError((_) {});
    _pageController.dispose();
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

  void _onTabChanged(int index) {
    if (index == _tab.index) return;
    _pageController.animateToPage(index, duration: const Duration(milliseconds: 420), curve: Curves.easeOutCubic);
  }

  void _onPageChanged(int index) {
    setState(() => _tab = SelectMealTab.values[index]);
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
    // RESEARCH-ONLY: inputSource arg is research-only
    final meal = Meal(name: '', ingredients: const [], timestamp: _applyDateToTime(DateTime.now(), selectedDate), inputSource: MealEntrySource.manual.code);
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

  List<_IngredientItem> _resolveIngredients() {
    return IngredientTemplateRepository.to.allTemplates.map((t) => _IngredientItem(ingredient: t.toIngredient(), subtitle: '${t.calories.toStringAsFixed(0)} ${tr(LocaleKeys.common_kcal)}', template: t)).toList();
  }

  List<MealTemplate> _applyMealFilters(List<MealTemplate> templates, {required SelectMealTab tab}) {
    var filtered = templates;
    if (_query.isNotEmpty) {
      filtered = filtered.where((t) => t.name.toLowerCase().contains(_query.toLowerCase())).toList();
    }
    if (tab == SelectMealTab.favorites) {
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

  List<_IngredientItem> _applyIngredientFilters(List<_IngredientItem> items, {required SelectMealTab tab}) {
    var filtered = items;
    if (_query.isNotEmpty) {
      filtered = filtered.where((item) => item.ingredient.name.toLowerCase().contains(_query.toLowerCase())).toList();
    }
    if (tab == SelectMealTab.favorites) {
      filtered = filtered.where((item) => item.template?.isFavorite == true).toList();
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
    // RESEARCH-ONLY: inputSource copyWith is research-only
    final newMeal = template.toMeal(timestamp: _applyDateToTime(DateTime.now(), selectedDate)).copyWith(inputSource: MealEntrySource.manual.code);
    final savedMeal = await DayRecordController.to.saveMealForDate(date: selectedDate, mealToSave: newMeal);
    DashboardController.to.refresh();
    if (!mounted) return;
    showSnackBar(
      context: context,
      message: tr(LocaleKeys.common_food_logged),
      primaryLabel: tr(LocaleKeys.common_view),
      onPrimary: () {
        SelectedDateService.to.selectedDate.value = selectedDate;
        MainScreenController.to.showDashboardTab();
        Get.back();
      },
      secondaryLabel: tr(LocaleKeys.common_undo),
      onSecondary: () async {
        if (savedMeal != null) {
          await DayRecordController.to.deleteMeal(savedMeal);
          DashboardController.to.refresh();
        }
      },
    );
  }

  Future<void> _addIngredientToToday(Ingredient ingredient) async {
    final selectedDate = SelectedDateService.to.selectedDate.value;
    // RESEARCH-ONLY: inputSource arg is research-only
    final meal = Meal(name: ingredient.name, ingredients: [ingredient], timestamp: _applyDateToTime(DateTime.now(), selectedDate), inputSource: MealEntrySource.manual.code);
    final savedMeal = await DayRecordController.to.saveMealForDate(date: selectedDate, mealToSave: meal);
    DashboardController.to.refresh();
    if (!mounted) return;
    showSnackBar(
      context: context,
      message: tr(LocaleKeys.common_food_logged),
      primaryLabel: tr(LocaleKeys.common_view),
      onPrimary: () {
        SelectedDateService.to.selectedDate.value = selectedDate;
        MainScreenController.to.showDashboardTab();
        Get.back();
      },
      secondaryLabel: tr(LocaleKeys.common_undo),
      onSecondary: () async {
        if (savedMeal != null) {
          await DayRecordController.to.deleteMeal(savedMeal);
          DashboardController.to.refresh();
        }
      },
    );
  }

  Widget _buildPage(SelectMealTab tab) {
    return Obx(() {
      final allTemplates = MealTemplateRepository.to.allTemplates.toList();
      IngredientTemplateRepository.to.allTemplates.length;
      final allIngredients = _resolveIngredients();
      final showMeals = tab == SelectMealTab.all || tab == SelectMealTab.meals || tab == SelectMealTab.favorites;
      final showIngredients = tab == SelectMealTab.all || tab == SelectMealTab.ingredients || tab == SelectMealTab.favorites;
      final meals = showMeals ? _applyMealFilters(allTemplates, tab: tab) : <MealTemplate>[];
      final ingredients = showIngredients ? _applyIngredientFilters(allIngredients, tab: tab) : <_IngredientItem>[];
      final isEmpty = meals.isEmpty && ingredients.isEmpty;

      return CustomScrollView(
        slivers: [
        if (isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: SelectMealEmptyState(title: tr(LocaleKeys.common_no_items_found), message: tr(LocaleKeys.common_try_adjusting_search)),
          )
        else ...[
          if (showMeals && meals.isNotEmpty) ...[
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
                        Icon(CupertinoIcons.slider_horizontal_3, color: AppColors.textSecondary, size: AppSizes.iconSm),
                        const SizedBox(width: 6),
                        Text(_sortLabel(_sort), style: AppTextStyles.body14.copyWith(color: AppColors.textSecondary, letterSpacing: -0.1504)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final template = meals[index];
                  final selectedDate = SelectedDateService.to.selectedDate.value;
                  final previewMeal = template.toMeal(timestamp: _applyDateToTime(DateTime.now(), selectedDate));
                  return MealItemCard(
                    name: template.name,
                    kcalText: '${template.totalCalories.toStringAsFixed(0)} ${tr(LocaleKeys.common_kcal)}',
                    proteins: template.totalProteins,
                    carbs: template.totalCarbs,
                    fats: template.totalFats,
                    imageProvider: _resolveImage(template.photoPath),
                    onTap: () => Get.to(() => MealDetailScreen(meal: previewMeal, openedFromLogScreen: true, selectedDate: selectedDate)),
                    onAdd: () => _addMealToToday(template),
                  );
                }, childCount: meals.length),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxs)),
          ],
          if (showIngredients && ingredients.isNotEmpty) ...[
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
              sliver: SliverToBoxAdapter(
                child: SelectMealSectionHeader(
                  title: tr(LocaleKeys.common_ingredients),
                  trailing: (!showMeals || meals.isEmpty)
                      ? GestureDetector(
                          onTap: _openSortPicker,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(CupertinoIcons.slider_horizontal_3, color: AppColors.textSecondary, size: AppSizes.iconSm),
                              const SizedBox(width: 6),
                              Text(_sortLabel(_sort), style: AppTextStyles.body14.copyWith(color: AppColors.textSecondary, letterSpacing: -0.1504)),
                            ],
                          ),
                        )
                      : null,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xs)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final item = ingredients[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                    child: IngredientRow(
                      ingredient: item.ingredient,
                      onAdd: () => _addIngredientToToday(item.ingredient),
                      onTap: () async {
                        final result = await Get.to<EditIngredientResult>(() => EditIngredientScreen(ingredient: item.ingredient, allowDelete: false));
                        if (result?.ingredient != null && item.template != null) {
                          await IngredientTemplateRepository.to.upsertFromIngredient(result!.ingredient!);
                        }
                      },
                    ),
                  );
                }, childCount: ingredients.length),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
          ],
        ],
        ],
      );
    });
  }

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
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
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
                                    Icon(CupertinoIcons.search, color: AppColors.textSecondary, size: AppSizes.iconMd),
                                    const SizedBox(width: AppSpacing.s),
                                    Expanded(
                                      child: TextField(
                                        controller: _searchController,
                                        focusNode: _searchFocusNode,
                                        onChanged: _onSearchChanged,
                                        autofocus: true,
                                        maxLength: 200,
                                        style: AppTextStyles.body16.copyWith(color: AppColors.textPrimary),
                                        decoration: InputDecoration(
                                          hintText: tr(LocaleKeys.meal_search_food),
                                          hintStyle: AppTextStyles.body16.copyWith(color: AppColors.textSecondary),
                                          border: InputBorder.none,
                                          isDense: true,
                                          contentPadding: EdgeInsets.zero,
                                          counterText: '',
                                        ),
                                      ),
                                    ),
                                    if (_searchController.text.isNotEmpty)
                                      GestureDetector(
                                        onTap: _clearSearch,
                                        child: Icon(CupertinoIcons.xmark_circle_fill, color: AppColors.textSecondary, size: AppSizes.iconMd),
                                      )
                                    else
                                      GestureDetector(
                                        onTap: _toggleVoiceSearch,
                                        child: Icon(CupertinoIcons.mic_fill, color: _isListening ? AppColors.error : AppColors.textSecondary, size: AppSizes.iconMd),
                                      ),
                                    const SizedBox(width: AppSpacing.m),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s),
                          CustomGlassIconButton(
                            icon: CupertinoIcons.xmark,
                            onPressed: _toggleSearch,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            : CustomGlassAppBar(
                // Use horizontalPadding instead of wrapping in PreferredSize
                // + SafeArea + Padding, which double-wraps SafeArea and
                // misreports the bar's preferred height on Android (where the
                // bar is taller by AppSpacing.m). This made the back/action
                // icons look squished on Meal Log.
                horizontalPadding: AppSpacing.screen,
                leadingIconSize: AppSizes.iconLg,
                onBack: () => Get.back(),
                titleWidget: Text(tr(LocaleKeys.meal_select_title), style: AppTextStyles.body16.copyWith(fontWeight: FontWeight.w600, letterSpacing: -0.3125, color: AppColors.primary)),
                actions: [
                  CustomGlassIconButtonGroup(
                    iconSize: AppSizes.iconLg,
                    items: [
                      (icon: CupertinoIcons.search, onPressed: _toggleSearch),
                      (icon: CupertinoIcons.add, onPressed: _openManualLog),
                    ],
                  ),
                ],
              ),
        body: LiquidGlassBackground(
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.s),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
                  child: SelectMealSegmentedTabs(
                    labels: [tr(LocaleKeys.common_all), tr(LocaleKeys.common_favorites), tr(LocaleKeys.common_meals), tr(LocaleKeys.common_ingredients)],
                    activeIndex: _tab.index,
                    onTap: _onTabChanged,
                  ),
                ),
                const SizedBox(height: AppSpacing.s),
                if (widget.showLoading)
                  const Expanded(child: SelectMealLoadingState())
                else if (widget.errorMessage != null)
                  Expanded(child: SelectMealErrorState(message: widget.errorMessage!, onRetry: () => setState(() {})))
                else
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: _onPageChanged,
                      children: SelectMealTab.values.map((tab) => _buildPage(tab)).toList(),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IngredientItem {
  final Ingredient ingredient;
  final String subtitle;
  final IngredientTemplate? template;

  const _IngredientItem({required this.ingredient, required this.subtitle, this.template});
}

class _SuggestionItem {
  final String name;
  final int frequency;

  const _SuggestionItem({required this.name, required this.frequency});
}

