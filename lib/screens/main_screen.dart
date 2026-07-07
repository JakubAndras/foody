import 'dart:io' show Platform;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import 'package:diplomka/app_theme.dart';
import 'package:diplomka/state/dashboard_notifier.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/screens/dashboard_screen.dart';
import 'package:diplomka/screens/log_meal/select_meal_screen.dart';
import 'package:diplomka/screens/logs/exercise_log_home_screen.dart';
import 'package:diplomka/screens/logs/voice_log_screen.dart';
import 'package:diplomka/screens/profile/profile_screen.dart';
import 'package:diplomka/screens/progress_screen.dart';
import 'package:diplomka/screens/scan/scan_camera_screen.dart';
import 'package:diplomka/screens/scan/scan_onboarding_screen.dart';
import 'package:diplomka/services/session_manager.dart';
import 'package:diplomka/widgets/dashboard_calendar_sheet.dart';
import 'package:diplomka/widgets/quick_action_sheet.dart';
import 'package:diplomka/widgets/streak_dialog.dart';

/// Stav hlavní obrazovky (3-tab shell).
///
/// Vedle aktivního tabu drží notifier i dvě reaktivní pole, která dřívější
/// controller vystavoval napříč aplikací: `isCalendarSheetVisible`
/// (kalendářový sheet na dashboardu) a `scrollToEnergy` (trigger pro
/// odscrollování na energetickou sekci na Progress tabu).
@immutable
class MainScreenState {
  const MainScreenState({this.selectedIndex = 0, this.isCalendarSheetVisible = false, this.scrollToEnergy = false});

  /// Aktivní tab (0 = Dashboard, 1 = Progress, 2 = Profile).
  final int selectedIndex;

  /// Zda je právě otevřený kalendářový sheet na dashboardu.
  final bool isCalendarSheetVisible;

  /// Po přepnutí na Progress tab se má odscrollovat na energetickou sekci.
  final bool scrollToEnergy;

  MainScreenState copyWith({int? selectedIndex, bool? isCalendarSheetVisible, bool? scrollToEnergy}) {
    return MainScreenState(
      selectedIndex: selectedIndex ?? this.selectedIndex,
      isCalendarSheetVisible: isCalendarSheetVisible ?? this.isCalendarSheetVisible,
      scrollToEnergy: scrollToEnergy ?? this.scrollToEnergy,
    );
  }
}

class MainScreenNotifier extends Notifier<MainScreenState> {
  @override
  MainScreenState build() => const MainScreenState();

  void changeTab(int index) => state = state.copyWith(selectedIndex: index);

  void showDashboardTab() => state = state.copyWith(selectedIndex: 0);

  void showProgressTab() => state = state.copyWith(selectedIndex: 1);

  /// Přepne na Progress tab a nastaví trigger pro odscrollování na energetickou sekci.
  void showProgressTabAndScrollToEnergy() => state = state.copyWith(selectedIndex: 1, scrollToEnergy: true);

  void setScrollToEnergy(bool value) => state = state.copyWith(scrollToEnergy: value);

  void setCalendarSheetVisible(bool value) => state = state.copyWith(isCalendarSheetVisible: value);
}

final mainScreenProvider = NotifierProvider<MainScreenNotifier, MainScreenState>(MainScreenNotifier.new);

