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
  /// [weightChangeRateKgPerWeek] — desired weekly weight change (0.1–1.5 kg).
  /// Deficit/surplus scales with the rate:
  ///   Lose: ~1000 kcal per kg/week, clamped to 300–1200.
  ///   Gain: ~700 kcal per kg/week, clamped to 150–700.
  /// Falls back to 500 kcal deficit / 300 kcal surplus when rate is null.
  factory NutritionGoals.fromProfile({
    required double weightKg,
    required double heightCm,
    required DateTime dateOfBirth,
    required ProfileSex sex,
    required ProfileGoal goal,
    String workoutsPerWeek = '2-3',
    double? weightChangeRateKgPerWeek,
  }) {
    final int age = DateTime.now().difference(dateOfBirth).inDays ~/ 365;

    // Mifflin-St Jeor BMR. For ProfileSex.other we average the male (+5) and
    // female (-161) constants to avoid silently biasing the goal either way.
    final double sexConstant = switch (sex) {
      ProfileSex.male => 5,
      ProfileSex.female => -161,
      ProfileSex.other => -78,
    };
    double bmr = 10 * weightKg + 6.25 * heightCm - 5 * age + sexConstant;

    // Activity multiplier
    final double activityMultiplier = switch (workoutsPerWeek) {
      '0-1' => 1.2,
      '2-3' => 1.375,
      '4-5' => 1.55,
      '6+' => 1.725,
      _ => 1.375,
    };

    double tdee = bmr * activityMultiplier;

    // Goal adjustment — scale with weight change rate when available
    switch (goal) {
      case ProfileGoal.lose:
        final double deficit = weightChangeRateKgPerWeek != null ? (weightChangeRateKgPerWeek * 1000).clamp(300, 1200) : 500;
        tdee -= deficit;
        break;
      case ProfileGoal.gain:
        final double surplus = weightChangeRateKgPerWeek != null ? (weightChangeRateKgPerWeek * 700).clamp(150, 700) : 300;
        tdee += surplus;
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
