import 'package:diplomka/app_theme.dart';
import 'package:diplomka/controller/dashboard_controller.dart';
import 'package:diplomka/controller/day_record_controller.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/model/exercise.dart';
import 'package:diplomka/screens/logs/add_exercise_screen.dart';
import 'package:diplomka/screens/logs/exercise_detail_screen.dart';
import 'package:diplomka/screens/logs/exercise_widgets.dart';
import 'package:diplomka/services/selected_date_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
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

  List<Exercise> _allExercises() {
    return DayRecordController.to.dayRecords.expand((record) => record.exercises).toList();
  }

  List<Exercise> _applyFilters(List<Exercise> exercises) {
    final query = _searchController.text.toLowerCase();
    return exercises.where((e) {
      final matchesQuery = query.isEmpty || e.name.toLowerCase().contains(query);
      final matchesFavorite = !_showFavorites || e.isFavorite;
      return matchesQuery && matchesFavorite;
    }).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  Future<void> _duplicateExerciseForSelectedDay(Exercise exercise) async {
    final selectedDate = SelectedDateService.to.selectedDate.value;
    final now = DateTime.now();
    final timestamp = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, now.hour, now.minute, now.second, now.millisecond, now.microsecond);

    final newExercise = Exercise(
      name: exercise.name,
      timestamp: timestamp,
      durationMinutes: exercise.durationMinutes,
      caloriesBurned: exercise.caloriesBurned,
    );

    await DayRecordController.to.saveExerciseForDate(date: selectedDate, exerciseToSave: newExercise);
    DashboardController.to.refresh();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr(LocaleKeys.exercise_exercise_added))));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.l, AppSpacing.m, AppSpacing.l, AppSpacing.s),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _CircleButton(
                    icon: Icons.chevron_left,
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                  Text(tr(LocaleKeys.exercise_log_title), style: AppTextStyles.title18Tight),
                  _CircleButton(
                    icon: _showFavorites ? Icons.bookmark : Icons.bookmark_border,
                    onTap: () => setState(() => _showFavorites = !_showFavorites),
                    filled: _showFavorites,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
              child: ExerciseSearchBar(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(height: AppSpacing.s),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
              child: Row(
                children: [
                  ExerciseFilterChip(
                    label: tr(LocaleKeys.common_all),
                    selected: !_showFavorites,
                    onTap: () => setState(() => _showFavorites = false),
                  ),
                  const SizedBox(width: AppSpacing.s),
                  ExerciseFilterChip(
                    label: tr(LocaleKeys.common_favorites),
                    selected: _showFavorites,
                    icon: Icons.close,
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
                  padding: const EdgeInsets.fromLTRB(AppSpacing.l, AppSpacing.s, AppSpacing.l, AppSpacing.xl),
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.s),
                  itemBuilder: (context, index) {
                    final exercise = filtered[index];
                    return ExerciseListCard(
                      title: exercise.name,
                      kcal: exercise.caloriesBurned.round(),
                      minutes: exercise.durationMinutes ?? 0,
                      onAdd: () => _duplicateExerciseForSelectedDay(exercise),
                      onTap: () => Get.to(() => ExerciseDetailScreen(exercise: exercise)),
                    );
                  },
                );
              }),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.l, 0, AppSpacing.l, AppSpacing.l),
              child: GestureDetector(
                onTap: () => Get.to(() => const AddExerciseScreen()),
                child: Container(
                  height: AppSizes.buttonHeightCompact,
                  decoration: BoxDecoration(
                    gradient: AppGradients.primary,
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                    boxShadow: AppShadows.button,
                  ),
                  child: Center(
                    child: Text(
                      tr(LocaleKeys.exercise_add_title),
                      style: AppTextStyles.button18.copyWith(color: AppColors.onPrimary),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.icon,
    required this.onTap,
    this.filled = true,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: AppSizes.backButtonSize,
        height: AppSizes.backButtonSize,
        decoration: BoxDecoration(
          color: filled ? AppColors.surface : AppColors.backgroundAlt,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: Border.all(color: AppColors.outline, width: 1),
          boxShadow: filled ? AppShadows.control : null,
        ),
        child: Icon(icon, color: AppColors.textPrimary, size: AppSizes.iconMd),
      ),
    );
  }
}
