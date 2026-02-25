import 'package:diplomka/app_theme.dart';
import 'package:diplomka/controller/dashboard_controller.dart';
import 'package:diplomka/controller/day_record_controller.dart';
import 'package:diplomka/model/exercise.dart';
import 'package:diplomka/screens/logs/add_exercise_screen.dart';
import 'package:diplomka/screens/logs/exercise_detail_screen.dart';
import 'package:diplomka/screens/logs/exercise_widgets.dart';
import 'package:diplomka/services/selected_date_service.dart';
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

  final List<_ExerciseItem> _items = [
    _ExerciseItem(title: 'Morning Run', kcal: 420, minutes: 30, favorite: true),
    _ExerciseItem(title: 'Cycling', kcal: 520, minutes: 40, favorite: false),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _duplicateExerciseForSelectedDay(_ExerciseItem item) async {
    final selectedDate = SelectedDateService.to.selectedDate.value;
    final now = DateTime.now();
    final timestamp = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      now.hour,
      now.minute,
      now.second,
      now.millisecond,
      now.microsecond,
    );

    final exercise = Exercise(
      name: item.title,
      timestamp: timestamp,
      durationMinutes: item.minutes,
      caloriesBurned: item.kcal.toDouble(),
    );

    await DayRecordController.to.saveExerciseForDate(
      date: selectedDate,
      exerciseToSave: exercise,
    );
    DashboardController.to.refresh();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exercise added')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.toLowerCase();
    final filtered = _items.where((item) {
      final matchesQuery = item.title.toLowerCase().contains(query);
      final matchesFavorite = !_showFavorites || item.favorite;
      return matchesQuery && matchesFavorite;
    }).toList();

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
                  Text('Exercise Log', style: AppTextStyles.title18Tight),
                  _CircleButton(
                    icon: Icons.bookmark_border,
                    onTap: () {},
                    filled: false,
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
                    label: 'All',
                    selected: !_showFavorites,
                    onTap: () => setState(() => _showFavorites = false),
                  ),
                  const SizedBox(width: AppSpacing.s),
                  ExerciseFilterChip(
                    label: 'Favorites',
                    selected: _showFavorites,
                    icon: Icons.close,
                    onTap: () => setState(() => _showFavorites = true),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(AppSpacing.l, AppSpacing.s, AppSpacing.l, AppSpacing.xl),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.s),
                itemBuilder: (context, index) {
                  final item = filtered[index];
                  return ExerciseListCard(
                    title: item.title,
                    kcal: item.kcal,
                    minutes: item.minutes,
                    onAdd: () => _duplicateExerciseForSelectedDay(item),
                    onTap: () => Get.to(() => ExerciseDetailScreen(title: item.title, kcal: item.kcal, minutes: item.minutes)),
                  );
                },
              ),
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
                      'Add Exercise',
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

class _ExerciseItem {
  _ExerciseItem({
    required this.title,
    required this.kcal,
    required this.minutes,
    required this.favorite,
  });

  final String title;
  final int kcal;
  final int minutes;
  final bool favorite;
}
