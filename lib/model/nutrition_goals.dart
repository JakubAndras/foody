import 'package:diplomka/model/day_record.dart';
import 'package:diplomka/model/user_profile.dart';

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

  /// Calculates nutrition goals from user profile using Mifflin-St Jeor equation.
  /// [workoutsPerWeek] maps to activity multiplier: 0-1 → 1.2, 2-3 → 1.375, 4-5 → 1.55, 6+ → 1.725.
  factory NutritionGoals.fromProfile({
    required double weightKg,
    required double heightCm,
    required DateTime dateOfBirth,
    required ProfileSex sex,
    required ProfileGoal goal,
    String workoutsPerWeek = '2-3',
  }) {
    final int age = DateTime.now().difference(dateOfBirth).inDays ~/ 365;

    // Mifflin-St Jeor BMR
    double bmr;
    if (sex == ProfileSex.male) {
      bmr = 10 * weightKg + 6.25 * heightCm - 5 * age + 5;
    } else {
      bmr = 10 * weightKg + 6.25 * heightCm - 5 * age - 161;
    }

    // Activity multiplier
    final double activityMultiplier = switch (workoutsPerWeek) {
      '0-1' => 1.2,
      '2-3' => 1.375,
      '4-5' => 1.55,
      '6+' => 1.725,
      _ => 1.375,
    };

    double tdee = bmr * activityMultiplier;

    // Goal adjustment
    switch (goal) {
      case ProfileGoal.lose:
        tdee -= 500;
        break;
      case ProfileGoal.gain:
        tdee += 300;
        break;
      case ProfileGoal.maintain:
        break;
    }

    tdee = tdee.clamp(1200, 5000);

    // Macro split: 30% protein, 40% carbs, 30% fat
    final double proteinCal = tdee * 0.30;
    final double carbsCal = tdee * 0.40;
    final double fatCal = tdee * 0.30;

    return NutritionGoals(
      calorieGoal: (tdee / 10).round() * 10.0,
      proteinGoal: (proteinCal / 4).round().toDouble(),
      carbsGoal: (carbsCal / 4).round().toDouble(),
      fatGoal: (fatCal / 9).round().toDouble(),
    );
  }

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
