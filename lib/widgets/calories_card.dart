import 'package:flutter/material.dart';

import 'package:diplomka/model/day_record.dart';

class CaloriesCard extends StatelessWidget {
  const CaloriesCard({super.key, required this.dayRecord, this.caloriesPlanEnabled = true});

  final DayRecord dayRecord;
  final bool caloriesPlanEnabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                caloriesPlanEnabled
                  ? dayRecord.caloriesLeft.toStringAsFixed(0)
                  : dayRecord.totalCalories.toStringAsFixed(0),
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              caloriesPlanEnabled
                ? const Text('Calories left')
                : const Text('Calories eaten'),
            ],
          ),
          // Container(
          //   width: 80,
          //   height: 80,
          //   decoration: BoxDecoration(
          //     shape: BoxShape.circle,
          //     border: Border.all(
          //       color: Colors.grey.shade300,
          //       width: 4,
          //     ),
          //   ),
          //   child: Icon(
          //     Icons.local_fire_department,
          //     size: 40,
          //     color: Colors.grey.shade400,
          //   ),
          // ),
        ],
      ),
    );
  }
}
