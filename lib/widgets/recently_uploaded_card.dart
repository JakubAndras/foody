import 'dart:async';
import 'dart:math';

import 'package:diplomka/controller/dashboard_controller.dart';
import 'package:diplomka/model/meal.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.paddingS),
          child: Text(
            "Today's meals",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: AppTheme.paddingS),
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
              children.add(const SizedBox(height: AppTheme.paddingS));
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
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.food_bank_outlined,
                size: 30,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Tap + to add your first meal of the day',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealsList(BuildContext context) {
    return Column(
      children: meals.map((meal) => _buildMealItem(context, meal)).toList(),
    );
  }

  Widget _buildMealItem(BuildContext context, Meal meal) {
    String mealTime = "${meal.timestamp.hour}:${meal.timestamp.minute.toString().padLeft(2, '0')}";

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: AppTheme.paddingXS),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            Icons.restaurant_menu,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
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
              mealTime, // Assumed field for time
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text('${meal.totalCalories.toStringAsFixed(0)} Calories', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 4),
            Row(
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
            )
          ],
        ),
        onTap: () {
          onMealTap?.call(meal);
        },
        contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
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
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: AppTheme.paddingXS),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: _progress,
                    strokeWidth: 3.0,
                    valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                  ),
                  Text(
                    '${(_progress * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Analyzing your meal, please wait...',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
