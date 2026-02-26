import 'package:diplomka/controller/dashboard_controller.dart';
import 'package:diplomka/screens/meals/meal_detail_screen.dart';
import 'package:diplomka/widgets/calories_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:diplomka/app_theme.dart';

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
                              return Center(child: Text('Error: ${dashboardController.dayRecordError.value}'));
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
          'Calories AI app',
          style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w700),
        ),
        Obx(() {
          if (dashboardController.isLoadingStreak.value) {
            return _streakPill(
              child: const SizedBox(
                width: AppSizes.iconSm,
                height: AppSizes.iconSm,
                child: CircularProgressIndicator(strokeWidth: AppSizes.borderThick, color: AppColors.orange),
              ),
            );
          }
          if (dashboardController.streakError.isNotEmpty) {
            return _streakPill(
              child: const Icon(Icons.error_outline, color: AppColors.error, size: AppSizes.iconSm),
              onTap: () => showDialog(context: context, builder: (_) => const StreakDialog()),
            );
          }
          final streak = dashboardController.streakInfo.value?.currentStreak ?? 0;
          return _streakPill(
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

  Widget _streakPill({required Widget child, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: AppSizes.streakPillHeight,
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
