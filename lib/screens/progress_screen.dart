import 'package:diplomka/app_theme.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:diplomka/controller/day_record_controller.dart';
import 'package:diplomka/screens/main_screen.dart';
import 'package:diplomka/controller/weight_entry_controller.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/model/day_record.dart';
import 'package:diplomka/model/streak_info.dart';
import 'package:diplomka/model/weight_entry.dart';
import 'package:diplomka/services/session_manager.dart';
import 'package:diplomka/services/streak_service.dart';
import 'package:diplomka/screens/profile/ask_ai/ask_ai_screen.dart';
import 'package:diplomka/screens/profile/subscreens/export_pdf_intro_screen.dart';
import 'package:diplomka/widgets/bmi_card.dart';
import 'package:diplomka/widgets/current_weight_card.dart';
import 'package:diplomka/widgets/dietary_violations_calendar_card.dart';
import 'package:diplomka/widgets/weight_progress_card.dart';
import 'package:diplomka/widgets/variable_blur_scroll_view.dart';
import 'package:diplomka/widgets/mesh_gradient_background.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../widgets/weekly_energy_card.dart';

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

List<WeightEntry> _sortWeightEntries(List<WeightEntry> entries, {bool descending = true}) {
  final data = List<WeightEntry>.from(entries);
  data.sort((a, b) => descending ? b.date.compareTo(a.date) : a.date.compareTo(b.date));
  return data;
}

double? _computeGoalProgress({required double current, required double start, required double goal}) {
  if (goal == start) {
    return current == goal ? 1.0 : 0.0;
  }
  final double progress = goal > start ? (current - start) / (goal - start) : (start - current) / (start - goal);
  return progress.clamp(0.0, 1.0);
}

String _formatWeight(double value) {
  final isInt = value % 1 == 0;
  return value.toStringAsFixed(isInt ? 0 : 1);
}

StreakInfo _computeStreakMetrics(List<DayRecord> records) {
  return StreakService.to.calculateStreakInfo(records);
}

String _nextWeighInLabel(WeightEntry? latestEntry) {
  if (latestEntry == null) {
    return tr(LocaleKeys.progress_log_first_weigh_in);
  }
  final DateTime today = _dateOnly(DateTime.now());
  final DateTime entryDate = _dateOnly(latestEntry.date);
  final int daysSince = today.difference(entryDate).inDays;
  if (true || daysSince >= 7 && daysSince % 7 == 0) { // TODO: revert
    return tr(LocaleKeys.progress_log_today);
  }
  final int remaining = 7 - (daysSince % 7);
  return tr(LocaleKeys.progress_next_weigh_in, namedArgs: {'days': '$remaining'});
}

class _DailyAverageStats {
  final double average;
  final bool hasMeals;
  final String rangeLabel;

