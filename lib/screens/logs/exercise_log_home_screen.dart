import 'package:diplomka/app_theme.dart';
import 'package:diplomka/controller/dashboard_controller.dart';
import 'package:diplomka/controller/day_record_controller.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/model/exercise_template.dart';
import 'package:diplomka/services/exercise_template_repository.dart';
import 'package:diplomka/screens/logs/add_exercise_screen.dart';
import 'package:diplomka/screens/logs/exercise_detail_screen.dart';
import 'package:diplomka/screens/logs/exercise_widgets.dart';
import 'package:diplomka/screens/profile/profile_widgets.dart';
import 'package:diplomka/services/selected_date_service.dart';
import 'package:diplomka/widgets/custom_glass_app_bar.dart';
import 'package:diplomka/widgets/logged_snackbar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class ExerciseLogHomeScreen extends StatefulWidget {
  const ExerciseLogHomeScreen({super.key});

  @override
  State<ExerciseLogHomeScreen> createState() => _ExerciseLogHomeScreenState();
}

class _ExerciseLogHomeScreenState extends State<ExerciseLogHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _showFavorites = false;

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
    return exercises.where((e) {
      final matchesQuery = query.isEmpty || e.name.toLowerCase().contains(query);
      final matchesFavorite = !_showFavorites || e.isFavorite;
      return matchesQuery && matchesFavorite;
    }).toList()..sort((a, b) => b.lastUsedAt.compareTo(a.lastUsedAt));
  }

  Future<void> _addExerciseFromTemplate(ExerciseTemplate template) async {
    final selectedDate = SelectedDateService.to.selectedDate.value;
    final now = DateTime.now();
    final timestamp = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, now.hour, now.minute, now.second, now.millisecond, now.microsecond);

    final newExercise = template.toExercise(timestamp: timestamp);

    final savedExercise = await DayRecordController.to.saveExerciseForDate(date: selectedDate, exerciseToSave: newExercise);
    DashboardController.to.refresh();

    if (!mounted) return;
    showLoggedSnackbar(
      context: context,
      message: tr(LocaleKeys.common_exercise_logged),
      onView: () => Get.back(),
      onUndo: () async {
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
              onBack: () => Navigator.of(context).maybePop(),
              actions: [
                CustomGlassIconButton(
                  icon: CupertinoIcons.add,
                  iconSize: AppSizes.iconMd,
                  onPressed: () => Get.to(() => const AddExerciseScreen()),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
            child: ExerciseSearchBar(controller: _searchController, onChanged: (_) => setState(() {})),
          ),
          const SizedBox(height: AppSpacing.s),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
            child: Row(
              children: [
                ExerciseFilterChip(label: tr(LocaleKeys.common_all), selected: !_showFavorites, onTap: () => setState(() => _showFavorites = false)),
                const SizedBox(width: AppSpacing.s),
                ExerciseFilterChip(
                  label: tr(LocaleKeys.common_favorites),
                  selected: _showFavorites,
                  icon: CupertinoIcons.xmark,
                  onTap: () => setState(() => _showFavorites = true),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.s),
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
