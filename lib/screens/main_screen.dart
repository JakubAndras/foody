import 'package:get/get.dart';

import 'package:diplomka/app_theme.dart';
import 'package:diplomka/controller/dashboard_controller.dart';
import 'package:diplomka/screens/dashboard_screen.dart';
import 'package:diplomka/screens/progress_screen.dart';
import 'package:diplomka/screens/profile/profile_screen.dart';
import 'package:diplomka/widgets/bottom_nav_bar.dart';
import 'package:diplomka/widgets/dashboard_calendar_sheet.dart';
import 'package:diplomka/widgets/liquid_glass/liquid_glass_system.dart';
import 'package:diplomka/widgets/streak_dialog.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart';
import 'package:diplomka/screens/scan/scan_onboarding_screen.dart';
import 'package:diplomka/controller/base_controller.dart';
import 'package:diplomka/screens/scan/scan_camera_screen.dart';
import 'package:diplomka/widgets/quick_action_sheet.dart';
import 'package:diplomka/screens/logs/voice_log_screen.dart';
import 'package:diplomka/screens/logs/exercise_log_home_screen.dart';
import 'package:diplomka/screens/log_meal/select_meal_screen.dart';
import 'package:diplomka/screens/logs/weight_log_sheet.dart';
import 'package:diplomka/services/session_manager.dart';

class MainScreen extends GetView<MainScreenController> {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        final activeBody = MainScreenController.to.widgetOptions.elementAt(controller._selectedIndex.value);
        return LayoutBuilder(
          builder: (context, constraints) {
            final double navWidth = constraints.maxWidth - AppSpacing.xxxl - AppSizes.fabSize - AppSpacing.s;
            final double actionLeft = constraints.maxWidth - AppSpacing.l - AppSizes.fabSize;

            final bool isDashboard = controller._selectedIndex.value == 0;
            const double calendarPillWidth = 100;
            final double calendarPillLeft = constraints.maxWidth - AppSpacing.l - calendarPillWidth;

            return AppLiquidGlassLayer(
              backgroundWidget: activeBody,
              children: [
                AppLiquidGlassPresets.mainTabBarLens.build(
                  width: navWidth,
                  height: AppSizes.bottomNavHeight,
                  position: LiquidGlassOffsetPosition(left: AppSpacing.l, bottom: AppSpacing.xl),
                  child: BottomNavBarContent(
                    currentIndex: controller._selectedIndex.value,
                    onTap: controller._onItemTapped,
                  ),
                ),
                AppLiquidGlassPresets.mainTabActionLens.build(
                  width: AppSizes.fabSize,
                  height: AppSizes.fabSize,
                  position: LiquidGlassOffsetPosition(left: actionLeft, bottom: AppSpacing.xl),
                  child: BottomNavActionButton(onTap: () => controller._showQuickActions(context)),
                ),
                if (isDashboard) ...[
                  AppLiquidGlassPresets.mainTabBarLens.build(
                    width: AppSizes.streakPillMinWidthTripleDigit,
                    height: AppSizes.streakPillHeight,
                    position: const LiquidGlassOffsetPosition(left: AppSpacing.l, top: AppSpacing.safeAreaTop),
                    child: const _DashboardStreakPill(),
                  ),
                  AppLiquidGlassPresets.mainTabBarLens.build(
                    width: calendarPillWidth,
                    height: AppSizes.streakPillHeight,
                    position: LiquidGlassOffsetPosition(left: calendarPillLeft, top: AppSpacing.safeAreaTop),
                    child: const _DashboardCalendarPill(),
                  ),
                ],
              ],
            );
          },
        );
      }),
    );
  }
}

class MainScreenController extends BaseController {
  static MainScreenController get to => Get.find();
  final RxInt _selectedIndex = 0.obs;

  final List<Widget> widgetOptions = <Widget>[const DashboardScreen(), const ProgressScreen(), const ProfileScreen()];

  void _onItemTapped(int index) {
    _selectedIndex.value = index;
  }

  void showDashboardTab() {
    _selectedIndex.value = 0;
  }

  void showProgressTab() {
    _selectedIndex.value = 1;
  }

  void _showQuickActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.overlayDark40,
      isScrollControlled: false,
      builder: (_) => QuickActionSheet(
        onLogMeal: () {
          Navigator.of(context).pop();
          Get.to(() => const SelectMealScreen());
        },
        onBarcode: () {
          Navigator.of(context).pop();
          Get.to(() => const ScanCameraScreen(initialMode: ScanMode.barcode));
        },
        onVoiceLog: () {
          Navigator.of(context).pop();
          Get.to(() => const VoiceLogScreen());
        },
        onMealScan: () {
          Navigator.of(context).pop();
          if (SessionManager.to.scanOnboardingComplete.value) {
            Get.to(() => const ScanCameraScreen());
          } else {
            Get.to(() => const ScanOnboardingScreen());
          }
        },
        onWeight: () {
          Navigator.of(context).pop();
          Get.to(() => const WeightLogSheet());
        },
        onExercise: () {
          Navigator.of(context).pop();
          Get.to(() => const ExerciseLogHomeScreen());
        },
      ),
    );
  }

  @override
  void onHidden() {
    // TODO: implement onHidden
  }
}

class _DashboardStreakPill extends StatelessWidget {
  const _DashboardStreakPill();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final dc = DashboardController.to;
      if (dc.isLoadingStreak.value) {
        return const Center(
          child: SizedBox(
            width: AppSizes.iconSm,
            height: AppSizes.iconSm,
            child: CircularProgressIndicator(strokeWidth: AppSizes.borderThick, color: AppColors.orange),
          ),
        );
      }

      Widget content;
      if (dc.streakError.isNotEmpty) {
        content = const Icon(Icons.error_outline, color: AppColors.error, size: AppSizes.iconSm);
      } else {
        final streak = dc.streakInfo.value?.currentStreak ?? 0;
        content = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events_outlined, color: AppColors.textSecondary, size: 18),
            const SizedBox(width: AppSpacing.xs),
            Text('$streak', style: AppTextStyles.body16.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
          ],
        );
      }

      return GestureDetector(
        onTap: () => showDialog(context: context, builder: (_) => const StreakDialog()),
        child: Center(child: content),
      );
    });
  }
}

class _DashboardCalendarPill extends StatelessWidget {
  const _DashboardCalendarPill();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final dc = DashboardController.to;
      final date = dc.selectedDate.value;
      final dayStr = date.day.toString();
      final monthStr = date.month.toString().padLeft(2, '0');
      return GestureDetector(
        onTap: () async {
          final selected = await DashboardCalendarSheet.show(context, selectedDate: date);
          if (selected != null) {
            dc.updateDate(selected);
          }
        },
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.calendar_month, color: AppColors.textSecondary, size: 18),
              const SizedBox(width: AppSpacing.xs),
              Text('$dayStr. $monthStr', style: AppTextStyles.body16.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      );
    });
  }
}
