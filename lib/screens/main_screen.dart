import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:get/get.dart';

import 'package:diplomka/app_theme.dart';
import 'package:diplomka/widgets/liquid_glass/liquid_glass_tap_effect.dart' show LiquidGlassTapEffect;
import 'package:diplomka/controller/dashboard_controller.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/screens/dashboard_screen.dart';
import 'package:diplomka/screens/progress_screen.dart';
import 'package:diplomka/screens/profile/profile_screen.dart';
import 'package:diplomka/widgets/dashboard_calendar_sheet.dart';
import 'package:diplomka/widgets/streak_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:diplomka/screens/scan/scan_onboarding_screen.dart';
import 'package:diplomka/controller/base_controller.dart';
import 'package:diplomka/screens/scan/scan_camera_screen.dart';
import 'package:diplomka/widgets/quick_action_sheet.dart';
import 'package:diplomka/screens/logs/voice_log_screen.dart';
import 'package:diplomka/screens/logs/exercise_log_home_screen.dart';
import 'package:diplomka/screens/log_meal/select_meal_screen.dart';
import 'package:diplomka/services/session_manager.dart';

class MainScreen extends GetView<MainScreenController> {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selectedIndex = controller._selectedIndex.value;
      final activeBody = controller.widgetOptions.elementAt(selectedIndex);
      final bool isDashboard = selectedIndex == 0;

      return LiquidGlassScope(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          extendBody: true,
          body: LiquidGlassBackground(
            child: Stack(
              children: [
                activeBody,
                if (isDashboard) ...[
                  Positioned(left: AppSpacing.l, top: AppSpacing.safeAreaTop, child: const _DashboardStreakPill()),
                  Positioned(right: AppSpacing.l, top: AppSpacing.safeAreaTop, child: const _DashboardCalendarPill()),
                ],
              ],
            ),
          ),
          bottomNavigationBar: _BorderedGlassBottomBar(
            child: GlassBottomBar(
              quality: GlassQuality.premium,
              barHeight: AppSizes.bottomNavHeight,
              selectedIconColor: AppColors.textPrimary,
              unselectedIconColor: AppColors.grey4,
              glassSettings: AppGlass.standard,
              tabs: [
                GlassBottomBarTab(label: tr(LocaleKeys.nav_home), icon: CupertinoIcons.house_fill, selectedIcon: CupertinoIcons.house_fill),
                GlassBottomBarTab(label: tr(LocaleKeys.nav_progress), icon: CupertinoIcons.chart_bar, selectedIcon: CupertinoIcons.chart_bar),
                GlassBottomBarTab(label: tr(LocaleKeys.nav_profile), icon: CupertinoIcons.person, selectedIcon: CupertinoIcons.person),
              ],
              selectedIndex: selectedIndex,
              onTabSelected: controller._onItemTapped,
              extraButton: GlassBottomBarExtraButton(
                icon: CupertinoIcons.add,
                label: tr(LocaleKeys.nav_home),
                onTap: () => controller.showQuickActions(context),
                iconColor: AppColors.primary,
                size: AppSizes.fabSize,
              ),
            ),
          ),
        ),
      );
    });
  }
}

class MainScreenController extends BaseController {
  static MainScreenController get to => Get.find();
  final RxInt _selectedIndex = 0.obs;
  final RxBool isCalendarSheetVisible = false.obs;

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

  void showQuickActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      elevation: 0,
      barrierColor: AppColors.overlayDark,
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
        return SizedBox(
          width: AppSizes.streakPillMinWidthTripleDigit,
          height: AppSizes.streakPillHeight,
          child: const Center(
            child: SizedBox(
              width: AppSizes.iconSm,
              height: AppSizes.iconSm,
              child: CircularProgressIndicator(strokeWidth: AppSizes.borderThick, color: AppColors.orange),
            ),
          ),
        );
      }

      Widget content;
      if (dc.streakError.isNotEmpty) {
        content = const Icon(CupertinoIcons.exclamationmark_circle, color: AppColors.error, size: AppSizes.iconSm);
      } else {
        final streak = dc.streakInfo.value?.currentStreak ?? 0;
        content = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(CupertinoIcons.star, color: AppColors.textPrimary, size: 18),
            const SizedBox(width: AppSpacing.xs),
            Text(
              '$streak',
              style: AppTextStyles.body16.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
            ),
          ],
        );
      }

      return LiquidGlassTapEffect(
        onTap: () {
          showDialog(context: context, builder: (_) => const StreakDialog());
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadii.pill),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
            child: Container(
              width: AppSizes.streakPillMinWidthTripleDigit,
              height: AppSizes.streakPillHeight,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(AppRadii.pill),
                border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 0.5),
              ),
              child: Center(child: content),
            ),
          ),
        ),
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
      final showYear = date.year != DateTime.now().year;
      final label = showYear ? '$dayStr. $monthStr. ${date.year}' : '$dayStr. $monthStr';
      final pillWidth = showYear ? 140.0 : 100.0;

      return LiquidGlassTapEffect(
        onTap: () {
          DashboardCalendarSheet.show(context, selectedDate: dc.selectedDate.value, onDateSelected: (date) => DashboardController.to.updateDate(date));
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadii.pill),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
            child: Container(
              width: pillWidth,
              height: AppSizes.streakPillHeight,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(AppRadii.pill),
                border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 0.5),
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(CupertinoIcons.calendar, color: AppColors.textPrimary, size: 18),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      label,
                      style: AppTextStyles.body16.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}

class _BorderedGlassBottomBar extends StatelessWidget {
  const _BorderedGlassBottomBar({required this.child});

  final GlassBottomBar child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: IgnorePointer(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: child.horizontalPadding, vertical: child.verticalPadding),
              child: Row(
                spacing: child.spacing,
                children: [
                  Expanded(
                    child: Container(
                      height: child.barHeight,
                      decoration: const BoxDecoration(),
                    ),
                  ),
                  if (child.extraButton != null)
                    Container(
                      width: child.extraButton!.size,
                      height: child.extraButton!.size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        // TODO do I want this or no?
                        // border: Border.all(color: AppColors.outline),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