  const _DailyAverageStats({required this.average, required this.hasMeals, required this.rangeLabel});
}

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _calendarKey = GlobalKey();
  Worker? _scrollWorker;

  @override
  void initState() {
    super.initState();
    _scrollWorker = ever(MainScreenController.to.scrollToEnergy, (shouldScroll) {
      if (shouldScroll) {
        MainScreenController.to.scrollToEnergy.value = false;
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCalendarSection());
      }
    });
  }

  @override
  void dispose() {
    _scrollWorker?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToCalendarSection() {
    final keyContext = _calendarKey.currentContext;
    if (keyContext != null) {
      final box = keyContext.findRenderObject() as RenderBox?;
      if (box != null && box.attached) {
        final scrollableState = Scrollable.maybeOf(keyContext);
        if (scrollableState != null) {
          final position = scrollableState.position;
          final target = position.pixels + box.localToGlobal(Offset.zero, ancestor: null).dy - MediaQuery.of(context).padding.top - 16;
          _scrollController.animateTo(target.clamp(0.0, _scrollController.position.maxScrollExtent), duration: const Duration(milliseconds: 600), curve: Curves.easeInOut);
          return;
        }
      }
    }
    // Fallback: scroll to roughly the middle
    if (_scrollController.hasClients) {
      _scrollController.animateTo(_scrollController.position.maxScrollExtent * 0.45, duration: const Duration(milliseconds: 600), curve: Curves.easeInOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.meshBase,
      body: SafeArea(
        top: false,
        bottom: false,
        child: VariableBlurScrollView(
          controller: _scrollController,
          topBlurSigma: 52,
          topFadeHeight: 40,
          backgroundColor: Colors.transparent,
          fadeColor: AppColors.meshBase,
          backgroundWidget: const MeshGradientBackground(),
          padding: const EdgeInsets.fromLTRB(AppSpacing.m, AppSpacing.mega + AppSpacing.s, AppSpacing.m, AppSpacing.mega + 42),
          //collapsedHeader: Text(tr(LocaleKeys.progress_title), style: AppTextStyles.title17.copyWith(fontWeight: FontWeight.w700)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Obx(() {
                final weightEntries = WeightEntryController.to.entries.toList(growable: false);
                final double? profileWeight = SessionManager.to.weightKg.value;
                final double? goalWeight = SessionManager.to.goalWeightKg.value;

                final sortedWeights = _sortWeightEntries(weightEntries);
                final latestEntry = sortedWeights.isNotEmpty ? sortedWeights.first : null;
                final earliestEntry = sortedWeights.isNotEmpty ? sortedWeights.last : null;
                final double? currentWeight = latestEntry?.weight ?? profileWeight;
                final double? startWeight = earliestEntry?.weight ?? profileWeight;
                final goalProgress = currentWeight != null && startWeight != null && goalWeight != null ? _computeGoalProgress(current: currentWeight, start: startWeight, goal: goalWeight) : null;

                final nextLabel = _nextWeighInLabel(latestEntry);
                final logToday = nextLabel == tr(LocaleKeys.progress_log_today) || nextLabel == tr(LocaleKeys.progress_log_first_weigh_in);

                return CurrentWeightCard(
                  currentWeight: currentWeight,
                  startWeight: startWeight,
                  goalWeight: goalWeight,
                  goalProgress: goalProgress,
                  nextWeighInLabel: nextLabel,
                  isLogToday: logToday,
                  weightEntries: sortedWeights,
                );
              }),
              const SizedBox(height: AppSpacing.m),
              Obx(() {
                final entries = WeightEntryController.to.entries;
                if (entries.isEmpty) {
                  return const WeightProgressCard(entries: []);
                }
                return WeightProgressCard(entries: entries.toList(growable: false));
              }),
              const SizedBox(height: AppSpacing.m),
              KeyedSubtree(key: _calendarKey, child: const MonthlyCalendarCard()),
              const SizedBox(height: AppSpacing.m),
              const WeeklyEnergyCard(),
              const SizedBox(height: AppSpacing.m),
              Obx(() {
                final weightEntries = WeightEntryController.to.entries.toList(growable: false);
                final sorted = _sortWeightEntries(weightEntries);
                final latest = sorted.isNotEmpty ? sorted.first : null;
                return BmiCard(currentWeight: latest?.weight, heightCm: SessionManager.to.heightCm.value);
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _DayLabel extends StatelessWidget {
  final String label;
  final bool highlight;

  const _DayLabel(this.label, {this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
      child: Text(label, style: AppTextStyles.label9.copyWith(color: highlight ? AppColors.orange : AppColors.textPrimary)),
    );
  }
}

class _DailyAverageCard extends StatefulWidget {
  const _DailyAverageCard();

  @override
  State<_DailyAverageCard> createState() => _DailyAverageCardState();
}

class _DailyAverageCardState extends State<_DailyAverageCard> {
  int _selectedIndex = 0;

  List<String> get _labels => [tr(LocaleKeys.progress_this_wk), tr(LocaleKeys.progress_last_wk), tr(LocaleKeys.progress_two_wk_ago), tr(LocaleKeys.progress_three_wk_ago)];

  DateTime _startOfWeek(DateTime date) => DateTime(date.year, date.month, date.day - (date.weekday - 1));

  _DailyAverageStats _calculateStats(List<DayRecord> records, int index) {
    final DateTime today = _dateOnly(DateTime.now());
    final DateTime baseWeekStart = _startOfWeek(today);
    final DateTime weekStart = DateTime(baseWeekStart.year, baseWeekStart.month, baseWeekStart.day - 7 * index);
    final DateTime weekEnd = DateTime(weekStart.year, weekStart.month, weekStart.day + 6);

    final Map<DateTime, DayRecord> byDate = {for (final record in records) _dateOnly(record.date): record};

    double totalCalories = 0;
    bool hasMeals = false;

    for (int i = 0; i < 7; i++) {
      final date = DateTime(weekStart.year, weekStart.month, weekStart.day + i);
      final record = byDate[date];
      if (record != null && record.meals.isNotEmpty) {
        hasMeals = true;
      }
      totalCalories += record?.totalCalories ?? 0;
    }

    final double average = hasMeals ? totalCalories / 7 : 0;
    final rangeLabel = '${DateFormat('MMM d').format(weekStart)} - ${DateFormat('MMM d').format(weekEnd)}';
    return _DailyAverageStats(average: average, hasMeals: hasMeals, rangeLabel: rangeLabel);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final records = DayRecordController.to.dayRecords.toList(growable: false);
      final stats = _calculateStats(records, _selectedIndex);

      return Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.l),
          border: Border.all(color: AppColors.outline),
          boxShadow: AppShadows.cardSoft,
        ),
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tr(LocaleKeys.progress_daily_avg_calories), style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: AppSpacing.xl),
            Center(
              child: Column(
                children: [
                  Container(
                    width: AppSizes.cardIconLg,
                    height: AppSizes.cardIconLg,
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadii.m)),
                    child: const Icon(CupertinoIcons.chart_bar, color: AppColors.textTertiary),
                  ),
                  const SizedBox(height: AppSpacing.m),
                  if (stats.hasMeals)
                    Text(tr(LocaleKeys.progress_avg_kcal, namedArgs: {'value': '${stats.average.round()}'}), style: AppTextStyles.weightValue)
                  else
                    Text(tr(LocaleKeys.progress_no_data), style: AppTextStyles.body16.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    stats.hasMeals ? '${tr(LocaleKeys.progress_avg_per_day)} • ${stats.rangeLabel}' : tr(LocaleKeys.progress_update_hint),
                    style: AppTextStyles.body14.copyWith(color: AppColors.textTertiary),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            _SegmentedControl(labels: _labels, selectedIndex: _selectedIndex, onTap: (index) => setState(() => _selectedIndex = index)),
          ],
        ),
      );
    });
  }
}

class _SegmentedControl extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int>? onTap;

  const _SegmentedControl({required this.labels, required this.selectedIndex, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GlassSegmentedControl(segments: labels, selectedIndex: selectedIndex, onSegmentSelected: onTap ?? (_) {}, useOwnLayer: true);
  }
}
