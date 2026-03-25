import 'package:diplomka/app_theme.dart';
import 'package:diplomka/widgets/info_dialog.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:diplomka/controller/day_record_controller.dart';
import 'package:diplomka/controller/weight_entry_controller.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/model/day_record.dart';
import 'package:diplomka/model/streak_info.dart';
import 'package:diplomka/model/weight_entry.dart';
import 'package:diplomka/services/session_manager.dart';
import 'package:diplomka/services/streak_service.dart';
import 'package:diplomka/screens/profile/ask_ai/ask_ai_screen.dart';
import 'package:diplomka/screens/profile/subscreens/export_pdf_intro_screen.dart';
import 'package:diplomka/widgets/current_weight_card.dart';
import 'package:diplomka/widgets/dietary_violations_calendar_card.dart';
import 'package:diplomka/widgets/weight_progress_card.dart';
import 'package:diplomka/widgets/variable_blur_scroll_view.dart';
import 'package:diplomka/widgets/mesh_gradient_background.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
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

class _BmiCategory {
  final String label;
  final Color color;

  const _BmiCategory({required this.label, required this.color});
}

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.meshBase,
      body: SafeArea(
        top: false,
        bottom: false,
        child: VariableBlurScrollView(
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
              const MonthlyCalendarCard(),
              const SizedBox(height: AppSpacing.m),
              const WeeklyEnergyCard(),
              const SizedBox(height: AppSpacing.m),
              Obx(() {
                final weightEntries = WeightEntryController.to.entries.toList(growable: false);
                final sorted = _sortWeightEntries(weightEntries);
                final latest = sorted.isNotEmpty ? sorted.first : null;
                return _BmiCard(currentWeight: latest?.weight, heightCm: SessionManager.to.heightCm.value);
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

  DateTime _startOfWeek(DateTime date) => date.subtract(Duration(days: date.weekday - 1));

  _DailyAverageStats _calculateStats(List<DayRecord> records, int index) {
    final DateTime today = _dateOnly(DateTime.now());
    final DateTime weekStart = _startOfWeek(today).subtract(Duration(days: 7 * index));
    final DateTime weekEnd = weekStart.add(const Duration(days: 6));

    final Map<DateTime, DayRecord> byDate = {for (final record in records) _dateOnly(record.date): record};

    double totalCalories = 0;
    bool hasMeals = false;

    for (int i = 0; i < 7; i++) {
      final date = weekStart.add(Duration(days: i));
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
                    child: const Icon(Icons.bar_chart_rounded, color: AppColors.textTertiary),
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

class _BmiCard extends StatelessWidget {
  const _BmiCard({this.currentWeight, this.heightCm});

  final double? currentWeight;
  final double? heightCm;

  double? get _bmiValue {
    if (currentWeight == null || heightCm == null || heightCm! <= 0) return null;
    final heightM = heightCm! / 100;
    return currentWeight! / (heightM * heightM);
  }

  _BmiCategory _bmiCategory(double bmi) {
    if (bmi < 18.5) return _BmiCategory(label: tr(LocaleKeys.progress_bmi_underweight), color: AppColors.info);
    if (bmi < 25) return _BmiCategory(label: tr(LocaleKeys.progress_bmi_healthy), color: AppColors.success);
    if (bmi < 30) return _BmiCategory(label: tr(LocaleKeys.progress_bmi_overweight), color: AppColors.warning);
    return _BmiCategory(label: tr(LocaleKeys.progress_bmi_obese), color: AppColors.error);
  }

  @override
  Widget build(BuildContext context) {
    final double? bmi = _bmiValue;
    final _BmiCategory? category = bmi == null ? null : _bmiCategory(bmi);
    final bool hasWeight = currentWeight != null;
    final bool hasHeight = heightCm != null && heightCm! > 0;
    final String missingLabel = !hasHeight && !hasWeight
        ? tr(LocaleKeys.progress_missing_height_weight)
        : !hasHeight
        ? tr(LocaleKeys.progress_missing_height)
        : tr(LocaleKeys.progress_missing_weight);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.l),
        border: AppBorders.screenCard,
        boxShadow: AppShadows.screenCard,
      ),
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(tr(LocaleKeys.progress_your_bmi), style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w700)),
              GestureDetector(
                onTap: () => showInfoDialog(context, title: tr(LocaleKeys.progress_bmi_info_title), body: tr(LocaleKeys.progress_bmi_info_body)),
                child: const Icon(Icons.info_outline, size: AppSizes.iconMd, color: AppColors.textTertiary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          if (bmi == null)
            Text(missingLabel, style: AppTextStyles.body14.copyWith(color: AppColors.textTertiary))
          else
            Row(
              children: [
                Text(bmi.toStringAsFixed(1), style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(width: AppSpacing.s),
                Text(tr(LocaleKeys.progress_your_weight_is), style: AppTextStyles.body14.copyWith(color: AppColors.textTertiary)),
                const SizedBox(width: AppSpacing.xs),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: AppSpacing.xxs),
                  decoration: BoxDecoration(color: category!.color, borderRadius: BorderRadius.circular(AppRadii.xs)),
                  child: Text(
                    category.label,
                    style: AppTextStyles.caption12.copyWith(color: AppColors.onPrimary, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          const SizedBox(height: AppSpacing.m),
          LayoutBuilder(
            builder: (context, constraints) {
              double indicatorX = 0;
              if (bmi != null) {
                final double clamped = bmi.clamp(16, 40);
                indicatorX = ((clamped - 16) / (40 - 16)) * constraints.maxWidth;
              }
              return Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Container(
                    height: AppSizes.bmiBarHeight,
                    decoration: BoxDecoration(gradient: AppGradients.bmi, borderRadius: BorderRadius.circular(AppRadii.pill)),
                  ),
                  if (bmi != null)
                    Positioned(
                      left: indicatorX,
                      child: Container(
                        width: AppSizes.bmiMarkerWidth,
                        height: AppSizes.bmiMarkerHeight,
                        decoration: BoxDecoration(color: AppColors.textPrimary, borderRadius: BorderRadius.circular(AppRadii.pill)),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.m),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _LegendItem(label: tr(LocaleKeys.progress_bmi_underweight), color: AppColors.info),
              _LegendItem(label: tr(LocaleKeys.progress_bmi_healthy), color: AppColors.success),
              _LegendItem(label: tr(LocaleKeys.progress_bmi_overweight), color: AppColors.warning),
              _LegendItem(label: tr(LocaleKeys.progress_bmi_obese), color: AppColors.error),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final String label;
  final Color color;

  const _LegendItem({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: AppSizes.legendDot,
          height: AppSizes.legendDot,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(label, style: AppTextStyles.label10.copyWith(color: AppColors.textTertiary)),
      ],
    );
  }
}

class _InsightsActionsCard extends StatelessWidget {
  const _InsightsActionsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.l),
        border: Border.all(color: AppColors.outline),
        boxShadow: AppShadows.cardSoft,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.m, AppSpacing.m, AppSpacing.m, 0),
            child: Text(tr(LocaleKeys.progress_insights_actions), style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: AppSpacing.s),
          _InsightActionRow(
            icon: Icons.ios_share_outlined,
            title: tr(LocaleKeys.progress_export_summary),
            onTap: () => Get.to(() => const ExportPdfIntroScreen()),
          ),
          _InsightActionRow(
            icon: Icons.auto_awesome_outlined,
            title: tr(LocaleKeys.progress_ask_ai),
            showDivider: false,
            onTap: () => Get.to(() => const AskAiScreen()),
          ),
        ],
      ),
    );
  }
}

class _InsightActionRow extends StatelessWidget {
  const _InsightActionRow({required this.icon, required this.title, this.showDivider = true, this.onTap});

  final IconData icon;
  final String title;
  final bool showDivider;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: AppSpacing.s),
            child: Row(
              children: [
                Icon(icon, size: AppSizes.iconMd, color: AppColors.textPrimary),
                const SizedBox(width: AppSpacing.m),
                Expanded(child: Text(title, style: AppTextStyles.body16.copyWith(fontWeight: FontWeight.w500))),
                const Icon(Icons.chevron_right, size: AppSizes.iconMd, color: AppColors.textTertiary),
              ],
            ),
          ),
          if (showDivider)
            Padding(
              padding: const EdgeInsets.only(left: AppSizes.settingsDividerIndent),
              child: Divider(height: AppSizes.dividerThin, color: AppColors.surfaceMuted),
            ),
        ],
      ),
    );
  }
}
