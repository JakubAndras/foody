import 'package:diplomka/widgets/macros_card.dart';
import 'package:flutter/material.dart';

import '../model/day_record.dart';

class MacrosRow extends StatelessWidget {
  const MacrosRow({super.key, required this.dayRecord, this.caloriesPlanEnabled = true});

  final DayRecord dayRecord;
  final bool caloriesPlanEnabled;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MacrosCard(
          title: caloriesPlanEnabled ? 'Protein left' : 'Proteins',
          value: caloriesPlanEnabled ? '${dayRecord.proteinsLeft.toStringAsFixed(0)}g' : '${dayRecord.totalProteins.toStringAsFixed(0)}g',
          icon: Icons.fastfood,
          iconColor: Colors.red,
        ),
        const SizedBox(width: 4),
        MacrosCard(
          title: caloriesPlanEnabled ? 'Carbs left' : 'Carbs',
          value: caloriesPlanEnabled ? '${dayRecord.carbsLeft.toStringAsFixed(0)}g' : '${dayRecord.totalCarbs.toStringAsFixed(0)}g',
          icon: Icons.bakery_dining,
          iconColor: Colors.orange,
        ),
        const SizedBox(width: 4),
        MacrosCard(
          title: caloriesPlanEnabled ? 'Fats left' : 'Fats',
          value: caloriesPlanEnabled ? '${dayRecord.fatsLeft.toStringAsFixed(0)}g' : '${dayRecord.totalFats.toStringAsFixed(0)}g',
          icon: Icons.icecream,
          iconColor: Colors.blue,
        ),
      ],
    );
  }
}
