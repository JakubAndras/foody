import 'dart:io' show Platform;

import 'package:diplomka/state/dashboard_notifier.dart';
import 'package:diplomka/screens/logs/exercise_detail_screen.dart';
import 'package:diplomka/screens/logs/exercise_log_home_screen.dart';
import 'package:diplomka/screens/logs/voice_log_screen.dart';
import 'package:diplomka/screens/log_meal/select_meal_screen.dart';
import 'package:diplomka/screens/meals/meal_detail_screen.dart';
import 'package:diplomka/screens/scan/scan_camera_screen.dart';
import 'package:diplomka/screens/scan/scan_onboarding_screen.dart';
import 'package:diplomka/widgets/custom_glass_app_bar.dart';
import 'package:diplomka/widgets/quick_action_sheet.dart';
import 'package:diplomka/services/day_record_repository.dart';
import 'package:diplomka/widgets/calories_card.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:diplomka/app_theme.dart';
import 'package:diplomka/model/day_record.dart';
import 'package:diplomka/widgets/date_selector.dart';
import 'package:diplomka/widgets/macros_row.dart';
import 'package:diplomka/widgets/recently_uploaded_card.dart';
import 'package:diplomka/services/session_manager.dart';
import 'package:diplomka/services/nutrition_goals_service.dart';
import 'package:diplomka/widgets/variable_blur_scroll_view.dart';
import 'package:diplomka/widgets/mesh_gradient_background.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  static const bool _useSegmentedDateRing = false;

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final ScrollController scrollController = ScrollController();
  final GlobalKey exerciseSectionKey = GlobalKey();
  int _lastHandledScrollRequestId = 0;
  int _lastHandledExerciseScrollRequestId = 0;
  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    scrollController.dispose();
    super.dispose();
  }

  void _maybeHandleScrollToTodayMealsRequest(int requestId) {
    if (requestId <= _lastHandledScrollRequestId) return;
    _lastHandledScrollRequestId = requestId;
    _scheduleScrollToTop(attempt: 0);
  }

  void _maybeHandleScrollToExercisesRequest(int requestId, {int currentMealsRequestId = 0}) {
    if (requestId <= _lastHandledExerciseScrollRequestId) return;
    _lastHandledExerciseScrollRequestId = requestId;
    if (currentMealsRequestId > _lastHandledScrollRequestId) _lastHandledScrollRequestId = currentMealsRequestId;
    _scheduleScrollToBottom(attempt: 0);
  }

  void _scheduleScrollToTop({required int attempt}) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_isDisposed) return;
      if (!scrollController.hasClients) {
        if (attempt < 4) {
          await Future<void>.delayed(const Duration(milliseconds: 120));
          _scheduleScrollToTop(attempt: attempt + 1);
        }
        return;
      }

      await scrollController.animateTo(0, duration: const Duration(milliseconds: 320), curve: Curves.easeOutCubic);
    });
  }

  void _scheduleScrollToBottom({required int attempt}) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_isDisposed) return;
      final ctx = exerciseSectionKey.currentContext;
      if (ctx == null) {
        if (attempt < 4) {
          await Future<void>.delayed(const Duration(milliseconds: 120));
          _scheduleScrollToBottom(attempt: attempt + 1);
        }
        return;
      }

      await Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 320), curve: Curves.easeOutCubic, alignment: 1.0);
    });
  }

  /// Rychlé akce (dřívější `MainScreenController.showQuickActions`).
  void _showQuickActions() {
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

  @override
  Widget build(BuildContext context) {
    // Scroll-request signály z analýzy cvičení/jídla řídí posun seznamu.
    ref.listen<ActivityAnalysisState>(activityAnalysisProvider, (previous, next) {
      if (previous?.scrollToTodayMealsRequestId != next.scrollToTodayMealsRequestId) {
        _maybeHandleScrollToTodayMealsRequest(next.scrollToTodayMealsRequestId);
      }
      if (previous?.scrollToExercisesRequestId != next.scrollToExercisesRequestId) {
        _maybeHandleScrollToExercisesRequest(next.scrollToExercisesRequestId, currentMealsRequestId: next.scrollToTodayMealsRequestId);
      }
    });

    final daily = ref.watch(dailyRecordProvider);
    // Přebuduj při změně cílů výživy pro vybraný den.
    ref.watch(nutritionGoalsProvider);

    final selectedDate = daily.selectedDate;
    final existingDayRecord = daily.dayRecord;
    final dayRecord = existingDayRecord ?? DayRecord.initial(selectedDate);
    final nutritionGoals = ref.read(nutritionGoalsProvider.notifier).goalsForDate(selectedDate, fallbackRecord: existingDayRecord);
    final recordToShow = nutritionGoals.applyToDayRecord(dayRecord);

    final isAnalyzingMeal = ref.watch(mealAnalysisProvider.select((s) => s.newMealAnalyzeLoading));
    final hasLoadedRecord = existingDayRecord != null;

    return Scaffold(
      backgroundColor: AppColors.meshBase,
      body: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Builder(
                builder: (context) {
                  if (!daily.initialLoadComplete && daily.isLoadingDayRecord && !hasLoadedRecord && !isAnalyzingMeal) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (daily.dayRecordError.isNotEmpty) {
                    return Center(child: Text(tr(LocaleKeys.dashboard_error_loading, namedArgs: {'error': daily.dayRecordError})));
                  }

                  final bottomInset = Platform.isAndroid ? MediaQuery.of(context).padding.bottom : 0.0;
                  return VariableBlurScrollView(
                    topBlurSigma: 52,
                    topBlurHeight: 0.1,
                    backgroundColor: Colors.transparent,
                    fadeColor: AppColors.meshBase,
                    backgroundWidget: const MeshGradientBackground(),
                    controller: scrollController,
                    padding: EdgeInsets.fromLTRB(AppSpacing.m, AppSpacing.xs, AppSpacing.m, AppSpacing.mega + 42 + bottomInset),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: Platform.isAndroid ? AppSpacing.huge * 2 - 20 : AppSpacing.huge * 2 - 12),
                        DateSelector(
                          selectedDate: selectedDate,
                          useSegmentedRing: DashboardScreen._useSegmentedDateRing,
                          onDateSelected: (date) {
                            ref.read(dailyRecordProvider.notifier).updateDate(date);
                          },
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        _caloriesTrackerWidget(recordToShow),
                        const SizedBox(height: AppSpacing.m),
                        RecentlyUploadedCard(
                          meals: recordToShow.meals,
                          exercises: recordToShow.exercises,
                          selectedDate: selectedDate,
                          exerciseSectionKey: exerciseSectionKey,
                          onMealTap: (meal) async {
                            await Navigator.of(context).push(MaterialPageRoute(builder: (_) => MealDetailScreen(meal: meal)));
                            ref.read(dailyRecordProvider.notifier).refresh();
                          },
                          onExerciseTap: (exercise) async {
                            await Navigator.of(context).push(MaterialPageRoute(builder: (_) => ExerciseDetailScreen(exercise: exercise)));
                            ref.read(dailyRecordProvider.notifier).refresh();
                          },
                          onEmptyStateTap: _showQuickActions,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _caloriesTrackerWidget(DayRecord recordToShow) {
    final rollover = ref.watch(dailyRecordProvider.select((s) => s.rolloverAmount));
    final caloriesPlanEnabled = ref.watch(sessionProvider.select((s) => s.caloriesPlanEnabled));
    Widget caloriesTrackerWidget;
    if (caloriesPlanEnabled) {
      caloriesTrackerWidget = Column(
        children: [
          CaloriesCard(dayRecord: recordToShow, rolloverAmount: rollover),
          const SizedBox(height: AppSpacing.s),
          MacrosRow(dayRecord: recordToShow),
        ],
      );
    } else {
      caloriesTrackerWidget = Column(
        children: [
          CaloriesCard(dayRecord: recordToShow, caloriesPlanEnabled: false, rolloverAmount: rollover),
          const SizedBox(height: AppSpacing.s),
          MacrosRow(dayRecord: recordToShow, caloriesPlanEnabled: false),
        ],
      );
    }
    return caloriesTrackerWidget;
  }
}

/// Standalone read-only dashboard for a specific date.
/// Used by Ask AI to preview an affected day.
/// No streak widget, no date picker, no bottom tab bar.
class DashboardPreviewScreen extends ConsumerStatefulWidget {
  const DashboardPreviewScreen({super.key, required this.date});

  final DateTime date;

  @override
  ConsumerState<DashboardPreviewScreen> createState() => _DashboardPreviewScreenState();
}

class _DashboardPreviewScreenState extends ConsumerState<DashboardPreviewScreen> {
  DayRecord? _dayRecord;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecord();
  }

  Future<void> _loadRecord() async {
    final record = await ref.read(dayRecordRepositoryProvider).getDayRecord(widget.date);
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
    ref.watch(nutritionGoalsProvider);
    final nutritionGoals = ref.read(nutritionGoalsProvider.notifier).goalsForDate(widget.date, fallbackRecord: _dayRecord);
    final recordToShow = nutritionGoals.applyToDayRecord(dayRecord);
    final dateLabel = DateFormat.yMMMd().format(widget.date);

    return LiquidGlassScope(
      child: Scaffold(
        backgroundColor: AppColors.meshBase,
        body: SafeArea(
          top: false,
          bottom: false,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                  children: [
                    VariableBlurScrollView(
                      topBlurSigma: 52,
                      topBlurHeight: 0.16,
                      edgeIntensity: 0.075,
                      topFadeHeight: 40,
                      bottomFadeHeight: 0,
                      backgroundColor: Colors.transparent,
                      fadeColor: AppColors.meshBase,
                      backgroundWidget: const MeshGradientBackground(),
                      padding: const EdgeInsets.fromLTRB(AppSpacing.m, AppSpacing.huge + 4, AppSpacing.m, AppSpacing.l),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: AppSizes.topBarHeight),
                          const SizedBox(height: AppSpacing.m),
                          _buildCaloriesTracker(recordToShow),
                          const SizedBox(height: AppSpacing.m),
                          RecentlyUploadedCard(
                            meals: recordToShow.meals,
                            exercises: recordToShow.exercises,
                            selectedDate: widget.date,
                            onMealTap: (meal) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => MealDetailScreen(meal: meal, isPreview: true))),
                          ),
                          const SizedBox(height: AppSpacing.huge),
                        ],
                      ),
                    ),
                    // Custom linear bottom fade
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: IgnorePointer(
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                AppColors.meshBase.withValues(alpha: 0.6),
                                AppColors.meshBase.withValues(alpha: 0.3),
                                AppColors.meshBase.withValues(alpha: 0.1),
                                AppColors.meshBase.withValues(alpha: 0),
                              ],
                              stops: const [0.0, 0.35, 0.7, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      left: AppSpacing.m + 1,
                      right: AppSpacing.m + 1,
                      child: SafeArea(
                        bottom: false,
                        child: CustomGlassAppBar(
                          title: dateLabel,
                          onBack: () => Navigator.of(context).pop(),
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
    final planEnabled = ref.watch(sessionProvider.select((s) => s.caloriesPlanEnabled));
    final rollover = ref.watch(dailyRecordProvider.select((s) => s.rolloverAmount));
    return Column(
      children: [
        CaloriesCard(dayRecord: recordToShow, caloriesPlanEnabled: planEnabled, rolloverAmount: rollover),
        const SizedBox(height: AppSpacing.s),
        MacrosRow(dayRecord: recordToShow, caloriesPlanEnabled: planEnabled),
      ],
    );
  }
}