/// Obsah jednotlivých tabů. Na Androidu drženy pohromadě přes `IndexedStack`.
const List<Widget> _mainTabs = <Widget>[DashboardScreen(), ProgressScreen(), ProfileScreen()];

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(mainScreenProvider.select((s) => s.selectedIndex));
    final isDashboard = selectedIndex == 0;
    final appBarSpacing = AppSpacing.m + 1;
    final appBarTop = defaultTargetPlatform == TargetPlatform.android ? AppSpacing.safeAreaTopAndroid : AppSpacing.safeAreaTop;

    // On Android, keep all tabs mounted via IndexedStack to avoid expensive
    // teardown/rebuild (Floor queries, LiquidGlass shader recompilation) that
    // causes visible blank frames on slower devices. iOS handles the swap fine.
    final body = Platform.isAndroid ? IndexedStack(index: selectedIndex, children: _mainTabs) : _mainTabs.elementAt(selectedIndex);

    return LiquidGlassScope(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        body: LiquidGlassBackground(
          child: Stack(
            children: [
              body,
              if (isDashboard) ...[
                Positioned(left: appBarSpacing, top: appBarTop, child: const _DashboardStreakPill()),
                Positioned(right: appBarSpacing, top: appBarTop, child: const _DashboardCalendarPill()),
              ],
            ],
          ),
        ),
        bottomNavigationBar: Builder(
          builder: (ctx) {
            final androidBottomPadding = Platform.isAndroid ? MediaQuery.of(ctx).viewPadding.bottom : 0.0;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _BorderedGlassBottomBar(
                  child: GlassBottomBar(
                    quality: GlassQuality.premium,
                    barHeight: AppSizes.bottomNavHeight,
                    selectedIconColor: AppColors.textPrimary,
                    unselectedIconColor: AppColors.grey4,
                    glassSettings: AppGlass.standard,
                    tabs: [
                      // liquid_glass_widgets 0.5.x: `icon` is now a Widget,
                      // `selectedIcon` was renamed to `activeIcon`.
                      GlassBottomBarTab(label: tr(LocaleKeys.nav_home), icon: const Icon(CupertinoIcons.house), activeIcon: const Icon(CupertinoIcons.house_fill)),
                      GlassBottomBarTab(label: tr(LocaleKeys.nav_progress), icon: const Icon(CupertinoIcons.chart_bar), activeIcon: const Icon(CupertinoIcons.chart_bar_fill)),
                      GlassBottomBarTab(label: tr(LocaleKeys.nav_profile), icon: const Icon(CupertinoIcons.person), activeIcon: const Icon(CupertinoIcons.person_fill)),
                    ],
                    selectedIndex: selectedIndex,
                    onTabSelected: (index) => ref.read(mainScreenProvider.notifier).changeTab(index),
                    extraButton: GlassBottomBarExtraButton(
                      icon: const Icon(CupertinoIcons.add),
                      label: tr(LocaleKeys.nav_home),
                      onTap: () => _showQuickActions(context, ref),
                      iconColor: AppColors.primary,
                      size: AppSizes.fabSize,
                    ),
                  ),
                ),
                if (androidBottomPadding > 0) Container(height: androidBottomPadding, color: AppColors.meshBase),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Rychlé akce (dřívější `MainScreenController.showQuickActions`). Navigace patří
/// do UI vrstvy, proto zůstává mimo notifier (viz konvence kontraktu).
void _showQuickActions(BuildContext context, WidgetRef ref) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    elevation: 0,
    barrierColor: AppColors.overlayDark40,
    isScrollControlled: false,
    builder: (_) => QuickActionSheet(
      onLogMeal: () {
        Navigator.of(context).pop();
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SelectMealScreen()));
      },
      onBarcode: () {
        Navigator.of(context).pop();
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ScanCameraScreen(initialMode: ScanMode.barcode)));
      },
      onVoiceLog: () {
        Navigator.of(context).pop();
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const VoiceLogScreen()));
      },
      onMealScan: () {
        Navigator.of(context).pop();
        if (ref.read(sessionProvider).scanOnboardingComplete) {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ScanCameraScreen()));
        } else {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ScanOnboardingScreen()));
        }
      },
      onExercise: () {
        Navigator.of(context).pop();
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ExerciseLogHomeScreen()));
      },
    ),
  );
}

class _DashboardStreakPill extends ConsumerWidget {
  const _DashboardStreakPill();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final daily = ref.watch(dailyRecordProvider);

    if (daily.streak.isLoading) {
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
    if (daily.streak.hasError) {
      content = Icon(CupertinoIcons.exclamationmark_circle, color: AppColors.error, size: AppSizes.iconSm);
    } else {
      final streak = daily.streak.valueOrNull?.currentStreak ?? 0;
      content = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(CupertinoIcons.star, color: AppColors.textPrimary, size: 18),
          const SizedBox(width: AppSpacing.xs),
          Text(
            '$streak',
            style: AppTextStyles.body16.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
          ),
        ],
      );
    }

    return GlassButton.custom(
      onTap: () => StreakSheet.show(context),
      width: AppSizes.streakPillMinWidthTripleDigit,
      height: AppSizes.streakPillHeight,
      shape: const LiquidRoundedRectangle(borderRadius: AppRadii.pill),
      useOwnLayer: true,
      settings: AppGlass.standard,
      quality: GlassQuality.premium,
      interactionScale: 0.95,
      child: Center(child: content),
    );
  }
}

class _DashboardCalendarPill extends ConsumerWidget {
  const _DashboardCalendarPill();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = ref.watch(dailyRecordProvider.select((s) => s.selectedDate));
    final dayStr = date.day.toString();
    final monthStr = date.month.toString().padLeft(2, '0');
    final showYear = date.year != DateTime.now().year;
    final label = showYear ? '$dayStr. $monthStr. ${date.year}' : '$dayStr. $monthStr';
    final pillWidth = showYear ? 140.0 : 100.0;

    return GlassButton.custom(
      onTap: () {
        DashboardCalendarSheet.show(context, selectedDate: date, onDateSelected: (selected) => ref.read(dailyRecordProvider.notifier).updateDate(selected));
      },
      width: pillWidth,
      height: AppSizes.streakPillHeight,
      shape: const LiquidRoundedRectangle(borderRadius: AppRadii.pill),
      useOwnLayer: true,
      settings: AppGlass.standard,
      quality: GlassQuality.premium,
      interactionScale: 0.95,
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(CupertinoIcons.calendar, color: AppColors.textPrimary, size: 18),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: AppTextStyles.body16.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
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
                    child: Container(height: child.barHeight, decoration: const BoxDecoration()),
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
