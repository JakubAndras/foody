import 'package:diplomka/model/day_record.dart';

class NutritionGoals {
  const NutritionGoals({
    required this.calorieGoal,
    required this.proteinGoal,
    required this.carbsGoal,
    required this.fatGoal,
  });

  static const NutritionGoals defaults = NutritionGoals(
    calorieGoal: 2000,
    proteinGoal: 150,
    carbsGoal: 250,
    fatGoal: 70,
  );

  final double calorieGoal;
  final double proteinGoal;
  final double carbsGoal;
  final double fatGoal;

  factory NutritionGoals.fromDayRecord(DayRecord record) {
    return NutritionGoals(
      calorieGoal: record.calorieGoal,
      proteinGoal: record.proteinGoal,
      carbsGoal: record.carbsGoal,
      fatGoal: record.fatGoal,
    );
  }

  DayRecord applyToDayRecord(DayRecord record) {
    return record.copyWith(
      calorieGoal: calorieGoal,
      proteinGoal: proteinGoal,
      carbsGoal: carbsGoal,
      fatGoal: fatGoal,
    );
  }

  NutritionGoals copyWith({
    double? calorieGoal,
    double? proteinGoal,
    double? carbsGoal,
    double? fatGoal,
  }) {
    return NutritionGoals(
      calorieGoal: calorieGoal ?? this.calorieGoal,
      proteinGoal: proteinGoal ?? this.proteinGoal,
      carbsGoal: carbsGoal ?? this.carbsGoal,
      fatGoal: fatGoal ?? this.fatGoal,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NutritionGoals && other.calorieGoal == calorieGoal && other.proteinGoal == proteinGoal && other.carbsGoal == carbsGoal && other.fatGoal == fatGoal;
  }

  @override
  int get hashCode => Object.hash(calorieGoal, proteinGoal, carbsGoal, fatGoal);
}
