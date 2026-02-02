import 'dart:async';
import 'dart:math';

import 'package:diplomka/controller/dashboard_controller.dart';
import 'package:diplomka/model/meal.dart';
import 'package:diplomka/widgets/progress_ring.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:diplomka/app_theme.dart';

class RecentlyUploadedCard extends StatelessWidget {
  final List<Meal> meals;
  final Function(Meal meal)? onMealTap;

  const RecentlyUploadedCard({super.key, required this.meals, this.onMealTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Today's meals",
          style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: AppSpacing.sm),
        Obx(() {
          final isLoading = DashboardController.to.newMealAnalyzeLoading.value;
          final hasMeals = meals.isNotEmpty;

          List<Widget> children = [];

          if (hasMeals) {
            children.add(_buildMealsList(context));
          }

          if (isLoading) {
            if (hasMeals) {
              // Add spacing if there are meals and we are showing the loader
              children.add(const SizedBox(height: AppSpacing.xs));
            }
            children.add(const AnalyzingMealCard());
          }

          if (!isLoading && !hasMeals) {
            children.add(_buildEmptyState());
          }
          
          return Column(children: children);
        }),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: AppSizes.emptyStateHeight,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.cardSoft,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: AppSizes.emptyStateIconSize,
            height: AppSizes.emptyStateIconSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.outline),
            ),
            child: const Icon(Icons.add, color: AppColors.textTertiary),
          ),
          const SizedBox(height: AppSpacing.md),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Text(
              'Tap + to add your first meal of the day',
              style: AppTextStyles.body14.copyWith(color: AppColors.textTertiary),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealsList(BuildContext context) {
    return Column(
      children: meals.map((meal) => _buildMealItem(context, meal)).toList(),
    );
  }

  Widget _buildMealItem(BuildContext context, Meal meal) {
    final String mealTime = DateFormat('h:mm a').format(meal.timestamp);

    return GestureDetector(
      onTap: () => onMealTap?.call(meal),
      child: Container(
        height: AppSizes.mealCardHeight,
        margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: Border.all(color: AppColors.border),
          boxShadow: AppShadows.cardSoft,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: AppSizes.mealImageSize,
                height: AppSizes.mealImageSize,
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
                child: const Icon(Icons.restaurant, color: AppColors.textTertiary),
              ),
              const SizedBox(width: AppSpacing.md),
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
                                meal.name,
                                style: AppTextStyles.body16.copyWith(fontWeight: FontWeight.w600),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                mealTime,
                                style: AppTextStyles.body13.copyWith(color: AppColors.textTertiary),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              meal.totalCalories.toStringAsFixed(0),
                              style: AppTextStyles.body16.copyWith(fontWeight: FontWeight.w700),
                            ),
                            Text(
                              'kcal',
                              style: AppTextStyles.caption12.copyWith(color: AppColors.textTertiary),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      height: AppSizes.dividerThin,
                      color: AppColors.border,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        _MacroDot(value: meal.totalProteins.toStringAsFixed(0), color: AppColors.macroProtein),
                        const SizedBox(width: AppSpacing.sm),
                        _MacroDot(value: meal.totalCarbs.toStringAsFixed(0), color: AppColors.macroCarbs),
                        const SizedBox(width: AppSpacing.sm),
                        _MacroDot(value: meal.totalFats.toStringAsFixed(0), color: AppColors.macroFats),
                      ],
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

class AnalyzingMealCard extends StatefulWidget {
  const AnalyzingMealCard({super.key});

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
    return Container(
      height: AppSizes.mealCardHeight,
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.cardSoft,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: AppSizes.mealImageSize,
              height: AppSizes.mealImageSize,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadii.sm2),
                color: AppColors.surfaceMuted,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadii.sm2),
                      color: AppColors.overlayDark60,
                    ),
                  ),
                  ProgressRing(
                    size: AppSizes.macroRingSize,
                    strokeWidth: AppSizes.progressRingStroke,
                    value: _progress,
                    backgroundColor: AppColors.onPrimary.withValues(alpha: 0.2),
                    foregroundColor: AppColors.onPrimary,
                    child: Text(
                      '${(_progress * 100).toInt()}%',
                      style: AppTextStyles.body14.copyWith(color: AppColors.onPrimary, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recognising meal',
                    style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      _ProgressSegment(width: AppSizes.progressSegmentMd, opacity: 0.8),
                      const SizedBox(width: AppSpacing.xs),
                      _ProgressSegment(width: AppSizes.progressSegmentSm, opacity: 0.72),
                      const SizedBox(width: AppSpacing.xs),
                      _ProgressSegment(width: AppSizes.progressSegmentLg, opacity: 0.64),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    "We’ll notify you when it’s done!",
                    style: AppTextStyles.body14.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroDot extends StatelessWidget {
  final String value;
  final Color color;

  const _MacroDot({required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: AppSizes.macroDot,
          height: AppSizes.macroDot,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.7),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          '${value}g',
          style: AppTextStyles.caption12.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
        ),
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
