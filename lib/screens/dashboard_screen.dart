import 'package:diplomka/controller/dashboard_controller.dart';
import 'package:diplomka/controller/day_record_controller.dart';
import 'package:diplomka/screens/meals/meal_detail_screen.dart';
import 'package:diplomka/screens/profile/profile_widgets.dart';
import 'package:diplomka/services/day_record_repository.dart';
import 'package:diplomka/services/selected_date_service.dart';
import 'package:diplomka/widgets/calories_card.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:diplomka/app_theme.dart';
import 'package:intl/intl.dart';

import 'package:diplomka/model/day_record.dart';
import 'package:diplomka/widgets/date_selector.dart';
import 'package:diplomka/widgets/macros_row.dart';
import 'package:diplomka/widgets/recently_uploaded_card.dart';
import 'package:diplomka/widgets/streak_dialog.dart';
import 'package:diplomka/controller/base_controller.dart';
import 'package:diplomka/services/session_manager.dart';
import 'package:diplomka/services/nutrition_goals_service.dart';

class DashboardScreen extends GetView<_DashboardScreenController> {
  const DashboardScreen({super.key});
  static const bool _useSegmentedDateRing = false;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<_DashboardScreenController>(
        init: _DashboardScreenController(),
        builder: (_DashboardScreenController controller) {
          final dashboardController = DashboardController.to;
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Container(
              decoration: const BoxDecoration(gradient: AppGradients.background),
              child: SafeArea(
                bottom: false,
                child: Obx(() {
                  final selectedDate = dashboardController.selectedDate.value;
                  final existingDayRecord = dashboardController.dayRecord.value;
                  final dayRecord = existingDayRecord ?? DayRecord.initial(selectedDate);
                  final nutritionGoals = NutritionGoalsService.to.goalsForDate(
                    selectedDate,
                    fallbackRecord: existingDayRecord,
                  );
                  final recordToShow = nutritionGoals.applyToDayRecord(dayRecord);
                  controller.maybeHandleScrollToTodayMealsRequest(
                    dashboardController.scrollToTodayMealsRequestId.value,
                  );

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(AppSpacing.l, AppSpacing.m, AppSpacing.l, AppSpacing.xs),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(context, dashboardController),
                            const SizedBox(height: AppSpacing.m),
                            DateSelector(
                              selectedDate: dashboardController.selectedDate.value,
                              useSegmentedRing: _useSegmentedDateRing,
                              onDateSelected: (date) {
                                dashboardController.updateDate(date);
                              },
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Builder(
                          builder: (context) {
                            final isAnalyzingMeal = dashboardController.newMealAnalyzeLoading.value;
                            final hasLoadedRecord = dashboardController.dayRecord.value != null;

                            if (dashboardController.isLoadingDayRecord.value && !hasLoadedRecord && !isAnalyzingMeal) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            if (dashboardController.dayRecordError.isNotEmpty) {
                              return Center(child: Text(tr(LocaleKeys.dashboard_error_loading, namedArgs: {'error': dashboardController.dayRecordError.value})));
                            }

                            return SingleChildScrollView(
                              controller: controller.scrollController,
                              padding: const EdgeInsets.fromLTRB(AppSpacing.l, AppSpacing.xs, AppSpacing.l, AppSpacing.mega + 42),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _caloriesTrackerWidget(recordToShow),
                                  const SizedBox(height: AppSpacing.m),
                                  RecentlyUploadedCard(
                                    meals: recordToShow.meals,
                                    exercises: recordToShow.exercises,
                                    selectedDate: dashboardController.selectedDate.value,
                                    onMealTap: (meal) async {
                                      await Get.to(() => MealDetailScreen(meal: meal));
                                      dashboardController.refresh();
                                    },
                                    onMealLongPress: (meal) async {
                                      final today = DateTime.now();
                                      final todayNormalized = DateTime(today.year, today.month, today.day);
                                      final duplicate = meal.copyWith(id: null, dayRecordId: null, timestamp: today);
                                      await DayRecordController.to.saveMealForDate(date: todayNormalized, mealToSave: duplicate);
                                      SelectedDateService.to.setSelectedDate(todayNormalized);
                                      dashboardController.refresh();
                                      Get.snackbar(tr(LocaleKeys.meal_duplicated), meal.name, snackPosition: SnackPosition.BOTTOM);
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          );
        });
  }

  Widget _buildHeader(BuildContext context, DashboardController dashboardController) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          tr(LocaleKeys.dashboard_title),
          style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w700),
        ),
        Obx(() {
          if (dashboardController.isLoadingStreak.value) {
            return _streakPill(
              minWidth: AppSizes.streakPillMinWidth,
              child: const SizedBox(
                width: AppSizes.iconSm,
                height: AppSizes.iconSm,
                child: CircularProgressIndicator(strokeWidth: AppSizes.borderThick, color: AppColors.orange),
              ),
            );
          }
          if (dashboardController.streakError.isNotEmpty) {
            return _streakPill(
              minWidth: AppSizes.streakPillMinWidth,
              child: const Icon(Icons.error_outline, color: AppColors.error, size: AppSizes.iconSm),
              onTap: () => showDialog(context: context, builder: (_) => const StreakDialog()),
            );
          }
          final streak = dashboardController.streakInfo.value?.currentStreak ?? 0;
          return _streakPill(
            minWidth: _streakPillMinWidthFor(streak),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.local_fire_department, color: AppColors.orange, size: AppSizes.iconSm),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  '$streak',
                  style: AppTextStyles.caption12.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            onTap: () => showDialog(context: context, builder: (_) => const StreakDialog()),
          );
        }),
      ],
    );
  }

  double _streakPillMinWidthFor(int streak) {
    final digits = streak.abs().toString().length;
    if (digits >= 3) return AppSizes.streakPillMinWidthTripleDigit;
    if (digits >= 2) return AppSizes.streakPillMinWidthDoubleDigit;
    return AppSizes.streakPillMinWidth;
  }

  Widget _streakPill({
    required Widget child,
    required double minWidth,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: AppSizes.streakPillHeight,
        constraints: BoxConstraints(minWidth: minWidth),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: Border.all(color: AppColors.border),
          boxShadow: AppShadows.cardSmall,
        ),
        child: Center(child: child),
      ),
    );
  }

