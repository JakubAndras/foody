import 'dart:async';
import 'dart:math';

import 'package:diplomka/state/dashboard_notifier.dart';
import 'package:diplomka/model/exercise.dart';
import 'package:diplomka/model/meal.dart';
import 'package:diplomka/utils/media_storage.dart';
import 'package:diplomka/widgets/progress_ring.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:diplomka/widgets/animated_add_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:diplomka/app_theme.dart';
import 'package:diplomka/services/session_manager.dart';

class RecentlyUploadedCard extends ConsumerWidget {
  final List<Meal> meals;
  final List<Exercise> exercises;
  final DateTime selectedDate;
  final Function(Meal meal)? onMealTap;
  final Function(Meal meal)? onMealLongPress;
  final Function(Exercise exercise)? onExerciseTap;
  final Function(Exercise exercise)? onExerciseLongPress;
  final VoidCallback? onEmptyStateTap;
  final GlobalKey? exerciseSectionKey;

  const RecentlyUploadedCard({
    super.key,
    required this.meals,
    required this.exercises,
    required this.selectedDate,
    this.onMealTap,
    this.onMealLongPress,
    this.onExerciseTap,
    this.onExerciseLongPress,
    this.onEmptyStateTap,
    this.exerciseSectionKey,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final isToday = selectedDate.year == now.year && selectedDate.month == now.month && selectedDate.day == now.day;
    final title = isToday
        ? tr(LocaleKeys.dashboard_meals_title_today)
        : tr(LocaleKeys.dashboard_meals_title, namedArgs: {'date': DateFormat('MMM d').format(selectedDate).replaceFirstMapped(RegExp(r'^.'), (m) => m[0]!.toUpperCase())});
    final sectionHeaderPaddingEnabled = ref.watch(sessionProvider).sectionHeaderPaddingEnabled;
    final isMealLoading = ref.watch(mealAnalysisProvider).newMealAnalyzeLoading;
    final isExerciseLoading = ref.watch(activityAnalysisProvider).newExerciseAnalyzeLoading;
    final mealSection = _buildMealSection(context, isMealLoading: isMealLoading);
    final exerciseSection = _buildExerciseSection(context, isExerciseLoading: isExerciseLoading, hasMealSectionContent: mealSection.isNotEmpty, sectionHeaderPaddingEnabled: sectionHeaderPaddingEnabled);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: sectionHeaderPaddingEnabled ? AppSpacing.s : 0),
          child: Text(
            title,
            style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        Column(children: [...mealSection, ...exerciseSection]),
      ],
    );
  }

  List<Widget> _buildMealSection(BuildContext context, {required bool isMealLoading}) {
    final hasMeals = meals.isNotEmpty;
    return <Widget>[
      // Loading card on top so the currently analyzing meal is most visible.
      if (isMealLoading) ...<Widget>[const AnalyzingMealCard(), if (hasMeals) const SizedBox(height: AppSpacing.xs)],
      if (hasMeals) _buildMealsList(context),
      if (!isMealLoading && !hasMeals) ...<Widget>[const SizedBox(height: AppSpacing.xs), _buildEmptyState()],
    ];
  }

  List<Widget> _buildExerciseSection(BuildContext context, {required bool isExerciseLoading, required bool hasMealSectionContent, required bool sectionHeaderPaddingEnabled}) {
    final hasExercises = exercises.isNotEmpty;
    if (!hasExercises && !isExerciseLoading) {
      return const <Widget>[];
    }

    return <Widget>[
      if (hasMealSectionContent) const SizedBox(height: AppSpacing.m),
      _buildExerciseHeader(sectionHeaderPaddingEnabled: sectionHeaderPaddingEnabled),
      const SizedBox(height: AppSpacing.xxs),
      // Loading card on top so the currently analyzing exercise is most visible.
      if (isExerciseLoading) ...<Widget>[const AnalyzingMealCard(analysisType: AnalysisCardType.exercise), if (hasExercises) const SizedBox(height: AppSpacing.xs)],
      if (hasExercises) _buildExercisesList(context),
    ];
  }

  Widget _buildExerciseHeader({required bool sectionHeaderPaddingEnabled}) {
    final now = DateTime.now();
    final isToday = selectedDate.year == now.year && selectedDate.month == now.month && selectedDate.day == now.day;
    final title = isToday
        ? tr(LocaleKeys.dashboard_exercises_title_today)
        : tr(LocaleKeys.dashboard_exercises_title, namedArgs: {'date': DateFormat('MMM d').format(selectedDate).replaceFirstMapped(RegExp(r'^.'), (m) => m[0]!.toUpperCase())});
    return Padding(
      key: exerciseSectionKey,
      padding: EdgeInsets.symmetric(horizontal: sectionHeaderPaddingEnabled ? AppSpacing.s : 0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(title, style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return GestureDetector(
      onTap: onEmptyStateTap,
      child: Container(
        width: double.infinity,
        height: AppSizes.emptyStateHeight,
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadii.l), border: AppBorders.screenCard, boxShadow: AppShadows.screenCard),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: AppSizes.emptyStateIconSize,
              height: AppSizes.emptyStateIconSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: AppBorders.screenCard ?? Border.all(color: AppColors.textTertiary.withValues(alpha: 0.3)),
              ),
              child: Icon(CupertinoIcons.add, color: AppColors.textTertiary),
            ),
            const SizedBox(height: AppSpacing.m),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Text(
                tr(LocaleKeys.dashboard_empty_state),
                style: AppTextStyles.body14.copyWith(color: AppColors.textTertiary),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealsList(BuildContext context) {
    // Newest meals first so the most recently added meal appears at the top.
    final sorted = [...meals]..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return Column(children: sorted.map((meal) => _buildMealItem(context, meal)).toList());
  }

  Widget _buildMealItem(BuildContext context, Meal meal) {
    final file = MediaStorage.existingMealPhotoFile(meal.photoPath);
    return MealItemCard(
      name: meal.name,
      kcalText: '${meal.totalCalories.toStringAsFixed(0)} ${tr(LocaleKeys.common_kcal)}',
      proteins: meal.totalProteins,
      carbs: meal.totalCarbs,
      fats: meal.totalFats,
      timeText: DateFormat('HH:mm').format(meal.timestamp),
      imageProvider: file != null ? FileImage(file) : null,
      isBarcodeMeal: meal.barcode != null,
      onTap: () => onMealTap?.call(meal),
      onLongPress: () => onMealLongPress?.call(meal),
    );
  }

  Widget _buildExercisesList(BuildContext context) {
    return Column(children: exercises.map((exercise) => _buildExerciseItem(context, exercise)).toList());
  }

  Widget _buildExerciseItem(BuildContext context, Exercise exercise) {
    final String exerciseTime = DateFormat('HH:mm').format(exercise.timestamp);
    final String exerciseDuration = exercise.durationMinutes == null ? '-' : '${exercise.durationMinutes} min';

    return GestureDetector(
      onTap: exercise.isFromHealthSync ? null : () => onExerciseTap?.call(exercise),
      onLongPress: exercise.isFromHealthSync ? null : () => onExerciseLongPress?.call(exercise),
      child: Container(
        height: AppSizes.exerciseCardHeight,
        margin: const EdgeInsets.symmetric(vertical: AppSpacing.xxs + 1),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadii.l), border: AppBorders.screenCard, boxShadow: AppShadows.screenCard),
        child: Padding(
          padding: const EdgeInsets.only(left: AppSpacing.xs, right: AppSpacing.m),
          child: Row(
            children: [
              Container(
                width: AppSizes.exerciseImageSize,
                height: AppSizes.exerciseImageSize,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppRadii.m), gradient: AppGradients.exerciseCalories),
                child: Icon(Icons.directions_run_rounded, color: AppColors.onPrimary),
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                exercise.name,
                                style: AppTextStyles.body16.copyWith(fontWeight: FontWeight.w600),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                '${exercise.caloriesBurned.toStringAsFixed(0)} ${tr(LocaleKeys.common_kcal)}',
                                style: AppTextStyles.body13.copyWith(color: AppColors.textTertiary),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(exerciseTime, style: AppTextStyles.body13.copyWith(color: AppColors.textTertiary)),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s),
                    Container(height: AppSizes.dividerThin, color: AppColors.outline),
                    const SizedBox(height: AppSpacing.xs),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        tr(LocaleKeys.dashboard_exercise_duration, namedArgs: {'duration': exerciseDuration}),
                        style: AppTextStyles.caption12.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum AnalysisCardType { meal, exercise }

class AnalyzingMealCard extends StatefulWidget {
  const AnalyzingMealCard({super.key, this.analysisType = AnalysisCardType.meal});

  final AnalysisCardType analysisType;

  @override
  State<AnalyzingMealCard> createState() => _AnalyzingMealCardState();
}

class _AnalyzingMealCardState extends State<AnalyzingMealCard> {
  Timer? _timer;
  double _progress = 0.0;
  final Random _random = Random();
  int _durationInSeconds = 0;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  void _startAnimation() {
    _timer?.cancel(); // Cancel any existing timer
    setState(() {
      _progress = 0.0;
      // Duration between 7 and 12 seconds (inclusive)
      _durationInSeconds = _random.nextInt(6) + 7;
    });

    const updateInterval = Duration(milliseconds: 100);
    final totalUpdates = (_durationInSeconds * 1000) ~/ updateInterval.inMilliseconds;
    double progressIncrement = 1.0 / totalUpdates;

    _timer = Timer.periodic(updateInterval, (timer) {
      setState(() {
        _progress += progressIncrement;
        if (_progress >= 1.0) {
          _progress = 1.0;
          timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isExercise = widget.analysisType == AnalysisCardType.exercise;
    final title = isExercise ? tr(LocaleKeys.dashboard_recognising_exercise) : tr(LocaleKeys.dashboard_recognising_meal);
    final subtitle = isExercise ? tr(LocaleKeys.dashboard_recognising_exercise_subtitle) : tr(LocaleKeys.dashboard_recognising_meal_subtitle);
    final cardHeight = isExercise ? AppSizes.exerciseCardHeight : AppSizes.mealCardHeight;
    final leadingDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(AppRadii.m),
      color: isExercise ? null : AppColors.surfaceMuted,
      gradient: isExercise ? AppGradients.exerciseCalories : null,
    );
    final leadingIcon = isExercise ? Icons.directions_run_rounded : Icons.restaurant;

    return Container(
      height: cardHeight,
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadii.l), border: AppBorders.screenCard, boxShadow: AppShadows.screenCard),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
        child: Row(
          children: [
            Container(
              width: AppSizes.mealImageSize,
              height: AppSizes.mealImageSize,
              decoration: leadingDecoration,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppRadii.m), color: AppColors.overlayDark60),
                  ),
                  if (isExercise) Icon(leadingIcon, color: AppColors.onPrimary.withValues(alpha: 0.45), size: AppSizes.iconLg),
                  ProgressRing(
                    size: AppSizes.macroRingSize,
                    strokeWidth: AppSizes.progressRingStroke,
                    value: _progress,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    foregroundColor: Colors.white,
                    child: Text(
                      '${(_progress * 100).toInt()}%',
                      style: AppTextStyles.body14.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: AppSpacing.s),
                  Row(
                    children: [
                      _ProgressSegment(width: AppSizes.progressSegmentMd, opacity: 0.8),
                      const SizedBox(width: AppSpacing.xs),
                      _ProgressSegment(width: AppSizes.progressSegmentSm, opacity: 0.72),
                      const SizedBox(width: AppSpacing.xs),
                      _ProgressSegment(width: AppSizes.progressSegmentLg, opacity: 0.64),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s),
                  Text(subtitle, style: AppTextStyles.body14.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MealItemCard extends StatelessWidget {
  const MealItemCard({
    super.key,
    required this.name,
    required this.kcalText,
    required this.proteins,
    required this.carbs,
    required this.fats,
    this.timeText,
    this.imageProvider,
    this.isBarcodeMeal = false,
    this.onTap,
    this.onLongPress,
    this.onAdd,
  });

  final String name;
  final String kcalText;
  final double proteins;
  final double carbs;
  final double fats;
  final String? timeText;
  final ImageProvider? imageProvider;
  final bool isBarcodeMeal;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        height: AppSizes.mealCardHeight,
        margin: const EdgeInsets.symmetric(vertical: AppSpacing.xxs + 1),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadii.l), border: AppBorders.screenCard, boxShadow: AppShadows.screenCard),
        child: Padding(
          padding: const EdgeInsets.only(left: AppSpacing.xs, right: AppSpacing.m),
          child: Row(
            children: [
              _buildImage(),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: AppTextStyles.body16.copyWith(fontWeight: FontWeight.w600),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: AppSpacing.xxs),
                              Text(
                                kcalText,
                                style: AppTextStyles.body13.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                        if (timeText != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(timeText!, style: AppTextStyles.body13.copyWith(color: AppColors.textTertiary)),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Container(
                      height: AppSizes.dividerThin,
                      color: AppColors.outline,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        _MacroDot(value: proteins.toStringAsFixed(0), color: AppColors.macroProtein),
                        const SizedBox(width: AppSpacing.s),
                        _MacroDot(value: carbs.toStringAsFixed(0), color: AppColors.macroCarbs),
                        const SizedBox(width: AppSpacing.s),
                        _MacroDot(value: fats.toStringAsFixed(0), color: AppColors.macroFats),
                      ],
                    ),
                  ],
                ),
              ),
              if (onAdd != null) ...[
                const SizedBox(width: AppSpacing.s),
                AnimatedAddButton(itemKey: name, onAdd: onAdd!),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    return Container(
      width: AppSizes.mealDashboardImageSize,
      height: AppSizes.mealDashboardImageSize,
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadii.m),
        image: imageProvider != null ? DecorationImage(image: imageProvider!, fit: BoxFit.cover) : null,
      ),
      child: imageProvider == null ? Icon(isBarcodeMeal ? CupertinoIcons.barcode_viewfinder : Icons.restaurant, color: AppColors.textTertiary) : null,
    );
  }
}

class _MacroDot extends StatelessWidget {
  final String value;
  final Color color;

  const _MacroDot({required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final style = AppTextStyles.body13.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w500);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: style.fontSize! * (style.height ?? 1.0),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 0.5),
              child: Container(
                width: AppSizes.macroDot,
                height: AppSizes.macroDot,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.xxs),
        Text('${value}g', style: style),
      ],
    );
  }
}

class _ProgressSegment extends StatelessWidget {
  final double width;
  final double opacity;

  const _ProgressSegment({required this.width, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: AppSizes.progressBarHeight,
      decoration: BoxDecoration(
        color: AppColors.outline.withValues(alpha: opacity),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
    );
  }
}
