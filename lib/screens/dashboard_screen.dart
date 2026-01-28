import 'package:diplomka/controller/dashboard_controller.dart';
import 'package:diplomka/screens/edit_meal_screen.dart';
import 'package:diplomka/screens/profile_screen.dart';
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

class DashboardScreen extends GetView<_DashboardScreenController> {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<_DashboardScreenController>(
        init: _DashboardScreenController(),
        builder: (_DashboardScreenController controller) {
          final dashboardController = DashboardController.to;
          return Scaffold(
            appBar: AppBar(
              centerTitle: false,
              actions: [
                Obx(() {
                  if (dashboardController.isLoadingStreak.value) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.orange))),
                    );
                  }
                  if (dashboardController.streakError.isNotEmpty) {
                    return IconButton(
                      icon: const Icon(Icons.error_outline, color: Colors.red),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext dialogContext) => const StreakDialog(),
                        );
                      },
                    );
                  }
                  if (dashboardController.streakInfo.value != null) {
                    return Padding(
                      padding: const EdgeInsets.all(AppTheme.paddingXS),
                      child: TextButton.icon(
                        icon: const Icon(Icons.local_fire_department, color: Colors.orange, size: 20),
                        label: Text(
                          '${dashboardController.streakInfo.value!.currentStreak}',
                          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext dialogContext) => const StreakDialog(),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          minimumSize: const Size(40, 32),
                          backgroundColor: Colors.white,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink(); // Fallback for no data
                }),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.paddingS),
                  child: IconButton(
                    icon: const Icon(Icons.account_circle, size: 28),
                    tooltip: 'Profile',
                    onPressed: () {
                      Get.to(() => const ProfileScreen());
                    },
                  ),
                ),
              ],
              elevation: 0,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.paddingM),
              child: Column(
                children: [
                  Obx(() => DateSelector(
                        selectedDate: dashboardController.selectedDate.value,
                        onDateSelected: (date) {
                          dashboardController.updateDate(date);
                        },
                      )),
                  Expanded(
                    child: Obx(() {
                      if (dashboardController.isLoadingDayRecord.value) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (dashboardController.dayRecordError.isNotEmpty) {
                        return Center(child: Text('Error: ${dashboardController.dayRecordError.value}'));
                      }

                      final recordToShow = dashboardController.dayRecord.value ?? DayRecord.initial(dashboardController.selectedDate.value);

                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            _caloriesTrackerWidget(recordToShow),
                            const SizedBox(height: 16),
                            RecentlyUploadedCard(
                              meals: recordToShow.meals,
                              onMealTap: (meal) async {
                                await Get.to(() => EditMealScreen(dayRecord: recordToShow, meal: meal, isNewMeal: false));
                              },
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          );
        });
  }

  Widget _caloriesTrackerWidget(DayRecord recordToShow) {
    Widget caloriesTrackerWidget;
    if (SessionManager.to.caloriesPlanEnabled.value) {
      caloriesTrackerWidget = Column(
        children: [
          CaloriesCard(dayRecord: recordToShow),
          const SizedBox(height: 8),
          MacrosRow(dayRecord: recordToShow),
        ],
      );
    } else {
      caloriesTrackerWidget = Column(
        children: [
          CaloriesCard(dayRecord: recordToShow, caloriesPlanEnabled: false),
          const SizedBox(height: 8),
          MacrosRow(dayRecord: recordToShow, caloriesPlanEnabled: false),
        ],
      );
    }
    return caloriesTrackerWidget;
  }
}

class _DashboardScreenController extends BaseController {

  @override
  void onHidden() {
    // TODO: implement onHidden
  }
}
