import 'package:diplomka/app_theme.dart';
import 'package:diplomka/controller/dashboard_controller.dart';
import 'package:diplomka/controller/day_record_controller.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/model/exercise_template.dart';
import 'package:diplomka/services/exercise_template_repository.dart';
import 'package:diplomka/screens/main_screen.dart';
import 'package:diplomka/screens/logs/add_exercise_screen.dart';
import 'package:diplomka/screens/logs/exercise_detail_screen.dart';
import 'package:diplomka/screens/logs/exercise_widgets.dart';
import 'package:diplomka/screens/logs/voice_log_screen.dart';
import 'package:diplomka/screens/profile/profile_widgets.dart';
import 'package:diplomka/services/selected_date_service.dart';
import 'package:diplomka/widgets/custom_glass_app_bar.dart';
import 'package:diplomka/widgets/glass_popup.dart';
import 'package:diplomka/widgets/liquid_glass/glass_segmented_tabs.dart';
import 'package:diplomka/widgets/logged_snackbar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

enum ExerciseSort { mostRecent, aToZ, zToA }

class ExerciseLogHomeScreen extends StatefulWidget {
  const ExerciseLogHomeScreen({super.key});

  @override
  State<ExerciseLogHomeScreen> createState() => _ExerciseLogHomeScreenState();
}

class _ExerciseLogHomeScreenState extends State<ExerciseLogHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _showFavorites = false;
  ExerciseSort _sort = ExerciseSort.mostRecent;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ExerciseTemplate> _allExercises() {
    return ExerciseTemplateRepository.to.allTemplates.toList();
  }

  List<ExerciseTemplate> _applyFilters(List<ExerciseTemplate> exercises) {
    final query = _searchController.text.toLowerCase();
    var filtered = exercises.where((e) {
      final matchesQuery = query.isEmpty || e.name.toLowerCase().contains(query);
      final matchesFavorite = !_showFavorites || e.isFavorite;
      return matchesQuery && matchesFavorite;
    }).toList();
    switch (_sort) {
      case ExerciseSort.mostRecent:
        filtered.sort((a, b) => b.lastUsedAt.compareTo(a.lastUsedAt));
      case ExerciseSort.aToZ:
        filtered.sort((a, b) => a.name.compareTo(b.name));
      case ExerciseSort.zToA:
        filtered.sort((a, b) => b.name.compareTo(a.name));
    }
    return filtered;
  }

  void _openSortPicker() {
    showGlassPopup(
      context: context,
      items: ExerciseSort.values.map((sort) {
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

  String _sortLabel(ExerciseSort sort) {
    switch (sort) {
      case ExerciseSort.mostRecent:
        return tr(LocaleKeys.common_most_recent);
      case ExerciseSort.aToZ:
        return tr(LocaleKeys.common_a_z);
      case ExerciseSort.zToA:
        return tr(LocaleKeys.common_z_a);
    }
  }

  Future<void> _addExerciseFromTemplate(ExerciseTemplate template) async {
    final selectedDate = SelectedDateService.to.selectedDate.value;
    final now = DateTime.now();
    final timestamp = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, now.hour, now.minute, now.second, now.millisecond, now.microsecond);

    final newExercise = template.toExercise(timestamp: timestamp);

    final savedExercise = await DayRecordController.to.saveExerciseForDate(date: selectedDate, exerciseToSave: newExercise);
    DashboardController.to.refresh();

    if (!mounted) return;
    showSnackBar(
      context: context,
      message: tr(LocaleKeys.common_exercise_logged),
      primaryLabel: tr(LocaleKeys.common_view),
      onPrimary: () {
        DashboardController.to.requestScrollToExercises();
        MainScreenController.to.showDashboardTab();
        Get.until((route) => route.isFirst);
      },
      secondaryLabel: tr(LocaleKeys.common_undo),
      onSecondary: () async {
        if (savedExercise != null) {
          await DayRecordController.to.deleteExercise(savedExercise);
          DashboardController.to.refresh();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ProfileGradientScaffold(
      safeBottom: false,
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
            child: CustomGlassAppBar(
              title: tr(LocaleKeys.exercise_log_title),
              leadingIconSize: AppSizes.iconLg,
              onBack: () => Navigator.of(context).maybePop(),
              actions: [
                CustomGlassIconButtonGroup(
                  iconSize: AppSizes.iconLg,
                  items: [
                    (icon: CupertinoIcons.mic, onPressed: () => Get.to(() => const VoiceLogScreen(initialMode: VoiceLogMode.exercise))),
                    (icon: CupertinoIcons.add, onPressed: () => Get.to(() => const AddExerciseScreen())),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
            child: ExerciseSearchBar(controller: _searchController, onChanged: (_) => setState(() {})),
          ),
          const SizedBox(height: AppSpacing.s),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
            child: Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2 - AppSpacing.m,
                  child: GlassSegmentedTabs(
                    labels: [tr(LocaleKeys.common_all), tr(LocaleKeys.common_favorites)],
                    activeIndex: _showFavorites ? 1 : 0,
                    onTap: (index) => setState(() => _showFavorites = index == 1),
                  ),
                ),
                const Spacer(),
                GestureDetector(
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
              ],
            ),
          ),
          const SizedBox(height: 2),
          Expanded(
            child: Obx(() {
              final filtered = _applyFilters(_allExercises());
              if (filtered.isEmpty) {
                return Center(
                  child: Text(
                    _showFavorites ? tr(LocaleKeys.exercise_no_favorites) : tr(LocaleKeys.exercise_no_logged),
                    style: AppTextStyles.body14.copyWith(color: AppColors.textTertiary),
                  ),
                );
              }
              return ListView.separated(
                padding: EdgeInsets.fromLTRB(AppSpacing.screen, AppSpacing.s, AppSpacing.screen, AppSpacing.l + MediaQuery.paddingOf(context).bottom),
                itemCount: filtered.length,
                separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.s),
                itemBuilder: (context, index) {
                  final template = filtered[index];
                  final previewExercise = template.toExercise(timestamp: DateTime.now());
                  return ExerciseListCard(
                    title: template.name,
                    kcal: template.caloriesBurned.round(),
                    minutes: template.durationMinutes ?? 0,
                    onAdd: () => _addExerciseFromTemplate(template),
                    onTap: () => Get.to(() => ExerciseDetailScreen(exercise: previewExercise, openedFromLogScreen: true)),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
