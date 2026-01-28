import 'package:diplomka/controller/dashboard_controller.dart';
import 'package:diplomka/model/ingredient.dart';
import 'package:diplomka/model/meal.dart';
import 'package:diplomka/controller/day_record_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:diplomka/app_theme.dart';
import 'package:diplomka/model/day_record.dart';
import 'edit_ingredient_screen.dart';

class EditMealScreen extends GetView<_EditMealScreenController> {
  final DayRecord? dayRecord;
  final Meal meal;
  final bool isNewMeal;

  const EditMealScreen({super.key, this.dayRecord, required this.meal, this.isNewMeal = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GetBuilder<_EditMealScreenController>(
        init: _EditMealScreenController(dayRecord: dayRecord, meal: meal, isNewMeal: isNewMeal),
        builder: (_EditMealScreenController controller) {
          return Scaffold(
            //backgroundColor: Colors.black54, // 1. Set Scaffold background
            body: SafeArea(
              top: false,
              child: Stack(
                children: [
                  CustomScrollView(
                    slivers: <Widget>[
                      SliverAppBar(
                        backgroundColor: Colors.transparent,
                        // 2. Make AppBar transparent
                        expandedHeight: 200.0,
                        pinned: false,
                        floating: false,
                        snap: false,
                        elevation: 0,
                        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Get.back()),
                        actions: [
                          if (isNewMeal == false)
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => controller.onTapDeleteMeal(),
                            ),
                          IconButton(
                            icon: const Icon(Icons.more_vert),
                            onPressed: () {
                              /* TODO: Implement Delete and etc */
                            },
                          ),
                        ],
                        flexibleSpace: FlexibleSpaceBar(
                          background: const Center(child: Icon(Icons.image, size: 100, color: Colors.white)),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(32.0),
                              topRight: Radius.circular(32.0),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(AppTheme.paddingM),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                _buildMealNameCard(theme, controller, context),
                                const SizedBox(height: 8),
                                _buildCaloriesPortionsRow(theme, controller),
                                const SizedBox(height: 8),
                                _buildMacrosRow(theme, controller), // Changed method name
                                const SizedBox(height: 8),
                                _buildIngredientsSection(theme, controller, context),
                                const SizedBox(height: 192), // Space for FAB
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: 10,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.surfaceColor,
                            blurRadius: 14,
                            spreadRadius: 20,
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
            floatingActionButton: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: double.infinity,
                child: FloatingActionButton.extended(
                  onPressed: () => controller.saveMeal(context),
                  label: Text('Save', style: theme.textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            // floatingActionButton: FloatingActionButton.extended(
            //   onPressed: () => controller.saveMeal(context),
            //   label: Text(
            //     'Save',
            //     style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
            //   ),
            //   backgroundColor: Colors.black,
            //   foregroundColor: Colors.white,
            //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            //   elevation: 0.0,
            //   extendedPadding: const EdgeInsets.symmetric(horizontal: 60),
            // ),
          );
        });
  }

  Widget _buildMealNameCard(ThemeData theme, _EditMealScreenController controller, BuildContext context) {
    String mealTime = "${meal.timestamp.hour}:${meal.timestamp.minute.toString().padLeft(2, '0')}";
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller.mealNameController,
            style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis),
            decoration: InputDecoration(
              hintText: "Meal name",
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: AppTheme.paddingXS),
            ),
            maxLines: 1,
            // Or null for multiline, adjust as needed
            textInputAction: TextInputAction.done,
          ),
        ),
        const SizedBox(width: 16),
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Text(
                  mealTime,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              SizedBox(height: 16)
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCaloriesPortionsRow(ThemeData theme, _EditMealScreenController controller) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _buildInfoCard(theme, 'Calories', controller.totalCalories.toString())),
          const SizedBox(width: 12),
          Expanded(child: _buildPortionsCard(theme)),
        ],
      ),
    );
  }

  Widget _buildInfoCard(ThemeData theme, String label, String value) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
            Text(value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            //const SizedBox(height: 4), // Added space for better layout
          ],
        ),
      ),
    );
  }

  Widget _buildPortionsCard(ThemeData theme) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.start,
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Portions", style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
            Row(
              children: [
                GestureDetector(
                  onTap: () => controller.portions.value = (controller.portions.value > 1 ? controller.portions.value - 1 : 1),
                  child: const Padding(
                    padding: EdgeInsets.all(0.0),
                    child: Icon(Icons.remove),
                  ),
                ),
                const Spacer(),
                Obx(
                  () => Text(
                    controller.portions.value.toString(),
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => controller.portions.value++,
                  child: const Padding(
                    padding: EdgeInsets.all(0.0), // Optional padding for tap area
                    child: Icon(Icons.add),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacrosRow(ThemeData theme, _EditMealScreenController controller) {
    // Renamed method
    return Row(
      // Changed from GridView
      children: [
        Expanded(
          // Added Expanded
          child: _buildMacroValueCard(theme, 'P', 'Proteins', controller.totalProteins.toDouble(), 'g', Colors.red.shade300, () {
            /* TODO: Edit Proteins */
          }),
        ),
        const SizedBox(width: 8), // Added for spacing between cards
        Expanded(
          // Added Expanded
          child: _buildMacroValueCard(theme, 'C', 'Carbs', controller.totalCarbs.toDouble(), 'g', Colors.orange.shade300, () {
            /* TODO: Edit Carbs */
          }),
        ),
        const SizedBox(width: 8), // Added for spacing between cards
        Expanded(
          // Added Expanded
          child: _buildMacroValueCard(theme, 'F', 'Fats', controller.totalFats.toDouble(), 'g', Colors.blue.shade300, () {
            /* TODO: Edit Fat */
          }),
        ),
      ],
    );
  }

  Widget _buildIngredientsSection(ThemeData theme, _EditMealScreenController controller, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Ingredients", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              TextButton.icon(
                icon: const Icon(Icons.add_circle_outline, size: 20),
                label: const Text("Add New"),
                onPressed: () => controller.navigateToEditIngredientScreen(context),
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
              ),
            ],
          ),
          SizedBox(height: 8),
          Obx(() {
            if (controller.ingredients.isEmpty) {
              return const Center(child: Text("No ingredients added yet."));
            }
            return Column(
              children: controller.ingredients.map((ingredient) {
                final index = controller.ingredients.indexOf(ingredient);
                return Card(
                  elevation: 0.5,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  child: ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            meal.name,
                            style: Theme.of(context).textTheme.titleSmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 4,),
                        Text(
                          '${meal.totalCalories.toStringAsFixed(0)} kcal',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ],
                    ),
                    subtitle: Row(
                      children: [
                        CircleAvatar(backgroundColor: Colors.red.shade300.withOpacity(0.2), radius: 12, child: Text('P', style: TextStyle(color: Colors.red.shade300, fontWeight: FontWeight.bold, fontSize: 12))),
                        SizedBox(width: 2,),
                        Text(
                          '${meal.totalProteins.toStringAsFixed(0)}g',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        SizedBox(width: 12,),

                        CircleAvatar(backgroundColor: Colors.orange.shade300.withOpacity(0.2), radius: 12, child: Text('C', style: TextStyle(color: Colors.orange.shade300, fontWeight: FontWeight.bold, fontSize: 12))),
                        SizedBox(width: 2,),
                        Text(
                          '${meal.totalCarbs.toStringAsFixed(0)}g',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        SizedBox(width: 12,),

                        CircleAvatar(backgroundColor: Colors.blue.shade300.withOpacity(0.2), radius: 12, child: Text('F', style: TextStyle(color: Colors.blue.shade300, fontWeight: FontWeight.bold, fontSize: 12))),
                        SizedBox(width: 2,),
                        Text(
                          '${meal.totalFats.toStringAsFixed(0)}g',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ],
                    ),
                    onTap: () => controller.navigateToEditIngredientScreen(context, ingredient: ingredient, index: index),
                  ),
                );
              }).toList(),
            );

          }),
        ],
      ),
    );
  }

  Widget _buildMacroValueCard(ThemeData theme, String iconChar, String label, double value, String unit, Color color, VoidCallback onEditTap) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.start,
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(backgroundColor: color.withOpacity(0.2), radius: 12, child: Text(iconChar, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12))),
                    const SizedBox(width: 6),
                    Text(label, style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
            Text("${value.toStringAsFixed(value % 1 == 0 ? 0 : 1)}$unit", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _EditMealScreenController extends GetxController {
  final DayRecord? dayRecord;
  final Meal meal;
  final bool isNewMeal;

  late TextEditingController mealNameController;
  final RxList<Ingredient> ingredients = <Ingredient>[].obs;
  final RxInt portions = 1.obs;

  _EditMealScreenController({this.dayRecord, required this.meal, required this.isNewMeal});

  @override
  void onInit() {
    super.onInit();
    mealNameController = TextEditingController(text: meal.name);
    ingredients.assignAll(meal.ingredients.map((ing) => ing.copyWith()).toList());
    // Assuming portions are part of initialMeal or default to 1
    // portions.value = initialMeal.portions ?? 1; // If Meal model has portions
  }

  @override
  void onClose() {
    mealNameController.dispose();
    super.onClose();
  }

  void updateIngredient(int index, Ingredient newIngredient) {
    ingredients[index] = newIngredient;
  }

  void addIngredient(Ingredient newIngredient) {
    ingredients.add(newIngredient);
  }

  void removeIngredient(int index) {
    ingredients.removeAt(index);
  }

  Future<void> navigateToEditIngredientScreen(BuildContext context, {Ingredient? ingredient, int? index}) async {
    final result = await Get.to(() => EditIngredientScreen(
          initialIngredient: ingredient,
        ));

    if (result is Ingredient) {
      if (ingredient == null || index == null) {
        addIngredient(result);
      } else {
        updateIngredient(index, result);
      }
    } else if (result == 'DELETED' && index != null) {
      removeIngredient(index);
    }
  }

  Future<void> saveMeal(BuildContext context) async {
    if (mealNameController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a meal name.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final mealToSave = Meal(
      id: meal.id,
      name: mealNameController.text,
      ingredients: ingredients.toList(),
      timestamp: meal.timestamp,
      // portions: portions.value, // Include portions if your Meal model supports it
    );
    // TODO: Replace DateTime.now() with your actual GetX based selectedDate logic
    // e.g., final selectedDate = Get.find<SelectedDateController>().selectedDate.value;
    final DateTime selectedDate = DateTime.now();

    DayRecordController.to.addMealToDayRecord(dayRecord: dayRecord ?? DayRecord.initial(selectedDate), mealToSave: mealToSave);
    Get.back();
  }

  void showEditMealNameDialog(BuildContext context) {
    final TextEditingController tempNameController = TextEditingController(text: mealNameController.text);
    Get.dialog(
      AlertDialog(
        title: const Text('Edit Meal Name'),
        content: TextField(
          controller: tempNameController,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Enter meal name'),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (tempNameController.text.isNotEmpty) {
                mealNameController.text = tempNameController.text;
              }
              Get.back();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // Computed properties
  int get totalCalories => ingredients.fold(0, (sum, item) => (sum + item.calories).toInt()) * portions.value;

  int get totalProteins => ingredients.fold(0, (sum, item) => (sum + item.proteins).toInt()) * portions.value;

  int get totalCarbs => ingredients.fold(0, (sum, item) => (sum + item.carbs).toInt()) * portions.value;

  int get totalFats => ingredients.fold(0, (sum, item) => (sum + item.fats).toInt()) * portions.value;

  String get healthScore {
    // Placeholder - implement your health score logic
    return "7/10";
  }

  Future<void> onTapDeleteMeal() async {
    if (dayRecord != null) {
      dayRecord?.meals.remove(meal);
      await DayRecordController.to.updateDayRecord(dayRecord!);
      DashboardController.to.refresh();
      Get.back();
    }
  }
}