  Widget _caloriesTrackerWidget(DayRecord recordToShow) {
    Widget caloriesTrackerWidget;
    if (SessionManager.to.caloriesPlanEnabled.value) {
      caloriesTrackerWidget = Column(
        children: [
          CaloriesCard(dayRecord: recordToShow),
          const SizedBox(height: AppSpacing.s),
          MacrosRow(dayRecord: recordToShow),
        ],
      );
    } else {
      caloriesTrackerWidget = Column(
        children: [
          CaloriesCard(dayRecord: recordToShow, caloriesPlanEnabled: false),
          const SizedBox(height: AppSpacing.s),
          MacrosRow(dayRecord: recordToShow, caloriesPlanEnabled: false),
        ],
      );
    }
    return caloriesTrackerWidget;
  }
}

class _DashboardScreenController extends BaseController {
  final ScrollController scrollController = ScrollController();
  int _lastHandledScrollRequestId = 0;
  bool _isDisposed = false;

  void maybeHandleScrollToTodayMealsRequest(int requestId) {
    if (requestId <= _lastHandledScrollRequestId) return;
    _lastHandledScrollRequestId = requestId;
    _scheduleScrollToTodayMealsBottom(attempt: 0);
  }

  void _scheduleScrollToTodayMealsBottom({required int attempt}) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_isDisposed) return;
      if (!scrollController.hasClients) {
        if (attempt < 6) {
          await Future<void>.delayed(const Duration(milliseconds: 120));
          _scheduleScrollToTodayMealsBottom(attempt: attempt + 1);
        }
        return;
      }

      final target = scrollController.position.maxScrollExtent;
      await scrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );

      if (attempt < 6) {
        await Future<void>.delayed(const Duration(milliseconds: 120));
        _scheduleScrollToTodayMealsBottom(attempt: attempt + 1);
      }
    });
  }

  @override
  void onClose() {
    _isDisposed = true;
    scrollController.dispose();
    super.onClose();
  }

  @override
  void onHidden() {
    // TODO: implement onHidden
  }
}

/// Standalone read-only dashboard for a specific date.
/// Used by Ask AI to preview an affected day.
/// No streak widget, no date picker, no bottom tab bar.
class DashboardPreviewScreen extends StatefulWidget {
  const DashboardPreviewScreen({super.key, required this.date});

  final DateTime date;

  @override
  State<DashboardPreviewScreen> createState() => _DashboardPreviewScreenState();
}

class _DashboardPreviewScreenState extends State<DashboardPreviewScreen> {
  DayRecord? _dayRecord;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecord();
  }

  Future<void> _loadRecord() async {
    final record = await DayRecordRepository.to.getDayRecord(widget.date);
    if (mounted) {
      setState(() {
        _dayRecord = record;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dayRecord = _dayRecord ?? DayRecord.initial(widget.date);
    final nutritionGoals = NutritionGoalsService.to.goalsForDate(widget.date, fallbackRecord: _dayRecord);
    final recordToShow = nutritionGoals.applyToDayRecord(dayRecord);
    final dateLabel = DateFormat.yMMMd().format(widget.date);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.background),
        child: SafeArea(
          bottom: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.m, AppSpacing.m, AppSpacing.l, AppSpacing.xs),
                child: ProfileTopBar(
                  title: dateLabel,
                  onBack: () => Get.back(),
                ),
              ),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(AppSpacing.l, AppSpacing.xs, AppSpacing.l, AppSpacing.l),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildCaloriesTracker(recordToShow),
                            const SizedBox(height: AppSpacing.m),
                            RecentlyUploadedCard(
                              meals: recordToShow.meals,
                              exercises: recordToShow.exercises,
                              selectedDate: widget.date,
                              onMealTap: (meal) => Get.to(() => MealDetailScreen(meal: meal)),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCaloriesTracker(DayRecord recordToShow) {
    final planEnabled = SessionManager.to.caloriesPlanEnabled.value;
    return Column(
      children: [
        CaloriesCard(dayRecord: recordToShow, caloriesPlanEnabled: planEnabled),
        const SizedBox(height: AppSpacing.s),
        MacrosRow(dayRecord: recordToShow, caloriesPlanEnabled: planEnabled),
      ],
    );
  }
}
