import 'package:diplomka/app_theme.dart';
import 'package:diplomka/controller/day_record_controller.dart';
import 'package:diplomka/model/ingredient.dart';
import 'package:diplomka/model/meal.dart';
import 'package:diplomka/screens/meals/fix_result_screen.dart';
import 'package:diplomka/screens/meals/ingredient_detail_screen.dart';
import 'package:diplomka/screens/meals/report_meal_screen.dart';
import 'package:diplomka/screens/meals/meal_components.dart';
import 'package:diplomka/screens/meals/meal_sheets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MealDetailScreen extends StatefulWidget {
  final Meal? meal;
  final bool showAllergyAlert;
  final bool showCaloriesDelta;
  final MatchBadgeVariant matchBadgeVariant;

  const MealDetailScreen({
    super.key,
    this.meal,
    this.showAllergyAlert = false,
    this.showCaloriesDelta = false,
    this.matchBadgeVariant = MatchBadgeVariant.good,
  });

  @override
  State<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> {
  late Meal _meal;

  @override
  void initState() {
    super.initState();
    _meal = widget.meal ?? _stubMeal;
  }

  Future<void> _toggleFavorite() async {
    final next = !_meal.isFavorite;
    setState(() => _meal = _meal.copyWith(isFavorite: next));
    if (_meal.id == null || _meal.dayRecordId == null) return;
    await DayRecordController.to.setMealFavorite(meal: _meal, isFavorite: next);
  }

  @override
  Widget build(BuildContext context) {
    final mealData = _meal;
    final date = DateTime(2026, 1, 11);
    final caloriesValue = widget.showCaloriesDelta ? '300' : '175';
    const double heroOverlap = AppSpacing.lg;

    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: AppSizes.buttonHeight + AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.showAllergyAlert)
                  Column(
                    children: [
                      SizedBox(
                        height: AppSizes.mealHeroHeight + AppSizes.alertCardHeight - heroOverlap,
                        child: Stack(
                          children: [
                            MealHeroHeader(
                              title: mealData.name,
                              timeLabel: _formatTime(mealData.timestamp),
                            ),
                            Positioned(
                              left: AppSpacing.edge,
                              right: AppSpacing.edge,
                              top: AppSizes.mealHeroHeight - heroOverlap,
                              child: const AllergyAlertCard(
                                title: 'Allergy Alert',
                                subtitle: 'This meal contains: Fish',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.edge),
                        child: CaloriesSummaryCard(
                          label: 'Calories',
                          value: caloriesValue,
                          delta: widget.showCaloriesDelta ? '+125' : null,
                          height: AppSizes.caloriesCardHeight,
                          badge: MatchBadge(
                            text: _matchText(widget.matchBadgeVariant),
                            variant: widget.matchBadgeVariant,
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  SizedBox(
                    height: AppSizes.mealHeroHeight + AppSizes.caloriesCardHeight - heroOverlap,
                    child: Stack(
                      children: [
                        MealHeroHeader(
                          title: mealData.name,
                          timeLabel: _formatTime(mealData.timestamp),
                        ),
                        Positioned(
                          left: AppSpacing.edge,
                          right: AppSpacing.edge,
                          top: AppSizes.mealHeroHeight - heroOverlap,
                          child: CaloriesSummaryCard(
                            label: 'Calories',
                            value: caloriesValue,
                            delta: widget.showCaloriesDelta ? '+125' : null,
                            height: AppSizes.caloriesCardHeight,
                            badge: MatchBadge(
                              text: _matchText(widget.matchBadgeVariant),
                              variant: widget.matchBadgeVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: AppSpacing.sm),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.edge),
                  child: Row(
                    children: [
                      MacroStatCard(
                        label: 'Protein',
                        value: '38g',
                        icon: Icons.bolt,
                        iconColor: AppColors.macroProtein,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      MacroStatCard(
                        label: 'Carbs',
                        value: '45g',
                        icon: Icons.grain,
                        iconColor: AppColors.macroCarbsStrong,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      MacroStatCard(
                        label: 'Fats',
                        value: '0g',
                        icon: Icons.opacity,
                        iconColor: AppColors.macroFats,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                MealRecordCard(
                  amount: '400 x 1 g',
                  mealtime: 'Lunch',
                  date: _formatDate(date),
                  onAmountTap: () => _showPortionPicker(context),
                  onMealtimeTap: () => _showMealtimePicker(context),
                  onDateTap: () => _showDatePicker(context, date),
                  margin: const EdgeInsets.symmetric(horizontal: AppSpacing.edge),
                ),
                const SizedBox(height: AppSpacing.xl),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.edge),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Ingredients', style: AppTextStyles.sectionHeader16),
                      InkWell(
                        onTap: () {},
                        borderRadius: BorderRadius.circular(AppRadii.sm),
                        child: Row(
                          children: [
                            const Icon(Icons.add, size: AppSizes.iconSm, color: AppColors.textTertiary),
                            const SizedBox(width: AppSpacing.xxs),
                            Text(
                              'Add',
                              style: AppTextStyles.caption12.copyWith(color: AppColors.textTertiary, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.edge),
                  child: Column(
                    children: mealData.ingredients.map((ingredient) {
                      final isAlert = widget.showAllergyAlert && ingredient.name == 'Salmon Fillet';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: IngredientRow(
                          ingredient: ingredient,
                          highlighted: isAlert,
                          alertText: isAlert ? 'Contains: Fish' : null,
                          onTap: () => Get.to(() => IngredientDetailScreen(ingredient: ingredient)),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
              child: _MealDetailTopBar(
                onBack: () => Navigator.of(context).maybePop(),
                onBookmark: _toggleFavorite,
                isFavorite: mealData.isFavorite,
                onMenu: () => _showActionSheet(context),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.edge, AppSpacing.sm, AppSpacing.edge, AppSpacing.md),
          child: Row(
            children: [
              Expanded(
                child: OutlinePillButton(
                  label: 'Fix Issue',
                  icon: Icons.auto_fix_high,
                  onTap: () => Get.to(() => const FixResultScreen()),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: GradientPillButton(
                  label: 'Done',
                  gradient: AppGradients.primary,
                  onTap: () => Get.back(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showActionSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: GlassActionSheet(
            items: [
              GlassActionSheetItem(label: 'Share', icon: Icons.share_outlined, onTap: () => Navigator.pop(context)),
              GlassActionSheetItem(
                label: 'Report',
                icon: Icons.report_outlined,
                onTap: () {
                  Navigator.pop(context);
                  Get.to(() => const ReportMealScreen());
                },
              ),
              GlassActionSheetItem(label: 'Save Image', icon: Icons.download_outlined, onTap: () => Navigator.pop(context)),
              GlassActionSheetItem(
                label: 'Delete',
                icon: Icons.delete_outline,
                color: AppColors.destructive,
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPortionPicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.lg)),
      builder: (context) {
        return PickerSheet(
          options: const [
            'portion (300 g)',
            'small portion (150 g)',
            '100 g',
            '1 g',
          ],
          selectedIndex: 3,
        );
      },
    );
  }

  void _showMealtimePicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.lg)),
      builder: (context) {
        return const PickerSheet(
          options: [
            'Breakfast',
            'Morning snack',
            'Lunch',
            'Afternoon snack',
            'Dinner',
            'Second dinner',
          ],
          selectedIndex: 2,
        );
      },
    );
  }

  void _showDatePicker(BuildContext context, DateTime selectedDate) {
    showModalBottomSheet<void>(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.lg)),
      builder: (context) {
        return DatePickerCard(
          month: DateTime(selectedDate.year, selectedDate.month),
          selectedDate: selectedDate,
        );
      },
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final suffix = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $suffix';
  }

  String _formatDate(DateTime date) {
    return '${date.day}. ${date.month}. ${date.year}';
  }

  String _matchText(MatchBadgeVariant variant) {
    switch (variant) {
      case MatchBadgeVariant.medium:
        return '72% Match';
      case MatchBadgeVariant.low:
        return '48% Match';
      case MatchBadgeVariant.good:
        return '94% Match';
    }
  }
}

class _MealDetailTopBar extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onBookmark;
  final VoidCallback onMenu;
  final bool isFavorite;

  const _MealDetailTopBar({
    required this.onBack,
    required this.onBookmark,
    required this.onMenu,
    required this.isFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSizes.mealTopBarHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _GlassIconButton(icon: Icons.chevron_left, onTap: onBack),
          Row(
            children: [
              _GlassIconButton(icon: isFavorite ? Icons.bookmark : Icons.bookmark_border, onTap: onBookmark),
              const SizedBox(width: AppSpacing.sm),
              _GlassIconButton(icon: Icons.more_horiz, onTap: onMenu),
            ],
          ),
        ],
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _GlassIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.pill),
      child: Ink(
        width: AppSizes.backButtonSize,
        height: AppSizes.backButtonSize,
        decoration: BoxDecoration(
          color: AppColors.glassSheet,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          boxShadow: AppShadows.cardSmall,
        ),
        child: Icon(icon, size: AppSizes.iconMd, color: AppColors.textPrimary),
      ),
    );
  }
}

Meal get _stubMeal {
  return Meal(
    name: 'Salmon & Vegetables',
    timestamp: DateTime(2026, 1, 11, 13, 15),
    ingredients: [
      Ingredient(name: 'Salmon Fillet', weight: 34, calories: 565, proteins: 34, carbs: 0, fats: 15),
      Ingredient(name: 'Quinoa', weight: 34, calories: 120, proteins: 34, carbs: 0, fats: 15),
      Ingredient(name: 'Broccoli', weight: 34, calories: 55, proteins: 34, carbs: 0, fats: 15),
      Ingredient(name: 'Bell Peppers', weight: 34, calories: 45, proteins: 34, carbs: 0, fats: 15),
      Ingredient(name: 'Olive Oil', weight: 34, calories: 65, proteins: 34, carbs: 0, fats: 15),
    ],
  );
}
